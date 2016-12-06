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
	utils_2_0.cfc
Summary:
	Util functions for the ADF Library
Version:
	2.0
History:
	2015-08-31 - MFC - Created
	2016-11-15 - GAC - Added createDataFileFolders,fixFilePathSlashes,writeDataFile,writeCSSfile methods
--->
<cfcomponent displayname="utils_2_0" extends="utils_1_2" hint="Util functions for the ADF Library">

<cfproperty name="version" value="2_0_1">
<cfproperty name="type" value="singleton">
<cfproperty name="ceData" type="dependency" injectedBean="ceData_3_0">
<cfproperty name="csData" type="dependency" injectedBean="csData_2_0">
<cfproperty name="data" type="dependency" injectedBean="data_2_0">
<cfproperty name="wikiTitle" value="Utils_2_0">

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$writeCSSfile
Summary:
	A function to write string data to a file
Returns:
	string
Arguments:
	string - filePath
	string - dataString
	boolean - overwrite
	charSet - string
History:
	2016-05-25 - GAC - Created
--->
<cffunction name="writeCSSfile" access="public" returntype="string" hint="A function to create a new WDDX packet">
	<cfargument name="filePath" type="string" required="true" hint="Full File Path">
	<cfargument name="dataString" type="string" required="false" default="" hint="data string to be written to the file">
	<cfargument name="overwrite" type="boolean" required="false" default="true" hint="If true, delete old file and create new file.">
	<cfargument name="charSet" type="string" required="false" default="utf-8" hint="CF File CharSet Encoding to use.">

	<cfscript>
		var writeStatus = "";
		var allowedFileTypes = "css";

		if ( ListFindNoCase(allowedFileTypes,ListLast(arguments.FilePath,".")) EQ 0 )
			return "not-css-file";

		writeStatus = writeDataFile(filePath=arguments.filePath,dataString=arguments.dataString,overwrite=arguments.overwrite,charSet=arguments.charSet);

		return writeStatus;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$writeDataFile
Summary:
	A function to write string data to a file
Returns:
	string
Arguments:
	string - filePath
	string - dataString
	boolean - overwrite
	charSet - string
History:
	2016-05-25 - GAC - Created
--->
<cffunction name="writeDataFile" access="public" returntype="string" hint="A function to create a new WDDX packet">
	<cfargument name="filePath" type="string" required="true" hint="Full File Path">
	<cfargument name="dataString" type="string" required="false" default="" hint="data string to be written to the file">
	<cfargument name="overwrite" type="boolean" required="false" default="true" hint="If true, delete old file and create new file.">
	<cfargument name="charSet" type="string" required="false" default="utf-8" hint="CF File CharSet Encoding to use.">

	<cfscript>
		var writeStatus = "";
		var dirCreate = StructNew();
		var allowedFileTypes = "ini,xml,wddx,txt,css,log";

		if ( ListFindNoCase(allowedFileTypes,ListLast(arguments.FilePath,".")) EQ 0 )
			return "invalid-file-type";
	</cfscript>

	<cfif LEN(TRIM(arguments.dataString))>
		<!--- // If file exists and overwrite is false do NOT delete the file and create a new one --->
		<cfif FileExists(arguments.filePath) AND arguments.overwrite IS false>
			<cfset writeStatus = "exists">
		</cfif>
		<cfif writeStatus NEQ "exists">
			<!--- // If needed, create directory (or directories) to store data file --->
			<cfset dirCreate = createDataFileFolders(arguments.filePath)>
			<cfif StructKeyExists(dirCreate,"Status") AND dirCreate.Status NEQ "dir-create-failed">
				<cftry>
					<!--- // Write the dataString to a file --->
					<cflock timeout="30" throwontimeout="Yes" name="writeDataFileLock" type="EXCLUSIVE">
						<cffile action="write" file="#arguments.filePath#" output="#arguments.dataString#" charset="#arguments.charSet#" addNewLine="false">
					</cflock>
					<cfset writeStatus = "success">
					<cfcatch type="any">
						<cfset writeStatus = "failed">
					</cfcatch>
				</cftry>
			<cfelse>
				<cfset writeStatus = "no-folder">
			</cfif>
		<cfelse>
			<cfset writeStatus = "exists">
			<!--- // TODO: Test code - if file exists (and overwrite is false) then append the dataString to the end end of the file --->
			<!--- <cftry>
					<!--- // Update file by appending dataString to the end of the existing file contents --->
					<cflock timeout="30" throwontimeout="Yes" name="writeDataFileLock" type="EXCLUSIVE">
						<cffile action="write" file="#arguments.filePath#" output="#arguments.dataString#" charset="#arguments.charSet#" addNewLine="true">
					</cflock>
					<cfset writeStatus = "success-exists-updated">
					<cfcatch type="any">
						<cfset writeStatus = "failed-exists">
					</cfcatch>
			</cftry> --->
		</cfif>
	<cfelse>
		<cfset writeStatus = "no-data">
	</cfif>

	<cfreturn writeStatus>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$fixFilePathSlashes
Summary:
	Returns the Full URL removing the double slash when the request.site.url and forumURL are combined
Returns:
	String
Arguments:
	string - filePath
	string - charToFind - default = "\"
	string - charToReplace - default = "/"
	string - scope - default = "all"
History:
	2016-05-25 - GAC - Created
--->
<cffunction name="fixFilePathSlashes" access="public" returntype="string" output="true" hint="">
	<cfargument name="filePath" type="string" required="true">
	<cfargument name="charToFind" type="string" default="\">
	<cfargument name="charToReplace" type="string" default="/">
	<cfargument name="scope" type="string" default="all">

	<cfscript>
		var retStr = arguments.filePath;

		if ( FindNoCase(arguments.charToFind,retStr,1) )
			retStr = ReplaceNoCase(retStr,arguments.charToFind,arguments.charToReplace,arguments.scope);

		return retStr;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$createDataFileFolders
Summary:
	A function to create the directory folders for the data file ... if needed

	Inspired by:
		http://cflib.org/udf/makeDirs
		makeDirs by	Jorge Iriso (jiriso@fitquestsl.com)
		version 1, September 21, 2004
Returns:
	struct
Arguments:
	string - filePath
History:
	2016-05-25 - GAC - Created
--->
<cffunction name="createDataFileFolders" access="public" returntype="struct" hint="A function to create the directory folders for the data file if needed">
	<cfargument name="filePath" type="string" required="true" hint="Full File Path or a folder path">

	<cfscript>
		var fullPath = fixFilePathSlashes(arguments.filePath);
		var folderPath = GetDirectoryFromPath(fullPath);
		var retStatus = StructNew();

		// If folder exists the we are done here... move on
		if ( DirectoryExists(folderPath) )
			retStatus.status = "dir-exists";
		else
		{
			try
			{
				CreateObject("java", "java.io.File").init(folderPath).mkdirs();
				retStatus.status = "dir-created";
			}
			catch (any e)
			{
				retStatus.status = "dir-create-failed";
			}
		}

		return retStatus;
	</cfscript>
</cffunction>

</cfcomponent>