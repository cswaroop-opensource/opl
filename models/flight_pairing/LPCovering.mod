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

///
include "FlightPairing_data.mod";
include "FlightCoverDual_data.mod";
include "PairingGeneration_data.mod";

/// externals specific to this LP model...
{TPairingCost} pairingCosts = ...;
{TPairingLeg}  pairingLegs  = ...;


/// internal
int NbFlights = card(flights);
range FlightIndexRange = 1..NbFlights;

/// locals
{int} covered[ p in pairingCosts ] = { fr | <p.id, l, fr> in pairingLegs };

dvar float usageVars[ pairingCosts] in 0..1;

dexpr float totalUsageCost = sum(pc in pairingCosts) (usageVars[pc] * pc.cost);
// symmetry breaking?? minimize nb of pairings, costs being equal.
//dexpr float totalUsed =  sum(pc in pairingCosts) (usageVars[pc] );

constraint flight_cover_cts[ 1..NbFlights ];

minimize totalUsageCost;

subject to { 
  forall (f in 1..NbFlights) {
   flight_cover_cts[f]:
    sum(pc in pairingCosts: f in covered[pc] ) usageVars[pc] >= 1;  
  }
}

/// ---
///  post-processing: save dual values per flight
/// ---

{TFlightCoverDual} coverCtDuals;
float dualHash;

execute DUMP_DUALS{

  includeScript("helpers.js");
  
  var DUAL_EPS = 1e-5;
  thisOplModel.settings.displayPrecision = 8;
  
  thisOplModel.dualHash = 0;
  for ( var f in FlightIndexRange) {
    coverCtDuals.add(f, flight_cover_cts[f].dual <= DUAL_EPS ? 0 : flight_cover_cts[f].dual);
    thisOplModel.dualHash += flight_cover_cts[f].dual <= DUAL_EPS ? 0 : flight_cover_cts[f].dual;
  }//for
  
  /// debug: write duals as a DAT structure
  if ( thisOplModel.PairingGenerationData.PrintFiles) {
     print_dual_values("sample_cover_duals.dat", coverCtDuals);
   }     
}
