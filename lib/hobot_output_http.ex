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
      {:ok, arguments_builder} ->
        filters = Keyword.get(plugin_options, :filters, [])
        case Enum.reduce_while(filters, data, &(apply(&1, [&2]))) do
          filtered_data when is_binary(filtered_data) ->
            httpc_request_arguments = apply(arguments_builder, [topic, filtered_data])
            result = apply(:httpc, :request, httpc_request_arguments)
            Logger.debug inspect(result)
          nil ->
            Logger.info fn ->
              "Ignores data due to filtered value is `nil`. The data are: #{inspect data}"
            end
        end
    end
    {:noreply, {topic_map, plugin_options}}
  end

  def terminate(reason, {topic_map, _plugin_options}) do
    for {topic, _} <- topic_map, do: Hobot.unsubscribe(topic)
    reason
  end
end
