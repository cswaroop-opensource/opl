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

/************************************************************************************

  OPL Model for Trucking Problem
 
  This model is described in the documentation. 
See IDE and OPL > Language and Interfaces Examples.


**************************************************************************************/

{string} Location = ...;
{string} TruckTypes = ...;

{string} Spokes = ...;
{string} Hubs = ...;

tuple spokeInfo {
  int     minDepTime; // Earliest departure time at spoke 
  int     maxArrTime; // Latest arrive time at spoke
};   

spokeInfo Spoke[Spokes] = ...;

// Make sure the data is consistent: latest arrival time >= earliest departure time
assert forall(s in Spokes) Spoke[s].maxArrTime > Spoke[s].minDepTime;

tuple truckTypeInfo {
  int   capacity;
  int   costPerMile;  
  int   milesPerHour; //speed
}

truckTypeInfo TruckTypeInfos[TruckTypes] = ...;
int LoadTime[Hubs][TruckTypes] = ...; // in minutes; loadTime = unloadTime

tuple routeInfo {
  key string   spoke;
  key string   hub;
  int      distance;  // in miles
}
{routeInfo} Routes = ...;

// The following assertion is to make sure that the spoke 
// in each route is indeed in the set of Spokes.
assert forall(r in Routes : r.spoke not in Spokes) 1 == 0;

// The following assertion is to make sure that the hub
// in each route is indeed in the set of Hubs.
assert forall(r in Routes : r.hub not in Hubs) 1 == 0;

tuple triple {
  string origin;
  string hub;
  string destination;
}

{triple} Triples =  // feasible paths from spokes to spokes via one hub  
{<r1.spoke,r1.hub,r2.spoke> | r1,r2 in Routes : r1 != r2 && r1.hub == r2.hub};
 
tuple shipment {
  key string   origin;
  key string   destination;
  int       totalVolume;
}
{shipment} Shipments = ...;

// The following assertion is to make sure that the origin 
// of each shipment is indeed in the set of Spokes.
assert forall(s in Shipments : s.origin not in Spokes) 1 == 0;

// The following assertion is to make sure that the destination 
// of each shipment is indeed in the set of Spokes.
assert forall(s in Shipments : s.destination not in Spokes) 1 == 0;

int PossibleTruckOnRoute[Routes][TruckTypes];

// the earliest unloading time at a hub for each type of truck  
int EarliestUnloadingTime[Routes][TruckTypes]; 
// the latest loading time at a hub for each type of truck
int LatestLoadingTime[Routes][TruckTypes];

// Compute possible truck types that can be assigned on a route
execute INITIALIZE {
  for(var r in Routes)
    for(var t in TruckTypes) {
      EarliestUnloadingTime[r][t] = Math.ceil(LoadTime[r.hub][t] + Spoke[r.spoke].minDepTime + 60*r.distance/TruckTypeInfos[t].milesPerHour);
      LatestLoadingTime[r][t] = Math.floor(Spoke[r.spoke].maxArrTime - LoadTime[r.hub][t] - 60*r.distance/TruckTypeInfos[t].milesPerHour);
      // A type of truck can be assigned on a route only if it can make it to the hub and back 
      //  before the max arrival time at the spoke.
      if ( EarliestUnloadingTime[r][t] < LatestLoadingTime[r][t]) { 
        PossibleTruckOnRoute[r][t] = 1;
      }
      else {
        PossibleTruckOnRoute[r][t] = 0;
      }   
    }
}

int MaxTrucks = 100;  // Maximum # of trucks for each type on a route 

// Maximum Volume of goods that can be handled 
// on each path for each type of truck
int MaxVolume = 5000; 

dvar int+ TruckOnRoute[Routes][TruckTypes] in 0..MaxTrucks;

// This represents the volumes shipped out from each hub 
// by each type of truck on each triple
// The volumes are distinguished by truck types because trucks of different types 
// arrive at a hub at different times and the timing is used in defining 
// the constraints for volume availability for the trucks leaving the hub. 
dvar int+ OutVolumeThroughHubOnTruck[Triples][TruckTypes] in 0..MaxVolume;

// This represents the volume shipped into each hub by each type of truck on each triple
// It is used in defining timing constraints. 
dvar int+ InVolumeThroughHubOnTruck[Triples][TruckTypes] in 0..MaxVolume;

dexpr float TotalCost = 
  sum(r in Routes, t in TruckTypes) 2*r.distance*TruckTypeInfos[t].costPerMile*TruckOnRoute[r][t];
  
minimize TotalCost;

subject to {      
  // The # of trucks of each type should be less than "maxTrucks", and if a type of truck 
  // is impossible for a route, its # should be zero 
  forall(r in Routes, t in TruckTypes)
    ctMaxTruck: 
      TruckOnRoute[r][t] <= PossibleTruckOnRoute[r][t]*MaxTrucks;

  // On each route s-h, the total inbound volume carried by trucks of each type 
  // should be less than the total capacity of the trucks of this type.
  forall(<s,h,dist> in Routes, t in TruckTypes)
    ctInCapacity: 
      sum(<s,h,dest> in Triples) InVolumeThroughHubOnTruck[<s,h,dest>][t] 
         <= TruckOnRoute[<s,h,dist>][t]*TruckTypeInfos[t].capacity;
         
  // On each route s-h, the total outbound volume carried by each truck type should be less than 
  // the total capacity of this type of truck.

  forall(<s,h,dist> in Routes, t in TruckTypes)
    ctOutCapacity:      
      sum(<o,h,s> in Triples) OutVolumeThroughHubOnTruck[<o,h,s>][t]
           <= TruckOnRoute[<s,h,dist>][t]*TruckTypeInfos[t].capacity;
   
  // On any triple, the total flows in the hub = the total flows out the hub
  forall (tr in Triples) 
    ctFlow: 
      sum(t in TruckTypes) InVolumeThroughHubOnTruck[tr][t]
        == sum(t in TruckTypes) OutVolumeThroughHubOnTruck[tr][t];
   
  // The sum of flows between any origin-destination pair via all hubs is equal to the shipment between the o-d pair.

  forall (<o,d,v> in Shipments )
    ctOrigDest: 
      sum(t in TruckTypes, <o,h,d> in Triples) InVolumeThroughHubOnTruck[<o,h,d>][t] == v;
   
          
  // There must be enough volume for a truck before it leaves a hub. 
  // In another words, the shipments for a truck must arrive 
  // at the hub from all spokes before the truck leaves.
  // The constraint can be expressed as the following:
  // For each route s-h and leaving truck of type t:
  // Cumulated inbound volume arrived before the loading time of the truck >=
  // Cumulated outbound volume up to the loading time of the truck (including the shipments being loaded).    
  forall (<s,h,dist> in Routes, t in TruckTypes)  
    ctTiming: 
      sum (<o,h,s> in Triples, t1 in TruckTypes, <o,h,dist1> in Routes :
          // The expression below defines the indices of the trucks unloaded before truck t starts loading.  
          EarliestUnloadingTime[<o,h,dist1>][t1] <= LatestLoadingTime[<s,h,dist>][t]) 
          InVolumeThroughHubOnTruck[<o,h,s>][t1] >=
      sum (<o,h,s> in Triples, t2 in TruckTypes, <o,h,dist2> in Routes : 
          // The expression below defines the indices of the trucks left before truck t starts loading.
          LatestLoadingTime[<o,h,dist2>][t2] <= LatestLoadingTime[<s,h,dist>][t]) 
          OutVolumeThroughHubOnTruck[<o,h,s>][t2];
}


/************************************************************
       POST-PROCESSING                                    
*************************************************************/
// Post processing: result data structures are exported as post-processed tuple or tuple sets
// Solve objective value
tuple result {
  float totalCost;
}
result Result = <TotalCost>;

// Number of trucks assigned to each route, for each truck type
tuple nbTrucksOnRouteRes {
  key string	spoke;
  key string	hub;
  key string	truckType;
  int			nbTruck;
}
{nbTrucksOnRouteRes} NbTrucksOnRouteRes = {<r.spoke, r.hub, t, TruckOnRoute[r][t]> | r in Routes, t in TruckTypes};

// Volume shipped into each hub by each type of truck and each pair (origin, destination)
tuple inVolumeThroughHubOnTruckRes {
  key string	origin;
  key string	hub;
  key string	destination;
  key string	truckType;
  int			quantity;
}
{inVolumeThroughHubOnTruckRes} InVolumeThroughHubOnTruckRes =
	{<tr.origin, tr.hub, tr.destination, t, InVolumeThroughHubOnTruck[tr][t]> | tr in Triples, t in TruckTypes};

// Volume shipped from each hub by each type of truck and each pair (origin, destination)
tuple outVolumeThroughHubOnTruckRes {
  key string	origin;
  key string	hub;
  key string	destination;
  key string	truckType;
  int			quantity;
}
{outVolumeThroughHubOnTruckRes} OutVolumeThroughHubOnTruckRes =
	{<tr.origin, tr.hub, tr.destination, t, OutVolumeThroughHubOnTruck[tr][t]> | tr in Triples, t in TruckTypes};

execute {
  Result;
  NbTrucksOnRouteRes;
  InVolumeThroughHubOnTruckRes;
  OutVolumeThroughHubOnTruckRes;
}