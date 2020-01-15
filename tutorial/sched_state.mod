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

/*********************************************
Problem Description
-------------------

This is a problem of building five houses in different locations; the
masonry, roofing, painting, etc. must be scheduled. Some tasks must
necessarily take place before others and these requirements are
expressed through precedence constraints.

A pool of two workers is available for building the houses. For a
given house, some tasks (namely: plumbing, ceiling and painting)
require the house to be clean whereas other tasks (namely: masonry,
carpentry, roofing and windows) put the house in a dirty state. A
transition time of 1 is needed to clean the house so to change from
state 'dirty' to state 'clean'.

The objective is to minimize the makespan.
*********************************************/

using CP;

int NbHouses  = ...; 
int NbWorkers = ...;
range Houses = 1..NbHouses;

{string} AllStates = ...;
{string} TaskNames = ...;

int Duration[t in TaskNames] = ...;

int Index[s in AllStates] = ord(AllStates, s);

tuple Precedence {
   string pre;
   string post;
};

{Precedence} Precedences = ...;

tuple StateRequirement {
  string task;
  string state;
};
{StateRequirement} States = ...;


//Create the interval variables


//Declare the worker usage functions


//Create the transition times


//Declare the state function


execute {
		cp.param.FailLimit = 10000;
}


//Add the objective


//Add the constraints

