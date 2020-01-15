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

// used in column generation
float Duals[Items] = ...;


tuple  pattern {
   key int id;
   int cost;
   int fill[Items];
}


{pattern} Patterns = ...;

dvar float Cut[Patterns] in 0..1000000;


minimize
  sum( p in Patterns ) 
    p.cost * Cut[p];
  
subject to {
  forall( i in Items ) 
    ctFill: 
      sum( p in Patterns )
         p.fill[i] * Cut[p] >= Amount[i];
}
    

execute DISPLAY {
  writeln("Cut = ",Cut);
  for(var p in Patterns) 
    writeln("Use of pattern ", p, " is : ",Cut[p]);
}
     
tuple CutSolutionT{ 
	pattern Patterns; 	
	float value; 
};
{CutSolutionT} CutSolution = {<i0,Cut[i0]> | i0 in Patterns};
