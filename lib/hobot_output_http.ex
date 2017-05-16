defmodule Hobot.Output.HTTP do
  @moduledoc """
  Writes out with using https.
  """

  use GenServer
  require Logger

  def match(topic_map, topic) do
    case Map.fetch(topic_map, topic) do
      {:ok, [_method, {_url, _headers, _content_type, _body}, _httpoptions, _options] = expected_data_structure} ->
        {:ok, expected_data_structure}
      {:ok, unexpected_data_structure} ->
        {:error, unexpected_data_structure}
    end
  end

  def pass_through_filters(data, filters) when is_list(filters) do
    Enum.reduce(filters, data, &(apply(&1, [&2])))
  end

  def put_into_arguments(data, arguments) do
    put_in(arguments, [Access.at(1), Access.elem(3)], data)
  end

  def do_http_request(arguments) do
    apply(:httpc, :request, arguments)
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
    case match(topic_map, topic) do
      {:ok, arguments_for_httpc_request} ->
        filters = Keyword.get(plugin_options, :filters, [])
        result =
          data
          |> pass_through_filters(filters)
          |> put_into_arguments(arguments_for_httpc_request)
          |> do_http_request
        Logger.debug inspect(result)
      {:error, unexpected_data_structure} ->
        Logger.warn fn ->
          "unexpected data strcture given: #{inspect unexpected_data_structure}"
        end
    end
    {:noreply, {topic_map, plugin_options}}
  end

  def terminate(reason, {topic_map, _plugin_options}) do
    for {topic, _} <- topic_map, do: Hobot.unsubscribe(topic)
    reason
  end
end
