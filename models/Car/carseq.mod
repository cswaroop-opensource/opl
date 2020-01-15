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

using CP;


//
// Raw data
//
int nbConfs   = ...; 
int nbOptions = ...;
range Confs = 1..nbConfs;
range Options = 1..nbOptions;
int demand[Confs] = ...;
tuple CapacitatedWindow {
  int l;
  int u;
};
CapacitatedWindow capacity[Options] = ...; 

//
// Data for modified model with "blank" configurations
//
range AllConfs = 0..nbConfs;
int nbCars = sum (c in Confs) demand[c];
int nbSlots = ftoi(floor(nbCars * 1.1 + 5)); // 10% slack + 5 slots
int nbBlanks = nbSlots - nbCars;
range Slots = 1..nbSlots;
int option[Options,Confs] = ...; 
int allOptions[o in Options, c in AllConfs] = (c == 0) ? 0 : option[o][c];

//
// Decision variables
//
dvar int slot[Slots] in AllConfs;
dvar int lastSlot in nbCars..nbSlots;

minimize lastSlot - nbCars; // Try to get to zero meaning all blanks at the end
subject to {
  // Cardinality of configurations
  count(slot, 0) == nbBlanks;
  forall (c in Confs)
    count(slot, c) == demand[c];

  // Capacity of gliding windows
  forall(o in Options, s in Slots : s + capacity[o].u - 1 <= nbSlots)
    sum(j in s .. s + capacity[o].u - 1) allOptions[o][slot[j]] <= capacity[o].l;

  // Last slot
  forall (s in nbCars + 1 .. nbSlots)
    (s > lastSlot) => slot[s] == 0;
};
