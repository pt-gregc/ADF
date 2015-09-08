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
	date_picker_props.cfm
Summary:
	A custom checkbox field that is used to select dates
ADF Requirements:
	date_1_0
	scripts_1_0
History:
	2013-02-12 - GAC - Created
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2014-09-19 - GAC - Removed deprecated doLabel and jsLabelUpdater js calls
	2015-05-14 - DJM - Updated the field version to 2.0
	2015-09-02 - DRM - Add getResourceDependencies support, bump version
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "2.0.1";
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	
	// START - Build Date picker type list
	pickerArray = ArrayNew(1);
	
	pickerType = StructNew();
	pickerType.displayName = "jQueryUI datepicker";
	pickerType.name = "UIdatepicker";
	arrayAppend(pickerArray,pickerType);
	
	pickerType = StructNew();
	pickerType.displayName = "datepick";
	pickerType.name = "datepick";
	arrayAppend(pickerArray,pickerType);
	// END - Build Date picker type list
	
	// START - Build Date Field Time Type Options
	standardizedTimeOption = StructNew();
	standardizedTimeOption['start'] = "00:00:00";
	standardizedTimeOption['end'] = "23:59:59";
	standardizedTimeOption['now'] = "{current-time}";
	standardizedTimeOption['other'] = "";
	// END - Build Date Field Time Type Options
	
	// Setup the default values
	defaultValues = StructNew();
	defaultValues.fldID = "";
	
	defaultValues.uiTheme = "redmond";
	defaultValues.displayType = pickerArray[1].name;
	defaultValues.fldIcon = "none"; //option: calendar
	defaultValues.fldClearDate = 'no';
	defaultValues.fldIconImg = "/ADF/extensions/customfields/date_picker/ui_calendar.gif";
	
	defaultValues.standardizedTimeType = "start";
	defaultValues.standardizedTimeStr = standardizedTimeOption[defaultValues.standardizedTimeType]; // Default is for start dates: 00:00:00 - For end dates use: 23:59:59	
	defaultValues.jsDateMask = "m/d/yy";	
	defaultValues.cfDateMask = "M/D/YYYY";
	
	//-- App Override Variables --//
	defaultValues.appBeanName = "";
	defaultValues.appPropsVarName = "";

	// This will override the current values with the default values.
	// In normal use this should not need to be modified.
	defaultValueArray = StructKeyArray(defaultValues);
	for(i=1;i<=ArrayLen(defaultValueArray);i++){
		// If there is a default value to exists in the current values
		//	AND the current value is an empty string
		//	OR the default value does not exist in the current values
		if( ( StructKeyExists(currentValues, defaultValueArray[i]) 
				AND (NOT LEN(currentValues[defaultValueArray[i]])) )
				OR (NOT StructKeyExists(currentValues, defaultValueArray[i])) ){
			currentValues[defaultValueArray[i]] = defaultValues[defaultValueArray[i]];
		}
	}

	// Load the jQuery Header 
	application.ADF.scripts.loadJQuery(noConflict=true);
</cfscript>

<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object
		fieldProperties['#typeid#'].paramFields = '#prefix#fldID,#prefix#displayType,#prefix#cfDateMask,#prefix#jsDateMask,#prefix#standardizedTimeStr,#prefix#standardizedTimeType,#prefix#uiTheme,#prefix#fldIcon,#prefix#fldIconImg,#prefix#fldClearDate,#prefix#appBeanName,#prefix#appPropsVarName';
		// allows this field to have a common onSubmit Validator
		fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';

		function #prefix#doValidate()
		{
			if( jQuery("###prefix#displayType").attr("value").length == 0 )
			{
				alert('Please select a date picker');
				jQuery("###prefix#displayType").focus();
				return false;
			}
			return true;
		}	
		
		jQuery(function() {
			jQuery('input[name=#prefix#standardizedTimeType]').click(function() {
				var isChecked = this.checked;
				var thisValue = jQuery(this).val();
			    if ( isChecked && thisValue == 'start' )              
			        jQuery('###prefix#standardizedTimeStr').val('#standardizedTimeOption["start"]#');
			    else if ( isChecked && thisValue == 'end' )              
			        jQuery('###prefix#standardizedTimeStr').val('#standardizedTimeOption["end"]#');
			    else if ( isChecked && thisValue == 'now' )              
			        jQuery('###prefix#standardizedTimeStr').val('#standardizedTimeOption["now"]#');
			    else 
			        jQuery('###prefix#standardizedTimeStr').val('#standardizedTimeOption["other"]#'); 
			});
		});
	</script>

	<table>
		<tr>
			<td class="cs_dlgLabelSmall">Field ID:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#fldID" id="#prefix#fldID" class="cs_dlgControl" value="#currentValues.fldID#" size="60">
				<br><span>Please enter the field ID to be used via JavaScript.  If blank, will use default CS field name.</span>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" colspan="2"><hr></td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Display Type:</td>
			<td class="cs_dlgLabelSmall">
				<select name="#prefix#displayType" id="#prefix#displayType" class="cs_dlgControl">
					<option value="">-SELECT-</option>
				<cfloop from="1" to="#ArrayLen(pickerArray)#" index="p">
					<option value="#pickerArray[p].name#"<cfif currentValues.displayType EQ pickerArray[p].name> selected="selected"</cfif>>#pickerArray[p].displayName#</option>
				</cfloop>	
				</select>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">UI Theme:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#uiTheme" id="#prefix#uiTheme" class="cs_dlgControl" value="#currentValues.uiTheme#" size="60">
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">JS Display Format:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#jsDateMask" id="#prefix#jsDateMask" class="cs_dlgControl" value="#currentValues.jsDateMask#" size="60">
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">CF Display Format:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#cfDateMask" id="#prefix#cfDateMask" class="cs_dlgControl" value="#currentValues.cfDateMask#" size="60">
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Standardized Time Type:</td>
			<td class="cs_dlgLabelSmall">
				<input type="radio" name="#prefix#standardizedTimeType" id="#prefix#standardizedTimeType_start" value="start" <cfif currentValues.standardizedTimeType eq 'start'>checked</cfif>>
				<label for="#prefix#standardizedTimeType_start">
				Start of Day
				</label>
				&nbsp;&nbsp;
				<input type="radio" name="#prefix#standardizedTimeType" id="#prefix#standardizedTimeType_end" value="end" <cfif currentValues.standardizedTimeType eq 'end'>checked</cfif>>
				<label for="#prefix#standardizedTimeType_end">
				End of Day
				</label>
				<!--- &nbsp;&nbsp;
				<input type="radio" name="#prefix#standardizedTimeType" id="#prefix#standardizedTimeType_now" value="now" <cfif currentValues.standardizedTimeType eq 'now'>checked</cfif>>
				<label for="#prefix#standardizedTimeType_now">
				Current Time
				</label> --->
				&nbsp;&nbsp;
				<input type="radio" name="#prefix#standardizedTimeType" id="#prefix#standardizedTimeType_other" value="other" <cfif currentValues.standardizedTimeType eq 'other'>checked</cfif>>
				<label for="#prefix#standardizedTimeType_other">
				Other
				</label>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Standardized Time:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#standardizedTimeStr" id="#prefix#standardizedTimeStr" class="cs_dlgControl" value="#currentValues.standardizedTimeStr#" size="60">
				<br/><span>Since CS Date fields store a date/time string (YYYY-MM-DD HH:MM:SS) we generally want to capture the start of the day time '00:00:00' for Start Dates and capture end of the day time '23:59:59' for End Dates. But this value can be any valid time string.</span> 
			</td>
		</tr>
		
		<tr>
			<td class="cs_dlgLabelSmall">Show icon next to Field:</td>
			<td class="cs_dlgLabelSmall">
				<input type="radio" name="#prefix#fldIcon" id="#prefix#fldIcon_none" value="none" <cfif currentValues.fldIcon eq 'none'>checked</cfif>>
				<label for="#prefix#fldIcon_none">
				None
				</label>
				&nbsp;&nbsp;
				<input type="radio" name="#prefix#fldIcon" id="#prefix#fldIcon_calendar" value="calendar" <cfif currentValues.fldIcon eq 'calendar'>checked</cfif>>
				<label for="#prefix#fldIcon_calendar">
					<img class="ui-datepicker-trigger" id="#prefix#fldIcon_dateIMG" src="#currentValues.fldIconImg#" alt="calendar" title="Select a Date...">
				</label>
				<input type="hidden" name="#prefix#fldIconImg" id="#prefix#fldIconImg" value="#currentValues.fldIconImg#">
			</td>
		</tr>
		<tr>
		<td class="cs_dlgLabelSmall" valign="top">Show Clear Date Link:</td>
			<td class="cs_dlgLabelSmall">
			<input type="radio" name="#prefix#fldClearDate" id="#prefix#fldClearDate_yes" value="yes" <cfif currentValues.fldClearDate eq 'yes'>checked</cfif>><label for="#prefix#fldClearDate_yes">Yes</label>&nbsp;&nbsp;
			<input type="radio" name="#prefix#fldClearDate" id="#prefix#fldClearDate_no" value="no" <cfif currentValues.fldClearDate eq 'no'>checked</cfif>><label for="#prefix#fldClearDate_no">No</label>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" colspan="2"><hr></td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" colspan="2">
				<strong>Optional ADF App PROPS Override Settings:</strong>
				<br/><span>(IMPORTANT: If configured correctly these settings will override the entries above!)</span> 
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" valign="top">App Bean Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#appBeanName" id="#prefix#appBeanName" class="cs_dlgControl" value="#currentValues.appBeanName#" size="60">
				<br/><span>Please enter the ADF Applications's AppName to override these configuration settings.</span>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" valign="top">App Props Variable Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#appPropsVarName" id="#prefix#appPropsVarName" class="cs_dlgControl" value="#currentValues.appPropsVarName#" size="60">
				<br/><span>Please enter the App Props Variable name that contains PROPS keys and values to override.</span> 
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" colspan="2" style="font-size:7pt;">
				<hr />
				ADF Custom Field v#fieldVersion#
			</td>
		</tr>
	</table>
</cfoutput>