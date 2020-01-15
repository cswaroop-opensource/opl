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

/*******************************************************************************
OPL Model for Air Traffic Flow Management 

This is an air traffic flow management problem. In order to avoid
congestion in critical air sectors, the take-off of flights is
delayed.

Limitations of air capacity are expressed in terms of regulated
periods, i.e. an interval with an hourly capacity rate.  Regulated
air-traffic sectors have one or several regulated periods, i.e. their
capacity is limited during these periods.  The flights have an
expected take-off time (ETOT) which is specified in hours, minutes,
and seconds and then converted into total number of minutes.  An enter
event specifies that a given flight will enter a given sector at an
expected time (called expected time over).

The objective is to minimize the total sum of flight delays.

*******************************************************************************/ 
using CP;

int nbOfFlights = ...;  
range Flights = 1 .. nbOfFlights;

{string} SectorNames = ...;

// times are specified in hours, minutes, seconds 
// (in general year, month, day are needed as well)
tuple Time {
   int hours;
   int minutes;
   int seconds;
};

// limitations of air capacity are expressed in terms of regulated
// periods, i.e. an interval with an hourly capacity rate
tuple Period {
   Time start;
   Time end;
   int rate;
};

{Period} periods[SectorNames] = ...;

// an enter event specifies that a given flight will enter a given sector
// at an expected time (called expected time over)
tuple Enter { 
   int flight;
   string sector;
   Time eto;
};

int nbOfEnters = ...;
range Enters = 1 .. nbOfEnters;
Enter e[Enters] = ...;
   
// flight delays will be limited to 2 hours
int maxDelay = 120;

// capacity of the resource will be made available by time steps of 10 minutes
int timeStep = 10;

// flight delays are expressed by integer variables
dvar int delay[Flights] in 0 .. maxDelay;

// each enter event is modelled by an activity of duration 1
dvar interval a[Enters] size 1;

// each sector is modelled by a resource
cumulFunction r[i in SectorNames] = sum(en in Enters : e[en].sector == i) pulse(a[en], 1);

execute {
  		cp.param.FailLimit = 20000;
}

dexpr int totalDelay = sum(i in Flights) delay[i];

minimize totalDelay;
constraints {

  // the capacity rate is adapted to intervals of 10 minutes;
  // the time scale of a resource is divided by the time step
  forall (i in SectorNames)
      forall (p in periods[i])
         alwaysIn(r[i], (p.start.hours * 60 + p.start.minutes) div timeStep,
                        (p.end.hours * 60 + p.end.minutes) div timeStep,
                           0,
                        (p.rate * timeStep + 59) div 60);


   // a flight enters a sector at its expected time-over plus its delay;
   // since the time scale of a resource is divided by the time step,
   // we do the same for the start time of the activity
   forall (i in Enters)
      startOf(a[i]) == (delay[e[i].flight] + e[i].eto.hours * 60 + e[i].eto.minutes) div timeStep;

   forall(i in SectorNames)
     r[i] <= nbOfFlights;
}

execute {
  writeln("total delay = " + totalDelay);
}
