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

/* Opencast Mining.  
   From H.P. Williams, Model Building in Mathematical Programming
   Problem 12.14.
   
   This model is described in the documentation. 
See IDE and OPL > Language and Interfaces Examples.
 */
int NbLevels = ...;
range Level = 1..NbLevels;

tuple blockType {
   float purity;
   int   level;
   int   x;
   int   y;
};

float Cost[Level] = ...;
float PureValue = ...;
{blockType} Blocks = ...;
{blockType} Ontop[j in Blocks] = 
    {i | i in Blocks: j.level == i.level - 1 &&
                       ((j.x + 1 == i.x && j.y + 1 == i.y) ||
                        (j.x - 1 == i.x && j.y + 1 == i.y) ||
                        (j.x + 1 == i.x && j.y - 1 == i.y) ||
                        (j.x - 1 == i.x && j.y - 1 == i.y)   )};
int Minx = min(i in Blocks) i.x;
int Miny = min(i in Blocks) i.y;
int Maxx = max(i in Blocks) i.x;
int Maxy = max(i in Blocks) i.y;
range XRange = Minx..Maxx;
range YRange = Miny..Maxy;

tuple trips {
  int x; 
  int y; 
  int z;
};

{trips} There = {<x,y,z> | <p,z,x,y> in Blocks};
{trips} Allposs = {<x,y,z> | x in XRange, y in YRange, z in Level};
{trips} Notthere = Allposs diff There;
                     

dvar boolean Extract[Blocks];
dvar boolean XYZ[Level][XRange][YRange];

dexpr float Objective =
  sum(i in Blocks) Extract[i] * (i.purity * PureValue / 100.0 - Cost[i.level]);
  
maximize Objective;

subject to {
  forall(i in Blocks: i.level < NbLevels)
    forall(j in Ontop[i])
      Extract[i] >= Extract[j];
 
  forall(i in Blocks) {
    ctBlocks: XYZ[i.level][i.x][i.y] == Extract[i];
  }
   
  forall(i in Notthere) {
    ctNotThere: XYZ[i.z][i.x][i.y] == 0;
  }
}


tuple ExtractSolutionT{ 
	blockType Blocks; 	
	int value; 
};
{ExtractSolutionT} ExtractSolution = {<i0,Extract[i0]> | i0 in Blocks};
tuple XYZSolutionT{ 
	int Level; 
	int XRange; 
	int YRange; 
	int value; 
};
{XYZSolutionT} XYZSolution = {<i0,i1,i2,XYZ[i0][i1][i2]> | i0 in Level,i1 in XRange,i2 in YRange};

