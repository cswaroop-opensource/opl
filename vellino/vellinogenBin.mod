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


// Generating the Bins in Vellino's Problem (vellinogenBin.mod) .
using CP;

include "vellinocommon.mod";

execute {
      writeln("genbin");
}

int maxcolor = card(Colors)-1;
range RColors = 0..maxcolor;
int capacity_int_idx[RColors] = [ord(Colors,c) : capacity[c] | c in Colors];
dvar int color in RColors;
dvar int n[Components] in 0..maxCapacity;
subject to {  
   1 <= sum(c in Components) n[c];
   sum(c in Components) n[c] <= capacity_int_idx[color];
   color == ord(Colors, "red") =>
     n["plastic"] == 0 &&  n["steel"] == 0 && n["wood"] <= 1;
   color == ord(Colors, "blue") =>
      n["plastic"] == 0 && n["wood"] == 0;
   color == ord(Colors, "green") =>
     n["glass"] == 0 && n["steel"] == 0 && n["wood"] <= 2;
   n["wood"] >= 1 => n["plastic"] >= 1;
   n["glass"] == 0 || n["copper"] == 0;  
   n["copper"] == 0 || n["plastic"] == 0;
};
int newId = card(Bins)+1;
string colorStringValue = item(Colors, color);

execute {
   writeln("Found bin with color : ", colorStringValue, " and containing elements ", n.solutionValue);
}
