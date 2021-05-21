%%%-------------------------------------------------------------------
%%% @author Nadavash
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. May 2021 14:42
%%%-------------------------------------------------------------------
-module(matrix_server).
-author("Nadavash").

%% API
-export([start_server/0, shutdown/0, mult/2, get_version/0, listen/0, upgrade_version/0]).

start_server()->
  io:format("starting server"),
  spawn(matrixSupervisor, restarter, []).


shutdown()->
  matrix_server ! shutdown.


mult(Mat1, Mat2)->
  MsgRef = make_ref(),
  matrix_server ! {self(), MsgRef, {multiple, Mat1, Mat2}},
  receive
    {MsgRef,Mat} -> Mat
  end.

get_version()->
  Pid = self(),
  MsgRef = make_ref(),
  matrix_server ! {Pid, MsgRef, get_version},
  receive
    {MsgRef, VersionIdentifier} -> VersionIdentifier
  end.


upgrade_version()->
  matrix_server ! sw_upgrade.

listen()->
  receive
    {Pid, MsgRef, {multiple, Mat1, Mat2}}->
      spawn(matrixMultiplier, multiplyMatrix, [{Pid, MsgRef, {multiple, Mat1, Mat2}}]),
      listen();

    shutdown ->
      exit(shutdown);

    {Pid, MsgRef, get_version} ->
      VersionIdentifier = version_1,
      Pid ! {MsgRef, VersionIdentifier},
      listen();

    sw_upgrade->
      ?MODULE:listen();

    _Other ->
      listen()
  end.