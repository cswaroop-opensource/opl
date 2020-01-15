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

range r = 1..10;
dvar int+ x[r];
dvar int+ y[r];
// The following array of values (defined as data) will be used as 
// a starting solution to warm-start the CPLEX search.
float values[i in r] = (i==5)? 10 : 0;


minimize 
  sum( i in r ) x[i] + sum( j in r ) y[j];
subject to{
  ctSum:    
    sum( i in r ) x[i] >= 10;
  forall( j in r )
    ctEqual:
      y[j] == j;
}

main{
  thisOplModel.generate();  
  var def = thisOplModel.modelDefinition;   
  // Default behaviour
  writeln("Default Behaviour");
  var cplex1 = new IloCplex();
  var opl1 = new IloOplModel(def, cplex1);
  opl1.generate();
  cplex1.solve();   
  writeln(opl1.printSolution());
  // Setting initial solution
  writeln("Setting initial solution");
  var cplex2 = new IloCplex();
  var opl2 = new IloOplModel(def, cplex2);
  opl2.generate();
  var vectors = new IloOplCplexVectors();
  // We attach the values (defined as data) as starting solution
  // for the variables x.
  vectors.attach(opl2.x,opl2.values);
  vectors.setStart(cplex2);   
  cplex2.solve();   
  writeln(opl2.printSolution());

  opl1.end();
  cplex1.end();
  opl2.end();
  cplex2.end();
  0;
}
