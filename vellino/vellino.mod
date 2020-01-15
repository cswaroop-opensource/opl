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

include "vellinocommon.mod";

main {
   var master = thisOplModel;
   master.generate();
   var data = master.dataElements;
      
   var genBin = new IloOplRunConfiguration("vellinogenBin.mod");
   genBin.oplModel.addDataSource(data);
   genBin.oplModel.generate();
   genBin.cp.startNewSearch();
   while (genBin.cp.next()) {  
     genBin.oplModel.postProcess();
     data.Bins.add(genBin.oplModel.newId, 
                   genBin.oplModel.colorStringValue, 
                   genBin.oplModel.n.solutionValue);
   }
   genBin.cp.endSearch();
   genBin.end();
   var chooseBin = new IloOplRunConfiguration("vellinochooseBin.mod");
   chooseBin.cplex = cplex;   
   chooseBin.oplModel.addDataSource(data);   
   chooseBin.oplModel.generate();
   if (chooseBin.cplex.solve()) {
     chooseBin.oplModel.postProcess();
   } 
   chooseBin.end();
}
