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

/*
 * This version of the main Cutstock script
 * uses OplDataElements for data that are 
 * passed from one model to the other
 */
 
 
// Common width of the rolls to be cut.
int RollWidth = ...;
// Number of item types to be cut
int NbItems = ...;

range Items = 1..NbItems;
// Size of each of the items
int Size[Items] = ...;
// Number of items of each type to be cut
int Amount[Items] = ...;

// Patterns of roll cutting that are generated.
// Some simple default patterns are given initially in cutstock.dat
tuple pattern {
   key int id;
   int cost;
   int fill[Items];
}
{pattern} Patterns = ...;

// dual values used to fill in the sub model.
float Duals[Items] = ...;


// How many of each pattern is to be cut
dvar float Cut[Patterns] in 0..1000000;
     
// Minimize cost : here each pattern has the same constant cost so that
// we minimize the number of rolls used.     
minimize
  sum( p in Patterns ) 
    p.cost * Cut[p];

subject to {
  // Unique constraint in the master model is to cover the item demand.
  forall( i in Items ) 
    ctFill:
      sum( p in Patterns ) 
        p.fill[i] * Cut[p] >= Amount[i];
}
tuple r {
   pattern p;
   float cut;
};

{r} Result = {<p,Cut[p]> | p in Patterns : Cut[p] > 1e-3};
// set dual values used to fill in the sub model.
execute FillDuals {
  for(var i in Items) {
     Duals[i] = ctFill[i].dual;
  }
}

// Output the current result
execute DISPLAY_RESULT {
   writeln(Result);
}

main {
   var status = 0;
   thisOplModel.generate();
   // This is an epsilon value to check if reduced cost is strictly negative
   var RC_EPS = 1.0e-6;
   
   // Retrieving model definition, engine and data elements from this OPL model
   // to reuse them later
   var masterDef = thisOplModel.modelDefinition;
   var masterCplex = cplex;
   var masterData = thisOplModel.dataElements;   
   
   // Creating the master-model
   var masterOpl = new IloOplModel(masterDef, masterCplex);
   masterOpl.addDataSource(masterData);
   masterOpl.generate();
   
   // Preparing sub-model source, definition and engine
   var subSource = new IloOplModelSource("cutstock-sub.mod");
   var subDef = new IloOplModelDefinition(subSource);
   var subCplex = new IloCplex();
   
   var best;
   var curr = Infinity;

   while ( best != curr ) {
      best = curr;
      writeln("Solve master.");
      if ( masterCplex.solve() ) {
        masterOpl.postProcess();
        curr = masterCplex.getObjValue();
        writeln();
        writeln("MASTER OBJECTIVE: ",curr);
      } else {
         writeln("No solution to master problem!");
         masterOpl.end();
         break;
      }
      // Creating the sub model
      var subOpl = new IloOplModel(subDef,subCplex);
      
      // Using data elements from the master model.
      var subData = new IloOplDataElements();
      subData.RollWidth = masterOpl.RollWidth;
      subData.Size = masterOpl.Size;
      subData.Duals = masterOpl.Duals;     
      subOpl.addDataSource(subData); 
      subOpl.generate();
      
      // Previous master model is not needed any more.
      masterOpl.end();
      
      writeln("Solve sub.");
      if ( subCplex.solve() &&
           subCplex.getObjValue() <= -RC_EPS) {
        writeln();
        writeln("SUB OBJECTIVE: ",subCplex.getObjValue());
      } else {
        writeln("No new good pattern, stop.");
           subData.end();
        subOpl.end();         
        break;
      }
      // prepare next iteration
      masterData.Patterns.add(masterData.Patterns.size,1,subOpl.Use.solutionValue);
      masterOpl = new IloOplModel(masterDef,masterCplex);
      masterOpl.addDataSource(masterData);
      masterOpl.generate();
      // End sub model
         subData.end();
      subOpl.end();      
   }
    
   // Check solution value
   if (Math.abs(curr - 46.25)>=0.0001) {
      status = -1;
      writeln("Unexpected objective value");
   }         

   subDef.end();
   subCplex.end();
   subSource.end();
   
   status;
}
