<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2013.
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
	time_picker_render.cfm
Summary:
	Time picker field to set pick a time from a jquery style time picker
ADF Requirements:
	scripts_1_0
History:
	2013-02-06 - GAC - Created
--->
<cfscript>	
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	// Pass new date URL variable through to the Calendar Picker
	if ( StructKeyExists(request.params,"newSelectedTime") )
		currentValue = request.params.newSelectedTime;
	
	// Validate if the property field has been defined
	if ( NOT StructKeyExists(xparams, "fldID") OR LEN(xparams.fldID) LTE 0 )
		xparams.fldID = TRIM(fqFieldName);
	else 
		xparams.fldID = TRIM(xparams.fldID);
	
	if ( NOT StructKeyExists(xparams, "uiTheme") OR LEN(xparams.uiTheme) LTE 0 )
		xparams.uiTheme = "redmond";
	
	if ( NOT StructKeyExists(xparams, "displayType") OR LEN(xparams.displayType) LTE 0 )
		xparams.displayType = "UItimepickerAddon";	
	if ( NOT StructKeyExists(xparams, "fldIcon") OR LEN(xparams.fldIcon) LTE 0 )
		xparams.fldIcon = "none";
	if ( NOT StructKeyExists(xparams, "fldIconImg") OR LEN(xparams.fldIconImg) LTE 0 )
		xparams.fldIconImg = "/ADF/extensions/customfields/time_picker/clock.png";

	if ( NOT StructKeyExists(xparams, "standardizedDateStr") OR LEN(xparams.standardizedDateStr) LTE 0 )
		xparams.standardizedDateStr = "1900-01-01";			
	if ( NOT StructKeyExists(xparams, "cfTimeMask") OR LEN(xparams.cfTimeMask) LTE 0 )
		xparams.cfTimeMask = "h:mm tt";	
	if ( NOT StructKeyExists(xparams, "jsTimeMask") OR LEN(xparams.jsTimeMask) LTE 0 )
		xparams.jsTimeMask = "";
		
	//-- App Override Variables --//
	if ( NOT StructKeyExists(xparams, "appBeanName") OR LEN(xparams.appBeanName) LTE 0 )
		xparams.appBeanName = "";
	if ( NOT StructKeyExists(xparams, "appPropsVarName") OR LEN(xparams.appPropsVarName) LTE 0 )
		xparams.appPropsVarName = "";

	// XPARAMS fields that cannot be overridden by the App
	xparamsExceptionsList = "fldID,appBeanName,appPropsVarName";

	// Optional ADF App Override for the Custom Field Type XPARAMS
	If ( LEN(TRIM(xparams.appBeanName)) AND LEN(TRIM(xparams.appPropsVarName)) ) {
		xparams = application.ADF.utils.appOverrideCSParams(
													csParams=xparams,
													appName=xparams.appBeanName,
													appParamsVarName=xparams.appPropsVarName,
													paramsExceptionList=xparamsExceptionsList
												);
	}

	displayValue = "";
	if ( LEN(TRIM(currentValue)) ) {
		// Fix bad or incorrect date/time entries stored
		currentValue = application.ADF.date.csDateFormat(currentValue,currentValue);
		// Strip the standardizedDateStr from the currentValue and do a TimeFormat for Display 
		displayValue = TimeFormat(TRIM(REPLACE(currentValue,xparams.standardizedDateStr,"","all")),xparams.cfTimeMask);
	}
		
	// Set Default Icon Options 
	useClockIcon = false;
	if ( xparams.fldIcon EQ "clock")
		useClockIcon = true;

	// jQuery Headers
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQueryUI(themeName=xparams.uiTheme);
	// Load the DateJS Plugin Headers
	application.ADF.scripts.loadDateJS();
	// Load the DateFormat Plugin Headers
	application.ADF.scripts.loadDateFormat();

	if ( xparams.displayType IS "UItimepickerAddon" ) {
		application.ADF.scripts.loadJQueryUITimepickerAddon();
		if ( LEN(TRIM(xparams.jsTimeMask)) EQ 0  )
			xparams.jsTimeMask = "h:mm TT"; 
	}
	else if ( xparams.displayType IS "UItimepickerFG" ) {
		application.ADF.scripts.loadJQueryUITimepickerFG();
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
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
		#fqFieldName#.msg="Please select a value for the #xparams.label# field.";
		#fqFieldName#.validator = "validate_#fqFieldName#()";

		//If the field is required
		if ( '#xparams.req#' == 'Yes' ){
			// push on to validation array
			vobjects_#attributes.formname#.push(#fqFieldName#);
		}

		//Validation function
		function validate_#fqFieldName#(){
			if (jQuery("input[name=#fqFieldName#]").val() != ''){
				return true;
			}else{
				return false;
			}
		}
		
		jQuery(function() {
			
		<cfif xparams.displayType EQ "UItimepickerAddon">
			// jQueryUI TimePicker Addon 
			// http://trentrichardson.com/examples/timepicker/	
			
			// jQueryUI TimePicker Addon Options
			var timePickerAddonOptions_#fqFieldName# = {
						ampm: true
						,timeFormat: '#xparams.jsTimeMask#'
						,hourGrid: 6
						,minuteGrid: 15
					};	
			
			// Calendar Picker Fields
			jQuery("###xparams.fldID#_picker").timepicker( timePickerAddonOptions_#fqFieldName# );
			
		<cfelseif xparams.displayType EQ "UItimepickerFG">
			// jQuery UI Timepicker (By François Gélinas)
			// http://fgelinas.com/code/timepicker/
			
			// jQueryUI TimePicker Addon Options
			var timePickerFGOptions_#fqFieldName# = {
						showPeriod: true
			       		,minutes: { interval: 5 }
			       		,showLeadingZero: false
			       		,button : null
			       		//,showOn : 'both' //button
			       		//,button : '.ui-timepicker-trigger'
					};	
			
			// jQuery UI Timepicker FG field
			jQuery("###xparams.fldID#_picker").timepicker( timePickerFGOptions_#fqFieldName# );
			
		</cfif>
		
			// Set the Clock or the Calendar Image to activate the Date/Time picker flyout 
		<cfif useClockIcon>
			jQuery("###xparams.fldID#_timeIMG").click(function(){
				jQuery("###xparams.fldID#_picker").focus();					
			});
		</cfif>
		
			// Onchange populate the Hidden field that stores the data
			jQuery("###xparams.fldID#_picker").change(function(){	
				var timeStr = jQuery("###xparams.fldID#_picker").val();
				var dateStr = '#xparams.standardizedDateStr#';
				
				var csDate = "";
				var jsDateObj = "";
				
				// Use DateJS lib to parse the concatenated date/time into a date/time object
				if ( jQuery.trim(dateStr).length && jQuery.trim(timeStr).length )
					jsDateObj = Date.parse(dateStr + " " + timeStr);

				// Use the dateFormat Lib to convert the date/time object to a CS Date string
				if ( jQuery.trim(jsDateObj).length )
					csDate=dateFormat(jsDateObj, "yyyy-mm-dd HH:MM:00");
					
				// Set the value to the hidden field to be stored
				jQuery("input[name=#fqFieldName#]").val(csDate);
			});
		
		});
	</script>

	<cfsavecontent variable="inputHTML">
		<cfoutput>
			<div>
				<input type="text" name="#fqFieldName#_picker" id="#xparams.fldID#_picker" value="#displayValue#" autocomplete="off"<cfif readOnly> disabled="disabled"</cfif>>
				<cfif useClockIcon>
					<img class="ui-timepicker-trigger" id="#xparams.fldID#_timeIMG" src="#xparams.fldIconImg#" alt="time picker" title="Set a Time...">
				</cfif>
				<!--- hidden field to store the value --->
				<input type='hidden' name='#fqFieldName#' id='#xparams.fldID#' value='#currentValue#'>
				<!--- <input type='text' name='#fqFieldName#_dtObject' id='#xparams.fldID#_dtObject' value=''> --->
			</div>
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