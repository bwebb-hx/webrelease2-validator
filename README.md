# WebRelease2 Validator

A comprehensive validator for WebRelease2 template files that checks syntax, structure, attributes, and element relationships.

## Overview

WebRelease2 is a CMS framework that uses HTML-like syntax with `%expression%` patterns and custom `wr-*` elements. This validator ensures your WebRelease2 templates follow proper syntax and structure rules.

## Features

✅ **Expression Validation** - Validates `%expression%` syntax and content  
✅ **Element Structure** - Checks opening/closing tags and nesting  
✅ **Attribute Validation** - Verifies required attributes and values  
✅ **Context-Aware Validation** - Ensures elements are used in correct parent contexts  
✅ **Self-Closing Elements** - Validates proper self-closing syntax  
✅ **Comment Syntax** - Supports both `<wr-comment>` and `<wr-->` formats  
✅ **Function Calls** - Validates function syntax and parentheses  
✅ **Variable Names** - Checks for reserved keywords and valid naming  
✅ **Comprehensive Error Reporting** - Clear, actionable error messages  

## Quick Start

### Validate a Template File

```bash
ruby webrelease2_validator.rb template.html
```

**Example output:**
```
✅ template.html is valid!
```

Or with errors:
```
❌ Found 2 error(s) in template.html:

Line 5: Missing required attributes for 'wr-if': condition
Line 12: Unclosed element: wr-switch
```

### Detailed Error Information

```bash
ruby webrelease2_validator.rb template.html --verbose
```

## Supported WebRelease2 Elements

| Element | Type | Required Attributes | Optional Attributes |
|---------|------|-------------------|-------------------|
| `wr-if` | Container | `condition` | - |
| `wr-then` | Container | - | - |
| `wr-else` | Container | - | - |
| `wr-switch` | Container | `value` | - |
| `wr-case` | Container | `value` | - |
| `wr-default` | Container | - | - |
| `wr-conditional` | Container | - | - |
| `wr-cond` | Container | `condition` | - |
| `wr-for` | Container | `variable` + one of: `list`, `string`, `times` | `count`, `index` |
| `wr-break` | Self-closing | - | `condition` |
| `wr-variable` | Self-closing | `name` | `value` |
| `wr-append` | Self-closing | `name`, `value` | - |
| `wr-clear` | Self-closing | `name` | - |
| `wr-error` | Container | - | `condition` |
| `wr-return` | Self-closing | `value` | - |
| `wr-comment` | Container | - | - |
| `wr-->` | Special | - | - |

## Validation Rules

### 1. Expression Syntax
- `%expression%` patterns must be properly closed
- No empty expressions (`%%`)
- Function calls must have balanced parentheses
- Use double quotes in function calls, not single quotes

### 2. Element Structure
- All container elements must be properly closed
- Self-closing elements cannot have closing tags
- No mismatched closing tags

### 3. Context Rules
- `wr-case` and `wr-default` only inside `wr-switch`
- `wr-then` and `wr-else` only inside `wr-if`
- `wr-cond` only inside `wr-conditional`
- `wr-break` only inside `wr-for`

### 4. Attribute Rules
- All required attributes must be present
- No empty values for critical attributes (`condition`, `value`, `name`, etc.)
- Variable names must follow naming conventions
- No reserved keywords as variable names

### 5. Special Rules
- `wr-for` must have exactly one loop source (`list`, `string`, or `times`)
- `times` attribute must be a positive integer
- WebRelease2 comments must be properly formatted

## Testing

This project includes a comprehensive test suite with **70 individual test cases** covering all validation rules.

### Run All Tests

```bash
ruby file_test_runner.rb
```

### Run Specific Test Categories

```bash
ruby file_test_runner.rb valid              # Valid template tests
ruby file_test_runner.rb syntax-error       # Syntax error tests
ruby file_test_runner.rb attribute-error    # Attribute error tests
ruby file_test_runner.rb structure-error    # Structure error tests
ruby file_test_runner.rb reference-error    # Reference error tests
ruby file_test_runner.rb function-error     # Function error tests
```

### Run Single Test

```bash
ruby file_test_runner.rb tests/individual/valid/basic-if-structure.html
```

### Verbose Output

```bash
ruby file_test_runner.rb --verbose
```

### List Test Categories

```bash
ruby file_test_runner.rb --list
```

### View Test Coverage

```bash
ruby test_summary.rb
```

## Test Structure

The test suite is organized into individual test files, each focusing on a specific validation rule:

```
tests/individual/
├── valid/                  # 9 valid template tests
├── syntax-error/           # 8 syntax error tests  
├── attribute-error/        # 36 attribute error tests
├── structure-error/        # 12 structure error tests
├── reference-error/        # 2 reference error tests
└── function-error/         # 3 function error tests
```

Each test file contains:
- The test case HTML
- Embedded metadata specifying expected behavior
- Clear descriptions of what's being validated

## Example Templates

### Valid WebRelease2 Template

```html
<div>
  <wr-if condition="pageType == 'news'">
    <wr-then>
      <h1>%title%</h1>
      <p>Published: %formatDate(publishDate, "yyyy-MM-dd")%</p>
    </wr-then>
    <wr-else>
      <h1>%pageTitle%</h1>
    </wr-else>
  </wr-if>

  <wr-for list="articles" variable="article" count="index">
    <article>
      <h2>%article.title%</h2>
      <p>%article.excerpt%</p>
      <wr-break condition="index >= 5"/>
    </article>
  </wr-for>

  <wr-switch value="layout">
    <wr-case value="grid">
      <div class="grid-layout">Content</div>
    </wr-case>
    <wr-case value="list">
      <div class="list-layout">Content</div>
    </wr-case>
    <wr-default>
      <div class="default-layout">Content</div>
    </wr-default>
  </wr-switch>
</div>
```

### Variable Operations

```html
<div>
  <wr-variable name="counter" value="0"/>
  <wr-variable name="results"/>
  
  <wr-for list="items" variable="item">
    <wr-append name="counter" value="1"/>
    <wr-append name="results" value="item.name"/>
  </wr-for>
  
  <p>Total items: %counter%</p>
  <wr-clear name="results"/>
</div>
```

### Comments

```html
<div>
  <wr-->This is a WebRelease2 comment</wr-->
  <wr-comment>Alternative comment syntax</wr-comment>
  
  <!-- Regular HTML comments are also supported -->
</div>
```

## Error Types

The validator reports five types of errors:

| Type | Description | Examples |
|------|-------------|----------|
| **Syntax Error** | Malformed syntax, unknown elements | Empty expressions, unknown `wr-*` elements |
| **Attribute Error** | Missing or invalid attributes | Missing `condition`, invalid variable names |
| **Structure Error** | Incorrect element structure | Unclosed elements, wrong parent contexts |
| **Reference Error** | Invalid element references | Malformed array access, invalid dot notation |
| **Function Error** | Function call issues | Unbalanced parentheses, invalid function names |

## Requirements

- Ruby (tested with Ruby 3.4+)
- No external dependencies

## CLI Options

```bash
ruby webrelease2_validator.rb [options] file

Options:
  -v, --verbose    Show detailed error information
  -h, --help       Show help message

Examples:
  ruby webrelease2_validator.rb template.html
  ruby webrelease2_validator.rb template.html --verbose
```

## Contributing

To add new validation rules:

1. **Add the validation logic** to `webrelease2_validator.rb`
2. **Create test cases** in `tests/individual/[category]/`
3. **Run the test suite** to ensure everything passes
4. **Update this README** if needed

### Test File Format

Each test file should include metadata:

```html
<!-- TEST_META:
  name: "Test case name"
  expected_result: "valid|error"
  expected_error_message: "Expected error message" (if error)
  description: "Description of what this tests"
-->
<div>
  <!-- Your test case HTML here -->
</div>
```

## License

This project is developed for internal use at Hexabase for WebRelease2 template validation.

## Support

For questions or issues with the validator, please refer to the WebRelease2 documentation or contact the development team.