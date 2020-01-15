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

using CP;

int NbHouses = ...; 
range Houses = 1..NbHouses;

{string} WorkerNames = ...;  
{string} TaskNames   = ...;

int    Duration [t in TaskNames] = ...;
string Worker   [t in TaskNames] = ...;

tuple Precedence {
  string pre;
  string post;
};
{Precedence} Precedences = ...;

tuple Break {
  int s;
  int e;
};
{Break} Breaks[WorkerNames] = ...; 

//Add the intensity step functions
//Create the interval variables

execute {
		cp.param.FailLimit = 10000;
}

//Add the objective

subject to {
//Add the precendence constraints
//Add the forbidden start and end constraints
//Add the no overlap constraints
}

