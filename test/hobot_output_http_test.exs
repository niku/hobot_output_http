defmodule Hobot.Output.HTTPTest do
  use ExUnit.Case
  doctest Hobot.Output.HTTP

  describe "Hobot.Output.HTTP.match/2" do
    test "maching topic found" do
      value = [:post, {'https://example.com', [], [], "hello~"}, [], []]
      topic_map = %{"foo_topic" => value}

      assert Hobot.Output.HTTP.match(topic_map, "foo_topic") == {:ok, value}
    end

    test "get unexpected data structure" do
      value = {}
      topic_map = %{"foo_topic" => value}

      assert Hobot.Output.HTTP.match(topic_map, "foo_topic") == {:error, value}
    end
  end
end
