// --------------------------------------------------------------------------
// Licensed Materials - Property of IBM
//
// 5725-A06 5725-A29 5724-Y48 5724-Y49 5724-Y54 5724-Y55
// Copyright IBM Corporation 1998, 2013. All Rights Reserved.
//
// Note to U.S. Government Users Restricted Rights:
// Use, duplication or disclosure restricted by GSA ADP Schedule
// Contract with IBM Corp.
// --------------------------------------------------------------------------


using CP;

{string} Tasks = ...;
int durations[Tasks] = ...;
int start    [Tasks] = ...;

{string} Groups = ...;

int maxUnusedWorkers[Groups] = ...;

{string} mayperform[Tasks] = ...;


tuple OptTask {
  string task;
  string group;
}
{OptTask} optTasks = { <t,g> | t in Tasks, g in mayperform[t] };

{string} Workers = ...;

{string} workers[Groups] = ...;

dvar interval tasks[t in Tasks] size durations[t];
dvar interval opttasks[optTasks] optional;
dvar interval worker[Workers];

cumulFunction group[g in Groups] = 
  sum (w in workers[g]) pulse(worker[w], 1) 
  - sum (<t,g> in optTasks) pulse(opttasks[<t,g>], 1);



execute {
  		cp.param.FailLimit = 5000;
}

minimize max(w in Workers) lengthOf(worker[w]);

subject to {
  forall(t in Tasks) /* starts of Tasks */
    startOf(tasks[t]) == start[t];
  
  forall(t in Tasks) 
    alternative(tasks[t], all(<t,g> in optTasks) opttasks[<t,g>]);
  
  forall(g in Groups) {
    0 <= group[g];
    group[g] <= maxUnusedWorkers[g];
  }
};

execute {
  for (var w in Workers) 
    writeln(w + " present from " + worker[w].start + " to " + worker[w].end);
}
