## Configuration

Config options can be found in the [`Configuration`](https://github.com/kickplan/sdk-ruby/blob/main/lib/kickplan/configuration.rb) module.

```ruby
require "kickplan"

Kickplan.configure do |config|
  config.adapter = :http
  config.endpoint = "https://demo-control.kickplan.com"
end
```

Additionally, the SDK can read from ENV variables and has a set of reasonable [defaults](https://github.com/kickplan/sdk-ruby/blob/main/lib/kickplan/default.rb).

## Resources

All API methods are accessed via the various [`Resource`](https://github.com/kickplan/sdk-ruby/blob/main/lib/kickplan/resources) modules.

Each resource endpoint will generally have a corresponding [`Request`](https://github.com/kickplan/sdk-ruby/blob/main/lib/kickplan/requests) module
that is configured to validate input client-side.

### Accounts

**`#create`**

Creates a new account record:

```ruby
Kickplan::Accounts.create(
  key: "acme",
  name: "Acme",
  account_plans: [{ plan_key: "essentials" }]
)
```

See [`Requests::Accounts::Create`](https://github.com/kickplan/sdk-ruby/blob/main/lib/kickplan/requests/accounts/create.rb) for parameters.

**`#update`**

Updates an existing account record:

```ruby
Kickplan::Accounts.update("acme", {
  name: "Acme Inc.",
  account_plans: [{ plan_key: "professional" }]
})
```

See [`Requests::Accounts::Update`](https://github.com/kickplan/sdk-ruby/blob/main/lib/kickplan/requests/accounts/update.rb) for parameters.

### Features

**`#resolve`**

To resolve a single feature, pass the feature key as the first argument:

```ruby
Kickplan::Features.resolve("chat")
=> #<Kickplan::Schemas::Resolution key="chat" value=false ...>

# Resolve for an account
Kickplan::Features.resolve("chat", {
  context: { account_key: "acme" }
})
=> #<Kickplan::Schemas::Resolution key="chat" value=true ...>

# Detailed response
Kickplan::Features.resolve("chat", detailed: true)
=> #<Kickplan::Schemas::Resolution key="chat" value=false metadata={...} ...>
```

To resolve all features, omit the feature key:

```ruby
Kickplan::Features.resolve()
=> [#<Kickplan::Schemas::Resolution key="chat" value=false ...>,
 #<Kickplan::Schemas::Resolution key="seats" value=false ...>]

# Resolve for an account
Kickplan::Features.resolve(context: { account_key: "acme" })
=> [#<Kickplan::Schemas::Resolution key="chat" value=true ...>,
 #<Kickplan::Schemas::Resolution key="seats" value=false ...>]
```

See [`Requests::Features::Resolve`](https://github.com/kickplan/sdk-ruby/blob/main/lib/kickplan/requests/features/resolve.rb) for parameters.

### Metrics

**`#set`**

Sets a metric to a specific value:

```ruby
Kickplan::Metrics.set(key: "seats", value: "5", account_key: "acme")
=> true
```

See [`Requests::Metrics::Set`](https://github.com/kickplan/sdk-ruby/blob/main/lib/kickplan/requests/metrics/set.rb) for parameters.

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

@todo Add info on the interface required for implementing a custom adapter.

## Additional Clients

By default, the Kickplan SDK utilizes a single client for all requests. You may have noticed this client
referenced when inspecting the resource modules:

```ruby
Kickplan::Features
=> #<Kickplan::Client(default)>::Features
```

There may be scenarios in which multiple clients are necessary (different endpoints, products, etc.). The
Kickplan SDK has a [thread-safe registry](https://ruby-concurrency.github.io/concurrent-ruby/master/Concurrent/Map.html) that stores all instantiated clients so
you don't have keep up the client instance yourself.

To create a new client, simply reference it by name using `Kickplan[]` or `Kickplan.client()`:

```ruby
# Equivalent
Kickplan[:custom]
Kickplan.client(:custom)
=> #<Kickplan::Client(custom)>

# Clients are stored as singleton objects
Kickplan[:custom].object_id == Kickplan[:custom].object_id
=> true
```

Resources are accessed in the same manner as using the default client:

```ruby
Kickplan[:custom]::Features
=> #<Kickplan::Client(custom)>::Features
```

The default client can also be accessed directly, though this is normally omitted. However, when
using multiple clients, you may prefer to access the default client explicitly for clarity or
configuration purposes:

```ruby
# Equivalent
Kickplan::Features
Kickplan[:default]::Features
=> #<Kickplan::Client(default)>::Features
```

### Configuration

The Kickplan SDK can be configured globally or on a per-client level. By default,
all clients will utilize the global configuration but you can also configure the client
directly:

```ruby
# Global configuration
Kickplan.configure do |config|
  config.access_token = "1234"
end

Kickplan.client.config.access_token
=> "1234"

Kickplan[:custom].config.access_token
=> "1234"

# Client configuration
Kickplan[:custom].configure do |config|
  config.access_token = "4321"
end

Kickplan.config.access_token
=> "1234"

Kickplan[:custom].config.access_token
=> "4321"
```
