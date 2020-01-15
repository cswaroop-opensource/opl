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

include "FlightPairing_data.mod";

 /// this is actually a JS program
 
 // the maximum number of initial pairings to generate.
 int NumberOfInitialPairings = 3;
 
 
{TPairingLeg}  pairingLegs;
{TPairingCost} pairingCosts;

 main {
   includeScript("helpers.js");
   var status = 0;

   var MAX_INITIAL_PAIRINGS_PER_FLIGHT         = thisOplModel.NumberOfInitialPairings;   // Initial pairings to cover each flight
   var PrintPeriod  = 20;   // Print frequency
   
   var time  = 0;          // Procedure time
   var date0;
   var totalTime;            // Total computation time 

   /******************************************************************************
    * INITIALIZATION:
    * Generate initial pairings that cover all flights
    ******************************************************************************/
   
   // Load pairing cover model
   var generateOnePairingConfig =
      new IloOplRunConfiguration("GenerateOnePairing.mod", "FlightPairing.dat", "PairingGeneration.dat", "DefaultGenerateOnePairing.dat");
   var generatePairingModel = generateOnePairingConfig.oplModel;
   var generatePairingData  = generatePairingModel.dataElements;
   //generatePairingData.forcedCoveredFlight = -1;
   generatePairingModel.generate();
   
   var allFlights = generatePairingData.flights;
   var nbFlights = generatePairingData.flights.size;
   var maxNbLegs = generatePairingData.parameters.maxNbLegs;
   
   writeln("* starting CP search for initial pairings", ", #flights=", nbFlights, ", max. pairings/flight=", MAX_INITIAL_PAIRINGS_PER_FLIGHT);
   date0 = new Date();
   // Indices for master problem
   var legs  = thisOplModel.pairingLegs;
   var costs = thisOplModel.pairingCosts;
   var totalNumberOfColumns = 0;

   // Now, generate pairings for every flight
   for (var f=1; f <= nbFlights; f++) {
   
     var localGeneratePairingConfig =
      new IloOplRunConfiguration("GenerateOnePairing.mod");
     var localGeneratePairingModel = localGeneratePairingConfig.oplModel;
     generatePairingData.forcedCoveredFlight = f;
     localGeneratePairingModel.addDataSource(generatePairingData);
     localGeneratePairingModel.generate();     
     var localNumberOfPairings = 0;
     var localCP = localGeneratePairingConfig.cp;

     /// --- search loop for covering pairings
     /// seems better with nb agents ==1
     ///
	 localCP.param.Workers = 1;
     localCP.startNewSearch();
     while (localCP.next()) {
       // Add the pairing to the list
       var currentPairingIndex = totalNumberOfColumns;
       /// 1. store the cost
       costs.add( currentPairingIndex, localGeneratePairingModel.costVar );
       /// 2. store the actual legs as triplets <#p, #l, flight>
       ///
       for (var l=1; l <= maxNbLegs; ++l) {   
         var flightRank  = localGeneratePairingModel.flightVars[l];
         var isActualLeg = localGeneratePairingModel.isActualLeg[l];
         //writeln("-- flight covered: ", f, ", #leg: ", l, ", f=", flightIndex);
         if ( isActualLeg < 0.1 ) break;  /// stop at dummy legs.
            
         /// BEWARE: variable is 1..F, but Opl.item() has C-convention
         legs.add(currentPairingIndex, l , flightRank);
       }//for           
       ++localNumberOfPairings;
       ++totalNumberOfColumns;
         
       if (localNumberOfPairings >= MAX_INITIAL_PAIRINGS_PER_FLIGHT) 
         break;
     }//while
     localCP.endSearch();
     if ( 0 == localNumberOfPairings) {
         writeln("** ERROR: cannot find any pairing for flight: ", f, " final problem will be infeasible");
         status = -2;
     }
     if ( localNumberOfPairings < MAX_INITIAL_PAIRINGS_PER_FLIGHT ) {
       ///  !!!
       /// This may be a problem: cannot find MAX_PAIRINGS pairings
       /// only a subset..        
       writeln("* warning: cannot find ", MAX_INITIAL_PAIRINGS_PER_FLIGHT, " pairings, only: ", localNumberOfPairings);
     }              
     if ( (f% PrintPeriod) == 0) {
       writeln("* initial generation: ", Opl.floor( (100 * f)/nbFlights +.5), "%, #columns: ", totalNumberOfColumns, ", time=", getElapsedTime(date0));
     }
   }
  
   writeln("* end initial pairings phase, time: " , time, "#columns=", totalNumberOfColumns, ", time=", getElapsedTime(date0), "s.");
   print_initial_pairings(legs, costs, "initial_pairings.dat");
   // this is the end
   
    writeln("*  script returns with code: ", status)
   status; 
 }
