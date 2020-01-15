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
******************************************************************************/

{string} Investments = ...;
float InvestReturn[Investments] = ...;
float  Covariance[Investments][Investments] = ...;
float Wealth = ...;
float EpsilonTolerance = ...;
float rho = ...;
float BigNumber = ...;

tuple t_BendersReturn {
  string inv;
  int id;
  float br;
}
{t_BendersReturn} BendersReturns = ...;


 
tuple t_RHS {
  int id;
  float rhs;
}
{t_RHS} RHSset = ...;

int lowcut = 1;
int highcut = card(RHSset);

range CutRange = lowcut..highcut;
float RHS[CutRange];
execute {
  for (var r in RHSset)
    RHS[r.id] = r.rhs;
}
   
/******************************************************************************
 * MODEL DECLARATIONS
 ******************************************************************************/

range float FloatRange = 0.0..Wealth;

dvar float   alpha;
dvar float  allocation[Investments] in FloatRange;  // Investment Level

constraint allocate;
constraint cuts[CutRange];

/******************************************************************************
 * MODEL
 ******************************************************************************/

maximize
    alpha;

subject to {
    allocate =
          (sum (i in Investments) (allocation[i])) == Wealth ;
   
    forall(b in CutRange)
      cuts[b]=
          alpha <=  RHS[b] + sum (inv in Investments) (sum(<inv,b,br> in BendersReturns) br)*allocation[inv];

};


float Objective = sum(i in Investments) (InvestReturn[i]*allocation[i]
                          - (1 div 2)*rho*(allocation[i]*(sum (j in Investments) Covariance[i][j]*allocation[j])));
                          
execute {
  Objective;
}                          
                          
