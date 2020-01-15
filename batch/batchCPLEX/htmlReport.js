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
 * Generates the html header of the report.
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

	
} 
/*
 * Generates the html footer of the report.
 */
function _generateFooterReport() {
	

	this.htmlFile.writeln( "</body>");
	this.htmlFile.writeln( "</html>");
}


/*
 * Generates the report
 */
function _generateReport(kpiFileName) {
	writeln( "Generate the HTML Report ", this.fileName);
	this.generateHeaderReport();
	var values = "";
	var header = "";	        			
	// Open the kpi file
	var kpiFile = new KpiInputFile(kpiFileName);
	if ( !kpiFile.exists ) {
		writeln( "ERROR : cannot find the specified file ", kpiFileName);  
	}

	var line = kpiFile.next();
	var name = "";	        
			        
	while (line!=null && line.modelName != null) {
		if (line.modelName != name){
			name = line.modelName;
			header+= "<table border=\"1\">";
			header+="<tr><td><b>Model: </b><i><b>"+line.modelName+"</b></i></td></tr>";					
		}	
		header += "<tr><td>" + line.kpiName + "</td>"; 
		header+= "<td>" + line.kpiValue + "</td></tr>";
		line = kpiFile.next();
		if (line == null || name != line.modelName){					
			header+="</table>";
			header += "<br/><br/>";
		}
	}
	// a row per dat file or per directory of dat files
	this.htmlFile.writeln( header );
	
	// Close the kpi file
	kpiFile.close();
    this.generateFooterReport();	
	// Close the html file
	this.htmlFile.close(); 
}

