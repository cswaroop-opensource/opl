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
dvar int+ x[r] in 1..10;
// Preferences are stated as data of the opl model.
// prefs[i] will be used to represent the preference of seeing cts[i] in the conflict.
float prefs[i in r] = i;

minimize sum(i in r) x[i];
subject to {
   ct: sum(i in r) x[i] >= 10;
   forall(i in r) 
     cts: x[i] >= i+5;
} 
main {
   thisOplModel.generate();
   var def = thisOplModel.modelDefinition;   
   // Default behavior
   writeln("Default Behavior");
   var opl1 = new IloOplModel(def, cplex);
   opl1.generate();
   writeln(opl1.printConflict()); 
   
  // now iterating manually
   writeln("now iterating manually");
   writeln();
   var iter = opl1.conflictIterator;  

      for(var c in iter)
      {
       var ct=c.ct;
       writeln(ct.name, " with status ", c.status);
      }  
opl1.end();
writeln();
   // With user-defined preferences
   writeln("With user-defined preferences");   
   var opl2 = new IloOplModel(def, cplex);
   opl2.generate();
   // We attach prefs (defined as data in the opl model) as preferences 
   // for constraints cts for the conflict refinement.
   opl2.conflictIterator.attach(opl2.cts, opl2.prefs);
   writeln(opl2.printConflict());        
   opl2.end();
}

