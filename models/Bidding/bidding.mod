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

/*******************************************************************
 OPL Model for CONTRACT BIDDING 

This model is described in the documentation. 
See IDE and OPL > Language and Interfaces Examples.
 
 *******************************************************************/


// DATA
// Custom data structures
tuple task {
  key string  bid;
  key string  task;
  float   price;
  int     option;
}

tuple bid {
  string  bid;
  string  task;
}


tuple penalty {
   key string task;
   float  cost;
}

// Basic data
{task}   TaskSet = ...;    // Bids for tasks
{string}    Tasks=... ;       // All tasks
{penalty}   TaskPenalty=...;  // Penalty for unassigned tasks. 
                              //If cost is -1, it means it must be assigned.

// Inferred sets

  // Set of <bids, task> pairs; 
  // If task ="REQD", it means that all tasks are mandatory for the bid; 
  // if task=a task name, it means the task is optional.
{bid}    Bids = {<t.bid, "REQD"> | t in TaskSet : t.option == 0} union 
                   {<t.bid, t.task> | t in TaskSet : t.option == 1};

                     
  // Set of all bids including task u; "REQD" indicates u is mandatory for the bid
{bid}    BidTasks[u in Tasks] = {<t.bid, "REQD"> | t in TaskSet : t.option == 0 && t.task == u} union 
                                   {<t.bid, t.task> | t in TaskSet : t.option == 1 && t.task == u};

// Inferred data

float BidCost[<b,t> in Bids] =
   sum (<b,t,price,opt> in TaskSet) price +
   sum (<b,t2,price,opt> in TaskSet : t == "REQD" && opt == 0) price;


assert sum (b in Bids) BidCost[b] >= 0;


float MaxBidCost = max (b in Bids) BidCost[b];
float Penalty[Tasks] = 
  [ t.task: (t.cost==-1) ? 1+MaxBidCost : t.cost | t in TaskPenalty];


// Decision variables
dvar boolean Award[Bids]; // 1 if the bid is awarded; 0 otherwise
dvar boolean Avoid[Tasks]; // 1 if the task is not assigned; 0 otherwise

// Objective value = cost of accepted bids + penalty for unassigned tasks
dexpr float AcceptedBidsCost =
  sum (b in Bids) BidCost[b]*Award[b];
dexpr float UnassignedTaskPenaltyCost = 
  sum (t in Tasks) Penalty[t]*Avoid[t];


// MODEL
minimize AcceptedBidsCost +UnassignedTaskPenaltyCost;
subject to {    
  // Assignment constraint: each task must be assigned to a bid
  forall (t in Tasks)
    ctAssign: sum (b in BidTasks[t]) Award[b] == 1 - Avoid[t];
       
  
}

tuple AwardSolutionT{ 
bid Bids; 	int value; 
};
{AwardSolutionT} AwardSolution = {<i0,Award[i0]> | i0 in Bids};
tuple AvoidSolutionT{ 
	string Tasks; 
	int value; 
};
{AvoidSolutionT} AvoidSolution = {<i0,Avoid[i0]> | i0 in Tasks};


// POST-PROCESSING
{bid} Awarded = {<t.bid, t.task> | t in TaskSet :
  (t.option == 0 && Award[<t.bid, "REQD">] == 1) ||
  (t.option == 1 && Award[<t.bid, t.task>] == 1)};
{string} Avoided = {t | t in Tasks : Avoid[t] == 1};
int TotalAvoided = sum (t in Tasks) Avoid[t];

execute DISPLAY {
   writeln("Award = ", Award);
   writeln("Awarded = ", Awarded);
   writeln("Avoided = ", Avoided);
   writeln("TotalAvoided = ", TotalAvoided);
   for (var b in Bids) {
      writeln(b,  " ", BidCost[b]);
   }
}
