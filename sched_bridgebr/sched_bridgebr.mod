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

{string} Task  = ...;
{string} Resource  = ...;

tuple Distance {
  string pre;
  string post;
  int    dist;
};

tuple Precedence {
  string pre;
  string post;
};

int taskDuration[Task] = ...;
{Distance} max_nf = ...;
{Distance} min_sf = ...;
{Distance} max_ef = ...;
{Distance} min_nf = ...;
{Distance} min_af = ...;
{string} tasksOnResource[Resource] = ...;
{Precedence} precedences = ...;

{string} TasksNotBreakable = { "ue", "ua", "ab1", "ab2", "ab3", "ab4", "ab5", "ab6", "l" };

int NbWeeks = 52;

stepFunction weekDays = stepwise(i in 0..NbWeeks-1, p in 0..1) { 100*p -> (7*i)+(5*p) ; 0 };
stepFunction allDays  = stepwise { 100 -> 0; 100 };

dvar interval a[t in Task] 
  size taskDuration[t] 
  intensity (t in TasksNotBreakable) ? allDays : weekDays; 

dvar sequence resourceUsage[r in Resource] in all(t in tasksOnResource[r]) a[t]; 

execute {
  		cp.param.FailLimit = 10000;
}

minimize max(t in Task) endOf(a[t]);

subject to {  
  forall(t in Task: t not in TasksNotBreakable) {
    forbidStart(a[t], weekDays);
    forbidEnd(a[t],   weekDays);
  }

  forall(r in Resource)
    noOverlap(resourceUsage[r]);

  forall(t in precedences ) 
    endBeforeStart(a[t.pre], a[t.post]); 
  
  forall( t in max_nf )
    startBeforeEnd(a[t.post], a[t.pre], -t.dist);
  
  forall(t in max_ef )
    endBeforeEnd( a[t.post],  a[t.pre], - t.dist); 
  
  forall( t in min_af )
    startBeforeStart(a[t.pre], a[t.post], t.dist);   
  
  forall( t in min_sf )
    endBeforeStart(a[t.post], a[t.pre], -t.dist);
  
  forall( t in min_nf )
    endBeforeStart(a[t.pre], a[t.post], t.dist);
  
};
