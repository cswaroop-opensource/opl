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
 * LP relaxation model
 *********************************************/

 /* LP relaxation model */ 

int build_limit = ...; 

//import int nbCities;
int nbCities = ...;
range cities = 1..nbCities; 

int send[cities] = ...;
int request[cities] = ...; 
int ship_cost[cities, cities]  = ...; 

// decision variables
dvar float Build[cities] in 0..1; 
dvar float Ship[cities,cities] in 0..maxint;  

dexpr float shipping_obj = sum(i in cities, j in cities) ship_cost[i,j] * Ship[i,j]; 

// constraints
constraint Supply_Constraint[cities];
constraint Demand_Constraint[cities]; 


minimize shipping_obj; 
subject to {
    
  forall(i in cities) { 
    Supply_Constraint[i] : sum(j in cities) Ship[i,j] <= send[i] * Build[i];
  } 
      
  forall(j in cities) { 
    Demand_Constraint[j] : sum(i in cities) Ship[i,j] >= request[j]; 
  }    

  Limit_Constraint : sum(i in cities) Build[i] <= build_limit;     
};
