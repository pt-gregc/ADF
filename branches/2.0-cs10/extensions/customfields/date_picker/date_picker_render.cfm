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
	date_picker_render.cfm
Summary:
	A custom checkbox field that is used to select dates within the Calendar App
ADF Requirements:
	date_1_0
	scripts_1_0
History:
	2013-02-12 - GAC - Created
--->
<cfscript>		
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	// Pass new date URL variable through to the Calendar Picker
	if ( StructKeyExists(request.params,"newSelectedDate") )
		currentValue = request.params.newSelectedDate;
	
	// Validate if the property field has been defined
	if ( NOT StructKeyExists(xparams, "fldID") OR LEN(xparams.fldID) LTE 0 )
		xparams.fldID = TRIM(fqFieldName);
	else 
		xparams.fldID = TRIM(xparams.fldID);
	
	if ( NOT StructKeyExists(xparams, "uiTheme") OR LEN(xparams.uiTheme) LTE 0 )
		xparams.uiTheme = "redmond";
		
	if ( NOT StructKeyExists(xparams, "displayType") OR LEN(xparams.displayType) LTE 0 )
		xparams.displayType = "UIdatepicker";
	if ( NOT StructKeyExists(xparams, "fldIcon") OR LEN(xparams.fldIcon) LTE 0 )
		xparams.fldIcon = "none";
	if ( NOT StructKeyExists(xparams, "fldClearDate") OR LEN(xparams.fldClearDate) LTE 0 )
		xparams.fldClearDate = "no";
	if ( NOT StructKeyExists(xparams, "fldIconImg") OR LEN(xparams.fldIconImg) LTE 0 )
		xparams.fldIconImg = "/ADF/extensions/customfields/date_picker/ui_calendar.gif";
	
	if ( NOT StructKeyExists(xparams, "standardizedTimeType") OR LEN(xparams.standardizedTimeType) LTE 0 )
		xparams.standardizedTimeType = "start";
	// Default: for start dates: 00:00:00 - Option: for end dates use: 23:59:59	
	if ( NOT StructKeyExists(xparams, "standardizedTimeStr") OR LEN(xparams.standardizedTimeStr) LTE 0 )
		xparams.standardizedTimeStr = "00:00:00";	
	if ( NOT StructKeyExists(xparams, "jsDateMask") OR LEN(xparams.jsDateMask) LTE 0 )
		xparams.jsDateMask = "m/d/yy";
	if ( NOT StructKeyExists(xparams, "cfDateMask") OR LEN(xparams.cfDateMask) LTE 0 )
		xparams.cfDateMask = "M/D/YYYY";
		
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
	if ( LEN(TRIM(currentValue)) ){
		// Fix bad or incorrect date/time entries
		currentValue = application.ADF.date.csDateFormat(currentValue,currentValue);
		// Strip the standardizedTimeStr from the currentValue and do a DateForamt for Display
		displayValue = DateFormat(TRIM(REPLACE(currentValue,xparams.standardizedTimeStr,"","all")),xparams.cfDateMask);
	}
	
	// Set Default Icon Options 
	useCalendarIcon = false;
	if ( xparams.fldIcon EQ "calendar")
		useCalendarIcon = true;	
	
	// jQuery Headers
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQueryUI(themeName=xparams.uiTheme);
	// Load the DateJS Plugin Headers
	application.ADF.scripts.loadDateJS();
	// Load the DateFormat Plugin Headers
	application.ADF.scripts.loadDateFormat();

	if ( xparams.displayType EQ "datepick" ) {
		application.ADF.scripts.loadJQueryDatePick();
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

		<cfif xparams.displayType EQ "UIdatepicker">
			// jQueryUI Date Picker
			// http://jqueryui.com/demos/datepicker/
			
			// jQueryUI Date Picker Options
			var datePickerOptions_#fqFieldName# = {
					changeMonth : true
					,changeYear : true
					,showButtonPanel : true
					,constrainInput : false 
					,dateFormat : '#xparams.jsDateMask#'
					,zIndex:9999
					<cfif useCalendarIcon>
					,showOn : "both" //button
					,buttonImage : "#xparams.fldIconImg#"
					,buttonImageOnly : true
					,buttonText : 'Choose a Date...'
					<cfelse>
					,showOn : "focus" 
					</cfif>
				};
				
			// Calendar Picker Fields
			jQuery("###xparams.fldID#_picker").datepicker( datePickerOptions_#fqFieldName# );
			
			// Set the offset to help with displaying inside an lightbox
			jQuery.extend(jQuery.datepicker,{_checkOffset:function(inst,offset,isFixed){offset.top=40; offset.left=200; return offset;}});
			
			<!--- // Now set the useCalendarIcon variable to false since the plugin js handles rendering it --->
			<cfset useCalendarIcon = false>
			
		<cfelseif xparams.displayType EQ "datepick">
			// jQuery datepick 
			// http://keith-wood.name/datepick.html
			
			// jQuery datepick field
			jQuery('###xparams.fldID#_picker').datepick();

		</cfif>
		
			// Set the Clock or the Calendar Image to activate the Date/Time picker flyout 
		<cfif useCalendarIcon>
			jQuery("###xparams.fldID#_dateIMG").click(function(){
				jQuery("###xparams.fldID#_picker").focus();				
			});
		</cfif>
		
			// Onchange populate the Hidden field that stores the data
			jQuery("###xparams.fldID#_picker").change(function(){	
				var dateStr = jQuery("###xparams.fldID#_picker").val();
				// Get the Standard/Dummy Time 
				var timeStr = '#xparams.standardizedTimeStr#';
				
				var csDate = "";
				var jsDateObj = "";
				
				// Use DateJS lib to parse the concatenated date/time into a date/time object
				if ( jQuery.trim(dateStr).length && jQuery.trim(timeStr).length )
					jsDateObj = Date.parse(dateStr + " " + timeStr);

				// Use the dateFormat Lib to convert the date/time object to a CS Date string
				if ( jQuery.trim(jsDateObj).length )
					csDate=dateFormat(jsDateObj, "yyyy-mm-dd HH:MM:ss");

				// Set the value to the hidden field to be stored
				jQuery("input[name=#fqFieldName#]").val(csDate);
			});
			
			<cfif xparams.fldClearDate EQ 'yes'>
			jQuery('###fqFieldName#_cleardate').click(function() {
				jQuery("input[name=#fqFieldName#_picker]").val('');
				jQuery("input[name=#fqFieldName#]").val('');
			});
			</cfif>
		});
	</script>
	
	<cfif xparams.fldClearDate EQ 'yes'>
	<style>
		.#fqFieldName#_smalllink{
			font-size: 9px;
		}
	</style>
	</cfif>
	
	<cfsavecontent variable="inputHTML">
		<cfoutput>
			<div>
				<input type="text" name="#fqFieldName#_picker" id="#xparams.fldID#_picker" value="#displayValue#" autocomplete="off"<cfif readOnly> disabled="disabled"</cfif>>
				<cfif useCalendarIcon>
					<img class="ui-datepicker-trigger" id="#xparams.fldID#_dateIMG" src="#xparams.fldIconImg#" alt="calendar" title="Select a Date...">
				</cfif>
				<!--- hidden field to store the value --->
				<input type='hidden' name='#fqFieldName#' id='#xparams.fldID#' value='#currentValue#'>
				<!--- <input type='text' name='#fqFieldName#_dtObject' id='#xparams.fldID#_dtObject' value=''> --->
			</div>
			<cfif xparams.fldClearDate EQ 'yes'>
			<div>
				<a href="javascript:;" id="#fqFieldName#_cleardate" class="#fqFieldName#_smalllink">Clear Date</a>
			</div>
			</cfif>
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