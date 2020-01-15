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

int NbWorkers = ...;
int NbHouses  = ...; 
range Houses  = 1..NbHouses;

{string} TaskNames   = ...;

int Duration [t in TaskNames] = ...;

tuple Precedence {
   string pre;
   string post;
};
{Precedence} Precedences = ...;

int ReleaseDate[Houses] = ...; 

//Create the interval variables

//Declare the worker usage function
//Declare the cash budget function

execute {
		cp.param.FailLimit = 10000;
}

//Add the objective

subject to {

//Add the temporal constraints
//Add the worker usage constraint
//Add cash budget constraint

}

