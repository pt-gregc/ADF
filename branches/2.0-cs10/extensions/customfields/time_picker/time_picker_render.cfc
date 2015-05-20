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
	G. Cronkright 
Custom Field Type:
	Time Picker Field
Name:
	time_picker_render.cfc
Summary:
	Time picker field to set pick a time from a jquery style time picker
ADF Requirements:
	scripts_1_0
History:
	2013-02-06 - GAC - Created
	2015-05-20 - DJM - Converted to CFC
--->
<cfcomponent displayName="TimePicker Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = Duplicate(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		var displayValue = "";
		var useClockIcon = false;
		
		// Pass new date URL variable through to the Calendar Picker
		if ( StructKeyExists(request.params,"newSelectedTime") )
			currentValue = request.params.newSelectedTime;
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);

		if ( LEN(TRIM(currentValue)) ) {
			// Fix bad or incorrect date/time entries stored
			currentValue = application.ADF.date.csDateFormat(currentValue,currentValue);
			// Strip the standardizedDateStr from the currentValue and do a TimeFormat for Display 
			displayValue = TimeFormat(TRIM(REPLACE(currentValue,inputParameters.standardizedDateStr,"","all")),inputParameters.cfTimeMask);
		}
			
		// Set Default Icon Options 
		if ( inputParameters.fldIcon EQ "clock")
			useClockIcon = true;

		// jQuery Headers
		application.ADF.scripts.loadJQuery();
		application.ADF.scripts.loadJQueryUI(themeName=inputParameters.uiTheme);
		// Load the DateJS Plugin Headers
		application.ADF.scripts.loadDateJS();
		// Load the DateFormat Plugin Headers
		application.ADF.scripts.loadDateFormat();

		if ( inputParameters.displayType IS "UItimepickerAddon" ) {
			application.ADF.scripts.loadJQueryUITimepickerAddon();
			if ( LEN(TRIM(inputParameters.jsTimeMask)) EQ 0  )
				inputParameters.jsTimeMask = "h:mm TT"; 
		}
		else if ( inputParameters.displayType IS "UItimepickerFG" ) {
			application.ADF.scripts.loadJQueryUITimepickerFG();
		}
		
		renderJSFunctions(argumentCollection=arguments,fieldParameters=inputParameters,useClockIcon=useClockIcon);
	</cfscript>

	<cfoutput>
		<div>
			<input type="text" name="#arguments.fieldName#_picker" id="#inputParameters.fldID#_picker" value="#displayValue#" autocomplete="off"<cfif readOnly> disabled="disabled"</cfif>>
			<cfif useClockIcon>
				<img class="ui-timepicker-trigger" id="#inputParameters.fldID#_timeIMG" src="#inputParameters.fldIconImg#" alt="time picker" title="Set a Time...">
			</cfif>
			<!--- hidden field to store the value --->
			<input type='hidden' name='#arguments.fieldName#' id='#inputParameters.fldID#' value='#currentValue#'>
			<!--- <input type='text' name='#arguments.fieldName#_dtObject' id='#inputParameters.fldID#_dtObject' value=''> --->
		</div>
	</cfoutput>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="fieldParameters" type="struct" required="yes">
	<cfargument name="useClockIcon" type="boolean" required="yes">
	<cfscript>
		var inputParameters = Duplicate(arguments.fieldParameters);
	</cfscript>
<cfoutput><script type="text/javascript">
<!--
jQuery(function() {	
	<cfif inputParameters.displayType EQ "UItimepickerAddon">
		// jQueryUI TimePicker Addon 
		// http://trentrichardson.com/examples/timepicker/	
		
		// jQueryUI TimePicker Addon Options
		var timePickerAddonOptions_#arguments.fieldName# = {
					ampm: true
					,timeFormat: '#inputParameters.jsTimeMask#'
					,hourGrid: 6
					,minuteGrid: 15
				};	
		
		// Calendar Picker Fields
		jQuery("###inputParameters.fldID#_picker").timepicker( timePickerAddonOptions_#arguments.fieldName# );
		
	<cfelseif inputParameters.displayType EQ "UItimepickerFG">
		// jQuery UI Timepicker (By François Gélinas)
		// http://fgelinas.com/code/timepicker/
		
		// jQueryUI TimePicker Addon Options
		var timePickerFGOptions_#arguments.fieldName# = {
					showPeriod: true
					,minutes: { interval: 5 }
					,showLeadingZero: false
					,button : null
					//,showOn : 'both' //button
					//,button : '.ui-timepicker-trigger'
				};	
		
		// jQuery UI Timepicker FG field
		jQuery("###inputParameters.fldID#_picker").timepicker( timePickerFGOptions_#arguments.fieldName# );
		
	</cfif>
	
		// Set the Clock or the Calendar Image to activate the Date/Time picker flyout 
	<cfif arguments.useClockIcon>
		jQuery("###inputParameters.fldID#_timeIMG").click(function(){
			jQuery("###inputParameters.fldID#_picker").focus();					
		});
	</cfif>
	
	// Onchange populate the Hidden field that stores the data
	jQuery("###inputParameters.fldID#_picker").change(function(){	
		var timeStr = jQuery("###inputParameters.fldID#_picker").val();
		var dateStr = '#inputParameters.standardizedDateStr#';
		
		var csDate = "";
		var jsDateObj = "";
		
		// Use DateJS lib to parse the concatenated date/time into a date/time object
		if ( jQuery.trim(dateStr).length && jQuery.trim(timeStr).length )
			jsDateObj = Date.parse(dateStr + " " + timeStr);

		// Use the dateFormat Lib to convert the date/time object to a CS Date string
		if ( jQuery.trim(jsDateObj).length )
			csDate=dateFormat(jsDateObj, "yyyy-mm-dd HH:MM:00");
			
		// Set the value to the hidden field to be stored
		jQuery("input[name=#arguments.fieldName#]").val(csDate);
	});

});
//-->
</script></cfoutput>
</cffunction>

<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = Duplicate(arguments.parameters);
		// inputParameters fields that cannot be overridden by the App
		var inputParametersExceptionsList = "fldID,appBeanName,appPropsVarName";
		
		// Validate if the property field has been defined
		if ( NOT StructKeyExists(inputParameters, "fldID") OR LEN(inputParameters.fldID) LTE 0 )
			inputParameters.fldID = TRIM(arguments.fieldName);
		else 
			inputParameters.fldID = TRIM(inputParameters.fldID);
		
		if ( NOT StructKeyExists(inputParameters, "uiTheme") OR LEN(inputParameters.uiTheme) LTE 0 )
			inputParameters.uiTheme = "redmond";
		
		if ( NOT StructKeyExists(inputParameters, "displayType") OR LEN(inputParameters.displayType) LTE 0 )
			inputParameters.displayType = "UItimepickerAddon";	
		if ( NOT StructKeyExists(inputParameters, "fldIcon") OR LEN(inputParameters.fldIcon) LTE 0 )
			inputParameters.fldIcon = "none";
		if ( NOT StructKeyExists(inputParameters, "fldIconImg") OR LEN(inputParameters.fldIconImg) LTE 0 )
			inputParameters.fldIconImg = "/ADF/extensions/customfields/time_picker/clock.png";

		if ( NOT StructKeyExists(inputParameters, "standardizedDateStr") OR LEN(inputParameters.standardizedDateStr) LTE 0 )
			inputParameters.standardizedDateStr = "1900-01-01";			
		if ( NOT StructKeyExists(inputParameters, "cfTimeMask") OR LEN(inputParameters.cfTimeMask) LTE 0 )
			inputParameters.cfTimeMask = "h:mm tt";	
		if ( NOT StructKeyExists(inputParameters, "jsTimeMask") OR LEN(inputParameters.jsTimeMask) LTE 0 )
			inputParameters.jsTimeMask = "";
			
		//-- App Override Variables --//
		if ( NOT StructKeyExists(inputParameters, "appBeanName") OR LEN(inputParameters.appBeanName) LTE 0 )
			inputParameters.appBeanName = "";
		if ( NOT StructKeyExists(inputParameters, "appPropsVarName") OR LEN(inputParameters.appPropsVarName) LTE 0 )
			inputParameters.appPropsVarName = "";

		// Optional ADF App Override for the Custom Field Type inputParameters
		If ( LEN(TRIM(inputParameters.appBeanName)) AND LEN(TRIM(inputParameters.appPropsVarName)) ) {
			inputParameters = application.ADF.utils.appOverrideCSParams(
														csParams=inputParameters,
														appName=inputParameters.appBeanName,
														appParamsVarName=inputParameters.appPropsVarName,
														paramsExceptionList=inputParametersExceptionsList
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
		return '';
	}
	
	private string function getValidationMsg()
	{
		return "Please select a value for the #arguments.label# field.";
	}
</cfscript>

</cfcomponent>