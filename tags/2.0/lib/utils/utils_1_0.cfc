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
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	utils_1_0.cfc
Summary:
	Util functions for the ADF Library
Version:
	1.0
History:
	2009-06-22 - MFC - Created
	2015-05-21 - GAC - Moved the HTMLSafeFormattedTextBox() method to data_1_2 LIB for v1.8.2
	2015-06-11 - GAC - Updated the component extends to use the libraryBase path
--->
<cfcomponent displayname="utils_1_0" extends="ADF.lib.libraryBase" hint="Util functions for the ADF Library">

<cfproperty name="version" value="1_0_16">
<cfproperty name="type" value="singleton">
<cfproperty name="ceData" type="dependency" injectedBean="ceData_1_0">
<cfproperty name="wikiTitle" value="Utils_1_0">

<cffunction name="exit" returntype="string" access="public">
	<cfexit>
</cffunction>

<cffunction name="abort" returntype="string" access="public">
	<cfabort>
</cffunction>

<!--- /*
 * Converts special characters to character entities, making a string safe for display in HTML.
 * Version 2 update by Eli Dickinson (eli.dickinson@gmail.com)
 * Fixes issue of lists not being equal and adding bull
 * v3, extra semicolons
 *
 * @param string 	 String to format. (Required)
 * @return Returns a string.
 * @author Gyrus (eli.dickinson@gmail.com gyrus@norlonto.net)
 * @version 3, August 30, 2006
 */ --->
<!--- // Moved to data_1_2 LIB for v1.8.2 --->
<cffunction name="HTMLSafeFormattedTextBox" access="public" returntype="string">
	<cfargument name="inString" type="string" required="true">

	<cfreturn application.ADF.data.HTMLSafeFormattedTextBox(inString=inString)>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	Ron West
Name:
	$logAppend
Summary:
	Logs any error to a log file
Returns:
	void
Arguments:
	String msg
	String logFile
	Boolean addTimeStamp
	String logDir
	String label
	Boolean useUTC
	Boolean addEntryTimeStampPrefix
History:
	2008-06-17 - RLW - Created
	2011-07-15 - RAK - Converted msg to be able to take anything
	2012-11-16 - SFS - Added Label argument so that you can individually label each complex object dump
	2013-02-20 - SFS - Added label name to the cffile so that the passed in label is actually part of the dump
	2013-11-20 - GAC - Added hints to the msg, addTimeStamp and the label arguments
	2013-12-05 - DRM - Create formatted UTC timestamp in local code, avoids crash logging ADF startup errors when ADF isn't built yet
	                   default logFile to adf-debug.log, instead of debug.log
	2014-09-19 - GAC - Add a parameter to make the UTC timestamp optional
	2015-12-03 - GAC - Added a parameter to make the timestamp prefix on the log entry optional 
	2015-12-22 - GAC - Moved to the Log_1_0 lib component	
--->
<!--- // Moved to the Log_1_0 library component --->
<cffunction name="logAppend" access="public" returntype="void">
	<cfargument name="msg" type="any" required="true" hint="if this value is NOT a simple string then the value gets converted to sting output using CFDUMP">
	<cfargument name="logFile" type="string" required="false" default="adf-debug.log">
	<cfargument name="addTimeStamp" type="boolean" required="false" default="true" hint="Adds a date stamp to the file name">
	<cfargument name="logDir" type="string" required="false" default="#request.cp.commonSpotDir#logs/">
	<cfargument name="label" type="string" required="false" default="" hint="Adds a text label to the log entry">
	<cfargument name="useUTC" type="boolean" required="false" default="true" hint="Converts the timestamp in the entry and the filename to UTC">
	<cfargument name="addEntryTimeStampPrefix" type="boolean" required="false" default="true" hint="Allows the timestamp prefix in the log entry to be excluded">
    <cfscript>
        application.ADF.log.logAppend( argumentCollection=arguments );
    </cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.		
	Ron West
Name:
	$bulkLogAppend
Summary:	
	Takes an array of log writes and calls log append with each write
Returns:
	Void
Arguments:
	Array logs
History:
	2009-07-09 - RLW - Created
	2015-12-22 - GAC - Moved to the Log_1_0 lib component
--->
<!--- // Moved to the Log_1_0 library component --->
<cffunction name="bulkLogAppend" access="public" returntype="void" hint="Takes an array of log writes and calls log append with each write">
	<cfargument name="logs" type="array" required="true" hint="Array of log append records">

    <cfscript>
        application.ADF.log.bulkLogAppend( argumentCollection=arguments );
    </cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	M. Carroll
Name:
	$doDump
Summary:
	ColdFusion dump of the variable argument.
	
	application.NAME.utils.doDump(arguments,"appendArrays - arguments", false);
Returns:
	void
Arguments:
	Any var - variable to dump
	String label [optional] - Label for the cfdump
	Boolean expand [optional] - T/F for the cfdump expand parameter
	Numeric returnInVar [optional] - Flag for return dump in a variable
	Boolean showUDFs [optional] -
History:
	2008-06-22 - MFC - Created
	2009-12-01 - GAC - Added label option for simple values
	2010-08-20 - GAC - Label on simple values is now controlled by the expand argument
	2010-08-20 - GAC - Added the output=true as a cffunction parameter
	2010-08-30 - GAC - Added arguments scope to the returnInVar variable
								 Set return value of 'foo' equal to an empty string 
	2014-01-13 - GAC - Updated the return variable name and simplified the dump output logic
	2015-06-17 - GAC - Updated the returnInVar argument to be type=boolean 
	2016-01-04 - GAC - Added a showUDF paramter to pass the showUDFs flag to the cfdump tag
--->
<cffunction name="doDump" access="public" returntype="string" output="true" hint="ColdFusion dump of the variable argument.">
	<cfargument name="var" required="Yes" type="any">
	<cfargument name="label" required="no" type="string" default="no label">
	<cfargument name="expand" required="no" type="boolean" default="true">
	<cfargument name="returnInVar" type="boolean" required="no" default="0">
	<cfargument name="showUDFs" type="boolean" required="no" default="1">
	
	<cfscript>
		var resultHTML = "";
	</cfscript>
	
	<!--- // process the dump and save it to the return variable --->
	<cfsavecontent variable="resultHTML">
		<cfif IsSimpleValue(arguments.var)>
			<cfoutput><div><cfif LEN(TRIM(arguments.label)) AND arguments.expand EQ true><strong>#arguments.label#:</strong> </cfif>#arguments.var#</div></cfoutput>
		<cfelse>
			<cfdump var="#arguments.var#" label="#arguments.label#" expand="#arguments.expand#" showUDFs="#arguments.showUDFs#">
		</cfif>
	</cfsavecontent>

	<!--- // output the dump in place or pass to the return of the function --->
	<cfif arguments.returnInVar neq 1>
		<!--- // outputing the dump in place so set the return to an empty string to avoid duplicate output --->
		<cfoutput>#resultHTML#</cfoutput>
		<cfreturn "">
	<cfelse>
		<cfreturn resultHTML>	
	</cfif>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	M. Carroll
Name:
	$directoryFiles
Summary:
	Returns the files for the directory
Returns:
	Query - Directory files
Arguments:
	String - Directory path
	String - Recurse Value
History:
	2009-05-11 - MFC - Created
--->
<cffunction name="directoryFiles" returntype="query" access="public" output="true" hint="Returns the files for the directory.">
	<cfargument name="dirPath" type="string" required="true" default="">
	<cfargument name="recurse" type="string" required="false" default="false">
	
	<cfset var dirQry = QueryNew("tmp")>
	<!--- recurse the custom app directory --->
	<!--- <cfdirectory action="list" directory="#ExpandPath(arguments.dirPath)#" name="dirQry" recurse="#arguments.recurse#"> --->
	<cfdirectory action="list" directory="#arguments.dirPath#" name="dirQry" recurse="#arguments.recurse#">
	
	<cfreturn dirQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.		
	M. Carroll
Name:
	$filterQueryByCFCFile
Summary:
	Filters the files for the directory query to find the whereCondValue file.
Returns:
	Query
Arguments:
	String - Directory Query
	String - whereCondValue
	String - whereOperator
	String - Query Type
History:
	2009-06-22 - MFC - Created
--->
<cffunction name="filterDirectoryQueryByType" access="public" returntype="query" output="true" hint="Filters the query to find the CFC file name.">
	<cfargument name="dirQuery" type="query" required="true" default="">
	<cfargument name="whereCondValue" type="string" required="true">
	<cfargument name="whereOperator" type="string" required="false" default="LIKE">
	<cfargument name="queryType" type="string" required="false" default="File">
	
	<cfset var retFilteredQry = QueryNew("temp")>
		
	<!--- query the results to find the 'appBeanConfig.cfm' files --->
	<cfquery name="retFilteredQry" dbtype="query">
		SELECT 		Directory, Name, Type
		FROM 		arguments.dirQuery
		WHERE 		Type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.queryType#">
		AND 		UPPER(name) #arguments.whereOperator# <cfqueryparam cfsqltype="cf_sql_varchar" value="#UCASE(arguments.whereCondValue)#">
		ORDER BY 	Directory, Name
	</cfquery>
	
	<cfreturn retFilteredQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	M Carroll
Name:
	$setScheduledTask
Summary:
	Updates the scheduled task to start in arguments.minuteDelay minutes.
Returns:
	void
Arguments:
	String url - URL to run on the scheduled task
	String taskname - Scheduled task name
	String logFileName - log file for task
	String minuteDelay - amount of time in minutes from now before running the scheduled task
History:
	2009-04-13 - MFC - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
	2016-02-16 - GAC - Updated for the schedule log file name to only allow .log and .txt files to be generated (as per ACF 10+)
	     			 	  - Added the allowedLogExts parameter to allow additional log extensions if set in ACF 10+ server config
	     			 	  - Added a param for passing in a schedule log directory
	     			 	  - Added the future parameter for an AuthToken
--->
<cffunction name="setScheduledTask" access="public" returntype="any">
	<cfargument name="url" type="string" required="true">
	<cfargument name="taskName" type="string" required="true">
	<cfargument name="schedLogFileName" type="string" default="#arguments.taskName#" required="false">
	<cfargument name="minuteDelay" type="string" required="true">
	<cfargument name="AuthToken" type="string" default="" required="false" hint="">
	<cfargument name="allowedLogExts" type="string" default="txt,log" required="false" hint="Comma Delimited list of allowed log file extensions (without the dot)">
	<cfargument name="schedLogDir" type="string" default="#request.cp.commonSpotDir#logs/" required="false">

	<cfscript>
		var newDate = dateFormat(dateAdd('n', arguments.minuteDelay, now()), "mm/dd/yyyy");
		var newTime = timeFormat(dateAdd('n', arguments.minuteDelay, now()), "HH:mm");

		var logFileDir = arguments.schedLogDir;
		var fullLogFilePath = "";
		var uniqueFullLogFilePath = "";
		var uniqueLogFileName = "";
		var logExt = "";
		var logFileName = "";

		// TODO: FUTURE FEATURE: Use for scheduled tasks that need authentication to run unattended
		var validAuthToken = false;

		// ACF 10+ only allows .log and .txt extension for the generated log files.
		// Additional extensions can be added to the \cfusion\lib\neo-cron.xml config file.
		// https://wikidocs.adobe.com/wiki/display/coldfusionen/cfschedule
		logExt = ListLast(arguments.schedLogFileName,'.');
		logFileName = Mid(arguments.schedLogFileName, 1, Len(arguments.schedLogFileName)-Len(logExt)-1);

		if ( ListFindNoCase(arguments.allowedLogExts,logExt) EQ 0 )
			arguments.schedLogFileName = logFileName & ".log";

		fullLogFilePath = logFileDir & arguments.schedLogFileName;
		uniqueFullLogFilePath = createUniqueFileName(fullLogFilePath);
		uniqueLogFileName = ListLast(uniqueFullLogFilePath,"/");

		// Validate authtoken (Future authentication feature)
		//validAuthToken = application.ADF.csSecurity.isValidAuthToken(arguments.authtoken);
		validAuthToken = true;

		if ( LEN(TRIM(arguments.AuthToken)) AND validAuthToken )
			schedURL = schedURL & "&authtoken=" & arguments.authtoken;
	</cfscript>
	
	<!--- set scheduled task --->
	<cfschedule url = #arguments.url#
		action="update"
		operation="HTTPRequest"
		startdate="#newDate#"
		starttime="#newTime#"
		task="#arguments.taskName#"
		interval="once"
		publish="yes"
		file="#uniqueLogFileName#"
		path="#logFileDir#"
		requesttimeout="3600">

</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	M Carroll
Name:
	$deleteScheduledTask
Summary:
	Deletes the scheduled task to start in 5 minutes.
Returns:
	void
Arguments:
	String taskname - Scheduled task name
History:
	2009-04-16 - MFC - Created
	2014-05-01 - ACW - in ACF 10, if you do not have a task called 'foo', run <cfschedule action="delete" task="foo"> will cause CF exception, message is 'The following task could not be found: foo.'
--->
<cffunction name="deleteScheduledTask" access="public" returntype="any">
	<cfargument name="taskName" type="string" required="true">
	
	<!--- Delete scheduled task --->
	<cftry>
		<cfschedule action="delete" task="#arguments.taskName#">
		<cfcatch>
			<cfif cfcatch.message NEQ 'The following task could not be found: #arguments.taskName#.'> <!--- ACF 10 only --->
				<cfrethrow>
			</cfif>
		</cfcatch>
	</cftry>
</cffunction>

<!---
/**
*
* From CFLib on 07/07/2009
*	Added By: M. Carroll
*
* Creates a unique file name; used to prevent overwriting when moving or copying files from one location to another.
* v2, bug found with dots in path, bug found by joseph
* v3 - missing dot in extension, bug found by cheesecow
* 
* @param fullpath      Full path to file. (Required)
* @return Returns a string. 
* @author Marc Esher (marc.esher@cablespeed.com) 
* @version 3, July 1, 2008 
*/
--->
<cffunction name="createUniqueFileName" access="public" returntype="string">
	<cfargument name="fullPath" type="string" required="true">

	<cfscript>
		/**
		* Creates a unique file name; used to prevent overwriting when moving or copying files from one location to another.
		* v2, bug found with dots in path, bug found by joseph
		* v3 - missing dot in extension, bug found by cheesecow
		* 
		* @param fullpath      Full path to file. (Required)
		* @return Returns a string. 
		* @author Marc Esher (marc.esher@cablespeed.com) 
		* @version 3, July 1, 2008 
		*/
		var extension = "";
		var thePath = "";
		var newPath = arguments.fullPath;
		var counter = 0;
		
		if(listLen(arguments.fullPath,".") gte 2) extension = listLast(arguments.fullPath,".");
		thePath = listDeleteAt(arguments.fullPath,listLen(arguments.fullPath,"."),".");
		
		while(fileExists(newPath)){
			counter = counter+1; 
			newPath = thePath & "_" & counter & "." & extension; 
		}
		return newPath; 
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	Ron West
Name:
	$getFieldTypes
Summary:	
	Returns back the details for any custom field type that is currently a list
Returns:
	Array listFieldTypes
Arguments:
	Void
History:
 	2009-11-17 - RLW - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="getFieldTypes" access="public" returntype="Array" hint="Returns back the details for any custom field type that is currently a list">
	<cfscript>
		var getFields = '';
		var data = server.ADF.objectFactory.getBean("Data_1_0");
		var fieldTypes = arrayNew(1);
	</cfscript>
	<!--- // query the custom field types --->
	<cfquery name="getFields" datasource="#request.site.datasource#">
		select type, propertyModule, renderModule, ID, active, dateLastModified, JSValidator
		from customFieldTypes
		order by type
	</cfquery>
	<cfif getFields.recordCount>
		<cfset fieldTypes = data.queryToArrayOfStructures(getFields)>
	</cfif>
	<cfreturn fieldTypes>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	Ron West
Name:
	$updateCustomFieldType
Summary:	
	Updates a custom field type record
Returns:
	Boolean results
Arguments:
	Numeric ID
	String propertyModule
	String renderModule
	String JSValidator
	String active
	String type
History:
 	2009-11-17 - RLW - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="updateCustomFieldType" access="public" returntype="boolean" hint="Updates a custom field type record">
	<cfargument name="ID" type="numeric" required="true" hint="The Field ID for the field type">
	<cfargument name="propertyModule" type="string" required="true">
	<cfargument name="renderModule" type="string" required="true">
	<cfargument name="type" type="string" required="true">
	<cfargument name="JSValidator" type="string" required="true">
	<cfargument name="active" type="string" required="true">
	<cfscript>
		var results = true;
		var update = '';
	</cfscript>
	<cftry>
		<cfquery name="update" datasource="#request.site.datasource#">
			update customFieldTypes
			set renderModule = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.renderModule#">,
			propertyModule = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.propertyModule#">,
			JSValidator = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.JSValidator#">,
			type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.type#">,
			Active = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.active#">,
			DateLastModified = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.formattedTimeStamp#">
			where ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
		</cfquery>
		<cfcatch>
			<cfscript>
				results = false;
				logAppend("Error updating custom field type: #cfcatch.detail#");
			</cfscript>
		</cfcatch>
	</cftry>
	<cfreturn results>
</cffunction>

<!---
/**
* From CFLib on 11/27/2009
*	Added By: M. Carroll
*
* Unzips a file to the specified directory.
*
* @param zipFilePath      Path to the zip file (Required)
* @param outputPath      Path where the unzipped file(s) should go (Required)
* @return void
* @author Samuel Neff (sam@serndesign.com)
* @version 1, September 1, 2003
*/
--->
<cffunction name="unzipFile" access="public" returntype="void" hint="">
	<cfargument name="zipFilePath" type="string" required="true" hint="">
	<cfargument name="outputPath" type="string" required="true" hint="">
	
	<cfscript>
	    var zipFile = ""; // ZipFile
	    var entries = ""; // Enumeration of ZipEntry
	    var entry = ""; // ZipEntry
	    var fil = ""; //File
	    var inStream = "";
	    var filOutStream = "";
	    var bufOutStream = "";
	    var nm = "";
	    var pth = "";
	    var lenPth = "";
	    var buffer = "";
	    var l = 0;
	
	    zipFile = createObject("java", "java.util.zip.ZipFile");
	    zipFile.init(zipFilePath);
	    
	    entries = zipFile.entries();
	    
	    while(entries.hasMoreElements()) {
	        entry = entries.nextElement();
	        if(NOT entry.isDirectory()) {
	            nm = entry.getName();
	            
	            lenPth = len(nm) - len(getFileFromPath(nm));
	            
	            if (lenPth) {
	            pth = outputPath & left(nm, lenPth);
	        } else {
	            pth = outputPath;
	        }
	        if (NOT directoryExists(pth)) {
	            fil = createObject("java", "java.io.File");
	            fil.init(pth);
	            fil.mkdirs();
	        }
	        filOutStream = createObject(
	            "java",
	            "java.io.FileOutputStream");
	        
	        filOutStream.init(outputPath & nm);
	        
	        bufOutStream = createObject(
	            "java",
	            "java.io.BufferedOutputStream");
	        
	        bufOutStream.init(filOutStream);
	        
	        inStream = zipFile.getInputStream(entry);
	        buffer = repeatString(" ",1024).getBytes();
	        
	        l = inStream.read(buffer);
	        while(l GTE 0) {
	            bufOutStream.write(buffer, 0, l);
	            l = inStream.read(buffer);
	        }
	        inStream.close();
	        bufOutStream.close();
	        }
	    }
	    zipFile.close();
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	Ron West
Name:
	$scriptExists
Summary:	
	Checks to see if the passed in template path actually exists
Returns:
	Boolean exists
Arguments:
	String templatePath
History:
	2009-11-29 - RLW - Created
 	2016-02-23 - GAC - Updated to check with expandPath first and then try again without expandPath
--->
<cffunction name="scriptExists" access="public" returntype="boolean" hint="">
	<cfargument name="templatePath" type="string" required="true">

	<cfscript>
		var exists = false;

		if ( fileExists(expandPath(arguments.templatePath)) )
			exists = true;
		else if ( fileExists(arguments.templatePath) )
			exists = true;

		return exists;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	Ron West
Name:
	$updateListItems
Summary:	
	Given a fieldType update the fields that use that field type to have list items
Returns:
	Struct results
Arguments:
	String fieldType
History:
 	2009-11-30 - RLW - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="updateListItems" access="public" returntype="struct" hint="Given a fieldType update the fields that use that field type to have list items">
	<cfargument name="fieldType" type="string" required="true">
	<cfscript>
		var fieldData = '';
		var count = '';
		var deleteLists = '';
		var insertList = '';
		var updateFieldValue = '';
		var results = structNew();
		var doUpdate = false;
		var fieldIDList = "";
		var fieldDataAry = arrayNew(1);
		var fieldID = "";
		var fieldDataList = "";
		var fieldVal = "";
		var theListID = "";
		// make sure that the field type passed in is of type list
		var isListType = fieldTypeIsList(arguments.fieldType);
		results.updated = false;
		if( isListType )
		{
			// get the fieldID's that have this fieldType
			fieldIDList = variables.ceData.getFieldIdsByType(arguments.fieldType);
			if( not listLen(fieldIDList) )
				results.msg = "No fields are bound to this type";
			else
				doUpdate = true;
		}
		else
			results.msg = "Field type #arguments.fieldType# is not a 'list' field type";
	</cfscript>
	<cfif listLen(fieldIDList) and doUpdate>
		<!--- // loop through the fieldIDList to get the data for each fieldID and process --->
		<cfloop list="#fieldIDList#" index="fieldID">
			<!--- // get the data for this fieldID --->
			<cfset fieldData = variables.ceData.getCEDataByFieldID(fieldID)>
			<cfloop query="fieldData">
				<!--- // if this field doesn't already have a listID --->
				<cfif not len(fieldData.listID) or ( len(fieldData.listID) and fieldData.listID eq 0 )>
					<!--- // get a new pageID for the listItem record --->
					<cfmodule template="/commonspot/utilities/getID.cfm"
						targetVar="theListID">
				<cfelse>
					<cfset theListID = fieldData.listID>
				</cfif>
				<!---// clear out any existing records in the list table for this listID --->
				<cfquery name="deleteLists" datasource="#request.site.datasource#">
					delete from data_ListItems
					where listID = <cfqueryparam cfsqltype="cf_sql_integer" value="#theListID#">
				</cfquery>
				<!--- // is this a regular field or a memo field --->
				<cfif len(fieldData.memoValue)>
					<cfset fieldDataList = fieldData.memoValue>
				<cfelse>
					<cfset fieldDataList = fieldData.fieldValue>
				</cfif>				
				<!--- // reset list position counter --->
				<cfset count = 0>
				<!--- // loop over the field data --->
				<cfloop list="#fieldDataList#" index="fieldVal">
					<cfset count = count + 1>
					<!--- // insert the listID --->
					<cfif isNumeric(fieldVal)>
						<cfquery name="insertList" datasource="#request.site.datasource#">
							insert into data_listItems (listID, position, pageID, numItemValue, StrItemValue )
							values (
							<cfqueryparam cfsqltype="cf_sql_integer" value="#theListID#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#count#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#fieldData.pageID#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#fieldVal#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#fieldVal#">)
						</cfquery>
					<cfelse>
						<cfquery name="insertList" datasource="#request.site.datasource#">
							insert into data_listItems (listID, position, pageID, StrItemValue )
							values (
							<cfqueryparam cfsqltype="cf_sql_integer" value="#theListID#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#count#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#fieldData.pageID#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#fieldVal#">)
						</cfquery>
					</cfif>
				</cfloop>
				<!--- // update data_fieldValue record with the new listID --->
				<cfquery name="updateFieldValue" datasource="#request.site.datasource#">
					update data_FieldValue
					set listID = <cfqueryparam cfsqltype="cf_sql_integer" value="#theListID#">
					where pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#fieldData.pageID#">
					and itemID = <cfqueryparam cfsqltype="cf_sql_integer" value="#fieldData.itemID#">
					and versionState = 2
				</cfquery>
			</cfloop>
		</cfloop>
		<!--- // TODO: this is a complicated update should wrap in cftry ... --->
		<cfset results.updated = true>
		<cfset results.msg = "">
	</cfif>
	<cfreturn results>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	Ron West
Name:
	$fieldTypeIsList
Summary:	
	Determines if the field type is a "list" field type
Returns:
	Boolean isList
Arguments:
	String fieldType
History:
 2009-11-30 - RLW - Created
--->
<cffunction name="fieldTypeIsList" access="public" returntype="boolean" hint="Determines if the field type is a 'list' field type">
	<cfargument name="fieldType" type="string" required="true">
	<cfscript>
		var isList = false;
		var checkFieldType = queryNew('');
	</cfscript>
	<cfquery name="checkFieldType" datasource="#request.site.datasource#">
		select ID
		from customFieldTypes
		where type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fieldType#">
	</cfquery>
	<cfif checkFieldType.recordCount>
		<cfset isList = true>
	</cfif>
	<cfreturn isList>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Sam Smith
Name:
	$buildPagination
Summary:
	Returns pagination widget
Returns:
	Struct rtn (itemStart & itemEnd for output loop)
Arguments:
	Numeric - page
	Numeric - itemCount
	Numeric -  pageSize
	Boolean - showCount (results count)
	String - URLparams (addl URL params for page links)
	Numeric - listLimit
	String - linkSeparator
	String - gapSeparator
History:
	2008-12-05 - SFS - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
	2012-03-08 - GAC - added a parameter for the listLimit to allow defined quantity of links to be built 
					 - added a parameter for the linkSeparator to allow the character(s) between consecutive links to be defined
					 - added a parameter for the gapSeparator to allow the character(s) for the gap of skipped links to be defined
					 - moved the Results Count string into the rtn Struct
					 - added the hints to the parameters
	2012-03-15 - MFC - Added check if itemCount is GT 0, then do the work. 
						If not, then return the default values.
--->
<cffunction name="buildPagination" access="public" returntype="struct">
	<cfargument name="page" type="numeric" required="true" default="1">
	<cfargument name="itemCount" type="numeric" required="true" default="0">
	<cfargument name="pageSize" type="numeric" required="true" default="1">
	<cfargument name="showCount" type="boolean" required="false" default="true">
	<cfargument name="URLparams" type="string" required="false" default="">
	<cfargument name="listLimit" type="numeric" required="false" default="6" hint="the number of link structs that get built">
	<cfargument name="linkSeparator" type="string" required="false" default="|" hint="character(s) separator for between consecutive page links">
	<cfargument name="gapSeparator" type="string" required="false" default="..." hint="character(s) separator for the gab between skipped page links">

	<cfscript>
		var rtn = StructNew();
		var listStart = '';
		var listEnd = '';
		var pg = '';
		var maxPage = Ceiling(arguments.itemCount / arguments.pageSize);
		var itemStart = 0;
		var itemEnd = 0;
	</cfscript>

	<!--- Check if we have records to process --->
	<cfif arguments.itemCount GT 0>
		<cfif arguments.page LT 1>
			<cfset arguments.page = 1>
		<cfelseif arguments.page GT maxPage>
			<cfset arguments.page = maxPage>
		</cfif>
	
		<cfif arguments.page EQ 1>
			<cfset itemStart = 1>
			<cfset itemEnd = arguments.pageSize>
		<cfelse>
			<cfset itemStart = ((arguments.page - 1) * arguments.pageSize) + 1>
			<cfset itemEnd = arguments.page * arguments.pageSize>
		</cfif>
	
		<cfif itemEnd GT arguments.itemCount>
			<cfset itemEnd = arguments.itemCount>
		</cfif>
	
		<cfscript>
			rtn.itemStart = itemStart;
			rtn.itemEnd = itemEnd;
		</cfscript>
	
		<cfoutput>
			<!--- // Moved the Results Count string into the rtn Struct ---> 
			<cfset rtn.resultsCount = "Results #itemStart# - #itemEnd# of #arguments.itemCount#">
			<cfif arguments.showCount>#rtn.resultsCount#</cfif>
			
			<cfif arguments.page GT 1>
				<cfset rtn.prevlink = "?page=#arguments.page-1##arguments.URLparams#">
				<!---&laquo; <a href="?page=#arguments.page-1##arguments.URLparams#">Prev</a>--->
			<cfelse>
				<cfset rtn.prevlink = "">
			</cfif>
	
			<!--- Complicated code to help determine which page numbers to show in pagination --->
			<cfif arguments.page LTE arguments.listLimit>
				<cfset listStart = 2>
			<cfelseif arguments.page GTE maxPage - (arguments.listLimit - 1)>
				<cfset listStart = maxPage - arguments.listLimit>
			<cfelse>
				<cfset listStart = arguments.page - 2>
			</cfif>
	
			<cfif arguments.page LTE arguments.listLimit>
				<cfset listEnd = arguments.listLimit + 1>
			<cfelseif arguments.page GTE maxPage - (arguments.listLimit - 1)>
				<cfset listEnd = maxPage - 1>
			<cfelse>
				<cfset listEnd = arguments.page + 2>
			</cfif>
	
			<cfset rtn.pagelinks = ArrayNew(1)>
			<cfloop from="1" to="#maxPage#" index="pg">
				<cfset rtn.pageLinks[pg] = StructNew()>
				<cfif (pg EQ 1 OR pg EQ maxPage) OR (pg GTE listStart AND pg LTE listEnd)>
					<cfif (pg EQ listStart AND listStart GT 2) OR (pg EQ maxPage AND listEnd LT maxPage - 1)>
						<!--- // Add the Separator to the struct for the 'gab' between skipped links --->
						<cfset rtn.pageLinks[pg].Separator = arguments.gapSeparator>
						<!---...--->
					<cfelse>
						<!--- // Add the Separator to the struct for between consecutive links --->
						<cfset rtn.pageLinks[pg].Separator = arguments.linkSeparator>
						<!---|--->
					</cfif>
					<cfif arguments.page NEQ pg>
						<cfset rtn.pageLinks[pg].link = "?page=#pg##arguments.URLparams#">
						<!---<a href="?page=#pg##arguments.URLparams#">#pg#</a>--->
					<cfelse>
						<cfset rtn.pageLinks[pg].link = "">
						<!---#pg#--->
					</cfif>
				<cfelse>
					<!--- // Builds an empty struct for pagelinks outside of the LIST limit --->
				</cfif>
			</cfloop>
			<cfif arguments.page LT maxPage>
				<cfset rtn.nextLink = "?page=#arguments.page+1##arguments.URLparams#">
				<!---| <a href="?page=#arguments.page+1##arguments.URLparams#">Next</a> &raquo;--->
			<cfelse>
				<cfset rtn.nextLink = "">
			</cfif>
		</cfoutput>
	<cfelse>	
		<cfscript>
			rtn.itemStart = itemStart;
			rtn.itemEnd = itemEnd;
			rtn.prevlink = "";
			rtn.pagelinks = ArrayNew(1);
			rtn.nextLink = "";
		</cfscript>
	</cfif>
	<cfreturn rtn>
</cffunction>

<!---
/**
 * From CFLib on 03/02/2010
 * Added By: S. Smith
 * Returns specified number of random list elements without repeats.
 * 
 * @param theList 	 Delimited list of values. (Required)
 * @param numElements 	 Number of list elements to retrieve. (Required)
 * @param theDelim 	 Delimiter used to separate list elements.  The default is the comma. (Optional)
 * @return Returns a string. 
 * @author Shawn Seley (shawnse@aol.com) 
 * @version 1, July 10, 2002 
 */
	2011-02-09 - RAK - Adding arguments to variables. Cleans up varscoper results
 --->
<cffunction name="ListRandomElements" access="public" returntype="string" hint="Returns specified number of random list elements without repeats.">
	<cfargument name="theList" type="string" required="yes" default="">
	<cfargument name="numElements" type="numeric" required="yes" default="1">
	<cfargument name="theDelim" type="string" required="no" default=",">
	<cfscript>
		var final_list	= "";
		var x			= 0;
		var random_i	= 0;
		var random_val	= 0;

	
		if(ArrayLen(Arguments) GTE 3) theDelim = Arguments[3];
	
		if(arguments.numElements GT ListLen(arguments.theList, theDelim)) {
			arguments.numElements = ListLen(arguments.theList, theDelim);
		}
	
		// Build the new list "scratching off" the randomly selected elements from the original list in order to avoid repeats
		for(x=1; x LTE arguments.numElements; x=x+1){
			random_i	= RandRange(1, ListLen(arguments.theList));	// pick a random list element index from the remaining elements
			random_val	= ListGetAt(arguments.theList, random_i);		// get the corresponding list element's value
			arguments.theList		= ListDeleteAt(arguments.theList, random_i);	// delete the used element from the list
	
			final_list	= ListAppend(final_list, random_val , theDelim);
		}
	
		return(final_list);
	</cfscript>
</cffunction>

</cfcomponent>