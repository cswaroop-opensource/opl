// --------------------------------------------------------------------------
// Licensed Materials - Property of IBM
//
// 5725-A06 5725-A29 5724-Y48 5724-Y49 5724-Y54 5724-Y55
// Copyright IBM Corporation 1998, 2014. All Rights Reserved.
//
// Note to U.S. Government Users Restricted Rights:
// Use, duplication or disclosure restricted by GSA ADP Schedule
// Contract with IBM Corp.
// --------------------------------------------------------------------------


//
// For a description of the problem and resolution methods:
//
//    The Progressive Party Problem: Integer Linear Programming
//    and Constraint Programming Compared
//
//    Proceedings of the First International Conference on Principles
//    and Practice of Constraint Programming table of contents
//
//    Lecture Notes In Computer Science; Vol. 976, pages 36-52, 1995
//    ISBN:3-540-60299-2
//

// This model is greater than the size allowed in trial mode. 
// You therefore need a commercial edition of CPLEX Studio to run this example.
// If you are a student or teacher, you can also get a full version through
// the IBM Academic Initiative.

using CP;

int numBoats = ...;
range Boats = 0..numBoats - 1;
int boatSize[Boats] = ...;
int crewSize[Boats] = ...;

int numPeriods = 6;
range Periods = 0..numPeriods - 1;

dvar boolean host[Boats];
dvar int goWhere[Periods][Boats] in Boats;
dvar int+ load[Periods][Boats];

dexpr int numHosts = sum (b in Boats) host[b];

minimize numHosts;

subject to {
   // Capacity of hosts, non-hosts have zero capacity
   forall (b in Boats, p in Periods)
     load[p][b] <= host[b] * boatSize[b];
   
   // Capacities respected
   forall (p in Periods)
     pack(all (b in Boats) load[p][b], all (b in Boats) goWhere[p][b], crewSize, numHosts);   

   // Hosts are always in their boat, guests are never in their boat
   forall (b in Boats)
     count(all(p in Periods) goWhere[p][b], b) == host[b] * numPeriods;
     
   // No two crews meet more than once
   forall (b1, b2 in Boats : b1 < b2)
     sum (p in Periods) (goWhere[p][b1] == goWhere[p][b2]) <= 1;
   
   // Asserted hosts and guests (in spec)
   host[0] == true;
   host[1] == true;
   host[2] == true;
   host[39] == false;
   host[40] == false;
   host[41] == false;
}

tuple hostSolutionT{ 
	int Boats; 
	int value; 
};
{hostSolutionT} hostSolution = {<i0,host[i0]> | i0 in Boats};
tuple loadSolutionT{ 
	int Periods; 
	int Boats; 
	int value; 
};
{loadSolutionT} loadSolution = {<i0,i1,load[i0][i1]> | i0 in Periods,i1 in Boats};
tuple goWhereSolutionT{ 
	int Periods; 
	int Boats; 
	int value; 
};
{goWhereSolutionT} goWhereSolution = {<i0,i1,goWhere[i0][i1]> | i0 in Periods,i1 in Boats};


