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

// Problem 7 from Model Building in Mathematical Programming, 3rd ed.
//   by HP Williams
// 
// Mining 
//
// This model is described in the documentation. 
//See IDE and OPL > Language and Interfaces Examples.

int NbMines = ...;
range Mines = 1..NbMines;

int NbYears = ...;
range Years = 1..NbYears;
range Years2 = 2..NbYears;

float Royalties[Mines] = ...;
float LimExtract[Mines] = ...;
float LimWork = ...;
float OreQual[Mines] = ...;
float BlendQual[Years] = ...;
float BlendPrice = ...;
float DiscountRate = ...;
float DiscountFactor[Years];

execute INITIALIZE {
   DiscountFactor[1] = 1.0;
   for(var y in Years2)
      DiscountFactor[y] = DiscountFactor[y-1]*(1.0-DiscountRate);
}
                           
dvar boolean Work[Mines,Years];
dvar boolean Open[Mines,Years];
dvar float+ Ore[m in Mines][y in Years] in 0..LimExtract[m];
dvar float+ Blend[Years];

dexpr float Objective = 
  sum(y in Years) (BlendPrice * DiscountFactor[y] * Blend[y]  
   - sum(m in Mines) Royalties[m] * DiscountFactor[y] * Open[m][y]);

maximize Objective;

subject to {
  // Maximum yearly capacity 
  forall(m in Mines, y in Years)
   ctMaxYearCap: Ore[m][y] <= LimExtract[m] * Work[m][y];

  // Limit on mines worked in a year
  forall(y in Years)
    ctMinLim: sum(m in Mines) Work[m][y] <= LimWork;

  // Closed mines cannot be worked
  forall(m in Mines, y in Years)
    ctClosedMine: Work[m][y] <= Open[m][y];
   
  // Once closed, a mine stays closed
  forall(m in Mines, y in 1..NbYears-1)
    ctStaysClosed: Open[m][y+1] <= Open[m][y];
 
  // Quality requirement on blended ore
  forall(y in Years)
    ctQuality: sum(m in Mines) OreQual[m] * Ore[m][y] == BlendQual[y] * Blend[y];

  // Balance constraint
  forall(y in Years)
    ctBalance: sum(m in Mines) Ore[m][y] == Blend[y];
     
  Work[2][3]==0;
  Work[1][2]==0;
  Work[2][1]==0;
  Work[4][4]==1;
  Work[4][3]==0;
  Work[3][4]==0;
  Work[4][5]==0;
}


tuple BlendSolutionT{ 
	int Years; 
	float value; 
};
{BlendSolutionT} BlendSolution = {<i0,Blend[i0]> | i0 in Years};
tuple OpenSolutionT{ 
	int Mines; 
	int Years; 
	int value; 
};
{OpenSolutionT} OpenSolution = {<i0,i1,Open[i0][i1]> | i0 in Mines,i1 in Years};
tuple OreSolutionT{ 
	int Mines; 
	int Years; 
	float value; 
};
{OreSolutionT} OreSolution = {<i0,i1,Ore[i0][i1]> | i0 in Mines,i1 in Years};
tuple WorkSolutionT{ 
	int Mines; 
	int Years; 
	int value; 
};
{WorkSolutionT} WorkSolution = {<i0,i1,Work[i0][i1]> | i0 in Mines,i1 in Years};

