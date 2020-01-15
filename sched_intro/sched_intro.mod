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

This is a basic problem that involves building a house. The masonry,
roofing, painting, etc.  must be scheduled. Some tasks must
necessarily take place before others, and these requirements are
expressed through precedence constraints.

------------------------------------------------------------ */


using CP;


dvar interval masonry    size 35;
dvar interval carpentry  size 15;
dvar interval plumbing   size 40;
dvar interval ceiling    size 15;
dvar interval roofing    size 5;
dvar interval painting   size 10;
dvar interval windows    size 5;
dvar interval facade     size 10;
dvar interval garden     size 5;
dvar interval moving     size 5;

subject to {
  endBeforeStart(masonry,   carpentry);
  endBeforeStart(masonry,   plumbing);
  endBeforeStart(masonry,   ceiling);
  endBeforeStart(carpentry, roofing);
  endBeforeStart(ceiling,   painting);
  endBeforeStart(roofing,   windows);
  endBeforeStart(roofing,   facade);
  endBeforeStart(plumbing,  facade);
  endBeforeStart(roofing,   garden);
  endBeforeStart(plumbing,  garden);
  endBeforeStart(windows,   moving);
  endBeforeStart(facade,    moving);
  endBeforeStart(garden,    moving);
  endBeforeStart(painting,  moving);
}


tuple solutionT{
	string name;
	int start;
	int end;	
};
{solutionT} solution = {};
execute {
  writeln("Masonry  : " + masonry.start   + ".." + masonry.end);
  writeln("Carpentry: " + carpentry.start + ".." + carpentry.end);
  writeln("Plumbing : " + plumbing.start  + ".." + plumbing.end);
  writeln("Ceiling  : " + ceiling.start   + ".." + ceiling.end);
  writeln("Roofing  : " + roofing.start   + ".." + roofing.end);
  writeln("Painting : " + painting.start  + ".." + painting.end);
  writeln("Windows  : " + windows.start   + ".." + windows.end);
  writeln("Facade   : " + facade.start    + ".." + facade.end);
  writeln("Garden   : " + garden.start    + ".." + garden.end);
  writeln("Moving   : " + moving.start    + ".." + moving.end);
  
  solution.addOnly("Masonry" , masonry.start, masonry.end);
  solution.addOnly("Carpentry" , carpentry.start , carpentry.end);
  solution.addOnly("Plumbing" , plumbing.start  , plumbing.end);
  solution.addOnly("Ceiling" , ceiling.start   , ceiling.end);
  solution.addOnly("Roofing" , roofing.start   , roofing.end);
  solution.addOnly("Painting" , painting.start  , painting.end);
  solution.addOnly("Windows" , windows.start   , windows.end);
  solution.addOnly("Facade" , facade.start    , facade.end);
  solution.addOnly("Garden" , garden.start    , garden.end);
  solution.addOnly("Moving" , moving.start    , moving.end);
  
  writeln(solution);
  }

/*
<<< setup


<<< generate

 ! ----------------------------------------------------------------------------
 ! Satisfiability problem - 10 variables, 14 constraints
 ! Initial process time : 0.00s (0.00s extraction + 0.00s propagation)
 !  . Log search space  : 300.0 (before), 300.0 (after)
 !  . Memory usage      : 283.0 Kb (before), 283.0 Kb (after)
 ! ----------------------------------------------------------------------------
 !   Branches  Non-fixed                Branch decision
 *         13      0.00s                         -
 ! ----------------------------------------------------------------------------
 ! Solution status        : Terminated normally, solution found
 ! Number of branches     : 13
 ! Number of fails        : 0
 ! Total memory usage     : 432.3 Kb (315.0 Kb CP Optimizer + 117.3 Kb Concert)
 ! Time spent in solve    : 0.00s (0.00s engine + 0.00s extraction)
 ! Search speed (br. / s) : 1300.0
 ! ----------------------------------------------------------------------------

<<< solve



OBJECTIVE: no objective
Masonry  : 0..35
Carpentry: 35..50
Plumbing : 35..75
Ceiling  : 35..50
Roofing  : 50..55
Painting : 50..60
Windows  : 55..60
Facade   : 75..85
Garden   : 75..80
Moving   : 85..90

<<< post process
*/
