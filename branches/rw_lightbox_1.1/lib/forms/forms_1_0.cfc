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
	forms_1_0.cfc
Summary:
	Form functions for the ADF Library
History:
	2009-06-22 - MFC - Created
--->
<cfcomponent displayname="forms_1_0" extends="ADF.core.Base" hint="Form functions for the ADF Library">

<cfproperty name="version" value="1_0_0">
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
--->
<cffunction name="addToSimpleForm" access="public" returntype="void">
	<cfargument name="fieldData" type="struct" required="true">
	<cfscript>
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
--->
<cffunction name="extractFromSimpleForm" access="public" returntype="Struct">
	<cfargument name="formStruct" type="struct" required="true">
	<cfargument name="fieldList" type="String" required="false" default="">
	<cfscript>
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
			fieldList = StructKeyList(rtnStruct);
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
				if ( ListFindNoCase(fieldList,fieldValue) )
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
		<cfoutput>
		<cfscript>
			variables.scripts.loadJquery('1.3.2', 1);
			variables.scripts.loadADFLightbox(force=1);
		</cfscript>
		<script type='text/javascript'>
			jQuery(document).ready(function(){
				//window.parent.location.href = window.parent.location.href;
				//window.parent.closeLB();
				RefreshAndCloseWindow();
			});
		</script>
		</cfoutput>
	</cfsavecontent>
	
	<cfif NOT renderResult>
		<cfif formContainRTE>
			<!--- Set the form result HTML --->
			<cfsavecontent variable="formResultHTML">
				<cfoutput>
				<cfscript>
					variables.scripts.loadJquery('1.3.2', 1);
				</cfscript>
				<!--- Close the lightbox on click --->
				<script type='text/javascript'>
					//window.opener.location.href = window.opener.location.href + "&renderResult=true";
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
					// set dialog name so forms will resize automatically
					request.CD_DialogName = "";
				</cfscript>
				<!--- Call the UDF function --->
				#Server.CommonSpot.UDF.UI.RenderSimpleForm(arguments.dataPageID, arguments.formID, APIPostToNewWindow, formResultHTML)#
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
History:
 	2009-10-25 - RLW - Created
	2010-02-18 - MFC - Returns a HTML for delete form.
	2010-04-14 - GAC - Updated to work with the ADFLightbox Framework
--->
<cffunction name="renderDeleteForm" access="public" returntype="String" hint="Renders the standard datasheet delete module">
	<cfargument name="formID" type="numeric" required="true" hint="The FormID for the Custom Element">
	<cfargument name="dataPageID" type="numeric" required="true" hint="the DataPageID for the record being deleted">
	
	<cfset var deleteFormHTML = "">
	<cfsavecontent variable="deleteFormHTML">
		<cfscript>
			variables.scripts.loadJquery('1.3.2', 1);
			variables.scripts.loadADFLightbox(force=1);
			
			//targetModule = "#request.subsiteCache[1].url#datasheet-modules/delete-form-data.cfm";
			targetModule = "/ADF/extensions/datasheet-modules/delete_element_handler.cfm";
			request.params.pageID = arguments.dataPageID;
			request.params.formID = arguments.formID;
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
--->
<cffunction name="closeLBAndRefresh" access="public" returntype="void" hint="">
	<cfoutput>
		<cfscript>
			variables.scripts.loadJquery('1.3.2', 1);
		</cfscript>
		<script type='text/javascript'>
			jQuery(document).ready(function(){
				window.parent.location.href = window.parent.location.href;
				window.parent.closeLB();
			});
		</script>
		<!--- Close the lightbox on click --->
		<!--- <script type='text/javascript'>
			jQuery(document).ready(function(){
				jQuery('a##closeLB').click(function () { 
					window.parent.location.href = window.parent.location.href;
					window.parent.closeLB();
			    });
			});
		</script>
		<div style='margin:10px;text-align:center;'>
			<a href='javascript:;' id='closeLB'>Click Here</a> to close this window.
		</div> --->
	</cfoutput>
</cffunction>

</cfcomponent>