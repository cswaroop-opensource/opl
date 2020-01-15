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

range r=1..3;
dvar boolean cell[r][r][r];

tuple t
{
   int x1;
   int x2;
   int x3;
   int y1;
   int y2;
   int y3;
   int z1;
   int z2;
   int z3;   
}

{t} lines={<x1,y1,z1,x2,y2,z2,x3,y3,z3> | x1,x2,x3,y1,y2,y3,z1,z2,z3 in r 
: (x2-x1==x3-x2) && (y2-y1==y3-y2) && (z2-z1==z3-z2) && (x1*9+y1*3+z1<x3*9+y3*3+z3) };

assert card(lines)==49;

dvar boolean monocolor[lines];

// minimize the number of mono color lines
minimize sum(l in lines) monocolor[l];

subject to
{
  // a line is mono color implies all the cells in the line have the same color 
  forall(<x1,y1,z1,x2,y2,z2,x3,y3,z3> in lines) 
    (monocolor[<x1,y1,z1,x2,y2,z2,x3,y3,z3>]==0) => 
    (cell[x1][y1][z1]+cell[x2][y2][z2]+cell[x3][y3][z3]>=1 && 
    cell[x1][y1][z1]+cell[x2][y2][z2]+cell[x3][y3][z3]<=2);
  
  // 14 cells of the same color
  sum(i,j,k in r) cell[i][j][k]==14; 
}

tuple monoT{
	t id;
	int value;
}
{monoT} monocolorSolution = {<t, monocolor[t]> | t in lines};
tuple cellsT{
	int a;
	int b;
	int c;
	int value;
}
{cellsT} cellSolution = {<i,j,k,cell[i][j][k]> | i,j,k in r};

