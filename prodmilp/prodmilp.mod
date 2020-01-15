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
{string} Resources = ...;
{string} Machines = ...;
float MaxProduction = ...;

tuple typeProductData {
  float demand;
  float incost;
  float outcost;
  float use[Resources];
  string machine;
}

typeProductData Product[Products] = ...;
float Capacity[Resources] = ...;
float RentCost[Machines] = ...;

dvar boolean Rent[Machines];
dvar float+ Inside[Products];
dvar float+ Outside[Products];


minimize
  sum( p in Products ) 
    ( Product[p].incost * Inside[p] + 
      Product[p].outcost * Outside[p] ) +
  sum( m in Machines ) 
    RentCost[m] * Rent[m];
   
subject to {
  forall( r in Resources )
    ctCapacity:
      sum( p in Products ) 
        Product[p].use[r] * Inside[p] <= Capacity[r];

  forall( p in Products )
    ctDemand: 
      Inside[p] + Outside[p] >= Product[p].demand;

  forall( p in Products )
    ctMaxProd:
      Inside[p] <= MaxProduction * Rent[Product[p].machine];
}

tuple InsideSolutionT{ 
	string Products; 
	float value; 
};
{InsideSolutionT} InsideSolution = {<i0,Inside[i0]> | i0 in Products};
tuple OutsideSolutionT{ 
	string Products; 
	float value; 
};
{OutsideSolutionT} OutsideSolution = {<i0,Outside[i0]> | i0 in Products};
tuple RentSolutionT{ 
	string Machines; 
	int value; 
};
{RentSolutionT} RentSolution = {<i0,Rent[i0]> | i0 in Machines};


