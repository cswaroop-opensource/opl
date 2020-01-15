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
 OPL Model for Call Traffic Optimization (Hop Version)
  
 This builds upon the simple version by adding an additional subscript for
 the number of hops each packet travels.  
  
 The data indicator "test" controls whether the model solves a feasibility or optimization 
 problem.  The data "maxHops" controls the maximum number of hops that can be used.
 An artificial variable "infeas" indicates how much more capacity required on every arc 
 to maintain feasible flows at the current "Maxhops", if the program is in the mode of 
 testing feasibility ("test "=1). If the program is in optimization mode, namely, 
 test =0, "infeas" has no effect and the program solves the problem with 
 the original arc capacities.  

******************************************************************************/


// Basic network configuration
{string} Hubs = ...;

tuple link {
    string    org;
    string    dst;
}

tuple market {
    string    org;
    string    dst;
}

{link} Links = ...;
{market} Markets = ...;


// Capacities and traffic volume
float cap[Links] = ...;
float vol[Markets] = ...;


// Hop Network configuration
int maxHops = ...;

tuple hoplink {
    int     hop;
    link    lnk;
}

tuple hophub {
    int     hop;
    string  hub;
}

// Initialize HopLinks and HopHubs implicitly from Links and Hubs.
// Note that the HopLinks must include single period delays and that the
// HopHubs start at time 0.

{hoplink} temp1 =
     { <n, <l.org,l.dst>> | l in Links, n in 1..maxHops};

{hoplink} temp2 =
     { <n, <h,h>> | h in Hubs, n in 1..maxHops};

{hoplink} HopLinks = temp1 union temp2;        
    
{hophub}  HopHubs = 
    { <n,h> | h in Hubs, n in 0..maxHops };


// Indicators to represent whether a node is supply, sink, or intermediate
int supply[HopHubs][Markets];


execute INITIALIZE {
   if(maxHops == 0) {
      writeln("maxHops has not been defined");
   } else {
      for(var h in HopHubs)
         for(var m in Markets)
            if(h.hub == m.org && h.hop == 0)
               supply[h][m] = -1;
            
      for(h in HopHubs)
         for(m in Markets)
            if(h.hub == m.dst && h.hop == maxHops)
               supply[h][m] = 1;
            
      for(h in HopHubs)
         for(m in Markets)
            if( (h.hub != m.org && h.hop == 0) ||
                (h.hub != m.dst && h.hop == maxHops) ||
                (0 < h.hop && h.hop < maxHops) )
               supply[h][m] = 0;
   }
}


// Indicator to toggle between infeasibility testing and optimization
int test = ...;


// Variables
dvar float+ traffic[HopLinks][Markets];          // arc traffic
dvar float+ surplus;                             // smallest surplus capacity
dvar float+ infeas;                              // arc infeasibility adder

// Constraint labels
constraint csv;
constraint arc[Links];



/************************************************************************
 * LINEAR PROGRAMMING MODEL
************************************************************************/

maximize  (1-test)*surplus - test*infeas;

subject to {
    // Flow conservation
    // flows in at this hop - flows out at the next hop = the demand at this hub
    csv =
    forall(h in HopHubs, m in Markets)
          sum(l in HopLinks: l.lnk.dst == h.hub && l.hop == h.hop)
            traffic[l][m]
        - sum(l in HopLinks: l.lnk.org == h.hub && l.hop == (h.hop+1))
            traffic[l][m]
            == supply[h][m]*(vol[m] + surplus);

    // Arc capacities
    forall(k in Links)
       arc[k] =
          sum(l in HopLinks, m in Markets: l.lnk.org == k.org && l.lnk.dst == k.dst)
            traffic[l][m] <= cap[k] + test*infeas;
}

// Display the surplus and the nondegenerate dual variables; ignored by the script in calls.mod
execute DISPLAY {
   writeln("surplus = ", surplus);
   for(k in Links)
      if(arc[k].slack == 0 && (Math.abs(arc[k].dual) > 0.0001)) 
         writeln("cap[", k, "] = ", cap[k]);
}
