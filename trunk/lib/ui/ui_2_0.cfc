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
	UI_2_0.cfc
Summary:
	UI functions for the ADF Library
Version:
	2.0
History:
	2015-08-31 - GAC - Created
	2016-02-23 - GAC - Added csPageResourceHeader and csPageResourceFooter methods
--->
<cfcomponent displayname="ui_2_0" extends="ui_1_0" hint="UI functions for the ADF Library">

<cfproperty name="version" value="2_0_1">
<cfproperty name="type" value="singleton">
<cfproperty name="ceData" injectedBean="ceData_3_0" type="dependency">
<cfproperty name="csData" injectedBean="csData_2_0" type="dependency">
<cfproperty name="scripts" injectedBean="scripts_2_0" type="dependency">
<cfproperty name="wikiTitle" value="UI_2_0">

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$csPageResourceHeader
Summary:
	Outputs HTML for the CS 10.x page header which allow resources to render
Returns:
	void
Arguments:
	string pageTitle
History:
	2016-02-23 - GAC - Created
--->
<cffunction name="csPageResourceHeader" access="public" returntype="void" output="true" hint="Outputs HTML for the CS 10.x page header which allow resources to render">
	<cfargument name="pageTitle" type="string" default="" hint="Page Title">

	<cfscript>
		var outputHTML = "";
	</cfscript>

	<cfif NOT StructKeyExists(request,"ADFRanCSPageResourceHead")>
		<cfset request.ADFRanCSPageResourceHead = true>
		<cfsavecontent variable="outputHTML">
		<!--- // Render the Page Header --->
		<cfoutput>
		<!DOCTYPE html>
		<html>
			<head>
				<title>#arguments.pageTitle#</title>
			</head>
		<body>
		</cfoutput>
		</cfsavecontent>
	</cfif>
	
	<cfoutput>#outputHTML#</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$csPageResourceFooter
Summary:
	Outputs HTML for the CS 10.x page footer which allow resources to render
Returns:
	void
Arguments:
	none
History:
	2016-02-23 - GAC - Created
--->
<cffunction name="csPageResourceFooter" access="public" returntype="string" output="true" hint="Outputs HTML for the CS 10.x page footer which allow resources to render">

	<cfscript>
		var outputHTML = "";
	</cfscript>

	<cfif NOT StructKeyExists(request,"ADFRanCSPageResourceFoot")>
		<cfset request.ADFRanCSPageResourceFoot = true>

		<cfscript>
			// Load the CommonSpot Resource Queue
			Server.CommonSpot.UDF.resources.renderQueued();
		</cfscript>

		<cfsavecontent variable="outputHTML">
			<!--- // Render the Page Footer --->
			<cfoutput>
					</body>
				</html>
			</cfoutput>
		</cfsavecontent>
	</cfif>

	<cfoutput>#outputHTML#</cfoutput>
</cffunction>

</cfcomponent>