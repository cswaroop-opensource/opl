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

There are three workers, and each task requires a worker.  There is
also a cash budget which starts with a given balance.  Each task costs
a given amount of cash per day which must be available at the start of
the task.  A cash payment is received periodically.  The objective is
to minimize the overall completion date.

------------------------------------------------------------ */

using CP;

int NbWorkers = ...;
int NbHouses  = ...; 
range Houses  = 1..NbHouses;

{string} TaskNames   = ...;

int Duration [t in TaskNames] = ...;

tuple Precedence {
   string pre;
   string post;
};

{Precedence} Precedences = ...;

int ReleaseDate[Houses] = ...; 

dvar interval itvs[h in Houses][t in TaskNames] in ReleaseDate[h]..(maxint div 2)-1 size Duration[t];

cumulFunction workersUsage = 
   sum(h in Houses, t in TaskNames) pulse(itvs[h][t],1);

cumulFunction cash = 
  sum (p in 0..5) step(60*p, 30000)
  - sum(h in Houses, t in TaskNames) stepAtStart(itvs[h][t], 200*Duration[t]);

execute {
	cp.param.FailLimit = 10000;
}

minimize max(h in Houses) endOf(itvs[h]["moving"]);

subject to {
  forall(h in Houses)
    forall(p in Precedences)
      endBeforeStart(itvs[h][p.pre], itvs[h][p.post]);

  workersUsage <= NbWorkers;

  cash >= 0;
}

execute display_workersUsage
{
 writeln("number of Segments of workersUsage = ",workersUsage.getNumberOfSegments());
 for(var i=0;i<workersUsage.getNumberOfSegments();i++)
 {
   write(workersUsage.getSegmentStart(i)," -> ",workersUsage.getSegmentEnd(i));
   writeln(" : ",workersUsage.getSegmentValue(i)); 
 }   
}  

