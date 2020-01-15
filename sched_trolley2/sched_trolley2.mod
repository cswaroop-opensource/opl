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

{string} Jobs   = {"j1","j2","j3","j4","j5","j6"};
{string} Tasks  = {"loadA","unload1","process1","load1","unload2","process2","load2","unloadS"};

{string} Machines = {"m1","m2","m3"};
{string} States = Machines union {"areaA","areaS"};

int Index[s in States] = ord(States, s);

tuple jobRecord {
  string machine1;
  int    durations1;
  string machine2;
  int    durations2;
};
jobRecord job[Jobs] = [
   <"m1", 80, "m2", 60>,
   <"m2",120, "m3", 80>,
   <"m2", 80, "m1", 60>,
   <"m1",160, "m3",100>,
   <"m3",180, "m2", 80>,
   <"m2",140, "m3", 60>
];

int loadDuration = 20;

int state[Jobs,Tasks];
execute {
   for(var j in Jobs) {
      state[j]["loadA"]    = Index["areaA"];
      state[j]["unload1"]  = Index[job[j].machine1];
      state[j]["process1"] = Index[job[j].machine1];
      state[j]["load1"]    = Index[job[j].machine1];
      state[j]["unload2"]  = Index[job[j].machine2];
      state[j]["process2"] = Index[job[j].machine2];
      state[j]["load2"]    = Index[job[j].machine2];
      state[j]["unloadS"]  = Index["areaS"];
   };
};

int duration[Jobs,Tasks];
execute {
   for(var j in Jobs) {
      duration[j]["loadA"]    = loadDuration;
      duration[j]["unload1"]  = loadDuration;
      duration[j]["process1"] = job[j].durations1;
      duration[j]["load1"]    = loadDuration;
      duration[j]["unload2"]  = loadDuration;
      duration[j]["process2"] = job[j].durations2;
      duration[j]["load2"]    = loadDuration;
      duration[j]["unloadS"]  = loadDuration;
   }
};

tuple triplet { int loc1; int loc2; int value; }; 
{triplet} m = { 
  <Index["m1"],    Index["m1"],      0>,
  <Index["m1"],    Index["m2"],     50>,
  <Index["m1"],    Index["m3"],     60>,
  <Index["m1"],    Index["areaA"],  50>,
  <Index["m1"],    Index["areaS"],  90>,
  <Index["m2"],    Index["m1"],     50>,
  <Index["m2"],    Index["m2"],      0>,
  <Index["m2"],    Index["m3"],     60>,
  <Index["m2"],    Index["areaA"],  90>,
  <Index["m2"],    Index["areaS"],  50>,
  <Index["m3"],    Index["m1"],     60>,
  <Index["m3"],    Index["m2"],     60>,
  <Index["m3"],    Index["m3"],      0>,
  <Index["m3"],    Index["areaA"],  80>,
  <Index["m3"],    Index["areaS"],  80>,
  <Index["areaA"], Index["m1"],     50>,
  <Index["areaA"], Index["m2"],     90>,
  <Index["areaA"], Index["m3"],     80>,
  <Index["areaA"], Index["areaA"],   0>,
  <Index["areaA"], Index["areaS"], 120>,
  <Index["areaS"], Index["m1"],     90>,
  <Index["areaS"], Index["m2"],     50>,
  <Index["areaS"], Index["m3"],     80>,
  <Index["areaS"], Index["areaA"], 120>,
  <Index["areaS"], Index["areaS"],   0>
};

stateFunction trolleyPosition with m;

dvar interval act[i in Jobs][j in Tasks] size duration[i][j];

execute {
		cp.param.FailLimit = 10000;
}

minimize max(j in Jobs) endOf(act[j]["unloadS"]);
subject to {
  // precedence
  forall(j in Jobs)
    forall(ordered t1, t2 in Tasks)
      endBeforeStart(act[j][t1], act[j][t2]);

  // no-overlap on machines
  forall (m in Machines) {
    noOverlap( append(
		      all(j in Jobs: job[j].machine1==m) act[j]["process1"],
		      all(j in Jobs: job[j].machine2==m) act[j]["process2"])
	       );
  }

   // state constraints
   forall(j in Jobs, t in Tasks : t != "process1" && t != "process2")
     alwaysEqual(trolleyPosition, act[j][t], state[j][t]);
}; 





