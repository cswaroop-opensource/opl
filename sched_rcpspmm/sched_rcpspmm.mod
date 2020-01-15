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
int NbRenewableRsrcs    = ...;
int NbNonRenewableRsrcs = ...;

range RenewableRsrcIds    = 0..NbRenewableRsrcs-1; 
range NonRenewableRsrcIds = 0..NbNonRenewableRsrcs-1; 

int CapRenewableRsrc    [RenewableRsrcIds] = ...;
int CapNonRenewableRsrc [NonRenewableRsrcIds] = ...;

tuple Task {
  key int id;
  {int}   succs; 
}
{Task} Tasks = ...;

tuple Mode {
  key int taskId;
  key int id;
  int pt;
  int dmdRenewable   [RenewableRsrcIds];
  int dmdNonRenewable[NonRenewableRsrcIds];
}
{Mode} Modes = ...;

dvar interval task[t in Tasks];
dvar interval mode[m in Modes] optional  size m.pt;

cumulFunction renewableRsrcUsage[r in RenewableRsrcIds] = 
  sum (m in Modes: m.dmdRenewable[r]>0) pulse(mode[m], m.dmdRenewable[r]);

dexpr int nonRenewableRsrcUsage[r in NonRenewableRsrcIds] = 
  sum (m in Modes: m.dmdNonRenewable[r]>0) m.dmdNonRenewable[r] * presenceOf(mode[m]);

execute {
		cp.param.FailLimit = 10000;
}

minimize max(t in Tasks) endOf(task[t]);
subject to {
  forall (t in Tasks) 
    alternative(task[t], all(m in Modes: m.taskId==t.id) mode[m]);
  forall (r in RenewableRsrcIds)
    renewableRsrcUsage[r] <= CapRenewableRsrc[r];
  forall (r in NonRenewableRsrcIds)
    nonRenewableRsrcUsage[r] <= CapNonRenewableRsrc[r];    
  forall (t1 in Tasks, t2id in t1.succs)
    endBeforeStart(task[t1], task[<t2id>]);
}

execute {
  for (var m in Modes) {
    if (mode[m].present)
      writeln("Task " + m.taskId + " with mode " + m.id + " starting at " + mode[m].start);
  }
}
