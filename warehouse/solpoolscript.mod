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

// the main script solves the warehouse location model
// and displays the solution pools that were populated
include "scalableWarehouse.mod";

main {
    thisOplModel.generate();
    cplex.solve();
    if (cplex.populate()) {
      var nsolns = cplex.solnPoolNsolns;
      writeln("Number of solutions found = ",nsolns);
      writeln();
      for (var s=0; s<nsolns; s++) {
        thisOplModel.setPoolSolution(s);
        writeln("solution #", s, ": objective = ", cplex.getObjValue(s));
        write("Open = [ ");
        for (var i in thisOplModel.Warehouses)
          write(thisOplModel.Open[i], " ");
        writeln("]");  
        writeln("---------");
      }
    }
}
