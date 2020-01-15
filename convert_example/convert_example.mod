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

dvar int x in 0..10;


minimize x;
subject to {
  ct :   
    x >= 1/2;
}

main {
  var status = 0;
  thisOplModel.generate();
  if (cplex.solve()) {
    writeln("Integer Model");   
    writeln("OBJECTIVE: ",cplex.getObjValue());   
    if (cplex.getObjValue() != 1) {
      status = -1;
    }
  } 

  thisOplModel.convertAllIntVars();
  if (cplex.solve()) {
    writeln("Relaxed Model");   
    writeln("OBJECTIVE: ",cplex.getObjValue());  
    if (cplex.getObjValue() != 0.5) {
      status = -1;
    }
  } 
   
  thisOplModel.unconvertAllIntVars();
  if (cplex.solve()) {
    writeln("Unrelaxed Model");   
    writeln("OBJECTIVE: ",cplex.getObjValue());
    if (cplex.getObjValue() != 1) {
      status = -1;
    }
  } 
  status;
}

