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
  int     smin;
  int     emax;
  int     dmds[RsrcIds];
  {int}   succs; 
}

{Task} Tasks = ...;

tuple Precedence {
  int beforeId;
  int afterId;
}

{Precedence} Precedences = { <t.id, j> | t in Tasks, j in t.succs };
  
dvar interval itvs[t in Tasks] size t.pt;

cumulFunction rsrcUsage[r in RsrcIds] = 
  sum (t in Tasks: t.dmds[r]>0) pulse(itvs[t], t.dmds[r]);

execute {
  cp.param.FailLimit = 10000;
  cp.param.CumulFunctionInferenceLevel = "Extended";
}

// Constraint arrays
constraint minstart  [t in Tasks]; 
constraint maxend    [t in Tasks];
constraint resource  [r in RsrcIds];
constraint precedence[p in Precedences];

// Arrays below will be used to represent the preference 
// of seeing the corresponding constraint in the conflict.
float minstartPref   [t in Tasks]       = 2.0;
float maxendPref     [t in Tasks]       = 2.0;
float resourcePref   [r in RsrcIds]     = 1.0;
float precedencePref [p in Precedences] = 3.0;

minimize max(t in Tasks) endOf(itvs[t]);
subject to {
  forall (t in Tasks) {
    minstart[t] : t.smin <= startOf(itvs[t]);
    maxend[t]   : endOf(itvs[t]) <= t.emax;
  }
  forall (r in RsrcIds) {
    resource[r] : rsrcUsage[r] <= Capacity[r];
  }
  forall (p in Precedences) {
    precedence[p] : endBeforeStart(itvs[<p.beforeId>], itvs[<p.afterId>]);
  }
}

execute {
  for (var t in Tasks) {
    writeln("Task " + t.id + " starts at " + itvs[t].start);
  }
}

main {
  thisOplModel.generate();
  var def  = thisOplModel.modelDefinition; 
  var data = thisOplModel.dataElements;
  
  var opl1 = new IloOplModel(def, cp);
  opl1.addDataSource(data);
  opl1.generate();

  // 1. Default behavior
  writeln("Default Behavior");
  writeln(opl1.printConflict()); 
   
  // 2. Iterating manually
  writeln("Iterating manually");
  var iter = opl1.conflictIterator;  
  for(var c in iter) {
    var ct=c.ct;  
    writeln(ct.name);
	writeln("info = ",c.info);
  }  
  writeln();
  opl1.end();
}
