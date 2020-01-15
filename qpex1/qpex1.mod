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

/* QP: Quadratic Objective
 *
 * Example from CPLEX : iloqpex1.cpp 
 */
range R = 0..2;
dvar float x[R] in 0..40;


maximize
  x[0] + 2 * x[1] + 3 * x[2]
  - 0.5 * 
    ( 33*x[0]^2 + 22*x[1]^2 + 11*x[2]^2 
    - 12*x[0]*x[1] - 23*x[1]*x[2] );

subject to {
  ct1:  - x[0] +     x[1] + x[2] <= 20;
  ct2:    x[0] - 3 * x[1] + x[2] <= 30;
}

tuple xSolutionT{ 
	int R; 
	float value; 
};
{xSolutionT} xSolution = {<i0,x[i0]> | i0 in R};
