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

/*  ----------------------------------------------------
 *   OPL Model for Production planning Example
 *
 *   This model is described in the documentation. 
 *   See IDE and OPL > Language and Interfaces Examples.
 *   --------------------------------------------------- */

{string} ComputerTypes = ...;
{string} ComponentTypes = ...;
int NbPeriods = ...;
range Periods = 1..NbPeriods;
int MaxBuildPerPeriod[Periods] = ...;
int MinDemand[ComputerTypes][Periods] = ...;
int MaxDemand[ComputerTypes][Periods] = ...;
tuple computersToBuild {
   {string} components;
   int      price;
   int      maxInventory;
}
computersToBuild Computers[ComputerTypes] = ...;
float TotalBuild[ComputerTypes] = ...;

int MaxInventory = 15;

/*  ----------------------------------------------------
 *   Variables:
 *   build --   How many of each computer type to build
 *         in each period
 *   inStockAtEndOfPeriod --   How many of each computer 
 *   type to hold over in inventory at the end of each
 *         period
 *   --------------------------------------------------- */
dvar float+ Build[ComputerTypes][Periods];
dvar float+ Sell[ComputerTypes][Periods];
dvar float+ InStockAtEndOfPeriod[ComputerTypes][Periods];


subject to {
   
  forall(p in Periods)  
    ctInventoryCapacity:  
      sum(c in ComputerTypes) InStockAtEndOfPeriod[c][p] <= MaxInventory;

  forall(c in ComputerTypes, p in Periods)
    ctUnderMaxDemand: Sell[c][p] <= MaxDemand[c][p];
     

  forall(c in ComputerTypes, p in Periods)
    ctOverMinDemand: Sell[c][p] >= MinDemand[c][p];
      
  forall(c in ComputerTypes, p in Periods)
    ctComputerTypeInventoryCapacity:     
      InStockAtEndOfPeriod[c][p] <= Computers[c].maxInventory;
  
  forall(c in ComputerTypes)
    ctTotalToBuild:      
      sum(p in Periods) Build[c][p] == TotalBuild[c];

  forall(c in ComputerTypes)
    Build[c][1] == Sell[c][1] + InStockAtEndOfPeriod[c][1];
     
   forall(c in ComputerTypes, p in 2..NbPeriods)
     ctInventoryBalance:      
       InStockAtEndOfPeriod[c][p-1] + Build[c][p] == 
         Sell[c][p] + InStockAtEndOfPeriod[c][p]; 
         
}
