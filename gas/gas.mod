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

{string} Products = ...;
{string} Components = ...;

float Demand[Products][Components] = ...;
float Profit[Products] = ...;
float Stock[Components] = ...;
dvar float+ Production[Products];

maximize
  sum( p in Products ) 
    Profit[p] * Production[p];
subject to {
  forall( c in Components )
    ct:
      sum( p in Products ) 
        Demand[p][c] * Production[p] <= Stock[c];
}

tuple ProductionSolutionT{ 
	string Products; 
	float value; 
};
{ProductionSolutionT} ProductionSolution = {<i0,Production[i0]> | i0 in Products};







