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
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	Michael Carroll 
Custom Field Type:
	CE_Select
Name:
	ce_select_props.cfm
Summary:
	Custom Element Field selection field type.  
	REQUIRES the CE_SELECT custom field type.  The properties must be set correctly in 
	the CE_FIELD_SELECT and CE_SELECT field properties.
ADF Requirements:
	lib/ceData/ceDATA_1_0
	lib/scripts/SCRIPTS_1_0
	extensions/CustomFields/CE_Field_Select
	extensions/CustomFields/AjaxService
History:
	2009-05-21 - MFC - Created
---><
<cfscript>
	// Load JQuery to the script
	server.ADF.objectFactory.getBean("scripts_1_0").loadJQuery("1.3.2");
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	// find if we need to render the simple form field
	renderSimpleFormField = false;
	if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) )
		renderSimpleFormField = true;
</cfscript>
<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
		#fqFieldName#.validator="validateCEFieldSelection()";
		#fqFieldName#.msg="Please select the Custom Element Field.";
		// push on to validation array
		vobjects_#attributes.formname#.push(#fqFieldName#);
	
		// Validation Function
		function validateCEFieldSelection(){
			// Verify that the selected value is not empty
			if (jQuery("select###fqFieldName#").find(':selected').val() != '')
				return true;
			else
				return false;
		}
		// Set the defaults
		#fqFieldName#ajaxCFC = '/ADF/extensions/customfields/ajax/AjaxService.cfc';
		#fqFieldName#method = 'CEFieldsSelect';
		// Function name is field ID 
		function #xparams.fieldID#(parentSelection) {
			// Put up the loading message
			jQuery("###fqFieldName#_ValueSelect").html("loading...");

			// JQuery get to return the select field to display for VALUE
			jQuery.get( #fqFieldName#ajaxCFC,
			{ 	method: #fqFieldName#method,
				customElementName: parentSelection,
				fieldName: '#fqFieldName#',
				selectedValue: '#currentValue#',
				subsiteurl: '#request.subsite.url#'
			},
			function(msg){
				// write the return html to the div
				jQuery("###fqFieldName#_ValueSelect").html(msg);
				// Check if no selection comes through, clear the field
				if ( parentSelection == '' ) {
					// Hide the empty select field to clear out this field when saved
					jQuery("###fqFieldName#_ValueSelect").hide();
				}
				else {
					// Show the select field
					jQuery("###fqFieldName#_ValueSelect").show();
				}
			});
		}
	</script>
	<tr>
		<td nowrap="nowrap" align="" width="25%" valign="baseline">
			<font face="Verdana,Arial" color="##000000" size="2">
				<cfif xParams.req EQ "Yes"><strong></cfif>
				<label for="#fqFieldName#">#xparams.label#:</label>
				<cfif xParams.req EQ "Yes"><strong></cfif>
			</font>
		</td>
		<td class="cs_dlgLabelSmall">
			<div id="#fqFieldName#_ValueSelect">
			</div>
		</td>
	</tr>
	<!--- // include hidden field for simple form processing --->
	<cfif renderSimpleFormField>
		<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(xParams.fieldName, 'fic_','')#">
	</cfif>
</cfoutput>