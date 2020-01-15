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

int SizeSquare = 112;
int NbSquares  = 21;

execute{
	}

range Squares = 1..NbSquares;

int Size[Squares] = [50,42,37,35,33,29,27,25,24,19,18,17,16,15,11,9,8,7,6,4,2];

dvar interval x[s in Squares] in 0..SizeSquare size Size[s];
dvar interval y[s in Squares] in 0..SizeSquare size Size[s];

cumulFunction rx = sum(s in Squares) pulse(x[s], Size[s]);
cumulFunction ry = sum(s in Squares) pulse(y[s], Size[s]);

execute {
  var f = cp.factory;
  cp.setSearchPhases(f.searchPhase(x),   
		     f.searchPhase(y));
};

constraints {
   alwaysIn(rx,0,SizeSquare,SizeSquare,SizeSquare);
   alwaysIn(ry,0,SizeSquare,SizeSquare,SizeSquare);
   forall(ordered i, j in Squares)
     endOf(x[i]) <= startOf(x[j]) ||
     endOf(x[j]) <= startOf(x[i]) ||
     endOf(y[i]) <= startOf(y[j]) ||
     endOf(y[j]) <= startOf(y[i]);
};


