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

int Deadline = ...;

{string} Workers = ...;
{string} Tasks = ...;

int Durations[Tasks] = ...;

tuple Skill {
  string worker;
  string task;
  int    level;  
};
{Skill} Skills = ...;

tuple Precedence {
  string pre;
  string post;
};

{Precedence} Precedences=...;

tuple Continuity {
  string worker;
  string task1;  
  string task2;
};
{Continuity} Continuities = ...;

//Create the interval variables

execute {
		cp.param.FailLimit = 10000;
}

//Add the objective

subject to {
  forall(h in Houses) {

    true;
//Add the temporal constraints
//Add the alternative constraints

//Add same worker constraints

  }
//Add the no overlap constraints

}
