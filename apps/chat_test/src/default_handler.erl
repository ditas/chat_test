%%%-------------------------------------------------------------------
%%% @author pravosudov
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Feb 2018 11:21
%%%-------------------------------------------------------------------
-module(default_handler).
-author("pravosudov").

%% API
-export([init/2]).

init(Req0, State) ->
    {ok, Cwd} = file:get_cwd(),
    Filename = filename:join([Cwd, "apps/chat_test/priv", "websocket_test.html"]),
    {ok, Body} = file:read_file(Filename),

    Req = cowboy_req:reply(200, #{<<"content-type">> => <<"text/html">>}, Body, Req0),
    {ok, Req, State}.
