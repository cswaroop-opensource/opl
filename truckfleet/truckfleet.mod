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

/* ------------------------------------------------------------

Problem Description
-------------------
The problem is to deliver some orders to several clients with a single truck. 
Each order consists of a given quantity of a product of a certain type (called
its color).
The truck must be configured in order to handle one, two or three different colors of products.
The cost for configuring the truck from a configuration A to a configuration B depends on A and B.
The configuration of the truck determines its capacity and its loading cost. 
A truck can only be loaded with orders for the same customer.
Both the cost (for configuring and loading the truck) and the number of travels needed to deliver all the 
orders must be minimized, the cost being the most important criterion. 

------------------------------------------------------------ */
using CP;

int nbTrucks       = ...; //max number of travels of the truck
range Trucks       = 1..nbTrucks;

tuple Order {
  key int id;
  int customerId;
  int volume;
  string color;
}
{Order} Orders = ...;
int volumes[o in Orders] = o.volume;
{int} Customers = { o.customerId | o in Orders };

tuple TruckConfig {
  key int id;
  int maxLoad;
  int cost;
  {string} allowedColors;
}
{TruckConfig} TruckConfigs = ...;
{int} TruckConfigIds = { t.id | t in TruckConfigs};
int minTruckConfigId = min(i in TruckConfigIds) i; 
int maxTruckConfigId = max(i in TruckConfigIds) i; 
range TruckConfigRange = minTruckConfigId..maxTruckConfigId;
int maxTruckConfigLoad[TruckConfigIds] = [t.id : t.maxLoad | t in TruckConfigs];
int maxLoad = max(t in TruckConfigIds) maxTruckConfigLoad[t]; 

//cost for loading a truck of a given config
int truckCost[TruckConfigIds] =  [t.id : t.cost | t in TruckConfigs];

//configuration of the truck
dvar int truckConfigs[Trucks] in TruckConfigRange;
//In which truck is an order
dvar int where[Orders] in Trucks;
//load of a truck
dvar int load[Trucks] in 0..maxLoad;
// number of trucks used
dvar int numUsed in 0..nbTrucks;
dvar int customerOfTruck[Trucks] in (min(i in Customers) i)..(max(i in Customers) i);

tuple Transition {
   int src;
   int dest;
   int cost;
};
{Transition} costTuples = ...;
dvar int transitionCost[Trucks] in 0..(max(t in costTuples) t.cost);
dvar int configOfContainer[Orders] in TruckConfigRange;

execute {
  cp.param.timeLimit=20;
  cp.param.logPeriod=50000;
  cp.setSearchPhases(cp.factory.searchPhase(where));
}

// Objective: first criterion for minimizing the cost for configuring and loading trucks 
//            second criterion for minimizing the number of trucks
dexpr int e1 =   sum(t in Trucks) (truckCost[truckConfigs[t]]*(load[t]!=0))
  + sum(t in Trucks) transitionCost[t];
dexpr int e2 = numUsed;

minimize staticLex(e1, e2);  // trying to minimize cost first
//minimize staticLex(e2, e1);  // trying to minimize numUsed first
subject to {
  forall(t in Trucks)
    truckConfigs[t] in TruckConfigIds;
  forall(o in Orders)
    configOfContainer[o] in TruckConfigIds;
  forall(t in Trucks)
    customerOfTruck[t] in Customers;

  forall(t in 2..nbTrucks)
    allowedAssignments(costTuples, truckConfigs[t-1], truckConfigs[t], transitionCost[t-1]);

  // constrain the volume of the orders in each truck 
  pack(load, where, volumes, numUsed);
  forall(t in Trucks)
    load[t] <= maxTruckConfigLoad[truckConfigs[t]];

  // compatibility between the colors of an order and the configuration of its truck 
  forall(o in Orders) {
    //configOfContainer[o] in allowedContainerConfigs[o.color];
    configOfContainer[o] in { t.id | t in TruckConfigs : o.color in t.allowedColors};
    configOfContainer[o] == truckConfigs[where[o]];
  }

  // only one customer per truck 
  forall(o in Orders)
    customerOfTruck[where[o]] == o.customerId;

  // non used trucks are at the end
  forall(t in 2..nbTrucks)
    (load[t-1]) > 0 || (load[t] == 0);

  // Dominance: the non used truck keep the last used configuration
  load[1] > 0;
  forall(t in 2..nbTrucks)
    (load[t] > 0) || (truckConfigs[t] == truckConfigs[t-1]);

  //Dominance:  regroup deliveries with same configuration
  forall(t in 2..nbTrucks-1)
    (truckConfigs[t] == truckConfigs[t-1])
    || and(p in (t+1)..nbTrucks) truckConfigs[p] != truckConfigs[t-1];
}

tuple solutionT{
	int truck;
	int config;
	Order o;
};
{solutionT} solution = {<t, truckConfigs[t], o> | t in Trucks : load[t]!=0, o in Orders : where[o] == t};

execute {
  writeln("Configuration cost: " + e1 +
          " Number of Trucks: " + numUsed);
          
  for(var t in Trucks) {  
    if (load[t]!=0) {
      write("Truck " + t + ": Config=" + truckConfigs[t] + " Items= ");
      for (var o in Orders) {
        if (where[o] == t) {
          write("<" + o.id + "," + o.color + "," + o.volume + "> ");
        }
      }
      writeln();
    }
  }
};
