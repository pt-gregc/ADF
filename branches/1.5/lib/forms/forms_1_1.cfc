<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2011.
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
	forms_1_1.cfc
Summary:
	Form functions for the ADF Library
Version:
	1.1.0
History:
	2009-09-28 - MFC - Created
	2010-12-20 - MFC - Updated Forms_1_1 for dependency to Scripts_1_5.
--->
<cfcomponent displayname="forms_1_1" extends="ADF.lib.forms.forms_1_0" hint="Form functions for the ADF Library">

<cfproperty name="version" value="1_1_0">
<cfproperty name="type" value="transient">
<cfproperty name="ceData" injectedBean="ceData_1_1" type="dependency">
<cfproperty name="scripts" injectedBean="scripts_1_1" type="dependency">
<cfproperty name="wikiTitle" value="Forms_1_1">

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
	2010-11-28 - RAK - Updated to have callback functionality
	2010-12-09 - RAK - Updated callback functionality to return an object containing all the form parameters
	2010-12-17 - MFC - Updated to force the load ADF Lightbox scripts for CE's with RTE fields.
						Moved the call to the UDF to output directly.
						Removed commented and unneeded code in the dlg header variables.
	2010-12-20 - MFC - Undo the param to force load ADF Lightbox scripts and the UDF to load
						into a variable.  These work now that Forms has the dependency for
						Scripts_1_5.
	2010-12-20 - RAK - Fixed a bunch of issues related to forms 1_5 callbacks not working properly.
	2010-12-21 - MFC - Added force params to loading scripts in the formResultHTML content block.
						Updated the form result to use the customizedFinalHtml argument or the default.
						Removed the renderResult param and IF blocks.
	2010-12-27 - MFC/RAK - Updated the form storage for the callback into the Document pageWindow space.
							Removed the form data storage in the cookie.
	2011-01-13 - MFC - Updated the form result LB Action params.
	2011-01-24 - RAK - Updated the code to handle callbacks pointing at checkboxes returning values only when checked
--->
<cffunction name="renderAddEditForm" access="public" returntype="String" hint="Returns the HTML for an Add/Edit Custom element record">
	<cfargument name="formID" type="numeric" required="true">
	<cfargument name="dataPageId" type="numeric" required="true">
	<cfargument name="lbAction" type="string" required="false" default="norefresh">
	<cfargument name="customizedFinalHtml" type="string" required="false" default="">
	<cfargument name="callback" type="string" required="false" default="">

	<cfscript>
		var APIPostToNewWindow = false;
		var rtnHTML = "";
		var formResultHTML = "";
		// Find out if the CE contains an RTE field
		var formContainRTE = application.ADF.ceData.containsFieldType(arguments.formID, "formatted_text_block");
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
		</cfscript>
		<CFINCLUDE TEMPLATE="/commonspot/dlgcontrols/dlgcommon-head.cfm">
		<cfoutput><tr><td class="formResultContainer"></cfoutput>
		<!--- Set the form result html to the argument if defined --->
		<cfoutput>
			<cfscript>
				// Load the scripts, check if we need to load 
				//	the JSON scripts for the callback.
				variables.scripts.loadJQuery(force=1);
				variables.scripts.loadADFLightbox(force=1);
			</cfscript>
			<script type='text/javascript'>
				jQuery(document).ready(function(){
					ResizeWindow();
					<cfif Len(arguments.callback)>
						// Get the PageWindow and the form value
						var pageWindow = commonspot.lightbox.getPageWindow();
						var value = pageWindow.ADFFormData.formValueStore; 
						//Call the callback with the form value
						getCallback('#arguments.callback#', value);
					</cfif>
				});
			</script>
			<!--- Set the form result HTML
					If none defined, then check the LBACTION param.
			 --->
			<cfif LEN(arguments.customizedFinalHtml)>
				<cfoutput>#arguments.customizedFinalHtml#</cfoutput>
			<cfelse>
				<!--- If the LB Action is to refresh parent --->
				<cfif arguments.lbAction EQ "refreshparent">
					<script type='text/javascript'>
						closeLBReloadParent();
					</script>
				<cfelseif LEN(arguments.callback) eq 0>
					<!--- Else if we don't have a callback, then close the LB --->
					<script type='text/javascript'>
						closeLB();
					</script>
				</cfif>
			</cfif>
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
		</cfscript>
		<CFINCLUDE TEMPLATE="/commonspot/dlgcontrols/dlgcommon-head.cfm">
        	<cfset udfResults = Server.CommonSpot.UDF.UI.RenderSimpleForm(arguments.dataPageID, arguments.formID, APIPostToNewWindow, formResultHTML)>
		<cfoutput>
			<cfscript>
				// ADF Lightbox needs to be forced to load the browser-all.js into
				//	the lightbox window for CE's with RTE fields
				variables.scripts.loadADFLightbox(force=1);
			</cfscript>
			<!--- Call the UDF function --->
			<tr>
			<td>
				#udfResults#
				<cfif Len(arguments.callback)>
					#variables.scripts.loadJQuery()#
					<script type="text/javascript">
						//Setting this up so that on page load the cookie gets filled with existing values, if there are any
						jQuery(document).ready(function (){
							handleFormChange();
							jQuery("##proxyButton1").live('click',handleFormChange);
						});
						function handleFormChange(){
							// Get the PageWindow and store the form value
							var pageWindow = commonspot.lightbox.getPageWindow();
							pageWindow.ADFFormData = {
								formValueStore: getForm()
							};
						}

						//returns the form values as an object
						// Obj[fieldName] = fieldValue;
						function getForm(){
							var rtnStruct = new Object();
							var formFields = jQuery("input");
							formFields = formFields.filter(
								function(){
									return jQuery(this).attr("name").toLowerCase().indexOf("fieldname") != -1;
								}
							);
							formFields.each(function (){
								var name = jQuery(this).attr("name");
								//Case insensitive replace
								name = name.replace(/_fieldName/i,"");
								if( jQuery("[name='"+name+"']").attr("type") === "checkbox" && !jQuery("[name='"+name+"']:checked").length){
									rtnStruct[jQuery(this).attr("value")] = "";
								}else{
									rtnStruct[jQuery(this).attr("value")] = jQuery("[name='"+name+"']").attr("value");
								}
							});
							return rtnStruct;
						}
					</script>
				</cfif>
			</td>
			</tr>
		</cfoutput>
		<CFINCLUDE template="/commonspot/dlgcontrols/dlgcommon-foot.cfm">
	</cfsavecontent>
	<cfreturn rtnHTML>

</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$renderDeleteForm
Summary:
	Renders the standard datasheet delete module
Returns:
	Void
Arguments:
	Numeric formID
	Numeric dataPageID
	String title
History:
 	2009-10-25 - RLW - Created
	2010-02-18 - MFC - Returns a HTML for delete form.
	2010-04-14 - GAC - Updated to work with the ADFLightbox Framework
	2010-07-23 - SFS - Added argument to supply the lightbox dialog with a title needed for CS CE delete function.
	2010-10-29 - MFC - Updated the delete form for CS 6 Lightbox styles.
	2010-12-21 - MFC - Removed the JQuery version in the param.
--->
<cffunction name="renderDeleteForm" access="public" returntype="String" hint="Renders the standard datasheet delete module">
	<cfargument name="formID" type="numeric" required="true" hint="The FormID for the Custom Element">
	<cfargument name="dataPageID" type="numeric" required="true" hint="the DataPageID for the record being deleted">
	<cfargument name="title" type="string" required="no" default="Delete Record" hint="The title of the dialog displayed while deleting">
	<cfargument name="callback" type="string" required="false" default="" hint="The callback Javascript function that will be called on succesful deletion">

	<cfset var deleteFormHTML = "">
	<cfsavecontent variable="deleteFormHTML">
		<!--- Render the dlg header --->
		<cfscript>
			CD_DialogName = request.params.title;
			CD_Title=CD_DialogName;
			CD_IncludeTableTop=1;
			CD_CheckLock=0;
			CD_CheckLogin=1;
			CD_CheckPageAlive=0;
		</cfscript>
		<CFINCLUDE TEMPLATE="/commonspot/dlgcontrols/dlgcommon-head.cfm">
		<cfoutput><tr><td></cfoutput>
		<cfscript>
			variables.scripts.loadJquery(force=1);
			variables.scripts.loadADFLightbox(force=1);

			//targetModule = "#request.subsiteCache[1].url#datasheet-modules/delete-form-data.cfm";
			targetModule = "/ADF/extensions/datasheet-modules/delete_element_handler.cfm";
			request.params.pageID = arguments.dataPageID;
			request.params.formID = arguments.formID;
			if(Len(arguments.callback)){
				request.params.callback = arguments.callback;
			}
			CD_DIALOGNAME = arguments.title;
		</cfscript>
		<cfinclude template="/ADF/extensions/datasheet-modules/delete_element_handler.cfm">
		<!--- Render the dlg footer --->
		<cfoutput></tr></td></cfoutput>
		<CFINCLUDE template="/commonspot/dlgcontrols/dlgcommon-foot.cfm">
	</cfsavecontent>
	<cfreturn deleteFormHTML>
</cffunction>


<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$isFieldReadOnly
Summary:
	Given xparams determines if the field is readOnly
Returns:
	boolean
Arguments:

History:
 	Dec 6, 2010 - RAK - Created
--->
<cffunction name="isFieldReadOnly" access="public" returntype="boolean" hint="Given xparams determines if the field is readOnly">
	<cfargument name="xparams" type="struct" required="true" default="" hint="XParams struct">
	<cfscript>
		// Get the list permissions and compare
		var commonGroups = application.ADF.data.ListInCommon(request.user.grouplist, arguments.xparams.pedit);
		// Set the read only
		var readOnly = true;
		// Check if the user does have edit permissions
		if ( (arguments.xparams.UseSecurity EQ 0) OR ( (arguments.xparams.UseSecurity EQ 1) AND (ListLen(commonGroups)) ) )
			readOnly = false;
		return readOnly;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$wrapFieldHTML
Summary:
	Wraps the given information with valid html for the current commonspot and configuration
Returns:
	String
Arguments:

History:
 	Dec 6, 2010 - RAK - Created
--->
<cffunction name="wrapFieldHTML" access="public" returntype="String" hint="Wraps the given information with valid html for the current commonspot and configuration">
	<cfargument name="fieldInputHTML" type="string" required="true" default="" hint="HTML for the field input, do a cfSaveContent on the input field and pass that in here">
	<cfargument name="fieldQuery" type="query" required="true" default="" hint="fieldQuery value">
	<cfargument name="attr" type="struct" required="true" default="" hint="Attributes value">
	<cfargument name="includeLabel" type="boolean" required="false" default="true" hint="Set to false to remove the label on the left">
	<cfscript>
		var row = arguments.fieldQuery.currentRow;
		var fqFieldName = "fic_#arguments.fieldQuery.ID[row]#_#arguments.fieldQuery.INPUTID[row]#";
		var description = arguments.fieldQuery.DESCRIPTION[row];
		var fieldName = arguments.fieldQuery.fieldName[row];
		var xparams = arguments.attr.parameters[arguments.fieldQuery.inputID[row]];
		var labelStart = arguments.attr.itemBaselineParamStart;
		var labelEnd = arguments.attr.itemBaseLineParamEnd;
		var renderSimpleFormField = false;

		//If the fields are required change the label start and end
		if(xparams.req eq "Yes"){
			labelStart = arguments.attr.reqItemBaselineParamStart;
			labelEnd = arguments.attr.reqItemBaseLineParamEnd;
		}

		// determine if this is rendererd in a simple form or the standard custom element interface
		if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) ){
			renderSimpleFormField = true;
		}
	</cfscript>
	<cfsavecontent variable="returnHTML">
		<cfoutput>
			<tr>
				<cfif includeLabel>
					<td valign="top">
						#labelStart#
						<label for="#fqFieldName#">#xParams.label#:</label>
						#labelEnd#
					</td>
				</cfif>
				<td>
					#arguments.fieldInputHTML#
				</td>
			</tr>
			<cfif Len(description)>
				<!--- If there is a description print out a new row and the description --->
				<tr>
					<td></td>
					<td>
						#arguments.attr.descParamStart#
						#description#
						<br/><br/>
						#arguments.attr.descParamEnd#
					</td>
				</tr>
			</cfif>
			<cfif renderSimpleFormField>
				<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(fieldName, 'fic_','')#">
			</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfreturn returnHTML>
</cffunction>

<!---
/* ***************************************************************
/*
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
	2011-01-25 - MFC - Modified - Updated formBean param default value to "forms_1_1"
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
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$closeLBandRefresh
Summary:	
	Closes the current lightbox and refreshes the parent window
Returns:
	Void
Arguments:
	Void
History:
	2009-10-25 - RLW - Created
	2010-12-21 - MFC - Updated to use the ADF Lightbox Framework functions
--->
<cffunction name="closeLBAndRefresh" access="public" returntype="void" hint="">
	<cfoutput>
		<cfscript>
			variables.scripts.loadJquery(force=1);
			variables.scripts.loadADFLightbox(force=1);
		</cfscript>
		<script type='text/javascript'>
			jQuery(document).ready(function(){
				closeLBReloadParent();
			});
		</script>
	</cfoutput>
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$wrapHTMLWithLightbox
Summary:
	Given html returns html that is wrapped properly with the lightbox code.
Returns:
	string
Arguments:

History:
 	1/5/11 - RAK - Created
--->
<cffunction name="wrapHTMLWithLightbox" access="public" returntype="string" hint="Given html returns html that is wrapped properly with the lightbox code.">
	<cfargument name="html" type="string" required="true" default="" hint="HTML to wrap">
	<cfset var returnHTML = "">
	<cfsavecontent variable="returnHTML">
		<cfoutput>
			<cfscript>
				if(StructKeyExists( request.params,"title")){
					CD_DialogName = request.params.title;
				}else{
					 CD_DialogName = "";
				}
				CD_Title=CD_DialogName;
				CD_IncludeTableTop=1;
				CD_CheckLock=0;
				CD_CheckLogin=1;
				CD_CheckPageAlive=0;
			</cfscript>
			<CFINCLUDE TEMPLATE="/commonspot/dlgcontrols/dlgcommon-head.cfm">
				<tr>
					<td class="formResultContainer">
						#html#
					</td>
				</tr>
			<CFINCLUDE template="/commonspot/dlgcontrols/dlgcommon-foot.cfm">
		</cfoutput>
	</cfsavecontent>
	<cfreturn returnHTML>
</cffunction>

</cfcomponent>