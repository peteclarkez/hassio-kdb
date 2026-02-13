/ Custom RDB Functions
/ This file is loaded by the RDB if present at /scripts/rdb_custom.q
/ Add your custom real-time analytics and functions here

show "loading RDB custom functions...";
/ Log the number of rows in the hass_events table
logHassEventsCount:{
	/ attempt to count hass_events, return -1 on error
	cnt:@[count; hass_event; { -1 }];
  //cnt = count value `hass_events;
	if[cnt = -1; 
    show "hass_events table not found";
    :()
   ];
	show "hass_events rows: ", (string cnt);
 };

/ Timer callback invoked on each timer tick
.z.ts:{
	logHassEventsCount[];
 };

/ Helpers to control the timer at runtime
startHassEventsTimer:{[ms]
  show "starting Home Assistant events timer with interval: ", (string ms), " ms";
	system "t ", string ms;
 };

stopHassEventsTimer:{
	system "t 0";
 };

/ Start the timer to run every 60000ms (1 minute) by default
startHassEventsTimer[15*60000];


-1 "Custom RDB functions loaded";
