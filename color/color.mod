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

The problem involves choosing colors for the countries on a map in 
such a way that at most four colors (blue, white, yellow, green) are 
used and no neighboring countries are the same color. In this exercise, 
you will find a solution for a map coloring problem with six countries: 
Belgium, Denmark, France, Germany, Luxembourg, and the Netherlands. 

------------------------------------------------------------ */
using CP;

range r = 0..3;

string Names[r] = ["blue", "white", "yellow", "green"]; 

dvar int Belgium in r;
dvar int Denmark in r;
dvar int France in r;
dvar int Germany  in r;
dvar int Luxembourg in r;
dvar int Netherlands in r;

subject to {  
   Belgium != France; 
   Belgium != Germany; 
   Belgium != Netherlands;
   Belgium != Luxembourg;
   Denmark != Germany; 
   France != Germany; 
   France != Luxembourg; 
   Germany != Luxembourg;
   Germany != Netherlands;    
}

execute {
   writeln("Belgium:     ", Names[Belgium]);
   writeln("Denmark:     ", Names[Denmark]);
   writeln("France:      ", Names[France]);
   writeln("Germany:     ", Names[Germany]);
   writeln("Luxembourg:  ", Names[Luxembourg]);
   writeln("Netherlands: ", Names[Netherlands]);
}

tuple resultT {
	string name;
	string value;
};
{resultT} solution = {};
execute{
   solution.add("Belgium", Names[Belgium]);
   solution.add("Denmark", Names[Denmark]);
   solution.add("France", Names[France]);
   solution.add("Germany", Names[Germany]);
   solution.add("Luxembourg", Names[Luxembourg]);
   solution.add("Netherlands", Names[Netherlands]);
   writeln(solution);
}