require "minitest/autorun"
require "kickplan"

class KickplanTest < Minitest::Test

  def setup_features
    {
      "features": [
        {"key": "boolean-flag", "variant": "true", metadata:{}},
        {"key": "integer-flag", "variant": "1", metadata:{}},
        {"key": "string-flag", "variant": "value", metadata:{}},
        {"key": "object-flag", "variant": {"key" => "value"}, metadata:{}}
      ]
    }
  end

  def setup
    Kickplan.configure("api_key", "app.kickplan.io")
    Kickplan.set_context("account1")
    @client = Kickplan.new
  end

  def test_evaluate_returns_boolean_variant
    @client.instance_variable_set(:@features, setup_features) #TOOD: probably a better way to do this

    assert_equal true, @client.evaluate_boolean("boolean-flag", false)
  end

  def test_evaluate_returns_string_variant
    @client.instance_variable_set(:@features, setup_features)

    assert_equal "value", @client.evaluate_string("string-flag", "default")
    assert_equal "default", @client.evaluate_string("string-flag-nope", "default")
  end

  def test_evaluate_returns_integer_variant
    @client.instance_variable_set(:@features, setup_features)

    assert_equal 1, @client.evaluate_integer("integer-flag", 0)
  end

  def test_evaluate_returns_object_variant
    @client.instance_variable_set(:@features, setup_features)

    assert_equal({"key" => "value"}.to_json, @client.evaluate_object("object-flag", {}))
  end

  def test_flag_details_returns_object
    @client.instance_variable_set(:@features, setup_features)
    features = setup_features
    feature = features[:features].find { |feature| feature[:key] == "string-flag" }

    assert_equal feature, @client.flag_details("string-flag", "default")
    assert_equal "default", @client.flag_details("string-flag-nope", "default")
  end


  def test_load_features_returns_data
    skip("I don't know what the API looks like yet.")
  end
end
