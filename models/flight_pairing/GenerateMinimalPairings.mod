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

{TPairingLeg}  pairingLegs;
{TPairingCost} pairingCosts;

{int} coveredFlights;

 main {
   includeScript("helpers.js");
   var retcode = 0;
   var PrintPeriod  = 20;   // Print frequency
   
   var time  = 0;          // Procedure time
   var timeorigin;
   var totalTime;            // Total computation time 

   /******************************************************************************
    * INITIALIZATION:
    * Generate initial pairings that cover all flights
    ******************************************************************************/
   
   // Load pairing cover model
   var generateOnePairingConfig =
      new IloOplRunConfiguration("GenerateOnePairing.mod", "FlightPairing.dat", "PairingGeneration.dat");
   var dummyGenerationData = new IloOplDataElements();
   dummyGenerationData.forcedCoveredFlight = -1;

   var generatePairingModel = generateOnePairingConfig.oplModel;
   generatePairingModel.addDataSource(dummyGenerationData);

   var generatePairingData  = generatePairingModel.dataElements;
   generatePairingModel.generate();
   
   var allFlights = generatePairingData.flights;
   var nbFlights  = generatePairingData.flights.size;
   var maxNbLegs  = generatePairingData.parameters.maxNbLegs;
   var numberOfFlights = allFlights.size;
   
   writeln("* starting search for initial (minimal) pairings", ", #flights=", nbFlights);
   timeorigin = new Date();
   // Indices for master problem
   var legs  = thisOplModel.pairingLegs;
   var costs = thisOplModel.pairingCosts;
   var totalNumberOfColumns = 0;
   var totalNumberOfSkipped = 0;
   
   var generateOnePairingSource = new IloOplModelSource("GenerateOnePairing.mod");
   var generateOnePairingDef    = new IloOplModelDefinition(generateOnePairingSource);
   var masterDataSource         = new IloOplDataSource("FlightPairing.dat");
   var generationDataSource     = new IloOplDataSource("PairingGeneration.dat");
  


   // Now, generate pairings for every flight
   for (var f=1; f <= nbFlights; f++) {
     if ( thisOplModel.coveredFlights.contains(f) ) {
       ++totalNumberOfSkipped;
       continue;     
     }
     writeln(totalNumberOfColumns+1, "> starting new CP search for flight: ", f);
     
     
     var pairingCP = new IloCP();   
     //pairingCP.clearModel();
     var generatePairingModel = new IloOplModel(generateOnePairingDef, pairingCP);
     generatePairingModel.addDataSource(masterDataSource);
     generatePairingModel.addDataSource(generationDataSource);
     // 3 lines to set the flight number!!
     var localGenerationData = new IloOplDataElements();
     localGenerationData.forcedCoveredFlight = f;
     generatePairingModel.addDataSource(localGenerationData);
     
     generatePairingModel.generate();     
     var localNumberOfPairings = 0;

     /// --- search loop for covering pairings
     /// seems better with nb agents ==1
     ///
	 pairingCP.param.Workers = 1;
	 var cpOk = pairingCP.solve();
	 if (!cpOk) {
	   writeln("* search for initial pairings fails, flight: ", item(allFlights,f).name);
	   retcode = -1;
	   break;
	 }
    
       // Add the pairing to the list
       var currentPairingIndex = totalNumberOfColumns;
       /// 1. store the cost
       costs.add( currentPairingIndex, generatePairingModel.costVar );
       /// 2. store the actual legs as triplets <#p, #l, flight>
       ///
       for (var l=1; l <= maxNbLegs; ++l) {   
         var flightRank  = generatePairingModel.flightVars[l];
         var isActualLeg = generatePairingModel.isActualLeg[l];
         //writeln("-- flight covered: ", f, ", #leg: ", l, ", f=", flightIndex);
         if ( isActualLeg <= 0.1 ) break;  /// stop at dummy legs.
            
         /// BEWARE: variable is 1..F, but Opl.item() has C-convention
         legs.add(currentPairingIndex, l , flightRank);
         thisOplModel.coveredFlights.add(flightRank);
       }//for           
       ++localNumberOfPairings;
       ++totalNumberOfColumns;
       //writeln("-- f=", f, ", #cols=", totalNumberOfColumns, ", #covered=", thisOplModel.coveredFlights.size); 
       if ( thisOplModel.coveredFlights.size >= numberOfFlights ) break;

     if ( 0 == localNumberOfPairings) {
         writeln("** ERROR: cannot find any pairing for flight: ", f, " final problem will be infeasible");
         retcode = -2;
         break;
     }
     generatePairingModel.end();
     pairingCP.end();
   }
  
   writeln("* end initial pairings phase" , ", cols=", totalNumberOfColumns, ", time=", getElapsedTime(timeorigin), "s.");
   writeln("* #skipped=", totalNumberOfSkipped);
   
   /// for debug purpose, write the legs and costs
   if ( 0 == retcode ) {
      print_initial_pairings(legs, costs, "minimal_pairings.dat");
    }      
   // this is the end
   writeln("* script returns with code: ", retcode)
   retcode; 
 }
