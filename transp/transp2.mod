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

tuple route { 
  string p; 
  string o; 
  string d; 
}
{route} Routes = ...;
tuple supply { 
  string p; 
  string o; 
}
{supply} Supplies = { <p,o> | <p,o,d> in Routes };
float Supply[Supplies] = ...;
tuple customer { 
  string p; 
  string d; 
}
{customer} Customers = { <p,d> | <p,o,d> in Routes };
float Demand[Customers] = ...;
float Cost[Routes] = ...;

{string} Orig[p in Products] = { o | <p,o,d> in Routes };
{string} Dest[p in Products] = { d | <p,o,d> in Routes };

assert forall(p in Products) 
  sum(o in Orig[p]) 
    Supply[<p,o>] == sum( d in Dest[p] ) Demand[<p,d>];

dvar float+ Trans[Routes];   
constraint ctSupply[Products][Cities];
constraint ctDemand[Products][Cities];

minimize
  sum(l in Routes) Cost[l] * Trans[l];
   
subject to {
  forall( p in Products , o in Orig[p] ) 

    ctSupply[p][o]: 
      sum( d in Dest[p] ) 
        Trans[< p,o,d >] == Supply[<p,o>];
  forall( p in Products , d in Dest[p] )
    ctDemand[p][d]:  
      sum( o in Orig[p] ) 
        Trans[< p,o,d >] == Demand[<p,d>];
  ctCapacity:  forall( o , d in Cities )
                 sum( <p,o,d> in Routes ) 
                   Trans[<p,o,d>] <= Capacity;
}
