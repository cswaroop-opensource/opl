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

// CLP model from the paper 
//
// Algorithms for hybrid MILP/CLP models for a class of optimization problems
// Vipul Jain and Ignacio Grossmann
// 
// Department of Chemical Engineering, Carnegie Mellon University
// 5000 Forbes Avenue, Pittsburgh, PA 15213, United States
//
// http: egon.cheme.cmu.edu/
// email: vjain@andrew.cmu.edu, ig0c@andrew.cmu.edu

// The data is given in separate files, the equation numbers refer to the paper

using CP;

// Number of Machines (Packing + Manufacturing)
int nbMachines = ...;
range Machines = 1..nbMachines;

// Number of Jobs
int nbJobs = ...;
range Jobs = 1..nbJobs;

int duration[Jobs,Machines] = ...;
int cost    [Jobs,Machines] =...;
int release [Jobs] = ...;
int due     [Jobs] = ...;
 
dvar interval task[j in Jobs] in release[j]..due[j];
dvar interval opttask[j in Jobs][m in Machines] optional size duration[j][m];

dvar sequence tool[m in Machines] in all(j in Jobs) opttask[j][m];

execute {
		cp.param.FailLimit = 5000;
}


// Minimize the total processing cost (24)
minimize 
  sum(j in Jobs, m in Machines) cost[j][m] * presenceOf(opttask[j][m]);
subject to {
  // Each job needs one unary resource of the alternative set s (28)
  forall(j in Jobs)
    alternative(task[j], all(m in Machines) opttask[j][m]);
  // No overlap on machines
   forall(m in Machines)
     noOverlap(tool[m]);
};

execute {
  writeln(task);
};
 
