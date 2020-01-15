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

// Problem Description
//
// The wood cutting machine
//
// A wood factory machine cuts stands (processed portions of log) into
// chips.  Each stand has a certain length, diameter and specie.  The
// machine can cut a limited number of stands at a time with some
// restriction on the sum of the diameters that it can accept.  Only
// one specie can be processed simultaneously.  Finally, each stands
// have fixed delivery dates and a processing status being either
// standard or rush.  Any delay on rush stand will cost a penalty.
//
// In the model, the stands are represented by activities with
// pre-specified durations.  The objective is to minimize the total
// cost of operating and delay while meeting the system constraints:
// 
// 1) The truck fleet that carry stands to machines for processing is
// limited.
//
// 2) The machine is a discrete resource with capacity specified in
// terms of the sume of stands capacity that can be cut at the same
// time.
// 
// 3) Beside the diameter constraint, only limited number of stands
// can be loaded at the same time.
// 
// 4) To express that only one type of species can be cut at the same
// time a state resource is used.  At any given time, this resource
// indicates the state in terms of available to cut.

//
// OPL model
//
using CP;

int maxDiameter = ...;
int nbTrucks = ...;
int maxStandsTogether = ...;
int nbPeriodsPerDay = ...;
int costPerDay = ...;
int costPerLateFoot = ...;
int maxCost = ...;
{string} Species = ...;
int cutTime[Species] = ...;

tuple Stand {
  int     diameter;
  string  species;
  int     len;
  int     dueDate;
  int     rush;
};

{Stand} stands = ...;

dvar interval a[s in stands] size (s.len * cutTime[s.species]);

dexpr float lateFeet = 
  sum (s in stands : s.rush == 1) s.len * (endOf(a[s]) > s.dueDate);

dexpr int makespan = 
  max (s in stands) endOf(a[s]);

cumulFunction standsBeingProcessed = sum (s in stands) pulse(a[s], 1);
cumulFunction trucksBeingUsed = standsBeingProcessed;
cumulFunction diameterBeingProcessed = sum (s in stands) pulse(a[s], s.diameter);

stateFunction species;

execute {
  		cp.param.FailLimit = 10000;
}

dexpr float objective = makespan * (costPerDay / nbPeriodsPerDay) + costPerLateFoot * lateFeet;
minimize objective;

subject to {
  forall (s in stands)
    alwaysEqual(species, a[s], ord(Species, s.species));
  standsBeingProcessed   <= maxStandsTogether;
  diameterBeingProcessed <= maxDiameter;
  trucksBeingUsed        <= nbTrucks;
};

execute {
  for(var s in stands) {
    writeln(s + " on [" + a[s].start + "," + a[s].end + ")");
  }
  
  //writeln("species ",species);
  for(var i=0; i<species.getNumberOfSegments(); i++) {
    var v = species.getSegmentValue(i);
    if ( v>-1 ) {
      writeln("species ",v," available ",species.getSegmentStart(i)," to ",species.getSegmentEnd(i));
    }
  }
}
