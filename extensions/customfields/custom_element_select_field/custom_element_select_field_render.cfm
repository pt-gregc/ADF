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
	M. Carroll 
Custom Field Type:
	Custom Element Select Field
Name:
	custom_element_select_field_render.cfm
Summary:
	Custom Element select field to select the custom element fields for the
		option id and name values.
	Added Properties to set the field name value, default field value, and field visibility.
ADF Requirements:
	csData_1_0
	scripts_1_0
History:
	2009-10-28 - MFC - Created
	2009-12-23 - MFC - Resolved error with loading the current value selected.
	2010-03-10 - MFC - Updated function call to ADF lib to reference Application.ADF.
						Updated cedata statement to remove filter and get all records
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];

	// Set the defaults
	if( StructKeyExists(xParams, "forceScripts") AND (xParams.forceScripts EQ "1") )
		xParams.forceScripts = true;
	else
		xParams.forceScripts = false;
		
	// Load JQuery to the script
	application.ADF.scripts.loadJQuery("1.3.2",xParams.forceScripts);
	
	// find if we need to render the simple form field
	renderSimpleFormField = false;
	if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) )
		renderSimpleFormField = true;

	if ( NOT StructKeyExists(xparams, "fldName") OR (LEN(xparams.fldName) LTE 0) )
		xparams.fldName = fqFieldName;
		
	// Get the data records
	ceDataArray = application.ADF.cedata.getCEData(xparams.customElement);	

	// Check if we do not have a current value then set to the default
	if ( (LEN(currentValue) LTE 0) OR (currentValue EQ "") )
		currentValue = xparams.defaultVal;
</cfscript>
<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName# = new Object();
		#fqFieldName#.id = '#fqFieldName#';
		//#fqFieldName#.tid = #rendertabindex#;
		#fqFieldName#.validator = "validate_#fqFieldName#()";
		#fqFieldName#.msg = "Please select a value for the #xparams.label# field.";
		// Check if the field is required
		if ( '#xparams.req#' == 'Yes' ){
			// push on to validation array
			vobjects_#attributes.formname#.push(#fqFieldName#);
		}
		
		function validate_#fqFieldName#()
		{
			//alert(fieldLen);
			if (jQuery("input[name=#fqFieldName#]").val() != '')
			{
				return true;
			}
			else
			{
				alert(#fqFieldName#.msg);
				return false;
			}
		}
		
		// Set a global disable field flag 
		var setDisableFlag = false;
		
		function #fqFieldName#_loadSelection()
		{
			//alert("fire");
			// Selected value
			var selectedVal = jQuery("select###fqFieldName#_select").find(':selected').val();
			//alert(selectedVal);
			// put the selected value into the 
			jQuery("input[name=#fqFieldName#]").val(selectedVal);
		}
		
		// Function to set the field as disabled
		function #xparams.fldName#_disableFld(){
			// Set a global disable field flag 
			setDisableFlag = true;
			jQuery("###fqFieldName#_select").attr('disabled', true);
		}
		// Function to set the field as enabled
		function #xparams.fldName#_enableFld(){
			// Set a global disable field flag 
			setDisableFlag = false;
			jQuery("###fqFieldName#_select").attr('disabled', false);
		}
		
		jQuery(document).ready(function(){ 
			// Check if the field is hidden
			if ( '#xparams.renderField#' == 'no' ) {
				jQuery("###fqFieldName#_fieldRow").hide();
			}
		});
	</script>
	
	<cfscript>
		if ( structKeyExists(request, "element") )
		{
			labelText = '<span class="CS_Form_Label_Baseline"><label for="#fqFieldName#">#xParams.label#:</label></span>';
			tdClass = 'CS_Form_Label_Baseline';
		}
		else
		{
			labelText = '<label for="#fqFieldName#">#xParams.label#:</label>';
			tdClass = 'cs_dlgLabel';
		}
	</cfscript>
	<tr id="#fqFieldName#_fieldRow">
		<td class="#tdClass#" valign="top">
			<font face="Verdana,Arial" color="##000000" size="2">
				<cfif xparams.req eq "Yes"><strong></cfif>
				#labelText#
				<cfif xparams.req eq "Yes"></strong></cfif>
			</font>
		</td>
		<td class="cs_dlgLabelSmall">
			<cfscript>
				// Get the list permissions and compare
				commonGroups = application.ADF.data.ListInCommon(request.user.grouplist, xparams.pedit);
				// Set the read only 
				readOnly = true;
				// Check if the user does have edit permissions
				if ( (xparams.UseSecurity EQ 0) OR ( (xparams.UseSecurity EQ 1) AND (ListLen(commonGroups)) ) )
					readOnly = false;
			</cfscript>
			<div id="#fqFieldName#_renderSelect">
				<select name='#fqFieldName#_select' id='#fqFieldName#_select' onchange='#fqFieldName#_loadSelection()' <cfif readOnly>disabled='disabled'</cfif>>
		 			<option value=''> - Select - </option>
		 			<cfloop index="cfs_i" from="1" to="#ArrayLen(ceDataArray)#">
						<cfif ceDataArray[cfs_i].Values['#xparams.valueField#'] EQ currentValue>
							<cfset isSelected = true>
						<cfelse>
							<cfset isSelected = false>
						</cfif>
						<option value="#ceDataArray[cfs_i].Values['#xparams.valueField#']#" <cfif isSelected>selected</cfif>>#ceDataArray[cfs_i].Values['#xparams.displayField#']#
					</cfloop>
		 		</select>
			</div>
		</td>
	</tr>
	<!--- hidden field to store the value --->
	<input type='hidden' name='#fqFieldName#' id='#xparams.fldName#' value='#currentValue#'>
	<!--- // include hidden field for simple form processing --->
	<cfif renderSimpleFormField>
		<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(xParams.fieldName, 'fic_','')#">
	</cfif>
</cfoutput>