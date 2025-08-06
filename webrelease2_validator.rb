#!/usr/bin/env ruby
# frozen_string_literal: true

=begin
WebRelease2 Template Validator

A comprehensive validator for WebRelease2 template files that checks:
- Expression syntax (%expression%)
- WebRelease2 custom elements (wr-if, wr-for, etc.)
- Element references and function calls
- Template structure and nesting

Usage: ruby webrelease2_validator.rb <template_file>
=end

require 'optparse'

class ValidationError
  attr_reader :line_number, :column, :error_type, :message, :context

  def initialize(line_number, column, error_type, message, context)
    @line_number = line_number
    @column = column
    @error_type = error_type
    @message = message
    @context = context
  end

  def to_s
    "Line #{@line_number}:#{@column} - #{@error_type}: #{@message}"
  end
end

class WebRelease2Validator
  ERROR_TYPES = {
    syntax: 'Syntax Error',
    attribute: 'Attribute Error',
    reference: 'Reference Error',
    structure: 'Structure Error',
    function: 'Function Error'
  }.freeze

  def initialize
    # Known WebRelease2 functions from the documentation
    @known_functions = %w[
      currentTime formatDate string length substring
      number divide setScale pageTitle pageURL
      isNull isNotNull count selectedPage
      selectedName selectedValue generateText
    ].to_set

    # WebRelease2 custom elements and their required/optional attributes
    @wr_elements = {
      'wr-if' => { required: %w[condition], optional: [] },
      'wr-then' => { required: [], optional: [] },
      'wr-else' => { required: [], optional: [] },
      'wr-switch' => { required: %w[value], optional: [] },
      'wr-case' => { required: %w[value], optional: [] },
      'wr-default' => { required: [], optional: [] },
      'wr-conditional' => { required: [], optional: [] },
      'wr-cond' => { required: %w[condition], optional: [] },
      'wr-for' => { required: %w[variable], optional: %w[list string times count index] },
      'wr-break' => { required: [], optional: %w[condition] },
      'wr-variable' => { required: %w[name], optional: %w[value] },
      'wr-append' => { required: %w[name value], optional: [] },
      'wr-clear' => { required: %w[name], optional: [] },
      'wr-error' => { required: [], optional: %w[condition] },
      'wr-return' => { required: %w[value], optional: [] },
      'wr-->' => { required: [], optional: [] },
      'wr-comment' => { required: [], optional: [] }
    }.freeze

    @errors = []
  end

  def validate_file(filepath)
    @errors = []
    
    begin
      content = File.read(filepath)
      validate_content(content)
    rescue Errno::ENOENT
      @errors << ValidationError.new(0, 0, ERROR_TYPES[:syntax], 
                                   "File not found: #{filepath}", "")
    rescue => e
      @errors << ValidationError.new(0, 0, ERROR_TYPES[:syntax], 
                                   "Error reading file: #{e.message}", "")
    end

    @errors.sort_by { |error| [error.line_number, error.column] }
  end

  private

  def validate_content(content)
    lines = content.split("\n")
    element_stack = []

    lines.each_with_index do |line, index|
      line_num = index + 1
      validate_line(line, line_num, element_stack)
    end

    # Check for unclosed elements
    element_stack.each do |element, line_num|
      @errors << ValidationError.new(line_num, 0, ERROR_TYPES[:structure],
                                   "Unclosed element: #{element}", "")
    end
  end

  def validate_line(line, line_num, element_stack)
    validate_expressions(line, line_num)
    validate_wr_elements(line, line_num, element_stack)
  end

  def validate_expressions(line, line_num)
    # Find all expressions using %expression% pattern
    line.scan(/%([^%]*)%/).each_with_index do |(expression), index|
      start_pos = line.index("%#{expression}%")
      
      if expression.strip.empty?
        @errors << ValidationError.new(line_num, start_pos, ERROR_TYPES[:syntax],
                                     "Empty expression found", line.strip)
        next
      end

      validate_expression_content(expression, line_num, start_pos, line)
    end

    # Check for unmatched % symbols
    if line.count('%').odd?
      @errors << ValidationError.new(line_num, 0, ERROR_TYPES[:syntax],
                                   "Unmatched % symbol - expressions must be properly closed",
                                   line.strip)
    end
  end

  def validate_expression_content(expression, line_num, col, context)
    expression = expression.strip

    # Check for function calls
    if match = expression.match(/(\w+)\s*\(/)
      function_name = match[1]
      # Be permissive about functions since templates can define custom methods
      # Only check for obviously invalid function names
      unless function_name.match?(/^[a-zA-Z_]\w*$/)
        @errors << ValidationError.new(line_num, col, ERROR_TYPES[:function],
                                     "Invalid function name: #{function_name}",
                                     context.strip)
      end

      # Check for balanced parentheses
      unless balanced_parentheses?(expression)
        @errors << ValidationError.new(line_num, col, ERROR_TYPES[:syntax],
                                     "Unbalanced parentheses in function call",
                                     context.strip)
      end
      # Don't validate element references inside function calls
      return
    end

    # Check for element references (only if not a function call)
    if expression.include?('.') || expression.include?('[')
      validate_element_reference(expression, line_num, col, context)
    end
  end

  def validate_element_reference(expression, line_num, col, context)
    # Check for proper array access syntax
    if expression.include?('[')
      unless expression.match?(/\[\s*\d+\s*\]/) || expression.match?(/\[\s*\w+\s*\]/)
        @errors << ValidationError.new(line_num, col, ERROR_TYPES[:reference],
                                     "Invalid array access syntax - use [index] or [variable]",
                                     context.strip)
      end
    end

    # Check for proper dot notation
    if expression.include?('.')
      parts = expression.split('.')
      parts.each do |part|
        # Remove array access for validation
        clean_part = part.gsub(/\[.*?\]/, '').strip
        next if clean_part.empty? || clean_part.include?('(')

        unless clean_part.match?(/^[a-zA-Z_]\w*$/)
          @errors << ValidationError.new(line_num, col, ERROR_TYPES[:reference],
                                       "Invalid element reference: #{clean_part}",
                                       context.strip)
        end
      end
    end
  end

  def validate_wr_elements(line, line_num, element_stack)
    # Find opening tags with proper attribute parsing
    # This regex handles quoted attributes that may contain > characters
    # Special handling for wr--> comment syntax
    line.scan(/<(wr-(?:\w+|->))((?:\s+\w+\s*=\s*"(?:[^"\\]|\\.)*")*)\s*>/) do |element_name, attributes_str|
      if @wr_elements.key?(element_name)
        validate_wr_attributes(element_name, attributes_str, line_num, line)

        # Add to stack for nesting validation (except self-closing elements)
        unless %w[wr--> wr-break wr-variable wr-append wr-clear wr-return].include?(element_name)
          element_stack << [element_name, line_num]
        end
      else
        @errors << ValidationError.new(line_num, 0, ERROR_TYPES[:syntax],
                                     "Unknown WebRelease2 element: #{element_name}",
                                     line.strip)
      end
    end

    # Find closing tags (including special wr--> syntax)
    line.scan(/<\/(wr-(?:\w+|->))>/) do |closing_element|
      closing_element = closing_element[0]
      
      if element_stack.any?
        expected_element, _ = element_stack.last
        if expected_element == closing_element
          element_stack.pop
        else
          @errors << ValidationError.new(line_num, 0, ERROR_TYPES[:structure],
                                       "Mismatched closing tag: expected #{expected_element}, found #{closing_element}",
                                       line.strip)
        end
      else
        @errors << ValidationError.new(line_num, 0, ERROR_TYPES[:structure],
                                     "Unexpected closing tag: #{closing_element}",
                                     line.strip)
      end
    end

    # Handle special comment syntax - check for proper <wr--> and </wr--> pairing
    if line.include?('<wr-->')
      # Check if there's a matching closing tag
      unless line.include?('</wr-->')
        comment_start = line.index('<wr-->')
        @errors << ValidationError.new(line_num, comment_start, ERROR_TYPES[:syntax],
                                     "WebRelease2 comment must be closed with </wr--> on the same line",
                                     line.strip)
      end
    elsif line.include?('<wr--') && !line.include?('<wr-->')
      # Catch incorrect opening syntax like <wr-- instead of <wr-->
      comment_start = line.index('<wr--')
      @errors << ValidationError.new(line_num, comment_start, ERROR_TYPES[:syntax],
                                   "Invalid WebRelease2 comment syntax - use <wr--> to open comments",
                                   line.strip)
    end
  end

  def validate_wr_attributes(element_name, attributes_str, line_num, context)
    element_def = @wr_elements[element_name]
    required_attrs = element_def[:required].to_set
    optional_attrs = element_def[:optional].to_set
    all_valid_attrs = required_attrs + optional_attrs

    # Parse attributes
    found_attrs = Set.new
    attributes_str.scan(/(\w+)\s*=\s*"((?:[^"\\]|\\.)*)"/) do |attr_name, attr_value|
      found_attrs << attr_name

      # Check if attribute is valid for this element
      unless all_valid_attrs.include?(attr_name)
        @errors << ValidationError.new(line_num, 0, ERROR_TYPES[:attribute],
                                     "Invalid attribute '#{attr_name}' for element '#{element_name}'",
                                     context.strip)
      end

      validate_attribute_value(element_name, attr_name, attr_value, line_num, context)
    end

    # Check for missing required attributes
    missing_required = required_attrs - found_attrs
    if missing_required.any?
      @errors << ValidationError.new(line_num, 0, ERROR_TYPES[:attribute],
                                   "Missing required attributes for '#{element_name}': #{missing_required.to_a.join(', ')}",
                                   context.strip)
    end

    # Special validation for wr-for
    validate_wr_for_attributes(found_attrs, line_num, context) if element_name == 'wr-for'
  end

  def validate_wr_for_attributes(found_attrs, line_num, context)
    loop_sources = %w[list string times].to_set
    found_sources = loop_sources & found_attrs

    if found_sources.empty?
      @errors << ValidationError.new(line_num, 0, ERROR_TYPES[:attribute],
                                   "wr-for must have one of: list, string, or times",
                                   context.strip)
    elsif found_sources.size > 1
      @errors << ValidationError.new(line_num, 0, ERROR_TYPES[:attribute],
                                   "wr-for cannot combine: #{found_sources.to_a.join(', ')}",
                                   context.strip)
    end
  end

  def validate_attribute_value(element_name, attr_name, attr_value, line_num, context)
    # Validate condition attributes
    if attr_name == 'condition' && !attr_value.empty? 
      # Check for single quotes in function calls (should use double quotes)
      if attr_value.match?(/\w+\s*\(\s*'[^']*'\s*\)/)
        @errors << ValidationError.new(line_num, 0, ERROR_TYPES[:syntax],
                                     "Use double quotes for string literals in function calls, not single quotes",
                                     context.strip)
      end
      
      unless valid_condition?(attr_value)
        @errors << ValidationError.new(line_num, 0, ERROR_TYPES[:attribute],
                                     "Invalid condition syntax: #{attr_value}",
                                     context.strip)
      end
    end
  end

  def valid_condition?(condition)
    return false if condition.strip.empty?

    valid_operators = %w[== != < > <= >= && ||]
    common_functions = %w[isNull isNotNull number string count]

    # Allow conditions with valid operators or functions
    return true if valid_operators.any? { |op| condition.include?(op) }
    return true if common_functions.any? { |func| condition.include?(func) }

    # Allow simple variable references
    return true if condition.strip.match?(/^[a-zA-Z_]\w*(\.\w+)*$/)

    true # Be permissive for complex conditions
  end

  def balanced_parentheses?(expression)
    count = 0
    expression.each_char do |char|
      case char
      when '('
        count += 1
      when ')'
        count -= 1
        return false if count < 0
      end
    end
    count.zero?
  end
end

# CLI Interface
def main
  options = {}
  
  OptionParser.new do |opts|
    opts.banner = "Usage: ruby #{$0} [options] file"
    opts.on("-v", "--verbose", "Show detailed error information") do |v|
      options[:verbose] = v
    end
    opts.on("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end.parse!

  if ARGV.empty?
    puts "Error: Please specify a template file to validate"
    puts "Usage: ruby #{$0} [options] file"
    exit 1
  end

  filepath = ARGV[0]
  validator = WebRelease2Validator.new
  errors = validator.validate_file(filepath)

  if errors.empty?
    puts "✅ #{filepath} is valid!"
    exit 0
  else
    puts "❌ Found #{errors.size} error(s) in #{filepath}:"
    puts

    errors.each do |error|
      if options[:verbose]
        puts "Line #{error.line_number}:#{error.column} - #{error.error_type}"
        puts "  #{error.message}"
        puts "  Context: #{error.context}" unless error.context.empty?
        puts
      else
        puts "Line #{error.line_number}: #{error.message}"
      end
    end

    exit 1
  end
end

main if __FILE__ == $0