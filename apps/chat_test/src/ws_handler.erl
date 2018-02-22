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
    {cowboy_websocket, Req, #state{}, #{idle_timeout => infinity}}.

websocket_init(State) ->
    {ok, State}.

websocket_handle({text, Msg}, #state{is_started = false} = State) ->
    [{<<"name">>, BinName}] = jsx:decode(Msg),

    {Reply, State1} = case chat_session:add_user(BinName, self()) of
        {ok, added} ->
            S = State#state{is_started = true},
            R = jsx:encode([{<<"user">>, BinName},{<<"reply">>, ok}]),
            {R, S};
        {error, Reason} ->
            R = jsx:encode([{<<"reply">>, Reason}]),
            {R, State}
    end,
    {reply, {text, Reply}, State1};
websocket_handle({text, Msg}, #state{is_started = true} = State) ->
    [{<<"name">>, BinName}, {<<"txt">>, BinTxt}] = jsx:decode(Msg),
    chat_session:cast_all(BinName, BinTxt),
    {reply, {text, ""}, State};
websocket_handle(_Data, State) ->
    {ok, State}.

websocket_info({cast, BinName, BinMsg}, State) ->
    Reply = jsx:encode([{<<"message">>, BinMsg},{<<"from">>, BinName}]),
    {reply, {text, Reply}, State};
websocket_info(_Info, State) ->
    {ok, State}.