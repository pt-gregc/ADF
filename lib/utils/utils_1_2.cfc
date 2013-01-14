<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2012.
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
--->
<cfcomponent displayname="utils_1_2" extends="ADF.lib.utils.utils_1_1" hint="Util functions for the ADF Library">

<cfproperty name="version" value="1_2_1">
<cfproperty name="type" value="singleton">
<cfproperty name="ceData" type="dependency" injectedBean="ceData_1_1">
<cfproperty name="csData" type="dependency" injectedBean="csData_1_1">
<cfproperty name="data" type="dependency" injectedBean="data_1_1">
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
--->
<cffunction name="pageRedirect" access="public" returntype="void">
	<cfargument name="targetURL" type="any" required="true">
	<cfif arguments.targetURL contains "http">
		<cflocation url="http://#arguments.targetURL#" addtoken="No">
	<cfelse>
		<cflocation url="#arguments.targetURL#" addtoken="No">
	</cfif>
</cffunction>

</cfcomponent>