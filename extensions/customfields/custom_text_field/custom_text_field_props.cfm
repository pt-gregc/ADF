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
	M. Carroll 
Custom Field Type:
	Custom Text Field
Name:
	custom_text_field_props.cfm
Summary:
	Custom text field to specify a field ID and action property set to allow one edit, 
		then the field is read only.
ADF Requirements:
	data_1_0
History:
	2009-07-06 - MFC - Created
	2010-11-29 - MFC - Removed typo in the script tag.
	2011-02-08 - MFC - Changed the field Name prop to have the title "Field ID".
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2014-09-19 - GAC - Removed deprecated doLabel and jsLabelUpdater js calls
	2014-01-09 - GAC - Updated a typo in the Edit Once props description
	2015-05-12 - DJM - Updated the field version to 2.0
	2015-09-02 - DRM - Add getResourceDependencies support, bump version
	2016-02-22 - GAC - Added getResourceDependencies and loadResourceDependencies support to the Render
			     		  - Added the getResources check to the Props
			     		  - Bumped field version
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<!--- // if this module loads resources, do it here.. --->
<!---<cfscript>
    // No resources to load
</cfscript>--->

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
	if( not structKeyExists(currentValues, "fldClass") )
		currentValues.fldClass = "";
	if( not structKeyExists(currentValues, "fldName") )
		currentValues.fldName = "";
	if( not structKeyExists(currentValues, "fldSize") )
		currentValues.fldSize = "40";
	if( not structKeyExists(currentValues, "editOnce") )
		currentValues.editOnce = 0;
	if ( not structKeyExists(attributes.currentValues, 'useUdef') )
		attributes.currentValues.useUdef = 0;
</cfscript>
<cfparam name="currentValues.useUDef" default="0">
<cfparam name="currentValues.defaultValue" default="">
<cfoutput>
	<script type="text/javascript">
		fieldProperties['#typeid#'].paramFields = "#prefix#fldName,#prefix#fldClass,#prefix#fldSize,#prefix#editOnce,#prefix#useUdef,#prefix#currentDefault";
		fieldProperties['#typeid#'].defaultValueField = '#prefix#defaultValue';
		// allows this field to have a common onSubmit Validator
		//fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
		
		/* function #prefix#doValidate()
		{
			if( jQuery("###prefix#checkedVal").attr("value").length == 0 )
			{
				alert('Please enter a valid Checked value for the checkbox');
				jQuery("###prefix#checkedVal").focus();
				return false;
			}
			return true;
		} */
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelBold">Field ID:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#fldName" id="#prefix#fldName" class="cs_dlgControl" value="#currentValues.fldName#" size="40">
				<br/><span>Please enter the field ID to be used via JavaScript.  If blank, will use default field name.</span>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold">Class Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#fldClass" id="#prefix#fldClass" class="cs_dlgControl" value="#currentValues.fldClass#" size="40">
				<br/><span>Please enter a class name to be used via JavaScript or CSS.  If blank, a class attribute will not be added.</span>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold">Field Size:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#fldSize" id="#prefix#fldSize" class="cs_dlgControl" value="#currentValues.fldSize#" size="40">
				<br/><span>Enter a display size for this field.</span>
			</td>
		</tr>
			<cfinclude template="/commonspot/metadata/form_control/input_control/default_value.cfm">
		<tr>
			<td colspan="2" class="cs_dlgLabelSmall">
				<strong>Action Properties:</strong>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold">Edit Once:</td>
			<td class="cs_dlgLabelSmall">
				<input type="radio" name="#prefix#editOnce" id="#prefix#editOnce" value="0" <cfif currentValues.editOnce EQ 0>checked</cfif>>False
				<input type="radio" name="#prefix#editOnce" id="#prefix#editOnce" value="1" <cfif currentValues.editOnce EQ 1>checked</cfif>>True
				<br/><span>Select True to allow the field to only be edited once on creation of the record.  
					This will lock the value in and make the field disabled.</span>
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