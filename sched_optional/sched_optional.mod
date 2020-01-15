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

/* ------------------------------------------------------------

Problem Description
-------------------

This is a problem of building five houses. The masonry, roofing,
painting, etc. must be scheduled. Some tasks must necessarily take
place before others and these requirements are expressed through
precedence constraints.

There are three workers, and each worker has a given non-negative
skill level for each task.  Each task requires one worker that will
have to be selected among the ones who have a non null skill level for
that task.  A worker can be assigned to only one task at a time.  Each
house has a deadline. The objective is to maximize the skill levels of
the workers assigned to the tasks while respecting the deadlines.

------------------------------------------------------------ */

using CP;
int NbHouses = ...;
range Houses = 1..NbHouses;

int Deadline = ...;

{string} Workers = ...;

{string} Tasks = ...;

int Durations[Tasks] = ...;

tuple Skill {
  string worker;
  string task;
  int    level;  
};
{Skill} Skills = ...;

tuple Precedence {
  string pre;
  string post;
};
{Precedence} Precedences = ...;

tuple Continuity {
  string worker;
  string task1;  
  string task2;
};
{Continuity} Continuities = ...;

dvar interval tasks [h in Houses][t in Tasks] in 0..Deadline size Durations[t];
dvar interval wtasks[h in Houses][s in Skills] optional;

execute {
		cp.param.FailLimit = 10000;
}

maximize sum(h in Houses, s in Skills) s.level * presenceOf(wtasks[h][s]);
subject to {
  forall(h in Houses) {
    // Temporal constraints
    forall(p in Precedences)
      endBeforeStart(tasks[h][p.pre], tasks[h][p.post]);  
    // Alternative workers  
    forall(t in Tasks)
      alternative(tasks[h][t], all(s in Skills: s.task==t) wtasks[h][s]);   
    // Continuity constraints
    forall(c in Continuities,
           <c.worker, c.task1, l1> in Skills, 
           <c.worker, c.task2, l2> in Skills)
      presenceOf(wtasks[h,<c.worker, c.task1, l1>]) == 
      presenceOf(wtasks[h,<c.worker, c.task2, l2>]);
  }
  // No overlap constraints
  forall(w in Workers)
    noOverlap(all(h in Houses, s in Skills: s.worker==w) wtasks[h][s]);
};
