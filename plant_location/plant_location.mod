// --------------------------------------------------------------------------
// Licensed Materials - Property of IBM
//
// 5725-A06 5725-A29 5724-Y48 5724-Y49 5724-Y54 5724-Y55
// Copyright IBM Corporation 1998, 2018. All Rights Reserved.
//
// Note to U.S. Government Users Restricted Rights:
// Use, duplication or disclosure restricted by GSA ADP Schedule
// Contract with IBM Corp.
// --------------------------------------------------------------------------


// Problem Description
// -------------------

// A ship-building company has a certain number of customers. Each customer is supplied
// by exactly one plant. In turn, a plant can supply several customers. The problem is
// to decide where to set up the plants in order to supply every customer while minimizing
// the cost of building each plant and the transportation cost of supplying the customers.

// For each possible plant location there is a fixed cost and a production capacity.
// Both take into account the country and the geographical conditions.

// For every customer, there is a demand and a transportation cost with respect to
// each plant location.

using CP;

int nbCustomer = ...;
int nbLocation = ...;
range Customers = 0..nbCustomer-1;
range Locations = 0..nbLocation-1;
int cost[Customers][Locations] = ...;
int demand[Customers] = ...;
int fixedCost[Locations] = ...;
int capacity[Locations] = ...;;

int custValues[Customers] = ...;

dvar int cust[Customers] in Locations;
dvar int open[Locations] in 0..1;
dvar int load[l in Locations] in 0..capacity[l];

dexpr int obj = sum(l in Locations) fixedCost[l]*open[l]
  + sum(c in Customers) cost[c][cust[c]];

dexpr float occupancy = sum(c in Customers) demand[c]
  / sum(l in Locations) open[l]*capacity[l];

dexpr float minOccup = min(l in Locations)
  ((load[l] / (capacity[l]) + (1-open[l])));

execute {
  cp.addKPI(occupancy, "Occupancy");
  cp.addKPI(minOccup, "Min occupancy");
  cp.param.timeLimit = 10;
  cp.param.logPeriod = 10000;
}

minimize obj;
subject to {
  forall(l in Locations)
    open[l] == (load[l] > 0);
  pack(all(l in Locations) load[l],
       all(c in Customers) cust[c],
       all(c in Customers) demand[c]);
}

execute {
  writeln("obj = " + obj);
}
main
{
  thisOplModel.generate();
  var sol=new IloOplCPSolution();
  for (var c in thisOplModel.Customers)
    sol.setValue(thisOplModel.cust[c],thisOplModel.custValues[c]);
  cp.setStartingPoint(sol);
  cp.solve();
  thisOplModel.postProcess();
} 
