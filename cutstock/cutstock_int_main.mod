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

int RollWidth = ...;
int NbItems = ...;

range Items = 1..NbItems;
int Size[Items] = ...;
int Amount[Items] = ...;

// Output dual values used to fill in the sub model.
float Duals[Items] = ...;

tuple  pattern {
   key int id;
   int cost;
   int fill[Items];
}

{pattern} Patterns = ...;

dvar int Cut[Patterns] in 0..1000000;

minimize
  sum( p in Patterns ) 
    p.cost * Cut[p];
subject to {
  forall( i in Items ) 
   ctFill:
     sum( p in Patterns ) 
       p.fill[i] * Cut[p] >= Amount[i];
}
 
// dual values used to fill in the sub model.
execute FillDuals {
  for(var i in Items) {
     Duals[i] = ctFill[i].dual;
  }
}    

main {
  var status = 0;
  thisOplModel.generate();

  var RC_EPS = 1.0e-6;

  var masterDef = thisOplModel.modelDefinition;
  var masterCplex = cplex;
  var masterData = thisOplModel.dataElements;
   
  var subSource = new IloOplModelSource("cutstock-sub.mod");
  var subDef = new IloOplModelDefinition(subSource);
  var subData = new IloOplDataElements();
  var subCplex = new IloCplex();

  var best;
  var curr = Infinity;

  while ( best != curr ) {
    best = curr;

    var masterOpl = new IloOplModel(masterDef, masterCplex);
    masterOpl.addDataSource(masterData);
    masterOpl.generate();
    masterOpl.convertAllIntVars();
        
    writeln("Solve master.");
    if ( masterCplex.solve() ) {
      curr = masterCplex.getObjValue();
      writeln();
      writeln("OBJECTIVE: ",curr);
    } 
    else {
      writeln("No solution!");
      masterOpl.end();
      break;
    }

    subData.RollWidth = masterOpl.RollWidth;
    subData.Size = masterOpl.Size;
    subData.Duals = masterOpl.Duals;
    for(var i in masterOpl.Items) {
      subData.Duals[i] = masterOpl.ctFill[i].dual;
    }

    var subOpl = new IloOplModel(subDef, subCplex);
    subOpl.addDataSource(subData);
    subOpl.generate();

    writeln("Solve sub.");
    if ( subCplex.solve() ) {
      writeln();
      writeln("OBJECTIVE: ",subCplex.getObjValue());
    }
    else {
      writeln("No solution!");
      subOpl.end();
      masterOpl.end();
      break;
    }

    if (subCplex.getObjValue() > -RC_EPS) { 
      subOpl.end();
      masterOpl.end();
      break;
    }

        
    // Prepare the next iteration:
    masterData.Patterns.add(masterData.Patterns.size,1,subOpl.Use.solutionValue);

    subOpl.end();
    masterOpl.end();
  }
  writeln("Relaxed model search end.");

  masterOpl = new IloOplModel(masterDef,masterCplex);
  masterOpl.addDataSource(masterData);
  masterOpl.generate();   

  writeln("Solve integer master.");  
  if ( masterCplex.solve() ) {
    writeln();
    writeln("OBJECTIVE: ",masterCplex.getObjValue());
    if (Math.abs(masterCplex.getObjValue() - 47)>=0.0001) {
      status = -1;
      writeln("Unexpected objective value");
    }
    for(i in  masterData.Patterns) {
      if (masterOpl.Cut[i].solutionValue > 0) {
        writeln("Pattern : ", i, " used ", masterOpl.Cut[i].solutionValue << " times");
      }
    }
  }
  masterOpl.end();
  status;
}
