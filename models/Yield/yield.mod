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

/******************************************************************************
 * 
 * OPL Model for Airline Yield Management
 * Deterministic LP formulation
 * 
 *
 * 
 * This model is greater than the size allowed in trial mode. 
 * You therefore need a commercial edition of CPLEX Studio to run this example. 
 * If you are a student or teacher, you can also get a full version through
 * the IBM Academic Initiative.
******************************************************************************/

/*
  This model is described in the documentation. 
See IDE and OPL > Language and Interfaces Examples.
  
  Examples of the proper data format appear below.
  
Flight Leg:
   <5,   "ABZ", 1165, "SVG", 1376,144>
   
   Flt. ID = 5
   Origin    = "ABZ" (city code)
   Departure Time (in minutes) = 1165
   Destination = "SVG" (city cod)
   Arrival Time (in minutes) = 1376
   Aircraft Capacity = 144
   
Itinerary:
   < 1, 3, {0, 3, 4}, 30, 110>
   
   Itinerary Num. = 1
   Number of Flight Legs = 3
   Flight Leg ID #1 = 0
   Flight Leg ID #2 = 3
   Flight Leg ID #3 = 4
   Expected Demand = 30
   fare = 110   
*/

// Flight Leg structure 
tuple flightLeg 
{
  key int        FltID;             //flight ID
  string     Origin;            //Originating Airport
  int        Dept;              //Departure Time
  string     Destination;       //Destination Airport
  int        Arrt;              //Arrival Time
  int        Cap;               //Capacity
}

// Set of Scheduled Flight Legs
{flightLeg} FlightLegs = ...; 
assert forall(fl in FlightLegs)  fl.Dept <= fl.Arrt;

{int} LegIDSet = {fl.FltID | fl in FlightLegs};

// Make sure there are no duplicate flight IDs!
assert card(LegIDSet) == card(FlightLegs);

flightLeg ArrayOfFlightLegs[LegIDSet] =
 [fl.FltID : fl | fl in FlightLegs];


// Maximum time that passenger is willing to wait between connecting flights
int MaxWaitTime = ...;

// Itinerary structure - Unlimited number of legs in itinerary
tuple itinerary
{
  key int ItinID;            //Itinerary ID
  int NumLegs;           //Number of legs in Itinerary    
  {int} LegIDs;          //Set of Legs in Itinerary
  float dmd;             //Expected Demand
  float fare;            //fare
}

// Set of desired Itineraries
{itinerary} Itineraries = ...; 

{int} ItinIDSet = {it.ItinID | it in Itineraries};

// Make sure there are no duplicate itinerary numbers!
assert card(ItinIDSet) == card(Itineraries);

int Maxis[i in Itineraries] = max(g in i.LegIDs) ArrayOfFlightLegs[g].Dept;

// An assertion ensuring that all itineraries are feasible             
assert
    forall(i in Itineraries, f1 in i.LegIDs: ArrayOfFlightLegs[f1].Dept < Maxis[i])
    1 ==
        sum(f2 in i.LegIDs:
             f1 != f2 &&
             ArrayOfFlightLegs[f2].Origin == ArrayOfFlightLegs[f1].Destination &&
             ArrayOfFlightLegs[f1].Arrt <= ArrayOfFlightLegs[f2].Dept &&
             ArrayOfFlightLegs[f2].Dept <= ArrayOfFlightLegs[f1].Arrt + MaxWaitTime
)
            1;

/******************************************************************************
 * MODEL DECLARATIONS
 ******************************************************************************/

dvar float+   Allocation[it in Itineraries] in 0..it.dmd;  // allocation level to itinerary        

/******************************************************************************
 * MODEL
 ******************************************************************************/

dexpr float TotalAllocation =
  sum(it in Itineraries) it.fare*Allocation[it];

maximize TotalAllocation;
    
subject to {
  forall(fl in FlightLegs) 
    ctCapLimit: 
      sum(it in Itineraries: fl.FltID in it.LegIDs) Allocation[it] <= fl.Cap;
}


tuple itineraryT{
  key int ItinID;        //Itinerary ID
  int NumLegs;           //Number of legs in Itinerary    
  float dmd;             //Expected Demand
  float fare;            //fare
}
tuple AllocationSolutionT{ 
	itineraryT Itineraries; 	
	float value; 
};
{AllocationSolutionT} AllocationSolution = {<<i0.ItinID, i0.NumLegs, i0.dmd, i0.fare>,Allocation[i0]> | i0 in Itineraries};
execute{ 
	writeln(AllocationSolution);
}

execute DISPLAY {
   for(var fl in FlightLegs)
      if(ctCapLimit[fl].dual > 0.001)
         writeln("ctCapLimit[", fl, "].dual = ", ctCapLimit[fl].dual);
}
