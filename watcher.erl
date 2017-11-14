-module(watcher).
-compile(export_all).
-author("Zach Saegesser, Khayyam Saleem").


start() ->
    {ok, [N]} = io:fread("enter number of sensors> ", "~d"),
    if N =< 1 ->
          io:fwrite("setup: range must be at least 2~n", []);
       true ->
         Num_watchers = 1 + (N div 10),
         %L = setup_loop(0, N, []),
         setup_loop(N, Num_watchers,0),
    end.

% setup_loop(Cur_SID, Last_SID, L) when Cur_SID >= Last_SID ->
%     L;
% setup_loop(Cur_SID, Last_SID, L) ->
%     {S_Pid, _Ref} = spawn_monitor(sensor, gen_sensor, [self(), Cur_SID]),
%     setup_loop(Cur_SID+1, Last_SID, L ++ [{Cur_SID, S_Pid}]).

% setup_loop(N, 0) ->
%   ;
% setup_loop(N,Num_watchers, Curr_sensor_num) when N >=10 ->
%   Watcher_Pid = spawn(watcher, watcher_start, [10, Curr_sensor_num, []]),
%   setup_loop(N-10, Num_watchers-1, Curr_sensor_num+1);
% setup_loop(N,Num_watchers, Curr_sensor_num) when N < 10 ->
%   Watcher_Pid = spawn(watcher, watcher_start, [10, Curr_sensor_num, []]).
%
% watcher_start(0, Curr_sensor_num, L) ->
%   spawn_monitor()
% watcher_start(Num_sensors, Curr_sensor_num, L) ->



setup_loop(N, 0, Curr_sensor_num) ->
  W_ID = spawn(watcher, watcher_start, [list:seq(Curr_sensor_num, Curr_sensor_num+N), []]);
      %catches the last case where the watcher will watch less than 10 sensors,
setup_loop(N, Num_watchers, Curr_sensor_num) ->
  W_ID = spawn(watcher, watcher_start, [list:seq(Curr_sensor_num, Curr_sensor_num+10), []]);
      %spawns a watcher_starter with a list of numbers representing the Sensor IDs that watcher should monitor
  setup_loop(N-10, Num_watchers-1, Curr_sensor_num+10).

watcher_start([], L_watched_sensors) ->
  watcher(L_watched_sensors);
      %initiates the receive loop of a watcher
watcher_start(L_sensorIDs, L_watched_sensors) ->
  Curr_sensorID = list:nth(0,L_sensorIDs),
      %grabs the sensor ID at the front of the list
  {Sensor_PID, _Ref} = spawn_monitor(sensor, gen_sensor, [self(), Curr_sensorID]),
      %spawns the sensor with arguments of the watcher PID and the sensor ID, also sets the watcher to monitor that sensor
  watcher_start(list:nthtail(0,L_sensorIDs),list:append(L_watched_sensors, {Curr_sensorID, Sensor_PID}).
      %recursive call teh watcher start with first argument the L_sensorIDs[1:] and the tail recursive built list of {sensorID, sensorPID}

watcher(L) ->
  io:format("~w~n", [L]), %print L
  receive
    {Sensor_ID, Measurement} ->
      io:format("Sensor ~w measured ~w~n", [Sensor_ID, Measurement]);
    {'DOWN', _Ref, gen_sensor, _PID, anomalous_reading} ->
      io:format("Sensor_ID crashed because of ~w~n", [Reason]),
      %start new sensor
      %update L
  %recieve Measurment
  %        catch exit(anomalous_reading) ->print sensor number
  %             restart sensor, delete crashed from List and add new one
  %             print new list of sensors
