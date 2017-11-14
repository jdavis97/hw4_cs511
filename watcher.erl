-module(watcher).
-compile(export_all).
-author("Zach Saegesser, Khayyam Saleem").


start() ->
    {ok, [N]} = io:fread("enter number of sensors> ", "~d"),
    if N =< 1 ->
          io:fwrite("setup: range must be at least 2~n", []);
       true ->
         Num_watchers = 1 + (N div 10),
         L = setup_loop(0, N, []), 
         %werk here zach
    end.

setup_loop(Cur_SID, Last_SID, L) when Cur_SID >= Last_SID ->
    L;
setup_loop(Cur_SID, Last_SID, L) ->
    {S_Pid, _Ref} = spawn_monitor(sensor, gen_sensor, [self(), Cur_SID]),
    setup_loop(Cur_SID+1, Last_SID, L ++ [{Cur_SID, S_Pid}]).

watcher(L) ->
  io:format("~w~n", [L]), %print L
  receive
    {Sensor_ID, Measurement} ->
      io:format("Sensor ~w measured ~w~n", [Sensor_ID, Measurement]);
    {'EXIT', Reason} ->
      io:format("Sensor_ID crashed because of ~w~n", [Reason]),
      %start new sensor
      %update L
  %recieve Measurment
  %        catch exit(anomalous_reading) ->print sensor number
  %             restart sensor, delete crashed from List and add new one
  %             print new list of sensors
