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
int timeLimit = ...;

/** 
 * Solves one by one all the LP or MPS from a given directory.
 */
main {
  writeln("* This OPL model is not compliant with cloud execution");
	
	includeScript("../kpiFile.js");
	includeScript("htmlReport.js");
	
	
	var KPI_FILE_NAME = "cplexKPIs.kpi";
	
	/**
	 * Solves  entryName for a given timeLimit
	 * and then save the resulting KPIs the file kpiFile.
	 * @param entryName The LP or MPS
	 * @param timeLimit The time limit
	 * @param kpiFile The KPI file
	 */
	 function solveModel( entryName, timeLimit, kpiFile ) {
	  	writeln("solving ", entryName);
	  	var engine = new IloCplex();
		engine.importModel(entryName);
		if (timeLimit != 0) engine.tilim = timeLimit;
		var previsousTime = engine.getCplexTime();
		engine.solve();
	  	kpiFile.saveAllKpi(entryName, null, entryName, engine, previsousTime);
	  	
	  	engine.end();
 	}	  
	/**
	 * Solves all the LP and MPS hold in the directory dataDir.
	 * @param dataDir Directory containing LP or MPS
	 * @param timeLimit Time limit for the run
	 */
	function solveModels(dataDir, timeLimit) {		
		var f = dataDir.getFirstFileName();
		var kpiFile = new KpiOutputFile(KPI_FILE_NAME);		
		while( f != null ) {  	
			if ( f.lastIndexOf(".mps")!=-1 || f.lastIndexOf(".lp")!=-1 || f.lastIndexOf(".sav")!=-1) {
		  		var entryName = dataDir.name + dataDir.separator + f; 
		    	solveModel(entryName, timeLimit, kpiFile);					
			}	
			else writeln("		ignoring ", f);				
			f = dataDir.getNextFileName();			
		}
		// Close the kpi file
		kpiFile.close();
		return true;
	}
	//**********************************************************/
	var status = true;
	thisOplModel.generate();
  	
	var oplDataPath = thisOplModel.dataElements.dataPath;
	var timeLimit = thisOplModel.timeLimit;		
	
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
		status = solveModels(dataDir, timeLimit);
	}
	// Generate the html kpi comparator
	if (status) {
		var htmlFileName = "report.html";
		var html = new HtmlReportFile(htmlFileName)
		status = html.generateReport(KPI_FILE_NAME);
	}
	status;
}
