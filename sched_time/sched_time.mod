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

This is a problem of building a house. The masonry, roofing, painting,
etc. must be scheduled.  Some tasks must necessarily take place before
others and these requirements are expressed through precedence
constraints.

Moreover, there are earliness and tardiness costs associated with some
tasks. The objective is to minimize these costs.

------------------------------------------------------------ */

using CP;


execute{
	}

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

pwlFunction tardinessFunction = piecewise { 0->100; 400 } (100, 0);
pwlFunction earliness1Function = piecewise { -200->25; 0 } (25, 0);
pwlFunction earliness2Function = piecewise { -300->75; 0 } (75, 0);
pwlFunction earliness3Function = piecewise { -100->75; 0 } (75, 0);

dexpr float tardiness=endEval(moving,tardinessFunction);
dexpr float earliness1=startEval(masonry,earliness1Function);
dexpr float earliness2=startEval(carpentry,earliness2Function);
dexpr float earliness3=startEval(ceiling,earliness3Function);

minimize tardiness + earliness1 + earliness2 + earliness3;

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
}


/*
OBJECTIVE: 5000
Masonry  : 20..55
Carpentry: 75..90
Plumbing : 55..95
Ceiling  : 75..90
Roofing  : 90..95
Painting : 90..100
Windows  : 95..100
Facade   : 95..105
Garden   : 95..100
Moving   : 105..110
*/
