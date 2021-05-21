%%%-------------------------------------------------------------------
%%% @author Nadavash
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. May 2021 14:39
%%%-------------------------------------------------------------------
-module(matrixSupervisor).
-author("Nadavash").

%% API
-export([restarter/0]).

restarter() ->
  process_flag(trap_exit, true),
  Pid = spawn_link(matrix_server, listen, []),
  register(matrix_server, Pid),
  receive
    {'EXIT', Pid, normal} -> ok; % no crash
    {'EXIT', Pid, shutdown} -> ok; % no crash
    {'EXIT', Pid, _} -> restarter() % restart
  end.