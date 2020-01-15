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


int checkResults=1; // In order to check objectives

execute {
  function ParseDat(dataFiles) {
    if (dataFiles == "") 
      return null;
    else {
      var pos = 0;
      var datFileNames = new Array();
      while (dataFiles.indexOf(",", pos) != -1) {
        var pos2 = dataFiles.indexOf(",", pos);
        datFileNames[datFileNames.length] = dataFiles.substring(pos, pos2);
        pos = pos2+1;
      }
      datFileNames[datFileNames.length] = dataFiles.substring(pos);
      return datFileNames;
    }
  }
  function ModelInfo(dirName, modName, datParam, expRes) {
    this.dir = dirName;
    this.name = modName;
    this.data = ParseDat(datParam);
    this.result = expRes;
  }
  function AddModel(models, dir, name, dat, res) {
    models[models.length] = new ModelInfo(dir, name, dat, res);
  }
  function isNearEqual(result, expectedResult) {
    var tolerance = 0.000001;
   return Math.abs(expectedResult-result)<tolerance;
  }
}

main {
  // activate end() method in the IDE
  thisOplModel.settings.mainEndEnabled = true;
  
  writeln("Executing some of the distributed examples...");
  writeln();
  writeln();
  
  var path = "";
  var OK = true;

  var models = new Array();
  var modelCurr = 0;


  AddModel(models, "../blending", "blending.mod", "blending.dat", 653.61);
  AddModel(models, "../cutstock", "cutstock_main.mod", "cutstock.dat", 0);
  AddModel(models, "../timetabling", "timetabling.mod", "timetabling-base.dat,timetabling-small.dat", 20);
  AddModel(models, "../sched_bridge", "sched_bridge.mod", "sched_bridge.dat",null); 
   

  while (modelCurr < models.length ) {
    var withData = true; 
    var dirName = models[modelCurr].dir;
    var modelName = models[modelCurr].name;
    var dataName = models[modelCurr].data;
    var expectedResult = models[modelCurr].result;

    if (dataName.length <= 0)
      withData = false;
  
    modelName = path + dirName + "/" + modelName;
    
    var allName;
    if (withData) {
      allName = modelName + " - " ;
      for (var i=0; i<dataName.length; i++) {
        dataName[i] = path + dirName + "/" + dataName[i];
        allName = allName + dataName[i] + " ";
      }
    } else {
      allName = modelName + " - without data file";
    }
    writeln("---------------");
    writeln("solving: ", allName);
    var source = new IloOplModelSource(modelName);
    
    var algo;      
    var def = new IloOplModelDefinition(source);
    
    if (def.isUsingCplex())
    {
      algo = new IloCplex(); 
    }  
    if (def.isUsingCP())
    {
      algo = new IloCP();       
    }
    var theModel;
    
    theModel= new IloOplModel(def,algo);
     
    
    if (withData) {
      var data = new Array();
      for (i=0; i<dataName.length; i++) {
        data[i] = new IloOplDataSource(dataName[i]);
        theModel.addDataSource(data[i]);
      }
    }
    
    var result;
    if (def.hasMain()) {
      result = theModel.main();
      if ((expectedResult != null && result != expectedResult) || (expectedResult==null && result!=0)) {
        OK = false;
        writeln(allName, " is NOT OK");
        break;
      } else {
        writeln(allName, " is OK");
      } 
    } else {
      theModel.generate();
      if ( algo.solve() ) {
        result = algo.getObjValue();
        if (expectedResult != null) {
           if (thisOplModel.checkResults==1) 
           if (isNearEqual(result,expectedResult)) {
             writeln(allName, " is OK");
             theModel.postProcess();
           } else {
             writeln("Fail to solve: ", allName);
             writeln("\tExpected result: ", expectedResult, " found result: ", result);
             OK = false;
             break;
           }
        }
      } else {
        writeln("Fail to solve: ", allName);
        writeln("\tNo solution found!");
        OK = false;
        break;
      }
    }  
    theModel.end();
    algo.end();
    def.end();
    if (withData) {
      for (i=0; i<data.length; i++)
        data[i].end();
    }
    source.end();
    modelCurr = modelCurr + 1;
  }
  writeln("---------------");
  writeln();
  if (OK) {
    writeln("All models have been solved.");
  } else {
    writeln("Not all models have been solved as expected.");
  }
  writeln();

  (OK)?0:1;
}
