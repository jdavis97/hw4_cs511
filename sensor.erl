-module(sensor).
-compile(export_all).
-author("Zach Saegesser, Khayyam Saleem").


sensor(Watcher_Pid, Sensor_ID) ->
  %linked wit a watcher so that if this
  %sensor crashes it the watcher will restart it
  Sleep_time = rand:uniform(10000),
  timer:sleep(Sleep_time),
  Measurement = rand:uniform(11),

  case Measurement of
    11 -> exit(anomalous_reading);
    Otherwise -> Watcher_Pid!{Sensor_ID, Measurement}
  end.

  %if num is 11 thenn crashes sensor
  %else Watcher_Pid!reading
