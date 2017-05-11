defmodule Hobot.Output.HTTP do
  @moduledoc """
  Writes out with using https.
  """

  @wildcard "*"

  use GenServer
  require Logger

  def match(topic_map, topic) do
    case Map.fetch(topic_map, topic) do
      {:ok, [_method, {_url, _headers, _content_type, _body}, _httpoptions, _options] = expected_data_structure} ->
        {:ok, expected_data_structure}
      {:ok, unexpected_data_structure} ->
        {:error, unexpected_data_structure}
      :error ->
        case Map.has_key?(topic_map, @wildcard) do
          true -> Map.fetch(topic_map, @wildcard)
          false -> {:error, :no_match}
        end
    end
  end

  def start_link(args, options \\ [])
  def start_link(topic_map, options) when is_map(topic_map) do
    GenServer.start_link(__MODULE__, topic_map, options)
  end

  def init(topic_map) do
    for {topic, _} <- topic_map, do: Hobot.subscribe(topic)
    {:ok, topic_map}
  end

  def handle_cast({:broadcast, topic, data}, topic_map) do
    case match(topic_map, topic) do
      {:ok, value} ->
        body_putted = put_in(value, [Access.at(1), Access.elem(3)], data)
        apply(:httpc, :request, body_putted)
      {:error, :no_match} ->
        Logger.warn "no maching data found"
      {:error, unexpected_data_structure} ->
        Logger.warn "unexpected data strcture given: #{inspect unexpected_data_structure}"
    end
    {:noreply, topic_map}
  end

  def terminate(reason, topic_map) do
    for {topic, _} <- topic_map, do: Hobot.unsubscribe(topic)
    reason
  end
end
