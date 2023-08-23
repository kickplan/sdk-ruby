# frozen_string_literal: true

# require "graphql"
# require "net/http"
# require "json"
# require "to_boolean"

module Kickplan
  require_relative "kickplan/version"

  #def self.configure(api_key, domain="app.kickplan.io")
  #  @@api_key = api_key
  #  @@domain = domain
  #end

  #def self.set_context(account)
  #  @@context = account
  #end

  #def flag_details(flag, default)
  #  feature = fetch_flag(flag)
  #  return default unless feature
  #  feature
  #end

  #def fetch_flag(flag)
  #  features[:features].find { |feature| feature[:key] == flag }
  #end

  #def evaluate(flag, default)
  #  feature = fetch_flag(flag)
  #  return default unless feature
  #  feature[:variant]
  #end

  #def evaluate_boolean(flag, default)
  #  value = evaluate(flag, default)
  #  return value.to_boolean
  #end

  #def evaluate_integer(flag, default)
  #  value = evaluate(flag, default)
  #  return value.to_i
  #end

  #def evaluate_string(flag, default)
  #  value = evaluate(flag, default)
  #  return value.to_s
  #end

  #def evaluate_object(flag, default)
  #  value = evaluate(flag, default)
  #  return value.to_json
  #end

  #private

  #def features(account=nil)
  #  context = account || @@context
  #  return @features if @features
  #  raise "Configure first" unless @@domain
  #  raise "Configure first" unless @@api_key

  #  uri = URI.parse("https://#{@@domain}/api/v1/graphql")
  #  @features = QueryLoader.new.load_features(product, context, uri)
  #end
#end


#class QueryLoader

  #features_query = <<~GRAPHQL
  #  query {
  #  }
  #GRAPHQL

  #def http(uri)
  #  http = Net::HTTP.new(uri.host, uri.port)
  #  http.use_ssl = true
  #end

  #def client(http)
  #  #TODO: where does schema come
  #  client = GraphQL::Client.new(schema: schema, execute: http.method(:post))
  #end

  #def load_features(product, account, uri)
  #  client = client(http(uri))
  #  query = features_query(product, account)
  #  result = client.execute(query)
  #  response = JSON.parse(result.to_json)
  #  return response["data"]
  #end

#end
end
