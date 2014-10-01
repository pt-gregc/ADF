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
	Base.cfc
Summary:
	Base component for Custom Application Common Framework
History:
	2009-05-11 - MFC - Created
	2011-01-21 - GAC - Added a getADFversion function
	2011-04-05 - MFC - Updated the version property.
					   Added a getCSVersion function.
	2011-07-11 - MFC - Updated INIT function to remove call to "super.init".
	2011-09-27 - GAC - Added a getADFminorVersion to only return first two version digits
	2013-10-21 - GAC - Added 'file-version' property for ADF core files
	2014-02-26 - GAC - Updated for version 1.7.0
--->
<cfcomponent name="Base" hint="Base component for Custom Application Common Framework">

<cfproperty name="version" value="1_7_1">
<cfproperty name="file-version" value="4">
	
<cffunction name="init" output="true" returntype="any">
	<cfscript>
		StructAppend(variables, arguments, false);
		return this;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc. 	
	G. Cronkright
Name:
	getADFversion
Summary:
	Returns the ADF Version
Returns:
	String - ADF Version
Arguments:
	Void
History:
	2011-01-20 - GAC - Created
--->
<cffunction name="getADFversion" access="public" returntype="string">
	<cfscript>
		var ADFversion = "0.0.0";
		if ( StructKeyExists(server.ADF,"version") )
			ADFversion = server.ADF.version;
	 	return ADFversion;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.	
	G. Cronkright
Name:
	getDecimalADFVersion
Summary:
	Returns the the major and minor digits of the ADF Version in decimal format
		for comparing.
Returns:
	Numeric - ADF Decimal Version 
Arguments:
	Void
History:
	2011-09-27 - GAC/MFC - Created
	2011-09-28 - GAC - Updated to use the VAL function to remove the version numbers after the minor version
--->
<cffunction name="getDecimalADFVersion" access="public" returntype="numeric">
	<cfscript>
		var ADFversion = getADFversion();
		return Val(ADFversion);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.
	M. Carroll
Name:
	getCSversion
Summary:
	Returns the CS Version as based on the "server.ADF.csVersion" loaded
		in Core.cfc.
Returns:
	numeric - ADF Version
Arguments:
	Void
History:
	2011-04-05 - MFC - Created
--->
<cffunction name="getCSVersion" access="public" returntype="numeric">
	<cfscript>
		var csVersion = "5.1.0";
		if ( StructKeyExists(server.ADF,"csVersion") )
			csVersion = server.ADF.csVersion;
	 	return csVersion;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ron West
Name:
	$deserializeXML
Summary:
	Converts XML into CF struct
Returns:
	Struct rtnData
Arguments:
	String XMLString
History:
 	2011-03-20 - RLW - Created
--->
<cffunction name="deserializeXML" access="public" returnType="struct" hint="Converts XML into CF Struct">
	<cfargument name="XMLString" type="string" required="true" hint="XML String to be deserialized into CF">
	<cfscript>
		var rtnData = structNew();
		if( isXML(arguments.XMLString) )
			rtnData = server.CommonSpot.MapFactory.deserialize(arguments.XMLString);
	</cfscript>
	<cfreturn rtnData>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	D. Merrill
Name:
	$siteDBIsUnicode
Summary:
	Returns the a boolean value indicating whether the site db is unicode or not.
Returns:
	boolean
Arguments:
	none
History:
	2014-01-15 - DRM - Created
--->
<cffunction name="siteDBIsUnicode" output="no" returntype="boolean">
	<cfset var qry = "">

	<cfquery name="qry" datasource="#Request.Site.Datasource#">
		SELECT nativeDataType
		  FROM Commonspot_Schema
		 WHERE tableName = <cfqueryparam value="DATA_FIELDVALUE" cfsqltype="CF_SQL_VARCHAR">
			AND columnName = <cfqueryparam value="MEMOVALUE" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

	<cfscript>
		if (left(qry.nativeDataType, 1) eq "N")
			return true;
		return false;
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
<!--- // doLog(msg="foo",logFile="logFile.log") --->
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
			
		if ( !isSimpleValue(arguments.msg) )
			arguments.msg = doOutput(arguments.msg,"#arguments.label#msg-#dateFormat(Now(), 'yyyy-mm-dd')# #timeFormat(Now(), 'HH:mm:ss')#",0,1);
	</cfscript>
	
	<cflock timeout="30" throwontimeout="Yes" name="#safeLogName#FileLock" type="EXCLUSIVE">
		<cffile action="append" file="#arguments.logDir##logFileNameWithExt#" output="#utcNow# (UTC) - #arguments.label# #arguments.msg#" addnewline="true" fixnewline="true">
	</cflock>
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
	Boolean - expand
	Numeric - returnInVar
History:
	2014-03-24 - GAC - Created
--->
<!--- // doOutput(msg="foo",label="bar") --->
<cffunction name="doOutput" access="private" returntype="string" output="true" hint="A local private method to output debug data to the page during the build process">
	<cfargument name="msg" type="any" required="true">
	<cfargument name="label" required="no" type="string" default="no label">
	<cfargument name="expand" required="no" type="boolean" default="true">
	<cfargument name="returnInVar" required="no" type="boolean" default="0">
	
	<cfscript>
		var resultHTML = "";
	</cfscript>
	
	<!--- // process the dump and save it to the return variable --->
	<cfsavecontent variable="resultHTML">
		<cfif IsSimpleValue(arguments.msg)>
			<cfoutput><div><cfif LEN(TRIM(arguments.label)) AND arguments.expand EQ true><strong>#arguments.label#:</strong> </cfif>#arguments.msg#</div></cfoutput>
		<cfelse>
			<cfdump var="#arguments.msg#" label="#arguments.label#" expand="#arguments.expand#">
		</cfif>
	</cfsavecontent>

	<!--- // output the dump in place or pass to the return of the function --->
	<cfif !arguments.returnInVar>
		<!--- // outputing the dump in place so set the return to an empty string to avoid duplicate output --->
		<cfoutput>#resultHTML#</cfoutput>
		<cfreturn "">
	<cfelse>
		<cfreturn resultHTML>	
	</cfif>
</cffunction>

</cfcomponent>
