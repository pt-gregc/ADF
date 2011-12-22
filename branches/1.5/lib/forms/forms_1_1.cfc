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
	2010-12-20 - MFC - Updated Forms_1_1 for dependency to Scripts_1_1.
	2011-09-09 - GAC - Minor comment updates and formatting
--->
<cfcomponent displayname="forms_1_1" extends="ADF.lib.forms.forms_1_0" hint="Form functions for the ADF Library">

<cfproperty name="version" value="1_1_0">
<cfproperty name="type" value="transient">
<cfproperty name="ceData" injectedBean="ceData_1_1" type="dependency">
<cfproperty name="scripts" injectedBean="scripts_1_1" type="dependency">
<cfproperty name="ui" injectedBean="ui_1_0" type="dependency">
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
						Scripts_1_1.
	2010-12-20 - RAK - Fixed a bunch of issues related to forms 1_1 callbacks not working properly.
	2010-12-21 - MFC - Added force params to loading scripts in the formResultHTML content block.
						Updated the form result to use the customizedFinalHtml argument or the default.
						Removed the renderResult param and IF blocks.
	2010-12-27 - MFC/RAK - Updated the form storage for the callback into the Document pageWindow space.
							Removed the form data storage in the cookie.
	2011-01-13 - MFC - Updated the form result LB Action params.
	2011-01-24 - RAK - Updated the code to handle callbacks pointing at checkboxes returning values only when checked
	2011-02-08 - MFC - Removed the lightbox dialog header and footer.
						The dialog header/footer code has been moved in the lightbox proxy.
	2011-02-09 - RAK - Var'ing un-var'd variables
	2011-03-26 - MFC - Commented out force JQuery, the loadADFLightbox with force will load JQuery.
						Removed the loadADFLightbox force argument when loading the form.
--->
<cffunction name="renderAddEditForm" access="public" returntype="String" hint="Returns the HTML for an Add/Edit Custom element record">
	<cfargument name="formID" type="numeric" required="true" hint="Form ID to render">
	<cfargument name="dataPageId" type="numeric" required="true" hint="DatapageID to render the edit for">
	<cfargument name="lbAction" type="string" required="false" default="norefresh" hint="The action, either norefresh or refreshparent">
	<cfargument name="customizedFinalHtml" type="string" required="false" default="" hint="Allows you to pass in custom HTML that will display after submit">
	<cfargument name="callback" type="string" required="false" default="" hint="Optional callback code that will get called on submit">

	<cfscript>
		var udfResults = '';
		var APIPostToNewWindow = false;
		var rtnHTML = "";
		var formResultHTML = "";
		// Find out if the CE contains an RTE field
		var formContainRTE = application.ADF.ceData.containsFieldType(arguments.formID, "formatted_text_block");
	</cfscript>
	<!--- Result from the Form Submit --->
	<cfsavecontent variable="formResultHTML">
		<!--- Set the form result html to the argument if defined --->
		<cfoutput>
			<cfscript>
				// Load the scripts, check if we need to load
				//	the JSON scripts for the callback.
				// 2011-03-26 - MFC - Commented out force JQuery, the loadADFLightbox with force will
				//						load JQuery.
				//variables.scripts.loadJQuery(force=1);
				variables.scripts.loadADFLightbox(force=1);
			</cfscript>
			<script type='text/javascript'>
				jQuery(document).ready(function(){
					lbResizeWindow();
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
				<cfif arguments.lbAction EQ "refreshparent" and LEN(arguments.callback) eq 0>
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
	</cfsavecontent>

	<!--- HTML for the form --->
	<cfsavecontent variable="rtnHTML">
		<cfset udfResults = Server.CommonSpot.UDF.UI.RenderSimpleForm(arguments.dataPageID, arguments.formID, APIPostToNewWindow, formResultHTML)>
		<cfoutput>
			<cfscript>
				// ADF Lightbox needs to be forced to load the browser-all.js into
				//	the lightbox window for CE's with RTE fields
				variables.scripts.loadADFLightbox();
			</cfscript>
			<!--- Call the UDF function --->
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
		</cfoutput>
	</cfsavecontent>
	<cfreturn rtnHTML>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc. 	
	Ron West
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
	2011-01-20 - GAC - Updated the conflicting title code was attempting to set the Lightbox DialogName
	2011-03-26 - MFC - Removed the lightbox header and footer from rendering.  The Lightbox proxy 
						now renders the header and footer.
	2011-04-07 - MFC - Added 'realTargetModule' variable for when deleting in CS6.1 and Greater.
	2011-06-22 - GAC - Added a callback ID list parameter to include IDs of records to be modified by the callback other than the one being deleted 
--->
<cffunction name="renderDeleteForm" access="public" returntype="String" hint="Renders the standard datasheet delete module">
	<cfargument name="formID" type="numeric" required="true" hint="The FormID for the Custom Element">
	<cfargument name="dataPageID" type="numeric" required="true" hint="the DataPageID for the record being deleted">
	<cfargument name="title" type="string" required="no" default="Delete Record" hint="The title of the dialog displayed while deleting">
	<cfargument name="callback" type="string" required="false" default="" hint="The callback Javascript function that will be called on succesful deletion">
	<cfargument name="cbIDlist" type="string" required="false" default="" hint="The list of IDs to pass to the call back function">
	<cfset var deleteFormHTML = "">
	<!--- Check if the user is logged In --->
	<cfsavecontent variable="deleteFormHTML">
		<cfscript>
			variables.scripts.loadJquery();
			variables.scripts.loadADFLightbox();

			targetModule = "/ADF/extensions/datasheet-modules/delete_element_handler.cfm";
			
			// IF in CS6.1 or greater set into 'RealTargetModule' variable
			if ( application.ADF.csVersion GTE 6.1 )
				realTargetModule = targetModule;
			
			request.params.pageID = arguments.dataPageID;
			request.params.formID = arguments.formID;
			if(Len(arguments.callback))
			{
				request.params.callback = arguments.callback;
				if(Len(Trim(arguments.cbIDlist)))
					request.params.cbIDlist = arguments.cbIDlist;
			}
			CD_DIALOGNAME = arguments.title;
		</cfscript>
		<cfinclude template="/ADF/extensions/datasheet-modules/delete_element_handler.cfm">
	</cfsavecontent>
	<cfreturn deleteFormHTML>
</cffunction>

<!---
/* *************************************************************** */
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
	Struct - xparams
	String - fieldPermission
History:
	2010-12-06 - RAK - Created
	2011-11-22 - GAC - Added a fieldPermission argument and logic to handle 6.x field security
--->
<cffunction name="isFieldReadOnly" access="public" returntype="boolean" hint="Given xparams determines if the field is readOnly">
	<cfargument name="xparams" type="struct" required="true" default="" hint="XParams struct">
	<cfargument name="fieldPermission" type="string" required="false" default="" hint="fieldPermission attribute for CS 6.x and above: 0 (no rights), 1 (read only), 2 (edit)">
	<cfscript>
		var readOnly = true;
		var productVersion = ListFirst(ListLast(request.cp.productversion," "),".");
		var commonGroups = "";
		// Determine if this field should be read only due to "Use Explicit Security"
		// Check the CS version
		if ( productVersion GTE 6 )
		{
			// For CS 6.x and above
			// - If the user has ready only rights (fieldPermission = 1) readOnly will be true
			if ( LEN(TRIM(arguments.fieldPermission)) OR arguments.fieldPermission NEQ 1 ) 
				readOnly = false;				
		}
		else
		{
			// For CS 5.x 
			// Get the list permissions and compare
			commonGroups = application.ADF.data.ListInCommon(request.user.grouplist, arguments.xparams.pedit);
			// Check if the user does have edit permissions
			if ( (arguments.xparams.UseSecurity EQ 0) OR ( (arguments.xparams.UseSecurity EQ 1) AND (ListLen(commonGroups)) ) )
				readOnly = false;	
		}
		return readOnly;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
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
	String - fieldInputHTML
	Query - fieldQuery
	Struct - attr
	String - fieldPermission
	Boolean - includeLabel
	Boolean - includeDescription
History:
 	2010-12-06 - RAK - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
	2011-09-09 - GAC - Added doHiddenFieldSecurity to convert field to a hidden field if "Use Explicit Security" and user is not part of an Edit or View group
	2011-11-07 - GAC - Addressed table formatting issues with the includeLabel argument 
					 - Added an includeDescription argument to allow the description to be turned off
	2011-11-22 - GAC - Added a fieldPermission argument and logic to handle 6.x field security
--->
<cffunction name="wrapFieldHTML" access="public" returntype="String" hint="Wraps the given information with valid html for the current commonspot and configuration">
	<cfargument name="fieldInputHTML" type="string" required="true" default="" hint="HTML for the field input, do a cfSaveContent on the input field and pass that in here">
	<cfargument name="fieldQuery" type="query" required="true" default="" hint="fieldQuery value">
	<cfargument name="attr" type="struct" required="true" default="" hint="Attributes value">
	<cfargument name="fieldPermission" type="string" required="false" default="" hint="fieldPermission attribute for CS 6.x and above: 0 (no rights), 1 (read only), 2 (edit)">
	<cfargument name="includeLabel" type="boolean" required="false" default="true" hint="Set to false to remove the label on the left">
	<cfargument name="includeDescription" type="boolean" required="false" default="true" hint="Set to false to remove the description under the field">
	<cfscript>
		var returnHTML = '';
		var productVersion = ListFirst(ListLast(request.cp.productversion," "),".");
		var row = arguments.fieldQuery.currentRow;
		var fqFieldName = "fic_#arguments.fieldQuery.ID[row]#_#arguments.fieldQuery.INPUTID[row]#";
		var description = arguments.fieldQuery.DESCRIPTION[row];
		var fieldName = arguments.fieldQuery.fieldName[row];
		var xparams = arguments.attr.parameters[arguments.fieldQuery.inputID[row]];
		var currentValue = arguments.attr.currentValues[fqFieldName];
		var labelStart = arguments.attr.itemBaselineParamStart;
		var labelEnd = arguments.attr.itemBaseLineParamEnd;
		var renderMode =  arguments.attr.rendermode;
		var renderSimpleFormField = false;
		var doHiddenFieldSecurity = false; // No Edit / No Readonly ... just a hidden field
		var editGroups = "";
		var viewGroups = "";
		
		//If the fields are required change the label start and end
		if ( xparams.req eq "Yes" )
		{
			labelStart = arguments.attr.reqItemBaselineParamStart;
			labelEnd = arguments.attr.reqItemBaseLineParamEnd;
		}

		// Determine if this is rendererd in a simple form or the standard custom element interface
		if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) )
		{
			renderSimpleFormField = true;
		}
		
		// Determine if this field should be hidden due to "Use Explicit Security"
		// - Check the CS version
		if ( productVersion GTE 6 )
		{
			// For CS 6.x and above
			// - If the user has no rights (fieldSecurity = 0) to the field then doHiddenSecurity should be true
			if ( LEN(TRIM(arguments.fieldPermission)) AND arguments.fieldPermission LTE 0 ) 
			{
				doHiddenFieldSecurity = true;		
			}	
			
			// TODO: determine if this conditional logic is needed to display the description or not (fieldPermission is new to CS6.x)
			//if ( renderMode NEQ 'standard' OR fieldpermission LTE 0 )
				//arguments.includeDescription = false;
		}
		else
		{
			// For CS 5.x 
			// Get the list permissions and compare for security
			editGroups = application.ADF.data.ListInCommon(request.user.grouplist, xparams.pedit);
			viewGroups = application.ADF.data.ListInCommon(request.user.grouplist, xparams.pread);
			// - If user is part for the edit or view groups doHiddenSecurity should remain false
			if ( xparams.UseSecurity AND ListLen(viewGroups) EQ 0 AND ListLen(editGroups) EQ 0 )
			{
				doHiddenFieldSecurity = true;
			}
		}
	</cfscript>
	<cfsavecontent variable="returnHTML">
		<cfoutput>
			<cfif NOT doHiddenFieldSecurity>
				<tr id="#fqFieldName#_FIELD_ROW">
					<cfif arguments.includeLabel>
						<td valign="top">
							#labelStart#
							<label for="#fqFieldName#" id="#fqFieldName#_LABEL">#xParams.label#:</label>
							#labelEnd#
						</td>
					</cfif>
					<td<cfif NOT arguments.includeLabel> colspan="2"</cfif>>
						#arguments.fieldInputHTML#
					</td>
				</tr>
				<cfif Len(description) AND arguments.includeDescription>
					<!--- // If there is a description print out a new row and the description --->
					<tr id="#fqFieldName#_DESCRIPTION_ROW">
						<cfif arguments.includeLabel>
						<td></td>
						</cfif>
						<td<cfif NOT arguments.includeLabel> colspan="2"</cfif>>
							#arguments.attr.descParamStart#
							#description#
							<br/><br/>
							#arguments.attr.descParamEnd#
						</td>
					</tr>
				</cfif>
			<cfelse>
				<input type="hidden" name="#fqFieldName#" id="#fqFieldName#" value="#currentValue#">
			</cfif>
			<cfif renderSimpleFormField>
				<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(fieldName, 'fic_','')#">
			</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfreturn returnHTML>
</cffunction>

<!---
/* *************************************************************** */
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
	string - HTML
	string - tdClass
History:
 	2011-05-11 - RAK - Created
	2011-01-20 - GAC - Moved a updated version to the UI lib and added the parameter for
						tdClass so CSS classes can be added to the inner TD of the lightBox header
--->
<cffunction name="wrapHTMLWithLightbox" access="public" returntype="string" hint="Given html returns html that is wrapped properly with the lightbox code.">
	<cfargument name="html" type="string" required="true" default="" hint="HTML to wrap">
	<cfargument name="tdClass" type="string" default="formResultContainer" hint="Used to add CSS classes to the TD wrapper around the provied HTML. Default: formResultContainer">
	<cfset var returnHTML = "">
	<cfsavecontent variable="returnHTML">
		<cfoutput>
			#variables.ui.wrapHTMLwithLBHeaderFooter(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>
	<cfreturn returnHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Dave Beckstrom
Name:
	$loadCFFormProtect
Summary:
	Creates the cffp CFFormProtect object
Returns:
	Any
Arguments:
	None
History:
	2011-01-07 - DMB - Created
	2011-02-02 - RAK - Cleaned up return parameters.
--->
<cffunction name="loadCFFormProtect" access="public" returntype="any" hint="Loads CFFormProtect">
	<cfscript>
	 	return CreateObject("component","ADF.thirdParty.cfformprotect.cffpVerify2").init();
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	Dave Beckstrom
Name:
	$verifyCFFormProtect
Summary:
	Verifies the form and deletes the element if it is invalid
Returns:
	boolean
Arguments:
	formStruct - struct- Structure of form fields
	elementName - string- Name of the element to search for
	primaryKey - string- Primary key to search for in the element
History:
	2011-01-13 - DMB - Created
	1011-02-02 - RAK - Changed parameters so it can work for any element.
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="verifyCFFormProtect" access="public" returntype="boolean" hint="Verifies the form and deletes the element if it is invalid">
	<cfargument name="formStruct" type="struct" required="true" default="" hint="Structure of form fields">
	<cfargument name="elementName" type="string" required="true" default="" hint="Name of the element to search for">
	<cfargument name="primaryKey" type="string" required="false" default="id" hint="Primary key to search for in the element">
	<cfscript>
		var key = '';
		// load cfformprotect
		var cffp = application.ADF.forms.loadCFFormProtect();
		var form = StructNew();
		var thisFormEntry = StructNew();
		var thisPageId = "";
		var isValid = true;
		// application.ADF.utils.doDump(formStruct,"formStruct", false);
	</cfscript>

	<cfloop list="#structKeyList(arguments.formStruct)#" index="key">
		<cfset "form.#key#" = "#arguments.formStruct[key]#">
	</cfloop>

	<cfif !cffp.testSubmission(form)>
		<!--- // this was spam --->
		<cfscript>
			// get the UUID of the element data just submitted by the simple form
			thisFormEntry  = application.ADF.ceData.getCEData(arguments.elementName,arguments.primaryKey, form[arguments.primaryKey]);
			// using the UUID, get the PageId (primary key) of the record just submitted
			if  (Arraylen(thisFormEntry)) {
				thisPageId = thisFormEntry[1].pageID;
			}
			// delete the spam record from the element.
			if (len(thisPageID)) {
				application.ADF.ceData.deleteCE(thisPageID);
			}
			isValid = false;
		</cfscript>
	</cfif>
	<cfreturn isValid>
</cffunction>

</cfcomponent>