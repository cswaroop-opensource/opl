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

/******************************************************************************
 * 
 * OPL Model for Telecommunication Route Generation
 * 
 * Construct a "route" from a set of end-to-end paths so that the collection
 * of paths satisfies the blocking criterion at a minimum cost.  This extends
 * the two-arc path optimization algorithm in chapter 4 of "Dynamic Routing in 
 * Telecommunications Networks" by Gerald R. Ash (McGraw Hill).
 * 
 * This is a dynamic programming model with two global constraints:
 *      1. All paths are different
 *      2. Blocking criterion
 * The "allDifferent" constraint is implemented explicitly to allow duplicates
 * of a dummy value at the end of the sequence.
 * 
 * Pseudorandom cost and blocking data are generated within the model.
 * 
******************************************************************************/

using CP;

execute
{
// This makes sure we'll get the exact minimum
 		cp.param.optimalityTolerance = 1.0;
	cp.param.relativeOptimalityTolerance = 0.0; 
}    

/******************************************************************************
 * DATA DECLARATIONS
 ******************************************************************************/

int nNodes          = 500;          // Number of nodes
int SCALE           = 1000;         // Integer scaling factor
int blkTol          = -6;           // Blocking criterion

range Nodes         = 1..nNodes;
range Paths         = 0..nNodes;    // Only consider 2-arc paths

// Blocking percentages
int blk[p in Paths] = (p==0)?0:(1+rand(10));   
// Logs of blocking percentages
int lbk[p in Paths] = ftoi(round(log(0.01*((p==0)?(1+rand(10)):blk[p]))*SCALE));
// Costs 
int cst[p in Paths] = (p==0)?0:(10+rand(90));                

/*
 * Initialize blocking percentages and path costs
 * with pseudorandom data.
 */


// Summary data
int minRoute    = ftoi(ceil(1.0*SCALE*blkTol/(min (i in Paths) lbk[i])));
int maxCost     = max (i in Nodes) cst[i];
int rteSize     = 2+minRoute;
range Route     = 1..rteSize;


/******************************************************************************
 * DECISION VARIABLES
 ******************************************************************************/
range R = 1..rteSize+1;
dvar int     rte[Route] in Paths;
dvar int     cost[R]  in 0..SCALE*maxCost;


/******************************************************************************
 * MODEL
 ******************************************************************************/

minimize cost[1];
subject to {
    
    // Recursive objective function
    cost[rteSize+1] == 0;
    forall (i in Route)
      cost[i] == ( SCALE*(100-blk[rte[i]])*cst[rte[i]]
                   + blk[rte[i]]*cost[i+1] ) div 100;
              
    // Path constraints: All paths are different except
    // dummy paths at the end.  This comes from simplifying
    // the two constraints:
   
    forall (ordered i,j in Route)
        (rte[i] != 0 && rte[i] != rte[j]) || (rte[j] == 0);
    
    // Blocking criterion: Joint probability that all paths are
    // blocked is at most 10^blkTol.  Take the log of both sides
    // to avoid underflow.
    sum (i in Route) lbk[rte[i]] <= SCALE*blkTol;
              
    // Redundant constraint: 
    // Eliminate dummy paths from the start of the route
    forall (i in 1..minRoute) rte[i] != 0;

    // Redundant constraint:
    // The expected cost is at least the minimum cost of a
    // single path
    cost[1] >= SCALE * (min (i in Nodes) cst[i]);
};


tuple costSolutionT{ 
	int R; 
	int value; 
};
{costSolutionT} costSolution = {<i0,cost[i0]> | i0 in R};
tuple rteSolutionT{ 
	int Route; 
	int value; 
};
{rteSolutionT} rteSolution = {<i0,rte[i0]> | i0 in Route};

execute{ 
	writeln(costSolution);
	writeln(rteSolution);
}




