<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
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
	utils_1_2.cfc
Summary:
	Util functions for the ADF Library
Version:
	1.2
History:
	2012-12-07 - MFC - Created
	2013-02-26 - MFC - Updated the Injection Dependencies to use the ADF v1.6 lib versions.
	2014-04-04 - GAC - Added the doThow method with logging options
	2014-05-27 - GAC - Added new methods to help secure ADFdumpVar: processADFDumpVar and sanitizeADFDumpVarData
--->
<cfcomponent displayname="utils_1_2" extends="ADF.lib.utils.utils_1_1" hint="Util functions for the ADF Library">

<cfproperty name="version" value="1_2_10">
<cfproperty name="type" value="singleton">
<cfproperty name="ceData" type="dependency" injectedBean="ceData_2_0">
<cfproperty name="csData" type="dependency" injectedBean="csData_1_2">
<cfproperty name="data" type="dependency" injectedBean="data_1_2">
<cfproperty name="wikiTitle" value="Utils_1_2">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Sam Smith
Name:
	$buildPaginationStruct
Summary:
	Returns pagination widget
Returns:
	Struct rtn (itemStart & itemEnd for output loop)
Arguments:
	Numeric - page
	Numeric - itemCount
	Numeric - pageSize
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
					 - removed the CFOUTPUTS and move all generated string values into the returned structure
					 - added the hints to the parameters
					 - moved to utils_1_1 since removing the CFOUTPUTS may change backwards compatiblity
	2012-09-17 - MFC - Fixed cfargument "default" attribute for URLparams. 
	2012-09-18 - MFC - Validate that the URL Params arg starts with a leading "&" 
--->
<cffunction name="buildPaginationStruct" access="public" returntype="struct">
	<cfargument name="page" type="numeric" required="true" default="1" hint="the value of the current page">
	<cfargument name="itemCount" type="numeric" required="true" default="0" hint="the total number of items">
	<cfargument name="pageSize" type="numeric" required="true" default="1" hint="the number of items per page">
	<cfargument name="showCount" type="boolean" required="false" default="true" hint="build the record results count string">
	<cfargument name="URLparams" type="string" required="false" default="" hint="additional URL params for page links">
	<cfargument name="listLimit" type="numeric" required="false" default="6" hint="the number of link structs that get built">
	<cfargument name="linkSeparator" type="string" required="false" default="|" hint="a character(s) separator for between consecutive links">
	<cfargument name="gapSeparator" type="string" required="false" default="..." hint="a character(s) separator for the gab between skipped links">
	
	<cfscript>
		var rtn = StructNew();
		var listStart = '';
		var listEnd = '';
		var pg = '';
		var maxPage = Ceiling(arguments.itemCount / arguments.pageSize);
		var itemStart = 0;
		var itemEnd = 0;

		// Make sure the value passed in for listLimit is at least 4
		if (arguments.listLimit LT 4 )
			arguments.listLimit = 4;

		if ( arguments.page LT 1 )
			arguments.page = 1;
		else if ( arguments.page GT maxPage )
			arguments.page = maxPage;

		if ( arguments.page EQ 1 )
		{
			itemStart = 1;
			itemEnd = arguments.pageSize;
		}
		else
		{
			itemStart = ((arguments.page - 1) * arguments.pageSize) + 1;
			itemEnd = arguments.page * arguments.pageSize;
		}

		if ( itemEnd GT arguments.itemCount )
			itemEnd = arguments.itemCount;

		rtn.itemStart = itemStart;
		rtn.itemEnd = itemEnd;
		
		// Validate that the URL Params arg starts with a leading "&"
		if ( LEN(arguments.URLparams) AND (LEFT(arguments.URLparams,1) NEQ "&") )
			arguments.URLparams = "&" & arguments.URLparams;
	</cfscript>

	<!--- // Moved the Record Count string into the rtn Struct --->
	<cfif arguments.showCount>
		<cfset rtn.resultsCount = "Results #itemStart# - #itemEnd# of #arguments.itemCount#">
	</cfif>
	
	<cfif arguments.page GT 1>
		<cfset rtn.prevlink = "?page=#arguments.page-1##arguments.URLparams#">
		<!---&laquo; <a href="?page=#arguments.page-1##arguments.URLparams#">Prev</a>--->
	<cfelse>
		<cfset rtn.prevlink = "">
	</cfif>

	<!--- // Complicated code to help determine which page numbers to show in pagination --->
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

	<cfreturn rtn>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	T. Parker 
Name:
	$fileLastModifiedDateTime
Summary:
	Returns the last modified datetime stamp for a file
	
	To get the file last modified date of the calling script use:
	thisModulePath = GetCurrentTemplatePath();
	modDateTime = application.ADF.utils.fileLastModifiedDateTime(thisModulePath);
Returns:
	String
Arguments:
	String - filePath
History:
 	2012-05-04 - GAC - Added
--->
<cffunction name="fileLastModifiedDateTime" access="public" returntype="string" hint="Returns the last modified datetime stamp for a file">
	<cfargument name="filePath" type="string" required="true" default="" hint="Full path to a file">
	<cfscript>
		var fileInfo = CreateObject("java","java.io.File").init(arguments.filePath);
 		var thisModuleLastModified = fileInfo.lastModified();
 		var thisModuleDateTime = createObject("java","java.util.Date").init(thisModuleLastModified);
    	return thisModuleDateTime;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Dave Beckstrom
Name:
	$pageRedirect
Summary:
	Redirects page to a new url via cflocation.  Useful for cfscript notation.
Returns:
	void
Arguments:
	String targetURL - URL target for cflocation.
History:
	2012-07-23 - DMB - Created
	2013-01-29 - GAC - Updated logic for the HTTP check
	2013-02-13 - GAC - Updated the type from ANY to STRING for the targetURL argument
--->
<cffunction name="pageRedirect" access="public" returntype="void">
	<cfargument name="targetURL" type="string" required="true">
	<cfif REFIND("^https?://",arguments.targetURL,1) EQ false>
		<cflocation url="http://#arguments.targetURL#" addtoken="No">
	<cfelse>
		<cflocation url="#arguments.targetURL#" addtoken="No">
	</cfif>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	$setRecurringScheduledTask
Summary:
	Creates or updates a scheduled task that is recurring.
Returns:
	struct
Arguments:
	String url 
	String taskname 
	String schedLogFileName 
	String interval
	String startDate
	String startTime
	String endDate
	String endTime
	String timeout
	String AuthToken -  future feature
History:
	2012-08-16 - GAC - Created
--->
<cffunction name="setRecurringScheduledTask" access="public" returntype="struct" output="false" hint="Creates or updates a scheduled task that is recurring.">
	<cfargument name="url" type="string" required="true">
	<cfargument name="taskName" type="string" required="true">
	<cfargument name="schedLogFileName" type="string" default="#arguments.taskName#" required="false"> 
	<cfargument name="interval" type="string" default="" required="false" hint="number of seconds,daily,weekly,monthly"> 
	<cfargument name="startDate" type="string" default="" required="false" hint="">
	<cfargument name="startTime" type="string" default="" required="false" hint=""> 
	<cfargument name="endDate" type="string" default="" required="false" hint="">
	<cfargument name="endTime" type="string" default="" required="false" hint="">
	<cfargument name="timeout" type="string" default="3600" required="false"> 
	<cfargument name="AuthToken" type="string" default="" required="false" hint=""> 
	<cfscript>
		var retResult = StructNew();
		var schedURL = arguments.url;
		
		var defaultDateFormat = "mm/dd/yyyy";
		var defaultTimeFormat = "HH:mm";
		var defaultMinStartDelay = 5;
		var defaultMinIntervalDelay = 15;
		var defaultRequestTimeOut = "3600"; // 3600 second (1 hour) is the default before the request times out
		var defaultInterval = "once";
		var intervalOptionsList = "once,daily,weekly,monthly";
		var defaultStartDateTime = DateAdd("n",defaultMinStartDelay,Now()); 
		var defaultEndDateTime = DateAdd("n",1,defaultStartDateTime);
		
		var logFileDir = request.cp.commonSpotDir & "logs/";
		var fullLogFilePath = logFileDir & arguments.schedLogFileName;
		var uniqueFullLogFilePath = createUniqueFileName(fullLogFilePath);
		var uniqueLogFileName = ListLast(uniqueFullLogFilePath,"/");
		
		var schedStartDate = arguments.startDate;
		var schedStartTime = arguments.startTime;
		var schedEndDate = "";
		var schedEndTime = "";
		var schedStartDateTime = "";
		var schedEndDateTime = "";
		
		// Set the schedInterval to the default value
		var schedInterval = defaultInterval;
		var schedRequestTimeOut = defaultRequestTimeOut;
		
		// TODO: FUTURE FEATURE: Use for recurring tasks that need authenication to run unattended
		var validAuthToken = false;
		
		// Verify that the interval passed is valid, if not set the interval to once
		// - if a numeric value they run the task every X number of seconds
		if ( IsNumeric(arguments.interval) OR ListFindNoCase(intervalOptionsList,arguments.interval) )
			schedInterval = arguments.interval;
		
		// Build Start Date	
		if ( LEN(TRIM(schedStartDate)) AND IsDate(schedStartDate) ) 
			schedStartDate = DateFormat(schedStartDate,defaultDateFormat);
		else
			schedStartDate = DateFormat(defaultStartDateTime,defaultDateFormat);
			
		// Build Start Time
		if ( LEN(TRIM(schedStartTime)) AND IsDate(schedStartTime) ) 
			schedStartTime = TimeFormat(schedStartTime, defaultTimeFormat);
		else
			schedStartTime = TimeFormat(defaultStartDateTime, defaultTimeFormat);
		
		// Build Start Date/Time String
		schedStartDateTime = DateFormat(schedStartDate,"mm-dd-yyyy") & " " & TimeFormat(schedStartTime,"HH:mm:ss");
		
		// Make sure the Start Date/Time is really in the future
		if ( defaultStartDateTime GT schedStartDateTime ) {
			schedStartDate = DateFormat(defaultStartDateTime,defaultDateFormat);
			schedStartTime = TimeFormat(defaultStartDateTime, defaultTimeFormat);
			schedStartDateTime = DateFormat(schedStartDate,"mm-dd-yyyy") & " " & TimeFormat(schedStartTime,"HH:mm:ss");
		}
		
		// Build End Date
		if ( LEN(TRIM(arguments.endDate)) AND IsDate(arguments.endDate) ) {
			schedEndDate = DateFormat(schedStartDate,defaultDateFormat);
			
			if ( LEN(TRIM(arguments.endTime)) AND IsDate(arguments.endTime) )
				schedEndTime = TimeFormat(arguments.endTime, defaultTimeFormat);
			else
				schedEndTime = "23:59:59";
				
			schedEndDateTime = DateFormat(schedEndDate,"mm-dd-yyyy") & " " & TimeFormat(schedEndTime,"HH:mm:ss");
		
			// Make sure the End Date/Time is after the Start Date/Time
			if ( schedEndDateTime GT schedStartDateTime ) {
				schedEndDate = "";
				schedEndTime = "";
				schedEndDateTime = "";
			}
		}
		
		// Make sure the passed timeout value is a valid integer
		if ( IsNumeric(arguments.timeout) )
			schedRequestTimeOut = int(arguments.timeout);
			
		// Validate authtoken (Future authentication feature)
		//validAuthToken = application.ADF.csSecurity.isValidAuthToken(arguments.authtoken);
		validAuthToken = true;
		
		if ( LEN(TRIM(arguments.AuthToken)) AND validAuthToken )
			schedURL = schedURL & "&authtoken=" & arguments.authtoken;
		
		// Set up the return result struct variables
		retResult.status = "";
		retResult.authenicated = validAuthToken; //Future authentication feature
	</cfscript>

	<cftry>
		
		<!--- // set the recurring scheduled task --->
		<cfschedule 
			task="#arguments.taskName#"
			url="#arguments.url#"
			action="update"
			operation="HTTPRequest"
			startdate="#schedStartDate#"
			starttime="#schedStartTime#"
			enddate="#schedEndDate#"
			endtime="#schedEndTime#"
			interval="#schedInterval#"
			publish="yes"
			file="#uniqueLogFileName#"
			path="#logFileDir#"
			requesttimeout="#schedRequestTimeOut#">
			
			<cfset retResult.status = "success">
		<cfcatch type="any">
			<cfset retResult.status = "failed">
			<cfif StructKeyExists(cfcatch,"message")>
				<cfset retResult.msg = cfcatch.message>
			</cfif>
		</cfcatch>
	</cftry>
	
	<cfreturn retResult>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$appOverrideCSParams
Summary:
	Used in Custom Fields Types for Props (XPARAMS) and in Custom Scripts for Parameters (ATTRIBUTES) 
	as a hook it to override key and values from with global params from the App  
Returns:
	Struct
Arguments:
	Struct csParams
	String appName
	String appParamsVarName
	String paramsExceptionList
History:
	2013-02-12 - GAC - Created
	2013-02-13 - GAC - Updated to allow params to be added to the return struct event if they are not in the original csParams struct
--->
<cffunction name="appOverrideCSParams" access="public" returntype="struct" output="false" hint="Used in Custom Fields Types for Props (XPARAMS)and in Custom Scripts for Parameters (ATTRIBUTES) as a hook it to override key and values from with global params from the App.">
	<cfargument name="csParams" type="struct" default="#StructNew()#" required="false" hint="The structure of parameters or props from the CS custom script or custom field type">
	<cfargument name="appName" type="string" default="" required="false" hint="The name of the App that is providing the override variable structure">
	<cfargument name="appParamsVarName" type="string" default="" required="false" hint="The name of override variable structure">
	<cfargument name="paramsExceptionList" type="string" default="" required="false" hint="A list of params that cannot be orverriden by the app">
	<cfscript>
		var retParams = arguments.csParams;
		var paramsOverride = StructNew();
		var key = "";
		// Build the App Params Struct that will override the XPARAMS/ATTRIBUTES keys and values
		If ( LEN(TRIM(arguments.appName)) AND LEN(TRIM(arguments.appParamsVarName)) ) {
			if ( StructKeyExists(application,TRIM(arguments.appName)) AND StructKeyExists(application[TRIM(arguments.appName)],TRIM(arguments.appParamsVarName)) )
				paramsOverride = application[TRIM(arguments.appName)][TRIM(arguments.appParamsVarName)];
			// Replace the the XPARAMS PROPS values with the APP CONFIG override values
			if ( IsStruct(paramsOverride) ) {
				for ( key in paramsOverride ) {
					// Check to make sure the param from the App can override the CS param
					if ( ListFindNoCase(arguments.paramsExceptionList,key) EQ 0 )
						retParams[key] = paramsOverride[key];	
				}	
			}
		}
		return retParams;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$doThrow
Summary:
	Used to throw errors in CFSCRIPT blocks since the cfscript 'throw' is not cf8 compatible
Returns:
	void
Arguments:
	String - message
	String - type
	String - detail
	Boolean - logerror
History:
 	2014-04-04 - GAC - Created
--->
<cffunction name="doThrow" access="public" returntype="void" hint="Used to throw errors in CFSCRIPT blocks since the cfscript 'throw' is not cf8 compatible">
	<cfargument name="message" type="string" required="false" default="" hint="Error Message to Throw">
	<cfargument name="type" type="string" required="false" default="Application" hint="Error Type to Throw">
	<cfargument name="detail" type="string" required="false" default="" hint="Error Message Detail to Throw">
	<cfargument name="logerror" type="boolean" required="false" default="false" hint="Log the error.">
	<cfargument name="logfile" type="string" required="false" default="" hint="Log the error file name.">
	<cfset var logMsg = "">
	<cfif LEN(TRIM(arguments.message))>
		<!--- // Option to log the error that is going to be thrown --->
		<cfif LEN(TRIM(arguments.logerror))>
			<cfset logMsg = arguments.message>
			<cfif LEN(TRIM(arguments.detail)) AND arguments.detail NEQ arguments.message>
				<cfset logMsg = logMsg & " Detail: #arguments.detail#">
			</cfif>
			<cfif LEN(TRIM(arguments.logFile))>
				<cfset logAppend(msg=logMsg,logFile=arguments.logFile)>
			<cfelse>
				<cfset logAppend(msg=logMsg)>
			</cfif>
		</cfif> 
		<cfthrow message="#arguments.message#" type="#arguments.type#" detail="#arguments.detail#">
	</cfif>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$processADFDumpVar
Summary:
	Returns the processed ADFdumpVar variable string as the provided variable's evaluated data. 
Returns:
	any
Arguments:
	String - dumpVarStr
	Boolean - sanitize
History:
 	2014-05-22 - GAC - Created
--->
<cffunction name="processADFDumpVar" access="public" returntype="any" output="true" hint="Returns the processed ADFdumpVar variable string as the provided variable's evaluated data.">
	<cfargument name="dumpVarStr" type="string" required="false" default="" hint="">
	<cfargument name="sanitize" type="boolean" required="false" default="true" hint="For security this must be TRUE by default">
	
	<cfscript>
		var retData = StructNew();
		var dataTemp = Evaluate(arguments.dumpVarStr); // Evalute the passed in variable // TODO: We need to find a better way to do this!
		
		// Clean the secure data from the dump data
		if ( arguments.sanitize ) 
		{
			// Use
			if ( arguments.dumpVarStr EQ "server" )
			{
				retData.dumpMsg = "The ADFDumpVar utility cannot be used to dump the entire SERVER scope";
			}
			else
			{
				retData = sanitizeADFDumpVarData(dumpVarStr=arguments.dumpVarStr,dumpVarData=dataTemp);
			}
		}
		else
			retData = dataTemp;
		
		return retData;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$sanitizeADFDumpVarData
Summary:
	Returns a ADFdumpVar data from the ADFdumpVar URL command with secure data sanitized. 
	
	The current version specificly focuses on replacing each site's' CCAPI config password
	that is stored in the Server.ENVIRONMENT array.
Returns:
	any
Arguments:
	String - dumpVarStr
	Any - dumpVarData
History:
 	2014-05-22 - GAC - Created
--->
<cffunction name="sanitizeADFDumpVarData" access="public" returntype="any" output="false" hint="Returns a ADFdumpVar data from the ADFdumpVar URL command with secure data sanitized.">
	<cfargument name="dumpVarStr" type="string" required="false" default="" hint="">
	<cfargument name="dumpVarData" type="any" required="false" default="" hint="the data evaluated from url.ADFdumpVar">
	
	<cfscript>
		var retData = "";
		var configPWscope = "server";
		var configPWkey = "cspassword";
		var configPWReplaceValue = "**************";
		var pwFindArray = ArrayNew(1);
		var i = 1;
		var k = 1;
		var n = 1;
		var configPWpath = "";
		var configPWpathKey = "";
		var configPWpathKeyList = "";	
		var configPWpathArray = ArrayNew(1);
		var varPath = "";
		
		retData = arguments.dumpVarData;
		
		if ( ListFirst(arguments.dumpVarStr,".") EQ configPWscope )
		{
			if ( ListFindNoCase(arguments.dumpVarStr,configPWkey,".") AND IsSimpleValue(arguments.dumpVarData) )
			{
				retData = configPWReplaceValue;
			}
			else if ( IsStruct(arguments.dumpVarData) AND arguments.dumpVarStr NEQ "server")
			{
				if ( arguments.dumpVarStr EQ "server" AND StructKeyExists(arguments.dumpVarData,"ADF") )
				{
						retData = tempData[arguments.dumpVarData];
				}
				else
				{
					retData = Duplicate(arguments.dumpVarData);
				}
//application.ADF.utils.doDump(retData,"data dump - before work",1);	
				
				pwFindArray = StructFindKey(retData,configPWkey,"all");
//application.ADF.utils.doDump(pwFindArray,"PW FIND ARRAY!",0);
				
				for ( i=1; i LTE ArrayLen(pwFindArray); i=i+1 )
				{
					configPWpath = pwFindArray[i].path;
//application.ADF.utils.doDump(configPWpath,"configPWpath",0);writeoutput("<br>");	
					
					//configPWpathHasNumbersArray = REMATCH("(\.[0-9]+)",configPWpath);
//application.ADF.utils.doDump(configPWpathHasNumbersArray,"configPWpathHasNumbersArray",0);writeoutput("<br>");

					if ( REFindNoCase("(\.[0-9]+)",configPWpath) ) 
					{
						configPWpathArray = ListToArray(configPWpath,".");
//application.ADF.utils.doDump(configPWpathArray,"configPWpathArray",0);

						varPath = "retData";		
						for ( n=1; n LTE ArrayLen(configPWpathArray); n=n+1 )
						{
							if ( IsNumeric(configPWpathArray[n]) )
								varPath = varPath & "[" & configPWpathArray[n] & "]";
							else if ( configPWpathArray[n] NEQ configPWkey )
							{
								varPath = varPath & "." & configPWpathArray[n];
								
								//varPath = varPath & "['" & configPWpathArray[n] & "']";
							}
						}
//application.ADF.utils.doDump(varPath,"varPath",0);writeoutput("<br>");
					
						data = Evaluate(varPath);
					
						//data = StructGet(varPath);
						//data = StructGet(configPWpath);
//application.ADF.utils.doDump(data,"data",0);writeoutput("<br>");
						
						StructUpdate(data, configPWkey, configPWReplaceValue);
						//"#varPath#" = configPWReplaceValue;
					} 
					else
					{
						configPWpath = REREPLACE( configPWpath,"(\.)([0-9]+)","[\2]","all");
//application.ADF.utils.doDump(configPWpath,"configPWpath",0);writeoutput("<br>");

						"retData#configPWpath#" = configPWReplaceValue;
					} 
					
				}
//application.ADF.utils.doDump(retData,"data dump - after work",1);			
				
			}
//application.ADF.utils.doDump(retData,"data dump - after work: 1",1);
		}
		
		return retData;
	</cfscript>
</cffunction>

</cfcomponent>