% Prolog WebWords Implementation
% This uses SWI-Prolog's HTTP server library

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_client)).
:- use_module(library(http/http_open)).

% Define the HTTP route
:- http_handler('/', webwords_handler, []).

% HTTP request handler
webwords_handler(Request) :-
    http_parameters(Request, [
        keyword(Keyword, [optional(true), default('')]),
        target(Target, [optional(true), default('')])
    ]),
    
    % Check if both parameters are provided
    (   (Keyword \= '', Target \= '') ->
        % Attempt to fetch the target URL
        catch(
            (
                http_get(Target, Body, []),
                % Check if keyword is in the body
                (   sub_string(Body, _, _, _, Keyword) ->
                    Found = 'true'
                ;   Found = 'false'
                ),
                format(user_error, 'found=~w, keyword=~w, uri=~w~n', [Found, Keyword, Target])
            ),
            Error,
            (
                format(user_error, 'Error fetching ~w: ~w~n', [Target, Error]),
                Found = 'false'
            )
        )
    ;   Found = 'false'
    ),
    
    % Send HTTP response
    format('Content-Type: text/plain~n~n'),
    write(Found).

% Main predicate to start the server
main :-
    write('listening on 0.0.0.0:31337'), nl,
    http_server(http_dispatch, [port(31337), bind_address('0.0.0.0')]),
    % Keep the server running
    thread_get_message(_).