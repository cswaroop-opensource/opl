// --------------------------------------------------------------------------
// Licensed Materials - Property of IBM
//
// 5725-A06 5725-A29 5724-Y48 5724-Y49 5724-Y54 5724-Y55
// Copyright IBM Corporation 1998, 2015. All Rights Reserved.
//
// Note to U.S. Government Users Restricted Rights:
// Use, duplication or disclosure restricted by GSA ADP Schedule
// Contract with IBM Corp.
// --------------------------------------------------------------------------

// JS utilities

function getElapsedTime(origin) {
   var curdate = new Date();
   return Opl.ceil((curdate - origin)/1000); 
}

function print_initial_pairings(legs, costs, initialPairingPath) {
  var initialPairingsFile = new IloOplOutputFile(initialPairingPath);
  var isFirst = true;
  initialPairingsFile.writeln("pairingLegs = {");
  for (var l in legs ) {
    initialPairingsFile.write("  ");   
    if ( !isFirst ) {
      initialPairingsFile.write(",");
    }      
    initialPairingsFile.writeln("<", l.id, ", ", l.legRank, ", "
				, l.flightRank, "> ");
    isFirst = false; 
  }
  initialPairingsFile.writeln("};\n");
  initialPairingsFile.writeln("pairingCosts = {");
  isFirst = true;
    
  for (var k in costs) {
    initialPairingsFile.write("  ");
    if ( !isFirst ) {
      initialPairingsFile.write(",");
    }        
    initialPairingsFile.writeln("<", k.id, ", ", k.cost, "> ");
    isFirst = false;  
  }
  initialPairingsFile.writeln("};");
  initialPairingsFile.close();
  //writeln("-- initial pairings DAT file overwritten: ", initialPairingPath);
}


/// debug: write duals as a DAT structure
function print_dual_values(dualPath, coverCtDuals) {
  var dualFile = new IloOplOutputFile(dualPath, false);
  dualFile.writeln("coverct_duals={");
  var isFirst = false;
  for (var d in coverCtDuals) {
    dualFile.write("  ");
    if ( isFirst) dualFile.write(",");
    dualFile.writeln("<", d.flightRank, "," , d.coverCtDual, ">");
    isFirst = true;
  }
  dualFile.writeln("};");
  dualFile.close();   
  //writeln("* dual file overwritten: ",dualPath);
}

