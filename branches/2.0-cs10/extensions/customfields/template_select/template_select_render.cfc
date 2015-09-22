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
Custom Field Type:
	Template Select
Name:
	template_select_render.cfc
Summary:
	Custom field type to select from the CS templates
ADF Requirements:
	scripts_1_0
	csData_1_0
History:
	2007-01-24 - RLW - Created
	2011-10-22 - MFC - Set the default selected value to be stored when loading the CFT.
	2012-02-06 - MFC - Updated scripts to load with the site ADF
	2013-02-20 - MFC - Replaced Jquery "$" references.
	2013-03-08 - GAC - Updated to use the wrapFieldHTML function
	2014-10-31 - GAC - Added the editOnce option
	2015-04-28 - DJM - Added own CSS
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 
	2015-09-22 - JTP - Updated the jQuery syntax to get the current selected value
--->
<cfcomponent displayName="TemplateSelect Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">

	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		var xparamsExceptionsList = "appBeanName,appPropsVarName";
		var selectField = "select_#arguments.fieldName#";
	
		inputParameters = setDefaultParameters(argumentCollection=arguments);
		
		// Optional ADF App Override for the Custom Field Type parameters
		If ( LEN(TRIM(inputParameters.appBeanName)) AND LEN(TRIM(inputParameters.appPropsVarName)) ) {
			inputParameters = application.ADF.utils.appOverrideCSParams(
														csParams=inputParameters,
														appName=inputParameters.appBeanName,
														appParamsVarName=inputParameters.appPropsVarName,
														paramsExceptionList=xparamsExceptionsList
													);
		}
	
		// Updated scripts to load with the site ADF
		application.ADF.scripts.loadJQuery();
		application.ADF.scripts.loadJQuerySelectboxes();
	
		if ( LEN(currentValue) AND inputParameters.editOnce )
			readOnly = true;
		
		renderJSFunctions(argumentCollection=arguments,fieldParameters=inputParameters);
	</cfscript>
	
	<cfoutput>
		<select name="#arguments.fieldName#_select" id="#arguments.fieldName#_select" size="1"<cfif readOnly> disabled='disabled'</cfif>>
			<option value="">-- select --</option>
		</select>
		<span id="#selectField#_loading" style="display:none;font-size:10px;">
			<img src="/ADF/extensions/customfields/template_select/ajax-loader-arrows.gif" width="16" height="16" /> Loading Templates...
		</span>
		<!--- hidden field to store the value --->
		<input type='hidden' name='#arguments.fieldName#' id='#arguments.fieldName#' value='#currentValue#'>
	</cfoutput>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="fieldParameters" type="struct" required="yes">
	
	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.fieldParameters);
		// Added for future use
		// TODO: Add options in Props for a Bean and a Method that return a custom Subsite Struct
		var templateStructBeanName = "csData_1_2";
		var templateStructMethodName = "getSiteTemplates";
		var selectField = "select_#arguments.fieldName#";
	</cfscript>

<cfoutput>
<script type="text/javascript">
<!--		
// get the list of subsites and load them into the select list
function #arguments.fieldName#_loadTemplates()
{
	//Show the ajax working image
	jQuery("###selectField#_loading").show();
	
	jQuery.get("#application.ADF.ajaxProxy#",
		{ 	bean: "#templateStructBeanName#",
			method: "#templateStructMethodName#",
			filterValueList: "#inputParameters.filterList#",
			oderby: "title",
			returnFormat: "json" },
		function( subsiteStruct )
		{
			// Load the options to the select field
			jQuery.each(subsiteStruct, function(i, val) {
				jQuery("###arguments.fieldName#_select").addOption(i, val);
			});
			// Sort the options
			jQuery("###arguments.fieldName#_select").sortOptions();
			
			// Set the selected field for the current value
			jQuery("###arguments.fieldName#_select").val('#arguments.value#');			
			
			// Load the on change binding for the select field
			#arguments.fieldName#_loadBinding();
			
			//Hide the ajax working image
			jQuery("###selectField#_loading").hide();
			
			ResizeWindow();
		},
		"json"
	);
}

function #arguments.fieldName#_loadBinding() {
	// Use 'click' event b/c 'change' not supported with LIVE in 1.3.2
	jQuery("###arguments.fieldName#_select").change( function(){
		// put the selected value into the fieldName
		jQuery("input[name=#arguments.fieldName#]").val(jQuery(this).val());
	});
	
	// 2011-10-22 - MFC - Load the current selection into the saved field
	jQuery("input[name=#arguments.fieldName#]").val(jQuery("###arguments.fieldName#_select option:selected").val());
}

jQuery(document).ready(function() {
	#arguments.fieldName#_loadTemplates();
});
//-->
</script></cfoutput>
</cffunction>

<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		
		if ( NOT StructKeyExists(inputParameters, "filterList") OR LEN(inputParameters.filterList) LTE 0 )
			inputParameters.filterList = "";
		if ( NOT StructKeyExists(inputParameters, "editOnce") )
			inputParameters.editOnce = 0;	
			
		//-- App Override Variables --//
		if ( NOT StructKeyExists(inputParameters, "appBeanName") OR LEN(inputParameters.appBeanName) LTE 0 )
			inputParameters.appBeanName = "";
		if ( NOT StructKeyExists(inputParameters, "appPropsVarName") OR LEN(inputParameters.appPropsVarName) LTE 0 )
			inputParameters.appPropsVarName = "";
		
		return inputParameters;
	</cfscript>
</cffunction>

<cfscript>
	private any function getValidationJS(required string formName, required string fieldName, required boolean isRequired)
	{
		if (arguments.isRequired)
			return 'hasValue(document.#arguments.formName#.#arguments.fieldName#, "TEXT")';
		return "";
	}
	
	private string function getValidationMsg()
	{
		return "Please select a value for the #arguments.label# field.";
	}

	public string function getResourceDependencies()
	{
		return listAppend(super.getResourceDependencies(), "jQuery,jQuerySelectboxes");
	}
</cfscript>

</cfcomponent>