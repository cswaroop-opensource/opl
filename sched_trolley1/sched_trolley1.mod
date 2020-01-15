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

execute{
	}

int loadDuration = 20;

dvar interval act[Jobs][Tasks];

stateFunction trolleyPosition;

minimize max(j in Jobs) endOf(act[j]["unloadS"]);
subject to {
  // durations 
  forall(j in Jobs) {
    lengthOf(act[j]["loadA"])    == loadDuration;
    lengthOf(act[j]["unload1"])  == loadDuration;
    lengthOf(act[j]["process1"]) == job[j].durations1;
    lengthOf(act[j]["load1"])    == loadDuration;
    lengthOf(act[j]["unload2"])  == loadDuration;
    lengthOf(act[j]["process2"]) == job[j].durations2;
    lengthOf(act[j]["load2"])    == loadDuration;
    lengthOf(act[j]["unloadS"])  == loadDuration;
  };
  
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
   forall(j in Jobs) {
     alwaysEqual(trolleyPosition, act[j]["loadA"],   Index["areaA"]);
     alwaysEqual(trolleyPosition, act[j]["unload1"], Index[job[j].machine1]);
     alwaysEqual(trolleyPosition, act[j]["load1"],   Index[job[j].machine1]);
     alwaysEqual(trolleyPosition, act[j]["unload2"], Index[job[j].machine2]);
     alwaysEqual(trolleyPosition, act[j]["load2"],   Index[job[j].machine2]);
     alwaysEqual(trolleyPosition, act[j]["unloadS"], Index["areaS"]);
   };
}; 

