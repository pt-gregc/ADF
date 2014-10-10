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
	custom-code-package-builder.cfm
Summary:
	Tool to build a custom code package for files within the custom coding 
		CommonSpot directories.
History:
	2012-04-23 - MFC - Created
--->

<!--- Validate the User account to check if they are in the CPAdmin group to run this tool --->
<cfif NOT application.ADF.csSecurity.isValidCPAdmin()>
	<cfoutput>
		<p>You must be a member of the CPAdmin group to access this tool.</p>
	</cfoutput>
	<cfexit>
</cfif>

<cfscript>
	// Check the action for the form
	if ( NOT StructKeyExists(request.params, "action") )
		request.params.action = "form";
	
	valError = false;
	// Validate the form fields
	if ( request.params.action EQ "run" ){
		if ( NOT LEN(request.params.modifiedDate) ){
			valError = true;
			valErrorMsg = "Please enter the last modified date.";
		}
		if ( NOT StructKeyExists(request.params, "customCodeDir") ){
			valError = true;
			valErrorMsg = "Please select the custom code directories.";
		}
		if ( request.params.buildPackage EQ "yes" AND NOT LEN(request.params.packageDir) ){
			valError = true;
			valErrorMsg = "Please enter the build package directory.";
		}
	}
	
	// Check if we ran into an error and reload the the form
	if ( valError )
		request.params.action = "form";

	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQueryUI(themeName="pepper-grinder");
</cfscript>

<cfoutput>
	<script>
		jQuery(function() {
			jQuery( "table##package-builder ##modifiedDate" ).datepicker();
			jQuery( "table##package-builder input##buildButton" ).button();
		});
	</script>
	<style>
		table##package-builder td {
			padding: 5px;
		}
		table##package-builder tr##help-text td {
			font-size: 90%;
		}
	</style>
	
	<h2>Custom Code Package Builder</h2>
</cfoutput>

<!--- Run the processing --->
<cfif request.params.action EQ "run">
	<cfoutput>
		<p><a href="#cgi.SCRIPT_NAME#?action=form"><< Return to Form</a></p>
	</cfoutput>
	<!--- <cfdump var="#request.params#" label="request.params" expand="false"> --->
	
	<cfscript>
		timeStart = GetTickCount();
		
		// Global file query
		globalFileQuery = QueryNew('null');
		// Loop over the custom code directories selected
		for ( i=1; i LTE LISTLEN(request.params.customCodeDir); i++ ){
			currDir = #request.site.dir# & ListGetAt(request.params.customCodeDir, i);
			// Get the files for the directory
			currDirFileQry = directoryFiles(dirPath=currDir, recurse="true");
			//application.ADF.utils.dodump(currDirFileQry, "currDirFileQry", false);
			// Filter by the last modified date
			filterCurrDirFileQry = filterDirByModifiedDate(dirFileQry=currDirFileQry, lastModifiedDate=request.params.modifiedDate);
			//application.ADF.utils.dodump(filterCurrDirFileQry, "filterCurrDirFileQry", false);
			
			// Merge the new files into the global file Query
			globalFileQuery = mergeDirFileData(globalQry=globalFileQuery, newFileQry=filterCurrDirFileQry);
			//application.ADF.utils.dodump(globalFileQuery, "globalFileQuery", false);
		}
		timeEnd = GetTickCount();
		timer = timeEnd - timeStart;
		//application.ADF.utils.dodump(globalFileQuery, "globalFileQuery", false);
	</cfscript>
	<cfoutput>
		<p>Global File Query Run Time = #timer/1000# seconds</p>
		<p><strong>Custom Code Files Modified On or After #request.params.modifiedDate#:</strong><br /><br /></p>
	</cfoutput>
	
	<!--- Build package tasks --->
	<cfif request.params.buildPackage>
		<cfscript>
			timeStart = GetTickCount();
			srcFilePathStart = Replace(request.site.dir, "/", "\", "all");
			destFilePathStart = request.params.packageDir & ReplaceList(request.formattedTimestamp," ,:", "-,-") & "\";
		</cfscript>
		<cfoutput>
			<p>#destFilePathStart#</p><br />
		</cfoutput>
	</cfif>
	
	<!--- Loop over the files, list out files and build package (if required) --->
	<cfloop query="globalFileQuery">
		<cfset currFilePath = "#directory#\#name#">
		<cfoutput>
			<p>#currFilePath#</p>
		</cfoutput>
		<!--- Build package tasks --->
		<cfif request.params.buildPackage>
			<cfscript>
				// Replace everything after the request.site.dir with the package destintation
				destDirPath = ReplaceNoCase(directory, srcFilePathStart, destFilePathStart);
				// Build the new file destination
				destFilePath = "#destDirPath#\#name#";
				// Setup the destination directory
				dirExists = createDirectory(destDir=destDirPath);
				// Copy the file
				fileCopyStatus = copyFile(srcFilePath=currFilePath, destFilePath=destFilePath);
			</cfscript>
			<cfoutput>
				<p>dirExists = #dirExists# | fileCopyStatus = #fileCopyStatus#</p>
				<p>#destFilePath#</p><br />
			</cfoutput>
		</cfif>
	</cfloop>
	<!--- Build package tasks --->
	<cfif request.params.buildPackage>
		<cfscript>
			timeEnd = GetTickCount();
			timer = timeEnd - timeStart;
		</cfscript>
		<cfoutput>
			<p>Build Package Run Time = #timer/1000# seconds</p>
		</cfoutput>
	</cfif>

<!--- Load the form --->
<cfelse>
	<cfoutput>
		<p>Please enter the form field values to run the package builder.</p>
		<cfif valError>
			<p style="color:red;">#valErrorMsg#</p>
		</cfif>
		<form action="#cgi.SCRIPT_NAME#" method="post">
			<input type="hidden" name="action" id="action" value="run">
			
			<table id="package-builder" cellpadding="4" cellspacing="4">
				<tr>
					<td>Last Modified Date:</td>
					<td>
						<input type="text" name="modifiedDate" id="modifiedDate" value="">
					</td>
				</tr>
				<tr>
					<td>Custom Code Directories:</td>
					<td>
						<input type="checkbox" name="customCodeDir" id="customCodeDir" value="_cs_apps" checked="checked">_cs_apps<br />
						<input type="checkbox" name="customCodeDir" id="customCodeDir" value="customcf" checked="checked">customcf<br />
						<input type="checkbox" name="customCodeDir" id="customCodeDir" value="customfields" checked="checked">customfields<br />
						<input type="checkbox" name="customCodeDir" id="customCodeDir" value="datasheet-modules" checked="checked">datasheet-modules<br />
						<input type="checkbox" name="customCodeDir" id="customCodeDir" value="renderhandlers" checked="checked">renderhandlers<br />
						<input type="checkbox" name="customCodeDir" id="customCodeDir" value="templates" checked="checked">templates<br />
					</td>
				</tr>
				<tr>
					<td>Build Package?:</td>
					<td>
						<input type="radio" name="buildPackage" id="buildPackage" value="no" checked="checked">No<br />
						<input type="radio" name="buildPackage" id="buildPackage" value="yes">Yes<br />
					</td>
				</tr>
				<tr id="help-text">
					<td colspan="2">Selecting "Yes" will build the custom code package and store in the file path defined in the "Package Directory" field.</td>
				</tr>
				<tr>
					<td>Package Directory:</td>
					<td>
						<input type="text" name="packageDir" id="packageDir" value="#request.site.CSAPPSDIR#package-builder/" size="50">
					</td>
				</tr>
				<tr id="help-text">
					<td colspan="2">Enter the absolute path on the server to store the package.</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2">
						<input type="submit" name="buildButton" id="buildButton" value="Run Package Builder">
					</td>
				</tr>
			</table>
		</form>
	</cfoutput>
</cfif>


<cffunction name="directoryFiles" returntype="query" access="private" output="true" hint="Returns the files for the directory.">
	<cfargument name="dirPath" type="string" required="true" default="">
	<cfargument name="recurse" type="string" required="false" default="false">
	
	<cfset var dirQry = QueryNew("tmp")>
	<!--- recurse the custom app directory --->
	<cfdirectory action="list" 
				 directory="#arguments.dirPath#" 
				 name="dirQry" 
				 recurse="#arguments.recurse#"
				 type="file">
	
	<cfreturn dirQry>
</cffunction>

<cffunction name="filterDirByModifiedDate" access="private" returntype="Query" output="true">
	<cfargument name="dirFileQry" type="query" required="true">
	<cfargument name="lastModifiedDate" type="string" required="true">
	
	<cfset var filterQry = "">
	<cfset var dateFormat = CreateDate(YEAR(arguments.lastModifiedDate), MONTH(arguments.lastModifiedDate), DAY(arguments.lastModifiedDate))>
	<!--- <cfdump var="#dateFormat#"> --->
	<!--- Run a query of query to filter by the date last modified --->
	<cfquery name="filterQry" dbtype="query">
		SELECT 		*
		FROM		arguments.dirFileQry
		WHERE		type = 'File'
		AND			DATELASTMODIFIED >= <cfqueryparam cfsqltype="cf_sql_varchar" value="#dateFormat#">
		ORDER BY 	Directory
	</cfquery>
	<cfreturn filterQry>
</cffunction>

<cffunction name="mergeDirFileData" access="private" returntype="Query" output="true">
	<cfargument name="globalQry" type="query" required="true">
	<cfargument name="newFileQry" type="query" required="true">

	<cfscript>
		var retFileQry = QueryNew('null');
		
		// Check if the global query contains NO records, then set to the new file query
		if ( arguments.globalQry.RecordCount LTE 0 )
			return arguments.newFileQry;
	</cfscript>
	<!--- UNION the 2 queries --->
	<cfquery name="retFileQry" dbtype="query">
		SELECT 		*
		FROM 		arguments.globalQry
		UNION ALL
		SELECT 		*
		FROM arguments.newFileQry
	</cfquery>
	<cfscript>	
		return retFileQry;
	</cfscript>
</cffunction>

<cffunction name="createDirectory" access="private" returntype="boolean" output="true">
	<cfargument name="destDir" type="string" required="true">

	<cftry>
		<!--- Check to see if the directory exists --->
		<cfif DirectoryExists(arguments.destDir)>
			<cfreturn true>
		<cfelse>
			<!--- Create the directory --->
			<cfdirectory action="create" directory="#arguments.destDir#">
			<cfreturn true>
		</cfif>	
			
		<cfcatch>
			<cfreturn false>
		</cfcatch>
	</cftry>
</cffunction>

<cffunction name="copyFile" access="private" returntype="boolean" output="true">
	<cfargument name="srcFilePath" type="string" required="true">
	<cfargument name="destFilePath" type="string" required="true">

	<cftry>
		<!--- Check if the source file exists --->	
		<cfif FileExists(arguments.srcFilePath)>
			<cffile action="copy" source="#arguments.srcFilePath#" destination="#arguments.destFilePath#">		
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
		
		<cfcatch>
			<cfreturn false>
		</cfcatch>
	</cftry>

</cffunction>