<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2016.
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
	log_1_0.cfc
Summary:
	Logging tools for the ADF Library
Version:
	1.0
History:
	2015-12-15 - GAC - Created
--->
<cfcomponent displayname="log_1_0" extends="ADF.lib.libraryBase" hint="Logging tools for the ADF Library">
    <cfproperty name="version" value="1_0_0">
    <cfproperty name="type" value="singleton">
    <cfproperty name="wikiTitle" value="Log_1_0">

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
	History:
		2008-06-17 - RLW - Created
		2011-07-15 - RAK - Converted msg to be able to take anything
		2012-11-16 - SFS - Added Label argument so that you can individually label each complex object dump
		2013-02-20 - SFS - Added label name to the cffile so that the passed in label is actually part of the dump
		2013-11-20 - GAC - Added hints to the msg, addTimeStamp and the label arguments
		2013-12-05 - DRM - Create formatted UTC timestamp in local code, avoids crash logging ADF startup errors when ADF isn't built yet
		                   default logFile to adf-debug.log, instead of debug.log
		2014-09-19 - GAC - Add a parameter to make the UTC timestamp optional
		2015-12-22 - GAC - Moved to the Log_1_0 lib component
	--->
	<cffunction name="logAppend" access="public" returntype="void" hint="Logs any error to a log file">
		<cfargument name="msg" type="any" required="true" hint="if this value is NOT a simple string then the value gets converted to sting output using CFDUMP">
		<cfargument name="logFile" type="string" required="false" default="adf-debug.log">
		<cfargument name="addTimeStamp" type="boolean" required="false" default="true" hint="Adds a date stamp to the file name">
		<cfargument name="logDir" type="string" required="false" default="#request.cp.commonSpotDir#logs/">
		<cfargument name="label" type="string" required="false" default="" hint="Adds a text label to the log entry">
		<cfargument name="useUTC" type="boolean" required="false" default="true" hint="Converts the timestamp in the entry and the filename to UTC">

		<cfscript>
			var logFileName = arguments.logFile;
			var dateTimeStamp = mid(now(), 6, 19);

			if( arguments.addTimeStamp )
				logFileName = dateFormat(now(), "yyyymmdd") & "." & request.site.name & "." & logFileName;

			if( len(arguments.label) )
				arguments.label = arguments.label & "-";

			if ( arguments.useUTC )
				dateTimeStamp = mid(dateConvert('local2utc', dateTimeStamp), 6, 19) & " (UTC)";
		</cfscript>

		<cftry>
			<!--- Check if the file exists --->
			<cfif NOT directoryExists(arguments.logdir)>
				<cfdirectory action="create" directory="#arguments.logdir#">
			</cfif>
			<cfif NOT isSimpleValue(arguments.msg)>
				<cfset arguments.msg = application.ADF.utils.doDump(arguments.msg,"#arguments.label# - #dateTimeStamp#",0,1)>
			</cfif>
			<cffile action="append" file="#arguments.logDir##logFileName#" output="#dateTimeStamp# - #arguments.label# #arguments.msg#" addnewline="true" fixnewline="true">
			<cfcatch type="any">
				<cfdump var="#arguments.logDir##logFileName#" label="Log File: #arguments.logDir##logFileName#" />
				<cfdump expand="false" label="LogAppend() Error" var="#cfcatch#" />
			</cfcatch>
		</cftry>
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
    /* *************************************************************** */
    Author:
        PaperThin, Inc.
    Name:
        $addLogEntry
    Summary:
        Wrapper for the CommonSpot AddLogEntry function
    Returns:
        void
    Arguments:
        String message
        String CFCatch
        Boolean forceStackTrace
        String fileName
        Boolean useDatePrefix
        Boolean wantAllStacks
    Usage:
        addLogEntry(message,CFCatch,forceStackTrace,fileName,useDatePrefix,wantAllStacks)
    History:
        2015-12-22 - GAC - Created
    --->
    <cffunction name="addLogEntry" access="public" returntype="void" hint="Wrapper for the CommonSpot AddLogEntry function">
        <cfargument name="message" type="string" required="true" hint="">
        <cfargument name="CFCatch" type="any" required="false" default="" hint="">
        <cfargument name="forceStackTrace" type="boolean" required="false" default="false" hint="">
        <cfargument name="fileName" type="string" required="false" default="" hint="">
        <cfargument name="useDatePrefix" type="boolean" required="false" default="false" hint="">
        <cfargument name="wantAllStacks" type="boolean" required="false" default="false" hint="">

        <cfscript>
            if ( isSimpleValue(arguments.CFCatch) AND LEN(TRIM(arguments.CFCatch)) EQ 0 )
                Server.CommonSpot.addLogEntry(arguments.message);
            else
                Server.CommonSpot.addLogEntry(arguments.message,arguments.CFCatch,arguments.forceStackTrace,arguments.fileName,arguments.useDatePrefix,arguments.wantAllStacks);
        </cfscript>
    </cffunction>

    <!---
    /* *************************************************************** */
    Author:
        PaperThin, Inc.
        G. Cronkright
    Name:
        $doStepLogging
    Summary:
        Creates a Log file with line-by-line text based log entries based on the simple or complex data.
    Returns:
        Void
    Arguments:
        String - methodName
        String - processName
        String - appName
        String - logMsg
        Any - logData
        Boolean - addBreak
        String - breakChar
        Numeric - breakSize
        String - delimiter
    Usage:
        doStepLogging(methodName,processName,appName,logMsg,logData,addBreak,breakChar,breakSize,delimiter)
    History:
        2015-11-24 - GAC - Created
    --->
    <cffunction name="doStepLogging" access="public" returntype="void" hint="Creates a Log file with line-by-line text based log entries based on the simple or complex data.">
        <cfargument name="methodName" type="string" required="false" default="Used as a prefix in the log entry">
        <cfargument name="processName" type="string" required="false" default="General" hint="Used as a prefix in the log entry and as part of the log file name">
        <cfargument name="appName" type="string" required="false" default="ADF" hint="Used as part of the log file name">
        <cfargument name="logMsg" type="string" required="false" default="" hint="A log message to render as a single line in the log file">
        <cfargument name="logData" type="any" required="false" default="" hint="Structured data object like a query, an array or a structure rendered as multiple single line entries in the log file">
        <cfargument name="addBreak" type="boolean" required="false" default="false" hint="Renders a repeated character string after this log entry">
        <cfargument name="breakChar" type="string" required="false" default="-" hint="the character used for the step log break divider">
        <cfargument name="breakSize" type="numeric" required="false" default="80" hint="the size of the step log break divider">
        <cfargument name="delimiter" type="string" required="false" default=":" hint="a column delimiter character used to seperate data on a single line.">

        <cfscript>
            var logFileName = stepLogFileName(processName=arguments.processName,appName=arguments.appName);
            var logPrefix = arguments.processName & arguments.delimiter & " ";

            // Prepend the processName and if exists the methodName
            if ( LEN(TRIM(arguments.methodName)) )
                logPrefix = logPrefix & arguments.methodName & arguments.delimiter & " ";

            if ( LEN(TRIM(arguments.logMsg)) )
                logAppend( msg=logPrefix & arguments.logMsg, logfile=logFileName );

            doStepLogData(logFilename=logFileName,logPrefix=logPrefix,logData=arguments.logData,delimiter=arguments.delimiter);

            if ( arguments.addBreak AND arguments.breakSize GT 0 )
                logAppend( msg=RepeatString(arguments.breakChar,arguments.breakSize), logfile=logFileName );
        </cfscript>
    </cffunction>

    <!---
    /* *************************************************************** */
    Author:
        PaperThin, Inc.
        G. Cronkright
    Name:
        $doStepLogData
    Summary:
        Renders the data passed in as text log entries.
    Returns:
        Void
    Arguments:
        String - logFilename
        String - logPrefix
        Any - logData
        String - breakChar
        String - delimiter
    Usage:
        doStepLogData(logFilename,logPrefix,logData)
    History:
        2015-11-24 - GAC - Created
    --->
    <cffunction name="doStepLogData" access="public" returntype="void" hint="Renders the data passed in as text log entries.">
        <cfargument name="logFilename" type="string" required="true">
        <cfargument name="logPrefix" type="string" required="false" default="">
        <cfargument name="logData" type="any" required="false" default="">
        <cfargument name="breakChar" type="string" required="false" default="-" hint="the character used for the step log break divider">
        <cfargument name="delimiter" type="string" required="false" default=":">

        <cfscript>
            var logMsg = "";

            if ( IsArray(arguments.logData) )
                doStepLogArray(logFilename=arguments.logFileName,logPrefix=arguments.logPrefix,logData=arguments.logData,delimiter=arguments.delimiter);
            else if ( IsStruct(arguments.logData) )
                doStepLogStruct(logFilename=arguments.logFileName,logPrefix=arguments.logPrefix,logData=arguments.logData,delimiter=arguments.delimiter);
            else if ( IsQuery(arguments.logData) )
                doStepLogQuery(logFilename=arguments.logFileName,logPrefix=arguments.logPrefix,logData=arguments.logData,delimiter=arguments.delimiter);
            else if ( IsSimpleValue(arguments.logData) )
                doStepLogSimple(logFilename=arguments.logFileName,logPrefix=arguments.logPrefix,logData=arguments.logData);
            else
                logAppend( msg=arguments.logPrefix & "[[Complex Object]] ", logfile=arguments.logFileName );

            if ( !IsSimpleValue(arguments.logData) )
                logAppend( msg=arguments.logPrefix & RepeatString(arguments.breakChar,10), logfile=arguments.logFileName );
        </cfscript>
    </cffunction>

    <!---
    /* *************************************************************** */
    Author:
       PaperThin, Inc.
       G. Cronkright
    Name:
       $doStepLogSimple
    Summary:
       Renders the simple data as a text log entry
    Returns:
       Void
    Arguments:
       String - logFilename
       String - logPrefix
       String - logData
       Boolean - cleanData
    Usage:
       doStepLogSimple(logFilename,logPrefix,logData,cleanData)
    History:
       2015-11-24 - GAC - Created
    --->
    <cffunction name="doStepLogSimple" access="public" returntype="void" hint="Renders the simple data as a text log entry">
        <cfargument name="logFilename" type="string" required="true">
        <cfargument name="logPrefix" type="string" required="false" default="">
        <cfargument name="logData" type="string" required="false" default="">
        <cfargument name="cleanData" type="boolean" required="false" default="true">

        <cfscript>
            // Clean the data
            if ( LEN(TRIM(arguments.logData)) )
            {
                if ( arguments.cleanData )
                    arguments.logData = REREPLACE( arguments.logData,'([#chr(9)#-#chr(30)#])',' ','all');

                logAppend( msg=arguments.logPrefix & arguments.logData, logfile=arguments.logFileName );
            }
        </cfscript>
    </cffunction>

    <!---
    /* *************************************************************** */
    Author:
       PaperThin, Inc.
       G. Cronkright
    Name:
       $doStepLogArray
    Summary:
       Renders array data as multiple text log entries
    Returns:
       Void
    Arguments:
       String - logFilename
       String - logPrefix
       String - logData
       String - delimiter
    Usage:
       doStepLogArray(logFilename,logPrefix,logData,delimiter)
    History:
       2015-11-24 - GAC - Created
    --->
    <cffunction name="doStepLogArray" access="public" returntype="void" hint="Renders array data as text log entries">
        <cfargument name="logFilename" type="string" required="true">
        <cfargument name="logPrefix" type="string" required="false" default="">
        <cfargument name="logData" type="array" required="false" default="#ArrayNew(1)#">
        <cfargument name="delimiter" type="string" required="false" default=":">

        <cfscript>
            var i = 1;
            var logMsg = "";
            var dataName = "";
            var dataValue = "";

            for ( i=1; i LTE ArrayLen(arguments.logData); i=i+1 )
            {
                logMsg = "";
                dataName = i;
                dataValue = arguments.logData[i];

                logMsg = arguments.logPrefix & "[" & dataName & "]" & arguments.delimiter & " ";
                doStepLogData(logFilename=arguments.logFileName,logPrefix=logMsg,logData=dataValue,delimiter=arguments.delimiter);
            }
        </cfscript>
    </cffunction>

    <!---
    /* *************************************************************** */
    Author:
       PaperThin, Inc.
       G. Cronkright
    Name:
       $doStepLogStruct
    Summary:
       Renders struct data as multiple text log entries
    Returns:
       Void
    Arguments:
       String - logFilename
       String - logPrefix
       String - logData
       String - delimiter
    Usage:
       doStepLogStruct(logFilename,logPrefix,logData,cleanData)
    History:
       2015-11-24 - GAC - Created
    --->
    <cffunction name="doStepLogStruct" access="public" returntype="void" hint="Renders struct data as text log entries">
        <cfargument name="logFilename" type="string" required="true">
        <cfargument name="logPrefix" type="string" required="false" default="">
        <cfargument name="logData" type="struct" required="false" default="#StructNew()#">
        <cfargument name="delimiter" type="string" required="false" default=":">

        <cfscript>
            var key = "";
            var logMsg = "";
            var dataName = "";
            var dataValue = "";

            for ( key IN arguments.logData )
            {
                dataName = key;
                dataValue = arguments.logData[key];

                if ( dataName NEQ "FieldNames" )
                {
                    logMsg = arguments.logPrefix & "[" & dataName & "]" & arguments.delimiter & " ";
                    doStepLogData(logFilename=arguments.logFileName,logPrefix=logMsg,logData=dataValue,delimiter=arguments.delimiter);
                }
            }
        </cfscript>
    </cffunction>

    <!---
    /* *************************************************************** */
    Author:
       PaperThin, Inc.
       G. Cronkright
    Name:
       $doStepLogQuery
    Summary:
       Renders query data as multiple text log entries
    Returns:
       Void
    Arguments:
       String - logFilename
       String - logPrefix
       String - logData
       String - delimiter
    Usage:
       doStepLogQuery(logFilename,logPrefix,logData,cleanData)
    History:
       2015-11-24 - GAC - Created
    --->
    <cffunction name="doStepLogQuery" access="public" returntype="void" hint="Renders query data as multiple text log entries">
        <cfargument name="logFilename" type="string" required="true">
        <cfargument name="logPrefix" type="string" required="false" default="">
        <cfargument name="logData" type="query" required="false" default="#QueryNew('temp')#">
        <cfargument name="delimiter" type="string" required="false" default=":">

        <cfscript>
            var i = 1;
            var logMsg = "";
            var dataName = "";
            var dataValue = StructNew();

            logMsg = "#logPrefix# Query";
            logAppend( msg=logMsg, logfile=arguments.logFileName );

            for ( i=1; i LTE arguments.logData.RecordCount; i=i+1 )
            {
                dataName = "Row " & i & arguments.delimiter;
                dataValue = application.ADF.data.queryRowToStruct(query=arguments.logData,rowNum=i);

                logMsg = arguments.logPrefix & " -- " & dataName & " -- ";
                doStepLogStruct(logFilename=arguments.logFileName,logPrefix=logMsg,logData=dataValue,delimiter=arguments.delimiter);
            }
        </cfscript>
    </cffunction>

    <!---
    /* *************************************************************** */
    Author:
      PaperThin, Inc.
      G. Cronkright
    Name:
      $stepLogFileName
    Summary:
      Builds the log file name from data passed in
    Returns:
      Void
    Arguments:
      String - processName
      String - appName
    Usage:
      stepLogFileName(processName,appName)
    History:
      2015-11-24 - GAC - Created
    --->
    <cffunction name="stepLogFileName" access="public" returntype="string" hint="Builds the log file name from data passed in">
        <cfargument name="processName" type="string" required="false" default="General">
        <cfargument name="appName" type="string" required="false" default="Import">

        <cfscript>
            var logFileName = arguments.appName & "." & arguments.processName & ".step.log";
            return logFileName;
        </cfscript>
    </cffunction>

    <!---
    /* *************************************************************** */
    Author:
        PaperThin, Inc.
        G. Cronkright
    Name:
        $deleteStepLog
    Summary:
        Used to delete logs file based on the standard naming convention
    Returns:
        Void
    Arguments:
        String - processName
        String - appName
        Boolean - addTimeStamp
        String - logDir
    Usage:
        deleteStepLog(processName,appName,addTimeStamp,logDir)
    History:
        2015-11-24 - GAC - Created
    --->
    <cffunction name="deleteStepLog" access="public" returntype="void" hint="Used to delete logs file based on the standard naming convention">
        <cfargument name="processName" type="string" required="false" default="General">
        <cfargument name="appName" type="string" required="false" default="ADF">
        <cfargument name="addTimeStamp" type="boolean" required="false" default="true" hint="Adds a date stamp to the file name">
        <cfargument name="logDir" type="string" required="false" default="#request.cp.commonSpotDir#logs/">

        <cfscript>
            var logFileName = stepLogFileName(processName=arguments.processName,appName=arguments.appName);
            var fullFilePath = "";

            if( arguments.addTimeStamp )
                logFileName = dateFormat(now(), "yyyymmdd") & "." & request.site.name & "." & logFileName;

            fullFilePath = arguments.logDir & logFileName;

            if ( FileExists(fullFilePath) )
                FileDelete(fullFilePath);
        </cfscript>
    </cffunction>

</cfcomponent>