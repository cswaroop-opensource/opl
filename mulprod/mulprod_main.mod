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

{string} Products = ...;
{string} Resources = ...;
int NbPeriods = ...;
range Periods = 1..NbPeriods;

float Consumption[Resources][Products] = ...;
float Capacity[Resources] = ...;
float Demand[Products][Periods] = ...;
float InsideCost[Products] = ...;
float OutsideCost[Products]  = ...;
float Inventory[Products]  = ...;
float InvCost[Products]  = ...;

dvar float+ Inside[Products][Periods];
dvar float+ Outside[Products][Periods];
dvar float+ Inv[Products][0..NbPeriods];


execute {
  writeln("* Note: This OPL model is not compliant with cloud execution");
}


minimize
  sum( p in Products , t in Periods ) 
    (InsideCost[p]*Inside[p][t] + 
     OutsideCost[p]*Outside[p][t] +
     InvCost[p]*Inv[p][t]);

subject to {
  forall( r in Resources , t in Periods )
    ctCapacity:
      sum( p in Products ) 
        Consumption[r][p] * Inside[p][t] <= Capacity[r];

  forall( p in Products , t in Periods )
    ctDemand:
      Inv[p][t-1] + Inside[p][t] + Outside[p][t] == 
      Demand[p][t] + Inv[p][t];

  forall( p in Products )
    ctInventory:
      Inv[p][0] == Inventory[p]; 
}

tuple plan {
  float inside;
  float outside;
  float inv;
}

plan Plan[p in Products][t in Periods] = 
  <Inside[p,t],Outside[p,t],Inv[p,t]>;

main {
  var status = 0;
  thisOplModel.generate();

  var produce = thisOplModel;
  var capFlour = produce.Capacity["flour"];

  var best;
  var curr = Infinity;
  var basis = new IloOplCplexBasis();
  var ofile = new IloOplOutputFile("mulprod_main.txt");
  while ( 1 ) {
    best = curr;
    writeln("Solve with capFlour = ",capFlour);
    if ( cplex.solve() ) {
      curr = cplex.getObjValue();
      writeln();
      writeln("OBJECTIVE: ",curr);
      ofile.writeln("Objective with capFlour = ", capFlour, " is ", curr);        
    } 
    else {
      writeln("No solution!");
      break;
    }
    if ( best==curr ) break;

    if ( !basis.getBasis(cplex) ) {
      writeln("warm start preparation failed: ",basis.status);
      break;
    }

    // prepare next iteration
    var def = produce.modelDefinition;
    var data = produce.dataElements;
      
    if ( produce!=thisOplModel ) {
      produce.end();
    }

    produce = new IloOplModel(def,cplex);
    capFlour++;
    data.Capacity["flour"] = capFlour;
    produce.addDataSource(data);
    produce.generate();

    if ( !basis.setBasis(cplex) ) {
      writeln("warm start ",basis.Nrows,"x",basis.Ncols," failed: ",basis.status);
      break;
    }
  }
  basis.end();
  ofile.close();
  if (Math.abs(cplex.getObjValue() - 393.5)>=0.01) {
      status = -1;
  }
  if (best != Infinity) {
    writeln("plan = ",produce.Plan);
  }
  
  if ( produce!=thisOplModel ) {
    produce.end();
  }

  status;
}
