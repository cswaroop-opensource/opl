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

// From Bradley, Hax, Magnanti, Applied Mathematical Programming, 
// Chapter 9, Exercise 24

//  - A Custom Pilot Chemical Company is a chemical manufacturer that produces
// batches of speciality chemicals to order. Principal equipment consists of
// eight interchangeable reactor vessels, five interchangeable distillation
// columns, four large interchangeable centrifuges, and a network of switchable
// piping and storage tanks. Customer demand comes in the form of orders for
// batches of one or more speciality chemicals, normally to be delivered
// simultaneously for further use by the customer.

// - An order consists of a set of jobs. Each job has an optional precedence
// requirement, arrival week of the job, duration of the job in weeks, the week
// that the job is due, the number of reactors required, distillation columns
// required, and centrifuges required.

// - Find a schedule of the orders and jobs to minimize the completion time of all
// orders.


using CP;

tuple paramsT{
	int NbReactors;
	int NbColumns;
	int NbCentrifuges;
};
paramsT Params = ...;

int NbReactors    = Params.NbReactors;
int NbColumns     = Params.NbColumns;
int NbCentrifuges = Params.NbCentrifuges;

tuple JobIndex {
  string ordernumber;
  int    jobnum;
};

tuple JobInfo {
  int jobprec;
  int arrival;
  int duration;
  int weekdue;
  int reactors;
  int columns;
  int centrifuges;
};

tuple JobData {
  JobIndex ind;
  JobInfo  info;
};
{JobData} jobs = ...;

{JobIndex} joblist = { i | <i,j> in jobs };
assert ( card(joblist) == card(jobs) );

JobInfo datarray[joblist];

execute {
  for(var j in jobs)
    datarray[j.ind] = j.info;
};

dvar interval a[j in joblist] 
  in datarray[j].arrival..datarray[j].weekdue 
  size datarray[j].duration;

cumulFunction reactors    = sum (j in joblist) pulse(a[j], datarray[j].reactors);
cumulFunction columns     = sum (j in joblist) pulse(a[j], datarray[j].columns);
cumulFunction centrifuges = sum (j in joblist) pulse(a[j], datarray[j].centrifuges);

minimize max(j in joblist) endOf(a[j]);
subject to {
  forall (j in joblist) {
    if (datarray[j].jobprec > 0) {
      endBeforeStart(a[<j.ordernumber,datarray[j].jobprec>], a[j]);
    }
  }
  reactors    <= NbReactors;
  columns     <= NbColumns;
  centrifuges <= NbCentrifuges;
};

execute {
  for(var j in joblist) {
    writeln(j + " on [" + a[j].start + "," + a[j].end + ")");
  }
}

tuple solutionT{
	JobIndex idx;
	int start;
	int end;
};
{solutionT} solution = {<j, startOf(a[j]), endOf(a[j])> | j in joblist};
execute{
	writeln(solution);
}