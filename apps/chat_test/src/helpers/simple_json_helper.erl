%%%-------------------------------------------------------------------
%%% @author pravosudov
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. Sep 2017 12:37
%%%-------------------------------------------------------------------
-module(simple_json_helper).
-author("pravosudov").

%% API
-export([parse/1]).

parse(Str) ->
    Str1 = re:replace(Str, "\\s+", "", [global,{return, list}]),
    Str2 = [E || E <- Str1, E =/= ${ andalso E =/= $\ andalso E =/= $" andalso E =/= $}],
    BinList = binary:split(list_to_binary(Str2), <<",">>, [global]),

    lists:foldl(fun(B, Acc) ->
        BL = binary:split(B, <<":">>, [global]),
        [list_to_tuple(BL)|Acc]
    end, [], BinList).

