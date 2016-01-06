<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc.  Copyright (c) 2009-2016.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!---
/* ***************************************************************
/*
Author:
	PaperThin Inc.
	M. Carroll
Name:
	Import Custom Element
Summary:
	Script to process the importing of a Custom Element from an datasource outside
		of CommmonSpot
Version:
	1.0
History:
	2009-10-21 - MFC - Created
--->
<cfcomponent displayname="importCE" extends="ADF.core.SiteBase">

<cfset variables.IMPORTCEPAGE = "#request.site.url#import/index.cfm">

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$controller
Summary:
	Controller for the ccapi_import form.
Returns:
	Void
Arguments:
	String - ceName - Custom Element name.
	Boolean - restart - Restart the import process at the begining.
	Numeric - passCount - Number of records to import per pass.
	Boolean - scheduleProcess - Flag to set for scheduling the process.
	Numeric - delayMinutes - Number of minutes to delay between process runs.
	String - logFileName - Log file name.
	Numeric - startAt - Data position to start the import at.
History:
	2009-10-21 - MFC - Created
--->
<cffunction name="controller" access="public" returntype="void" hint="Controller for the ccapi_import form.">
	<cfargument name="ceName" type="string" required="true" hint="Custom Element name.">
	<cfargument name="restart" type="boolean" required="false" default="false" hint="Restart the import process at the begining.">
	<cfargument name="passCount" type="numeric" required="false" default="1" hint="Number of records to import per pass.">
	<cfargument name="scheduleProcess" type="boolean" required="false" default="false" hint="Flag to set for scheduling the process.">
	<cfargument name="delayMinutes" type="numeric" required="false" default="5" hint="Number of minutes to delay between process runs.">
	<cfargument name="logFileName" type="string" required="false" default="import_element.log" hint="Log file name.">
	<cfargument name="startAt" type="numeric" required="false" default="0" hint="Data position to start the import at.">
	
	<cfscript>
		var argPassStruct = StructNew();
		switch(arguments.ceName)
	    {
		    case "Rental_Property_Contact":
		    {
		    	argPassStruct.ceName = arguments.ceName;
		    	argPassStruct.uniqueFldName = "CID";
		    	argPassStruct.createUUIDFld = "uniqueID";
		    	argPassStruct.ccAPIConfigName = "RentalPropertyContact";
		    	argPassStruct.extDataSource = "ocrental";
		    	argPassStruct.extTableName = "contact";
		    	processImport(importData=argPassStruct, 
		    					restart=arguments.restart,
		    					passCount=arguments.passCount,
		    					scheduleProcess=arguments.scheduleProcess,
		    					delayMinutes=arguments.delayMinutes,
		    					logFileName="import_element_#arguments.ceName#.log",
		    					startAt=arguments.startAt);
		    	break;
		    }
		    case "Rental_Property":
		    {
		    	argPassStruct.ceName = arguments.ceName;
		    	argPassStruct.uniqueFldName = "autoid";
		    	argPassStruct.createUUIDFld = "uniqueID";
		    	argPassStruct.ccAPIConfigName = "RentalProperty";
		    	argPassStruct.extDataSource = "ocrental";
		    	argPassStruct.extTableName = "rental";
		    	processImport(importData=argPassStruct, 
		    					restart=arguments.restart,
		    					passCount=arguments.passCount,
		    					scheduleProcess=arguments.scheduleProcess,
		    					delayMinutes=arguments.delayMinutes,
		    					logFileName="import_element_#arguments.ceName#.log",
		    					startAt=arguments.startAt);
		    	break;
		    }
		}
		
	</cfscript>
	
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$processImport
Summary:
	Process the import of the Custom Element Data.
Returns:
	Void
Arguments:
	Struct - importData - Data that is being imported.
	Boolean - restart - Restart the import process at the begining.
	Numeric - passCount - Number of records to import per pass.
	Boolean - scheduleProcess - Flag to set for scheduling the process.
	Numeric - delayMinutes - Number of minutes to delay between process runs.
	String - logFileName - Log file name.
	Numeric - startAt - Data position to start the import at.
History:
	2009-10-21 - MFC - Created
	2014-03-05 - JTP - Var declarations
--->
<cffunction name="processImport" access="public" returntype="void" hint="Process the import of the Custom Element Data.">
	<cfargument name="importData" type="struct" required="true" hint="Data that is being imported.">
	<cfargument name="restart" type="boolean" required="false" default="false" hint="Restart the import process at the begining.">
	<cfargument name="passCount" type="numeric" required="false" default="20" hint="Number of records to import per pass.">
	<cfargument name="scheduleProcess" type="boolean" required="false" default="false" hint="Flag to set for scheduling the process.">
	<cfargument name="delayMinutes" type="numeric" required="false" default="5" hint="Number of minutes to delay between process runs.">
	<cfargument name="logFileName" type="string" required="false" default="import_element.log" hint="Log file name.">
	<cfargument name="startAt" type="numeric" required="false" default="0" hint="Data position to start the import at.">
	
	<cfscript>
		var i = 1;
		var dataArray = "";
		var currVal = "";
		var j = 1;
		var currKey = "";
		var ccData = StructNew();
		var elementFields = "";
		var csContent = "";
		var pageResult = "";
		var extData = "";
		var schedTaskURL = '';
		
		//application.ADF.utils.doDump(arguments, "arguments", false);		
		// check if app variable exists or we need to restart
		if ( (NOT StructKeyExists(application.ADF, "importElement")) OR (arguments.restart) ){
			// Reset the bulk update variable
			application.ADF.importElement = StructNew();
			// Get the Data
			application.ADF.importElement.Query = getExternalData(arguments.importData.extDataSource, arguments.importData.extTableName, arguments.importData.uniqueFldName);
			// Store the current row
			application.ADF.importElement.currRow = 0;
			// Log that the application vars were updated
			application.ADF.utils.logAppend("Import Element Process - Element:#arguments.importData.ceName# - Application Vars Populated @ #now()#;", arguments.logFileName);
		}
		if ( arguments.startAt GT 0 ){
			// check if we want to set the start number in the url
			application.ADF.importElement.currRow = arguments.startAt - 1;
		}
		//application.ADF.utils.doDump(application.ADF.importElement,"application.ADF.importElement",false);	
		
		// Log that we are starting the process
		application.ADF.utils.logAppend("Import Element Process - Element:#arguments.importData.ceName# - Start @ #now()#;", arguments.logFileName);	
			
		// loop over the next updatePassCount of records
		for (i = 1; i LTE arguments.passCount; i++) {
	
			// Increment the current row counter
			application.ADF.importElement.currRow = application.ADF.importElement.currRow + 1;
			if (application.ADF.importElement.currRow LTE application.ADF.importElement.Query.RecordCount) {
				
				// Get the current value
				currVal = application.ADF.importElement.Query[arguments.importData.uniqueFldName][application.ADF.importElement.currRow];
				
				// check that we have an eaglenetid
				if (LEN(currVal)) {
					WriteOutput("application.ADF.importElement.Query[arguments.uniqueFldName][#application.ADF.importElement.currRow#] = #currVal#<br>");
					
					// Check if we have data for the current record
					dataArray = application.ADF.ceData.getCEData(arguments.importData.ceName, arguments.importData.uniqueFldName, currVal);
					
					// Check if we have a value already
					if ( ArrayLen(dataArray) ) {
						ccData = dataArray[1].Values;
						ccData.datapageid = dataArray[1].pageid;
					} else {
						// Get the default fields for the data
						ccData = application.ADF.ceData.defaultFieldStruct(arguments.importData.ceName);
						// Set the UUID field if one is defined
						if ( StructKeyExists(arguments.importData, "createUUIDFld") AND LEN(arguments.importData.createUUIDFld) )
							ccData[arguments.importData.createUUIDFld] = createUUID();
					}
					
					// Get the external data for the userid
					extData = getExternalData(arguments.importData.extDataSource, arguments.importData.extTableName, arguments.importData.uniqueFldName, currVal);
					//application.ADF.utils.doDump(extData, "extData", false);
						
					// Get the keylist
					elementFields = StructKeyList(ccData);
					// Load in the external data query
					// Loop over the external data and load into ccData
					for (j = 1; j LTE ListLen(elementFields); j = j + 1) {
						currKey = ListGetAt(elementFields, j);
						if ( StructKeyExists(extData, "#currKey#") ) {
							ccData[currKey] = application.ADF.importElement.Query[currKey][application.ADF.importElement.currRow];
						}
					}
					
					// Call the Element creation API
					csContent = server.ADF.objectFactory.getBean("csContent_1_0");
					// Create the page
			 		pageResult = csContent.populateContent(arguments.importData.ccAPIConfigName, ccData);
					// Log
					application.ADF.utils.logAppend("Import Element Process - Element:#arguments.importData.ceName# - Record Number: #application.ADF.importElement.currRow#; Current Value: #currVal#; Completed @ #now()#;", arguments.logFileName);
				}
				else {
					WriteOutput("Query field:  - application.ADF.importElement.Query[qryFieldName][#application.ADF.importElement.currRow#] = #currVal#<br>");
					application.ADF.utils.logAppend("Import Element Process - Element:#arguments.importData.ceName# - No Record Number: #application.ADF.importElement.currRow# - @ #now()#;", arguments.logFileName);
				}
			}
			else {
				application.ADF.utils.logAppend("Import Element Process - Element:#arguments.importData.ceName# - Completed @ #now()#;", arguments.logFileName);
				if ( arguments.scheduleProcess ) {
					// Delete the scheduled task
					application.ADF.utils.deleteScheduledTask("Import_Element_Process_#arguments.importData.ceName#");
					// Log that we are ending the process
					application.ADF.utils.logAppend("Import Element Process - Element:#arguments.importData.ceName# - Scheduled task deleted;", arguments.logFileName);
				}
				break;
			}
		}
		
		// Log that we are ending the process
		application.ADF.utils.logAppend("Import Element Process - Element:#arguments.importData.ceName# - End @ #now()#;", arguments.logFileName);
		
		if ( arguments.scheduleProcess ) 
		{
			if (application.ADF.importElement.currRow LTE application.ADF.importElement.Query.RecordCount) 
			{
				// set the scheduled task to start again
				schedTaskURL = "#variables.IMPORTCEPAGE#?action=process&importCE=#arguments.importData.ceName#&restart=false&count=#arguments.passCount#&cont=#arguments.scheduleProcess#&pause=#arguments.delayMinutes#";
				application.ADF.utils.setScheduledTask(schedTaskURL, "Import_Element_Process_#arguments.importData.ceName#","Import_Element_Process_#arguments.importData.ceName#.htm", arguments.delayMinutes);
				// Log that we are ending the process
				application.ADF.utils.logAppend("Import Element Process - Element:#arguments.importData.ceName# - Set scheduled task to start in #arguments.delayMinutes# minutes from #now()#", arguments.logFileName);
			}
		}
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getExternalData
Summary:
	Dynamic query to get the data for the datasource and table name
Returns:
	Query
Arguments:
	String - extDataSource - External data source name.
	String - extTableName - External data table name.
	String - uniqueFldName - External data table unique id field.
	String - value - External data table field value to find in the unique id field.
History:
	2009-10-21 - MFC - Created
--->
<cffunction name="getExternalData" access="public" returntype="query" hint="Dynamic query to get the data for the datasource and table name">
	<cfargument name="extDataSource" type="string" required="true" hint="External data source name.">
	<cfargument name="extTableName" type="string" required="true" hint="External data table name.">
	<cfargument name="uniqueFldName" type="string" required="true" hint="External data table unique id field.">
	<cfargument name="value" type="string" required="false" default="" hint="External data table field value to find in the unique id field.">
	
	<cfset var extDataQry = QueryNew("tmp")>	
	<cfquery name="extDataQry" datasource="#arguments.extDataSource#">
		SELECT *
		FROM #arguments.extTableName#
		<cfif LEN(arguments.value)>
			WHERE #arguments.uniqueFldName# = #arguments.value#
		</cfif>
		ORDER BY #arguments.uniqueFldName#
	</cfquery>
	<cfreturn extDataQry>
</cffunction>

</cfcomponent>