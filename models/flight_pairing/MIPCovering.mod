// --------------------------------------------------------------------------
// Licensed Materials - Property of IBM
//
// 5725-A06 5725-A29 5724-Y48 5724-Y49 5724-Y54 5724-Y55
// Copyright IBM Corporation 1998, 2015. All Rights Reserved.
//
// Note to U.S. Government Users Restricted Rights:
// Use, duplication or disclosure restricted by GSA ADP Schedule
// Contract with IBM Corp.
// --------------------------------------------------------------------------

/// --- 
/// This is the MIP variant of the set covering problem.
/// ---
include "FlightPairing_data.mod";
include "PairingGeneration_data.mod";

/// externals
{TPairingCost} pairingCosts = ...;
{TPairingLeg}  pairingLegs  = ...;

/// internal
int NbFlights = card(flights);
range FlightIndexRange = 1..NbFlights;

{int} pairing_ids = { pc.id | pc in pairingCosts };

/// locals
{int} covered[ p in pairing_ids] = { fr | <p, l, fr> in pairingLegs };

dvar boolean iUsageVars[ pairing_ids ];

dexpr float totalUsageCost = sum(pc in pairingCosts) (iUsageVars[pc.id] * pc.cost);

minimize totalUsageCost;

subject to { 
  forall (f in FlightIndexRange) {
    sum(p in pairing_ids: f in covered[p]) iUsageVars[p] >= 1;  
  }
}

int numberOfSelectedPairings = sum(p in pairing_ids) iUsageVars[p];
execute DEBUG {
  writeln("* MIP covering uses: ", numberOfSelectedPairings, " out of ", pairingLegs.size);
}
