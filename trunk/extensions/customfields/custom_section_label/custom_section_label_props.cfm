<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
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
	Custom Section Label Field
Name:
	$custom_section_label_props.cfm
Summary:
	Label Custom Field
ADF Requirements:
	NA
History:
	2012-03-19 - GAC - Created
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "1.0"; 
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
		
	// Setup the default values
	defaultValues = StructNew();
	defaultValues.labelID = "";
	defaultValues.labelClass = "";
	defaultValues.descptID = "";
	defaultValues.descptClass = "";
	defaultValues.hideLabelText = false;
	
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
	<script type="text/javascript">
		fieldProperties['#typeid#'].paramFields = "#prefix#labelID,#prefix#labelClass,#prefix#descptID,#prefix#descptClass,#prefix#hideLabelText";
		// allows this field to support the orange icon (copy down to label from field name)
		fieldProperties['#typeid#'].jsLabelUpdater = '#prefix#doLabel';
		// allows this field to have a common onSubmit Validator
		//fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
		// handling the copy label function
		function #prefix#doLabel(str)
		{
			document.#formname#.#prefix#label.value = str;
		}
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
			<td class="cs_dlgLabelSmall">Label ID:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#labelID" id="#prefix#labelID" value="#currentValues.labelID#" size="40">
				<br/><span>Please enter the label ID to be used on the &lt;LABEL&gt; tag.  If blank, will use the default id.</span>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Label Class Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#labelClass" id="#prefix#labelClass" class="cs_dlgControl" value="#currentValues.labelClass#" size="40">
				<br/><span>Please enter a class name to be used on the &lt;LABEL&gt; tag.  If blank, a class attribute will not be added.</span>
			</td>
		</tr>
		<tr>
			<td colspan="2" class="cs_dlgLabelSmall"><hr></td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Description ID:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#descptID" id="#prefix#descptID" value="#currentValues.descptID#" size="40">
				<br/><span>Please enter the description ID to be used on a &lt;DIV&gt; wrapper.  If blank, will use the default wrapper font tag.</span>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Description Class Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#descptClass" id="#prefix#descptClass" class="cs_dlgControl" value="#currentValues.descptClass#" size="40">
				<br/><span>Please enter the description Class to be used on a &lt;DIV&gt; wrapper.  If blank, a class attribute will not be added.</span>
			</td>
		</tr>
		<tr>
			<td colspan="2" class="cs_dlgLabelSmall"><hr></td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Hide Label Text:</td>
			<td class="cs_dlgLabelSmall">
				<input type="radio" name="#prefix#hideLabelText" id="#prefix#hideLabelText" value="1" <cfif currentValues.hideLabelText EQ 1>checked</cfif>>Yes
				<input type="radio" name="#prefix#hideLabelText" id="#prefix#hideLabelText" value="0" <cfif currentValues.hideLabelText EQ 0>checked</cfif>>No
				<br/><span>Select YES to hide the label text. Doing this will generate an empty &lt;SPAN&gt; tag that uses the Label ID and/or Label Class Name.</span>
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