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

// Problem 5 from Model Building in Mathematical Programming, 3rd ed.
//   by HP Williams
// Manpower Planning 
//
//This model is described in the documentation. 
//See IDE and OPL > Language and Interfaces Examples.

{string} Class = ...;

int NbYears = ...;
range Year = 1..NbYears;

float InitialStaff[Class] = ...;
float RequiredStaff[Year][Class] = ...;
float LimRecruit[Class] = ...;

float Retain[Class][Class] = ...;
float RetainRecruit[Class] = ...;

float CostRetrain[Class][Class] = ...;
float LimRetrain[Class][Class] = ...;
float OnjobRetrain[Class][Class] = ...;

float CostRedundant[Class] = ...;

float LimOver = ...;
float CostOver[Class] = ...;

float LimShort = ...;
float TimeShort = ...;
float CostShort[Class] = ...;

float LimRedundancy = ...;
float WeightRedundancy = ...;
float LimCost = ...;
float WeightCost = ...;

range R0 = 0..NbYears;

dvar float+ Staff[Class][R0];
dvar float+ Recruit[c in Class][y in Year] in 0..LimRecruit[c];
dvar float+ Retrain[i in Class][c in Class][y in Year];
dvar float+ Redundant[Class][Year];
dvar float+ StaffShort[Class][Year] in 0..LimShort;
dvar float+ StaffOver[Class][Year];
dvar float+ Cost;
dvar float+ Redundancy;

// Composite objective
minimize
  WeightRedundancy * Redundancy + WeightCost * Cost;

subject to {

  // Continuity
  forall(c in Class, y in Year)
    ctContinuity: Staff[c][y] == Retain[c][c] * Staff[c][y-1] 
                 + RetainRecruit[c] * Recruit[c][y]
                 + sum (i in Class: i!=c) Retain[i][c] * Retrain[i][c][y]
                 - sum (i in Class: i!=c) Retrain[c][i][y]
                 - Redundant[c][y]; 

  // Retraining & downgrading
  // Some retraining has absolute limits
  forall(i in Class, c in Class, y in Year: LimRetrain[i][c] >= 0)
    ctRetrn: Retrain[i][c][y] <= LimRetrain[i][c];

  // Some retraining has variable limits
  forall(i in Class, c in Class, y in Year: OnjobRetrain[i][c] >= 0)
    ctRetvar: Retrain[i][c][y] <= OnjobRetrain[i][c] * Staff[c][y];
      
  // Overmanning
  forall(y in Year)
    ctOverman: sum(c in Class) StaffOver[c][y] <= LimOver;

  // Required staffing
  forall(y in Year, c in Class)
    ctStaffing: Staff[c][y] - StaffOver[c][y] - TimeShort * StaffShort[c][y] == 
       RequiredStaff[y][c];
   
  // Initial conditions
  forall(c in Class)
    ctInitCond: Staff[c][0] == InitialStaff[c]; 

  // Redundancy
  ctRedund1: Redundancy == sum(c in Class, y in Year) Redundant[c,y];
  ctRedund2: Redundancy <= LimRedundancy;

  // Cost
  ctCost1: Cost == sum(c in Class, y in Year) (
            CostRedundant[c] * Redundant[c,y]
          + CostShort[c] * StaffShort[c,y]
          + CostOver[c] * StaffOver[c,y]
          + sum (i in Class) CostRetrain[i,c] * Retrain[i,c,y]); 
  ctCost2: Cost <= LimCost;
}


tuple StaffSolutionT{ 
	string Class; 
	int R; 
	float value; 
};
{StaffSolutionT} StaffSolution = {<i0,i1,Staff[i0][i1]> | i0 in Class,i1 in R0};
tuple RecruitSolutionT{ 
	string Class; 
	int Year; 
	float value; 
};
{RecruitSolutionT} RecruitSolution = {<i0,i1,Recruit[i0][i1]> | i0 in Class,i1 in Year};
tuple RetrainSolutionT{ 
	string Class1; 
	string Class2; 
	int Year; 
	float value; 
};
{RetrainSolutionT} RetrainSolution = {<i0,i1,i2,Retrain[i0][i1][i2]> | i0 in Class,i1 in Class,i2 in Year};
tuple RedundantSolutionT{ 
	string Class; 
	int Year; 
	float value; 
};
{RedundantSolutionT} RedundantSolution = {<i0,i1,Redundant[i0][i1]> | i0 in Class,i1 in Year};
tuple StaffOverSolutionT{ 
	string Class; 
	int Year; 
	float value; 
};
{StaffOverSolutionT} StaffOverSolution = {<i0,i1,StaffOver[i0][i1]> | i0 in Class,i1 in Year};
tuple StaffShortSolutionT{ 
	string Class; 
	int Year; 
	float value; 
};
{StaffShortSolutionT} StaffShortSolution = {<i0,i1,StaffShort[i0][i1]> | i0 in Class,i1 in Year};


main {
  thisOplModel.generate();
      
  var model = thisOplModel;
   
  // Solve for minimal redundancy
  if(cplex.solve()) {
    writeln("Minimal redundancy: ", model.Redundancy.solutionValue, " for unrestricted cost: ", model.Cost.solutionValue)
  } else {
    writeln("No Solution for the 1st model!")
  }
  var minRedundancy = Math.ceil(model.Redundancy.solutionValue);

  //prepare for next solution
  var def = thisOplModel.modelDefinition;
  var data = thisOplModel.dataElements;
  var newCplex = new IloCplex();
  var model1 = new IloOplModel(def,newCplex);
   
  // Solve for minimal cost given minimal redundancy
  data.WeightRedundancy = 0.0;
  data.WeightCost  = 1.0;
  data.LimRedundancy = minRedundancy;
  data.LimCost  = Infinity;
  model1.addDataSource(data);
  model1.generate();
  newCplex.exportModel("first.lp");
  if(newCplex.solve()) {
    writeln("Minimal cost: ", model1.Cost.solutionValue, " for minimal redundancy: ", model1.Redundancy.solutionValue)
  } else {
    writeln("No Solution for the 2nd model!")
  }
   
  //prepare for next solution
  model1.end();
  newCplex.end();
  var newCplex2 = new IloCplex();
  var model2 = new IloOplModel(def,newCplex2);

  // Solve for minimal cost
  data.WeightRedundancy = 0.0;
  data.WeightCost  = 1.0;
  data.LimRedundancy = Infinity;
  data.LimCost  = Infinity;
  model2.addDataSource(data);
  model2.generate();
  newCplex2.exportModel("second.lp");
  if(newCplex2.solve()) {
    writeln("Minimal cost: ", model2.Cost.solutionValue, " for unrestricted redundancy: ", model2.Redundancy.solutionValue)
  } else {
    writeln("No Solution for the 3rd model!")
  }
  var minCost = Math.ceil(model2.Cost.solutionValue);
   
  //prepare for next solution
  model2.end();
  newCplex2.end();
  var newCplex3 = new IloCplex();
  var model3 = new IloOplModel(def,newCplex3);

  // Solve for minimal redundancy given minimal cost
  data.WeightRedundancy = 1.0;
  data.WeightCost  = 0.0;
  data.LimRedundancy = Infinity;
  data.LimCost  = minCost;
  model3.addDataSource(data);
  model3.generate();
  newCplex3.exportModel("third.lp");
  if(newCplex3.solve()) {
	model3.postProcess();
    writeln("Minimal redundancy: ", model3.Redundancy.solutionValue, " for minimal cost: ", model3.Cost.solutionValue)
  } else {
    writeln("No Solution!")
  }  
  model3.end();
}
