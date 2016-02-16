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
Custom Field Type:
	Subsite Select
Name:
	subsite_select_render.cfc
Summary:
	Custom field type, that allows a new subsite to be created
ADF Requirements:
	script_1_0
	csData_1_0
History:
	2007-01-24 - RLW - Created
	2011-02-08 - GAC - Removed old jQuery tools reference
					 - Replaced the getBean call with application.ADF
	2012-02-13 - GAC - Updated to use accept a filter porperty and a uitheme propery 
					 - Also added the appBeanName and appPropsVarName props to allow porps to be overridden by an app
	2013-03-07 - GAC - Fixed an issue with the Required field validation script.
	2015-04-28 - DJM - Converted to CFC
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean()
	2016-02-09 - GAC - Updated duplicateBean() to use data_2_0.duplicateStruct()
	2016-02-16 - GAC - Added getResourceDependencies support
	                 - Added loadResourceDependencies support
	                 - Moved resource loading to the loadResourceDependencies() method
	                 - Moved appOverrideCSParams into the setDefaultParameters() method so loadResourceDependencies() loads the correct params
--->
<cfcomponent displayName="SubsiteSelect Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		var selectField = "select_#arguments.fieldName#";
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);

		renderJSFunctions(argumentCollection=arguments, fieldParameters=inputParameters);
	</cfscript>
	
	<cfoutput>
		<!--- // TODO: future enhancement --->
		<!--- <div id="#arguments.fieldName#_add_msg" style="display:none;">
			Subsite Added
		</div> --->
		<select name="#arguments.fieldName#" id="#arguments.fieldName#" size="1"<cfif readOnly> disabled='disabled'</cfif>>
			<option value="">-- select --</option>
		</select>
		<span id="#selectField#_loading" style="display:none;font-size:10px;">
			<img src="/ADF/extensions/customfields/subsite_select/ajax-loader-arrows.gif" width="16" height="16" /> Loading Subsites...
		</span>
		<!--- // TODO: future enhancement --->
		<!---
			<br /><button rel="/ADF/extensions/customfields/subsite_select/add_subsite.cfm?fqfieldName=#arguments.fieldName#" class="ui-button ui-state-default ui-corner-all ADFLightbox" id="#arguments.fieldName#_new_button">New Subsite</button>
		--->
	</cfoutput>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="fieldParameters" type="struct" required="yes">
	
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.fieldParameters);
		var selectField = "select_#arguments.fieldName#";
		// Added for future use
		// TODO: Add options in Props for a Bean and a Method that return a custom Subsite Struct
		var subsiteStructBeanName = "csData_2_0";
		var subsiteStructMethodName = "getSubsiteStruct";
		var currentValue = arguments.value;	// the field's current value
		var currentValueText = "";
		
		// If the currentValue has a numeric value get the subsiteURL for that subsiteID
		if ( LEN(TRIM(currentValue)) AND IsNumeric(currentValue) AND StructKeyExists(request.subsitecache,currentValue) ) 
			currentValueText = request.subsitecache[currentValue].URL;
	</cfscript>
<cfoutput><script type="text/javascript">
<!--
// init allowSubsiteAdd show/hide options
var options = {};

// handle on start processing
jQuery(function() {
	//Hide the ajax working image
	jQuery("###selectField#_loading").hide();	
	
	<!--- // TODO: future enhancement --->
	<!--- // jQuery("###arguments.fieldName#_new_button").button(); --->
		
	// load the list of subsites
	#arguments.fieldName#_loadSubsites();		
});

// get the list of subsites and load them into the select list
function #arguments.fieldName#_loadSubsites()
{
	//Show the ajax working image
	jQuery("###selectField#_loading").show();
	
	jQuery.get("#application.ADF.ajaxProxy#",
		{ 	
			bean: "#subsiteStructBeanName#",
			method: "#subsiteStructMethodName#",
			filterValueList: "#inputParameters.filterList#",
			orderby: "subsiteURL",
			returnFormat: "json" 
		},
		function( subsiteStruct )
		{
			var cValue = "#currentValue#";
			var cValueText = "#currentValueText#";
			
			// If currentValue has a value add it as an option
			if ( cValue.length && cValueText.length ) {
				jQuery("###arguments.fieldName#").addOption(cValue, cValueText);
			}
			
			jQuery.each(subsiteStruct, function(i, val) {
				jQuery("###arguments.fieldName#").addOption(i, val);
			});
			
			// Sort by Options by Struct Value
			jQuery("###arguments.fieldName#").sortOptions();
			
			if ( cValue.length && cValueText.length ) {
				// make the current subsite selected
				jQuery("###arguments.fieldName#").selectOptions(cValue);
			} else {
				jQuery("###arguments.fieldName#").selectOptions("");
			}
			
			//Hide the ajax working image
			jQuery("###selectField#_loading").hide();
			
			ResizeWindow();
		},
		"json"
	);
}

<cfif inputParameters.allowSubsiteAdd>
function #arguments.fieldName#addSubsite(name, displayName, description)
{
	// get values from the form fields
	var subsiteName = jQuery("###arguments.fieldName#_name").attr("value");
	var displayName = jQuery("###arguments.fieldName#_display").attr("value");
	var description = jQuery("###arguments.fieldName#_descr").attr("value");
	var parentSubsiteID = jQuery("###arguments.fieldName#").selectedValues();
	// make the call to add the subsite
	jQuery.post("#application.ADF.ajaxProxy#", 
		{ 
			bean: "csData",
			method: "addSubsite",
			name: subsiteName,
			displayName: displayName,
			description: description,
			parentSubsiteID: parentSubsiteID,
			returnFormat: "json" 
		},
		function(newSubsiteID){
			// reload the subsite listing
			#arguments.fieldName#_loadSubsites();
			// select the new subsite
			jQuery("###arguments.fieldName#").selectOptions(newSubsiteID);
			// close the dialog and show the "add message"
			jQuery("###arguments.fieldName#_add").dialog("close");
			jQuery("###arguments.fieldName#_add_msg").show("blind", options, 500, callback);
			jQuery("###arguments.fieldName#_add_msg").hide("blind", options, 1500, callback);
		 },
		 "json"
	);
}
</cfif>	
//-->
</script></cfoutput>
</cffunction>

<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		var xparamsExceptionsList = "appBeanName,appPropsVarName";
		
		if ( NOT StructKeyExists(inputParameters, "allowSubsiteAdd") OR LEN(inputParameters.allowSubsiteAdd) LTE 0 )
			inputParameters.allowSubsiteAdd = "no";
		if ( NOT StructKeyExists(inputParameters, "uiTheme") OR LEN(inputParameters.uiTheme) LTE 0 )
			inputParameters.uiTheme = "smoothness";
		if ( NOT StructKeyExists(inputParameters, "filterList") OR LEN(inputParameters.filterList) LTE 0 )
			inputParameters.filterList = "";	
			
		//-- App Override Variables --//
		if ( NOT StructKeyExists(inputParameters, "appBeanName") OR LEN(inputParameters.appBeanName) LTE 0 )
			inputParameters.appBeanName = "";
		if ( NOT StructKeyExists(inputParameters, "appPropsVarName") OR LEN(inputParameters.appPropsVarName) LTE 0 )
			inputParameters.appPropsVarName = "";

		// Optional ADF App Override for the Custom Field Type
		if ( LEN(TRIM(inputParameters.appBeanName)) AND LEN(TRIM(inputParameters.appPropsVarName)) )
		{
			inputParameters = application.ADF.utils.appOverrideCSParams(
														csParams=inputParameters,
														appName=inputParameters.appBeanName,
														appParamsVarName=inputParameters.appPropsVarName,
														paramsExceptionList=xparamsExceptionsList
													);
		}
		
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

	/*
		IMPORTANT: Since loadResourceDependencies() is using ADF.scripts loadResources methods, getResourceDependencies() and
		loadResourceDependencies() must stay in sync by accounting for all of required resources for this Custom Field Type.
	*/
	public void function loadResourceDependencies()
	{
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);

		inputParameters = setDefaultParameters(argumentCollection=arguments);

		// Load registered Resources via the ADF scripts_2_0
		application.ADF.scripts.loadJQuery();
		application.ADF.scripts.loadJQueryUI(themeName=inputParameters.uiTheme);
		application.ADF.scripts.loadJQuerySelectboxes();
	}
	public string function getResourceDependencies()
	{
		return "jQuery,jQueryUI,JQuerySelectboxes";
	}
</cfscript>

</cfcomponent>