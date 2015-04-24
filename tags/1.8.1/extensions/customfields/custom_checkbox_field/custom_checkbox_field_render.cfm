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
	Michael Carroll 
Custom Field Type:
	Custom Checkbox Field
Name:
	custom_checkbox_field_render.cfm
Summary:
	Custom checkbox field to set the field name value, default field value, and field visibility.
ADF Requirements:
	scripts_1_0
	forms_1_0
History:
	2009-07-06 - MFC - Created
	2011-05-26 - GAC - Added a class parameter and updated the id attributes on the input field
	2011-06-01 - GAC - Added trim around the field name variable to remove extra spaces, updated the jQuery checked logic and added additional logic to allow seeing other boolean values as checked
	2011-09-09 - GAC - Removed renderSimpleFormField check, added readOnly field security code and updated the jQuery script block 
	2012-04-11 - GAC - Added the fieldPermission parameter to the wrapFieldHTML function call
					 - Added the includeLabel and includeDescription parameters to the wrapFieldHTML function call
					 - Updated the readOnly check to use the cs6 fieldPermission parameter
					 - Updated the wrapFieldHTML explanation comment block
	2012-11-13 - GAC - Updated the logic for 'Checked By Default' option so when the unchecked value is blank and the currentValue is blank 
					   it determines if this form is creating the a new record before setting the currentValue to the default value					     
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
	
	// Set the value that is stored when the checkbox is checked
	if ( NOT StructKeyExists(xparams, "checkedVal") )
		xparams.checkedVal = "yes";
	// Set the value that is stored when the checkbox is checked
	if ( NOT StructKeyExists(xparams, "uncheckedVal") )
		xparams.uncheckedVal = "no";
		
	// Set the field ID from the field name
	xparams.fldID = TRIM(xparams.fldName);
	
	// Get the DataPageID to see if this is a form to create a new record or update an existing record
	// 0 = new record and greater than 0 = existing record
	formDataPageID = 0;
	if ( StructKeyExists(attributes,"LayoutStruct") AND StructKeyExists(attributes.LayoutStruct,"UDFPAGEID") ) 
		formDataPageID = attributes.LayoutStruct.UDFPAGEID;	

	if ( LEN(TRIM(currentValue)) LTE 0 ) {
		currentValue = xparams.uncheckedVal; //'no'
		//  If no value and this is a new record then use the defaulted value 
		if ( formDataPageID EQ 0 AND xparams.defaultVal EQ "yes" )
			currentValue = xparams.checkedVal; //'yes'
	}

	
	// Set defaults for the label and description 
	includeLabel = true;
	includeDescription = true; 

	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";

	//-- Read Only Check w/ cs6 fieldPermission parameter --
	readOnly = application.ADF.forms.isFieldReadOnly(xparams,variables.fieldPermission);
</cfscript>

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
	
		jQuery(function(){
			
			// Check if we want to hide the field or if we are rendering the field 
			if ( '#xparams.renderField#' == 'yes' ) {
			
				// Set the value of the checkbox
				if ( jQuery('input[name=#fqFieldName#]').val() == '#xparams.checkedVal#' ) {
					jQuery('###xparams.fldID#_checkbox').attr('checked', 'checked');
				}
							
				// On Change Action
				jQuery('###xparams.fldID#_checkbox').change( function() {
					// Check the checkbox status
					//if ( jQuery('###xparams.fldID#_checkbox:checked').val() == 'yes' )
					if ( jQuery(this).attr("checked") )
						currVal = "#xparams.checkedVal#";
					else
						currVal = "#xparams.uncheckedVal#";
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

	<cfsavecontent variable="inputHTML">
		<cfoutput>
			
			<div id="#fqFieldName#_renderCheckbox">
				<!--- <input type='checkbox' name='#fqFieldName#_checkbox' id='#fqFieldName#_checkbox' value='yes' <cfif readOnly>readonly="true"</cfif>> --->
				<input type='checkbox' name='#fqFieldName#_checkbox' id='#xparams.fldID#_checkbox'<cfif LEN(TRIM(xparams.fldClass))> class="#xparams.fldClass#"</cfif> value='yes' <cfif readOnly>readonly="true"</cfif>>
			</div>
			<!--- hidden field to store the value --->
			<input type='hidden' name='#fqFieldName#' id='#xparams.fldID#' value='#currentValue#'>
			
		</cfoutput>
	</cfsavecontent>
	
	<!---
		This CFT is using the forms lib wrapFieldHTML functionality. The wrapFieldHTML takes
		the Form Field HTML that you want to put into the TD of the right section of the CFT 
		table row and helps with display formatting, adds the hidden simple form fields (if needed) 
		and handles field permissions (other than read-only).
		Optionally you can disable the field label and the field discription by setting 
		the includeLabel and/or the includeDescription variables (found above) to false.  
	--->
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission,includeLabel,includeDescription)#
</cfoutput>