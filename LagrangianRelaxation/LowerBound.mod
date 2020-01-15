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
 * Lower Bound model to show Lagrangian relaxation
 *********************************************/
int build_limit = ...; 

int nbCities = ...;
range cities = 1..nbCities; 

int send[cities] = ...;
int request[cities] = ...; 
int ship_cost[cities, cities]  = ...; 

float mult[cities] = ...; 

//decision variables 
dvar int Build[cities] in 0..1; 
dvar int Ship[cities,cities] in 0..maxint; 
dexpr float lagrangian_obj = sum(i in cities, j in cities) ship_cost[i,j] * Ship[i,j] 
                    + sum(j in cities) mult[j] * (request[j] - sum(i in cities) Ship[i,j]); 

//constraint names
constraint Supply_Constraint[cities];
constraint Limit_Constraint; 

minimize lagrangian_obj; 
subject to {
   forall(i in cities) 
     Supply_Constraint[i]: sum(j in cities) Ship[i,j] <= send[i] * Build[i]; 
          
   Limit_Constraint= sum(i in cities) Build[i] <= build_limit;     
      
};
