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
 * OPL Model for Investment Portfolio Problem
 * 
 * Charles H. Rosa

 * This model is described in the documentation. 
 * See IDE and OPL > Language and Interfaces Examples.
 * 
******************************************************************************/

{string} Investments = ...;
float Return[Investments] = ...;
float Covariance[Investments][Investments] = ...;
float Wealth = ...;
float Rho = ...;  // Variance Penalty (increasing rho from 0.001 to 1.0 
                  //                   produces a distribution of funds 
                  //                   with smaller and smaller variability).

/******************************************************************************
 * MODEL DECLARATIONS
 ******************************************************************************/

range float FloatRange = 0.0..Wealth;

dvar float  Allocation[Investments] in FloatRange;  // Investment Level


/******************************************************************************
 * MODEL
 ******************************************************************************/

dexpr float Objective =
  (sum(i in Investments) Return[i]*Allocation[i])
    - (Rho/2)*(sum(i,j in Investments) Covariance[i][j]*Allocation[i]*Allocation[j]);

maximize Objective;

subject to {
  // sum of allocations equals amount to be invested
  allocate: (sum (i in Investments) (Allocation[i])) == Wealth;
}

tuple AllocationSolutionT{ 
	string Investments; 
	float value; 
};
{AllocationSolutionT} AllocationSolution = {<i0,Allocation[i0]> | i0 in Investments};


float TotalReturn = sum(i in Investments) Return[i]*Allocation[i];
float TotalVariance = sum(i,j in Investments) Covariance[i][j]*Allocation[i]*Allocation[j];

execute DISPLAY {
  writeln("Total Expected Return: ", TotalReturn);
  writeln("Total Variance       : ", TotalVariance);
}
