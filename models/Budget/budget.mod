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

/*********************************************************************

CAPITAL BUDGETING EXAMPLE 

This model is described in the documentation. 
See IDE and OPL > Language and Interfaces Examples.
   
***********************************************************************/  

int T=...;
int NbMustTakeOne=...;

range Periods = 1..T;

// All projects in the model 
{string} AllProjects = ...;                    

// Subsets of projects; must take one 
{string} MustTakeOne[1..NbMustTakeOne] = ...;  

//Discount rate (interest rate)
float Rate = ...;

// Setup cost of projects 
float SetupCost[AllProjects][Periods] = ...; 

// Rewards (= Revenue - Cost) of projects in each period 
float Reward[AllProjects][Periods] = ...;    

// Minimum balance in each period
float MinBal[Periods]=...;

float InitBal = ...;

// Account balance at the end of each period
dvar float Bal[0..T];

// Selection activities 
dvar boolean doProj[AllProjects][Periods]; // 1 if project is selected to start at time t; 0 otherwise


// Indicate if a project has been selected up to period t
dvar boolean SelectedProj[AllProjects][Periods];


// Maximize the total NPV of selected projects 
dexpr float Objective = 
  Bal[T] /pow(1+Rate,T) - Bal[0];
  
maximize
    Objective;
    
subject to {
   
   // Initial Balanced
   Bal[0] == InitBal;   
   
   // Cash flows balance constraints
   // Current money = Money left from previous period - Cost of selected projects 
   //in current period  +  Rewards of the ongoing projects 
   forall(t in Periods) 
      ctBal: Bal[t] == (1+Rate)*(Bal[t-1] - sum(i in AllProjects) SetupCost[i][t]*doProj[i][t] 
      + sum(i in AllProjects) Reward[i][t]*SelectedProj[i][t]);
   
   // Minimum Balance constraint in each period
   forall(i in Periods) 
      ctMinBal: Bal[i] >= MinBal[i];
   
   // Selected Projects
   forall(i in AllProjects, t in Periods) 
      SelectedProj[i][t] == sum(s in 1..t-1) doProj[i][s];
   
      
   // All project are selected at most once
   forall(i in AllProjects) 
      ctMost: SelectedProj[i][T] <= 1;  
   
   // Must-take-one group -- select one project from the MustTakeOne set 
   forall(i in 1..NbMustTakeOne) 
      ctMust: sum(p in MustTakeOne[i]) SelectedProj[p][T] == 1;
}
