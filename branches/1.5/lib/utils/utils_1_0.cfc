<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2010.
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
History:
	2009-06-22 - MFC - Created
--->
<cfcomponent displayname="utils_1_0" extends="ADF.core.Base" hint="Util functions for the ADF Library">

<cfproperty name="version" value="1_0_0">
<cfproperty name="type" value="singleton">
<cfproperty name="ceData" type="dependency" injectedBean="ceData_1_0">
<cfproperty name="wikiTitle" value="Utils_1_0">

<cffunction name="exit" returntype="string">
	<cfexit>
</cffunction>

<cffunction name="abort" returntype="string">
	<cfabort>
</cffunction>

<!--- /**
 * Coverts special characters to character entities, making a string safe for display in HTML.
 * Version 2 update by Eli Dickinson (eli.dickinson@gmail.com)
 * Fixes issue of lists not being equal and adding bull
 * v3, extra semicolons
 *
 * @param string 	 String to format. (Required)
 * @return Returns a string.
 * @author Gyrus (eli.dickinson@gmail.comgyrus@norlonto.net)
 * @version 3, August 30, 2006
 */ --->
<cffunction name="HTMLSafeFormattedTextBox" access="public" returntype="string">
	<cfargument name="inString" type="string" required="true">

	<cfscript>
		var badChars = "&amp;nbsp;,&amp;amp;,&quot;,&amp;ndash;,&amp;rsquo;,&amp;ldquo;,&amp;rdquo;,#chr(12)#";
		var goodChars = "&nbsp;,&amp;,"",&ndash;,&rsquo;,&ldquo;,&rdquo;,&nbsp;";

		// Return immediately if blank string
		if (NOT Len(Trim(arguments.inString))) return arguments.inString;

		// Do replacing
		return ReplaceList(arguments.inString, badChars, goodChars);
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$logAppend
Summary:
	Logs any error to a log file
Returns:
	void
Arguments:
	String msg - the message to be logged
	String logFile [optional] - an alternative log file
History:
	2008-06-17 - RLW - Created
--->
<cffunction name="logAppend" access="public" returntype="void">
	<cfargument name="msg" type="string" required="true">
	<cfargument name="logFile" type="string" required="false" default="debug.log">
	<cfargument name="addTimeStamp" type="boolean" required="false" default="true">
	<cfargument name="logDir" type="string" required="false" default="#request.cp.commonSpotDir#logs/">
	<cfscript>
		var logFileName = arguments.logFile;
		var utcNow = DateConvert('local2utc', now());
		if( arguments.addTimeStamp )
			logFileName = dateFormat(now(), "yyyymmdd") & "." & request.site.name & "." & logFileName;
	</cfscript>
	<cftry>
		<!--- Check if the file exists --->
		<cfif NOT directoryExists(arguments.logdir)>
			<cfdirectory action="create" directory="#arguments.logdir#">
		</cfif>
		<cffile action="append" file="#arguments.logDir##logFileName#" output="#application.adf.date.csDateFormat(utcNow,utcNow)# (UTC) - #arguments.msg#" addnewline="true">
		<cfcatch type="any">
			<cfdump var="#arguments.logDir##logFileName#" label="Log File: #arguments.logDir##logFileName#" />
			<cfdump expand="false" label="LogAppend() Error" var="#cfcatch#" />
		</cfcatch>
	</cftry>
</cffunction>
<!---
	/* ***************************************************************
	/*
	Author: 	Ron West
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
	--->
<cffunction name="bulkLogAppend" access="public" returntype="void" hint="Takes an array of log writes and calls log append with each write">
	<cfargument name="logs" type="array" required="true" hint="Array of log append records">
	<cfscript>
		var itm = 1;
		var thisLog = structNew();
		for( itm; itm lte arrayLen(arguments.logs); itm=itm+1 )
		{
			thisLog = arguments.logs[itm];
			// inspect the record and build argumentCol to pass to logAppend
			if( structKeyExists(thisLog, "msg") )
				logAppend(argumentCollection=thisLog);
		}
	</cfscript>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	M. Carroll
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
	Numeric returnInVar [optional] = Flag for return dump in a variable
History:
	2008-06-22 - MFC - Created
	2009-12-01 - GAC - Updated - Added label option for simple values
	2010-08-20 - GAC - Updated - Label on simple values is now controlled by the expand argument
	2010-08-20 - GAC - Updated - Added the output=true as a cffunction parameter
	2010-08-30 - GAC - Updated - Added arguments scope to the returnInVar variable
								 Set return value of 'foo' equal to an empty string 
--->
<cffunction name="doDump" access="public" returntype="string" output="true" hint="ColdFusion dump of the variable argument.">
	<cfargument name="var" required="Yes" type="any">
	<cfargument name="label" required="no" type="string" default="no label">
	<cfargument name="expand" required="no" type="boolean" default="true">
	<cfargument name="returnInVar" type="numeric" required="No" default="0">

	<CFSCRIPT>
		var foo = "";
	</CFSCRIPT>

	<cfif arguments.returnInVar eq 1>
		<cfsavecontent variable="foo">
			<cfif IsSimpleValue(arguments.var)>
				<cfoutput><div><cfif LEN(TRIM(arguments.label)) AND arguments.expand EQ true><strong>#arguments.label#:</strong> </cfif>#arguments.var#</div></cfoutput>
			<cfelse>
				<cfdump var="#arguments.var#" label="#arguments.label#" expand="#arguments.expand#">
			</cfif>
		</cfsavecontent>
	<cfelse>
		<cfif IsSimpleValue(arguments.var)>
			<cfoutput><div><cfif LEN(TRIM(arguments.label)) AND arguments.expand EQ true><strong>#arguments.label#:</strong> </cfif>#arguments.var#</div></cfoutput>
		<cfelse>
			<cfdump var="#arguments.var#" label="#arguments.label#" expand="#arguments.expand#">
		</cfif>
	</cfif>
	<cfreturn foo>
</cffunction>

<!---
	/* ***************************************************************
	/*
	Author: 	M. Carroll
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
	/* ***************************************************************
	/*
	Author: 	M. Carroll
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
/* ***************************************************************
/*
Author: 	M Carroll
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
History:
	2009-04-13 - MFC - Created
--->
<cffunction name="setScheduledTask" access="public" returntype="any">
	<cfargument name="url" type="string" required="true">
	<cfargument name="taskName" type="string" required="true">
	<cfargument name="schedLogFileName" type="string" required="true"> 
	<cfargument name="minuteDelay" type="string" required="true"> 
	
	<cfscript>
		newDate = dateFormat(dateAdd('n', arguments.minuteDelay, now()), "mm/dd/yyyy");
		newTime = timeFormat(dateAdd('n', arguments.minuteDelay, now()), "HH:mm");
	</cfscript>
	
	<!--- set scheduled task for "mayo_Fetch_Assets" --->
	<cfschedule url = #arguments.url#
		action="update"
		operation="HTTPRequest"
		startdate="#newDate#"
		starttime="#newTime#"
		task="#arguments.taskName#"
		interval="once"
		publish="yes"
		file="#arguments.schedLogFileName#"
		path="#request.cp.commonSpotDir#logs/"
		requesttimeout="3600">

</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M Carroll
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
--->
<cffunction name="deleteScheduledTask" access="public" returntype="any">
	<cfargument name="taskName" type="string" required="true">
	
	<!--- Delete scheduled task --->
	<cfschedule action="delete"	task="#arguments.taskName#">

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
/* ***************************************************************
/*
Author: 	Ron West
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
--->
<cffunction name="getFieldTypes" access="public" returntype="Array" hint="Returns back the details for any custom field type that is currently a list">
	<cfscript>
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
/* ***************************************************************
/*
Author: 	Ron West
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
--->
<cffunction name="updateCustomFieldType" access="public" returntype="boolean" hint="Updates a custom field type record">
	<cfargument name="ID" type="numeric" required="true" hint="The Field ID for the field type">
	<cfargument name="propertyModule" type="string" required="true">
	<cfargument name="renderModule" type="string" required="true">
	<cfargument name="type" type="string" required="true">
	<cfargument name="JSValidator" type="string" required="true">
	<cfargument name="active" type="string" required="true">
	<cfset results = true>
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
/* ***************************************************************
/*
Author: 	Ron West
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
--->
<cffunction name="scriptExists" access="public" returntype="boolean" hint="">
	<cfargument name="templatePath" type="string" required="true">
	<cfscript>
		var exists = fileExists(expandPath(arguments.templatePath));
	</cfscript>
	<cfreturn exists>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	Ron West
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
--->
<cffunction name="updateListItems" access="public" returntype="struct" hint="Given a fieldType update the fields that use that field type to have list items">
	<cfargument name="fieldType" type="string" required="true">
	<cfscript>
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
/* ***************************************************************
/*
Author: 	Ron West
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
/* ***************************************************************
/*
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
	Integer page
	Integer itemCount
	Integer pageSize
	Boolean showCount (results count)
	String URLparams (addl URL params for page links)
History:
	2008-12-05 - SFS - Created
--->
<cffunction name="buildPagination" access="public" returntype="struct">
	<cfargument name="page" type="numeric" required="true" default="1">
	<cfargument name="itemCount" type="numeric" required="true" default="0">
	<cfargument name="pageSize" type="numeric" required="true" default="1">
	<cfargument name="showCount" type="boolean" required="false" default="true">
	<cfargument name="URLparams" type="string" required="false" default="">

	<cfscript>
		var maxPage = Ceiling(arguments.itemCount / arguments.pageSize);
		var listLimit = 6;
		var itemStart = 0;
		var itemEnd = 0;
		rtn = StructNew();
	</cfscript>

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
	<!---<div>--->
		<cfif arguments.showCount>Results #itemStart# - #itemEnd# of #arguments.itemCount#</cfif>
		<cfif arguments.page GT 1>
			<cfset rtn.prevlink = "?page=#arguments.page-1##arguments.URLparams#">
			<!---&laquo; <a href="?page=#arguments.page-1##arguments.URLparams#">Prev</a>--->
		<cfelse>
			<cfset rtn.prevlink = "">
		</cfif>

		<!--- Complicated code to help determine which page numbers to show in pagination --->
		<cfif arguments.page LTE listLimit>
			<cfset listStart = 2>
		<cfelseif arguments.page GTE maxPage - (listLimit - 1)>
			<cfset listStart = maxPage - listLimit>
		<cfelse>
			<cfset listStart = arguments.page - 2>
		</cfif>

		<cfif arguments.page LTE listLimit>
			<cfset listEnd = listLimit + 1>
		<cfelseif arguments.page GTE maxPage - (listLimit - 1)>
			<cfset listEnd = maxPage - 1>
		<cfelse>
			<cfset listEnd = arguments.page + 2>
		</cfif>

		<cfset rtn.pagelinks = ArrayNew(1)>
		<cfloop from="1" to="#maxPage#" index="pg">
			<cfset rtn.pageLinks[pg] = StructNew()>
			<cfif (pg EQ 1 OR pg EQ maxPage) OR (pg GTE listStart AND pg LTE listEnd)>
				<cfif (pg EQ listStart AND listStart GT 2) OR (pg EQ maxPage AND listEnd LT maxPage - 1)>
				<cfset rtn.pageLinks[pg].Separator = "...">
				<!---...--->
				<cfelse>
				<cfset rtn.pageLinks[pg].Separator = "|">
				<!---|--->
				</cfif>
				<cfif arguments.page NEQ pg>
					<cfset rtn.pageLinks[pg].link = "?page=#pg##arguments.URLparams#">
					<!---<a href="?page=#pg##arguments.URLparams#">#pg#</a>--->
				<cfelse>
					<cfset rtn.pageLinks[pg].link = "">
					<!---#pg#--->
				</cfif>
			</cfif>
		</cfloop>
		<cfif arguments.page LT maxPage>
			<cfset rtn.nextLink = "?page=#arguments.page+1##arguments.URLparams#">
			<!---| <a href="?page=#arguments.page+1##arguments.URLparams#">Next</a> &raquo;--->
		<cfelse>
			<cfset rtn.nextLink = "">
		</cfif>
		<!---<div class="clear"><!-- --></div>
	</div>
	<div class="clear"><!-- --></div>--->
	</cfoutput>
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
	
		if(numElements GT ListLen(theList, theDelim)) {
			numElements = ListLen(theList, theDelim);
		}
	
		// Build the new list "scratching off" the randomly selected elements from the original list in order to avoid repeats
		for(x=1; x LTE numElements; x=x+1){
			random_i	= RandRange(1, ListLen(theList));	// pick a random list element index from the remaining elements
			random_val	= ListGetAt(theList, random_i);		// get the corresponding list element's value
			theList		= ListDeleteAt(theList, random_i);	// delete the used element from the list
	
			final_list	= ListAppend(final_list, random_val , theDelim);
		}
	
		return(final_list);
	</cfscript>
</cffunction>


<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$runCommand
Summary:
	Runs the given command
Returns:
	Any
Arguments:

History:
 	Dec 3, 2010 - RAK - Created
--->
<cffunction name="runCommand" access="public" returntype="Any" hint="Runs the given command">
	<cfargument name="beanName" type="string" required="true" default="" hint="Name of the bean you would like to call">
	<cfargument name="methodName" type="string" required="true" default="" hint="Name of the method you would like to call">
	<cfargument name="args" type="Struct" required="false" default="#StructNew()#" hint="Structure of arguments for the speicified call">
	<cfscript>
		var returnData = "";
		var bean = "";
		// load the bean that we will call - check in application scope first
		if( application.ADF.objectFactory.containsBean(arguments.beanName) )
			bean = application.ADF.objectFactory.getBean(arguments.beanName);
		else if( server.ADF.objectFactory.containsBean(arguments.beanName) )
			bean = server.ADF.objectFactory.getBean(arguments.beanName);
	</cfscript>
   <cfinvoke component = "#bean#"
				 method = "#arguments.methodName#"
				 returnVariable = "returnData"
				 argumentCollection = "#arguments.args#">
	<cfreturn returnData>
</cffunction>
</cfcomponent>