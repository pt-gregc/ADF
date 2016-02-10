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
	PaperThin Inc.
Name:
	uniqueID_props.cfm
Version:
	1.0.0
History:
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2015-05-12 - DJM - Updated the field version to 2.0
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "2.0.2";
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;

	// Setup the default values
	defaultValues = StructNew();
	defaultValues.uniqueIDtype = "cfuuid"; //cfuuid or csid
	defaultValues.varName = "";
	defaultValues.renderField = "no";
	defaultValues.renderRequestVar = "no";
	
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
		// register the fields with global props object, this uses the name of the field
		fieldProperties['#typeid#'].paramFields = '#prefix#uniqueIDtype,#prefix#varName,#prefix#renderField,#prefix#renderRequestVar';
		// allows this field to support the orange icon (copy down to label from field name)
		fieldProperties['#typeid#'].jsLabelUpdater = '#prefix#doLabel';
		// allows this field to have a common onSubmit Validator
		//fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';

		// handling the copy label function. **bug - This is not actually getting called, keeping it in here until future update fixes**
		function #prefix#doLabel(str){
			document.#formname#.#prefix#label.value = str;
		};

		//Validation function, this specific instance checks to verify they entered a valid value.
		/* function #prefix#doValidate(){
			if(jQuery("###prefix#defaultText").val().length){
				return true;
			}
			alert("Please enter a value for the default text.");
			return false;
		} */
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Unique ID Type:</td>
			<td class="cs_dlgLabelSmall">
				<label style="color:black;font-size:12px;font-weight:normal;">ColdFusion UUID <input type="radio" id="#prefix#uniqueIDtype" name="#prefix#uniqueIDtype" value="cfuuid" <cfif currentValues.uniqueIDtype EQ "cfuuid">checked</cfif>></label>
				&nbsp;&nbsp;&nbsp;
				<label style="color:black;font-size:12px;font-weight:normal;">CommonSpot Numeric ID <input type="radio" id="#prefix#uniqueIDtype" name="#prefix#uniqueIDtype" value="csid" <cfif currentValues.uniqueIDtype EQ "csid">checked</cfif>></label>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top">Request Variable Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#varName" id="#prefix#varName" class="cs_dlgControl" value="#currentValues.varName#" size="40">
				<br /><span>Please enter a variable name for the uniqueID request variable.
				<br />If blank, will use 'uniqueID' (request.uniqueID).</span>
			</td>
		</tr>
		<tr>
			<td colspan="2"><hr /></td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Field Display Type:</td>
			<td class="cs_dlgLabelSmall">
				<label style="color:black;font-size:12px;font-weight:normal;">Hidden <input type="radio" name="#prefix#renderField" id="#prefix#renderField_no" value="no" <cfif currentValues.renderField eq 'no'>checked</cfif>></label>
				<label style="color:black;font-size:12px;font-weight:normal;">Visible <input type="radio" name="#prefix#renderField" id="#prefix#renderField_yes" value="yes" <cfif currentValues.renderField eq 'yes'>checked</cfif>></label>
				<!--- <br /><span>('Visible' is generally used for developement or debugging.)</span --->
			</td>
		</tr>
		<!--- <input type="hidden" name="#prefix#renderRequestVar" id="#prefix#renderRequestVar" value="#currentValues.renderRequestVar#"> --->
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Render Request Variable:</td>
			<td class="cs_dlgLabelSmall">
				<label style="color:black;font-size:12px;font-weight:normal;">No <input type="radio" name="#prefix#renderRequestVar" id="#prefix#renderRequestVar_no" value="no" <cfif currentValues.renderRequestVar eq 'no'>checked</cfif>></label>
				<label style="color:black;font-size:12px;font-weight:normal;">Yes <input type="radio" name="#prefix#renderRequestVar" id="#prefix#renderRequestVar_yes" value="yes" <cfif currentValues.renderRequestVar eq 'yes'>checked</cfif>></label>
				<!--- <br /><span>('Yes' is generally used for developement or debugging.)</span> --->
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