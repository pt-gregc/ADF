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
	custom_checkbox_field_render.cfc
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
	2015-04-28 - DJM - Added own CSS
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 
--->
<cfcomponent displayName="CustomCheckboxField Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">

	<cfscript>
		var inputParameters =  Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		var formDataPageID = 0;
		var allAtrs = getAllAttributes();

		// Load JQuery to the script
		application.ADF.scripts.loadJQuery();
	
		inputParameters = setDefaultParameters(argumentCollection=arguments);	
	
		// Get the DataPageID to see if this is a form to create a new record or update an existing record
		// 0 = new record and greater than 0 = existing record
		if ( StructKeyExists(allAtrs,"LayoutStruct") AND StructKeyExists(allAtrs.LayoutStruct,"UDFPAGEID") ) 
			formDataPageID = allAtrs.LayoutStruct.UDFPAGEID;

		if ( LEN(TRIM(currentValue)) LTE 0 ) {
			currentValue = inputParameters.uncheckedVal; //'no'
			//  If no value and this is a new record then use the defaulted value 
			if ( formDataPageID EQ 0 AND inputParameters.defaultVal EQ "yes" )
				currentValue = inputParameters.checkedVal; //'yes'
		}
		
		renderJSFunctions(argumentCollection=arguments, fieldParameters=inputParameters);
	</cfscript>

<cfoutput>	
	<div id="#arguments.fieldName#_renderCheckbox">
		<input type='checkbox' name='#arguments.fieldName#_checkbox' id='#inputParameters.fldID#_checkbox'<cfif LEN(TRIM(inputParameters.fldClass))> class="#inputParameters.fldClass#"</cfif> value='yes' <cfif readOnly>readonly="true"</cfif>>
	</div>
	<!--- hidden field to store the value --->
	<input type='hidden' name='#arguments.fieldName#' id='#inputParameters.fldID#' value='#currentValue#'>
</cfoutput>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="fieldParameters" type="struct" required="yes">
	
	<cfscript>
		var inputParameters =  Server.CommonSpot.UDF.util.duplicateBean(arguments.fieldParameters);
	</cfscript>

<cfoutput>
<script type="text/javascript">
<!--
jQuery(function(){		
	// Check if we want to hide the field or if we are rendering the field 
	if ( '#inputParameters.renderField#' == 'yes' ) {
	
		// Set the value of the checkbox
		if ( jQuery('input[name=#arguments.fieldName#]').val() == '#inputParameters.checkedVal#' ) {
			jQuery('###inputParameters.fldID#_checkbox').attr('checked', 'checked');
		}
					
		// On Change Action
		jQuery('###inputParameters.fldID#_checkbox').change( function() {
			// Check the checkbox status
			//if ( jQuery('###inputParameters.fldID#_checkbox:checked').val() == 'yes' )
			if ( jQuery(this).attr("checked") )
				currVal = "#inputParameters.checkedVal#";
			else
				currVal = "#inputParameters.uncheckedVal#";
			// Set the form field
			jQuery('input[name=#arguments.fieldName#]').val(currVal);
		});
	}
	else {
		// Hide the field row
		jQuery("###arguments.fieldName#_container").hide();
	}
});
//-->
</script></cfoutput>
</cffunction>

<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters =  Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		
		if ( NOT StructKeyExists(inputParameters, "fldClass") )
			inputParameters.fldClass = "";
		
		if ( NOT StructKeyExists(inputParameters, "fldName") )
			inputParameters.fldName = arguments.fieldName;
		else if ( LEN(TRIM(inputParameters.fldName)) EQ 0 )
			inputParameters.fldName = ReplaceNoCase(inputParameters.fieldName,'fic_','');
		
		// Set the value that is stored when the checkbox is checked
		if ( NOT StructKeyExists(inputParameters, "checkedVal") )
			inputParameters.checkedVal = "yes";
		// Set the value that is stored when the checkbox is checked
		if ( NOT StructKeyExists(inputParameters, "uncheckedVal") )
			inputParameters.uncheckedVal = "no";
			
		// Set the field ID from the field name
		inputParameters.fldID = TRIM(inputParameters.fldName);
		
		return inputParameters;
	</cfscript>
</cffunction>

<cfscript>
	public string function getResourceDependencies()
	{
		return listAppend(super.getResourceDependencies(), "jQuery");
	}
</cfscript>

</cfcomponent>