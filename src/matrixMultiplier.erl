%%%-------------------------------------------------------------------
%%% @author Nadavash
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. May 2021 13:25
%%%-------------------------------------------------------------------
-module(matrixMultiplier).
-author("Nadavash").

%% API
-export([multiplyMatrix/1]).


multiplyMatrix({Pid, MsgRef, {multiple, Mat1, Mat2}})->
  NewMatRowsNum = tuple_size(matrix:getCol(Mat1, 1)),
  NewMatColsNum = tuple_size(matrix:getRow(Mat2, 1)),
  [spawn(fun()-> getMultiplyElement(self(),0, matrix:getRow(Mat1,Row), matrix:getCol(Mat2, Col), tuple_size(matrix:getRow(Mat1, 1))) end) || Row<- lists:seq(1, NewMatRowsNum), Col<- lists:seq(1, NewMatColsNum)],
  NewMatrix = getResultMatrix(matrix:getZeroMat(NewMatRowsNum,NewMatColsNum), NewMatRowsNum*NewMatColsNum),
  Pid ! {MsgRef, NewMatrix}.

getMultiplyElement(RequestPID,Sum,Row,Col,0) ->
  RequestPID ! {Sum,Row,Col};

getMultiplyElement(RequestPID,Sum,Row,Col,Cnt) ->
  RowElement = element(Cnt, Row),
  ColElement = element(Cnt, Col),
  getMultiplyElement(RequestPID,Sum + RowElement*ColElement ,Row,Col,Cnt-1).


getResultMatrix(Matrix,0)->
  Matrix;

getResultMatrix(Matrix,Cnt)->
  receive
    {Sum,Row,Col}->
      getResultMatrix(matrix:setElementMat(Row,Col,Matrix,Sum),Cnt-1);
    _other ->
      getResultMatrix(Matrix,Cnt)
  end.
