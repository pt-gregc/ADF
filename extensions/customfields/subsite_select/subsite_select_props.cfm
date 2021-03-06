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
	subsite_select_props.cfm
Summary:
	Custom field type, that allows a new subsite to be created
ADF Requirements:
	none
History:
	2007-01-24 - RLW - Created
	2012-02-13 - GAC - Updated to use accept a filter porperty and a uitheme propery 
					 - Also added the appBeanName and appPropsVarName props to allow porps to be overridden by an app												
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2014-09-19 - GAC - Removed deprecated doLabel and jsLabelUpdater js calls
	2015-05-12 - DJM - Updated the field version to 2.0
	2015-09-02 - DRM - Add getResourceDependencies support, bump version
	2016-02-16 - GAC - Added getResourceDependencies and loadResourceDependencies support to the Render
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
	
	// Setup the default values
	defaultValues = StructNew();
	defaultValues.allowSubsiteAdd = "no";
	defaultValues.uiTheme = "ui-lightness";
	defaultValues.filterList = "";
	
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
	<script type="text/javascript">
		// this establishes that we have a parameter
		fieldProperties['#typeid#'].paramFields = "#prefix#allowSubsiteAdd,#prefix#uiTheme,#prefix#filterList,#prefix#appBeanName,#prefix#appPropsVarName";
	</script>
	<table>
		<input type="hidden" name="#prefix#allowSubsiteAdd" id="#prefix#allowSubsiteAdd" value="#currentValues.allowSubsiteAdd#">
		<!--- // TODO: future enhancement --->
		<!--- <tr>
			<td class="cs_DlgLabel">Allow Subsite Add</td>
			<td class="cs_DlgLabel">
				<select name="#prefix#allowSubsiteAdd" id="#prefix#allowSubsiteAdd" size="1">
					<option value="Yes"<cfif currentValues.allowSubsiteAdd eq "Yes"> selected="selected"</cfif>>Yes</option>
					<option value="No"<cfif currentValues.allowSubsiteAdd eq "No"> selected="selected"</cfif>>No</option>
				</select>
			</td>
		</tr> --->
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">UI Theme:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#uiTheme" id="#prefix#uiTheme" class="cs_dlgControl" value="#currentValues.uiTheme#" size="40">
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Subsite Name Filter List:</td>
			<td class="cs_dlgLabelSmall">
				<!--- <input type="text" name="#prefix#filterList" id="#prefix#filterList" class="cs_dlgControl" value="#currentValues.filterList#" size="40"> --->
				<textarea type="text" name="#prefix#filterList" id="#prefix#filterList" class="cs_dlgControl" rows="3" cols="60" wrap="soft">#currentValues.filterList#</textarea>
				<br/><span>(Comma-Delimited list of Subsite Names OR SubsiteIDs to exclude. Using Subsite Names excludes the any child subsites.)</span>
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