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

int NbPeriods = ...;
range Periods = 1..NbPeriods;

float Demand[Periods] = ...;
float RegularCost = ...;
float ExtraCost = ...;
float Capacity = ...;
float Inventory = ...;
float InventoryCost = ...;

range Periods0 = 0..NbPeriods;

dvar float+ RegulBoat[Periods];
dvar float+ ExtraBoat[Periods];
dvar float+ Inv[Periods0];


minimize
   RegularCost * 
   ( sum( t in Periods ) RegulBoat[t] ) +
   ExtraCost * 
   ( sum( t in Periods ) ExtraBoat[t] ) +
   InventoryCost * 
   ( sum(t in Periods ) Inv[t] );
   
subject to {
  ctInit:  
    Inv[0] == Inventory;
  forall( t in Periods ) 
    ctCapacity:
      RegulBoat[t] <= Capacity;
  forall( t in Periods )
    ctBoat: 
      RegulBoat[t] + ExtraBoat[t] + Inv[t-1] == Inv[t] + Demand[t];
}


tuple RegulBoatSolutionT{ 
	int Periods; 
	float value; 
};
{RegulBoatSolutionT} RegulBoatSolution = {<i0,RegulBoat[i0]> | i0 in Periods};
tuple ExtraBoatSolutionT{ 
	int Periods; 
	float value; 
};
{ExtraBoatSolutionT} ExtraBoatSolution = {<i0,ExtraBoat[i0]> | i0 in Periods};
tuple InvSolutionT{ 
	int Periods0; 
	float value; 
};
{InvSolutionT} InvSolution = {<i0,Inv[i0]> | i0 in Periods0};
