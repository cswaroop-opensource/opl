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

/***********************************************************
*
* This model is described in the documentation. 
* See IDE and OPL > Language and Interfaces Examples.
*
* This model is greater than the size allowed in trial mode. 
* You therefore need a commercial edition of CPLEX Studio to 
* run this example. 
* If you are a student or teacher, you can also get a full version 
* through the IBM Academic Initiative.
************************************************************/

/** This sample uses only 1 Worker because enumeration of solutions is faster using single worker with depth-first search. **/

include "common.mod";

tuple p
{
   int v[1..nbRounds];
}

{p} patterns;

tuple ps
{
   int v[0..nbTeams];
}

{ps} patset;


main
{
  writeln("* Note: This OPL model is not compliant with cloud execution");

 var rc1 = new IloOplRunConfiguration(
    "pattern.mod","pattern.dat");
 rc1.oplModel.generate();
 rc1.cp.startNewSearch();

 while (rc1.cp.next()) { 
     thisOplModel.patterns.add(rc1.oplModel.pattern.solutionValue);
     
 }
 
   var f = new IloOplOutputFile();
   f.open("patset0.dat");
   f.writeln("patterns=");
   f.writeln(thisOplModel.patterns);
   f.writeln(";");
   f.close();
   


 writeln("patterns");
 writeln(thisOplModel.patterns);
 writeln("found ",thisOplModel.patterns.size," patterns");
 
 var rc2 = new IloOplRunConfiguration(
    "patset.mod","patset0.dat");
   
   for(var i in thisOplModel.patterns) 
   rc2.oplModel.dataElements.patterns.add(i); 
   
  
  rc2.oplModel.generate();
   rc2.cp.startNewSearch();
   while (rc2.cp.next()) { 
    thisOplModel.patset.add(rc2.oplModel.patset.solutionValue);  
   }
   //writeln("patset");
   //writeln(thisOplModel.patset);
   writeln("found ",thisOplModel.patset.size," pattern sets");
   
   f = new IloOplOutputFile();
   f.open("acc0.dat");
   f.writeln("patset=");
   f.writeln(thisOplModel.patset);
   f.writeln(";");
   f.close();
  

var rc3 = new IloOplRunConfiguration(
    "acc.mod","acc0.dat","weekend.dat","weekday.dat",
    "pattern.dat","patset0.dat");
    
   for(var j in thisOplModel.patterns) 
   rc3.oplModel.dataElements.patterns.add(j); 
   for(var k in thisOplModel.patset) 
   rc3.oplModel.dataElements.patset.add(k); 
 
  rc3.oplModel.generate();
  if (rc3.cp.solve()){
  	writeln("obj is ",rc3.cp.getObjValue());
  	rc3.oplModel.postProcess();
  }
  else{
  	writeln("No solution");
  }


}





