# Pobo Ruby SDK

Official Ruby SDK for [Pobo API V2](https://api.pobo.space) - product content management and webhooks.

## Requirements

- Ruby 3.0+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pobo-sdk'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install pobo-sdk
```

## Quick Start

### API Client

```ruby
require 'pobo'

client = Pobo::Client.new(
  api_token: 'your-api-token',
  base_url: 'https://api.pobo.space', # optional
  timeout: 30 # optional, in seconds
)
```

## Import

### Import Order

```
1. Parameters (no dependencies)
2. Categories (no dependencies)
3. Products (depends on categories and parameters)
4. Blogs (no dependencies)
```

### Import Parameters

```ruby
parameters = [
  Pobo::DTO::Parameter.new(
    id: 1,
    name: 'Color',
    values: [
      Pobo::DTO::ParameterValue.new(id: 1, value: 'Red'),
      Pobo::DTO::ParameterValue.new(id: 2, value: 'Blue')
    ]
  ),
  Pobo::DTO::Parameter.new(
    id: 2,
    name: 'Size',
    values: [
      Pobo::DTO::ParameterValue.new(id: 3, value: 'S'),
      Pobo::DTO::ParameterValue.new(id: 4, value: 'M')
    ]
  )
]

result = client.import_parameters(parameters)
puts "Imported: #{result.imported}, Values: #{result.values_imported}"
```

### Import Categories

```ruby
categories = [
  Pobo::DTO::Category.new(
    id: 'CAT-001',
    is_visible: true,
    name: Pobo::DTO::LocalizedString.create('Electronics')
      .with_translation(Pobo::Language::CS, 'Elektronika')
      .with_translation(Pobo::Language::SK, 'Elektronika'),
    url: Pobo::DTO::LocalizedString.create('https://example.com/electronics')
      .with_translation(Pobo::Language::CS, 'https://example.com/cs/elektronika')
      .with_translation(Pobo::Language::SK, 'https://example.com/sk/elektronika'),
    description: Pobo::DTO::LocalizedString.create('<p>All electronics</p>')
      .with_translation(Pobo::Language::CS, '<p>Veškerá elektronika</p>')
      .with_translation(Pobo::Language::SK, '<p>Všetka elektronika</p>'),
    images: ['https://example.com/images/electronics.jpg']
  )
]

result = client.import_categories(categories)
puts "Imported: #{result.imported}, Updated: #{result.updated}"
```

### Import Products

```ruby
products = [
  Pobo::DTO::Product.new(
    id: 'PROD-001',
    is_visible: true,
    name: Pobo::DTO::LocalizedString.create('iPhone 15')
      .with_translation(Pobo::Language::CS, 'iPhone 15')
      .with_translation(Pobo::Language::SK, 'iPhone 15'),
    url: Pobo::DTO::LocalizedString.create('https://example.com/iphone-15')
      .with_translation(Pobo::Language::CS, 'https://example.com/cs/iphone-15')
      .with_translation(Pobo::Language::SK, 'https://example.com/sk/iphone-15'),
    short_description: Pobo::DTO::LocalizedString.create('Latest iPhone model')
      .with_translation(Pobo::Language::CS, 'Nejnovější model iPhone'),
    images: ['https://example.com/images/iphone-1.jpg'],
    categories_ids: ['CAT-001', 'CAT-002'],
    parameters_ids: [1, 2]
  )
]

result = client.import_products(products)

if result.has_errors?
  result.errors.each do |error|
    puts "Error: #{error['errors'].join(', ')}"
  end
end
```

### Import Blogs

```ruby
blogs = [
  Pobo::DTO::Blog.new(
    id: 'BLOG-001',
    is_visible: true,
    name: Pobo::DTO::LocalizedString.create('New Product Launch')
      .with_translation(Pobo::Language::CS, 'Uvedení nového produktu')
      .with_translation(Pobo::Language::SK, 'Uvedenie nového produktu'),
    url: Pobo::DTO::LocalizedString.create('https://example.com/blog/new-product')
      .with_translation(Pobo::Language::CS, 'https://example.com/cs/blog/novy-produkt')
      .with_translation(Pobo::Language::SK, 'https://example.com/sk/blog/novy-produkt'),
    category: 'news',
    description: Pobo::DTO::LocalizedString.create('<p>We are excited to announce...</p>')
      .with_translation(Pobo::Language::CS, '<p>S radostí oznamujeme...</p>'),
    images: ['https://example.com/images/blog-1.jpg']
  )
]

result = client.import_blogs(blogs)
puts "Imported: #{result.imported}, Updated: #{result.updated}"
```

## Export

### Export Products

```ruby
response = client.get_products(page: 1, per_page: 50)

response.data.each do |product|
  puts "#{product.id}: #{product.name.default}"
end

puts "Page #{response.current_page} of #{response.total_pages}"

# Iterate through all products (handles pagination automatically)
client.each_product do |product|
  puts "#{product.id}: #{product.name.default}"
end

# Filter by last update time
since = Time.new(2024, 1, 1)
response = client.get_products(last_update_from: since)

# Filter only edited products
response = client.get_products(is_edited: true)
```

### Export Categories

```ruby
response = client.get_categories

response.data.each do |category|
  puts "#{category.id}: #{category.name.default}"
end

# Iterate through all categories
client.each_category do |category|
  process_category(category)
end
```

### Export Blogs

```ruby
response = client.get_blogs

response.data.each do |blog|
  puts "#{blog.id}: #{blog.name.default}"
end

# Iterate through all blogs
client.each_blog do |blog|
  process_blog(blog)
end
```

## Content (HTML/Marketplace)

Products, categories, and blogs include a `content` field with generated HTML content:

```ruby
client.each_product do |product|
  next unless product.content

  # Get HTML content for web
  html_cs = product.content.get_html(Pobo::Language::CS)
  html_sk = product.content.get_html(Pobo::Language::SK)

  # Get content for marketplace
  marketplace_cs = product.content.get_marketplace(Pobo::Language::CS)

  # Get default content
  html_default = product.content.html_default
  marketplace_default = product.content.marketplace_default
end
```

## Webhook Handler

### Basic Usage (Rails)

```ruby
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def pobo
    handler = Pobo::WebhookHandler.new(webhook_secret: ENV['POBO_WEBHOOK_SECRET'])

    begin
      payload = handler.handle_request(request)

      case payload.event
      when Pobo::WebhookEvent::PRODUCTS_UPDATE
        SyncProductsJob.perform_later
      when Pobo::WebhookEvent::CATEGORIES_UPDATE
        SyncCategoriesJob.perform_later
      when Pobo::WebhookEvent::BLOGS_UPDATE
        SyncBlogsJob.perform_later
      end

      render json: { status: 'ok' }
    rescue Pobo::WebhookError => e
      render json: { error: e.message }, status: :unauthorized
    end
  end
end
```

### Manual Handling

```ruby
payload = handler.handle(
  payload: request.raw_post,
  signature: request.headers['X-Webhook-Signature']
)
```

### Webhook Payload

```ruby
payload.event     # String: "products.update", "categories.update", or "blogs.update"
payload.timestamp # Time
payload.eshop_id  # Integer
```

## Error Handling

```ruby
begin
  result = client.import_products(products)
rescue Pobo::ValidationError => e
  puts "Validation error: #{e.message}"
rescue Pobo::ApiError => e
  puts "API error (#{e.http_code}): #{e.message}"
  puts e.response_body
end
```

## Localized Strings

```ruby
# Create with default value
name = Pobo::DTO::LocalizedString.create('Default Name')

# Add translations using fluent interface
name = name
  .with_translation(Pobo::Language::CS, 'Czech Name')
  .with_translation(Pobo::Language::SK, 'Slovak Name')
  .with_translation(Pobo::Language::EN, 'English Name')

# Get values
name.default                      # => 'Default Name'
name.get(Pobo::Language::CS)      # => 'Czech Name'
name.to_hash                      # => { 'default' => '...', 'cs' => '...', ... }
```

### Supported Languages

| Code      | Language           |
|-----------|--------------------|
| `default` | Default (required) |
| `cs`      | Czech              |
| `sk`      | Slovak             |
| `en`      | English            |
| `de`      | German             |
| `pl`      | Polish             |
| `hu`      | Hungarian          |

## API Methods

| Method                                                            | Description                      |
|-------------------------------------------------------------------|----------------------------------|
| `import_products(products)`                                       | Bulk import products (max 100)   |
| `import_categories(categories)`                                   | Bulk import categories (max 100) |
| `import_parameters(parameters)`                                   | Bulk import parameters (max 100) |
| `import_blogs(blogs)`                                             | Bulk import blogs (max 100)      |
| `get_products(page:, per_page:, last_update_from:, is_edited:)`   | Get products page                |
| `get_categories(page:, per_page:, last_update_from:, is_edited:)` | Get categories page              |
| `get_blogs(page:, per_page:, last_update_from:, is_edited:)`      | Get blogs page                   |
| `each_product(last_update_from:, is_edited:)`                     | Iterate all products             |
| `each_category(last_update_from:, is_edited:)`                    | Iterate all categories           |
| `each_blog(last_update_from:, is_edited:)`                        | Iterate all blogs                |

## Limits

| Limit                        | Value        |
|------------------------------|--------------|
| Max items per import request | 100          |
| Max items per export page    | 100          |
| Product/Category ID length   | 255 chars    |
| Name length                  | 250 chars    |
| URL length                   | 255 chars    |
| Image URL length             | 650 chars    |
| Description length           | 65,000 chars |
| SEO description length       | 500 chars    |

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

## License

MIT License
