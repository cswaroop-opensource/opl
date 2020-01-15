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

{string} ComputerTypes = ...;
{string} ActivityTypes = ...;
{string} ResourceTypes = ...;
int requiredQuantities[ComputerTypes] = ...;

/* ----------------------------------------------------
 *   An activity consists of an activity type, a
 * duration, a unary resource requirement, and a list
 * of precedences.
 *   --------------------------------------------------- */
tuple ActivityInfo {
   key string   activity;
   int      duration;
   string   requirement;
   {string} precedences;
};
{ActivityInfo} activities[ComputerTypes] = ...;

tuple ComputerActivityMatch {
   ActivityInfo activity;
   string       computerType;
   int          computer;            
};
// All activities that must get scheduled
{ComputerActivityMatch} allActivities = {<a,c,j> | c in ComputerTypes,
					 a in activities[c],
					 j in 1..requiredQuantities[c]};
// The activities which must precede activity a
{ComputerActivityMatch} precedences[a in allActivities] = { b | b in allActivities : 
                                 a.computerType == b.computerType &&
                                 a.computer == b.computer && 
                                 b.activity.activity in a.activity.precedences };


dvar interval activity[a in allActivities] size a.activity.duration;

dvar sequence resource[r in ResourceTypes] in 
   all(a in allActivities: a.activity.requirement==r) activity[a];

constraint Precedence[allActivities,allActivities];

execute {
		cp.param.FailLimit = 10000;
}

minimize max(a in allActivities) endOf(activity[a]);
subject to {
  // Remove symmetry
  forall(a1,a2 in allActivities:
	(a1.activity == a2.activity && 
	a1.computerType == a2.computerType && 
	a1.computer < a2.computer) )
    
          BreakSymmetry: endBeforeStart(activity[a1], activity[a2]);

  // Resource Requirements
  forall (r in ResourceTypes)
    NoOverlap: noOverlap(resource[r]);
    
  // Precedences
  forall( a in allActivities)
    forall( p in precedences[a])
      Precedence[a,p]: endBeforeStart(activity[p], activity[a]);
};


   
