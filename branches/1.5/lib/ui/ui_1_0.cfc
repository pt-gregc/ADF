<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2010.
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
History:
	2010-12-21 - GAC - Created
--->
<cfcomponent displayname="ui_1_0" extends="ADF.core.Base" hint="UI functions for the ADF Library">

<cfproperty name="version" value="1_0_0">
<cfproperty name="type" value="singleton">
<cfproperty name="csData" injectedBean="csData_1_0" type="dependency">
<cfproperty name="scripts" injectedBean="scripts_1_0" type="dependency">
<cfproperty name="wikiTitle" value="UI_1_0">

<!---
/* ***************************************************************
/*
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
	String formBean 
	String formMethod
	String urlParams - additional URL parameters to be passed to the form 
	String lbTitle 
	String linkClass
History:
	2010-12-21 - GAC - Created - Based on RLWs buildAddEditLink function in forms_1_5
--->
<cffunction name="buildLBAjaxProxyLink" access="public" returntype="string" output="false">
	<cfargument name="linkTitle" type="string" required="true">
	<cfargument name="bean" type="string" required="false" default="forms_1_5">
	<cfargument name="method" type="string" required="false" default="renderAddEditForm">
	<cfargument name="urlParams" type="string" required="false" default=""> 
	<cfargument name="lbTitle" type="string" required="false" default="#arguments.linkTitle#">
	<cfargument name="linkClass" type="string" required="false" default="">  
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
		<cfoutput><a href="javascript:;" rel="#application.ADF.ajaxProxy#?bean=#arguments.bean#&method=#arguments.method#&title=#arguments.lbTitle##uParams#" class="ADFLightbox<cfif LEN(TRIM(arguments.linkClass))> #arguments.linkClass#</cfif>" title="#arguments.linkTitle#">#arguments.linkTitle#</a></cfoutput>
	</cfsavecontent>
	<cfreturn rtnStr>
</cffunction>

<!---
/* ***************************************************************
/*
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
History:
	2010-12-21 - GAC - Created - Based on RLWs buildAddEditLink function in forms_1_5
--->
<cffunction name="buildLBcsPageLink" access="public" returntype="string" output="false">
	<cfargument name="linkTitle" type="string" required="true">
	<cfargument name="csPage" type="string" required="false" default="" hint="csPageID or csPageURL">
	<cfargument name="urlParams" type="string" required="false" default=""> 
	<cfargument name="lbTitle" type="string" required="false" default="#arguments.linkTitle#">
	<cfargument name="linkClass" type="string" required="false" default="">  
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
		<cfoutput><a href="javascript:;" rel="#csPgURL#?title=#arguments.lbTitle##uParams#" class="ADFLightbox<cfif LEN(TRIM(arguments.linkClass))> #arguments.linkClass#</cfif>" title="#arguments.linkTitle#">#arguments.linkTitle#</a></cfoutput>
	</cfsavecontent>
	<cfreturn rtnStr>
</cffunction>

</cfcomponent>