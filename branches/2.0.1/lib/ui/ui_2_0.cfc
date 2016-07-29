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
	2016-06-28 - GAC - Added an updated version of the buildAddEditLink method
--->
<cfcomponent displayname="ui_2_0" extends="ui_1_0" hint="UI functions for the ADF Library">

<cfproperty name="version" value="2_0_2">
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
	$buildAddEditLink
Summary:
	Returns a nice string to renderAddEditForm with lightbox enabled
Returns:
	String rtnStr
Arguments:
	String linkTitle
	String formName
	Numeric dataPageID
	Boolean refreshparent
	String urlParams - additional URL parameters to be passed to the form
	String formBean 
	String formMethod 
	String lbTitle
	String linkClass
	String appName
	String uiTheme
	String linkText
	String buttonLibrary
	String buttonStyleClass
	String buttonSizeClass
History:
  	2016-06-28 - GAC - Versioned to work with other JS/CSS Libraries other than jQueryUI (eg. Bootstrap)
--->
<cffunction name="buildAddEditLink" access="public" returntype="string" output="true" hint="Returns a nice string to renderAddEditForm with lightbox enabled">
	<cfargument name="linkTitle" type="string" required="true" hint="Link Title">
	<cfargument name="formName" type="string" required="true" hint="Name of the form">
	<cfargument name="dataPageID" type="numeric" required="false" default="0" hint="Data pageID of the element, 0 is new">
	<cfargument name="refreshparent" type="boolean" required="false" default="false" hint="refresh the page or not?">
	<cfargument name="urlParams" type="string" required="false" default="" hint="additional URL parameters to be passed to the form">
	<cfargument name="formBean" type="string" required="false" default="forms_2_0" hint="bean for the form">
	<cfargument name="formMethod" type="string" required="false" default="renderAddEditForm" hint="method for the form">
	<cfargument name="lbTitle" type="string" required="false" default="#arguments.linkTitle#" hint="lightbox title">
	<cfargument name="linkClass" type="string" required="false" default="" hint="link class">
	<cfargument name="appName" type="string" required="false" default="" hint="app name">
	<cfargument name="uiTheme" type="string" required="false" default="ui-lightness" hint="JQueryUI Theme to load">
	<cfargument name="linkText" type="string" required="false" default="#arguments.linkTitle#" hint="Link text">
	<cfargument name="buttonLibrary" type="string" required="false" default="jQueryUI" hint="Options: jQueryUI,Bootstrap - Default: jQueryUI">
	<cfargument name="buttonStyleClass" type="string" required="false" default="" hint="Not used with jQueryUI. Bootstrap Examples: btn-default, btn-primary, btn-success, btn-info, btn-warning, btn-danger, btn-link">
	<cfargument name="buttonSizeClass" type="string" required="false" default="" hint="Not used with jQueryUI. Bootstrap Examples: btn-lg, btn-sm, or btn-xs">

	<cfscript>
		var rtnStr = "";
		var formID = variables.ceData.getFormIDByCEName(arguments.formName);
		var lbAction = "norefresh";
		var uParams = "";
		var btnLib = "jqueryui";
		var btnLibOptions = "jqueryui,bootstrap";

		if ( arguments.refreshparent )
			lbAction = "refreshparent";

		if ( LEN(TRIM(arguments.urlParams)) )
		{
			uParams = TRIM(arguments.urlParams);
			if ( Find("&",uParams,"1") NEQ 1 )
				uParams = "&" & uParams;
		}

		if ( ListFindNoCase(btnLibOptions,arguments.buttonLibrary) )
			btnLib = arguments.buttonLibrary;

		if ( btnLib EQ "bootstrap" )
		{
			if ( LEN(TRIM(arguments.buttonStyleClass)) EQ 0 )
				arguments.buttonStyleClass = "btn-primary";

			arguments.linkClass = "btn " & arguments.buttonStyleClass;

			if ( LEN(TRIM(arguments.buttonSizeClass)) )
				arguments.linkClass = arguments.linkClass & " " & arguments.buttonSizeClass;
		}
	</cfscript>
	
	<cfsavecontent variable="rtnStr">
		<cfscript>
			variables.scripts.loadJQuery();
			variables.scripts.loadADFLightbox();

			if ( btnLib EQ "jqueryui" )
				variables.scripts.loadJQueryUI(themeName=arguments.uiTheme);
			else if ( btnLib EQ "bootstrap" )
				variables.scripts.loadBootstrap();
		</cfscript>
		<cfoutput><a href="javascript:;" rel="#application.ADF.lightboxProxy#?bean=#arguments.formBean#&method=#arguments.formMethod#<cfif LEN(TRIM(arguments.appName))>&appName=#arguments.appName#</cfif>&formID=#formID#&dataPageID=#arguments.dataPageID#&lbAction=#lbAction#&title=#arguments.lbTitle##uParams#" class="ADFLightbox<cfif LEN(TRIM(arguments.linkClass))> #arguments.linkClass#</cfif>" title="#arguments.linkTitle#">#arguments.linkText#</a></cfoutput>
	</cfsavecontent>
	
	<cfreturn rtnStr>
</cffunction>

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
	2016-03-04 - GAC - Simplified and removed the use of cfsavecontent
--->
<cffunction name="csPageResourceHeader" access="public" returntype="void" output="true" hint="Outputs HTML for the CS 10.x page header which allow resources to render">
	<cfargument name="pageTitle" type="string" default="" hint="Page Title">

	<cfif NOT StructKeyExists(request,"ADFRanCSPageResourceHead")>
		<cfset request.ADFRanCSPageResourceHead = true>
		
		<!--- // Render the Page Header --->
		<cfoutput>
		<!DOCTYPE html>
		<html>
			<head>
				<title>#arguments.pageTitle#</title>
			</head>
			<body>
		</cfoutput>
	</cfif>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$csPageResourceFooter
Summary:
	Outputs HTML and the renderQueued() for the CS 10.x page footer which 
	allows the resources to render
Returns:
	void
Arguments:
	none
History:
	2016-02-23 - GAC - Created
	2016-03-04 - GAC - Simplified and removed the use of cfsavecontent
--->
<cffunction name="csPageResourceFooter" access="public" returntype="string" output="true" hint="Outputs HTML for the CS 10.x page footer which allow resources to render">

	<cfif NOT StructKeyExists(request,"ADFRanCSPageResourceFoot")>
		<cfset request.ADFRanCSPageResourceFoot = true>

		<cfscript>
			// Load the CommonSpot Resource Queue via the ADF scripts
			variables.scripts.renderQueued();
		</cfscript>

		<!--- // Render the Page Footer --->
		<cfoutput>
			</body>
		</html>
		</cfoutput>
	</cfif>
</cffunction>

</cfcomponent>