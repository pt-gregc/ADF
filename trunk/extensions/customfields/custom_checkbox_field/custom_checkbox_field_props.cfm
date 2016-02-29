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
	Michael Carroll 
Custom Field Type:
	Custom Checkbox Field
Name:
	custom_checkbox_field_props.cfm
Summary:
	Custom checkbox field to set the field name value, default field value, and field visibility.
ADF Requirements:
	ceData_1_0
	Data_1_0
	scripts_1_0
History:
	2009-07-06 - MFC - Created
	2011-05-26 - GAC - Modified - added a class parameter and updated the id attributes on the input field
	2011-07-19 - GAC - Modified - added a parameter to assign the stored value (ie. 1, Yes or True )
	2011-12-22 - GAC - Modified - added a call to the loadJQuery method in the scripts lib
	2011-12-28 - MFC - Force JQuery to "noconflict" mode to resolve issues with CS 6.2.
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2014-09-19 - GAC - Removed deprecated doLabel and jsLabelUpdater js calls
	2015-05-12 - DJM - Updated the field version to 2.0
	2015-09-02 - DRM - Add getResourceDependencies support, bump version
	2016-02-19 - DRM - Resource detection exit
							 Bump field version
	2016-02-22 - GAC - Updated field label class
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<!--- // if this module loads resources, do it here.. --->
<cfscript>
	application.ADF.scripts.loadJQuery(noConflict=true);
</cfscript>

<!--- ... then exit if all we're doing is detecting required resources --->
<cfif Request.RenderState.RenderMode EQ "getResources">
  <cfexit>
</cfif>


<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "2.0.5";
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	
	if( not structKeyExists(currentValues, "renderField") )
		currentValues.renderField = "yes";
	if( not structKeyExists(currentValues, "defaultVal") )
		currentValues.defaultVal = "no";
	if( not structKeyExists(currentValues, "checkedVal") )
		currentValues.checkedVal = "yes";
	if( not structKeyExists(currentValues, "uncheckedVal") )
		currentValues.uncheckedVal = "no";
	if( not structKeyExists(currentValues, "fldName") )
		currentValues.fldName = "";
	if( not structKeyExists(currentValues, "fldClass") )
		currentValues.fldClass = "";
</cfscript>

<cfoutput>
	<script type="text/javascript">
		fieldProperties['#typeid#'].paramFields = "#prefix#renderField,#prefix#defaultVal,#prefix#fldName,#prefix#fldClass,#prefix#checkedVal,#prefix#uncheckedVal";
		// allows this field to have a common onSubmit Validator
		fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
		
		function #prefix#doValidate()
		{
			if( jQuery("###prefix#checkedVal").attr("value").length == 0 )
			{
				alert('Please enter a valid Checked value for the checkbox');
				jQuery("###prefix#checkedVal").focus();
				return false;
			}
			return true;
		}
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Field ID:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#fldName" id="#prefix#fldName" value="#currentValues.fldName#" size="40">
				<br/><span>Please enter the field name to be used via JavaScript.  If blank, will use default name.</span>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Class Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#fldClass" id="#prefix#fldClass" class="cs_dlgControl" value="#currentValues.fldClass#" size="40">
				<br/><span>Please enter a class name to be used via JavaScript or CSS.  If blank, a class attribute will not be added.</span>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Field Display Type:</td>
			<td class="cs_dlgLabelSmall">
				<input type="radio" name="#prefix#renderField" id="#prefix#renderField" value="yes" <cfif currentValues.renderField eq 'yes'>checked</cfif>>Visible
				<input type="radio" name="#prefix#renderField" id="#prefix#renderField" value="no" <cfif currentValues.renderField eq 'no'>checked</cfif>>Hidden
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Default Field Value:</td>
			<td class="cs_dlgLabelSmall">
				<input type="radio" name="#prefix#defaultVal" id="#prefix#defaultVal" value="yes" <cfif currentValues.defaultVal eq 'yes'>checked</cfif>>Checked
				<input type="radio" name="#prefix#defaultVal" id="#prefix#defaultVal" value="no" <cfif currentValues.defaultVal eq 'no'>checked</cfif>>Unchecked
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Checked Value: (Required)</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#checkedVal" id="#prefix#checkedVal" class="cs_dlgControl" value="#currentValues.checkedVal#">
				<br/><span>Indicate the value that is stored when the checkbox is <strong>Checked</strong>.</span>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Unchecked Value: </td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#uncheckedVal" id="#prefix#uncheckedVal" class="cs_dlgControl" value="#currentValues.uncheckedVal#">
				<br/><span>Indicate the value that is stored when the checkbox is <strong>Unchecked</strong>. Default is 'no'. This field can also be blank.</span>
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