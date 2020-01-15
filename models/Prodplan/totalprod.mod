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
 * This model is described in the documentation. 
 * See IDE and OPL > Language and Interfaces Examples.
 *   --------------------------------------------------- */
 
// The data
{string} ComputerTypes = ...;
{string} ComponentTypes = ...;

int NumComputerTypes = card(ComputerTypes);

// Number of Periods to use for this problem
int NbPeriods = ...;
range Periods = 1..NbPeriods;

/*   ---------------------------------------------------
 *   Each computer type has a list of components, a 
 *   selling price and a maximum on the number allowed 
 *   to be held over in inventory to the next period.
 *   --------------------------------------------------- */
tuple computersToBuild
{
  {string} components;
  int      price;
  int      maxInventory;
}

computersToBuild Computers[ComputerTypes] = ...;

/*   ---------------------------------------------------
 *   Each computer type has a maximum and minimum amount
 *   that can be sold in each period.  These values are
 *   used to calculate a range on the total to build of
 *   each computer type.  There is also a plant capacity
 *   for each period.
 *   --------------------------------------------------- */

int MinDemand[ComputerTypes][1..NbPeriods] = ...;
int MaxDemand[ComputerTypes][1..NbPeriods] = ...;
int MaxBuildPerPeriod[1..NbPeriods] = ...;
int MaxBuild = 0;
int TotalMaxDemand[ComputerTypes];
int TotalMinDemand[ComputerTypes];
float TotalBuild[ComputerTypes];
execute INITIALIZE {
  for(var p in Periods) {
    MaxBuild = MaxBuild + MaxBuildPerPeriod[p];
    for(var c in ComputerTypes) {
      TotalMaxDemand[c] = MaxDemand[c][p] + TotalMaxDemand[c];
      TotalMinDemand[c] = MinDemand[c][p] + TotalMinDemand[c];
    }
  }
}

{string} Suppliers = ...;
int NbIncrements = ...;         // Number of "breaks" in PLF
int SupplyCostIncrements[1..NbIncrements] = ...;
range Incrementspp = 1..NbIncrements+1;

tuple componentInfo
{
  string supplier;
  int    costSlope[1..3];   //should be Incrementspp
}
{componentInfo} Components[ComponentTypes] = ...;
tuple supplierMatch {
  string         component;
  componentInfo  componentInformation;
}
{supplierMatch} ComponentSupplierMatches = { <i,j> | i in ComponentTypes, j in Components[i] };

/*  ----------------------------------------------------
 *   Variables:
 *   build --   How many of each computer type to build.
 *   NecessaryComponents -- Based on build
 *   SuppliedComponents -- How many of each component
 *         type are supplied by which supplier
 *   inHouse -- How many of each component type are
 *         manufactured in House.
 *   grossProfit -- linear function of build
 *   cost -- function of SuppliedComponents and inHouse
 *   --------------------------------------------------- */
dvar float+ Build[ComputerTypes];
dvar float+ NecessaryComponents[ComponentTypes];
dvar float+ InHouse[ComponentTypes];
dvar float+ SuppliedComponents[ComponentSupplierMatches];

/*  ----------------------------------------------------
 *   constraints
 *   --------------------------------------------------- */

dexpr float Cost =       
  sum(m in ComponentSupplierMatches)
    piecewise(i in 1..NbIncrements) {
      m.componentInformation.costSlope[i] -> SupplyCostIncrements[i];   
      m.componentInformation.costSlope[NbIncrements+1]
    } SuppliedComponents[m];
    
dexpr float GrossProfit=
  sum(p in ComputerTypes) Computers[p].price * Build[p];

minimize Cost-GrossProfit;

subject to
{
  ctPlantCapacity:
    sum(p in ComputerTypes) Build[p] <= MaxBuild;
      
  forall(p in ComputerTypes)
    ctComputerTypeMaxDemand: Build[p] <= TotalMaxDemand[p];
      
  forall(p in ComputerTypes)
    ctComputerTypeMinDemand: Build[p] >= TotalMinDemand[p];

  // Get the necessary components
  forall(c in ComponentTypes)
    ctDetermineAmtNecessary:      
      sum(p in ComputerTypes: c in Computers[p].components) 
        Build[p] == NecessaryComponents[c];
         
  forall(c in ComponentTypes)
    ctDetermineAmtSupplied:      
      sum(m in ComponentSupplierMatches: c == m.component) 
         SuppliedComponents[m] == NecessaryComponents[c];

  forall(m in ComponentSupplierMatches: m.componentInformation.supplier == "InHouse")
    ctMadeInHouse:      
      InHouse[m.component] == SuppliedComponents[m];
         
}

main {

/*   ---------------------------------------------------
 *   Solve the first model.  This piecewise-linear 
 *   program determines the total number of each computer 
 *   type to build, as well as from where to acquire the 
 *   necessary components.  The objective is to 
 *   maximize profit (really, minimize -profit).
 *   The quantity.build var values are stored to use in
 *   the second step.
 *   --------------------------------------------------- */

   var quantity = thisOplModel;
   quantity.generate();
   if (cplex.solve()) {

     var c;   
     var totalbuild = new Array();

     // Output & get total to build of each type
     writeln("Net profit: ", -cplex.getObjValue());
     for(c in quantity.ComputerTypes) {
       writeln("   ", c, ":  ", quantity.Build[c].solutionValue);
       totalbuild[c] = quantity.Build[c].solutionValue;
     }

     writeln("Components to build in-house:");
     for(c in quantity.ComponentTypes)
       if(quantity.InHouse[c] > 0) {
         writeln("  ", c, ": ", quantity.InHouse[c].solutionValue);
       }

     /*   ---------------------------------------------------
      *   Solve the second model.  This linear program
      *   determines the number of each computer type to
      *   build, sell and hold in each period.  The 
      *   objective is to find a feasible solution.
      *   --------------------------------------------------- */

     var source = new IloOplModelSource("period.mod");
     var def = new IloOplModelDefinition(source);
     var newCplex = new IloCplex();
     var dates = new IloOplModel(def, newCplex);
     var data = new IloOplDataSource("period.dat");
     dates.addDataSource(data);
     dates.generate();
     data = dates.dataElements;
     for(c in dates.ComputerTypes) {
       data.TotalBuild[c] = totalbuild[c];
     }
     if (newCplex.solve()) {
       // Output
       for(var p in dates.Periods) {
         writeln("Period: ", p)
         for(c in dates.ComputerTypes) {
           writeln("  ", c, ":  ")
           writeln("      Build: ", dates.Build[c][p].solutionValue)
           writeln("      Sell:  ", dates.Sell[c][p].solutionValue)
           writeln("      Hold:  ", dates.InStockAtEndOfPeriod[c][p].solutionValue)
         }
       }
     }
     dates.end();
   } else {
     writeln("Could not determine the total number of each computer type to build");
   }
}
