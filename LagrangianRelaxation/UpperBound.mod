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

/*********************************************
 * Upper bound model to show Lagrangian relaxation 
 *********************************************/
int build_limit = ...; 

int nbCities = ...;
range cities = 1..nbCities; 

int send[cities] = ...;
int request[cities] = ...; 
int ship_cost[cities, cities]  = ...; 

//this data is calculated in the script using result of previous solve
int SBuild[cities] = ...;

//decision variables
dvar int Ship[cities,cities] in 0..maxint; 

dexpr int shipping_obj = sum(i in cities, j in cities) ship_cost[i,j] * Ship[i,j]; 

constraint Supply_Constraint[cities];
constraint Demand_Constraint [cities]; 

minimize shipping_obj; 
subject to {
  forall(i in cities) 
    Supply_Constraint[i]: sum(j in cities) Ship[i,j] <= send[i] * SBuild[i]; 
      
  forall(j in cities) 
    Demand_Constraint[j]: sum(i in cities) Ship[i,j] >= request[j]; 
      
  Limit_Constraint: sum(i in cities) SBuild[i] <= build_limit;    
};
