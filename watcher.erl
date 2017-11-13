-module(watcher).
-compile(export_all).


start() ->
    {ok, [N]} = io:fread("enter number of sensors> ", "~d"),
    if N =< 1 ->
          io:fwrite("setup: range must be at least 2~n", []);
       true ->
         Num_watchers = 1 + (N div 10),
         setup_loop(N, Num_watchers)
 end.

setup_loop(0, Num_watchers) ->
  %stop
  ;
setup_loop(N, Num_watchers) ->







watcher(L) ->
  io:format("~w~n", [L]), %print L
  receive
    {Sensor_ID, Measurment} ->
      io:format("Sensor ~w measured ~w~n", [Sensor_ID, Measurment]);
    {'EXIT', Reason} ->
      io:format("Sensor_ID crashed because of ~w~n"),
      %start new sensor
      %update L
  %recieve Measurment
  %        catch exit(anomalous_reading) ->print sensor number
  %             restart sensor, delete crashed from List and add new one
  %             print new list of sensors
