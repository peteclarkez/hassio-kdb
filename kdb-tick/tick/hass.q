// HASS Tables

hass_event:([] time:`timestamp$(); sym:`$(); entity_id:`$(); nvalue:`float$();svalue:();eattr:())


// 
// convertJsonTime
// @param t float Float time value as generated by Python json converter
// @return timestamp
// @example  convertJsonTime[ (.j.k d)`time]
//
convertJsonTime:{[t] (`timestamp$1000000000*t)+`long$1970.01.01D00 };

//
// .u.updjson
// @param t symbol The tablename 
// @param d char[] Json data, See payload in comment below for example  
// @return null
 
 .u.updjson: {[t; d]
   x:@[;`time`domain`entity_id`value`svalue`attributes] _[;`host] raze (_;@).\:((.j.k 0N!.p.d:d);`event);
   tblData: flip(cols hass_event)!enlist each @ [;(enlist 0); convertJsonTime] @ [;(1 2);(`$)] x;
   updData: value flip tblData;
   .u.upd[t;updData]
   //insert[t ;tblData]
  }

// payload = {
//             "time": event.time_fired.timestamp(),
//             "host": name,
//             "event": {
//                 "time": event.time_fired.timestamp(),
//                 "domain": state.domain,
//                 "entity_id": state.object_id,
//                 "attributes": dict(state.attributes),
//                 "value": _state,
//             }

// Debug version
//.u.updjson:{[t;d] .p.t:t;.p.d:d;0N!(t;d)}
// .u.updjson:{[t;d]  insert[.p.t:t] flip(cols hass_event)!enlist each @ [;(enlist 0); convertJsonTime] @ [;(1 2);(`$)] @[;`time`domain`entity_id`value`attributes] _[;`host] raze (_;@).\:((.j.k .p.d:d);`event) }

//.pc.j:{\"time\": 1604877539.956502, \"host\": \"hass_event\", \"event\": {\"domain\": \"binary_sensor\", \"entity_id\": \"updater\", \"attributes\": {\"friendly_name\": \"Updater\"}, \"value\": 0}}"
//.u.updjson[`hass_event;.pc.j]