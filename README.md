# Hobot.Output.HTTP

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `hobot_output_http` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:hobot_output_http, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/hobot_output_http](https://hexdocs.pm/hobot_output_http).

## Usage

```console
iex(1)> defmodule MyModule do
...(1)>   def do_convert(topic, data) do
...(1)>     [:post, {'http://httpbin.org/post', [], [], data}, [], []]
...(1)>   end
...(1)> end

iex(2)> topic_map = %{ "foo" => &MyModule.do_convert/2 }

iex(3)> Hobot.Output.HTTP.start_link(topic_map, [], [])

iex(4)> Hobot.publish("foo", "hello~")

08:13:01.843 [debug] {:ok, {{'HTTP/1.1', 200, 'OK'}, [{'connection', 'keep-alive'}, {'date', 'Sat, 20 May 2017 23:13:01 GMT'}, {'via', '1.1 vegur'}, {'server','meinheld/0.6.1'}, {'content-length', '281'}, {'content-type', 'application/json'}, {'access-control-allow-origin', '*'}, {'access-control-allow-credentials', 'true'}, {'x-powered-by', 'Flask'}, {'x-processed-time', '0.000798940658569'}], '{\n  "args": {}, \n  "data": "hello~", \n  "files": {}, \n  "form": {}, \n  "headers": {\n    "Connection": "close", \n    "Content-Length": "6", \n    "Content-Type": "", \n    "Host": "httpbin.org"\n  }, \n  "json": null, \n  "origin": "124.100.44.46", \n  "url": "http://httpbin.org/post"\n}\n'}}
```
