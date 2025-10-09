-module(webwords_handler).

-export([init/2]).

init(Req, Opts) ->
    #{keyword := Keyword, target := Target} = cowboy_req:match_qs([{keyword, [], <<"">>}, {target, [], <<"">>}], Req),
    Found = case {Keyword, Target} of
        {<<>>, _} -> <<"false">>;
        {_, <<>>} -> <<"false">>;
        {K, T} ->
            Result = case fetch_url(T) of
                {ok, Body} ->
                    case binary:match(Body, K) of
                        nomatch -> <<"false">>;
                        _ -> <<"true">>
                    end;
                {error, _} -> <<"false">>
            end,
            io:format("found=~s, keyword=~s, uri=~s~n", [Result, K, T]),
            Result
    end,
    
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, Found, Req),
    {ok, Req2, Opts}.

fetch_url(Url) ->
    case hackney:get(Url, [], <<>>, [{timeout, 10000}]) of
        {ok, 200, _Headers, ClientRef} ->
            {ok, Body} = hackney:body(ClientRef),
            {ok, Body};
        _ ->
            {error, failed}
    end.