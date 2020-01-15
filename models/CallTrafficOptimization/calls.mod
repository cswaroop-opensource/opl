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
 * ILOG Script for Call Traffic Optimization
 * 
 * The number of hops a call takes affects its quality.  
 * The more hops a call takes, the worse is its quality.  
 * Using this program, we know the maximum number of hops
 * that a call may take in a balanced telecom network. First, we solve 
 * a simple multicommodity flow model to balance the
 * calls throughout a telecom network.  Then, we solve a similar formulation
 * where the number of "hops" is limited.   We increase the number of hops
 * until the solution has the same reserve capacity as the solution from the
 * unlimited problem.  This number is the number of hops the longest call may take.     
 * 
******************************************************************************/


// Network configuration
{string} Hubs = ...;

tuple link {
    string org;
    string dst;
}

tuple market {
    string org;
    string dst;
}

{link} Links = ...;
{market} Markets = ...;


// Capacities and traffic volume
float cap[Links] = ...;
float vol[Markets] = ...;


// Indicators to represent whether a node is supply, sink, or intermediate
int supply[Hubs][Markets];

execute INITIALIZE {
var nb1 = 0;
var nb0 = 0;

    for(var h in Hubs)
      for(var m in Markets)
         if(h == m.org){ 
            supply[h][m] = -1;
            nb1 ++;
          }            
            
            
    for(h in Hubs)
      for(m in Markets)
         if(h == m.dst){ 
            supply[h][m] =  1;
            nb0 ++
          }            
            
    for(h in Hubs)
      for(m in Markets)
         if(h != m.org && h != m.dst) 
            supply[h][m] = 0;
            
            writeln(nb1, " ", nb0);
}


// Variables
dvar float+ traffic[Links][Markets];             // arc traffic
dvar float+ surplus;                             // smallest surplus capacity


// Constraint labels
constraint csv;
constraint arc;



/************************************************************************
 * LINEAR PROGRAMMING MODEL
************************************************************************/

maximize surplus;

subject to {
    // Flow conservation
    // If supply[h,m]=1,  outbound volume for m - inbound volume for m = Volume of the market m
    // If supply[h,m]=-1, inbound volume for m - outbound volume for m= Volume of the market m
    // If supply[h,m]=0, the hub is intermediate 
    //     and inbound volume for m - outbound volume for m = 0 
    csv =
    forall(h in Hubs, m in Markets)
       sum(l in Links: h == l.dst) traffic[l][m]
              - sum (l in Links: h == l.org) traffic[l][m]
              == supply[h][m]*(vol[m]+surplus);
    
    // Arc capacities
    arc =
    forall(l in Links)
       sum(m in Markets) traffic[l][m] <= cap[l];
    
}

main {
   thisOplModel.generate();
  	cplex.exportModel("toto.lp");
   var m = thisOplModel;
   var def = m.modelDefinition;
   var data = m.dataElements;
   
   // System epsilon
   var EPS = 0.0001;
   
   // Simple model
   writeln("Balancing packet volume throughout the network");

   if(cplex.solve()) {
      writeln("Optimal solution has surplus = ", m.surplus.solutionValue);
      var msol = m.surplus.solutionValue;

      // Load hop model and configure for feasibility testing
      cplex.clearModel();
      var source = new IloOplModelSource("hopcalls.mod");
      var defi = new IloOplModelDefinition(source);
      var subcplex = new IloCplex();
      var hop0 = new IloOplModel(defi, subcplex);
	  var hop = hop0;
      var hubsdata = new IloOplDataSource("hubs.dat");
      var marketsdata = new IloOplDataSource("markets.dat");
      var capacitydata = new IloOplDataSource("capacity.dat");
      var volumedata = new IloOplDataSource("volume.dat");
      hop.addDataSource(hubsdata);
      hop.addDataSource(marketsdata);
      hop.addDataSource(capacitydata);
      hop.addDataSource(volumedata);
      var paramsdata = new IloOplDataElements();
      paramsdata.maxHops = 1;
      paramsdata.test = 1;
      hop.addDataSource(paramsdata);
      
      var hdata = hop.dataElements;
      hop.generate();
      var test = 1;
      var maxHops = 1;
      
      writeln("Solving with at most ", maxHops, " hops");
      
      if(test == 1) {
         if(subcplex.solve() &&
           hop.infeas.solutionValue < EPS) { // If the problem is feasible at current Maxhops, test =0;  
            writeln(maxHops, " is feasible; changing to optimization problem");
            test = 0;
            maxHops--;
            
         } else {
            cplex.solve();
            writeln(maxHops, " is infeasible");
         }
      } else {
         writeln("Optimal solution with ", maxHops, " hops has surplus = ", hop.surplus.solutionValue);
      }
      
      // Repeat until the simple and hop models have the same surplus capacity
      writeln("XXXX= ", hop.surplus.solutionValue - msol);
      while(!(Math.abs(hop.surplus.solutionValue - msol) < EPS)) {
         // Increment maxHops
         maxHops++;
         writeln("Solving with at most ", maxHops, " hops and test = ", test);
		 
         // Initialize hop problem
         subcplex.clearModel();
         hdata = hop.dataElements;
         hdata.maxHops = maxHops;
         hdata.test = test;

		 if ( hop!=hop0 ) {
			hop.end();
		 }

         hop = new IloOplModel(defi, subcplex);
         hop.addDataSource(hdata);
         hop.generate();


         if(test == 1) {            
            if(subcplex.solve()) { // If the problem is feasible at current Maxhops, test =0;
            writeln("YYY= ", hop.infeas.solutionValue);
            	if (hop.infeas.solutionValue < EPS){  
               writeln(maxHops, " is feasible; changing to optimization problem");
               test = 0;
               maxHops--;
             }               
            } else {
               writeln(maxHops, " is infeasible");
            }
        
         } else {
            subcplex.solve();
            writeln("Optimal solution with ", maxHops, " hops has surplus = ", hop.surplus.solutionValue);
         }

      }
    
      // Print hop solution; scale to remove surplus capacity
      for(var r in hop.Markets)
         if(hdata.vol[r] > EPS) {
            writeln("Traffic from ", r.org, " to ", r.dst, " = ", hop.vol[r]);
            for(var l in hop.Links) {
               var traffic = 0;
               for(var k in hop.HopLinks) { 
                  if(k.lnk.org == l.org && k.lnk.dst == l.dst) {
                     traffic += hop.traffic[k][r].solutionValue;
                  }
               }
               traffic /= (1+hop.surplus.solutionValue/hdata.vol[r]);
               if(traffic > EPS) {
                  writeln("    ", l.org, "->", l.dst, ":  ", traffic);
               }
               
            }
         }
         
      writeln("DONE: ", hop.surplus.solutionValue, " surplus capacity and at most ", maxHops, " hops");

   } else {
      writeln("No feasible solution exists");
   }
   
   hop0.end();
   subcplex.end();
}
