#!/usr/bin/env ruby
# Test Summary - Overview of WebRelease2 Validator Test Coverage

require 'find'

class TestSummary
  def initialize(test_dir = 'tests/individual')
    @test_dir = test_dir
  end

  def generate_summary
    puts "📊 WebRelease2 Validator Test Coverage Summary"
    puts "=" * 55

    categories = get_test_categories
    total_tests = 0

    categories.each do |category|
      files = get_test_files(category)
      total_tests += files.length
      
      puts "\n📂 #{category.capitalize.gsub('-', ' ')} Tests: #{files.length} files"
      puts "   " + "-" * 45
      
      files.sort.each do |file|
        metadata = parse_test_metadata(file)
        name = metadata['name'] || File.basename(file, '.html').gsub('-', ' ').capitalize
        description = metadata['description'] || 'No description'
        
        puts "   ✓ #{name}"
        puts "     #{description}" if description != 'No description'
      end
    end

    puts "\n" + "=" * 55
    puts "📈 Coverage Summary:"
    puts "Total test categories: #{categories.length}"
    puts "Total individual test cases: #{total_tests}"
    
    puts "\n🎯 Validation Rules Covered:"
    print_validation_rules_covered
    
    puts "\n🚀 How to run tests:"
    puts "ruby file_test_runner.rb                    # Run all tests"
    puts "ruby file_test_runner.rb valid              # Run valid template tests"
    puts "ruby file_test_runner.rb syntax-error       # Run syntax error tests"
    puts "ruby file_test_runner.rb --verbose          # Detailed output"
    puts "ruby file_test_runner.rb --list             # List all categories"
  end

  private

  def get_test_categories
    Dir.entries(@test_dir).select { |entry| 
      File.directory?(File.join(@test_dir, entry)) && !entry.start_with?('.') 
    }.sort
  end

  def get_test_files(category)
    Dir.glob(File.join(@test_dir, category, '*.html'))
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
          if match = line.match(/\s*(\w+):\s*"([^"]*)"/)
            metadata[match[1]] = match[2]
          end
        end
      end
    end
    
    metadata
  end

  def print_validation_rules_covered
    rules = [
      "✅ Expression syntax validation (%expression%)",
      "✅ Element structure validation (opening/closing tags)",
      "✅ Required attribute validation",
      "✅ Attribute value validation (empty, numeric, variable names)",
      "✅ Context-aware validation (parent-child relationships)", 
      "✅ Self-closing element validation",
      "✅ WebRelease2 comment syntax validation",
      "✅ Function call validation (parentheses, quotes)",
      "✅ Element reference validation (dot notation, array access)",
      "✅ Variable name validation (reserved keywords, format)",
      "✅ Loop source validation (wr-for combinations)",
      "✅ Malformed tag detection",
      "✅ Unclosed element detection",
      "✅ Mismatched closing tag detection"
    ]
    
    rules.each { |rule| puts "   #{rule}" }
  end
end

# Run the summary
if __FILE__ == $0
  summary = TestSummary.new
  summary.generate_summary
end