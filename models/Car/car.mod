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

/***************************************************
OPL Model for Car Sequencing

Cars in production are placed on an
assembly line moving through various
units that install options such as air
conditioning and radios.  The
assembly line can thus be viewed as
composed of slots and each car must
be allocated to a single slot.    The
cars cannot be allocated arbitrarily,
since the production units have
limited capacity and the options must
be added to the cars as the assembly
line is moving in front of the unit.

Two projects are given, with two different
data sets.  The "Small" run configuration has the data
file smallcar.dat that will run with the
OPL Studio trial version.
***************************************************/
using CP;


execute{
	}

int  nbCars    = ...; // # of cars
int   nbOptions = ...;// # of options
int   nbSlots   = ...;// # of slots

range   Cars    = 1..nbCars; 
range   Options = 1..nbOptions;
range   Slots   = 1..nbSlots;

int demand[Cars] = ...;
int option[Options,Cars] = ...; 

tuple Tcapacity {
   int l;
   int u;
};
Tcapacity capacity[Options] = ...; 
int optionDemand[i in Options] = sum(j in Cars) demand[j] * option[i,j];

dvar int slot[Slots] in Cars;
dvar int setup[Options,Slots] in 0..1;

subject to {
   // # of cars = demand
   forall(c in Cars )
      sum(s in Slots ) (slot[s] == c) == demand[c];
   
   forall(o in Options, s in 1..(nbSlots - capacity[o].u + 1) )
      sum(j in s..(s + capacity[o].u - 1)) setup[o,j] <= capacity[o].l;

   forall(o in Options, s in Slots )
     setup[o,s] == option[o][slot[s]];
   
   forall(o in Options, i in 1..optionDemand[o])
     sum(s in 1 .. (nbSlots - i * capacity[o].u)) setup[o,s] >=
     optionDemand[o] - i * capacity[o].l;
};

tuple slotSolutionT{ 
	int Slots; 
	int value; 
};
{slotSolutionT} slotSolution = {<i0,slot[i0]> | i0 in Slots};
tuple setupSolutionT{ 
	int Options; 
	int Slots; 
	int value; 
};
{setupSolutionT} setupSolution = {<i0,i1,setup[i0][i1]> | i0 in Options,i1 in Slots};

