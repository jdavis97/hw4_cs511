-module(watcher).
-compile(export_all).
-author("Zach Saegesser, Khayyam Saleem").


start() ->
    {ok, [N]} = io:fread("enter number of sensors> ", "~d"),
    if N =< 1 ->
          io:fwrite("setup: range must be at least 2~n", []);
       true ->
         Num_watchers = 1 + (N div 10),
         setup_loop(N, Num_watchers,0)
    end.

setup_loop(N, 1, Curr_sensor_num) ->
  W_ID = spawn(watcher, watcher_start, [lists:seq(Curr_sensor_num, Curr_sensor_num+(N-1)), []]);
      %catches the last case where the watcher will watch less than 10 sensors,
setup_loop(N, Num_watchers, Curr_sensor_num) ->
  W_ID = spawn(watcher, watcher_start, [lists:seq(Curr_sensor_num, Curr_sensor_num+10), []]),
      %spawns a watcher_starter with a list of numbers representing the Sensor IDs that watcher should monitor
  setup_loop(N-10, Num_watchers-1, Curr_sensor_num+10).

watcher_start([], L_watched_sensors) ->
  io:fwrite("~w~n", [L_watched_sensors]),
  watcher(L_watched_sensors);
      %initiates the receive loop of a watcher
watcher_start(L_sensorIDs, L_watched_sensors) ->
  Curr_sensorID = lists:nth(1,L_sensorIDs),
      %grabs the sensor ID at the front of the list
  {Sensor_PID, _Ref} = spawn_monitor(sensor, gen_sensor, [self(), Curr_sensorID]),
      %spawns the sensor with arguments of the watcher PID and the sensor ID, also sets the watcher to monitor that sensor
  watcher_start(lists:nthtail(1,L_sensorIDs),lists:append(L_watched_sensors,[{Curr_sensorID, Sensor_PID}])).
      %recursive call the watcher start with first argument the L_sensorIDs[1:] and the tail recursive built list of {sensorID, sensorPID}

watcher(L) ->
  receive
    {Sensor_ID, Measurement} ->
      io:fwrite("Sensor ~w measured ~w~n", [Sensor_ID, Measurement]),
      watcher(L);
    {'DOWN', _Ref, _Process, PID, Reason} ->
      %io:format("received crash"),
      {Sensor_ID, SPID} = lists:keyfind(PID, 2, L),
      io:fwrite("Sensor ~w crashed because of ~w~n", [Sensor_ID, Reason]),
      {Sensor_PID, _NRef} = spawn_monitor(sensor, gen_sensor, [self(), Sensor_ID]),
      Temp_list = L -- [{Sensor_ID, SPID}],
      New_list = Temp_list ++ [{Sensor_ID, Sensor_PID}],
      io:fwrite("~w~n", [New_list]),
      watcher(New_list)
    end.
