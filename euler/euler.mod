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

int scale=8;
range ChessBoard = 1..scale*scale;


tuple coord
{
 int x;
 int y;  
};

{coord} Knightmoves2D[i in 1..scale][j in 1..scale]=
{<i+2,j+1>,<i+2,j-1>,<i+1,j+2>,<i+1,j-2>,
<i-2,j+1>,<i-2,j-1>,<i-1,j+2>,<i-1,j-2>}
inter {<x,y> | x in 1..scale ,y in 1..scale};

{int} Knightmove[i in ChessBoard]={(x-1)*scale+y | <x,y> in Knightmoves2D[(i-1) div scale+1][(i-1) % scale+1]};

dvar int jump[ChessBoard] in ChessBoard;
dvar int Sequence[ChessBoard] in ChessBoard;

execute {
		var f = cp.factory;
	cp.setSearchPhases(f.searchPhase(Sequence));
	cp.param.defaultInferenceLevel="Extended";
}

subject to {
   forall(p in ChessBoard)
      jump[p] in Knightmove[p];

    Sequence[1] == jump[1];
    forall(p in 2..scale*scale)
      Sequence[p] == jump[Sequence[p-1]];

   allDifferent(Sequence);
   allDifferent(jump);
   
   Sequence[scale*scale] == 1;


   forall(p in ChessBoard)
      sum(c in Knightmove[p]) (jump[c] == p) == 1;  


};


int rank[1..scale,1..scale]=[ (Sequence[i]-1) % scale+1 : [ (Sequence[i]-1) div scale+1 : i ] | i in 1..scale *scale]; 

execute
{
 // rank is the human oriented result
 writeln(rank);  
}


tuple SequenceSolutionT{ 
	int ChessBoard; 
	int value; 
};
{SequenceSolutionT} SequenceSolution = {<i0,Sequence[i0]> | i0 in ChessBoard};
tuple jumpSolutionT{ 
	int ChessBoard; 
	int value; 
};
{jumpSolutionT} jumpSolution = {<i0,jump[i0]> | i0 in ChessBoard};















