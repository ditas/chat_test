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

websocket_handle({text, Msg}, #state{is_started = false} = State) ->
    [{BinName}] = simple_json_helper:parse(Msg),
    Name = binary_to_list(BinName),

    {Reply, State1} = case chat_session:add_user(Name, self()) of
        {ok, added} ->
            S = State#state{is_started = true},
            R = "{\"user\": ~p, \"reply\": ~p}",
            R1 = io_lib:format(R, [Name, "ok"]),
            {R1, S};
        {error, Reason} ->
            R = "{\"reply\": ~p}",
            R1 = io_lib:format(R, [Reason]),
            {R1, State}
    end,
    {reply, {text, Reply}, State1};
websocket_handle({text, Msg}, #state{is_started = true} = State) ->

    io:format("________________~p~n", [Msg]),

    [{BinName, BinTxt}] = simple_json_helper:parse(Msg),
    chat_session:cast_all(BinName, BinTxt),
    {reply, {text, ""}, State};
websocket_handle(_Data, State) ->
    {ok, State}.

websocket_info({timeout, _Ref, Msg}, State) ->
%%    erlang:start_timer(1000, self(), <<"How' you doin'?">>),
    {reply, {text, Msg}, State};
websocket_info({cast, BinName, BinMsg}, State) ->

    io:format("----------~p~n", [{BinName, BinMsg}]),

    Reply = "{\"message\": ~p, \"from\": ~p}",
    Reply1 = io_lib:format(Reply, [binary_to_list(BinMsg), binary_to_list(BinName)]),
    {reply, {text, Reply1}, State};
websocket_info(_Info, State) ->
    {ok, State}.