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

{string} Cities = ...;
{string} Products = ...;
float Capacity = ...;

tuple tableRoutesType { 
  string p; 
  string o; 
  string d; 
  float cost; 
}
{tableRoutesType} TableRoutes = ...;

tuple connection { 
  string o; 
  string d; 
}
tuple route { 
  string p; 
  connection e; 
}
{route} Routes = { < p,<o,d> > | <p,o,d,c> in TableRoutes };
{connection} Connections = { c | <p,c> in Routes };
tuple supply{ 
  string p; 
  string o; 
}
{supply} Supplies = { <p,c.o> | <p,c> in Routes };
float Supply[Supplies] = ...;
tuple customer { 
  string p; 
  string d; 
}
{customer} Customers = { <p,c.d> | <p,c> in Routes };
float Demand[Customers] = ...;

float Cost[Routes] = [ <t.p,<t.o,t.d>>:t.cost | t in TableRoutes ];
/*
// Alternate way to initialize the indexing array 'Cost'
float Cost[Routes];
execute INITIALIZE {
  for( var t in TableRoutes ) {
      Cost[Routes.get(t.p,Connections.get(t.o,t.d))] = t.cost;
   }
}
*/

execute PARAMS {
  cplex.tilim = 100;
}

execute SETTINGS {
  settings.displayComponentName = true;
  settings.displayWidth = 40;
  writeln("Routes: ",Routes);
}

execute DISPLAY {
  function printRoute(r) {
    write("  ",r.p,":");
    writeln(r.e.o,"->",r.e.d);
  }

  writeln("Routes:");
  for (var r in Routes) {
    printRoute(r);
  }
}
{string} Orig[p in Products] = { c.o | <p,c> in Routes };
{string} Dest[p in Products] = { c.d | <p,c> in Routes };

{connection} CPs[p in Products] = { c | <p,c> in Routes };

assert forall( p in Products ) 
  sum( o in Orig[p] ) 
    Supply[<p,o>] == sum( d in Dest[p] ) Demand[<p,d>];

dvar float+ Trans[Routes];   

constraint ctSupply[Products][Cities];
constraint ctDemand[Products][Cities];

minimize
  sum( l in Routes ) Cost[l] * Trans[l];
   
subject to {
  forall( p in Products , o in Orig[p] ) 
      ctSupply[p][o]: 
        sum( <o,d> in CPs[p] ) 
          Trans[< p,<o,d> >] == Supply[<p,o>];
    forall( p in Products , d in Dest[p] ) 
      ctDemand[p][d]:  
        sum( <o,d> in CPs[p] ) 
          Trans[< p,<o,d> >] == Demand[<p,d>];
    forall( c in Connections )
      ctCapacity:
        sum( <p,c> in Routes ) 
          Trans[<p,c>] <= Capacity;
}


