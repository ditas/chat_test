%%%-------------------------------------------------------------------
%%% @author pravosudov
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Feb 2018 11:42
%%%-------------------------------------------------------------------
-module(ws_handler).
-author("pravosudov").

-record(state, {
    is_started = false
}).

%% API
-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).

init(Req, _Opts) ->
    {cowboy_websocket, Req, #state{}}.

websocket_init(State) ->
%%    erlang:start_timer(1000, self(), <<"Hello!">>),
    {ok, State}.

websocket_handle({text, Msg}, State#state{is_started = false}) ->

    io:format("~p~n", [State]),

%%    io:format("-------IN ~p~n", [Msg]), %% <<"{\"message\":\"fsdf\"}">>

    [{BinName}] = simple_json_helper:parse(Msg),
    Name = binary_to_list(BinName),

    Reply = "{
        \"reply\": ~p,
        \"user\": ~p
    }",
    Reply1 = io_lib:format(Reply, [
        Name,
        Name
    ]),

%%    io:format("-------OUT ~s~n", [Reply1]),

    {reply, {text, Reply1}, State};
websocket_handle(_Data, State) ->
    {ok, State}.

websocket_info({timeout, _Ref, Msg}, State) ->
%%    erlang:start_timer(1000, self(), <<"How' you doin'?">>),
    {reply, {text, Msg}, State};
websocket_info(_Info, State) ->
    {ok, State}.