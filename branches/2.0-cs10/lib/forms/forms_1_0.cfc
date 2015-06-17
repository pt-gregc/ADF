<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
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
	forms_1_0.cfc
Summary:
	Form functions for the ADF Library
Version:
	1.0
History:
	2009-06-22 - MFC - Created
	2015-06-11 - GAC - Updated the component extends to use the libraryBase path
--->
<cfcomponent displayname="forms_1_0" extends="ADF.lib.libraryBase" hint="Form functions for the ADF Library">

<cfproperty name="version" value="1_0_4">
<cfproperty name="type" value="transient">
<cfproperty name="ceData" injectedBean="ceData_1_0" type="dependency">
<cfproperty name="scripts" injectedBean="scripts_1_0" type="dependency">
<cfproperty name="wikiTitle" value="Forms_1_0">

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$addToSimpleForm
Summary:
	Adds content into the Simple Form structure before it is submitted
	Using a structure it would look like fieldData["FieldName"] = fieldValue;

	NOTE: assumes that the simple form data is in the "form" scope
Returns:
	Void
Arguments:
	Struct fieldData
History:
	2009-03-13 - RLW - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="addToSimpleForm" access="public" returntype="void">
	<cfargument name="fieldData" type="struct" required="true">
	<cfscript>
		var tmpArray = '';
		var labelFieldName = '';
		var actualFieldName = '';
		var itm = 1;
		var fieldList = structKeyList(arguments.fieldData);
		// loop through the form fields and find any that match the structure keys
		for( itm; itm lte listLen(fieldList); itm=itm+1 )
		{
			// get field
			thisField = listGetAt(fieldList, itm);
			// search for this fields label form field
			tmpArray = structFindValue(form, thisField);
			if( arrayLen(tmpArray) )
			{
				labelFieldName = tmpArray[1].key;
				// get the fieldName for the actual field - remember this is just the label
				actualFieldName = listDeleteAt(labelFieldName, listLen(labelFieldName, "_"), "_");
				if( structKeyExists(form, actualFieldName) )
				{
					// update this field with the data passed in
					form[actualFieldName] = arguments.fieldData[thisField];
				}
			}
		}
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$extractFromSimpleForm
Summary:
	Extracts fields from the simple form element
Returns:
	Struct fieldValues
Arguments:
	Struct form
	String fieldList
History:
	2009-02-09 - RLW - Created
	2009-07-02 - MFC - Updated:	Fieldlist argument is not required.
								If fieldlist is blank, then return all the fields in the element.
	2009-07-07 - MFC - Updated:	Set the call to CEDATA defaultFieldStruct to set to rtnStruct variable,
									this will default all the CE fields into the return struct.
	2009-07-31 - MFC - Updated: Updated the 'Replace' to 'ReplaceNoCase'.
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="extractFromSimpleForm" access="public" returntype="Struct">
	<cfargument name="formStruct" type="struct" required="true">
	<cfargument name="fieldList" type="String" required="false" default="">
	<cfscript>
		var formKeyList = '';
		var fieldValue = '';
		var rtnStruct = structNew();
		var itm = 1;
		var thisField = "";
		var tmpArray = arrayNew(1);
		var labelFieldName = "";
		var actualFieldName = "";
		
		// Check if the field list is empty, then get all the fields in the element form
		if ( (ListLen(arguments.fieldList) LTE 0) AND ( LEN(arguments.formStruct.formName) GT 0) ) {
			// Call CEData to get the fields for the element
			rtnStruct = variables.ceData.defaultFieldStruct(arguments.formStruct.formName);
			// Load the fieldList to all the elements fields
			arguments.fieldList = StructKeyList(rtnStruct);
		}
		formKeyList = StructKeyList(arguments.formStruct);
	
		// loop through the fields to find their values
		for( itm; itm lte listLen(formKeyList); itm=itm+1 )
		{
			// get field
			thisField = listGetAt(formKeyList, itm);
			
			// Check if we are on a field name
			if ( (UCASE(ListFirst(thisField,"_")) EQ "FIC") AND (UCASE(ListLast(thisField, "_")) EQ "FIELDNAME") )
			{
				actualFieldName = ReplaceNoCase(thisField, "_FIELDNAME", "", "all");
				fieldValue = arguments.formStruct[thisField];
				// Check if the value that is the field name in the fieldlist
				if ( ListFindNoCase(arguments.fieldList,fieldValue) )
				{
					// Check if the field is in the form, else set to empty string
					if ( StructKeyExists(arguments.formStruct, actualFieldName) )
						rtnStruct[fieldValue] = arguments.formStruct[actualFieldName];
					else
						rtnStruct[fieldValue] = "";
				}
			}
		}	
	</cfscript>
	<cfreturn rtnStruct>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
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
	2010-11-17 - MFC - Updated the JS close LB action script.
						Updated script command to load ADF Lightbox.
						Added logic to use the customizedFinalHtml argument if defined.
--->
<cffunction name="renderAddEditForm" access="public" returntype="String" hint="Returns the HTML for an Add/Edit Custom element record">
	<cfargument name="formID" type="numeric" required="true">
	<cfargument name="dataPageId" type="numeric" required="true">
	<cfargument name="lbAction" type="string" required="false" default="norefresh">
	<cfargument name="customizedFinalHtml" type="string" required="false" default="">
	<cfargument name="renderResult" type="boolean" required="false" default="0">
	
	<cfscript>
		var APIPostToNewWindow = false;
		var rtnHTML = "";
		var formResultHTML = "";
		// Find out if the CE contains an RTE field
		var formContainRTE = application.ADF.ceData.containsFieldType(arguments.formID, "formatted_text_block");
	</cfscript>
	
	<!--- Result from the Form Submit --->
	<cfsavecontent variable="formResultHTML">
		<!--- Set the form result html to the argument if defined --->
		<cfif LEN(arguments.customizedFinalHtml)>
			<cfoutput>#arguments.customizedFinalHtml#</cfoutput>
		<cfelse>
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
		</cfif>
	</cfsavecontent>
	
	<cfif NOT renderResult>
		<!--- Check the CS build is 5 or less AND we have an RTE field --->
		<cfif (ListLast(request.cp.productversion," ") LT 6)  AND formContainRTE>
			<!--- Set the form result HTML --->
			<cfsavecontent variable="formResultHTML">
				<cfoutput>
				<cfscript>
					variables.scripts.loadJquery('1.3.2', 1);
				</cfscript>
				<!--- Close the lightbox on click --->
				<script type='text/javascript'>
					window.opener.location.href = window.opener.location.href + "&renderResult=true";
					// Close the window
					if (jQuery.browser.msie){
						window.open('','_self','');
	           			window.close();
				    }else{
				    	window.close();
				    } 
				</script>
				</cfoutput>
			</cfsavecontent>
		</cfif>
		<!--- HTML for the form --->
		<cfsavecontent variable="rtnHTML">
			<cfoutput>
				<cfscript>
					variables.scripts.loadADFLightbox(force=1);
				</cfscript>
				<!--- Call the UDF function --->
				#server.CommonSpot.UDF.UI.RenderSimpleForm(arguments.dataPageID, arguments.formID, APIPostToNewWindow, formResultHTML)#
			</cfoutput>
		</cfsavecontent>
	<cfelse>
		<cfset rtnHTML = formResultHTML>
	</cfif>
	<cfreturn rtnHTML>
	
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$getCEFieldNameData
Summary:
	Returns structure of the simple form field names for the CE fields.
Returns:
	Struct
Arguments:
	String - ceName - Custom element name
History:
	2009-08-27 - MFC - Created
--->
<cffunction name="getCEFieldNameData" access="public" returntype="struct" hint="Returns structure of the simple form field names for the CE fields.">
	<cfargument name="ceName" type="string" required="true" hint="Custom element name">
	
	<cfscript>
		var fieldDataStruct = StructNew();
		var formid = variables.ceData.getFormIDByCEName(arguments.ceName);
		var elementFields = variables.ceData.getElementFieldsByFormID(formid);
		var i = 1;
		var currKey = "";
		var currFieldID = "";
		var currFieldName = "";
		var currFormFieldName = "";

		// Loop over the element fields
		for ( i = 1; i LTE elementFields.RecordCount; i = i + 1)
		{
			// Build the field data
			currFieldID = elementFields.fieldID[i];
			currFieldName = ReplaceNoCase(elementFields.fieldName[i], "FIC_", "");
			currFormFieldName = "fic_" & formid & "_" & currFieldID;
			// Insert into the fieldDataStruct
			StructInsert(fieldDataStruct, currFieldName, currFormFieldName, true);
		}	
	</cfscript>
	<cfreturn fieldDataStruct>
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
	2014-03-05 - JTP - Var declarations
	2014-03-07 - GAC - Moved the scripts calls for jquery and ADFlightbox back into the return variable string
					 - Removed the hardcoded jquery version
--->
<cffunction name="renderDeleteForm" access="public" returntype="String" hint="Renders the standard datasheet delete module" output="false">
	<cfargument name="formID" type="numeric" required="true" hint="The FormID for the Custom Element">
	<cfargument name="dataPageID" type="numeric" required="true" hint="the DataPageID for the record being deleted">
	<cfargument name="title" type="string" required="no" default="Delete Record" hint="The title of the dialog displayed while deleting">
	
	<cfscript>
		var deleteFormHTML = "";
		// Overwrite the CommonSpot Variables (CD_DialogName and targetModule)
		var CD_DialogName = arguments.title;
		// Use the ADF's delete_element_handler.cfm instead of the CommonSpot standard delete ds module
		var targetModule = "/ADF/extensions/datasheet-modules/delete_element_handler.cfm";
		// var targetModule = "#request.subsiteCache[1].url#datasheet-modules/delete-form-data.cfm";

		// Set the request.params variables for pageID and formID
		request.params.pageID = arguments.dataPageID;
		request.params.formID = arguments.formID;
	</cfscript>

	<cfsavecontent variable="deleteFormHTML">
		<cfscript>
			variables.scripts.loadJquery(force=1);
			variables.scripts.loadADFLightbox(force=1);
		</cfscript>
		<cfinclude template="/ADF/extensions/datasheet-modules/delete_element_handler.cfm">
	</cfsavecontent>
	<cfreturn deleteFormHTML>
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
	2011-01-25 - MFC - Modified - Updated formBean param default value to "forms_1_1"
	2012-03-08 - GAC - Modified - Added a comment to encourage the use of the current function in the UI lib
--->
<!--- // This function has be DEPRECATED! // ---> 
<!--- // - To use the buildAddEditLink to call the default formBean of forms_1_1 please use the buildAddEditLink in the UI lib --->
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
		<cfoutput>#application.ADF.scripts.loadJQuery()##application.ADF.scripts.loadADFLightbox()#<a href="javascript:;" rel="#application.ADF.ajaxProxy#?bean=#arguments.formBean#&method=#arguments.formMethod#&formID=#formID#&dataPageID=#arguments.dataPageID#&lbAction=#lbAction#&title=#arguments.lbTitle##uParams#" class="ADFLightbox<cfif LEN(TRIM(arguments.linkClass))> #arguments.linkClass#</cfif>" title="#arguments.linkTitle#">#arguments.linkTitle#</a></cfoutput>
	</cfsavecontent>
	<cfreturn rtnStr>
</cffunction>

</cfcomponent>