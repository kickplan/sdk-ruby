class Kickplan

  def self.configure(api_key, domain="app.kickplan.io")
    @@api_key = api_key
    @@domain = domain
  end


end



require 'graphql'
require 'net/http'
require 'json'

class QueryLoader

  features_query = <<~GRAPHQL
    query {
    }
  GRAPHQL

  def http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
  end

  def client(http)
    client = GraphQL::Client.new(schema: schema, execute: http.method(:post))
  end

  def load_features(account, product, uri)
    client = client(http(uri))
    result = client.execute(features_query)
    response = JSON.parse(result.to_json)
    return response["data"]
  end

end
