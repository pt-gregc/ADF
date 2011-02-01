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
Version:
	1.0.0
History:
	2010-12-21 - GAC - Created
	2011-01-21 - GAC - Moved in the lightbox wrapper function from forms_1_1
						Segmented out the lightbox header and footer in independant functions
--->
<cfcomponent displayname="ui_1_0" extends="ADF.core.Base" hint="UI functions for the ADF Library">

<cfproperty name="version" value="1_0_0" />
<cfproperty name="type" value="singleton" />
<cfproperty name="ceData" injectedBean="ceData_1_1" type="dependency" />
<cfproperty name="csData" injectedBean="csData_1_1" type="dependency" />
<cfproperty name="scripts" injectedBean="scripts_1_1" type="dependency" />
<cfproperty name="wikiTitle" value="UI_1_0" />

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
History:
  	2010-09-30 - RLW - Created
 	2010-10-18 - GAC - Modified - Added a RefreshParent parameter
   	2010-10-18 - GAC - Modified - Added a urlParams parameter
	2010-12-15 - GAC - Modified - Added bean, method and lbTitle parameters
	2010-12-21 - GAC - Modified - Added a linkClass parameter
	2011-01-20 - GAC - Moved to the ui_1_0 lib from the Forms_1_1 lib
	2011-01-25 - MFC - Modified - Updated bean param default value to "forms_1_1"
--->
<cffunction name="buildAddEditLink" access="public" returntype="string" output="false">
	<cfargument name="linkTitle" type="string" required="true">
	<cfargument name="formName" type="string" required="true">
	<cfargument name="dataPageID" type="numeric" required="false" default="0">
	<cfargument name="refreshparent" type="boolean" required="false" default="false">
	<cfargument name="urlParams" type="string" required="false" default="">
	<cfargument name="formBean" type="string" required="false" default="forms_1_1">
	<cfargument name="formMethod" type="string" required="false" default="renderAddEditForm">
	<cfargument name="lbTitle" type="string" required="false" default="#arguments.linkTitle#">
	<cfargument name="linkClass" type="string" required="false" default="">   
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
		<cfoutput><a href="javascript:;" rel="#application.ADF.ajaxProxy#?bean=#arguments.formBean#&method=#arguments.formMethod#&formID=#formID#&dataPageID=#arguments.dataPageID#&lbAction=#lbAction#&title=#arguments.lbTitle##uParams#" class="ADFLightbox<cfif LEN(TRIM(arguments.linkClass))> #arguments.linkClass#</cfif>" title="#arguments.linkTitle#">#arguments.linkTitle#</a></cfoutput>
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
	String formBean 
	String formMethod
	String urlParams - additional URL parameters to be passed to the form 
	String lbTitle 
	String linkClass
History:
	2010-12-21 - GAC - Created - Based on RLWs buildAddEditLink function in forms_1_1
	2011-01-25 - MFC - Modified - Updated bean param default value to "forms_1_1"
--->
<cffunction name="buildLBAjaxProxyLink" access="public" returntype="string" output="false">
	<cfargument name="linkTitle" type="string" required="true">
	<cfargument name="bean" type="string" required="false" default="forms_1_1">
	<cfargument name="method" type="string" required="false" default="renderAddEditForm">
	<cfargument name="appName" type="string" required="false" default="">
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
		<cfoutput><a href="javascript:;" rel="#application.ADF.ajaxProxy#?bean=#arguments.bean#&method=#arguments.method#<cfif LEN(TRIM(arguments.appName))>&appName=#arguments.appName#</cfif>&title=#arguments.lbTitle##uParams#" class="ADFLightbox<cfif LEN(TRIM(arguments.linkClass))> #arguments.linkClass#</cfif>" title="#arguments.linkTitle#">#arguments.linkTitle#</a></cfoutput>
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
History:
	2010-12-21 - GAC - Created - Based on RLWs buildAddEditLink function in forms_1_1
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
History:
	2011-02-01 - GAC - Created - For LightboxProxy.cfm - Based on RLWs buildAddEditLink function in forms_1_1
--->
<cffunction name="buildLightboxProxyLink" access="public" returntype="string" output="false">
	<cfargument name="linkTitle" type="string" required="true">
	<cfargument name="bean" type="string" required="false" default="forms_1_1">
	<cfargument name="method" type="string" required="false" default="renderAddEditForm">
	<cfargument name="appName" type="string" required="false" default="">
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
		<cfoutput><a href="javascript:;" rel="#application.ADF.lightboxProxy#?bean=#arguments.bean#&method=#arguments.method#<cfif LEN(TRIM(arguments.appName))>&appName=#arguments.appName#</cfif>&title=#arguments.lbTitle##uParams#" class="ADFLightbox<cfif LEN(TRIM(arguments.linkClass))> #arguments.linkClass#</cfif>" title="#arguments.linkTitle#">#arguments.linkTitle#</a></cfoutput>
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
--->
<cffunction name="wrapHTMLwithLBHeaderFooter" access="public" returntype="string" output="false" hint="Given html returns html that is wrapped properly with the CS 6.x lightbox header and footer code.">
	<cfargument name="html" type="string" default="" hint="HTML to wrap">
	<cfargument name="lbTitle" type="string" default="">
	<cfargument name="tdClass" type="string" default="" hint="Used to add CSS classes to the outer TD wrapper like 'formResultContainer' for the addEditRenderForm results">
	<cfargument name="forceLightboxResize" type="boolean" default="false">
	<cfscript>
		var retHTML = "";
	</cfscript>
	<cfsavecontent variable="retHTML">
		<cfoutput>
		<!--- // Output the CS 6.x LB Header --->
		#lightboxHeader(argumentCollection=arguments)#
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
	String retHTML
Arguments:
	boolean isForm
History:
	2011-01-19 - GAC - Created
	2011-01-28 - GAC - Modified - Removed the parameter isForm and added the parameter for tdClass so CSS classes can be added to the inner TD of the lightBox header
--->
<cffunction name="lightboxHeader" access="public" returntype="string" output="false" hint="Returns HTML for the CS 6.x lightbox header (use with the lightboxFooter)">
	<cfargument name="lbTitle" type="string" default="">
	<cfargument name="tdClass" type="string" default="" hint="Used to add CSS classes to the outer TD wrapper like 'formResultContainer' for the addEditRenderForm results">
	<cfargument name="forceLightboxResize" type="boolean" default="false">
	<cfscript>
		var retHTML = "";
	    var productVersion = ListFirst(ListLast(request.cp.productversion," "),".");
	    if ( productVersion GTE 6 ) {
	     	// Shared variable to be detected by the 6.x LB Footer
	     	variables.hasLightBoxHeader = true;
	     	// Request.params variable to override/disable the addMainTable in LightboxProxy.cfm if 6.x LB header and footer are used
	    	request.params.addMainTable = false;
	    }
	</cfscript>
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
				CD_CheckLogin=1;
				CD_CheckPageAlive=0;
				//CD_OnLoad="handleOnLoad();";
				//CD_OnLoad="";
		        APIPostToNewWindow = false;
			</cfscript>
			<cfoutput>
				<CFINCLUDE TEMPLATE="/commonspot/dlgcontrols/dlgcommon-head.cfm">
				<tr>
					<td<cfif LEN(TRIM(arguments.tdClass))> class="#arguments.tdClass#"</cfif>>
				<cfif arguments.forceLightboxResize>
				<script type="text/javascript">
			        <!--
			        function handleOnLoad()
			        {
			           ResizeWindow();
			        }
			        // -->
		        </script>
		        </cfif>
			</cfoutput> 
		</cfif>		
	</cfsavecontent>
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
--->
<cffunction name="lightboxFooter" access="public" returntype="string" output="false" hint="Returns HTML for the CS 6.x lightbox footer (use with the lightboxHeader)">
	<cfscript>
		var retHTML = "";
	    var productVersion = ListFirst(ListLast(request.cp.productversion," "),".");
	</cfscript>
	<cfsavecontent variable="retHTML">
		<!--- // Load the CommonSpot Lightbox Footer when in version 6.0 --->
		<cfif productVersion GTE 6 AND variables.hasLightBoxHeader>
			<cfoutput></td>
				</tr>
			<CFINCLUDE template="/commonspot/dlgcontrols/dlgcommon-foot.cfm">
			</cfoutput>
		</cfif>		
	</cfsavecontent>
	<cfreturn retHTML>
</cffunction>

</cfcomponent>