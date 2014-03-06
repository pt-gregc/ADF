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
	UI_1_0.cfc
Summary:
	UI functions for the ADF Library
Version:
	1.0
History:
	2010-12-21 - GAC - Created
	2011-01-21 - GAC - Moved in the lightbox wrapper function from forms_1_1
						Segmented out the lightbox header and footer in independant functions
	2011-02-09 - GAC - Removed self-closing CF tag slashes
	2013-11-18 - GAC - Updated the lib dependencies to scripts_1_2, csData_1_2, ceData_2_0
--->
<cfcomponent displayname="ui_1_0" extends="ADF.core.Base" hint="UI functions for the ADF Library">

<cfproperty name="version" value="1_0_2">
<cfproperty name="type" value="singleton">
<cfproperty name="ceData" injectedBean="ceData_2_0" type="dependency">
<cfproperty name="csData" injectedBean="csData_1_2" type="dependency">
<cfproperty name="scripts" injectedBean="scripts_1_2" type="dependency">
<cfproperty name="wikiTitle" value="UI_1_0">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
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
History:
  	2010-09-30 - RLW - Created
 	2010-10-18 - GAC - Modified - Added a RefreshParent parameter
   	2010-10-18 - GAC - Modified - Added a urlParams parameter
	2010-12-15 - GAC - Modified - Added bean, method and lbTitle parameters
	2010-12-21 - GAC - Modified - Added a linkClass parameter
	2011-01-20 - GAC - Moved to the ui_1_0 lib from the Forms_1_1 lib
	2011-01-25 - MFC - Modified - Updated bean param default value to "forms_1_1"
	2011-02-01 - GAC - Modified - Added the appName argument
	2011-02-03 - GAC - Modified - Updated to use use lightboxProxy.cfm instead of ajaxProxy.cfm
	2011-02-09 - GAC - Modified - Added the jquery and jueryUI headers and a jqueryUI theme parameter
	2011-03-08 - GAC - Modified - Added the ADFLightbox script headers
	2011-06-11 - GAC - Modified - Added the linkText parameter to allow linkTitle, lbTitle and linkText to each be defined individually
									while still maintaining backwards compatiblity with the primary linkTitle (required) parameter
--->
<cffunction name="buildAddEditLink" access="public" returntype="string" output="false" hint="Returns a nice string to renderAddEditForm with lightbox enabled">
	<cfargument name="linkTitle" type="string" required="true" hint="Link Title">
	<cfargument name="formName" type="string" required="true" hint="Name of the form">
	<cfargument name="dataPageID" type="numeric" required="false" default="0" hint="Data pageID of the element, 0 is new">
	<cfargument name="refreshparent" type="boolean" required="false" default="false" hint="refresh the page or not?">
	<cfargument name="urlParams" type="string" required="false" default="" hint="additional URL parameters to be passed to the form">
	<cfargument name="formBean" type="string" required="false" default="forms_1_1" hint="bean for the form">
	<cfargument name="formMethod" type="string" required="false" default="renderAddEditForm" hint="method for the form">
	<cfargument name="lbTitle" type="string" required="false" default="#arguments.linkTitle#" hint="lightbox title">
	<cfargument name="linkClass" type="string" required="false" default="" hint="link class">
	<cfargument name="appName" type="string" required="false" default="" hint="app name">
	<cfargument name="uiTheme" type="string" required="false" default="ui-lightness" hint="JQueryUI Theme to load">
	<cfargument name="linkText" type="string" required="false" default="#arguments.linkTitle#" hint="Link text">
	<cfscript>
		var rtnStr = "";
		var formID = variables.ceData.getFormIDByCEName(arguments.formName);
		var lbAction = "norefresh";
		var uParams = "";
		if ( arguments.refreshparent )
			lbAction = "refreshparent";
		if ( LEN(TRIM(arguments.urlParams)) ) {
			uParams = TRIM(arguments.urlParams);
			if ( Find("&",uParams,"1") NEQ 1 )
				uParams = "&" & uParams;
		}
	</cfscript>
	<cfsavecontent variable="rtnStr">
		<cfscript>
			variables.scripts.loadJQuery();
			variables.scripts.loadADFLightbox();
			variables.scripts.loadJQueryUI(themeName=arguments.uiTheme);
		</cfscript>
		<cfoutput><a href="javascript:;" rel="#application.ADF.lightboxProxy#?bean=#arguments.formBean#&method=#arguments.formMethod#<cfif LEN(TRIM(arguments.appName))>&appName=#arguments.appName#</cfif>&formID=#formID#&dataPageID=#arguments.dataPageID#&lbAction=#lbAction#&title=#arguments.lbTitle##uParams#" class="ADFLightbox<cfif LEN(TRIM(arguments.linkClass))> #arguments.linkClass#</cfif>" title="#arguments.linkTitle#">#arguments.linkText#</a></cfoutput>
	</cfsavecontent>
	<cfreturn rtnStr>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$buildLBAjaxProxyLink
Summary:	
	Returns a nice HTML string from a provided bean and method with lightbox enabled
Returns:
	String rtnStr
Arguments:
	String linkTitle
	String bean 
	String method
	String urlParams - additional URL parameters to be passed to the form 
	String lbTitle 
	String linkClass
	String appName
	String uiTheme
	String linkText
History:
	2010-12-21 - GAC - Created - Based on RLWs buildAddEditLink function in forms_1_1
	2011-01-25 - MFC - Modified - Updated bean param default value to "forms_1_1"
	2011-02-01 - GAC - Modified - Added the appName argument
	2011-02-03 - GAC - Modified - Updated to use the buildLightboxProxyLink method which uses lightboxProxy.cfm instead of ajaxProxy.cfm
	2011-02-09 - GAC - Modified - Added a jqueryUI theme parameter
	2011-06-11 - GAC - Modified - Added the linkText parameter to allow linkTitle, lbTitle and linkText to each be defined individually
									while still maintaining backwards compatiblity with the primary linkTitle (required) parameter  
--->
<cffunction name="buildLBAjaxProxyLink" access="public" returntype="string" output="false" hint="Returns a nice HTML string from a provided bean and method with lightbox enabled">
	<cfargument name="linkTitle" type="string" required="true" hint="Link Title">
	<cfargument name="bean" type="string" required="false" default="forms_1_1" hint="bean">
	<cfargument name="method" type="string" required="false" default="renderAddEditForm" hint="method">
	<cfargument name="urlParams" type="string" required="false" default="" hint="URL Parameters">
	<cfargument name="lbTitle" type="string" required="false" default="#arguments.linkTitle#" hint="Lightbox Title">
	<cfargument name="linkClass" type="string" required="false" default="" hint="Link Class">
	<cfargument name="appName" type="string" required="false" default="" hint="Application name">
	<cfargument name="uiTheme" type="string" required="false" default="ui-lightness" hint="JQueryUI Library to load">
	<cfargument name="linkText" type="string" required="false" default="#arguments.linkTitle#" hint="link text">
	<cfscript>
		var rtnStr = "";
	</cfscript>
	<cfsavecontent variable="rtnStr">
		<cfoutput>#buildLightboxProxyLink(argumentCollection=arguments)#</cfoutput>
	</cfsavecontent>
	<cfreturn rtnStr>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$buildLightboxProxyLink
Summary:	
	Returns a nice HTML string from a provided bean and method to call ADFlightbox using lightboxProxy.cfm
Returns:
	String rtnStr
Arguments:
	String linkTitle
	String bean 
	String method
	String appName
	String urlParams - additional URL parameters to be passed to the form 
	String lbTitle 
	String linkClass
	String uiTheme
	String linkText
History:
	2011-02-01 - GAC - Created - For LightboxProxy.cfm - Based on RLWs buildAddEditLink function in forms_1_1
	2011-02-09 - GAC - Modified - Added the jquery and jueryUI headers and a jqueryUI theme parameter
	2011-03-08 - GAC - Modified - Added the ADFLightbox script headers
	2011-06-11 - GAC - Modified - Added the linkText parameter to allow linkTitle, lbTitle and linkText to each be defined individually
									while still maintaining backwards compatiblity with the primary linkTitle (required) parameter
--->
<cffunction name="buildLightboxProxyLink" access="public" returntype="string" output="false" hint="Returns a nice HTML string from a provided bean and method to call ADFlightbox using lightboxProxy.cfm">
	<cfargument name="linkTitle" type="string" required="true" hint="Link Title">
	<cfargument name="bean" type="string" required="false" default="forms_1_1"  hint="Bean name">
	<cfargument name="method" type="string" required="false" default="renderAddEditForm" hint="method name">
	<cfargument name="urlParams" type="string" required="false" default="" hint="URL Parameters">
	<cfargument name="lbTitle" type="string" required="false" default="#arguments.linkTitle#" hint="Lightbox Title">
	<cfargument name="linkClass" type="string" required="false" default="" hint="Link Class">
	<cfargument name="appName" type="string" required="false" default="" hint="Application name">
	<cfargument name="uiTheme" type="string" required="false" default="ui-lightness" hint="JQuery UI Theme to load">
	<cfargument name="linkText" type="string" required="false" default="#arguments.linkTitle#" hint="Link Text">
	<cfscript>
		var rtnStr = "";
		var uParams = "";
		if ( LEN(TRIM(arguments.urlParams)) ) {
			uParams = TRIM(arguments.urlParams);
			if ( Find("&",uParams,"1") NEQ 1 ) 
				uParams = "&" & uParams;
		}
	</cfscript>
	<cfsavecontent variable="rtnStr">
		<cfscript>
			variables.scripts.loadJQuery();
			variables.scripts.loadADFLightbox();
			variables.scripts.loadJQueryUI(themeName=arguments.uiTheme);
		</cfscript>
		<cfoutput><a href="javascript:;" rel="#application.ADF.lightboxProxy#?bean=#arguments.bean#&method=#arguments.method#<cfif LEN(TRIM(arguments.appName))>&appName=#arguments.appName#</cfif>&title=#arguments.lbTitle##uParams#" class="ADFLightbox<cfif LEN(TRIM(arguments.linkClass))> #arguments.linkClass#</cfif>" title="#arguments.linkTitle#">#arguments.linkText#</a></cfoutput>
	</cfsavecontent>
	<cfreturn rtnStr>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$buildLBcsPageLink
Summary:	
	Returns a nice string to a provided PageID with lightbox enabled
Returns:
	String rtnStr
Arguments:
	String linkTitle
	String csPage - csPageID or csPageURL
	String urlParams - additional URL parameters to be passed to the form 
	String lbTitle 
	String linkClass
	String uiTheme
	String linkText
History:
	2010-12-21 - GAC - Created - Based on RLWs buildAddEditLink function in forms_1_1
	2011-02-09 - GAC - Modified - Added the jquery and jueryUI headers and a jqueryUI theme parameter
	2011-03-08 - GAC - Modified - Added the ADFLightbox script headers
	2011-06-11 - GAC - Modified - Added the linkText parameter to allow linkTitle, lbTitle and linkText to each be defined individually
									while still maintaining backwards compatiblity with the primary linkTitle (required) parameter
--->
<cffunction name="buildLBcsPageLink" access="public" returntype="string" output="false" hint="Returns a nice string to a provided PageID with lightbox enabled">
	<cfargument name="linkTitle" type="string" required="true" hint="Link Title">
	<cfargument name="csPage" type="string" required="false" default="" hint="csPageID or csPageURL">
	<cfargument name="urlParams" type="string" required="false" default="" hint="URL Parameters as a string">
	<cfargument name="lbTitle" type="string" required="false" default="#arguments.linkTitle#" hint="Title of the ligthbox">
	<cfargument name="linkClass" type="string" required="false" default="" hint="Class of the lightbox">
	<cfargument name="uiTheme" type="string" required="false" default="ui-lightness" hint="UI Theme to load">
	<cfargument name="linkText" type="string" required="false" default="#arguments.linkTitle#" hint="Text of the link">
	<cfscript>
		var rtnStr = "";
		var csPgURL = "";
		var uParams = "";
		
		if ( IsNumeric(arguments.csPage) ) 
			csPgURL = variables.csData.getCSPageURL(arguments.csPage);	
		else 
			csPgURL = arguments.csPage;

		if ( LEN(TRIM(arguments.urlParams)) ) {
			uParams = TRIM(arguments.urlParams);
			if ( Find("&",uParams,"1") NEQ 1 ) 
				uParams = "&" & uParams;
		}
	</cfscript>
	<cfsavecontent variable="rtnStr">
		<cfscript>
			variables.scripts.loadJQuery();
			variables.scripts.loadADFLightbox();
			variables.scripts.loadJQueryUI(themeName=arguments.uiTheme);
		</cfscript>
		<cfoutput><a href="javascript:;" rel="#csPgURL#?title=#arguments.lbTitle##uParams#" class="ADFLightbox<cfif LEN(TRIM(arguments.linkClass))> #arguments.linkClass#</cfif>" title="#arguments.linkTitle#">#arguments.linkText#</a></cfoutput>
	</cfsavecontent>
	<cfreturn rtnStr>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$wrapHTMLwithLBHeaderFooter
Summary:
	Given html returns html that is wrapped properly with the CS 6.x lightbox header and footer code.
Returns:
	string
Arguments:
	string html
History:
 	2011-01-05 - RAK - Created
	2011-01-19 - GAC - Modified - Moved to the UI Lib. And Changed the name of the function.
								 Segmented out the 6.x LB header and footer so they could be used outside of the wrap function 
	2011-01-28 - GAC - Modified - Removed the parameter isForm and added the parameter for tdClass so CSS classes can be added to the inner TD of the lightBox header
	2011-02-14 - MFC - Modified - Removed forceLightboxResize argument.
									Removed the global header/footer variables.
									Added lbCheckLogin parameter to validate if the user is authenticated.
	2011-06-11 - GAC - Modified - Removed the argumentsCollection from the lightboxHeader method call 
--->
<cffunction name="wrapHTMLwithLBHeaderFooter" access="public" returntype="string" output="false" hint="Given html returns html that is wrapped properly with the CS 6.x lightbox header and footer code.">
	<cfargument name="html" type="string" default="" hint="HTML to wrap">
	<cfargument name="lbTitle" type="string" default="" hint="Lightbox Title">
	<cfargument name="tdClass" type="string" default="" hint="Used to add CSS classes to the outer TD wrapper like 'formResultContainer' for the addEditRenderForm results">
	<cfargument name="lbCheckLogin" type="boolean" default="1" required="false" hint="Have the lightbox validate login, by default this is on">
	<cfscript>
		var retHTML = "";
	</cfscript>
	<cfsavecontent variable="retHTML">
		<cfoutput>
		<!--- // Output the CS 6.x LB Header --->
		#lightboxHeader(lbTitle=arguments.lbTitle,tdClass=arguments.tdClass,lbCheckLogin=arguments.lbCheckLogin)#
		<!--- // Output the HTML --->
		#arguments.html#
		<!--- // Output the CS 6.x LB Footer --->
		#lightboxFooter()#
		</cfoutput>
	</cfsavecontent>
	<cfreturn retHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$lightboxHeader
Summary:	
	Returns HTML for the CS 6.x lightbox header (use with the lightboxFooter)
Returns:
	string 
Arguments:
	string lbTitle
	string tdClass
	boolean lbCheckLogin
History:
	2011-01-19 - GAC - Created
	2011-01-28 - GAC - Modified - Removed the parameter isForm and added the parameter for tdClass so CSS classes can be added to the inner TD of the lightBox header
	2011-02-09 - GAC - Comments - Updated the list of arguments in the comments header
	2011-02-11 - GAC - Modified - Fixed the logic with the LB Fixed the logic with the LB Header/Footer render twice protection
	2011-02-14 - MFC - Modified - Removed forceLightboxResize argument.
									Removed the global header/footer variables.
									Added lbCheckLogin parameter to validate if the user is authenticated.
	2011-03-20 - MFC - Added Else statement to add Table tag for CS5 lightbox resizing.
	2011-04-07 - RAK - Prevented this from getting called 2x in the same request and producing duplicate stuff
	2011-05-24 - RLW - Changed the "lbCheckLogin" arg to default to false.
	2014-03-05 - JTP - Var declarations
--->
<cffunction name="lightboxHeader" access="public" returntype="string" output="false" hint="Returns HTML for the CS 6.x lightbox header (use with the lightboxFooter)">
	<cfargument name="lbTitle" type="string" default="" hint="Lightbox Title">
	<cfargument name="tdClass" type="string" default="" hint="Used to add CSS classes to the outer TD wrapper like 'formResultContainer' for the addEditRenderForm results">
	<cfargument name="lbCheckLogin" type="boolean" default="0" required="false" hint="Validate the user is logged in">
	<cfscript>
		var retHTML = "";
		var productVersion = ListFirst(ListLast(request.cp.productversion," "),".");
		var CD_DialogName = '';
		var CD_Title = '';
		var CD_IncludeTableTop = 1;
		var CD_CheckLock = 0;
		var CD_CheckLogin = 0;
		var CD_CheckPageAlive = 0;		
	</cfscript>
	<cfif NOT StructKeyExists(request,"HaveRunDlgCommonHead")>
		<cfsavecontent variable="retHTML">
			<!--- // Load the CommonSpot Lightbox Header when in version 6.0 --->
			<cfif productVersion GTE 6>
				<cfscript>
					// Use the Title passed in or if available use the title in the request.params for the Lightbox DialogName
					if ( LEN(TRIM(arguments.lbTitle)) )
						CD_DialogName = arguments.lbTitle;
					else if ( StructKeyExists(request.params,"title"))
						CD_DialogName = request.params.title;
					else
						CD_DialogName = "";
					CD_Title=CD_DialogName;
					CD_IncludeTableTop=1;
					CD_CheckLock=0;
					// 2011-02-16 - Added flag to check if the user is authenticated
					CD_CheckLogin=arguments.lbCheckLogin;
					CD_CheckPageAlive=0;
				 </cfscript>
				<cfoutput>
					<CFINCLUDE TEMPLATE="/commonspot/dlgcontrols/dlgcommon-head.cfm">
					<tr>
						<td<cfif LEN(TRIM(arguments.tdClass))> class="#arguments.tdClass#"</cfif>>
				</cfoutput>
			<cfelse>
				<cfoutput>
					<table id="MainTable">
						<tr>
							<td>
				</cfoutput>
			</cfif>
		</cfsavecontent>
	</cfif>
	<cfreturn retHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$lightboxFooter
Summary:	
	Returns HTML for the CS 6.x lightbox footer (use with the lightboxHeader)
Returns:
	String retHTML
Arguments:
	none
History:
	2011-01-19 - GAC - Created 
	2011-02-11 - GAC - Modified - Fixed the logic with the LB Header/Footer render twice protection
	2011-02-14 - MFC - Modified - Removed the global header/footer variables.
	2011-03-20 - MFC - Added Else statement to add Table tag for CS5 lightbox resizing.
						Added scripts to resize the dialog on load.
	2011-03-30 - MFC - Changed the lightbox resize to call "lbResizeWindow()" in CS 5.
	2011-04-07 - RAK - Prevented this from getting called 2x in the same request and producing duplicate stuff
--->
<cffunction name="lightboxFooter" access="public" returntype="string" output="false" hint="Returns HTML for the CS 6.x lightbox footer (use with the lightboxHeader)">
	<cfscript>
		var retHTML = "";
	   	var productVersion = ListFirst(ListLast(request.cp.productversion," "),".");
	</cfscript>
	<cfif NOT StructKeyExists(request,"ADFRanDLGFoot")>
		<cfset request.ADFRanDLGFoot = true>
		<cfsavecontent variable="retHTML">
			<!--- // Load the CommonSpot Lightbox Footer when in version 6.x --->
			<cfif productVersion GTE 6>
				<cfoutput></td>
					</tr>
				<CFINCLUDE template="/commonspot/dlgcontrols/dlgcommon-foot.cfm">
				</cfoutput>
			<cfelse>
				<!--- CS 5 and under, close Table Tab --->
				<cfoutput>
							</td>
						</tr>
					</table>
					<!--- Load JQuery to resize the dialog after loading --->
					<cfscript>
						application.ADF.scripts.loadJQuery();
					</cfscript>
					<script type="text/javascript">
						// Resize with the CS lightbox scripts
						jQuery(document).ready(function() {
							lbResizeWindow();
						});
					</script>
				</cfoutput>
			</cfif>
		</cfsavecontent>
	</cfif>
	<cfreturn retHTML>
</cffunction>

</cfcomponent>