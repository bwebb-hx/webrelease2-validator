#!/usr/bin/env ruby
# File-Based Test Runner for WebRelease2 Validator
# Tests individual HTML files with embedded metadata

require_relative 'webrelease2_validator'
require 'find'

class FileTestRunner
  def initialize(test_dir = 'tests/individual')
    @validator = WebRelease2Validator.new
    @test_dir = test_dir
    @passed_tests = 0
    @failed_tests = 0
    @total_test_cases = 0
  end

  def run_all_tests(verbose: false)
    puts "🧪 Running File-Based WebRelease2 Validation Tests"
    puts "=" * 55

    # Find all test categories
    categories = Dir.entries(@test_dir).select { |entry| 
      File.directory?(File.join(@test_dir, entry)) && !entry.start_with?('.') 
    }.sort

    categories.each do |category|
      run_category_tests(category, verbose)
    end

    print_summary
  end

  def run_category(category, verbose: false)
    puts "🎯 Running #{category.capitalize.gsub('-', ' ')} Tests"
    puts "=" * 50

    if Dir.exist?(File.join(@test_dir, category))
      run_category_tests(category, verbose)
    else
      puts "❌ Category '#{category}' not found!"
      puts "Available categories: #{list_categories.join(', ')}"
      return
    end

    print_summary
  end

  def list_categories
    Dir.entries(@test_dir).select { |entry| 
      File.directory?(File.join(@test_dir, entry)) && !entry.start_with?('.') 
    }.sort
  end

  def run_single_test(test_file, verbose: false)
    unless File.exist?(test_file)
      puts "❌ Test file '#{test_file}' not found!"
      return
    end

    puts "🧪 Running Single Test: #{File.basename(test_file)}"
    puts "-" * 40

    run_test_file(test_file, verbose)
    print_summary
  end

  private

  def run_category_tests(category, verbose)
    category_path = File.join(@test_dir, category)
    test_files = Dir.glob(File.join(category_path, '*.html')).sort

    if test_files.empty?
      puts "\n📋 #{category.capitalize.gsub('-', ' ')} Tests - No test files found"
      return
    end

    puts "\n📋 #{category.capitalize.gsub('-', ' ')} Tests (#{test_files.length} files)"
    puts "-" * 40

    test_files.each do |test_file|
      run_test_file(test_file, verbose)
    end
  end

  def run_test_file(test_file, verbose)
    @total_test_cases += 1
    
    # Parse test metadata
    metadata = parse_test_metadata(test_file)
    test_name = metadata['name'] || File.basename(test_file, '.html')
    expected_result = metadata['expected_result'] || 'unknown'
    expected_error = metadata['expected_error_message']
    description = metadata['description']

    # Run validator
    errors = @validator.validate_file(test_file)

    case expected_result
    when 'valid'
      if errors.empty?
        puts "  ✅ #{test_name}"
        @passed_tests += 1
      else
        puts "  ❌ #{test_name}"
        if verbose
          puts "     Expected: No errors"
          puts "     Got: #{errors.size} error(s):"
          errors.each { |err| puts "       - Line #{err.line_number}: #{err.message}" }
        end
        @failed_tests += 1
      end

    when 'error'
      if expected_error
        found_error = errors.any? { |err| err.message.include?(expected_error) }
        if found_error
          puts "  ✅ #{test_name}"
          @passed_tests += 1
        else
          puts "  ❌ #{test_name}"
          if verbose
            puts "     Expected error containing: '#{expected_error}'"
            if errors.empty?
              puts "     Got: No errors"
            else
              puts "     Got #{errors.size} error(s):"
              errors.each { |err| puts "       - Line #{err.line_number}: #{err.message}" }
            end
          end
          @failed_tests += 1
        end
      else
        # Just expect any error
        if errors.any?
          puts "  ✅ #{test_name}"
          @passed_tests += 1
        else
          puts "  ❌ #{test_name}"
          if verbose
            puts "     Expected: At least one error"
            puts "     Got: No errors"
          end
          @failed_tests += 1
        end
      end

    else
      puts "  ⚠️  #{test_name} - Unknown expected result: #{expected_result}"
      @failed_tests += 1
    end

    # Show description in verbose mode
    if verbose && description
      puts "     Description: #{description}"
    end
  end

  def parse_test_metadata(file_path)
    metadata = {}
    
    File.open(file_path, 'r') do |file|
      in_meta = false
      file.each_line do |line|
        if line.strip == '<!-- TEST_META:'
          in_meta = true
          next
        elsif line.strip == '-->' && in_meta
          break
        elsif in_meta
          # Parse key: "value" format
          if match = line.match(/\s*(\w+):\s*"([^"]*)"/)
            metadata[match[1]] = match[2]
          end
        end
      end
    end
    
    metadata
  end

  def print_summary
    puts "\n" + "=" * 55
    puts "📊 Test Summary"
    puts "Total test cases: #{@total_test_cases}"
    puts "Passed: #{@passed_tests}"
    puts "Failed: #{@failed_tests}"
    
    if @total_test_cases > 0
      success_rate = (@passed_tests.to_f / @total_test_cases * 100).round(1)
      puts "Success rate: #{success_rate}%"
    end
    
    if @failed_tests == 0
      puts "\n🎉 All tests passed!"
    else
      puts "\n⚠️  #{@failed_tests} test(s) failed. Use --verbose for details."
    end
  end
end

# CLI interface
if __FILE__ == $0
  runner = FileTestRunner.new

  # Parse command line arguments
  verbose = ARGV.include?('--verbose') || ARGV.include?('-v')
  category = nil
  test_file = nil
  
  ARGV.each do |arg|
    next if arg.start_with?('-')
    if File.exist?(arg)
      test_file = arg
    else
      category = arg
    end
  end

  if ARGV.include?('--help') || ARGV.include?('-h')
    puts "Usage: ruby #{$0} [category|file] [options]"
    puts ""
    puts "Options:"
    puts "  --verbose, -v    Show detailed error information"
    puts "  --help, -h       Show this help message"
    puts "  --list           List available test categories"
    puts ""
    puts "Examples:"
    puts "  ruby #{$0}                           # Run all tests"
    puts "  ruby #{$0} valid                     # Run only valid tests"
    puts "  ruby #{$0} syntax-error              # Run only syntax error tests"
    puts "  ruby #{$0} tests/individual/valid/basic-if-structure.html  # Run single test"
    puts "  ruby #{$0} --verbose                 # Run all tests with detailed output"
    exit 0
  end

  if ARGV.include?('--list')
    puts "📋 Available Test Categories:"
    runner.list_categories.each { |cat| puts "  - #{cat}" }
    exit 0
  end

  if test_file
    runner.run_single_test(test_file, verbose: verbose)
  elsif category
    runner.run_category(category, verbose: verbose)
  else
    runner.run_all_tests(verbose: verbose)
  end
end