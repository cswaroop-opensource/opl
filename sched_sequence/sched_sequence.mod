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

This is a problem of building five houses in different locations. The
masonry, roofing, painting, etc. must be scheduled. Some tasks must
necessarily take place before others and these requirements are
expressed through precedence constraints.

There are two workers, and each task requires a specific worker.  The
time required for the workers to travel between houses must be taken
into account.  

Moreover, there are tardiness costs associated with some tasks as well
as a cost associated with the length of time it takes to build each
house.  The objective is to minimize these costs.

------------------------------------------------------------ */

using CP;

int NbHouses = ...; 
range Houses = 1..NbHouses;

{string} WorkerNames = ...;  
{string} TaskNames   = ...;

int    Duration [t in TaskNames] = ...;
string Worker   [t in TaskNames] = ...;

tuple Precedence {
   string pre;
   string post;
};

{Precedence} Precedences = ...;

int   ReleaseDate[Houses] = ...; 
int   DueDate    [Houses] = ...; 
float Weight     [Houses] = ...; 

dvar interval houses[h in Houses] in ReleaseDate[h]..(maxint div 2)-1;
dvar interval itvs  [h in Houses][t in TaskNames] size Duration[t];

dvar sequence workers[w in WorkerNames] in
    all(h in Houses, t in TaskNames: Worker[t]==w) itvs[h][t] types
    all(h in Houses, t in TaskNames: Worker[t]==w) h;

tuple triplet { int loc1; int loc2; int value; }; 
{triplet} transitionTimes = { <i,j, ftoi(abs(i-j))> | i in Houses, j in Houses };

execute {
  cp.param.FailLimit = 30000;
}

execute{
		cp.param.timeLimit=60;
}

minimize sum(h in Houses) 
  (Weight[h] * maxl(0, endOf(houses[h])-DueDate[h]) + lengthOf(houses[h]));
subject to {
  forall(h in Houses)
    forall(p in Precedences)
      endBeforeStart(itvs[h][p.pre], itvs[h][p.post]);
  forall(h in Houses)
    span(houses[h], all(t in TaskNames) itvs[h][t]);
  forall(w in WorkerNames)
    noOverlap(workers[w], transitionTimes);
}

/*
OBJECTIVE: 13852
*/
