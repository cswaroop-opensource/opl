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

dvar int i in 1..100;
dvar int j in 1..100;
dvar int k in 1..99;

dexpr float kf = k/100;
dexpr float ar[i in 1..10] = k/i;

minimize kf + sum(i in 1..10)ar[i];

subject to {
   i*(1+kf) == j;
}

tuple solutionT{
	int i;
	int j;
	int k;
};

{solutionT} solution = {};
execute{
solution.add(i,j,k);
writeln(solution);
}
