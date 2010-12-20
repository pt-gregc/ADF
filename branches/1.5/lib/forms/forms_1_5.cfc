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
	2010-12-20 - MFC - Updated Forms_1_5 for dependency to Scripts_1_5.
--->
<cfcomponent displayname="forms_1_5" extends="ADF.lib.forms.forms_1_0" hint="Form functions for the ADF Library">

<cfproperty name="version" value="1_5_0">
<cfproperty name="type" value="transient">
<cfproperty name="ceData" injectedBean="ceData_1_0" type="dependency">
<cfproperty name="scripts" injectedBean="scripts_1_5" type="dependency">
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
	2010-11-28 - RAK - Updated to have callback functionality
	2010-12-09 - RAK - Updated callback functionality to return an object containing all the form parameters
	2010-12-17 - MFC - Updated to force the load ADF Lightbox scripts for CE's with RTE fields.
						Moved the call to the UDF to output directly.
						Removed commented and unneeded code in the dlg header variables.
	2010-12-20 - MFC - Undo the param to force load ADF Lightbox scripts and the UDF to load 
						into a variable.  These work now that Forms has the dependency for 
						Scripts_1_5.
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
		<cfoutput><tr><td></cfoutput>
		<!--- Set the form result html to the argument if defined --->
		<cfif LEN(arguments.customizedFinalHtml)>
			<cfoutput>#arguments.customizedFinalHtml#</cfoutput>
		<cfelse>
			<cfoutput>
				<cfscript>
					variables.scripts.loadADFLightbox(force=1);
				</cfscript>
				<cfif Len(arguments.callback)>
					#application.ADF.scripts.loadJQuery()#
					#application.ADF.scripts.loadJQueryCookie()#
					#application.ADF.scripts.loadJQueryJSON()#
				</cfif>
				<script type='text/javascript'>
					jQuery(document).ready(function(){
						<cfif Len(arguments.callback)>
							//We need to get the cookie information, stored in a cookie because
							// this page is only JS and we cant get the form varaibles!
							cookieValue = jQuery.evalJSON(jQuery.cookie("tempFormCookie"));
							//Call the callback with the cookie value
							getCallback('#arguments.callback#', cookieValue);
							//Delete the cookie
							jQuery.cookie("tempFormCookie",null,{path:"/"});
						<cfelse>
							if ( "#arguments.lbAction#" == "refreshparent" )
								closeLBReloadParent();
							closeLB();
						</cfif>
					});
				</script>
			</cfoutput>
		</cfif>
		<!--- Render the dlg footer --->
		<cfoutput></tr></td></cfoutput>
		<CFINCLUDE template="/commonspot/dlgcontrols/dlgcommon-foot.cfm">
	</cfsavecontent>
	
	<cfif NOT renderResult>
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
        	<cfscript>
				// Load ADF Lightbox Framework
				variables.scripts.loadADFLightbox();
				
				// Load the UDF form
				udfLoadForm = Server.CommonSpot.UDF.UI.RenderSimpleForm(arguments.dataPageID, arguments.formID, APIPostToNewWindow, formResultHTML);
			</cfscript>
			<cfoutput>
				<!--- Call the UDF function --->
				<tr><td>
				#udfLoadForm#
				</td></tr>
				<cfif Len(arguments.callback)>
					#application.ADF.scripts.loadJQuery()#
					#application.ADF.scripts.loadJQueryCookie()#
					#application.ADF.scripts.loadJQueryJSON()#
					<script type="text/javascript">
						//Onchange because we don't have a finalize function that we can have called.
						//Stored in a cookie because the receiving page is only JS and cannot get form params
						jQuery("form").change(function(){
							var formEncoded = jQuery.toJSON(getForm());
							jQuery.cookie("tempFormCookie",formEncoded,{path:"/"});
						});

						//returns the form values as an object
						// Obj[fieldName] = fieldValue;
						function getForm(){
							var rtnStruct = new Object();
							jQuery("[name$='fieldName']").each(function (){
								var name = jQuery(this).attr("name");
								name = name.replace("_fieldName","");
								rtnStruct[jQuery(this).attr("value")] = jQuery("[name='"+name+"']").attr("value");
							});
							return rtnStruct;
						}
					</script>
				</cfif>
			</cfoutput>
			<CFINCLUDE template="/commonspot/dlgcontrols/dlgcommon-foot.cfm">
		</cfsavecontent>
	<cfelse>
		<cfset rtnHTML = formResultHTML>
	</cfif>
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
--->
<cffunction name="renderDeleteForm" access="public" returntype="String" hint="Renders the standard datasheet delete module">
	<cfargument name="formID" type="numeric" required="true" hint="The FormID for the Custom Element">
	<cfargument name="dataPageID" type="numeric" required="true" hint="the DataPageID for the record being deleted">
	<cfargument name="title" type="string" required="no" default="Delete Record" hint="The title of the dialog displayed while deleting">
	
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
			variables.scripts.loadJquery('1.3.2', 1);
			variables.scripts.loadADFLightbox(force=1);
			
			//targetModule = "#request.subsiteCache[1].url#datasheet-modules/delete-form-data.cfm";
			targetModule = "/ADF/extensions/datasheet-modules/delete_element_handler.cfm";
			request.params.pageID = arguments.dataPageID;
			request.params.formID = arguments.formID;
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
				<td valign="top">
					#labelStart#
					<label for="#fqFieldName#">#xParams.label#:</label>
					#labelEnd#
				</td>
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
Author: 	Ron West
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
History:
  	2010-09-30 - RLW - Created
 	2010-10-18 - GAC - Modified - Added a RefreshParent parameter
   	2010-10-18 - GAC - Modified - Added a urlParams parameter
	2010-10-18 - GAC - Modified - Added bean and method parameters
--->
<cffunction name="buildAddEditLink" access="public" returntype="string" output="false">
	<cfargument name="linkTitle" type="string" required="true">
	<cfargument name="formName" type="string" required="true">
	<cfargument name="dataPageID" type="numeric" required="false" default="0">
	<cfargument name="refreshparent" type="boolean" required="false" default="false"> 
	<cfargument name="urlParams" type="string" required="false" default=""> 
	<cfargument name="formBean" type="string" required="false" default="forms_1_5">
	<cfargument name="formMethod" type="string" required="false" default="renderAddEditForm">
	<cfargument name="lbTitle" type="string" required="false" default="#arguments.linkTitle#">  
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
		<cfoutput><a href="javascript:;" rel="#application.ADF.ajaxProxy#?bean=#arguments.formBean#&method=#arguments.formMethod#&formID=#formID#&dataPageID=#arguments.dataPageID#&lbAction=#lbAction#&title=#arguments.lbTitle##uParams#" class="ADFLightbox" title="#arguments.linkTitle#">#arguments.linkTitle#</a></cfoutput>
	</cfsavecontent>
	<cfreturn rtnStr>
</cffunction>

</cfcomponent>