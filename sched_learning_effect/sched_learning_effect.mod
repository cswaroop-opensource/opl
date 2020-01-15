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

/* ------------------------------------------------------------

Problem Description
-------------------

This problem is an extension of the classical Job-Shop Scheduling
problem (see sched_jobshop.mod) with a learning effect on machines: 
because of experience acquired by the machine, executing an
operation at a position i on the machine will require less time than 
if it would be executed earlier at a position k<i. 

More formally, each machine M_j has a learning factor alpha_j in [0,1] 
such that the actual processing time of the operation executed at the 
ith position on machine M_j is the decreasing function d(i)=d*pow(alpha_j,i) 
where d is the nominal processing time of operation.

The model for a resource, except for the classical no-overlap constraint, 
consists of a chain of intervals of unknown size that maps the actual 
operations. The mapping (using an instance of isomorphism constraint) 
associates an integer variable (the position) with each operation of the resource. 
The position variable allows defining the processing time of an operation 
taking the learning effect into account. 

This example illustrates the usage of a chain of intervals as a generic 
tool to express constraints on sophisticated topology of a resource and 
the typical usage of the isomorphism constraint to get the position of 
interval variables in a sequence.

------------------------------------------------------------ */

using CP;

int nbJobs = ...;
int nbMachines = ...;

range Jobs = 1..nbJobs;
range Machines = 1..nbMachines;

tuple Operation {
  int job; // Job
  int pos; // position into the job
  int mch; // Machine
  int pt;  // Processing time
};
{Operation} Ops = ...;
float alpha[Machines] = ...;

dvar interval machines[Ops];
dvar int indices[Ops] in Jobs;
dvar interval chains[Machines][Jobs];

execute {
	cp.param.FailLimit = 10000;
}

minimize max (o in Ops) endOf(machines[o]);
subject to {
  forall(o1, o2 in Ops: o1.job == o2.job && o1.pos + 1 == o2.pos) 
    endBeforeStart(machines[o1], machines[o2]);

  // Building of the chain of intervals for the machine.
  forall(m in Machines, j in 2..nbJobs)
    endBeforeStart(chains[m][j-1], chains[m][j]);

  // Learning effect captured by the decreasing function
  // of the position (0 <= alpha <= 1).
  // The first operation in the sequence has no learning effect
  // so the alpha's exponent is 0 which is equal to index-1.
  forall(o in Ops) 
    sizeOf(machines[o]) == floor((o.pt)*pow(alpha[o.mch], indices[o]-1));

  forall(m in Machines)
    isomorphism(all[Jobs](j in Jobs) chains[m][j],
                all(o in Ops : o.mch == m) machines[o],
                all(o in Ops : o.mch == m) indices[o],
                nbJobs);
  // The no-overlap is in a redundant constraint in this quite simple model, but 
  // it is used to provide stronger inference. In a practical model, there were
  // exist constraints on the sequence that would require the no-overlap constraint.
  forall(m in Machines)
    noOverlap(all(o in Ops : o.mch == m) machines[o]);
}
