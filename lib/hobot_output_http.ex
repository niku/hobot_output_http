defmodule Hobot.Output.HTTP do
  @moduledoc """
  Writes out with using https.
  """

  use GenServer
  require Logger

  def match(topic_map, topic) do
    case Map.fetch!(topic_map, topic) do
      [_method, {_url, _headers, _content_type, _body}, _httpoptions, _options] = expected_data_structure ->
        {:ok, expected_data_structure}
      unexpected_data_structure ->
        {:error, unexpected_data_structure}
    end
  end

  def pass_through_filters(data, filters) when is_list(filters) do
    Enum.reduce(filters, data, &(apply(&1, [&2])))
  end

  def build_argument(data, argument_builder, topic) do
    apply(argument_builder, [topic, data])
  end

  def do_http_request(argument) do
    apply(:httpc, :request, argument)
  end

  def start_link(topic_map, plugin_options \\ [], genserver_options \\ [])
  def start_link(topic_map, plugin_options, genserver_options) when is_map(topic_map) do
    GenServer.start_link(__MODULE__, {topic_map, plugin_options}, genserver_options)
  end

  def init({topic_map, plugin_options}) do
    for {topic, _} <- topic_map, do: Hobot.subscribe(topic)
    {:ok, {topic_map, plugin_options}}
  end

  def handle_cast({:broadcast, topic, data}, {topic_map, plugin_options}) do
    case Map.fetch(topic_map, topic) do
      {:ok, argument_builder} ->
        filters = Keyword.get(plugin_options, :filters, [])
        result =
          data
          |> pass_through_filters(filters)
          |> build_argument(argument_builder, topic)
          |> do_http_request
        Logger.debug inspect(result)
      :error ->
        Logger.warn fn ->
          "Matching topic does not find. topic_map: #{inspect topic_map}, data: #{data}"
        end
    end
    {:noreply, {topic_map, plugin_options}}
  end

  def terminate(reason, {topic_map, _plugin_options}) do
    for {topic, _} <- topic_map, do: Hobot.unsubscribe(topic)
    reason
  end
end
