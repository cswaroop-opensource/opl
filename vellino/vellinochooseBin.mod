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

// Choosing the Bins in Vellino's Problem (vellinochooseBin.mod) .

include "vellinocommon.mod";

execute {
   writeln("choosebin");
   }
dvar int produce[Bins] in 0..maxDemand;
minimize
   sum(b in Bins) produce[b];
subject to {
   forall(c in Components)
     demandCt: sum(b in Bins) b.n[c] * produce[b] == demand[c];
 };
execute {
   writeln("Chosen : ");
   for (var b in Bins)
     writeln(b, " : ", produce[b]);
}
