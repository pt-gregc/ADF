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
	forms_1_1.cfc
Summary:
	Form functions for the ADF Library
Version:
	1.1
History:
	2009-09-28 - MFC - Created
	2010-12-20 - MFC - Updated Forms_1_1 for dependency to Scripts_1_1.
	2011-09-09 - GAC - Minor comment updates and formatting
	2013-11-18 - GAC - Updated the lib dependencies to scripts_1_2 and ceData_2_0
	2015-06-10 - ACW - Updated the component extends to no longer be dependant on the 'ADF' in the extends path
--->
<cfcomponent displayname="forms_1_1" extends="forms_1_0" hint="Form functions for the ADF Library">

<cfproperty name="version" value="1_1_9">
<cfproperty name="type" value="transient">
<cfproperty name="ceData" injectedBean="ceData_2_0" type="dependency">
<cfproperty name="scripts" injectedBean="scripts_1_2" type="dependency">
<cfproperty name="ui" injectedBean="ui_1_0" type="dependency">
<cfproperty name="fields" injectedBean="fields_1_0" type="dependency">
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
	2012-01-03 - MFC - Added check that the field has the name attribute.
	2012-02-03 - MFC - Updates to the lightbox callback to store the form in "top.commonspot".
	2013-02-06 - MFC - Removed JS 'alert' commands for CS 8.0.1 and CS 9 compatibility
	2015-09-10 - GAC - Removed jQuery.LIVE and replaced it with a jQuery.ON call since it has been deprected since 1.7 and no longer works with jQuery 2.x
	2015-10-09 - GAC - Added a workaround to fix for the ADF Lightbox form result javascript issues with the CommonSpot loadResource() 
--->
<cffunction name="renderAddEditForm" access="public" returntype="String" hint="Returns the HTML for an Add/Edit Custom element record">
	<cfargument name="formID" type="numeric" required="true" hint="Form ID to render">
	<cfargument name="dataPageId" type="numeric" required="true" hint="DatapageID to render the edit for">
	<cfargument name="lbAction" type="string" required="false" default="norefresh" hint="The action, either norefresh or refreshparent">
	<cfargument name="customizedFinalHtml" type="string" required="false" default="" hint="Allows you to pass in custom HTML that will display after submit">
	<cfargument name="callback" type="string" required="false" default="" hint="Optional callback code that will get called on submit">
	<cfargument name="behaveAsSimpleForm" type="Boolean" required="no" default="0" hint="Optional parameter to treat the form as simple form or not">
	
	<cfscript>
		var udfResults = '';
		var APIPostToNewWindow = false;
		var rtnHTML = "";
		var formResultHTML = "";
		// Find out if the CE contains an RTE field
		//var formContainRTE = application.ADF.ceData.containsFieldType(arguments.formID, "formatted_text_block");
	</cfscript>
	
	<!--- Result from the Form Submit --->
	<cfsavecontent variable="formResultHTML">
		<!--- Set the form result html to the argument if defined --->
		<cfoutput>
			<cfscript>
				// Load the scripts, check if we need to load the JSON scripts for the callback.
				variables.scripts.loadJQuery(force=1);
				variables.scripts.loadADFLightbox(force=1);
			</cfscript>
			<script type='text/javascript'>
				jQuery(document).ready(function(){
					lbResizeWindow();
					<cfif Len(arguments.callback)>
						// Get the PageWindow and the form value
						var pageWindow = top.commonspot.lightbox.getPageWindow();
						var value = pageWindow.ADFFormData.formValueStore;
						//console.log(value);
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
		<cfset udfResults = server.CommonSpot.UDF.UI.RenderSimpleForm(arguments.dataPageID, arguments.formID, APIPostToNewWindow, formResultHTML, arguments.behaveAsSimpleForm)>
		<cfoutput>
			<cfscript>
				// ADF Lightbox needs to be forced to load the browser-all.js into
				//	the lightbox window for CE's with RTE fields
				//variables.scripts.loadADFLightbox(force=1);
			</cfscript>
			<!--- Call the UDF function --->
			#udfResults#
			<cfif Len(arguments.callback)>
				#variables.scripts.loadJQuery()#
				<script type="text/javascript">
					//Setting this up so that on page load the cookie gets filled with existing values, if there are any
					jQuery(document).ready(function (){
						handleFormChange();
						jQuery(document).on("click","##proxyButton1",handleFormChange);
						//jQuery("##proxyButton1").live('click',handleFormChange);
					});
					
					function handleFormChange(){
						// Get the PageWindow and store the form value
						var pageWindow = top.commonspot.lightbox.getPageWindow();
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
								// Need to check that the field has a name attribute
								if ( jQuery(this).attr("name") )
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
	2014-03-05 - JTP - Var declarations
	2014-03-07 - GAC - Moved the scripts calls for jquery and ADFlightbox back into the return variable string
--->
<cffunction name="renderDeleteForm" access="public" returntype="String" hint="Renders the standard datasheet delete module" output="false">
	<cfargument name="formID" type="numeric" required="true" hint="The FormID for the Custom Element">
	<cfargument name="dataPageID" type="numeric" required="true" hint="the DataPageID for the record being deleted">
	<cfargument name="title" type="string" required="no" default="Delete Record" hint="The title of the dialog displayed while deleting">
	<cfargument name="callback" type="string" required="false" default="" hint="The callback Javascript function that will be called on succesful deletion">
	<cfargument name="cbIDlist" type="string" required="false" default="" hint="The list of IDs to pass to the call back function">
	
	<cfscript>
		var deleteFormHTML = '';
		// Overwrite the CommonSpot Variables (CD_DialogName, targetModule and realTargetModule)
		var CD_DialogName = arguments.title;
		var targetModule = "/ADF/extensions/datasheet-modules/delete_element_handler.cfm";
		var realTargetModule = "";
		
		// IF in CS6.1 or greater set the 'realTargetModule' CS Varaible from the targetModule
		if ( application.ADF.csVersion GTE 6.1 )
			realTargetModule = targetModule;

		// Set the request.params variables for pageID, formID, callback and cbIDlist
		request.params.pageID = arguments.dataPageID;
		request.params.formID = arguments.formID;
		
		if ( Len(arguments.callback) )
		{
			request.params.callback = arguments.callback;
			if ( Len(Trim(arguments.cbIDlist)) )
				request.params.cbIDlist = arguments.cbIDlist;
		}
	</cfscript>
	
	<cfsavecontent variable="deleteFormHTML">
		<cfscript>
			variables.scripts.loadJquery();
			variables.scripts.loadADFLightbox();
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
	2012-12-03 - GAC - Fixed the logic when checking the fieldPermission value for CS 6.0+ to only return ReadOnly when the fieldPermission value equals 1
	2013-12-05 - GAC - Added parameters for the CFTs fqFieldName and the attributes.currentValues struct
					 - Added the CS 9+ fqFieldName_doReadonly check to see if the field is forces to be read only
	2014-01-06 - GAC - Moved to the new Field_1_0 LIB
--->
<!--- // Moved to the Fields LIB for v1.6.2 --->
<cffunction name="isFieldReadOnly" access="public" returntype="boolean" hint="Given xparams determines if the field is readOnly">
	<cfargument name="xparams" type="struct" required="true" hint="the CFT xparams struct">
	<cfargument name="fieldPermission" type="string" required="false" default="" hint="fieldPermission attribute for CS 6.x and above: 0 (no rights), 1 (read only), 2 (edit)">
	<cfargument name="fqfieldName" type="string" required="false" default="" hint="the CFT's fqfieldName">
	<cfargument name="currentValues" type="struct" required="false" default="#StructNew()#" hint="the CFT attributes.currentValues struct">
	<cfscript>
		return variables.fields.isFieldReadOnly(xparams=arguments.xparams,fieldPermission=arguments.fieldPermission,fqfieldName=arguments.fqfieldName,currentValues=arguments.currentValues);
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
	2013-12-06 - GAC - Added nowrap="nowrap" to the Label table cell
					 - Added a TRIM to the label variable
	2014-01-06 - GAC - Added the labelClass variable the Field Label to specify optional or required class to the label tag
	2014-01-06 - GAC - Moved to the new Field_1_0 LIB
--->
<!--- // Moved to the Fields LIB for v1.6.2 --->
<cffunction name="wrapFieldHTML" access="public" returntype="String" hint="Wraps the given information with valid html for the current commonspot and configuration">
	<cfargument name="fieldInputHTML" type="string" required="true" default="" hint="HTML for the field input, do a cfSaveContent on the input field and pass that in here">
	<cfargument name="fieldQuery" type="query" required="true" default="" hint="fieldQuery value">
	<cfargument name="attr" type="struct" required="true" default="" hint="Attributes value">
	<cfargument name="fieldPermission" type="string" required="false" default="" hint="fieldPermission attribute for CS 6.x and above: 0 (no rights), 1 (read only), 2 (edit)">
	<cfargument name="includeLabel" type="boolean" required="false" default="true" hint="Set to false to remove the label on the left">
	<cfargument name="includeDescription" type="boolean" required="false" default="true" hint="Set to false to remove the description under the field">
	<cfscript>
		return variables.fields.wrapFieldHTML(fieldInputHTML=arguments.fieldInputHTML,fieldQuery=arguments.fieldQuery,attr=arguments.attr,fieldPermission=arguments.fieldPermission,includeLabel=arguments.includeLabel,includeDescription=arguments.includeDescription);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$renderDataValueStringfromFieldMask
Summary:
	Returns the string of data values from field mask. 
	Used with the Custom Element Field Select CFT
Returns:
	string
Arguments:
	Struct - fieldDataStruct
	string - fieldMaskStr
History:
 	2010-12-06 - RAK - Created
	2013-11-14 - DJM - Pulled out from the Custom Element Select Field render file and converted to its own method
	2013-11-14 - GAC - Moved from the Custom Element Select Field to the Forms_1_1 lib
	2013-12-18 - GAC - Moved to the fields_1_0 lib
--->
<!--- // Moved to the Fields LIB for v1.6.2 --->
<cffunction name="renderDataValueStringfromFieldMask" hint="Returns the string of data values from field mask" access="public" returntype="string">
	<cfargument name="fieldDataStruct" type="struct" required="true" hint="Struct with the field key/value pair">
	<cfargument name="fieldMaskStr" type="string" required="true" hint="String mask of <fieldNames> used build the field value display">
	<cfscript>
		return variables.fields.renderDataValueStringfromFieldMask(fieldDataStruct=arguments.fieldDataStruct,fieldMaskStr=arguments.fieldMaskStr);
	</cfscript>
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
			if  (Arraylen(thisFormEntry)) 
			{
				thisPageId = thisFormEntry[1].pageID;
			}
			// delete the spam record from the element.
			if (len(thisPageID)) 
			{
				application.ADF.ceData.deleteCE(thisPageID);
			}
			isValid = false;
		</cfscript>
	</cfif>
	<cfreturn isValid>
</cffunction>

</cfcomponent>