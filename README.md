# Kickplan - Ruby SDK

## Configuration

Config options can be found in the [`Configuration`](/lib/kickplan/configuration.rb) module.

```ruby
Kickplan.configure do |config|
  config.access_token = "..."
  config.adapter = :http
end
```

Additionally, the SDK can read from ENV variables and has a set of reasonable [defaults](/lib/kickplan/default.rb).

## Adapters

The SDK currently supports 2 adapters: `:memory` and `:http`. Additional built-in adapters are planned.

The `:memory` adapter can be used for testing purposes or as a fully in-memory feature resolution tool.

You can also create and register your own adapter:

```ruby
Kickplan::Adapters.register(:custom_adapter, CustomAdapter)

Kickplan.configure do |config|
  config.adapter = :custom_adapter
end
```

@todo info on the Interface required for implementing a custom adapter.
@todo should this section go lower in the README?

## Resources

All API methods are accessed via various the [`Resource`](/lib/kickplan/resources) modules. Each
resource endpoint will generally have a corresponding [`Request`](/lib/kickplan/requests) module
that is configured to validate input.

### Accounts

@todo

### Features

@todo introduce what a feature is, `key`, defaults, etc.

#### `configure`

To configure a new feature:

```ruby
# Configure feature with defaults
Kickplan::Features.configure("chat")

# Fully customize feature
Kickplan::Features.configure("seats", {
  name: "Seats",
  default: "small",
  variants: { "small" => 10, "large" => 50 }
})
```

See [`Requests::ConfigureFeature`](/lib/kickplan/requests/configure_feature.rb) for a list parameters.

#### `resolve`

To resolve a single feature:

```ruby
Kickplan::Features.resolve("chat")
=> #<Kickplan::Responses::Resolution key="chat" value=false ...>

# Resolve with context
Kickplan::Features.resolve("chat", {
  context: { account_id: "..." }
})
=> #<Kickplan::Responses::Resolution key="chat" value=false ...>

# Detailed response
Kickplan::Features.resolve("chat", detailed: true)
=> #<Kickplan::Responses::Resolution key="chat" value=false metadata={...} ...>
```

To resolve all features, you can use the same method without a feature key:

```ruby
Kickplan::Features.resolve
=> [#<Kickplan::Responses::Resolution key="chat" value=false ...>,
 #<Kickplan::Responses::Resolution key="seats" value=false ...>]
```

See [`Requests::ResolveFeature`](/lib/kickplan/requests/resolve_feature.rb) for a list parameters.

### Metrics

@todo

## Additional Clients

Kickplan uses a single `Kickplan::Client` instance by default. However, you may need
multiple clients in your application to access multiple endpoints or utilize different
adapters.

Clients are referenced by an arbitrary name via `Kickplan.[]` or `Kickplan.client()`. Once referenced,
the client is instantiated and stored internally in a
[thread-safe registry](https://ruby-concurrency.github.io/concurrent-ruby/master/Concurrent/Map.html).

The default client is registered with the name `:default`.

```ruby
# Access the default client
Kickplan.client.class
=> Kickplan::Client

# These are all equivalent
Kickplan.client.object_id
Kickplan.client(:default).object_id
Kickplan[:default].object_id
=> 3180

# Instantiate a new client
Kickplan[:foobar].class
=> Kickplan::Client

# Clients are stored as singleton objects
Kickplan[:foobar].object_id == Kickplan[:foobar].object
=> true
```

### Configuration

The Kickplan SDK can be configured globally or on a per-client level. When instantiating,
clients will default to the global configuration but can customized afterwards:

```ruby
# Global configuration
Kickplan.configure do |config|
  config.access_token = "1234"
end

Kickplan.client.config.access_token
=> "1234"

Kickplan[:foobar].config.access_token
=> "1234"

# Per-client configuration
Kickplan[:foobar].configure do |config|
  config.access_token = "4321"
end

Kickplan.client.config.access_token
=> "1234"

Kickplan[:foobar].config.access_token
=> "4321"
```

### Resources

Resources on custom clients are referenced with the same syntax as the default client:

```ruby
# Default client
Kickplan::Feature.configure(...)

# Custom client
Kickplan[:foobar]::Features.configure(...)
```
