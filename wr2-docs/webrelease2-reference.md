# WebRelease2 - Comprehensive Technical Reference

**Overview**: WebRelease2 is a CMS for building websites, which supports HTML combined with a super-set of HTML-like tags which is the WebRelease2 Framework.

## 1. Expression Syntax

**Purpose**: WebRelease2 uses `%expression%` syntax for dynamic content insertion, allowing templates to output dynamic data, perform calculations, and call functions.

**When to use**: Whenever you need to insert dynamic content, reference page elements, or perform operations within template HTML.

### Basic Expression Types

- **Element references**: `%elementName%` - Access form fields, content elements, and page data
- **Resource references**: `%resourceName%` - Reference images, CSS files, and other assets
- **Function calls**: `%functionName(params)%` - Use built-in functions for formatting, calculations
- **Method calls**: `%methodName(args)%` - Call custom template methods
- **Arithmetic operations**: `%1 + 1%` - Perform mathematical calculations inline
- **Nested expressions**: `%pageTitle(selectedPage())%` - Combine functions and references

### Escaping

- Use `%%` to output a literal `%` character when you need to display percentage symbols in content

## 2. Element References

**Purpose**: Access data from form elements, page content, and structured data within your WebRelease2 pages.

**When to use**:

- Displaying dynamic data in a template or component
- Displaying user input from forms
- Accessing page metadata and content
- Working with structured data like addresses, contact info
- Building dynamic navigation from page hierarchies

### Basic Syntax

```html
<!-- Simple element - displays the element's value -->
%elementName%

<!-- Nested element - access child within a group -->
%groupElement.child%

<!-- Array access - get specific item from list -->
%arrayElement[0]%

<!-- Nested array access - get property of array item -->
%addresses[1].name%
```

**Key concepts**:

- Dot notation (`.`) accesses nested properties
- Square brackets (`[]`) access array elements by index (0-based)
- References resolve to different value types based on element type

### Element Value Types

| Element Type      | Reference Value             |
| ----------------- | --------------------------- |
| Single-line Text  | Input string                |
| Multi-line Text   | Input string                |
| WYSIWYG Editor    | HTML content string         |
| Radio Button      | Selected option text        |
| Checkbox          | CheckBox object             |
| Date/Time         | Milliseconds since 1970/1/1 |
| Table of Contents | Page object array           |
| Link              | Linked page URL             |
| Image             | Image URL                   |
| Attached File     | File URL                    |

## 3. Structure Elements - Creating Arrays of Objects

**Purpose**: Structure elements allow you to create arrays of complex, structured data by combining multiple child elements under a repeatable parent structure.

**When to use**:

- Store lists of related information (addresses, contact details, product specifications)
- Create arrays of objects where each object contains multiple properties
- Organize complex data that requires multiple fields per entry
- Build repeatable content sections with consistent structure

**Key concepts**:

- Structure elements act as containers for child elements
- When set to "repeatable", they create arrays where each entry is an object
- Child elements become properties of each object in the array
- Access via array notation with dot notation for properties

### Creating Structure Elements

**Setup process**:

1. Create an element with type "Structure"
2. Enable "repeatable" setting in element configuration
3. Add child elements under the structure (text fields, images, etc.)
4. Each repetition becomes an array entry containing all child element values

**Example structure definition**:

```
addresses (Structure, repeatable)
├── name (Single-line Text)
├── postalCode (Single-line Text)
├── address (Multi-line Text)
└── phone (Single-line Text)
```

This creates an array conceptually similar to:

```javascript
addresses = [
  {
    name: "John Doe",
    postalCode: "12345",
    address: "123 Main St",
    phone: "555-1234",
  },
  {
    name: "Jane Smith",
    postalCode: "67890",
    address: "456 Oak Ave",
    phone: "555-5678",
  },
  // ... more entries
];
```

### Accessing Structure Data

**Array access patterns**:

```xml
<!-- Access specific array index -->
%addresses[0].name%           <!-- First entry's name -->
%addresses[1].postalCode%     <!-- Second entry's postal code -->

<!-- Get count of array entries -->
%count(addresses)%            <!-- Returns number of address entries -->

<!-- Check if array has data -->
<wr-if condition="count(addresses) > 0">
    We have %count(addresses)% addresses on file.
</wr-if>
```

### Iterating Through Structure Arrays

**Loop processing**: Use `wr-for` to process each structure entry:

```xml
<!-- Basic iteration -->
<wr-for list="addresses" variable="addr" count="i">
    <div class="address-card">
        <h3>Address #%i%</h3>
        <p><strong>%addr.name%</strong></p>
        <p>%addr.address%</p>
        <p>%addr.postalCode%</p>
        <p>Phone: %addr.phone%</p>
    </div>
</wr-for>

<!-- Conditional processing within loop -->
<wr-for list="products" variable="product">
    <wr-if condition="number(product.price) > 100">
        <div class="premium-product">
            <h4>%product.name%</h4>
            <p>Price: $%product.price%</p>
            <p>%product.description%</p>
        </div>
    </wr-if>
</wr-for>
```

### Filtering Structure Arrays

**Building filtered results**: Use variables to collect matching entries:

```xml
<wr-variable name="expensiveProducts"/>

<wr-for list="products" variable="product">
    <wr-if condition="number(product.price) > 500">
        <wr-append name="expensiveProducts" value="product"/>
    </wr-if>
</wr-for>

<!-- Display filtered results -->
<h2>Premium Products</h2>
<wr-for list="expensiveProducts" variable="item">
    <p>%item.name% - $%item.price%</p>
</wr-for>
```

### Structure Element Best Practices

**Design considerations**:

- **Logical grouping**: Group related fields that belong together conceptually
- **Consistent naming**: Use clear, descriptive names for both structure and child elements
- **Data validation**: Include null checks when accessing structure properties
- **Performance**: Consider using `count()` to check array size before processing large structures

**Common structure patterns**:

1. **Contact Information**:

```
contacts (Structure, repeatable)
├── name (Single-line Text)
├── email (Single-line Text)
├── phone (Single-line Text)
└── role (Radio Button)
```

2. **Product Catalog**:

```
products (Structure, repeatable)
├── name (Single-line Text)
├── description (Multi-line Text)
├── price (Single-line Text)
├── image (Image)
└── category (Radio Button)
```

3. **Event Schedule**:

```
events (Structure, repeatable)
├── title (Single-line Text)
├── startDate (Date/Time)
├── endDate (Date/Time)
├── location (Single-line Text)
└── description (WYSIWYG Editor)
```

## 4. Selector Elements - Dynamic Element Type Selection

**Purpose**: Selector elements enable dynamic content rendering where each instance can use a different element type from a predefined set of options.

**When to use**:

- Flexible content areas where content type varies per instance
- Templates that need to handle mixed content types (text, images, rich content) in the same section
- Conditional rendering based on selected element type

**Key concepts**:

- Contains multiple child element options, but only one is selected per instance
- Template expansion creates a Selector object with methods for examining and using the selection
- Each selector instance can use a different child element type

### Selector vs Structure Elements

| Aspect                 | Structure Elements         | Selector Elements                       |
| ---------------------- | -------------------------- | --------------------------------------- |
| **Child Usage**        | ALL child elements used    | ONE child element selected per instance |
| **Data Pattern**       | Fixed object structure     | Variable element type per instance      |
| **Template Reference** | `%structure.childElement%` | `%selector.selectedValue()%`            |

### Selector Object Methods

**Core methods available on selector elements**:

- **`isSelected(elementName)`** - Check if specific child element is selected (returns boolean)
- **`selectedName()`** - Get the name of the selected child element
- **`selectedValue()`** - Get the actual selected element for content generation

### Template Syntax

**Basic selector usage**:

```xml
<!-- Generate content from selected element -->
%selectorElement.selectedValue()%

<!-- For components, call generateText method -->
%selectorElement.selectedValue().generateText()%

<!-- Get name of selected element -->
%selectorElement.selectedName()%
```

**Conditional rendering based on selection**:

```xml
<!-- Check if specific element type is selected -->
<wr-if condition="contentBlock.isSelected('textContent')">
    <div class="text-block">
        %contentBlock.selectedValue()%
    </div>
</wr-if>

<wr-if condition="contentBlock.isSelected('imageContent')">
    <figure class="image-block">
        %contentBlock.selectedValue()%
    </figure>
</wr-if>
```

**Switch-based rendering**:

```xml
<wr-switch value="flexibleSection.selectedName()">
    <wr-case value="paragraph">
        <div class="text-content">%flexibleSection.selectedValue()%</div>
    </wr-case>
    <wr-case value="image">
        <figure class="image-content">%flexibleSection.selectedValue()%</figure>
    </wr-case>
    <wr-case value="richContent">
        <div class="rich-content">%flexibleSection.selectedValue()%</div>
    </wr-case>
    <wr-default>
        <div class="default-content">%flexibleSection.selectedValue()%</div>
    </wr-default>
</wr-switch>
```

### Element Definition Patterns

**Mixed content selector**:

```
contentBlock (Selector)
├── textContent (Single-line Text)
├── richContent (WYSIWYG Editor)
├── imageContent (Image)
└── videoEmbed (Multi-line Text)
```

**Component-based selector**:

```
pageSection (Selector)
├── heroSection (Component)
├── textSection (Component)
├── gallerySection (Component)
└── formSection (Component)
```

### Advanced Usage Patterns

**Dynamic CSS classes based on selection**:

```xml
<wr-for list="flexibleContent" variable="content">
    <div class="content-block %content.selectedName()%-block">
        %content.selectedValue()%
    </div>
</wr-for>
```

**Conditional attribute generation**:

```xml
<wr-for list="mediaItems" variable="item">
    <wr-if condition="item.isSelected('image')">
        <img src="%item.selectedValue()%" alt="Media content" />
    </wr-if>

    <wr-if condition="item.isSelected('video')">
        <video controls>
            <source src="%item.selectedValue()%" />
        </video>
    </wr-if>
</wr-for>
```

**Nested selector processing**:

```xml
<wr-for list="pageSections" variable="section">
    <section class="page-section">
        <wr-switch value="section.selectedName()">
            <wr-case value="flexibleContent">
                <!-- Section itself contains another selector -->
                <wr-for list="section.selectedValue().contentItems" variable="item">
                    %item.selectedValue()%
                </wr-for>
            </wr-case>
            <wr-case value="standardContent">
                %section.selectedValue()%
            </wr-case>
        </wr-switch>
    </section>
</wr-for>
```

### Best Practices

**Selection checking**:

- Use `isSelected()` for specific element type checks
- Use `selectedName()` with switch statements for multiple options
- Combine both approaches for complex conditional logic

**Template design**:

- Plan CSS classes that work with `selectedName()` output
- Include fallback cases for unexpected selection types
- Use consistent naming conventions for selector child elements

## 5. CheckBox Elements - Boolean Values and Multiple Selection

**Purpose**: CheckBox elements serve as WebRelease2's boolean data type and multiple selection mechanism, creating CheckBox objects with methods for examining selection state.

**When to use**:

- **Boolean values**: Single checkbox option for true/false logic (agree to terms, enable feature, opt-in)
- **Multiple selection**: Multiple checkbox options for multi-select scenarios (categories, features, preferences)
- **Optional selections**: Where zero, one, or many items can be chosen

### CheckBox Object Methods

**Core methods available on checkbox elements**:

- **`isSelected(optionName)`** - Check if specific option is selected (returns boolean)
- **`selected()`** - Get array of currently selected options in original order
- **`selectionList()`** - Get complete array of all available options in original order

### Boolean Usage (Single Option)

**Element definition for boolean**:

```
agreeToTerms (CheckBox)
Options:
- agree
```

**Boolean template syntax**:

```xml
<!-- Boolean check -->
<wr-if condition="agreeToTerms.isSelected('agree')">
    <p>Terms accepted</p>
</wr-if>

<!-- Boolean validation -->
<wr-error condition="!agreeToTerms.isSelected('agree')">
    You must agree to the terms to continue
</wr-error>

<!-- Boolean-based conditional content -->
<wr-if condition="enableNotifications.isSelected('enable')">
    <wr-then>
        <div class="notifications-enabled">
            <h3>Notifications Active</h3>
            <p>You will receive updates</p>
        </div>
    </wr-then>
    <wr-else>
        <div class="notifications-disabled">
            <p>Notifications are disabled</p>
        </div>
    </wr-else>
</wr-if>
```

**Common boolean patterns**:

```xml
<!-- Feature toggles -->
<wr-if condition="advancedMode.isSelected('enabled')">
    <!-- Advanced interface -->
</wr-if>

<!-- Privacy settings -->
<wr-if condition="shareData.isSelected('allow')">
    <!-- Data sharing code -->
</wr-if>

<!-- Subscription options -->
<wr-if condition="premium.isSelected('subscribe')">
    <!-- Premium features -->
</wr-if>
```

### Multiple Selection Usage

**Element definition for multi-select**:

```
preferences (CheckBox)
Options:
- email
- sms
- push
- newsletter
```

**Multi-select template syntax**:

```xml
<!-- Check specific selections -->
<wr-if condition="preferences.isSelected('email')">
    <div class="email-settings">Email notifications enabled</div>
</wr-if>

<!-- Process all selected items -->
<wr-for list="preferences.selected()" variable="pref">
    <span class="selected-preference">%pref%</span>
</wr-for>

<!-- Selection count logic -->
<wr-switch value="count(preferences.selected())">
    <wr-case value="0">
        <p>No preferences selected</p>
    </wr-case>
    <wr-case value="1">
        <p>One preference: %preferences.selected()[0]%</p>
    </wr-case>
    <wr-default>
        <p>%count(preferences.selected())% preferences selected</p>
    </wr-default>
</wr-switch>
```

**Display all options with selection status**:

```xml
<wr-for list="features.selectionList()" variable="feature">
    <div class="feature-option">
        <wr-if condition="features.isSelected(feature)">
            <span class="selected">✓ %feature% (selected)</span>
        </wr-if>
        <wr-else>
            <span class="unselected">○ %feature%</span>
        </wr-else>
    </div>
</wr-for>
```

### Validation and Logic Patterns

**Boolean validation**:

```xml
<!-- Required boolean acceptance -->
<wr-error condition="!terms.isSelected('accept')">
    Terms must be accepted
</wr-error>

<!-- Boolean dependency -->
<wr-if condition="subscribe.isSelected('yes')">
    <wr-error condition="!email.isSelected('provide')">
        Email address required for subscription
    </wr-error>
</wr-if>
```

**Multi-select validation**:

```xml
<!-- Minimum selections required -->
<wr-error condition="count(categories.selected()) == 0">
    Please select at least one category
</wr-error>

<!-- Maximum selections allowed -->
<wr-error condition="count(options.selected()) > 3">
    Please select no more than 3 options
</wr-error>
```

**Complex conditional logic**:

```xml
<!-- Boolean combinations -->
<wr-if condition="premium.isSelected('enable') && notifications.isSelected('allow')">
    <div class="premium-notifications">Premium notification features</div>
</wr-if>

<!-- Multi-select combinations -->
<wr-if condition="services.isSelected('delivery') && services.isSelected('assembly')">
    <div class="combo-discount">Special combo pricing applied</div>
</wr-if>
```

### Data Type Comparison

| Use Case                    | Element Type                | Template Reference               | Value Type             |
| --------------------------- | --------------------------- | -------------------------------- | ---------------------- |
| **Boolean (true/false)**    | CheckBox (single option)    | `%element.isSelected('option')%` | Boolean                |
| **Multiple selection**      | CheckBox (multiple options) | `%element.selected()%`           | String array           |
| **Single choice from list** | Radio Button                | `%element%`                      | Selected option string |
| **Complex object**          | Structure                   | `%element.property%`             | Object with properties |

### Best Practices

**Boolean usage**:

- Use single CheckBox option for all true/false logic
- Choose descriptive option names (`agree`, `enable`, `accept`, `allow`)
- Always validate required boolean acceptances with `wr-error`

**Multi-select usage**:

- Use `isSelected()` for specific option checks
- Use `selected()` to iterate only chosen items
- Use `selectionList()` when displaying all available options
- Validate selection counts for business rules

**Performance considerations**:

- Cache `selected()` results if used multiple times
- Use `isSelected()` for single-option boolean checks
- Prefer boolean CheckBox over Radio Button for true/false logic

## 6. Radio Button Elements - Single Selection from Options

**Purpose**: Radio Button elements provide single selection from a predefined list of options, returning the selected option text directly.

**When to use**:

- **Single choice selection**: Choose one option from multiple predefined choices (gender, region, category)
- **Enumerated values**: When you need one value from a fixed set of options
- **Mutually exclusive options**: Where selecting one option excludes all others
- **Required selections**: Where empty/no selection should be avoided

**Programming model**:

- **Returns selected option text directly** (not an object like CheckBox)
- **Single selection enforcement** - only one option can be chosen
- **Simpler template syntax** than CheckBox for single selections
- **Choice list sharing** - reuse option lists across different radio elements

### Template Syntax

**Basic radio button usage**:

```xml
<!-- Direct value access -->
%region%                    <!-- Returns selected text like "Tokyo" -->

<!-- Conditional logic -->
<wr-if condition="gender == 'Male'">
    <p>Welcome, sir!</p>
</wr-if>

<!-- Switch-based branching -->
<wr-switch value="priority">
    <wr-case value="High">
        <div class="high-priority">Urgent processing</div>
    </wr-case>
    <wr-case value="Medium">
        <div class="medium-priority">Standard processing</div>
    </wr-case>
    <wr-case value="Low">
        <div class="low-priority">Delayed processing</div>
    </wr-case>
</wr-switch>
```

**Validation and error handling**:

```xml
<!-- Required selection validation -->
<wr-error condition="isNull(category)">
    Please select a category
</wr-error>

<!-- Value validation -->
<wr-error condition="priority != 'High' && priority != 'Medium' && priority != 'Low'">
    Invalid priority selection
</wr-error>

<!-- Conditional requirements -->
<wr-if condition="membershipType == 'Premium'">
    <wr-error condition="isNull(preferredService)">
        Premium members must select a preferred service
    </wr-error>
</wr-if>
```

### Element Configuration Patterns

**Basic radio button setup**:

```
region (Radio Button)
Options:
- Tokyo
- Osaka
- Kyoto
- Hiroshima
Initial Value: Tokyo
```

**Category selection**:

```
priority (Radio Button)
Options:
- High
- Medium
- Low
Display: 3 columns, horizontal
```

**With choice sharing**:

```
primaryRegion (Radio Button)
Options: [SharedRegionList]

secondaryRegion (Radio Button)
Options: [SharedRegionList]
```

### Conditional Rendering Patterns

**Content switching based on selection**:

```xml
<wr-switch value="layoutType">
    <wr-case value="Grid">
        <div class="grid-layout">
            <wr-for list="items" variable="item">
                <div class="grid-item">%item%</div>
            </wr-for>
        </div>
    </wr-case>
    <wr-case value="List">
        <div class="list-layout">
            <wr-for list="items" variable="item">
                <div class="list-item">%item%</div>
            </wr-for>
        </div>
    </wr-case>
    <wr-case value="Cards">
        <div class="card-layout">
            <wr-for list="items" variable="item">
                <div class="card">%item%</div>
            </wr-for>
        </div>
    </wr-case>
</wr-switch>
```

**Style and behavior changes**:

```xml
<div class="content-area theme-%theme%">
    <wr-if condition="theme == 'Dark'">
        <link rel="stylesheet" href="%dark-theme-css%"/>
    </wr-if>
    <wr-else>
        <link rel="stylesheet" href="%light-theme-css%"/>
    </wr-else>

    <!-- Content affected by theme selection -->
    %pageContent%
</div>
```

**Form flow control**:

```xml
<wr-switch value="contactMethod">
    <wr-case value="Email">
        <div class="email-form">
            <label>Email Address:</label>
            <input type="email" value="%emailAddress%"/>
        </div>
    </wr-case>
    <wr-case value="Phone">
        <div class="phone-form">
            <label>Phone Number:</label>
            <input type="tel" value="%phoneNumber%"/>
        </div>
    </wr-case>
    <wr-case value="Mail">
        <div class="address-form">
            <label>Mailing Address:</label>
            <textarea>%mailingAddress%</textarea>
        </div>
    </wr-case>
</wr-switch>
```

### Advanced Usage Patterns

**Dynamic content based on multiple radio selections**:

```xml
<wr-if condition="userType == 'Business' && region == 'Tokyo'">
    <div class="business-tokyo-content">
        <h2>Tokyo Business Services</h2>
        <p>Special corporate rates available</p>
    </div>
</wr-if>

<wr-if condition="membershipLevel == 'Premium' && (region == 'Tokyo' || region == 'Osaka')">
    <div class="premium-metro-services">
        <p>Premium metropolitan area services</p>
    </div>
</wr-if>
```

**Using radio selections in loops and filters**:

```xml
<!-- Filter content based on radio selection -->
<wr-variable name="filteredProducts"/>
<wr-for list="allProducts" variable="product">
    <wr-if condition="product.category == selectedCategory">
        <wr-append name="filteredProducts" value="product"/>
    </wr-if>
</wr-for>

<div class="filtered-results">
    <h2>%selectedCategory% Products</h2>
    <wr-for list="filteredProducts" variable="product">
        <div class="product-item">%product.name%</div>
    </wr-for>
</div>
```

### Selection Element Comparison

| Element Type            | Selection Model             | Template Reference               | Use Case              |
| ----------------------- | --------------------------- | -------------------------------- | --------------------- |
| **Radio Button**        | Single selection (required) | `%element%`                      | Choose one from list  |
| **CheckBox (single)**   | Boolean (optional)          | `%element.isSelected('option')%` | True/false logic      |
| **CheckBox (multiple)** | Multiple selection          | `%element.selected()%`           | Choose many from list |
| **Selector**            | Single from element types   | `%element.selectedValue()%`      | Choose content type   |

### Best Practices

**When to use Radio Button**:

- Single selection from 2-7 options (optimal range)
- When all options should be visible simultaneously
- When selection is typically required (not optional)
- When choice affects subsequent form behavior or content

**Template design**:

- Use `wr-switch` for multiple option handling rather than chained `wr-if`
- Plan for all possible option values in conditional logic
- Include validation for required selections
- Use meaningful option text that works well in templates

**Configuration best practices**:

- Keep option lists concise (2-7 items ideal)
- Use descriptive option names that work in template conditions
- Consider choice list sharing for consistency across elements
- Set appropriate initial values for better user experience

**Performance considerations**:

- Radio button comparisons are simple string operations
- Cache radio values if used in multiple conditions
- Prefer `wr-switch` over multiple `wr-if` statements for multiple options

## 7. Conditional Logic

**Purpose**: Control which content appears based on data availability, user choices, or other conditions.

**When to use**:

- Show/hide content based on form selections
- Display different layouts for different content types
- Handle optional data fields gracefully
- Create responsive content that adapts to available data

### wr-if / wr-then / wr-else - Basic Conditional Rendering

**Use cases**: Simple true/false decisions, checking if data exists, binary content switching.

```xml
<!-- Basic conditional -->
<wr-if condition="isNotNull(picture)">
    <img src="%picture%" alt="%altText%" />
</wr-if>

<!-- With then/else -->
<wr-if condition="layout == \"Left\"">
    <wr-then>
        <img src="%picture%" style="float: left;" />
    </wr-then>
    <wr-else>
        <img src="%picture%" style="float: right;" />
    </wr-else>
</wr-if>
```

### wr-switch / wr-case / wr-default - Multi-way Branching

**Purpose**: Handle multiple possible values efficiently, similar to switch statements in programming.

**When to use**:

- Displaying different content based on category/type
- Converting codes to readable text (status codes, month numbers)
- Template layout switching based on page type

**Key features**: Only first matching case executes, no fall-through behavior, optional default case.

```xml
<wr-switch value="number(formatDate(currentTime(), \"M\"))">
    <wr-case value="1">January</wr-case>
    <wr-case value="2">February</wr-case>
    <wr-case value="3">March</wr-case>
    <wr-default>Unknown Month</wr-default>
</wr-switch>
```

### wr-conditional / wr-cond - Sequential Condition Checking

**Purpose**: Test multiple conditions in sequence, executing only the first match.

**When to use**:

- Priority-based content display
- Fallback content chains
- Complex conditional logic with multiple alternatives

**Best practice**: Use the last `wr-cond` with `condition="true"` as a default/fallback case.

```xml
<wr-conditional>
    <wr-cond condition="isNotNull(startDate)">
        Event starts: %formatDate(startDate, "yyyy/MM/dd")%
    </wr-cond>
    <wr-cond condition="isNotNull(endDate)">
        Event ends: %formatDate(endDate, "yyyy/MM/dd")%
    </wr-cond>
    <wr-cond condition="true">
        No event dates available
    </wr-cond>
</wr-conditional>
```

## 8. Loops

**Purpose**: Generate repeated HTML content by iterating through data collections, strings, or performing fixed-count operations.

**When to use**:

- Display lists of items (products, articles, addresses)
- Generate table rows from data arrays
- Create navigation menus from page hierarchies
- Process each character in a string
- Generate numbered sequences or pagination

### wr-for - Iteration and Looping

**Key attributes**:

- `list`: Array or collection to iterate over
- `string`: String to process character by character
- `times`: Fixed number of iterations
- `variable`: Variable name for current item
- `count`: 1-based counter (optional)
- `index`: 0-based index (optional)

**Important**: Cannot combine `list`, `string`, and `times` in the same loop.

```xml
<!-- List iteration -->
<wr-for list="addresses" variable="address" count="i" index="j">
    <tr>
        <td>%i%</td>                    <!-- 1-based counter -->
        <td>%j%</td>                    <!-- 0-based index -->
        <td>%address.postalCode%</td>
        <td>%address.address%</td>
    </tr>
</wr-for>

<!-- String iteration -->
<wr-for string="text" variable="char" count="i">
    Character %i%: %char%<br/>
</wr-for>

<!-- Fixed iterations -->
<wr-for times="5" variable="x" count="i">
    Iteration %i%: %x%<br/>
</wr-for>
```

### wr-break - Loop Control

**Purpose**: Exit loops early based on conditions or after processing a certain number of items.

**When to use**:

- Limit results to first N items
- Stop processing when a condition is met
- Implement "show more" functionality
- Performance optimization for large datasets

**Best practice**: Combine with wr-if for conditional breaking with additional output.

```xml
<wr-for list="items" variable="item" count="i">
    <p>%item.name%</p>
    <!-- Conditional break -->
    <wr-break condition="i == 3"/>

    <!-- Unconditional break with output -->
    <wr-if condition="i == 5">
        <p>Showing first 5 items only</p>
        <wr-break/>
    </wr-if>
</wr-for>
```

## 9. Variable Management

**Purpose**: Create temporary storage for data manipulation, filtering, and complex template logic.

**When to use**:

- Filter data collections based on criteria
- Accumulate results from loops
- Store computed values for reuse
- Build complex data structures during template processing

### wr-variable - Variable Declaration

**Key concepts**:

- All variables are stored as arrays internally
- Can be initialized empty, with a value, or with generated content
- Scope is within the current template/method
- Variables can be referenced like template elements

```xml
<!-- Empty variable -->
<wr-variable name="results"/>

<!-- Variable with initial value -->
<wr-variable name="counter" value="0"/>

<!-- Variable with complex content -->
<wr-variable name="pageList">
    <wr-for list="index" variable="x">
        %pageTitle(x)%<br/>
    </wr-for>
</wr-variable>
```

### wr-append - Adding Data to Variables

**Purpose**: Build arrays by adding items one at a time, typically used for filtering or collecting data during loops.

**When to use**:

- Filter items from a larger collection
- Collect matching results during iteration
- Build custom data structures
- Accumulate values based on conditions

**Common pattern**: Initialize empty variable, loop through data, conditionally append matching items, then process the filtered results.

```xml
<wr-variable name="tokyoBranches"/>

<wr-for list="branchList" variable="branch">
    <wr-if condition="branch.region == \"Tokyo\"">
        <wr-append name="tokyoBranches" value="branch"/>
    </wr-if>
</wr-for>

<!-- Using the filtered results -->
<wr-for list="tokyoBranches" variable="branch">
    <td>%branch.name%</td>
    <td>%branch.phone%</td>
</wr-for>
```

### wr-clear - Resetting Variables

**Purpose**: Reset a variable to empty state, useful for reusing variables or clearing data between operations.

**When to use**:

- Reuse variables in complex templates
- Clear accumulated data before new operations
- Reset state in methods that might be called multiple times

**Note**: Only clears variable contents, doesn't delete the variable or affect page elements.

```xml
<wr-clear name="results"/>
```

## 10. Operators

**Purpose**: Perform comparisons, logical operations, and calculations within template expressions and conditions.

**When to use**:

- Conditional logic in wr-if statements
- Data validation and filtering
- Mathematical calculations
- Complex boolean expressions

### Comparison Operators

- `==` Equal to - Test for equality (supports type conversion)
- `!=` Not equal to - Test for inequality
- `<` Less than - Numeric/string comparison
- `<=` Less than or equal to
- `>` Greater than - Numeric/string comparison
- `>=` Greater than or equal to

### Logical Operators

- `&&` Logical AND - Both conditions must be true
- `||` Logical OR - Either condition can be true

### Arithmetic Operators

- `+` Addition - Numeric addition or string concatenation
- `-` Subtraction - Numeric subtraction
- `*` Multiplication - Numeric multiplication
- `/` Division - Basic division (use `divide()` function for precision)

**Type conversion notes**:

- Mixed types are converted to numeric for comparison
- Use `number()` function for strict numeric comparison
- Use `string()` function for strict string comparison

### Type Conversion Examples

```xml
<wr-if condition="number(price) > 1000">
    Expensive item
</wr-if>

<wr-if condition="string(category) == \"electronics\"">
    Electronic device
</wr-if>
```

## 11. Methods

**Purpose**: Create reusable template functions for complex logic, HTML generation, and data processing.

**When to use**:

- Reusable HTML components (cards, buttons, forms)
- Complex data transformations
- Encapsulate business logic
- Create template libraries and shared functionality

**Key features**:

- Support multiple parameters
- Can return values using wr-return
- Can be recursive
- Can be private (template-only) or public
- Access to all template variables and functions

### Method Definition

**Syntax**: `methodName(param1, param2) { template content }`

**Best practices**: Use descriptive names, keep methods focused on single responsibilities, document complex methods with comments.

```xml
<!-- Method definition in template -->
drawImage(img, alt) {
    <img src="%img%" alt="%alt%" class="responsive-image"/>
}

formatPrice(price, currency) {
    <span class="price">%currency%%price%</span>
}
```

### Method Usage

**Calling methods**: Use standard function call syntax within expressions: `%methodName(arg1, arg2)%`

```xml
%drawImage(productImage, productName)%
%formatPrice(itemPrice, "¥")%
```

### Method with Return Value

**Purpose**: Create methods that process data and return results for use in other parts of the template.

**Common patterns**:

- Data filtering and transformation
- Conditional data processing
- Building structured results from complex logic

```xml
getNewsPages() {
    <wr-variable name="result"/>
    <wr-for list="index" variable="page">
        <wr-if condition="page.category == \"news\"">
            <wr-append name="result" value="page"/>
            <wr-if condition="count(result) >= 5">
                <wr-return value="result"/>
            </wr-if>
        </wr-if>
    </wr-for>
    <wr-return value="result"/>
}
```

## 12. Components

**Purpose**: Create reusable, modular content blocks that can be embedded within templates and other components. Components provide a way to organize template logic into maintainable, reusable units.

**When to use**:

- Create reusable HTML patterns (cards, navigation, forms)
- Modularize complex template logic
- Build component libraries for consistent design
- Enable content selection through selectors
- Centralize maintenance of common UI elements

**Key concepts**:

- Components are template-like structures but cannot directly create pages
- Must be embedded within templates or other components
- Content generation occurs through component methods
- Support their own elements, resources, and methods
- Can be combined with selectors for dynamic content selection

### Component Structure

**Basic component anatomy**:

- **Elements**: Data fields specific to the component (text, images, selections)
- **Resources**: Component-specific assets (CSS, images, scripts)
- **Methods**: Functions that generate HTML output (typically `generateText()`)
- **Configuration**: Name, folder location, description, and settings

### Creating Components

**Component creation workflow**:

1. Define component elements (data fields)
2. Add component resources if needed
3. Implement component methods (especially `generateText()`)
4. Embed component in templates using component elements

**Example component definition**:

```xml
<!-- Component: "Image with Text" -->
<!-- Elements: picture (Image), layout (Radio), altText (Text), text (Multiline Text) -->

<div class="image-text-component">
    <wr-if condition="isNotNull(picture)">
        <wr-if condition="layout == \"Left\"">
            <wr-then>
                <img src="%picture%" alt="%altText%" style="float: left; margin-right: 20px;" />
            </wr-then>
            <wr-else>
                <img src="%picture%" alt="%altText%" style="float: right; margin-left: 20px;" />
            </wr-else>
        </wr-if>
    </wr-if>
    <div class="text-content">
        %text%
    </div>
    <div style="clear: both;"></div>
</div>
```

### Using Components in Templates

**Basic component usage**:

1. Call the component's method to generate content

**Template integration pattern**:

```xml
<!-- In template with component element named "contentBlock" -->
<div class="content-section">
    %contentBlock.selectedValue().generateText()%
</div>
```

**Component element reference**:

```xml
<!-- Access component element data -->
%componentElement.elementName%

<!-- Call component methods -->
%componentElement.methodName(parameters)%

<!-- Common pattern for content generation -->
%componentElement.selectedValue().generateText()%
```

### Components with Selectors

**Purpose**: Selectors enable dynamic selection between different component types within a single template element.

**When to use**:

- Provide content authors with multiple layout options
- Create flexible content areas that can display different component types
- Build adaptive templates that change based on content needs

**Selector implementation**:

```xml
<!-- Template with selector element "part" -->
<!-- Selector configured with multiple component options -->

<section class="flexible-content">
    <wr-for list="part" variable="section">
        <!-- Renders selected component type -->
        %section.selectedValue().generateText()%
    </wr-for>
</section>
```

**Benefits of selector pattern**:

- Authors can choose appropriate component for each content section
- Single template supports multiple content presentation styles
- Easy to add new component types without template modification
- Consistent interface for different content types

### Component Best Practices

**Design principles**:

- **Single responsibility**: Each component should handle one specific content type or layout
- **Parameterization**: Use component elements to make components flexible and reusable
- **Method naming**: Use descriptive method names, `generateText()` is conventional for main output
- **Error handling**: Include validation in component methods for required elements
- **Resource management**: Keep component-specific assets within component resources

**Common component patterns**:

1. **Content Cards**:

```xml
<div class="card">
    <wr-if condition="isNotNull(image)">
        <img src="%image%" alt="%title%" class="card-image" />
    </wr-if>
    <div class="card-content">
        <h3>%title%</h3>
        <p>%description%</p>
        <wr-if condition="isNotNull(link)">
            <a href="%link%" class="card-link">Read More</a>
        </wr-if>
    </div>
</div>
```

2. **Ordered Lists**:

```xml
<ol class="ordered-list">
    <wr-for list="items" variable="item">
        <li>%item%</li>
    </wr-for>
</ol>
```

3. **Navigation Menus**:

```xml
<nav class="component-nav">
    <ul>
        <wr-for list="menuItems" variable="item">
            <li>
                <a href="%item.url%">%item.title%</a>
            </li>
        </wr-for>
    </ul>
</nav>

```

**Component organization**:

- Group related components in folders
- Use descriptive component names
- Document component elements and their purposes
- Test components with various data scenarios
- Consider component dependencies and relationships

## 13. Resources

**Purpose**: Manage and reference static assets like images, CSS files, JavaScript, and other files used in templates.

**When to use**:

- Template-specific styling and scripts
- Images and media files
- Any static assets needed by the template

### Template Resources vs Site Resources

- **Template Resources**: Stored in template directory, template-specific
- **Site Resources**: Available across the entire site
- **Priority**: Elements > Template Resources > Site Resources

### Resource References

**Syntax**: Use resource name within expressions: `%resourceName%`

**Best practices**:

- Use descriptive resource names
- Avoid conflicts with element names
- Prefer resource references over hardcoded URLs for maintainability

```xml
<!-- Resource reference -->
<img src="%goldfish%" alt="Goldfish image"/>
<link rel="stylesheet" href="%main-style%"/>

<!-- Priority order: Elements > Template Resources > Site Resources -->
```

## 14. Error Handling and Control

**Purpose**: Implement validation, error checking, and controlled template execution flow.

**When to use**:

- Validate required form fields
- Check data integrity before processing
- Provide user-friendly error messages
- Prevent template processing with invalid data

### wr-error - Template Error Generation

**Purpose**: Stop template processing and display error messages when conditions aren't met.

**Behavior**:

- Stops content generation immediately
- Shows error message in preview mode
- Logs errors in FTP generation records
- HTML in error messages is automatically escaped

**Best practice**: Use descriptive error messages that help users understand what's wrong and how to fix it.

```xml
<wr-error condition="isNull(emailAddress)">
    Email address is required.
</wr-error>

<!-- Unconditional error -->
<wr-error>
    This template is under maintenance.
</wr-error>
```

### wr-return - Method Return Values

**Purpose**: Return values from methods and exit method execution early.

**When to use**:

- Return processed data from methods
- Early method termination based on conditions
- Provide default values when data is unavailable
- Control method execution flow

**Key features**:

- Can return variables, computed values, or static content
- Exits method immediately when encountered
- Essential for methods that process and transform data

```xml
<!-- In methods -->
<wr-if condition="count(results) == 0">
    <wr-return value="\"No results found\""/>
</wr-if>
<wr-return value="results"/>
```

## 15. Comments

**Purpose**: Add documentation and notes within templates without affecting output.

**When to use**:

- Document complex template logic
- Add development notes and TODOs
- Temporarily disable template sections
- Explain business rules and data relationships

### Comment Syntax

**Two formats available**:

- `<wr-->content</wr-->` - Primary comment syntax
- `<wr-comment>content</wr-comment>` - Alternative syntax

```xml
<wr-->
This is a comment and will not appear in output.
Multiple lines are supported.
</wr-->

<wr-comment>
Alternative comment syntax.
</wr-comment>
```

## 16. Functions

**Purpose**: WebRelease2 provides 91+ built-in functions for data manipulation, formatting, and template operations.

**When to use**:

- Format dates and numbers for display
- Manipulate strings and text content
- Perform calculations and data validation
- Access page and site metadata
- Check data availability and types

**Function categories**:

- **Date/Time manipulation**: `currentTime()`, `formatDate()` - Format dates, get current time
- **String processing**: `string()`, `length()`, `substring()` - Text manipulation and formatting
- **Mathematical operations**: `number()`, `divide()`, `setScale()` - Precise calculations
- **Page operations**: `pageTitle()`, `pageURL()` - Access page metadata
- **Utility functions**: `isNull()`, `isNotNull()`, `count()` - Data validation and checks

### Function Examples

**Best practices**:

- Use appropriate functions for data types (string() for text, number() for calculations)
- Chain functions for complex operations
- Refer to function index for complete parameter specifications

```xml
%formatDate(currentTime(), "yyyy/MM/dd (E)")%
%pageTitle()%
%count(addresses)%
%isNotNull(description)%
```

## 17. Complete Template Example

**Purpose**: Demonstrates real-world usage of WebRelease2 features in a complete, functional template.

**Features demonstrated**:

- Conditional content rendering
- Multi-way page type switching
- Data filtering and variable management
- Loop control and item limiting
- Error handling and validation
- Resource references and method calls
- Component usage with selectors

**Template structure**: Header with conditional image, main content area with different layouts based on page type, component integration, error checking for data integrity.

```xml
<!DOCTYPE html>
<html>
<head>
    <title>%pageTitle()%</title>
    <link rel="stylesheet" href="%main-css%"/>
</head>
<body>
    <wr-- Page header with conditional navigation -->
    <header>
        <h1>%siteName%</h1>
        <wr-if condition="isNotNull(headerImage)">
            <img src="%headerImage%" alt="Header"/>
        </wr-if>

        <wr-- Component usage: Navigation component -->
        <wr-if condition="isNotNull(mainNavigation)">
            %mainNavigation.selectedValue().generateText()%
        </wr-if>
    </header>

    <wr-- Main content area -->
    <main>
        <wr-switch value="pageType">
            <wr-case value="news">
                <wr-- News page layout -->
                <wr-for list="articles" variable="article" count="i">
                    <article>
                        <h2>%article.title%</h2>
                        <time>%formatDate(article.date, "yyyy/MM/dd")%</time>
                        <p>%article.summary%</p>
                    </article>
                    <wr-break condition="i >= 5"/>
                </wr-for>
            </wr-case>

            <wr-case value="product">
                <wr-- Product page layout -->
                <wr-variable name="expensiveItems"/>
                <wr-for list="products" variable="product">
                    <wr-if condition="number(product.price) > 10000">
                        <wr-append name="expensiveItems" value="product"/>
                    </wr-if>
                </wr-for>

                <h2>Premium Products</h2>
                <wr-for list="expensiveItems" variable="item">
                    %drawProductCard(item.name, item.price, item.image)%
                </wr-for>
            </wr-case>

            <wr-default>
                <wr-- Default page layout with flexible content -->
                <h2>%pageTitle%</h2>
                <div class="content">
                    <wr-- Component usage: Flexible content sections -->
                    <wr-for list="contentSections" variable="section">
                        %section.selectedValue().generateText()%
                    </wr-for>
                </div>
            </wr-default>
        </wr-switch>
    </main>

    <wr-- Error checking -->
    <wr-error condition="isNull(content) && pageType != \"news\"">
        Page content is missing.
    </wr-error>
</body>
</html>
```

## Summary

This comprehensive reference covers all major WebRelease2 template features with practical examples optimized for AI-assisted development. Each section includes:

- **Purpose**: What the feature does and why it exists
- **When to use**: Specific scenarios and use cases
- **Best practices**: Recommended approaches and common patterns
- **Technical details**: Syntax, parameters, and implementation examples

**Key WebRelease2 concepts for AI developers**:

1. **Static generation**: Templates are processed server-side to generate static HTML
2. **Expression-based**: `%expression%` syntax for all dynamic content
3. **Array-centric**: Variables are stored as arrays, supporting complex data manipulation
4. **Type-flexible**: Automatic type conversion with explicit conversion functions
5. **Method-supported**: Reusable template functions for complex logic
6. **Resource-aware**: Built-in asset management with priority-based resolution
7. **Component-driven**: Modular, reusable content blocks with their own elements and methods
8. **Selector-enabled**: Dynamic component selection for flexible content authoring
