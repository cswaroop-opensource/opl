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
 * OPL Model for Airline Yield Management
 * Stochastic formulation
 * 
 *
 * This model implements the example of Yield Management 
 * from "Model Building in Mathematical Programming"
 * by H. Paul Williams 
 *
******************************************************************************/

// Data
//=======

// Seat classes available in the plane
// 10% of seats from a class can be transferred to an adjacent class.
{string} classes = {"First", "Business", "Economy"};
int capacity[classes] = [37, 38, 47];

// Planned periods 
range periods = 1..3;

// 3 scenarios are studied with their corresponding probability
range scenarios = 1..3;
float probaScenarios[scenarios] = [0.1, 0.7, 0.2];

// 3 pricing options for each class and period
range options = 1..3;
int priceOptions[periods][classes][options] = ...;

// Demands given by analytics for each period, scenario, class and price option
int demand[periods][scenarios][classes][options] = ...;

int planeBookPrice = ...;

// Decision variables
//=====================

// Boolean variables for each period and each class on selected price option
dvar boolean PriceLevel1[classes][options];
dvar boolean PriceLevel2[scenarios][classes][options];
dvar boolean PriceLevel3[scenarios][scenarios][classes][options];

// Number of seats 
dvar float+ Seats1[scenarios][classes][options]; // seats sold in wk 1 for scenario s, class c, price option o 
dvar float+ Seats2[scenarios][scenarios][classes][options]; // seats sold in wk 2 for scenario s1 for wk1, s2 for wk2, class c, price option o
dvar float+ Seats3[scenarios][scenarios][scenarios][classes][options]; //seats sold in wk 3 for scenario s1 for wk1, s2 for wk2, s3 for wk3, class c, price option o 

// Slack and Excess of capacity per class
dvar int+ U[scenarios][scenarios][scenarios][classes];
dvar int+ V[scenarios][scenarios][scenarios][classes];

// Number of planes to book (up to 6)
dvar int NbPlanes in 1..6; 

dvar int Revenue1[s1 in scenarios][c in classes][o in options] ;
dvar int Revenue2[s1 in scenarios][s2 in scenarios][c in classes][o in options] ;
dvar int Revenue3[s1 in scenarios][s2 in scenarios][s3 in scenarios][c in classes][o in options];

  
// Objective
//============ 
dexpr float revenue1 = sum (s1 in scenarios,c in classes, o in options) probaScenarios[s1]*Revenue1[s1][c][o];
dexpr float revenue2 = sum(s1,s2 in scenarios,c in classes, o in options) probaScenarios[s1]*probaScenarios[s2]*Revenue2[s1][s2][c][o];
dexpr float revenue3 = sum(s1,s2,s3 in scenarios,c in classes, o in options) probaScenarios[s1]*probaScenarios[s2]*probaScenarios[s3]*Revenue3[s1][s2][s3][c][o];
dexpr float planeCost = planeBookPrice * NbPlanes;

dexpr float totalObj = revenue1 + revenue2 + revenue3 - planeCost;
 
maximize revenue1 + revenue2 + revenue3 - planeCost;

subject to {
   // linearization 
   forall (s1 in scenarios, c in classes, o in options) {
      Revenue1[s1][c][o] - priceOptions[1][c][o]*Seats1[s1][c][o] <= 0;
      priceOptions[1][c][o]*Seats1[s1][c][o] - Revenue1[s1][c][o] + priceOptions[1][c][o]*demand[1][s1][c][o]*PriceLevel1[c][o] <= priceOptions[1][c][o]*demand[1][s1][c][o]; 
   }
   forall (s1,s2 in scenarios, c in classes, o in options) {
      Revenue2[s1][s2][c][o] - priceOptions[2][c][o]*Seats2[s1][s2][c][o] <= 0;
      priceOptions[2][c][o]*Seats2[s1][s2][c][o] - Revenue2[s1][s2][c][o] + priceOptions[2][c][o]*demand[2][s2][c][o]*PriceLevel2[s1][c][o] <= priceOptions[2][c][o]*demand[2][s2][c][o]; 
   }
   forall (s1,s2,s3 in scenarios, c in classes, o in options) {
      Revenue3[s1][s2][s3][c][o] - priceOptions[3][c][o]*Seats3[s1][s2][s3][c][o] <= 0;
      priceOptions[3][c][o]*Seats3[s1][s2][s3][c][o] - Revenue3[s1][s2][s3][c][o] + priceOptions[3][c][o]*demand[3][s3][c][o]*PriceLevel3[s1][s2][c][o] <= priceOptions[3][c][o]*demand[3][s3][c][o]; 
   }

   // At each period, and for each class, only one price option is selected.
   forall(c in classes) 
      sum (o in options) PriceLevel1[c][o] == 1;
   forall (c in classes, s1 in scenarios) 
      sum (o in options) PriceLevel2[s1][c][o] == 1;
   forall (c in classes, s1,s2 in scenarios) 
      sum (o in options) PriceLevel3[s1][s2][c][o] == 1;
 
   // Seat Capacity  
   forall(s1,s2,s3 in scenarios, c in classes) 
      ctSeatCapacities: 
         sum (o in options) (Seats1[s1][c][o] + Seats2[s1][s2][c][o] + Seats3[s1][s2][s3][c][o]) 
         <= capacity[c]*NbPlanes + U[s1][s2][s3][c] - V[s1][s2][s3][c];  
   forall(s1,s2,s3 in scenarios, c in classes) {
      U[s1][s2][s3][c] <= 0.1*capacity[c];
      V[s1][s2][s3][c] <= 0.1*capacity[c];
   }
   forall(s1,s2,s3 in scenarios)
     sum (c in classes) (U[s1][s2][s3][c] - V[s1][s2][s3][c]) == 0;
     
   // Number of seats sold is lower than demand at each period    
   forall (s1 in scenarios, c in classes, o in options)
      ctDemand1: Seats1[s1][c][o] <= demand[1][s1][c][o]*PriceLevel1[c][o];    
   forall (s1,s2 in scenarios, c in classes, o in options)
      ctDemand2: Seats2[s1][s2][c][o] <= demand[2][s2][c][o]*PriceLevel2[s1][c][o];  
   forall (s1,s2,s3 in scenarios, c in classes, o in options)
      ctDemand3: Seats3[s1][s2][s3][c][o] <= demand[3][s3][c][o]*PriceLevel3[s1][s2][c][o];  

};


tuple Revenue1SolutionT{ 
	int scenarios; 
	string classes; 
	int options; 
	int value; 
};
{Revenue1SolutionT} Revenue1Solution = {<i0,i1,i2,Revenue1[i0][i1][i2]> | i0 in scenarios,i1 in classes,i2 in options};
tuple Revenue2SolutionT{ 
	int scenarios1; 
	int scenarios2; 
	string classes; 
	int options; 
	int value; 
};
{Revenue2SolutionT} Revenue2Solution = {<i0,i1,i2,i3,Revenue2[i0][i1][i2][i3]> | i0 in scenarios,i1 in scenarios,i2 in classes,i3 in options};
tuple Revenue3SolutionT{ 
	int scenarios1; 
	int scenarios2; 
	int scenarios3; 
	string classes; 
	int options; 
	int value; 
};
{Revenue3SolutionT} Revenue3Solution = {<i0,i1,i2,i3,i4,Revenue3[i0][i1][i2][i3][i4]> | i0 in scenarios,i1 in scenarios,i2 in scenarios,i3 in classes,i4 in options};
tuple Seats1SolutionT{ 
	int scenarios; 
	string classes; 
	int options; 
	float value; 
};
{Seats1SolutionT} Seats1Solution = {<i0,i1,i2,Seats1[i0][i1][i2]> | i0 in scenarios,i1 in classes,i2 in options};
tuple PriceLevel1SolutionT{ 
	string classes; 
	int options; 
	int value; 
};
{PriceLevel1SolutionT} PriceLevel1Solution = {<i0,i1,PriceLevel1[i0][i1]> | i0 in classes,i1 in options};
tuple Seats2SolutionT{ 
	int scenarios1; 
	int scenarios2; 
	string classes; 
	int options; 
	float value; 
};
{Seats2SolutionT} Seats2Solution = {<i0,i1,i2,i3,Seats2[i0][i1][i2][i3]> | i0 in scenarios,i1 in scenarios,i2 in classes,i3 in options};
tuple PriceLevel2SolutionT{ 
	int scenarios; 
	string classes; 
	int options; 
	int value; 
};
{PriceLevel2SolutionT} PriceLevel2Solution = {<i0,i1,i2,PriceLevel2[i0][i1][i2]> | i0 in scenarios,i1 in classes,i2 in options};
tuple Seats3SolutionT{ 
	int scenarios1; 
	int scenarios2; 
	int scenarios3; 
	string classes; 
	int options; 
	float value; 
};
{Seats3SolutionT} Seats3Solution = {<i0,i1,i2,i3,i4,Seats3[i0][i1][i2][i3][i4]> | i0 in scenarios,i1 in scenarios,i2 in scenarios,i3 in classes,i4 in options};
tuple PriceLevel3SolutionT{ 
	int scenarios1; 
	int scenarios2; 
	string classes; 
	int options; 
	int value; 
};
{PriceLevel3SolutionT} PriceLevel3Solution = {<i0,i1,i2,i3,PriceLevel3[i0][i1][i2][i3]> | i0 in scenarios,i1 in scenarios,i2 in classes,i3 in options};
tuple USolutionT{ 
	int scenarios1; 
	int scenarios2; 
	int scenarios3; 
	string classes; 
	int value; 
};
{USolutionT} USolution = {<i0,i1,i2,i3,U[i0][i1][i2][i3]> | i0 in scenarios,i1 in scenarios,i2 in scenarios,i3 in classes};
tuple VSolutionT{ 
	int scenarios1; 
	int scenarios2; 
	int scenarios3; 
	string classes; 
	int value; 
};
{VSolutionT} VSolution = {<i0,i1,i2,i3,V[i0][i1][i2][i3]> | i0 in scenarios,i1 in scenarios,i2 in scenarios,i3 in classes};


execute DISPLAY_RESULTS {
  writeln("(Provisionally) book ", NbPlanes, " planes");
  writeln("expected profit = ", totalObj);  
};
       
    
    
