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

range Jobs = 0..nbJobs-1;
range Mchs = 0..nbMchs-1; 

int OpDurations[j in Jobs][m in Mchs] = ...;

dvar interval itvs[j in Jobs][m in Mchs]  size OpDurations[j][m];
dvar sequence mchs[m in Mchs] in all(j in Jobs) itvs[j][m];
dvar sequence jobs[j in Jobs] in all(m in Mchs) itvs[j][m];

execute {
		cp.param.FailLimit = 10000;
}

minimize max(j in Jobs, m in Mchs) endOf(itvs[j][m]);
subject to {
  forall (j in Jobs)
    noOverlap(jobs[j]);
  forall (m in Mchs)
    noOverlap(mchs[m]);
}

execute {
  for (var j = 0; j <= nbJobs-1; j++) {
    for (var m = 0; m <= nbMchs-1; m++) {
      write(itvs[j][m].start + " ");
    }
    writeln("");
  }
}
