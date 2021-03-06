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
	G. Cronkright 
Custom Field Type:
	Time Picker Field
Name:
	time_picker_props.cfm
Summary:
	Time picker field to set pick a time from a jquery style time picker
ADF Requirements:
	scripts_1_0
History:
	2013-02-06 - GAC - Created
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2014-09-19 - GAC - Removed deprecated doLabel and jsLabelUpdater js calls
	2015-05-20 - DJM - Modified the fieldVersion variable to be 2.0
	2015-09-02 - DRM - Add getResourceDependencies support, bump version
	2016-02-16 - GAC - Added getResourceDependencies and loadResourceDependencies support to the Render
					 - Added the getResources check to the Props
			     	 - Bumped field version
					 - Fixed a doValidate() issue with a jQuery attribute
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<!--- // load resources here --->
<cfscript>
	// Load the jQuery Header
	application.ADF.scripts.loadJQuery(noConflict=true);
</cfscript>

<!--- ... then exit if all we're doing is detecting required resources --->
<cfif Request.RenderState.RenderMode EQ "getResources">
  <cfexit>
</cfif>

<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "2.0.4";
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	
	// START - Build Date/Time picker type list
	pickerArray = ArrayNew(1);
	
	pickerType = StructNew();
	pickerType.displayName = "UI Timepicker Addon";
	pickerType.name = "UItimepickerAddon";
	arrayAppend(pickerArray,pickerType);
	
	pickerType = StructNew();
	pickerType.displayName = "UI Timepicker FG";
	pickerType.name = "UItimepickerFG";
	arrayAppend(pickerArray,pickerType);
	// END - Build Date/Time picker type list
		
	// Setup the default values
	defaultValues = StructNew();
	defaultValues.fldID = "";
	
	defaultValues.uiTheme = "ui-lightness";
	defaultValues.displayType = pickerArray[1].name;
	defaultValues.fldIcon = "none"; //option: clock
	defaultValues.fldIconImg = "/ADF/extensions/customfields/time_picker/clock.png";
	
	defaultValues.standardizedDateStr = "1900-01-01";
	defaultValues.jsTimeMask = "h:mm TT";	
	defaultValues.cfTimeMask = "h:mm tt";
	
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
				OR (NOT StructKeyExists(currentValues, defaultValueArray[i])) )
		{
			currentValues[defaultValueArray[i]] = defaultValues[defaultValueArray[i]];
		}
	}
</cfscript>

<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object
		fieldProperties['#typeid#'].paramFields = '#prefix#fldID,#prefix#displayType,#prefix#jsTimeMask,#prefix#uiTheme,#prefix#fldIcon,#prefix#fldIconImg,#prefix#standardizedDateStr,#prefix#cfTimeMask,#prefix#appBeanName,#prefix#appPropsVarName';
		// allows this field to have a common onSubmit Validator
		fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';

		function #prefix#doValidate()
		{
			if( jQuery("###prefix#displayType").val().length == 0 )
			{
				alert('Please select a time picker');
				jQuery("###prefix#displayType").focus();
				return false;
			}
			return true;
		}	
	</script>

	<table>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Field ID:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#fldID" id="#prefix#fldID" class="cs_dlgControl" value="#currentValues.fldID#" size="40">
				<br/><span>Please enter the field ID to be used via JavaScript.  If blank, will use default CS field name.</span>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" colspan="2"><hr></td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" colspan="2"><strong>Field Configuration Settings:</strong></td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Display Type:</td>
			<td class="cs_dlgLabelSmall">
				<!--- <input type="text" name="#prefix#displayType" id="#prefix#displayType" class="cs_dlgControl" value="#currentValues.displayType#" size="40"> --->
				<select name="#prefix#displayType" id="#prefix#displayType" class="cs_dlgControl">
					<option value="">-SELECT-</option>
				<cfloop from="1" to="#ArrayLen(pickerArray)#" index="p">
					<option value="#pickerArray[p].name#"<cfif currentValues.displayType EQ pickerArray[p].name> selected="selected"</cfif>>#pickerArray[p].displayName#</option>
				</cfloop>	
				</select>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">UI Theme:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#uiTheme" id="#prefix#uiTheme" class="cs_dlgControl" value="#currentValues.uiTheme#" size="40">
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">JS Display Format:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#jsTimeMask" id="#prefix#jsTimeMask" class="cs_dlgControl" value="#currentValues.jsTimeMask#" size="40">
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">CF Display Format:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#cfTimeMask" id="#prefix#cfTimeMask" class="cs_dlgControl" value="#currentValues.cfTimeMask#" size="40">
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Standardized Date:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#standardizedDateStr" id="#prefix#standardizedDateStr" class="cs_dlgControl" value="#currentValues.standardizedDateStr#" size="40">
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Show Icon next to Field:</td>
			<td class="cs_dlgLabelSmall">
				<input type="radio" name="#prefix#fldIcon" id="#prefix#fldIcon_none" value="none" <cfif currentValues.fldIcon eq 'none'>checked</cfif>>
				<label for="#prefix#fldIcon_none">
				None
				</label>
				&nbsp;&nbsp;
				<input type="radio" name="#prefix#fldIcon" id="#prefix#fldIcon_clock" value="clock" <cfif currentValues.fldIcon eq 'clock'>checked</cfif>>
				<label for="#prefix#fldIcon_clock">
					<img class="ui-timepicker-trigger" id="#prefix#fldIcon_timeIMG" src="#currentValues.fldIconImg#" alt="Clock" title="Set a Time...">
				</label>
				<input type="hidden" name="#prefix#fldIconImg" id="#prefix#fldIconImg" value="#currentValues.fldIconImg#">
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
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">App Bean Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#appBeanName" id="#prefix#appBeanName" class="cs_dlgControl" value="#currentValues.appBeanName#" size="40">
				<br/><span>Please enter the ADF Applications's AppName to override these configuration settings.</span>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">App Props Variable Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#appPropsVarName" id="#prefix#appPropsVarName" class="cs_dlgControl" value="#currentValues.appPropsVarName#" size="40">
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