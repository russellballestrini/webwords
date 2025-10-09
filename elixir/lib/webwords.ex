defmodule WebWords do
  use Plug.Router

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug :match
  plug :dispatch

  get "/" do
    keyword = conn.params["keyword"] || ""
    target = conn.params["target"] || ""
    
    found = if keyword != "" and target != "" do
      case HTTPoison.get(target, [], recv_timeout: 10_000) do
        {:ok, %HTTPoison.Response{body: body}} ->
          if String.contains?(body, keyword) do
            "true"
          else
            "false"
          end
        {:error, _} ->
          "false"
      end
    else
      "false"
    end
    
    IO.puts("found=#{found}, keyword=#{keyword}, uri=#{target}")
    
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, found)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end