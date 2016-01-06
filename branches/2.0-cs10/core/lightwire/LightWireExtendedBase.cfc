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
	LightWireExtendedBase.cfc
History:
	2009-08-14 - MFC - Created
	2013-10-21 - GAC - Added 'file-version' property for ADF core files 
	2014-02-26 - GAC - Updated for version 1.7.0
	2014-03-24 - GAC - Added doLog and doOutput local private function to assit with debugging
	2014-10-07 - GAC - Updated for version 1.8.0
--->

<cfcomponent name="LightWireExtendedBase" extends="ADF.thirdParty.lightwire.LightWire" output="false">

<cfproperty name="version" value="2_0_0">
<cfproperty name="file-version" value="3">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	G. Cronkright
Name:
	$getBean
Summary:
	Override method for the Lightwire getBean method with added error handling.
	Used return a bean with all of its dependencies loaded..
Returns:
	void
Arguments:
	String - ObjectName 
History:
	2011-01-20 - GAC - Copied from Lightwire Lightwire.cfc
					   Modified to add error logging
--->
<cffunction name="getBean" returntype="any" access="public" output="false" hint="I return a bean with all of its dependencies loaded.">
	<cfargument name="ObjectName" type="string" required="yes" hint="I am the name of the object to generate.">
	<cfscript>
		var ReturnObject = '';
		var buildError = StructNew();
		
		try {
			// Call the getBean method from the extended Lightwire.cfc in Lightwire
			ReturnObject = Super.getBean(argumentCollection=arguments);
		}
		catch( Any e ) {
			// Build the Error Struct
			buildError.args = arguments;
			buildError.details = e;
			// Log the Error struct and add it to the ADF buildErrors Array 
			doBuildErrorLogging("getBean",buildError);
		}
		return ReturnObject;
	</cfscript>	
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	G. Cronkright
Name:
	doBuildErrorLogging
Summary:
	Create a Log file for the given error and add the error struct to the application.ADF.buildErrors Array
Returns:
	Boolean
Arguments:
	String - meathodName
History:
	2011-01-21 - GAC - Created
	2014-03-20 - GAC - Added parameter to allow debugging
					 - Updated the build struct to allow clearer display of the error detials
					 - Removed invalid filename characters when using the methodName as filename or lockname
	2014-03-24 - GAC - Moved the log file create process to its own local private method doLog
--->
<cffunction name="doBuildErrorLogging" access="public" returntype="void" hint="Create a Log file for the given error and add the error struct to the application.ADF.buildErrors Array">
	<cfargument name="methodName" type="string" required="false" default="GenericBuild" hint="method that was called that we should log">
	<cfargument name="errorDetailsStruct" type="struct" required="false" default="#StructNew()#" hint="Error details structure to log">
	<cfargument name="addBuildErrors" type="boolean" required="false" default="true" hint="Append error output to ADF build errors output.">
	
	<cfscript>
		var errorDumpStr = "";
		var safeMethodName = REReplaceNoCase(arguments.methodName,"[\W]","","ALL");
		//var logFileName = dateFormat(now(), "yyyymmdd") & "." & request.site.name & ".ADF_" & safeMethodName & "_Errors.htm";
		var logFileName = ".ADF_" & safeMethodName & "_Errors.htm";
		var errorStruct = StructNew();	
		
		// Add the methodName to the errorStruct
		errorStruct.ADFmethodName = arguments.methodName;
		errorStruct.ErrorDetails = arguments.errorDetailsStruct;
	</cfscript>
	
	<!--- // Package the error dump and write it to a html file in the logs directory --->
	<cfsavecontent variable="errorDumpStr">
		<cfdump var="#errorStruct#" label="#arguments.methodName# Error" expand="false">
	</cfsavecontent>
	
	<cfset doLog(msg=errorDumpStr,logFile=logFileName)>
	<!--- <cflock timeout="30" throwontimeout="Yes" name="#safeMethodName#FileLock" type="EXCLUSIVE">
		<cffile action="append" file="#request.cp.commonSpotDir#logs/#logFileName#" output="#request.formattedtimestamp# - #errorDumpStr#" addnewline="true">
	</cflock> --->
	
	<cfscript>
		// Add the errorStruct to the server.ADF.buildErrors Array
		if ( arguments.addBuildErrors )
			ArrayAppend(server.ADF.buildErrors,errorStruct);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	G. Cronkright
Name:
	doLog
Summary:
	A local private method to create cs formatted log files during the build process
Returns:
	Boolean
Arguments:
	Any - msg
	String - logFile
	Boolean - addTimeStamp
	String - logDir
	String - label
History:
	2014-03-24 - GAC - Created
--->
<!--- doLog(msg="foo",logFile="logFile.log") --->
<cffunction name="doLog" access="private" returntype="void" output="false" hint="A local private method to create cs formatted log files">
	<cfargument name="msg" type="any" required="true" hint="if this value is NOT a simple string then the value gets converted to sting output using CFDUMP">
	<cfargument name="logFile" type="string" required="false" default="ADF_log.log">
	<cfargument name="addTimeStamp" type="boolean" required="false" default="true" hint="Adds a date stamp to the file name">
	<cfargument name="logDir" type="string" required="false" default="#request.cp.commonSpotDir#logs/">
	<cfargument name="label" type="string" required="false" default="" hint="Adds a text label to the log entry">
	
	<cfscript>
		var logFileName = ListDeleteAt(arguments.logFile,ListLen(arguments.logFile,"."), ".");
		var logFileExt = ListLast(arguments.logFile,".");
		var safeLogName = REReplaceNoCase(logFileName,"[\W]","","ALL");
		var utcNow = mid(dateConvert('local2utc', now()), 6, 19);
		var logFileNameWithExt = request.site.name & "." & safeLogName & "." & logFileExt;
		
		if( arguments.addTimeStamp )
			logFileNameWithExt = dateFormat(now(), "yyyymmdd") & "." & logFileNameWithExt;
			
		if( len(arguments.label) )
			arguments.label = arguments.label & "-";
	</cfscript>
	
	<cflock timeout="30" throwontimeout="Yes" name="#safeLogName#FileLock" type="EXCLUSIVE">
		<cffile action="append" file="#arguments.logDir##logFileNameWithExt#" output="#utcNow# (UTC) - #arguments.label# #arguments.msg#" addnewline="true" fixnewline="true">
	</cflock>
	<!--- <cffile action="append" file="#arguments.logDir##logFileName#" output="#utcNow# (UTC) - #arguments.label# #arguments.msg#" addnewline="true" fixnewline="true"> --->
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	G. Cronkright
Name:
	doOutput
Summary:
	A local private method to output debug data to the page during the build process
Returns:
	Boolean
Arguments:
	String - msg
	String - label
History:
	2014-03-24 - GAC - Created
--->
<!--- doOutput(msg="foo",label="bar") --->
<cffunction name="doOutput" access="private" returntype="void" output="true" hint="A local private method to output debug data to the page during the build process">
	<cfargument name="msg" type="any" required="true">
	<cfargument name="label" type="string" default="" required="false">
	<cfif IsSimpleValue(arguments.msg)>
	<cfoutput>
	<div><cfif LEN(TRIM(arguments.label))>#arguments.label#: </cfif>#arguments.msg#</div>                        
	</cfoutput>                                                                                                              
	<cfelse>
	<cfdump var="#arguments.msg#" label="#arguments.label#" expand="false">
	</cfif>
	<!--- <cfflush> --->
</cffunction>

</cfcomponent>