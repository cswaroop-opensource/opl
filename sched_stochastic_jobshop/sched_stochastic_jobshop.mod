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

int nbJobs = ...;
int nbMchs = ...;
int nbScns = ...;

range Jobs = 0..nbJobs-1;
range Mchs = 0..nbMchs-1; 
range Scns = 0..nbScns-1;

// Mchs is used both to index machines and operation position in job

int Machines[j in Jobs][m in Mchs] = ...;
int Durations[k in Scns][j in Jobs][m in Mchs] = ...;

dvar interval itvs[k in Scns][j in Jobs][o in Mchs] size Durations[k][j][o];
dvar sequence mchs[k in Scns][m in Mchs] in all(j in Jobs, o in Mchs : Machines[j][o] == m) itvs[k][j][o];

execute {
  cp.param.FailLimit = 250000;
  cp.param.LogPeriod = 1000000;
}

minimize sum(k in Scns) (max(j in Jobs) endOf(itvs[k][j][nbMchs-1])) / nbScns;
subject to {
  forall(k in Scns) {
	forall (m in Mchs) {
	  noOverlap(mchs[k][m]);
	  if (0<k) {
	    sameSequence(mchs[0][m], mchs[k][m]);
     }	    
   }	  
  forall (j in Jobs, o in 0..nbMchs-2)
    endBeforeStart(itvs[k][j][o], itvs[k][j][o+1]);
  }	    
}

execute {
  for (var m in Machines) {
    writeln(mchs[0][m]);
  }  
}
