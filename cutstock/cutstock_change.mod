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


range Items = 1..5;
range Patterns = 1..5;

int Size[Items] = ...;
int Amount[Items] = ...;


int Fill[Patterns][Items] = ...;
int Cost[Patterns] = ...;

// used in column generation
float Duals[Items] = ...;


dvar float Cut[Patterns] in 0..1000000;
// use a dvar to represent the part of the objective that has an aggregate  
// so that we can call IloObjective.setLinearCoef() when modifying the objective function with the interfaces examples
dvar float initialCost;
 
minimize initialCost;
subject to {
  initialCost == sum( i in Patterns ) 
    Cost[i] * Cut[i];

  forall( i in Items ) 
    ctFill:
      sum( p in Patterns ) 
        Fill[p][i] * Cut[p] >= Amount[i];
}
    

execute DISPLAY {
  writeln("Cut = ",Cut);
  for(var p in Patterns) 
    writeln("Use of pattern ", p, " is : ",Cut[p]);
}
     
