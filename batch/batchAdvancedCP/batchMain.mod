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
 
using CP;
 
string dataPath = ...;
int timeLimit = ...;
int seed = ...;

/** 
 * Solves a given OPL project with engine parameters changed by code.
 * In this example, are compared the KPIs of a model solved 
 * with a different engine.param.randomSeed value.
 */ 
main {
  writeln("* This OPL model is not compliant with cloud execution");
	
	includeScript("../kpiFile.js");
	includeScript("../htmlReport.js");
	
	/**
	 * Redefine this method to save the KPIs for a given modelName, optional 
	 * modelParam  and dataSet 
	 * using the solution from the engine.
	 * You can write your own method to define your custom KPIs.
	 * @param modelName Name of the model with the full path of the file
	 * @param modelParam Optional parameter changed by code on the model
	 * @param dataSetName Name of the data set with the full path
	 * @param engine Optimization engine
	 */
	function overload_output_saveAllKpi(modelName, modelParam, dataSetName, engine) {					           
		if (typeof(engine)=="IloOplMain.IloCplex") {
		    // CPLEX
		
		} else {
			// CP
			this.saveKpi( modelName, modelParam, dataSetName, engine, "obj", engine.getObjValue(), MAX);
			this.saveKpi( modelName, modelParam, dataSetName, engine, "seed", engine.param.randomSeed, MAX);
			this.saveKpi( modelName, modelParam, dataSetName, engine, "total time", engine.info.TotalTime, MIN);
			this.saveKpi( modelName, modelParam, dataSetName, engine, "solve time", engine.info.SolveTime, MIN);
	        this.saveKpi( modelName, modelParam, dataSetName, engine, "nb fails", engine.info.NumberOfFails, MIN);
	        this.saveKpi( modelName, modelParam, dataSetName, engine, "nb cons aggre", engine.info.NumberOfConstraintsAggregated, MIN);
	        this.saveKpi( modelName, modelParam, dataSetName, engine, "nb branches", engine.info.NumberOfBranches, MIN);
	        this.saveKpi( modelName, modelParam, dataSetName, engine, "nb choices", engine.info.NumberOfChoicePoints, MIN);
		}	
	} 
	
	/**
	 * Solves the oplProject for a given random seed and 
	 * timeLimit, and then save the resulting KPIs the file kpiFile.
	 * @param oplProject The OPL project
	 * @param seed The random seed
	 * @param timeLimit The time limit
	 * @param kpiFile The KPI file
	 */
	function solveModel( oplProject, seed, timeLimit, kpiFile ) {
	  	writeln("solving ", oplProject, " with seed=", seed);
  		var prj = new IloOplProject(oplProject);
		var rc = prj.makeRunConfiguration();
  		rc.oplModel.generate();
  		var engine = rc.cp;
  		// Change by code the random seed and the time limit
  		engine.param.randomSeed = seed;
  		engine.param.timeLimit = timeLimit;
  		if (engine.solve()){
  		    // Save the KPI after the solve
			kpiFile.saveAllKpi(oplProject, "Seed=" + seed, oplProject, engine);
		}
		rc.end();
		prj.end();
 	}	  
	/**
	 * Solves the oplProject for a given random seed and 
	 * timeLimit, and then save the resulting KPIs the file kpiFile.
	 * @param oplProject The OPL project
	 * @param seed The random seed
	 * @param timeLimit The time limit
	 */
	function solveModels(oplProject, seed, timeLimit) {		
		var kpiFileName = getKpiFileName(oplProject);
		var kpiFile = new KpiOutputFile(kpiFileName);
		// Redefine the save kpi method
		kpiFile.saveAllKpi = overload_output_saveAllKpi;
		// For seed ranging from zero to the value specified in the path.dat 
		// solve the CP model and save the resulting KPI
		for (var i = 0; i<= seed; i++){ 
			solveModel(oplProject, i, timeLimit, kpiFile);
      	}
		// Close the kpi file
		kpiFile.close();
		return true;
	}
	
	/**
	 * Returns the name of the KPI file.
	 */
    function getKpiFileName(modelFile) {
		return "cpoKPIs.kpi";
	}
	//**********************************************************/
	var status = true;
	thisOplModel.generate();
  	
	var oplDataPath = thisOplModel.dataElements.dataPath;
	var timeLimit = thisOplModel.timeLimit;
	var seed = thisOplModel.seed;		
		
	// Solve the opl models if needed and generate the related kpi files
	if (status) { 
		status = solveModels(oplDataPath, seed, timeLimit);
	}
	// Generate the html kpi comparator
	if (status) {
		var htmlFileName = "report.html";
		var html = new HtmlReportFile(htmlFileName);
		// Array of models
		var modelNames = new Array();
		modelNames[modelNames.length] = oplDataPath
		status = html.generateReport(modelNames, modelNames);
	}
	status;
}
