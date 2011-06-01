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
	Custom Checkbox Field
Name:
	custom_checkbox_field_render.cfm
Summary:
	Custom checkbox field to set the field name value, default field value, and field visibility.
ADF Requirements:
	ceData_1_0
	data_1_0
	scripts_1_0
History:
	2009-07-06 - MFC - Created
	2011-05-26 - GAC - Modified - added a class parameter and updated the id attributes on the input field
	2011-06-01 - GAC - Modified - added trim around the field name variable to remove extra spaces, updated the jquery checked logic and added additional logic to allow seeing other boolean values as checked
--->
<cfscript>
	// Load JQuery to the script
	application.ADF.scripts.loadJQuery();
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	if ( NOT StructKeyExists(xparams, "fldClass") )
		xparams.fldClass = "";
		
	if ( NOT StructKeyExists(xparams, "fldName") )
		xparams.fldName = fqFieldName;
	else if ( LEN(TRIM(xparams.fldName)) EQ 0 )
		xparams.fldName = ReplaceNoCase(xParams.fieldName,'fic_','');
		
	// Set the field ID from the field name
	xparams.fldID = TRIM(xparams.fldName);
	
	// Check the default value
	if ( LEN(currentValue) LTE 0 ) {
		currentValue = 'no';
		// If defaulted to checked
		if ( xparams.defaultVal EQ "yes" )
			currentValue = 'yes';
	}
	
	// find if we need to render the simple form field
	renderSimpleFormField = false;
	if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) )
		renderSimpleFormField = true;
</cfscript>
<!--- <cfdump var="#xparams#"> --->

<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName# = new Object();
		#fqFieldName#.id = '#fqFieldName#';
		#fqFieldName#.tid = #rendertabindex#;
		
		//#fqFieldName#.validator = "validateLength()";
		//#fqFieldName#.msg = "Please upload a document.";
		// push on to validation array
		//vobjects_#attributes.formname#.push(#fqFieldName#);
	
		jQuery(document).ready(function(){
			
			// Check if we want to hide the field
			// Check if we are rendering the field 
			if ( '#xparams.renderField#' == 'yes' ) {
			
				// Set the value of the checkbox
				if ( jQuery('input[name=#fqFieldName#]').val() == 'yes' || jQuery('input[name=#fqFieldName#]').val() == 1 ) {
					jQuery('###xparams.fldID#_checkbox').attr('checked', 'checked');
				}
							
				// On Change Action
				jQuery('###xparams.fldID#_checkbox').change( function() {
					// Check the checkbox status
					//if ( jQuery('###xparams.fldID#_checkbox:checked').val() == 'yes' )
					if ( jQuery(this).attr("checked") )
						currVal = "yes";
					else
						currVal = "no";
					// Set the form field
					jQuery('input[name=#fqFieldName#]').val(currVal);
					
					//alert(jQuery('input[name=#fqFieldName#]').val());
				});
			}
			else {
				// Hide the field row
				jQuery("###fqFieldName#_fieldRow").hide();
			}
		});
	</script>
	<!--- hidden field to store the value --->
	
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
		<td class="#tdClass#" valign="top" nowrap="nowrap">
			<!--- <font face="Verdana,Arial" color="##000000" size="2"> --->
				<cfif xparams.req eq "Yes"><strong></cfif>
				#labelText#
				<cfif xparams.req eq "Yes"></strong></cfif>
			<!--- </font> --->
		</td>
		<td class="cs_dlgLabelSmall">
			<cfscript>
				// Get the list permissions and compare
				commonGroups = server.ADF.objectFactory.getBean("data_1_0").ListInCommon(request.user.grouplist, xparams.pedit);
				// Set the read only 
				readOnly = true;
				// Check if the user does have edit permissions
				if ( (xparams.UseSecurity EQ 0) OR ( (xparams.UseSecurity EQ 1) AND (ListLen(commonGroups)) ) )
					readOnly = false;
			</cfscript>
			<div id="#fqFieldName#_renderCheckbox">
				<!--- <input type='checkbox' name='#fqFieldName#_checkbox' id='#fqFieldName#_checkbox' value='yes' <cfif readOnly>readonly="true"</cfif>> --->
				<input type='checkbox' name='#fqFieldName#_checkbox' id='#xparams.fldID#_checkbox'<cfif LEN(TRIM(xparams.fldClass))> class="#xparams.fldClass#"</cfif> value='yes' <cfif readOnly>readonly="true"</cfif>>
			</div>
		</td>
	</tr>
	<input type='hidden' name='#fqFieldName#' id='#xparams.fldID#' value='#currentValue#'>
	<!--- // include hidden field for simple form processing --->
	<cfif renderSimpleFormField>
		<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(xParams.fieldName, 'fic_','')#">
	</cfif>
</cfoutput>