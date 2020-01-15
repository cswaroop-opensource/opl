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

// Constants
MOD_FILE_INDEX=0;
MOD_PARAM_INDEX=1;
DAT_FILE_INDEX=2;
KPI_NAME_INDEX=3;
KPI_VALUE_INDEX=4;
MIN_MAX_INDEX=5;
CSV_SEPARATOR = ";";
MIN = "MIN";
MAX = "MAX";


/**
 * Constructs a KpiOutputFile with the file passed as parameter.
 */
function KpiOutputFile(kpiFileName) {
    this.fileName = kpiFileName;
	this.kpiFile = new IloOplOutputFile( kpiFileName, false);
	
	// Add headers
	this.kpiFile.writeln( "MODEL_FILE" + CSV_SEPARATOR  + 
	                 "MODEL_PARAM" + CSV_SEPARATOR  +
			         "DATA_FILE" +  CSV_SEPARATOR  +
			         "KPI_NAME" + CSV_SEPARATOR  + 
			         "KPI_VALUE" +  CSV_SEPARATOR,
			         "MIN_OR_MAX");
	// Add the methods
	this.getName = output_getName;
	this.close = output_close;
	this.saveKpi = output_saveKpi;
	this.saveAllKpi = output_saveAllKpi;
} 

/**
 * Returns the KPI file name.
 */		
function output_getName() {
  return this.fileName;
}

/**
 * Closes the KPI output stream.
 */	
function output_close() {
  this.kpiFile.close();
}

/**
 * Saves the KPIs for a given modelName and dataSet 
 * using the solution from the engine.
 * You can write your own method to define your custom KPIs.
 * @param modelName Name of the model with the full path of the file
 * @param modelParam Optional parameter changed by code on the model
 * @param dataSetName Name of the data set with the full path
 * @param engine Optimization engine
 * @param previousTime Time before the solve
 */
function output_saveAllKpi(modelName, modelParam, dataSetName, engine, previousTime) {					           
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
 * Saves one KPI for a given modelName and dataSet 
 * using the solution from the engine.
 * You can write your own method to define your custom KPIs.
 * @param modelName Name of the model with the full path of the file
 * @param modelParam Optional parameter changed by code on the opl model 
 * @param dataSetName Name of the data set with the full path
 * @param engine Optimization engine
 * @param kpiName Name of the KPI
 * @param kpiValue Value of the KPI
 * @param minOrMax MIN or MAX, to say whether the value is minimized or maximized by the engine.
 */
function output_saveKpi(modelName, modelParam, dataSetName, engine, kpiName, kpiValue, minOrMax) {
	var prefix = modelName + CSV_SEPARATOR + modelParam + CSV_SEPARATOR + dataSetName + CSV_SEPARATOR;

	this.kpiFile.writeln( prefix + kpiName + CSV_SEPARATOR  + kpiValue +  CSV_SEPARATOR + minOrMax);
}


/**
 * Constructs a KpiInputFile to read the content of a KPI file.
 * @param kpiFileName Name of the KPI file.
 */
function KpiInputFile(kpiFileName) {
    this.fileName = kpiFileName;
	this.kpiFile = new IloOplInputFile( kpiFileName);
	
	this.firstLine=true; // internal attribute to skip the first line
	
	// Add the methods
	this.exists = input_exists;
	this.next = input_next;
	this.close = input_close;
} 

/**
 * Returns true if the KPI file exists, false otherwise.
 */
function input_exists() {
  return this.kpiFile.exist();
}

/**
 * Closes the input stream.
 */
function input_close() {
  return this.kpiFile.close();
}

/**
 * Data structure of a CSV line
 */
function KpiFileLine(modelName, modelParam, dataFile, kpiName, kpiValue, isMinimized) {
  	this.modelName = modelName;
  	this.modelParam = modelParam;
  	this.dataFile = dataFile;
  	this.kpiName = kpiName;
  	
  	// parseFloat or parseInt do not know how to handle the string Infinity, 
  	// so need to do it yourself
  	if (kpiValue=="Infinity") {
  		this.kpiValue = Infinity;
  	} else if (kpiValue=="-Infinity") {
  		this.kpiValue = -Infinity;
  	} else {
  		this.kpiValue = parseFloat(kpiValue);
  	}
  	this.isMinimized = isMinimized;
};

/**
 * Returns the next KpiFileLine from the KPI file 
 * or null if there are no more lines.
 */
function input_next() {
    var result = null;
    if (!this.kpiFile.eof) {
	    var line = this.kpiFile.readline();
	  	if (this.firstLine==true) {
	  		// Skip the first line of csv header
	  		line = this.kpiFile.readline();
	  		this.firstLine = false;
	  	}
	  	if (line!=null) {
	  	    var lines = line.split(CSV_SEPARATOR);
	  	    result = new KpiFileLine(lines[0], 
		  	    lines[1]=="null"? null: lines[1], 
		  	    lines[2],
		  	    lines[3], 
		  	    lines[4],
		  	    (lines[5]=="MIN"));
	  	}
  	}
  	
	return result;
}


