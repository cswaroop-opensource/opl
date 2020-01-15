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

// Total number of wells.
int nbWells = ...;

// Number of wells that can work simultaneously.
int wellLimit =...;

// Number of operations in each well (= number of pay sands in each well).
int nbOperations = ...;

// Number of pay sand types.
int nbSands =...;

// Ranges.
range Wells      = 1..nbWells;
range Operations = 1..nbOperations;
range Sands      = 1..nbSands;

// Production rate on each well and for each type of sand.
int rate[Wells][Sands] = ...;

// List of sands in a well.
int composition[Wells][Operations] = ...;

// Depth of each pay sand in each well.
int depth[Wells][Operations] = ...;

// Duration of the workover. It depends on the type of sand that follows.
int workDuration[Sands] = ...;

// Operations for digging the pay sands in each wells.
// Their duration is computed by multiplying the rate by the the depth.
dvar interval operations[w in Wells][o in Operations] size depth[w][o]*rate[w][composition[w][o]];

// Operations for the workovers. 
// Their duration depends on the composition of the sand.
dvar interval workovers[w in Wells][o in Operations] size workDuration[composition[w][o]];

// Cumul for limiting the number of wells that can run simultaneouly.
cumulFunction wellUsage = sum (w in Wells, o in Operations) pulse(operations[w][o], 1);

execute {
  		cp.param.FailLimit = 5000;
}

minimize max(w in Wells) endOf(operations[w,nbOperations]);
subject to {
    
    // In each well: 
    forall(w in Wells) {
        // Workovers are before the operations on the sand,
        forall(o in Operations)
            endBeforeStart(workovers[w][o], operations[w][o]);
        // Each operation is followed by a workover.
        forall(o in 1..nbOperations-1)
            endBeforeStart(operations[w][o], workovers[w][o+1]);
    }
    
    // All the workovers need the rig so they cannot overlap.
    noOverlap(workovers);
    
    // At any time, no more than wellLimit wells can be used.
    wellUsage <= wellLimit;
};


execute {
  writeln(operations);
}
