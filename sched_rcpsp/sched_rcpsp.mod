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

int NbTasks = ...;
int NbRsrcs = ...;

range RsrcIds = 0..NbRsrcs-1; 

int Capacity[r in RsrcIds] = ...;

tuple Task {
  key int id;
  int     pt;
  int     dmds[RsrcIds];
  {int}   succs; 
}

{Task} Tasks = ...;

dvar interval itvs[t in Tasks]  size t.pt;

cumulFunction rsrcUsage[r in RsrcIds] = 
  sum (t in Tasks: t.dmds[r]>0) pulse(itvs[t], t.dmds[r]);

execute {
		cp.param.FailLimit = 10000;
}

minimize max(t in Tasks) endOf(itvs[t]);
subject to {
  forall (r in RsrcIds)
    rsrcUsage[r] <= Capacity[r];
  forall (t1 in Tasks, t2id in t1.succs)
    endBeforeStart(itvs[t1], itvs[<t2id>]);
}

execute {
  for (var t in Tasks) {
    writeln("Task " + t.id + " starts at " + itvs[t].start);
  }
}
