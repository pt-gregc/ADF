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
	date picker
Name:
	date_picker_render.cfc
Summary:
	A custom checkbox field that is used to select dates within the Calendar App
ADF Requirements:
	date_1_0
	scripts_1_0
History:
	2013-02-12 - GAC - Created
	2015-05-13 - DJM - Converted to CFC
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 
--->
<cfcomponent displayName="DatePicker Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		var displayValue = "";
		var useCalendarIcon = false;
		
		// Pass new date URL variable through to the Calendar Picker
		if ( StructKeyExists(request.params,"newSelectedDate") )
			currentValue = request.params.newSelectedDate;
	
		inputParameters = setDefaultParameters(argumentCollection=arguments);
	
		if ( LEN(TRIM(currentValue)) ){
			// Fix bad or incorrect date/time entries
			currentValue = application.ADF.date.csDateFormat(currentValue,currentValue);
			// Strip the standardizedTimeStr from the currentValue and do a DateForamt for Display
			displayValue = DateFormat(TRIM(REPLACE(currentValue,inputParameters.standardizedTimeStr,"","all")),inputParameters.cfDateMask);
		}
		
		// Set Default Icon Options 
		if ( inputParameters.fldIcon EQ "calendar")
			useCalendarIcon = true;	
	
		// jQuery Headers
		application.ADF.scripts.loadJQuery();
		application.ADF.scripts.loadJQueryUI(themeName=inputParameters.uiTheme);
		// Load the DateJS Plugin Headers
		application.ADF.scripts.loadDateJS();
		// Load the DateFormat Plugin Headers
		application.ADF.scripts.loadDateFormat();

		if ( inputParameters.displayType EQ "datepick" ) {
			application.ADF.scripts.loadJQueryDatePick();
		}
		
		renderJSFunctions(argumentCollection=arguments, fieldParameters=inputParameters,useCalendarIcon=useCalendarIcon);
		
		if (inputParameters.displayType EQ "UIdatepicker")
			useCalendarIcon = false;
	</cfscript>

	<cfif inputParameters.fldClearDate EQ 'yes'>
		<cfoutput><style>
			.#arguments.fieldName#_smalllink{
				font-size: 9px;
			}
		</style></cfoutput>
	</cfif>

	<cfoutput>
		<div>
			<input type="text" name="#arguments.fieldName#_picker" id="#inputParameters.fldID#_picker" value="#displayValue#" autocomplete="off"<cfif readOnly> disabled="disabled"</cfif>>
			<cfif useCalendarIcon>
				<img class="ui-datepicker-trigger" id="#inputParameters.fldID#_dateIMG" src="#inputParameters.fldIconImg#" alt="calendar" title="Select a Date...">
			</cfif>
			<!--- hidden field to store the value --->
			<input type='hidden' name='#arguments.fieldName#' id='#inputParameters.fldID#' value='#currentValue#'>
			<!--- <input type='text' name='#arguments.fieldName#_dtObject' id='#inputParameters.fldID#_dtObject' value=''> --->
		</div>
		<cfif inputParameters.fldClearDate EQ 'yes'>
		<div>
			<a href="javascript:;" id="#arguments.fieldName#_cleardate" class="#arguments.fieldName#_smalllink">Clear Date</a>
		</div>
		</cfif>
	</cfoutput>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="fieldParameters" type="struct" required="yes">
	<cfargument name="useCalendarIcon" type="boolean" required="yes">
	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.fieldParameters);
		var bUseCalendarIcon = arguments.useCalendarIcon;
	</cfscript>
<cfoutput><script type="text/javascript">
<!--
jQuery(function() {
<cfif inputParameters.displayType EQ "UIdatepicker">
	// jQueryUI Date Picker
	// http://jqueryui.com/demos/datepicker/
	
	// jQueryUI Date Picker Options
	var datePickerOptions_#arguments.fieldName# = {
			changeMonth : true
			,changeYear : true
			,showButtonPanel : true
			,constrainInput : false 
			,dateFormat : '#inputParameters.jsDateMask#'
			,zIndex:9999
			<cfif bUseCalendarIcon>
			,showOn : "both" //button
			,buttonImage : "#inputParameters.fldIconImg#"
			,buttonImageOnly : true
			,buttonText : 'Choose a Date...'
			<cfelse>
			,showOn : "focus" 
			</cfif>
		};
		
	// Calendar Picker Fields
	jQuery("###inputParameters.fldID#_picker").datepicker( datePickerOptions_#arguments.fieldName# );
	
	// Set the offset to help with displaying inside an lightbox
	jQuery.extend(jQuery.datepicker,{_checkOffset:function(inst,offset,isFixed){offset.top=40; offset.left=200; return offset;}});
	
	<!--- // Now set the bUseCalendarIcon variable to false since the plugin js handles rendering it --->
	<cfset bUseCalendarIcon = false>
	
<cfelseif inputParameters.displayType EQ "datepick">
	// jQuery datepick 
	// http://keith-wood.name/datepick.html
	
	var datePickerOptions_#arguments.fieldName# = {
			onSelect: function() {
				jQuery(this).change();
			  }
		};
	
	// jQuery datepick field
	jQuery('###inputParameters.fldID#_picker').datepick( datePickerOptions_#arguments.fieldName# );
</cfif>

	// Set the Clock or the Calendar Image to activate the Date/Time picker flyout 
<cfif bUseCalendarIcon>
	jQuery("###inputParameters.fldID#_dateIMG").click(function(){
		jQuery("###inputParameters.fldID#_picker").focus();				
	});
</cfif>

	// Onchange populate the Hidden field that stores the data
	jQuery("###inputParameters.fldID#_picker").change(function(){
		var dateStr = jQuery("###inputParameters.fldID#_picker").val();
		// Get the Standard/Dummy Time 
		var timeStr = '#inputParameters.standardizedTimeStr#';
		
		var csDate = "";
		var jsDateObj = "";
		
		// Use DateJS lib to parse the concatenated date/time into a date/time object
		if ( jQuery.trim(dateStr).length && jQuery.trim(timeStr).length )
			jsDateObj = Date.parse(dateStr + " " + timeStr);

		// Use the dateFormat Lib to convert the date/time object to a CS Date string
		if ( jQuery.trim(jsDateObj).length )
			csDate=dateFormat(jsDateObj, "yyyy-mm-dd HH:MM:ss");

		// Set the value to the hidden field to be stored
		jQuery("input[name=#arguments.fieldName#]").val(csDate);
	});
	
	<cfif inputParameters.fldClearDate EQ 'yes'>
	jQuery('###arguments.fieldName#_cleardate').click(function() {
		jQuery("input[name=#arguments.fieldName#_picker]").val('');
		jQuery("input[name=#arguments.fieldName#]").val('');
	});
	</cfif>
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
			inputParameters.displayType = "UIdatepicker";
		if ( NOT StructKeyExists(inputParameters, "fldIcon") OR LEN(inputParameters.fldIcon) LTE 0 )
			inputParameters.fldIcon = "none";
		if ( NOT StructKeyExists(inputParameters, "fldClearDate") OR LEN(inputParameters.fldClearDate) LTE 0 )
			inputParameters.fldClearDate = "no";
		if ( NOT StructKeyExists(inputParameters, "fldIconImg") OR LEN(inputParameters.fldIconImg) LTE 0 )
			inputParameters.fldIconImg = "/ADF/extensions/customfields/date_picker/ui_calendar.gif";
		
		if ( NOT StructKeyExists(inputParameters, "standardizedTimeType") OR LEN(inputParameters.standardizedTimeType) LTE 0 )
			inputParameters.standardizedTimeType = "start";
		// Default: for start dates: 00:00:00 - Option: for end dates use: 23:59:59	
		if ( NOT StructKeyExists(inputParameters, "standardizedTimeStr") OR LEN(inputParameters.standardizedTimeStr) LTE 0 )
			inputParameters.standardizedTimeStr = "00:00:00";	
		if ( NOT StructKeyExists(inputParameters, "jsDateMask") OR LEN(inputParameters.jsDateMask) LTE 0 )
			inputParameters.jsDateMask = "m/d/yy";
		if ( NOT StructKeyExists(inputParameters, "cfDateMask") OR LEN(inputParameters.cfDateMask) LTE 0 )
			inputParameters.cfDateMask = "M/D/YYYY";
			
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
		return "";
	}
	
	private string function getValidationMsg()
	{
		return "Please select a value for the #arguments.label# field.";
	}
	
	private boolean function isMultiline()
	{
		return structKeyExists(arguments.parameters, "fldClearDate") && arguments.parameters.fldClearDate == "yes";
	}

	public string function getResourceDependencies()
	{
		return listAppend(super.getResourceDependencies(), "jQuery,jQueryUI,DateJS,DateFormat,JQueryDatePick");
	}
</cfscript>

</cfcomponent>