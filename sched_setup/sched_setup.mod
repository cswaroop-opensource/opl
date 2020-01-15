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

This example solves a scheduling problem on two alternative
heterogeneous machines. A set of tasks {a_1,...,a_n} has to be
executed on either one of the two machines. Different types of tasks
are distinguished, the type of task a_i is denoted tp_i.  

A machine m needs a sequence dependent setup time setup(tp,tp') to
switch from a task of type tp to the next task of type
tp'. Furthermore some transitions tp->tp' are forbidden.

The two machines are different: they process tasks with different
speed and have different setup times and forbidden transitions.

The objective is to minimize the makespan.

The model uses transition distances and noOverlap constraints to model
machines setup times. The noOverlap constraint is specified to enforce
transition distance between immediate successors on the
sequence. Forbidden transitions are modeled with a very large
transition distance.

------------------------------------------------------------ */

using CP;

int nbTypes = 5;
range Types = 0..nbTypes-1;

int nbMachines = 2;
range Machines = 0..nbMachines-1;

int setup[Machines][Types][Types] = [
 // Setups on machine 0; -1 means forbidden transition
 [ [ 0, 26,  8,  3, -1],
   [22,  0, -1,  4, 22],
   [28,  0,  0, 23,  9],
   [29, -1, -1,  0,  8],
   [26, 17, 11,  7,  0]
   ],
 // Setups on machine 1; -1 means forbidden transition
 [ [ 0,  5, 28, -1,  2],
   [-1,  0, -1,  7, 10],
   [19, 22,  0, 28, 17],
   [ 7, 26, 13,  0, -1],
   [13, 17, 26, 20,  0]
   ]
 ];

int nbTasks = 50;
range Tasks = 0..nbTasks-1;

int taskDur[Machines][Tasks] = [
 // Task duration if executed on machine 0
 [ 4, 17,  4,  7, 17, 14,  2, 14,  2,  8,
  11, 14,  4, 18,  3,  2,  9,  2,  9, 17,
  18, 19,  5,  8, 19, 12, 17, 11,  6,  3,
  13,  6, 19,  7,  1,  3, 13,  5,  3,  6,
  11, 16, 12, 14, 12, 17,  8,  8,  6,  6 ],
 // Task duration if executed on machine 1
 [12,  3, 12, 15,  4,  9, 14,  2,  5,  9,
  10, 14,  7,  1, 11,  3, 15, 19,  8,  2,
  18, 17, 19, 18, 15, 14,  6,  6,  1,  2,
   3, 19, 18,  2,  7, 16,  1, 18, 10, 14,
   2,  3, 14,  1,  1,  6, 19,  5, 17,  4 ]
];

int taskType[Tasks]= [
  3, 3, 1, 1, 1, 1, 2, 0, 0, 2,
  4, 4, 3, 3, 2, 3, 1, 4, 4, 2,
  2, 1, 4, 2, 2, 0, 3, 3, 2, 1,
  2, 1, 4, 3, 3, 0, 2, 0, 0, 3,
  2, 0, 3, 2, 2, 4, 1, 2, 4, 3
];

tuple triplet { int t1; int t2; int v; }
{triplet} tt[m in Machines] = 
  { <t1,t2,setup[m][t1][t2]> | t1,t2 in Types : 0<=setup[m][t1][t2]} union
  { <t1,t2,(maxint div 2)-1> | t1,t2 in Types : setup[m][t1][t2]<0 }; // Forbidden transitions

execute {
		cp.param.FailLimit = 100000;
	cp.param.LogPeriod = 10000;
}

dvar interval a[i in Tasks];
dvar interval alt[i in Tasks][m in Machines] optional size taskDur[m][i];
dvar sequence s[m in Machines] 
  in    all(i in Tasks) alt[i][m] 
  types all(i in Tasks) taskType[i];

minimize max(i in Tasks) endOf(a[i]);
subject to {
  forall (i in Tasks)
    alternative(a[i], all(m in Machines) alt[i][m]);
  forall (m in Machines)
    noOverlap(s[m],tt[m],1);
}

execute {
  for (var m in Machines) {
    writeln(s[m]);
  }
};
