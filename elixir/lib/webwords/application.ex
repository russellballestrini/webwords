defmodule WebWords.Application do
  use Application

  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "31337")
    
    children = [
      {Plug.Cowboy, scheme: :http, plug: WebWords, options: [port: port, ip: {0, 0, 0, 0}]}
    ]

    IO.puts("listening on 0.0.0.0:#{port}")
    
    opts = [strategy: :one_for_one, name: WebWords.Supervisor]
    Supervisor.start_link(children, opts)
  end
end