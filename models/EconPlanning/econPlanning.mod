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

// Problem 9 from Model Building in Mathematical Programming, 3rd ed.
//   by HP Williams
// Economic Planning 
// 
//This model is described in the documentation. 
//See IDE and OPL > Language and Interfaces Examples.

{string} Ind = ...;

int NbYears = ...;
range Years = 1..NbYears;

float Input_output[Ind][Ind] = ...;
float Input_addcap[Ind][Ind] = ...;
float Exdem[Ind] = ...;
float Manpower_out[Ind] = ...;
float Manpower_cap[Ind] = ...;
float LimManpower = ...;
float InitCap[Ind] = ...;
float InitStock[Ind] = ...;
float InputStatic[Ind] = ...;
int  Obj1 = 0;
int  Obj2 = 0;
int  Obj3 = 1;

range R = 1..NbYears+2;
range R1= 0..NbYears;

dvar float+ Output[i in Ind][y in R];
dvar float+ Stock[i in Ind][y in R];
dvar float+ Addcap[Ind][R];
dvar float+ Cap[Ind][Years];
dvar float+ ManpowerUsed[R1];


maximize
  Obj1 * (sum(i in Ind) Cap[i][NbYears]) +
  Obj2 * (sum(i in Ind, y in 4..5) Output[i][y]) +  
  Obj3 * (sum(y in Years) ManpowerUsed[y]);

subject to {
  // Year 0
  forall(i in Ind){
    sum(j in Ind) Input_output[i][j] * Output[j][1]
      + sum(j in Ind) Input_addcap[i][j] * Addcap[j][2]
        <= InitStock[i] - Stock[i][1];
    Output[i][1]<=InitCap[i];
  };

  // Total output
  forall(i in Ind, y in Years)
    sum(j in Ind) Input_output[i][j] * Output[j][y+1]
      + sum(j in Ind) Input_addcap[i][j] * Addcap[j][y+2]
        <= Output[i][y] + Stock[i][y] - Stock[i][y+1] - Exdem[i] * (1-Obj2);

  // Manpower
  forall(y in 0..NbYears)
    sum(j in Ind) Manpower_out[j] * Output[j][y+1]
      + sum(j in Ind) Manpower_cap[j] * Addcap[j][y+2] 
        == ManpowerUsed[y];
         
  if ( Obj3 < 1 ) {
    forall(y in 0..NbYears)
       ManpowerUsed[y] <= LimManpower;
  };

  // Productive capacity
  forall(i in Ind, y in Years) {
    Cap[i][y] == InitCap[i] + sum(k in Years: k <= y) Addcap[i][k]; 
    Output[i][y] <= Cap[i][y]; 
  };
   

  // Initial stocks
  forall(i in Ind) {     
    Addcap[i][1] == 0.0;
  }; 
  
  // Horizon conditions
  forall(i in Ind) {
    Output[i][NbYears+1] >= InputStatic[i];
    Output[i][NbYears+2] >= InputStatic[i];
    Addcap[i][NbYears+1] == 0.00;
    Addcap[i][NbYears+2] == 0.0;
  };

};


tuple CapSolutionT{ 
	string Ind; 
	int Years; 
	float value; 
};
{CapSolutionT} CapSolution = {<i0,i1,Cap[i0][i1]> | i0 in Ind,i1 in Years};
tuple OutputSolutionT{ 
	string Ind; 
	int R; 
	float value; 
};
{OutputSolutionT} OutputSolution = {<i0,i1,Output[i0][i1]> | i0 in Ind,i1 in R};
tuple ManpowerUsedSolutionT{ 
	int R1; 
	float value; 
};
{ManpowerUsedSolutionT} ManpowerUsedSolution = {<i0,ManpowerUsed[i0]> | i0 in R1};
tuple AddcapSolutionT{ 
	string Ind; 
	int R; 
	float value; 
};
{AddcapSolutionT} AddcapSolution = {<i0,i1,Addcap[i0][i1]> | i0 in Ind,i1 in R};
tuple StockSolutionT{ 
	string Ind; 
	int R; 
	float value; 
};
{StockSolutionT} StockSolution = {<i0,i1,Stock[i0][i1]> | i0 in Ind,i1 in R};
