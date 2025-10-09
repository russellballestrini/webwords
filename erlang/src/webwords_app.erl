-module(webwords_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Port = case os:getenv("PORT") of
        false -> 31337;
        PortStr -> list_to_integer(PortStr)
    end,
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", webwords_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http_listener,
        [{port, Port}, {ip, {0, 0, 0, 0}}],
        #{env => #{dispatch => Dispatch}}
    ),
    io:format("listening on 0.0.0.0:~p~n", [Port]),
    webwords_sup:start_link().

stop(_State) ->
    ok.