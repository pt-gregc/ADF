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
	Link Builder
Name:
	link_builder_props.cfm
Summary:
	Custom field to build a collection of CS and external URL links.
ADF Requirements:
	
History:
	2009-10-06 - MFC - Created
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2014-09-19 - GAC - Removed deprecated doLabel and jsLabelUpdater js calls
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "1.0.1"; 
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	
	if( not structKeyExists(currentValues, "fieldID") )
		currentValues.fieldID = "";
	if( not structKeyExists(currentValues, "fieldClass") )
		currentValues.fieldClass = "";
	if( not structKeyExists(currentValues, "actionPage") )
		currentValues.actionPage = "#request.subsitecache[1].url#";
</cfscript>
<cfoutput>
	<script type="text/javascript">
		fieldProperties['#typeid#'].paramFields = "#prefix#fieldID,#prefix#fieldClass,#prefix#actionPage";
		// allows this field to have a common onSubmit Validator
		//fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
		
		/*function #prefix#doValidate()
		{
			// get the function added in default value to use again
			if( document.#formName#.#prefix#useUdef.value.length != 0 )
				document.getElementById("#prefix#theUDF").value = document.#formName#.#prefix#defaultValue.value;
				return true;
		}*/
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelSmall">Field ID:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#fieldID" id="#prefix#fieldID" class="cs_dlgControl" value="#currentValues.fieldID#" size="40">
				<br/><span>Please enter the field ID to be used via JavaScript.  If blank, will use default name.</span>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Field Class Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#fieldClass" id="#prefix#fieldClass" class="cs_dlgControl" value="#currentValues.fieldClass#" size="40">
				<br/><span>Please enter a class name to be used by JavaScript.  If blank, a class attribute will not be added.</span>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Action Page:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#actionPage" id="#prefix#actionPage" class="cs_dlgControl" value="#currentValues.actionPage#" size="60">
				<br/><span>Please enter the URL to the action page for the Link Builder custom field type.</span>
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