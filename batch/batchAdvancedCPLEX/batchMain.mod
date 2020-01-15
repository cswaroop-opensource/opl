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
 
string dataPath = ...;

tuple BatchModelType {
  	string name;
  	int needToSolve;
};

// Set of OPL model of type T defined above 
{BatchModelType} models = ...;  

/** 
 * Limitations:
 * solve only with a mod and a dat file (or a set of dat file), not possible with only a mod.
 * not compatible with opl config
 * not compatible ops file
 */
main {
  writeln("* Note: This OPL model is not compliant with cloud execution");
	
	includeScript("../kpiFile.js");
	includeScript("../htmlReport.js");
	
	/**
	 * Modify this method to save the KPIs for a given modelName, optional 
	 * modelParam  and dataSet 
	 * using the solution from the engine.
	 * You can write your own method to define your custom KPIs.
	 * @param modelName Name of the model with the full path of the file
     * @param modelParam Optional parameter changed by code on the model
     * @param dataSetName Name of the data set with the full path
     * @param engine Optimization engine
     * @param previousTime Time before the solve
     */ 
    function overload_output_saveAllKpi(modelName, modelParam, dataSetName, engine, previousTime) {		
		if (typeof(engine)=="IloOplMain.IloCplex") {
		    // CPLEX
			this.saveKpi( modelName, modelParam, dataSetName, engine, "best obj", engine.getBestObjValue(), MAX);
			this.saveKpi( modelName, modelParam, dataSetName, engine, "status", engine.getCplexStatus(), MIN);
			this.saveKpi( modelName, modelParam, dataSetName, engine, "n cols", engine.getNcols(), MIN);
			this.saveKpi( modelName, modelParam, dataSetName, engine, "n rows", engine.getNrows(), MIN);
		    this.saveKpi( modelName, modelParam, dataSetName, engine, "n nodes", engine.getNnodes(), MIN);
			this.saveKpi( modelName, modelParam, dataSetName, engine, "n iterations", engine.getNiterations(), MIN);
			this.saveKpi( modelName, modelParam, dataSetName, engine, "obj", engine.getObjValue(), MAX);
			this.saveKpi( modelName, modelParam, dataSetName, engine, "time", engine.getCplexTime() - previousTime, MIN);		
			this.saveKpi( modelName, modelParam, dataSetName, engine, "gap", engine.getMIPRelativeGap(), MIN);
			this.saveKpi( modelName, modelParam, dataSetName, engine, "n ints", cplex.getNintVars(), MIN);
			this.saveKpi( modelName, modelParam, dataSetName, engine, "n nzs", cplex.getNNZs(), MIN);
			this.saveKpi( modelName, modelParam, dataSetName, engine, "n bins", cplex.getNbinVars(), MIN);
			this.saveKpi( modelName, modelParam, dataSetName, engine, "n qcs", cplex.getNQCs(), MIN);
			this.saveKpi( modelName, modelParam, dataSetName, engine, "n sos", cplex.getNSOSs(), MIN);
			
		} else {
			// CP
		
		}	
	} 	
	
	
    /**
	 * Returns the name of the KPI file.
	 */	
	function getKpiFileName(modelFile) {
		return modelFile.absolutePath.split(".")[0] + ".kpi";
	}
    /**
	 * Solves the oplModelName with the dataSetPath, 
	 * and then save the resulting KPIs the file kpiFile.
	 * @param oplModelDefinition The Definition
	 * @param oplModelName The MOD file
	 * @param dataSetPath The DAT file name or directory of DAT files
	 * @param kpiFile The KPI file
	 */
	 function solveModel( oplModelDefinition, oplModelName, dataSetPath, kpiFile ) {
	  	var engine = "";
	  	var foundADatFile = false;
	  	
	  	if( oplModelDefinition.isUsingCP() ) {
			engine = new IloCP();  
		} else {
		   	engine = new IloCplex();		   	
		}
		var model = new IloOplModel( oplModelDefinition, engine );

		var dataSet = new IloOplFile( dataSetPath );
		if( !dataSet.exists ) {
			  writeln( "ERROR : cannot find the specified file: ", dataSet.name);      
		} else if (!dataSet.isHidden) {
		    if( !dataSet.isDirectory ) {
			    // a file
			    if ( dataSet.name.lastIndexOf(".dat")!=-1 ) {
			      // A dat file
				  var dataSource = new IloOplDataSource(dataSet.name);
				  model.addDataSource(dataSource);
				  foundADatFile = true;
				} else if (dataSet.name.lastIndexOf(".kpi")==-1 &&
						   dataSet.name.lastIndexOf(".html")==-1) {	
				  writeln( "ERROR : ", dataSet.name, 
				           " is not a *.dat file");      
				}
	  		} else {
	  		  var f = dataSet.getFirstFileName();
	  		  while( f != null ) {
	  		    if ( f.lastIndexOf(".dat")!=-1 ) {
	  		      // A dat file	
				  var ds1 = new IloOplDataSource(f);
				  model.addDataSource(ds1);
				  foundADatFile = false;
	  		    } else {
				  writeln( "ERROR : Directory ", dataSet.name,
				           " contains a file that is not a *.dat :", f);
				}
				f = dataSet.getNextFileName();
	      	  }
	    	} 
		}
    	if (foundADatFile) {    	
    	  addDatFileName(dataSet.absolutePath);
    	  // Only solve if a dat file has been found	
    	  writeln("* DAT FILE", dataSetPath);
    	  var previousTime = engine.getCplexTime();
    	  model.generate();
		  engine.solve();
		  kpiFile.saveAllKpi(oplModelName, null, dataSet.absolutePath, engine, previousTime);
		  
		  model.end();
		  engine.end();
		}
 	}
 		  
	/**
	 * Solves one by one all the models for each DAT file
	 * of sub directory of DAT files.
	 * @param dataDir Either a DAT file or a set of sub directory containing the DAT files.
	 * @param models Set of BatchModelType
	 */
	 function solveModels(dataDir, models) {		
		for (var model in models ) {
			var oplModelName = model.name;
			if (model.needToSolve) {
				// Check the validity of the mod file
				var oplModelFile = new IloOplFile(oplModelName);
				if( !oplModelFile.exists ) {
					writeln( "ERROR : Cannot find specified file: ", oplModelName);
					return false;
				} else if (oplModelFile.isDirectory != false) {
					writeln( "ERROR : Not a file: ", oplModelName);
					return false;
				} else {
					writeln( "--------------------");
					writeln( "MODEL : ", oplModelName);
					writeln( "--------------------");
					var kpiFileName = getKpiFileName(oplModelFile);
					var kpiFile = new KpiOutputFile(kpiFileName);
					// Redefine the save kpi method
		            kpiFile.saveAllKpi = overload_output_saveAllKpi;
		
					var source = new IloOplModelSource(oplModelName);	
				  	var def = new IloOplModelDefinition(source);
		
					// Solve
					var f = dataDir.getFirstFileName();
					while( f != null ) {  	
					  	var entryName = dataDir.name + dataDir.separator + f; 
					    solveModel( def, oplModelFile.absolutePath, entryName, kpiFile);
								
						f = dataDir.getNextFileName();
					}
					def.end();	
					source.end();
					// Close the kpi file
					kpiFile.close();
				}
			}
		}
		return true;
	}
	/*
	 * Adds a datFileName in the array if not already added.
	 */
	function addDatFileName(datFileName ) {
		var found = false;
		for (var j=0; (j <datFileNames.length) && !found; j++) {
			if (datFileNames[j]==datFileName) {
				found = true;
			}
		}
		if (found==false) {
			datFileNames[datFileNames.length] = datFileName;
		}
	}
	
	
	//**********************************************************/
	var status = true;
	thisOplModel.generate();
  	
	var oplDataPath = thisOplModel.dataElements.dataPath;		
	var datFileNames = new Array();
	
	// Check the validity of the data directory
	var dataDir = new IloOplFile(oplDataPath);
	if( !dataDir.exists ) {
		writeln( "ERROR : Cannot find specified file: ", oplDataPath);
		status = false;
	} else if (dataDir.isDirectory != true) {
		writeln( "ERROR : Not a directory: ", oplDataPath);
		status = false;
	}
	
	// Solve the opl models if needed and generate the related kpi files
	if (status) { 
		status = solveModels(dataDir, thisOplModel.models);
	}
	// Generate the html kpi comparator
	if (status) {
		var htmlFileName = "report.html";
		var html = new HtmlReportFile(htmlFileName);
		var modelNames = new Array();
		for (var model in thisOplModel.models ) {
			modelNames[modelNames.length] = model.name;
		}		
		status = html.generateReport(modelNames, datFileNames);
	}
	status;
}
