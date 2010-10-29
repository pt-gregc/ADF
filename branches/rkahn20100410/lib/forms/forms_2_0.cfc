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
	forms_2_0.cfc
Summary:
	Form functions for the ADF Library
History:
	2009-09-28 - MFC - Created
--->
<cfcomponent displayname="forms_2_0" extends="ADF.lib.forms.forms_1_0" hint="Form functions for the ADF Library">

<cfproperty name="version" value="2_0_0">
<cfproperty name="type" value="transient">
<cfproperty name="ceData" injectedBean="ceData_1_0" type="dependency">
<cfproperty name="scripts" injectedBean="scripts_1_0" type="dependency">
<cfproperty name="wikiTitle" value="Forms_1_0">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$renderAddEditForm
Summary:	
	Returns the HTML for an Add/Edit Custom element record
Returns:
	String formHTML
Arguments:
	Numeric - formID - the Custom Element Form ID
	Numeric - dataPageID - the dataPageID for the record that you would like to edit
	String - lbAction - Lightbox action on close, norefresh or refreshparent
	String - customizedFinalHtml - HTML to display when form is submitted
History:
	2009-08-03 - MFC - Created
	2009-11-11 - MFC - Updates to force the jquery script to load
	2010-06-04 - MFC - Added IF statement to check for lbAction to refresh parent
	2010-06-07 - MFC - Updated the render form to not call the special RTE operations when above CS 6.
	2010-09-28 - MFC - Updated the Lightbox forms to load the CS Dialog headers and footers.
--->
<cffunction name="renderAddEditForm" access="public" returntype="String" hint="Returns the HTML for an Add/Edit Custom element record">
	<cfargument name="formID" type="numeric" required="true">
	<cfargument name="dataPageId" type="numeric" required="true">
	<cfargument name="lbAction" type="string" required="false" default="norefresh">
	<cfargument name="customizedFinalHtml" type="string" required="false" default="">
	<cfargument name="renderResult" type="boolean" required="false" default="0">
	<cfargument name="callback" type="string" required="false" default="">
	
	<cfscript>
		var APIPostToNewWindow = false;
		var rtnHTML = "";
		var formResultHTML = "";
		// Find out if the CE contains an RTE field
		var formContainRTE = application.ADF.ceData.containsFieldType(arguments.formID, "formatted_text_block");
	
		// Check if the title is defined
		if ( NOT StructKeyExists(request.params, "title") ){
			request.params.title = "";
		}
	</cfscript>
	
	<!--- Result from the Form Submit --->
	<cfsavecontent variable="formResultHTML">
		<!--- Render the dlg header --->
		<cfscript>
			CD_DialogName = request.params.title;
			CD_Title=CD_DialogName;
			CD_IncludeTableTop=1;
			CD_CheckLock=0;
			CD_CheckLogin=1;
			CD_CheckPageAlive=0;
			//CD_OnLoad="handleOnLoad();";
			//CD_OnLoad="";
         	APIPostToNewWindow = false;
		</cfscript>
		<CFINCLUDE TEMPLATE="/commonspot/dlgcontrols/dlgcommon-head.cfm">
		<cfoutput><tr><td></cfoutput>
		<cfoutput>
		<cfscript>
			variables.scripts.loadADFLightbox(force=1);
		</cfscript>
		<script type='text/javascript'>
			jQuery(document).ready(function(){
				if ( "#arguments.lbAction#" == "refreshparent" )
					closeLBReloadParent();
				closeLB();
			});
		</script>
		</cfoutput>
		<!--- Render the dlg footer --->
		<cfoutput></tr></td></cfoutput>
		<CFINCLUDE template="/commonspot/dlgcontrols/dlgcommon-foot.cfm">
	</cfsavecontent>
		
	<!--- HTML for the form --->
	<cfsavecontent variable="rtnHTML">
		<cfscript>
			CD_DialogName = request.params.title;
			CD_Title=CD_DialogName;
			CD_IncludeTableTop=1;
			CD_CheckLock=0;
			CD_CheckLogin=1;
			CD_CheckPageAlive=0;
			//CD_OnLoad="handleOnLoad();";
			//CD_OnLoad="";
         		APIPostToNewWindow = false;
		</cfscript>
		<CFINCLUDE TEMPLATE="/commonspot/dlgcontrols/dlgcommon-head.cfm">
		<cfoutput>
			<cfscript>
				variables.scripts.loadJQuery(force=1);
				//variables.scripts.loadADFLightbox();
			</cfscript>
			<!--- Call the UDF function --->
			<tr><td>#Server.CommonSpot.UDF.UI.RenderSimpleForm(arguments.dataPageID, arguments.formID, APIPostToNewWindow, formResultHTML)#</td></tr>
		</cfoutput>
		<CFINCLUDE template="/commonspot/dlgcontrols/dlgcommon-foot.cfm">
	</cfsavecontent>
	
	<cfreturn rtnHTML>
	
</cffunction>

</cfcomponent>