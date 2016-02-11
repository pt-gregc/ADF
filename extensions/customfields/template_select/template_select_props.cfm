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
	Template Select
Name:
	template_select_props.cfm
Summary:
	Custom field type to select from the CS templates
ADF Requirements:
	scripts_1_0
History:
	2007-01-24 - RLW - Created
	2011-10-22 - MFC - Set the default selected value to be stored when loading the CFT.
	2013-03-12 - GAC - Updated to allow a list of template name or template page ids to be added to exclude
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2014-09-19 - GAC - Removed deprecated doLabel and jsLabelUpdater js calls
	2014-10-31 - GAC - Added the editOnce option
	2015-05-12 - DJM - Updated the field version to 2.0
	2015-09-02 - DRM - Add getResourceDependencies support, bump version
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "2.0.6";
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	
	// Setup the default values
	defaultValues.filterList = "";
	defaultValues.editOnce = 0;
	
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
</cfscript>

<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object
		fieldProperties['#typeid#'].paramFields = '#prefix#filterList,#prefix#editOnce,#prefix#appBeanName,#prefix#appPropsVarName';
		// allows this field to have a common onSubmit Validator
		//fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';

	/*	function #prefix#doValidate()
		{
			//set the default msgvalue
			document.#formname#.#prefix#msg.value = 'Please enter some text to be converted';
			if( document.#formname#.#prefix#foo.value.length == 0 )
			{
				alert('please Enter some data for foo');
				return false;
			}
			return true;
		}
	*/
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelSmall" valign="top">Template Filter List:</td>
			<td class="cs_dlgLabelSmall">
				<textarea type="text" name="#prefix#filterList" id="#prefix#filterList" class="cs_dlgControl" rows="3" cols="60" wrap="soft">#currentValues.filterList#</textarea>
				<br/><span>(Comma-Delimited list of Templates Names OR Template Page IDs to exclude. Using a part of a Template Name excludes all templates that contain that part in the name.)</span>
			</td>
		</tr>
		<tr>
			<td colspan="2" class="cs_dlgLabelSmall">
				<strong>Action Properties:</strong>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Edit Once:</td>
			<td class="cs_dlgLabelSmall">
				<input type="radio" name="#prefix#editOnce" id="#prefix#editOnce" value="0" <cfif currentValues.editOnce EQ 0>checked</cfif>>False
				<input type="radio" name="#prefix#editOnce" id="#prefix#editOnce" value="1" <cfif currentValues.editOnce EQ 1>checked</cfif>>True
				<br/><span>Select the True to allow the field to only be edited once on creation of the record.  
					This will lock the value in and make the field disabled.</span>
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
				<input type="text" name="#prefix#appBeanName" id="#prefix#appBeanName" class="cs_dlgControl" value="#currentValues.appBeanName#" size="40">
				<br/><span>Please enter the ADF Applications's AppName to override these configuration settings.</span>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" valign="top">App Props Variable Name:</td>
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