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
include "PairingGeneration_data.mod";

 /// The main loop
 
 
{TPairingLeg}  pairingLegs;
{TPairingCost} pairingCosts;
{int} bestCoveredFlights;

 main {
   includeScript("helpers.js");
   var retcode = 0;

   var MAX_INITIAL_PAIRINGS_PER_FLIGHT         = thisOplModel.PairingGenerationData.NumberOfInitialPairings;   // Initial pairings to cover each flight
   var PrintPeriod  = 20;   // Print frequency
   var isdebug = thisOplModel.PairingGenerationData.DebugMode >= 1;
   
   var time  = 0;          // Procedure time
   var date0;
   var totalTime;            // Total computation time 

   /******************************************************************************
    * INITIALIZATION:
    * Generate initial pairings that cover all flights
    ******************************************************************************/
   var generateOnePairingSource = new IloOplModelSource("GenerateOnePairing.mod");
   var generateOnePairingDef    = new IloOplModelDefinition(generateOnePairingSource);
   var masterDataSource         = new IloOplDataSource("FlightPairing.dat");
   var generationDataSource     = new IloOplDataSource("PairingGeneration.dat");
   // Load pairing cover model
   var generatePairingConfig =
      new IloOplRunConfiguration("GenerateOnePairing.mod", "FlightPairing.dat", "PairingGeneration.dat");
   var generatePairingModel = generatePairingConfig.oplModel;
   
   // to set the forcedCoveredFligh, I must use a data elements!!!
   var dummyGenerationData = new IloOplDataElements();
   dummyGenerationData.forcedCoveredFlight = -1;
   generatePairingModel.addDataSource(dummyGenerationData);
   ///
   generatePairingModel.generate();
   var generatePairingData  = generatePairingModel.dataElements;
   
   var allFlights = generatePairingData.flights;
   var nbFlights  = generatePairingData.flights.size;
   var maxNbLegs  = generatePairingData.parameters.maxNbLegs;
   
   writeln("* starting CP search for initial pairings", ", #flights=", nbFlights, ", #initial=", MAX_INITIAL_PAIRINGS_PER_FLIGHT);
   date0 = new Date();
   // Indices for master problem
   var legs  = thisOplModel.pairingLegs;
   var costs = thisOplModel.pairingCosts;
   var totalNumberOfColumns = 0;

   // Now, generate pairings for every flight
   for (var f=1; f <= nbFlights; f++) {
     var initialCP =  new IloCP();
     initialCP.param.Workers = 1;
     
     // IloOplModel
     var localGeneratePairingModel = new IloOplModel(generateOnePairingDef, initialCP);
     localGeneratePairingModel.addDataSource(masterDataSource);
     localGeneratePairingModel.addDataSource(generationDataSource);
     var flightGenerationData = new IloOplDataElements();
     flightGenerationData.forcedCoveredFlight = f;
     localGeneratePairingModel.addDataSource( flightGenerationData );
    
     localGeneratePairingModel.generate();     
     var localNumberOfPairings = 0;

     /// --- search loop for covering pairings
     //initialCP.param.RandomSeed = f;
     initialCP.startNewSearch();
     while (initialCP.next()) {
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
     
     initialCP.endSearch();
     if ( 0 == localNumberOfPairings) {
         writeln("** ERROR: cannot find any pairing for flight: ", f, " final problem will be infeasible");
         Opl.fail();
         retcode = -2;

     } else if ( localNumberOfPairings < MAX_INITIAL_PAIRINGS_PER_FLIGHT ) {
       ///  !!!
       /// This may be a problem: cannot find MAX_PAIRINGS pairings
       /// only a subset..        
       writeln("* warning: cannot find ", MAX_INITIAL_PAIRINGS_PER_FLIGHT, " pairings, only: ", localNumberOfPairings);
     }              
     if ( (f% PrintPeriod) == 0) {
       writeln("-- initial generation: ", Opl.floor( (100 * f)/nbFlights +.5), "%, #columns: ", totalNumberOfColumns, ", time=", getElapsedTime(date0));
     }
   }
  
   writeln("* end initial pairings phase", ", #columns=", totalNumberOfColumns, ", time=", getElapsedTime(date0), "s.");
   
   /// for debug purpose, write initial pairings to a file.
   if ( thisOplModel.PairingGenerationData.PrintFiles ) {
     print_initial_pairings(legs, costs,  "initial_pairings.dat");
   }     
   
   ///
   /// main loop stuff
   var lastLPObjective = -1;
   var currentLPObjective = 999999999;
   var lastDualHash     = -1;
   var currentDualHash  = 999999999;
   var nbIterations = 0;
   var MAX_NB_ITERATIONS = 30;
   var NB_RANDOM_COLUMNS = thisOplModel.PairingGenerationData.NumberOfRandomColumns;
   var lpCoveringSource  = new IloOplModelSource("LPCovering.mod");
   var lpCoveringDef     = new IloOplModelDefinition(lpCoveringSource);
   var mipCoveringSource = new IloOplModelSource("MIPCovering.mod");
   var mipCoveringDef    = new IloOplModelDefinition(mipCoveringSource);
   
   var generateRandomSource = new IloOplModelSource("GenerateOnePairingWithMaxCost.mod");
   var generateRandomDef    = new IloOplModelDefinition(generateRandomSource);
  
   var currentGenCost    = 999999999;
   var currentGenLength  = 8;
   var randomCP = new IloCP;
   randomCP.param.Workers = 1; // why???
    
   writeln("* starting main loop, max iters=", MAX_NB_ITERATIONS, ", #random=", NB_RANDOM_COLUMNS);
   while (nbIterations <= MAX_NB_ITERATIONS ) {
     ++nbIterations;
     // the LP covering model.
     var lpCoveringCplex  = new IloCplex();  
     var lpCoveringModel  = new IloOplModel(lpCoveringDef, lpCoveringCplex);
     lpCoveringModel.addDataSource(masterDataSource);
     lpCoveringModel.addDataSource(generationDataSource);
     
     var dynamicPairingData = new IloOplDataElements();
     dynamicPairingData.pairingLegs = legs;
     dynamicPairingData.pairingCosts = costs;
     lpCoveringModel.addDataSource(dynamicPairingData);
   
     lpCoveringModel.generate();
   
     //writeln("-- starting lp covering model solve");
     var lpCoveringOk = lpCoveringCplex.solve();
     if ( !lpCoveringOk ) {
       writeln("ERROR: lp covering model fails, stopping");
       retcode = -2;    
       break;
         
     }
     writeln(nbIterations, "> LP covering finds objective of: ", lpCoveringCplex.getObjValue());
     lpCoveringModel.postProcess();
     
     currentLPObjective = lpCoveringCplex.getObjValue();
     currentDualHash    = lpCoveringModel.dualHash;
     if ( lastDualHash >= 0) {
       //var delta = Opl.abs(currentLPObjective-lastLPObjective);
       var delta = Opl.abs(currentDualHash-lastDualHash);
       if ( delta <= 0.001) {
         //writeln("* LP covering does not improve, stopping, delta=", delta);
         writeln("* LP covering does not improve, stopping...");
         break;     
       };
     }
     
     ///
     /// generate best pairing.

     var bestPairingCP = new IloCP();
     bestPairingCP.param.branchLimit = thisOplModel.PairingGenerationData.SlaveModelBranchLimit;
     bestPairingCP.param.Workers = 1;
     var bestPairingSource = new IloOplModelSource("GenerateBestPairing.mod");
     var bestPairingDef    = new IloOplModelDefinition(bestPairingSource);
     var bestPairingModel  = new IloOplModel(bestPairingDef, bestPairingCP);
     /// master data
     bestPairingModel.addDataSource(masterDataSource);
     bestPairingModel.addDataSource(generationDataSource);
     /// dynamic data
     var dynamicBestPairingData = new IloOplDataElements();
     dynamicBestPairingData.coverct_duals = lpCoveringModel.coverCtDuals;
     //for (var d in lpCoveringModel.coverCtDuals) {
     //   writeln (d.flightIndex, " = ", d.coverCtDual);         
     //}
     bestPairingModel.addDataSource(dynamicBestPairingData);
   
     bestPairingModel.generate();
   
     var bestOK = bestPairingCP.solve();
     if ( !bestOK ) {
       writeln("** ERROR: generation of new column pairing FAILS");
       Opl.fail();
       retcode = -4;
     }
     if ( isdebug ) {
       writeln("-- best pairing model succeeds, obj=", bestPairingCP.getObjValue());
     }       
     bestPairingModel.postProcess();
     currentGenCost = bestPairingModel.genCost.cost;
     var newLegs = bestPairingModel.genLegs;
     currentGenLength = newLegs.size;
     
     var newPairingId = thisOplModel.pairingCosts.size;
    
   
     thisOplModel.pairingCosts.addOnly(newPairingId, currentGenCost);
     for (var l in newLegs) {
       thisOplModel.pairingLegs.addOnly(newPairingId, l.legRank, l.flightRank); 
     }
     //writeln("-- new number of pairings: ", thisOplModel.pairingCosts.size);
     
     /// try adding random columns.
     //randomCP.clear();
     var generateRandomPairingModel = new IloOplModel(generateRandomDef, randomCP);
     generateRandomPairingModel.addDataSource(masterDataSource);
     generateRandomPairingModel.addDataSource(generationDataSource);
     // dynamic data
     var generateRandomData = new IloOplDataElements();
     generateRandomData.tabuLength = currentGenLength;
     generateRandomData.costMax = currentGenCost;
     generateRandomData.forcedCoveredFlights = thisOplModel.bestCoveredFlights;
     generateRandomPairingModel.addDataSource(generateRandomData);
     generateRandomPairingModel.generate();
     var nbRandom = 0;
     while ( nbRandom <=  NB_RANDOM_COLUMNS) {
        randomCP.param.RandomSeed = nbRandom;
        if ( randomCP.solve() ) {
           generateRandomPairingModel.postProcess();
           // extract
           var randomCost = generateRandomPairingModel.genCost.cost;
           var randomLegs = generateRandomPairingModel.genLegs;
           
           var newPairingId = thisOplModel.pairingCosts.size;
           thisOplModel.pairingCosts.addOnly(newPairingId, randomCost);
           for (var rl in randomLegs) {
             thisOplModel.pairingLegs.addOnly(newPairingId, rl.legRank, rl.flightRank); 
           }  
           ++nbRandom;           
        } else {
          break;            
        }       
      }
      //writeln("-- new number of pairings: ", thisOplModel.pairingCosts.size, ", #random=", nbRandom);
     
     lastLPObjective = currentLPObjective;
     lastDualHash    = currentDualHash;
     // twist again...
   }
   ///now run the MIP covering stuff
   var mipCoveringCplex  = new IloCplex();  
   var mipCoveringModel  = new IloOplModel(mipCoveringDef, mipCoveringCplex);
   mipCoveringModel.addDataSource(masterDataSource);
   mipCoveringModel.addDataSource(generationDataSource);
     
   var dynamicPairingData = new IloOplDataElements();
   dynamicPairingData.pairingLegs = legs;
   dynamicPairingData.pairingCosts = costs;
   mipCoveringModel.addDataSource(dynamicPairingData);
   
   mipCoveringModel.generate();
   var mipOk = mipCoveringCplex.solve();
   if ( !mipOk ) {
      writeln("ERROR: MIP covering model fails, stop");
      retcode = -8;
      Opl.fail(); 
   } else {
     writeln("* final MIP covering: ", mipCoveringCplex.getObjValue());
     mipCoveringModel.postProcess();
   }
   
   
   // return code is 0 if ok, else negative....
   writeln("* main script returns with code: ", retcode)
   retcode; 
 }
