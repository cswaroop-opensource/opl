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

{string} Cities =...;
{string} Products = ...;
float Capacity = ...;

float Supply[Products][Cities] = ...;
float Demand[Products][Cities] = ...;
assert
  forall(p in Products)
    sum(o in Cities) Supply[p][o] == sum(d in Cities) Demand[p][d];
float Cost[Products][Cities][Cities] = ...;

dvar float+ Trans[Products][Cities][Cities];


minimize
  sum( p in Products , o , d in Cities ) 
    Cost[p][o][d] * Trans[p][o][d];
   
subject to {
  forall( p in Products , o in Cities )
    ctSupply:  
      sum( d in Cities ) 
        Trans[p][o][d] == Supply[p][o];
  forall( p in Products , d in Cities ) 
    ctDemand:
      sum( o in Cities ) 
        Trans[p][o][d] == Demand[p][d];
   forall( o , d in Cities )
     ctCapacity:
       sum( p in Products ) 
         Trans[p][o][d] <= Capacity;
}  

execute DISPLAY {
  writeln("trans = ",Trans);
}


tuple solutionT{
	string Products;
	string City1;
	string City2;
	float Trans;	
};
{solutionT} solution = {<p,c1,c2, Trans[p][c1][c2]> | p in Products, c1 in Cities, c2 in Cities: Trans[p][c1][c2] != 0};

