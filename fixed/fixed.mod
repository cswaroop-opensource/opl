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

{string} Machines = ...;
{string} Products = ...;
{string} Resources = ...;

int Capacity[Resources] = ...;
int MaxProduction = max(r in Resources) Capacity[r];
int RentingCost[Machines] = ...;
tuple productType {
   int profit;
   {string} machines;
   int use[Resources];
}
productType Product[Products] = ...;

dvar boolean Rent[Machines];
dvar int Produce[Products] in 0..MaxProduction;

constraint ctMaxProd[Products][Machines];

maximize 
  sum( p in Products ) 
    Product[p].profit * Produce[p] -
  sum( m in Machines ) 
    RentingCost[m] * Rent[m];
      
subject to {
  forall( r in Resources )
    ctCapacity:
      sum( p in Products ) 
        Product[p].use[r] * Produce[p] <= Capacity[r];
    forall( p in Products , m in Product[p].machines )
      ctMaxProd[p][m]:
        Produce[p] <= MaxProduction * Rent[m];
}


tuple ProduceSolutionT{ 
	string Products; 
	int value; 
};
{ProduceSolutionT} ProduceSolution = {<i0,Produce[i0]> | i0 in Products};
tuple RentSolutionT{ 
	string Machines; 
	int value; 
};
{RentSolutionT} RentSolution = {<i0,Rent[i0]> | i0 in Machines};
