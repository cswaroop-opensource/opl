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

//
// This example is inspired from the talent hold cost scheduling problem
// described in:
//
// T.C.E Cheng, J. Diamond, B.M.T. Lin.  Optimal scheduling in film
// production to minimize talent holding cost.  Journal of Optimization
// Theory and Applications, 79:197-206, 1993.
//
// of which the 'Rehearsal problem' is a specific case:
//
// Barbara M. Smith.  Constraint Programming In Practice: Scheduling
//                    a Rehearsal.  Report APES-67-2003, September 2003.
// 
// See: http://www.csplib.org/Problems/prob039/
//



using CP;

execute{
	}
int numActors = ...;
range Actors = 1..numActors;
int actorPay[Actors] = ...;
int numScenes = ...;
range Scenes = 1..numScenes;
int sceneDuration[Scenes] = ...;

int actorInScene[Actors][Scenes]  = ...;

dvar int scene[Scenes] in Scenes;
dvar int slot[Scenes] in Scenes;


// First and last slots where each actor plays
dexpr int firstSlot[a in Actors] = min(s in Scenes:actorInScene[a][s] == 1) slot[s];
dexpr int lastSlot[a in Actors] = max(s in Scenes:actorInScene[a][s] == 1) slot[s];

// Expression for the waiting time for each actor
dexpr int actorWait[a in Actors] = sum(s in Scenes: actorInScene[a][s] == 0)  
   (sceneDuration[s] * (firstSlot[a] <= slot[s] && slot[s] <= lastSlot[a]));

// Expression representing the global cost
dexpr int idleCost = sum(a in Actors) actorPay[a] * actorWait[a];

minimize idleCost;
subject to {
   // use the slot-based secondary model
   inverse(scene, slot);
}

tuple slotSolutionT{ 
	int Scenes; 
	int value; 
};
{slotSolutionT} slotSolution = {<i0,slot[i0]> | i0 in Scenes};
tuple sceneSolutionT{ 
	int Scenes; 
	int value; 
};
{sceneSolutionT} sceneSolution = {<i0,scene[i0]> | i0 in Scenes};

