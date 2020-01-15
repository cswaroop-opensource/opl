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

// This example illustrates how to execute several examples consecutively
// The models can be solved by either CPLEX or CPO and include scripting or not

execute {
  function ProjectInfo(dirName, prjName, runConfigName, expRes) {
    this.dir = dirName;
    this.name = prjName;
    this.runConfig = runConfigName;
    this.result = expRes;
  }
  function AddProject(projects, dir, name, runConfig, res) {
    projects[projects.length] = new ProjectInfo(dir, name, runConfig, res);
  }
  function isNearEqual(result, expectedResult) {
    var tolerance = 0.000001;
   return Math.abs(expectedResult-result)<tolerance;
  }
}

main {
  // activate end() method in the IDE
  thisOplModel.settings.mainEndEnabled = true;
  
  writeln("Executing some of the distributed examples thru projects ...");
  writeln();
  writeln();
   
  var path = "";
  var OK = true;

  var projects = new Array();
  var projectCurr = 0;

  AddProject(projects, "../blending", "", "", 653.61);
  AddProject(projects, "../cutstock", "", "Full integer problem using column generation", 0);
  AddProject(projects, "../timetabling", "", "Small data", 20);
  AddProject(projects, "../sched_bridge", "", "", null);

  while (projectCurr < projects.length ) {
    var withData = true;
    var projectDir = projects[projectCurr].dir;
    var projectName = projects[projectCurr].name;
    var runConfigName = projects[projectCurr].runConfig;
    var expectedResult = projects[projectCurr].result;
    projectName = path + projectDir;
    
    var allName=projectName;
    writeln("---------------");
    writeln("solving: ", projectName);
    var project = new IloOplProject(projectName);
    var rc;
    write("run configuration: ");
    if (runConfigName != "") {
       rc=project.makeRunConfiguration(runConfigName);
       writeln(runConfigName);
    }
    else { //default run configuration
       rc=project.makeRunConfiguration();  
       writeln("default");
    }
       
    var result;
    if (rc.oplModel.modelDefinition.hasMain()) {
      result = rc.oplModel.main();
      if (result != expectedResult) {
        OK = false;
        writeln(allName, " is NOT OK");
        break;
      } else {
        writeln(allName, " is OK");
      }
    } 
    else {
      rc.oplModel.generate();
    
      var algo;      
      if (rc.oplModel.modelDefinition.isUsingCplex())
      {
        algo = rc.cplex;  
      }  
      if (rc.oplModel.modelDefinition.isUsingCP())
      {
        algo = rc.cp;       
      }
      if ( algo.solve() ) {
        result = algo.getObjValue();
        if (expectedResult != null) {
          if (isNearEqual(result,expectedResult)) {
            writeln(allName, " is OK");
            rc.oplModel.postProcess();
          } else {
            writeln("Fail to solve: ", allName);
            writeln("\tExpected result: ", expectedResult, " found result: ", result);
            OK = false;
            break;
          }
        }
      } else {
        writeln("Fail to solve: ", allName);
        writeln("\tNo solution found!");
        OK = false;
        break;
      }
    }
    rc.end();
    project.end();
    projectCurr = projectCurr + 1;
  }
  writeln("---------------");
  writeln();
  if (OK) {
    writeln("All projects have been solved.");
  } else {
    writeln("Not all projects have been solved as expected.");
  }
  writeln();
  
  (OK)?0:1;
}



