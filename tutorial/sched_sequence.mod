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

int   ReleaseDate[Houses] = ...; 
int   DueDate    [Houses] = ...; 
float Weight     [Houses] = ...; 

//Create the house interval variables
//Create the task interval variables

//Create the sequence variables
//Create the transition times

execute {
		cp.param.FailLimit = 20000;
}

//Add the objective

subject to {

//Add the precendence constraints
//Add the house span constraints
//Add the no overlap constraints
}
