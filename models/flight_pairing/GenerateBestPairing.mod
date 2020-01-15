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

 include "FlightPairing_data.mod";
 include "PairingGeneration_data.mod";
 include "FlightCoverDual_data.mod";
 
 using CP;
 
 int NbFlights  = card(flights);
 //int NbAirports = card(airports);
 int MaxLegs = parameters.maxNbLegs;
 int latestArrivalTime = max(f in flights) f.arrivalTime;
 int MaxWorkTime = parameters.workDurationMax;
 
 range FlightRange  = 1..NbFlights;
 range LegRange     = 1..MaxLegs;
 
 // time horizon is limited by latest arrival time.
 range horizon      = 0..latestArrivalTime;
 
 /// intermediate arrays for CP
 TFlightData FlightsByIndex[ f in FlightRange ] = item(flights,f-1);
 int arrivalTimes  [ f in FlightRange ] = FlightsByIndex[f].arrivalTime;
 int departureTimes[ f in FlightRange ] = FlightsByIndex[f].departureTime;
 int FlyingTimes[ f in FlightRange ] = FlightsByIndex[f].arrivalTime-FlightsByIndex[f].departureTime;
 
 int fromAirportIndex[ f in FlightRange] = ord(airports,<FlightsByIndex[f].fromAirportName>);
 int toAirportIndex  [ f in FlightRange] = ord(airports,<FlightsByIndex[f].toAirportName>);
 
 TAirport originAirport     [f in FlightRange] = item( airports, ord(airports,<FlightsByIndex[f].fromAirportName>) );
 //TAirport destinationAirport[f in FlightRange] = item( airports, ord(airports,<FlightsByIndex[f].originAirportName>) );
  
 int originTransitTimeMin[ f in FlightRange ] = originAirport[f].transitTimeMin;
 int originTransitTimeMax[ f in FlightRange ] = originAirport[f].transitTimeMax;
 
{TPairingLeg} genLegs;
TPairingCost genCost = <1, 0>;
 
 /**
  ** Pairings are modeled by a sequence of variables ranging over flights.
  ** 
  */
 dvar int flightVars[ LegRange ] in FlightRange;
 
 dvar boolean isActualLeg[ LegRange];
 
 dvar int+ startTimeVar in horizon;
 dvar int+ endTimeVar   in horizon;
 dvar int+ totalFlyingTime in 0..parameters.flyingDurationMax;
 
 /// pay
 dvar int+ costVar in parameters.minPay..999999999;
 dvar int+ workTimeCostVar;
 dvar int+ flyingTimeCostVar;
 
 dvar int+ costVars[1..3];
 
/// input from master LP model.
{TFlightCoverDual} coverct_duals = ...;

float duals[ FlightRange ] = [ fcd.flightRank : fcd.coverCtDual | fcd in coverct_duals ];

dexpr float dualObj =
  sum (f in FlightRange) duals[f] * (count(flightVars,f)>=1);

execute LIMIT_CP {
  cp.param.branchLimit = thisOplModel.PairingGenerationData.SlaveModelBranchLimit;
  cp.param.Workers = 1;
}

minimize 1 - dualObj;

subject to
 {
    // forbid one-leg pairings
    flightVars[1] != flightVars[2];
    isActualLeg[1] == 1;
    
    // sum(l in LegRange) isActualLeg[l] >= 7;
    
    // relate status vars to flight vars
    forall(l in LegRange: l > 1) {
      isActualLeg[l] == (flightVars[l] != flightVars[l-1]);    
    }
    
    // return home at the end of the chain
    fromAirportIndex[ flightVars[1] ] == toAirportIndex[ flightVars[ MaxLegs]];
    
    // either the chain ends or the airport chain is continuous
    forall(l in 2..MaxLegs) {
       (0 == isActualLeg[l])
       ||
       (fromAirportIndex[ flightVars[l] ] == toAirportIndex[ flightVars[l-1]]);
    }
  
    forall (l in 2..MaxLegs) {
       (0 == isActualLeg[l])    
     ||
     (
      departureTimes[ flightVars[l] ] >= arrivalTimes[ flightVars[l-1]]
      + originTransitTimeMin[ flightVars[l] ]
      );
     }
    forall (l in 2..MaxLegs) {       
        (isActualLeg[l]==0)
      || 
      (
      departureTimes[ flightVars[l] ] <= arrivalTimes[ flightVars[l-1]]
      + originTransitTimeMax[ flightVars[l] ]
      );
    }
    
    /// propagate end of chain to the right
    forall (l in LegRange: 1 < l) {
       isActualLeg[l-1] >= isActualLeg[l];
    }
    
    // total flying time is counted only on "actual" legs
    totalFlyingTime == 
    FlyingTimes[ flightVars[1]]
    + sum(l in 2..MaxLegs) ( FlyingTimes[ flightVars[l] ] * isActualLeg[l]);
    
    startTimeVar == departureTimes[ flightVars[1]];
    endTimeVar   == arrivalTimes  [ flightVars[MaxLegs] ];
    
    (endTimeVar <= startTimeVar + MaxWorkTime);
    
    flyingTimeCostVar >= parameters.flyingPayRate * totalFlyingTime;
    flyingTimeCostVar <= parameters.flyingPayRate * totalFlyingTime+1;
    workTimeCostVar >= parameters.workPayRate * (endTimeVar - startTimeVar);
    workTimeCostVar <= parameters.workPayRate * (endTimeVar - startTimeVar)+1;
    
    /// all that pain to use max[]
    costVars[1] == parameters.minPay;
    costVars[2] == workTimeCostVar;
    costVars[3] == flyingTimeCostVar;
    
    costVar == max(j in 1..3) costVars[j];
 }
 
 
 
 execute DISPLAY_SOLUTION {
   var lastTime = -1;
   var lastFlight = null;
   genCost.cost = costVar;
   
   for (var l in LegRange) {
     var flightRank = flightVars[l];
     var flight = FlightsByIndex[flightRank];
     genLegs.add(1, l, flightRank);
     
     if ( flight == lastFlight ) break;
     //writeln("* leg #", l, "f: ", flightRank, ", flight: ", flight.name, ", from ", flight.fromAirportName, " to ", flight.toAirportName);
     var idle = lastTime>=0? flight.departureTime - lastTime: 0;
     //writeln("* idle: ", idle, ", fly time=", flight.arrivalTime-flight.departureTime);
     lastTime = flight.arrivalTime;
     lastFlight = flight;
   } 
   //writeln(" work=", (endTimeVar - startTimeVar), ", flying=", totalFlyingTime);
   //writeln(" cost=", costVar, ", dual:", dualObj);
 }
