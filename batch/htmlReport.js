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


function HtmlReportFile(htmlFileName) {
    this.fileName = htmlFileName;
 	this.htmlFile = new IloOplOutputFile( this.fileName, false);

 	// Add the object methods
 	this.generateReport = _generateReport;
 	this.generateHeaderReport = _generateHeaderReport;
 	this.generateFooterReport = _generateFooterReport;
}

/*
 * Generates the HTML header of the report.
 */
function _generateHeaderReport() {

	this.htmlFile.writeln( "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">");
    this.htmlFile.writeln( "<html xmlns=\"http://www.w3.org/1999/xhtml\" >");
	this.htmlFile.writeln( "<head>");
	this.htmlFile.writeln( "    <title>KPI Report</title>");
	this.htmlFile.writeln( "</head>");
	this.htmlFile.writeln( "<style type=\"text/css\"></style>");
	this.htmlFile.writeln( "<body>");
	
	this.htmlFile.writeln( "<p>KPI report</p>" );
	this.htmlFile.writeln( "<table border=\"1\">");
} 
/*
 * Generates the HTML footer of the report.
 */
function _generateFooterReport() {
	this.htmlFile.writeln( "</table>");
	this.htmlFile.writeln( "</body>");
	this.htmlFile.writeln( "</html>");
}


function Kpi(kpiName, kpiValue, isMinimized) {
	this.kpiName = kpiName;
	this.kpiValue = kpiValue; 
	this.isMinimized = isMinimized;
}

function ModelKpis( modelName, modelParam ) {
  this.modelName = modelName;
  this.modelParam = modelParam;
  this.kpis = new Array();
  this.add = modelkpi_add;
  this.getKpi = modelkpi_getKpi;
}

function modelkpi_add(kpiName, kpiValue, isMinimized) {
	this.kpis[this.kpis.length] = new Kpi(kpiName, kpiValue, isMinimized);
}

function modelkpi_getKpi(kpiName) {
	for (var l=0; l < this.kpis.length; l++) {
		if (this.kpis[l].kpiName == kpiName) {
			return this.kpis[l];
		}
	}
	return null;
}

function DatFileResult(datFile) {  
  this.datFile = datFile;
  this.models = new Array();
  this.kpiNames = new Array();
  this.bestKpiValue = new Array();
  this.worstKpiValue = new Array();
  
  // Add the methods
  this.add = dataresult_add;
  this.getModelKpis = dataresult_getModelKpis;
  this.addKpiName = dataresult_addKpiName;
  this.getValue = dataresult_getValue;
  this.getBestValue = dataresult_getBestValue;
  this.getWorstValue = dataresult_getWorstValue;
}

function dataresult_add(modelName, modelParam, kpiName, kpiValue, isMinimized) {
	var modelKpis = this.getModelKpis(modelName, modelParam);
	modelKpis.add(kpiName, kpiValue, isMinimized);
	this.addKpiName(kpiName, kpiValue, isMinimized);
}

function dataresult_getValue(modelName, modelParam, kpiName) {
	var kpi = this.getModelKpis(modelName, modelParam).getKpi(kpiName);
	if (kpi!=null) {
		return kpi.kpiValue;
	}
	return null;
}

function dataresult_getBestValue(kpiName) {
	for (var j=0; j <this.kpiNames.length; j++) {
		if (this.kpiNames[j]==kpiName) {
			return this.bestKpiValue[j];
		}
	}
	return null;
}

function dataresult_getWorstValue(kpiName) {
	for (var j=0; j <this.kpiNames.length; j++) {
		if (this.kpiNames[j]==kpiName) {
			return this.worstKpiValue[j];
		}
	}
	return null;
}

function dataresult_addKpiName(kpiName, kpiValue, isMinimized ) {
	var found = false;
	for (var j=0; (j <this.kpiNames.length) && !found; j++) {
		if (this.kpiNames[j]==kpiName) {
			found = true;
			if (isMinimized) {
			    if (kpiValue < this.bestKpiValue[j]) {
			    	this.bestKpiValue[j] = kpiValue;
			    }
			    if (kpiValue > this.worstKpiValue[j]) {
			    	this.worstKpiValue[j] = kpiValue;
			    }
			} else {
				if (kpiValue > this.bestKpiValue[j]) {
			    	this.bestKpiValue[j] = kpiValue;
			    }
			    if (kpiValue < this.worstKpiValue[j]) {
			    	this.worstKpiValue[j] = kpiValue;
			    }
			}
		}
	}
	if (found==false) {
		this.kpiNames[this.kpiNames.length] = kpiName;
		this.bestKpiValue[this.bestKpiValue.length] = kpiValue;
		this.worstKpiValue[this.worstKpiValue.length] = kpiValue;
	}
}

function dataresult_getModelKpis(modelName, modelParam) {
    for (var k=0; k < this.models.length; k++) {
		if (this.models[k].modelName == modelName && 
		    this.models[k].modelParam == modelParam) {
			return this.models[k];
		}
	}
	// Not found so create it
	var result = new ModelKpis(modelName, modelParam);
	this.models[this.models.length] = result;
	return result;
}


/*
 * Generates the report
 * @param modelNames Array of model
 * @param modelParams Array of parameter changes by code on the model.
 * @param datFileNames Array of dat file
 */
function _generateReport(modelNames, datFileNames) {
	writeln( "Generate the HTML Report ", this.fileName);
	this.generateHeaderReport();
    var grayBackground = false;
    for (var k=0;k < datFileNames.length; k++) {
        var datFileName = datFileNames[k];
	    var datResult = new DatFileResult();
		// Extract the KPIs and build a data structure to aggregate the result
        for (var m=0; m < modelNames.length; m++ ) {
        	var oplModelName = modelNames[m];
			var kpiFileName = getKpiFileName( new IloOplFile(oplModelName) );
	        			
			// Open the KPI file
			var kpiFile = new KpiInputFile( kpiFileName);
	        if ( !kpiFile.exists ) {
	        	writeln( "ERROR : cannot find the specified file ", kpiFileName);  
	        }
            
	        var line = kpiFile.next();
			while (line!=null) {
				if (line.dataFile==datFileName) {
				    // Add the KPI to the data structure
				    datResult.add(line.modelName, line.modelParam, line.kpiName, line.kpiValue, line.isMinimized);
				}
				line = kpiFile.next();
	        }
			
	        // Close the KPI file
			kpiFile.close();
		}

		// Generate the HTML by reading back the data structure 
		for (var m=0; m < datResult.models.length; m++) {
        	var oplModelName = datResult.models[m].modelName;
        	var oplModelParam = datResult.models[m].modelParam;
        	  	
        	var oplModelFile = new IloOplFile(oplModelName)
			if (k==0 && m==0) {
				// Headers only for the first line
				this.htmlFile.writeln( "  <tr style=\"background-color:Blue; color:White\" >");
				if (oplModelName!= datFileName) this.htmlFile.writeln( "    <td>Dat File</td>" );
				this.htmlFile.writeln( "    <td>Mod File</td>" );
				if (oplModelParam!=null) this.htmlFile.writeln( "    <td>Model Param</td>" );
				for (var i=0; i < datResult.kpiNames.length; i++) {
					this.htmlFile.writeln( "    <td>" + datResult.kpiNames[i] + "</td>" );
				}
			    this.htmlFile.writeln( "  </tr>");
			}
			
			// A row per solve
			this.htmlFile.writeln( "  <tr " + (grayBackground? "style=\"background-color:Silver\"" : "") +  ">");
			if (oplModelName!= datFileName) {
				if (m==0) {
					this.htmlFile.writeln( "    <td><a href=\"" + datFileName + "\">" + datFileName + "</a></td>" );
				} else {
					this.htmlFile.writeln( "    <td>...</td>" );
				}
			}
			if (oplModelFile.exists) {
			  this.htmlFile.writeln( "    <td><a href=\"" + oplModelFile.absolutePath + "\">" + oplModelName + "</a></td>" );
			} else {
			  this.htmlFile.writeln( "    <td>" + oplModelName + "</td>" );
			}
			if (oplModelParam!=null) this.htmlFile.writeln( "    <td>" + oplModelParam + "</td>" );
			for (var i=0; i < datResult.kpiNames.length; i++) {
			    var kpiName = datResult.kpiNames[i];
			    var value = datResult.getValue(oplModelName, oplModelParam, kpiName);
			    var best = datResult.getBestValue(kpiName);
			    var worst = datResult.getWorstValue(kpiName);
			    if (value==best) {
					this.htmlFile.writeln( "    <td style=\"color:Green\">" + value + "</td>" );
			    } else if (value==worst) {
					this.htmlFile.writeln( "    <td style=\"color:Red\">" + value + "</td>" );
			    } else {
			    	this.htmlFile.writeln( "    <td>" + value + "</td>" );
			    }
			}
		    this.htmlFile.writeln( "  </tr>");
		}
		grayBackground= !grayBackground; // alternate the background color
    }	
    this.generateFooterReport();
	
	// Close the HTML file
	this.htmlFile.close(); 
}