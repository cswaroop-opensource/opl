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

The problem is to schedule a set of tasks on two alternative
machines with different setup times.

The objective is to minimize the number of "long" setup times on
machines. A setup time is considered to be long if it is larger than
30.

------------------------------------------------------------ */

using CP;

int nbTypes = 10;
range Types = 0..nbTypes-1;

int nbMachines = 2;
range Machines = 0..nbMachines-1;

int setup[Machines][Types][Types] = [
 // Setups on machine 0
 [ [22, 24,  7, 10, 9,  41, 14, 30, 24,  6],
   [63, 21, 42,  1, 24, 17, 35, 25,  0, 68],
   [60, 70, 37, 70, 39, 84, 44, 60, 67, 36],
   [77, 57, 65, 33, 81, 74, 72, 82, 57, 83],
   [51, 31, 18, 32, 48, 45, 51, 21, 28, 45],
   [46, 42, 29, 11, 11, 21, 59,  8,  4, 51],
   [35, 59, 42, 45, 44, 76, 37, 65, 59, 41],
   [38, 62, 45, 14, 33, 24, 52, 32,  7, 44],
   [63, 57, 44,  7, 26, 17, 55, 25, 21, 68],
   [24, 34,  1, 34,  3, 48,  8, 24, 31, 30]
   ],
 // Setups on machine 1
 [ [27, 48, 44, 52, 21, 61, 33,  5, 37, 64],
   [42, 44, 42, 40, 17, 40, 49, 41, 66, 29],
   [36, 53, 31, 56, 50, 56,  7, 41, 49, 60],
   [6,  43, 46, 38, 16, 44, 39, 11, 43, 12],
   [25, 27, 45, 67, 37, 67, 52, 30, 62, 56],
   [6,  43,  2,  0, 16, 35,  9, 11, 43, 12],
   [29, 70, 25, 62, 43, 62, 26, 34, 42, 61],
   [22, 43, 53, 47, 16, 56, 28, 10, 32, 59],
   [56, 93, 73, 76, 66, 82, 48, 61, 51, 50],
   [18, 55, 34, 26, 28, 32, 40, 12, 44, 25]
   ]
 ];

int nbTasks = 50;
range Tasks = 0..nbTasks-1;

int taskDur[Tasks] = [
  19, 18, 16, 11, 16, 15, 19, 18, 17, 17, 
  20, 16, 16, 14, 19, 11, 10, 16, 12, 20, 
  14, 14, 20, 12, 18, 16, 10, 15, 11, 13,
  15, 11, 11, 13, 19, 17, 11, 20, 19, 17,
  15, 19, 13, 16, 20, 13, 13, 13, 13, 15
];

int taskType[Tasks]= [
  8,  1,  6,  3,  4,  8,  8,  4,  3,  5, 
  9,  4,  1,  5,  8,  8,  4,  1,  9,  2,
  6,  0,  8,  9,  1,  0,  1,  7,  5,  9,
  3,  1,  9,  3,  0,  7,  0,  7,  1,  4, 
  5,  7,  4,  0,  9,  1,  5,  4,  5,  1
];

range NextTypes = 0..nbTypes; // Includes nbTypes as escape value

int isLongSetup[m in Machines][t1 in Types][t2 in NextTypes] = 
  ((t2<nbTypes) && (30<=setup[m][t1][t2]))?1:0;

tuple triplet { int t1; int t2; int v; }
{triplet} tt[m in Machines] = { <t1,t2,setup[m][t1][t2]> | t1,t2 in Types };

execute {
		cp.param.FailLimit = 100000;
	cp.param.LogPeriod = 10000;	
}

dvar interval a[i in Tasks] size taskDur[i];
dvar interval alt[Tasks][Machines] optional;
dvar sequence s[m in Machines] 
  in    all(i in Tasks) alt[i][m] 
  types all(i in Tasks) taskType[i];

dexpr int nbLongs = sum(m in Machines, i in Tasks)
   isLongSetup[m][taskType[i]][typeOfNext(s[m],alt[i][m],nbTypes,nbTypes)];

minimize nbLongs;
subject to {
  forall (i in Tasks)
    alternative(a[i], all(m in Machines) alt[i][m]);
  forall (m in Machines)
    noOverlap(s[m],tt[m],1);
}

execute {
  for (var m in Machines)
    writeln(s[m]);
  writeln("Number of long transition times: ", nbLongs);
};
