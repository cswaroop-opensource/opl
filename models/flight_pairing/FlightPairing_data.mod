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

/**
 * Airport data. 
 * Each airport is identified by its three-letter id code
 * and a transit time range: each flight passing through the airport
 * must satisfy this transit range.
 */
tuple TAirport {
   key string id;
   int transitTimeMin;
   int transitTimeMax;
}

/**
 * Flight data;
 * A flight is identified by its id, its source and target airports
 * and time schedule.
 */
tuple TFlightData {
   key string name;
   string fromAirportName;
   string toAirportName;
   
   // times are in minutes...
   int departureTime;
   int arrivalTime;
}
 
 /**
  * Global parameters (one single tuple of this type)
  * maxmum work and fly time (regulations)
  * data pertaining to pay
  *  - minimum pay (flat sum)
  *  - work time pay rate per time unit
  *  - fly-time pay rate by time unit
  *
  * - maximum nb legs is 8 by default.
 */
tuple TParameters {
  int maxNbLegs;
  int workDurationMax;
  int flyingDurationMax;
  
  int minPay;
  float workPayRate;
  float flyingPayRate;

};

/// INPUT data
{TAirport}    airports = ...;
{TFlightData} flights  = ...;

TParameters parameters = ...;


/// output data

tuple TPairingLeg {
  int id;
  int legRank;
  int flightRank; // in 1..card(flights) 
};

tuple TPairingCost {
  int id;
  float cost;
}
