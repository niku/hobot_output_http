defmodule Hobot.Output.HTTPTest do
  use ExUnit.Case
  doctest Hobot.Output.HTTP

  describe "Hobot.Output.HTTP.match/2" do
    test "maching topic found" do
      value = [:post, {'https://example.com', [], [], "hello~"}, [], []]
      wildcard_value = [:put, {'https://example.com', [], [], "cool"}, [], []]
      topic_map = %{"foo_topic" => value, "*" => wildcard_value}

      assert Hobot.Output.HTTP.match(topic_map, "foo_topic") == {:ok, value}
    end

    test "maching topic does not found" do
      value = [:post, {'https://example.com', [], [], "hello~"}, [], []]
      wildcard_value = [:put, {'https://example.com', [], [], "cool"}, [], []]
      topic_map = %{"foo_topic" => value, "*" => wildcard_value}

      assert Hobot.Output.HTTP.match(topic_map, "bar_topic") == {:ok, wildcard_value}
    end

    test "maching topic does not found and no wildcard given" do
      value = [:post, {'https://example.com', [], [], "hello~"}, [], []]
      topic_map = %{"foo_topic" => value}

      assert Hobot.Output.HTTP.match(topic_map, "bar_topic") == {:error, :no_match}
    end

    test "get unexpected data structure" do
      value = {}
      wildcard_value = [:put, {'https://example.com', [], [], "cool"}, [], []]
      topic_map = %{"foo_topic" => value, "*" => wildcard_value}

      assert Hobot.Output.HTTP.match(topic_map, "foo_topic") == {:error, value}
    end
  end
end
