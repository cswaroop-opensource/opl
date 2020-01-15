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
int NbPieces = ...;

float Cost[1..NbPieces] = ...;
float Breakpoint[1..NbPieces-1] = ...;
float Demand[Periods] = ...;
float Inventory = ...;
float InventoryCost = ...;

dvar float+ Boat[Periods];
dvar float+ Inv[0..NbPeriods];


minimize
  sum( t in Periods )
    piecewise(i in 1..NbPieces-1) { 
      Cost[i] -> Breakpoint[i]; 
      Cost[NbPieces] 
    } Boat[t] +
  InventoryCost  * ( sum( t in Periods ) Inv[t] );
   
subject to {
  ctInit:  
    Inv[0] == Inventory;
  forall( t in Periods ) 
    ctBoat: 
      Boat[t] + Inv[t-1] == Inv[t] + Demand[t];
           
}
