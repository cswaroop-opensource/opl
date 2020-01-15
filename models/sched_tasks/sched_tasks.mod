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

// Problem Description : workforce scheduling problem.
//
// A set of resources (tuple ResourceDat) of different types is available to perform some requests.
// Different types of requests are considered (tuple RequestType). 
// A given type of request can be decomposed into a set of tasks (tuple Recipe) and 
// some temporal dependencies between those tasks (tuple Dependency).
// Each task is associated with a processing time (tuple Task) and a set of resource requirements (tuple Requirement).
// A requirement consists of a task type, a resource type and a quantity 
// (number of resources of the specified type to be used for executing this type of task).
//
// The objective is to schedule a set of requests with individual due dates so as to minimize the total tardiness. 
//
// Model and Constraints
//
// Each request, task and possible allocation of a task to a resource for a requirement 
// is modelled as an interval variable. 
// A request spans its tasks. 
// Allocations are optional.
// Each requirement posts a generalized alternative constraint between 
// the task and the set of possible allocations for this requirement. 
// The cardinality of this generalized alternative is the number of required resources. 
//
// Each resource is a sequence of its non-overlapping allocations.
//
// The objective is to minimize total tardiness.
//
// Redundant cumul.
//
// In this model, a redundant cumul function is used to globally constrain 
// the number of resources of a certain type simultaneously used by the tasks. 
// This cumul is limited by the number of resources of the resource type.
// These redundant cumuls may help in some models as they enforce a stronger inference 
// in the engine while the whole set of resources for the tasks is still not completely chosen. 
// For more complex problems, e.g resources with several resource types / skills, 
// other partitions of the resource set may define efficient redundant cumul. 

using CP;

// Data for resources, requests and tasks

tuple ResourceDat {
  key int id;
  string  type;
  string name;
};

tuple RequestDat {
  key int id;
  string  type;
  int     duedate;
  string  name;
};

tuple TaskDat {
  key int id;
  string  type;
  int     ptime;
  string  name;
};

{RequestDat}  requests  = ...;
{ResourceDat} resources = ...;
{TaskDat}     tasks     = ...;

{string} resourceTypes = { r.type | r in resources };

// Data for template recipes, dependencies and requirements

tuple Recipe {
  string request;
  string task;
};

tuple Dependency {
  string request;
  string taskb;
  string taska;
  int    delay;
};

tuple Requirement {
  string task;
  string resource;
  int    quantity;
};

{Recipe}      recipes      = ...;
{Dependency}  dependencies = ...;
{Requirement} requirements = ...;

// Set of operations (tasks of a request) and allocations (operation on a possible resource)

tuple Operation {
  RequestDat request;
  TaskDat    task;
};

tuple Allocation {
  Operation   dmd;
  Requirement req;
  ResourceDat resource;
};

{Operation} operations = 
  { <r, t> | r in requests,  m in recipes, t in tasks : 
   r.type == m.request && t.type == m.task};

{Allocation} allocs = 
  { <o, m, r> | o in operations, m in requirements, r in resources : 
   o.task.type == m.task && r.type == m.resource};

dvar interval tirequests[requests];
dvar interval tiops[o in operations] size o.task.ptime;
dvar interval tiallocs[allocs] optional;

dvar sequence workers[r in resources] in all(a in allocs: a.resource == r) tiallocs[a];

int levels[rt in resourceTypes] = sum(r in resources : r.type == rt) 1;

cumulFunction cumuls[rt in resourceTypes] =
  sum(rc in requirements, o in operations : rc.resource == rt && o.task.type == rc.task) pulse(tiops[o], rc.quantity);

minimize sum(t in requests) maxl(0, endOf(tirequests[t]) - t.duedate);
subject to {
  forall(r in requests) {
    span(tirequests[r], all(o in operations : o.request == r) tiops[o]);
    forall (o in operations : o.request == r) {
      forall (rc in requirements : rc.task == o.task.type) {
        alternative(tiops[o], all(a in allocs : a.req == rc && a.dmd == o) tiallocs[a], rc.quantity);
      }        
      forall(tc in dependencies: tc.request == r.type && tc.taskb == o.task.type) {
        forall(o2 in operations : o2.request == r && tc.taska == o2.task.type) {
          endBeforeStart(tiops[o], tiops[o2], tc.delay);    
        }
      }
    }   
  }
  forall(r in resources) {
    noOverlap(workers[r]);
  }    
  forall(r in resourceTypes: levels[r] > 1) {
    cumuls[r] <= levels[r];
  }    
};
