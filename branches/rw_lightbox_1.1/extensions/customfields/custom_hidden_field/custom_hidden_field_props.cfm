<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2010.
All Rights Reserved.
 
By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	Michael Carroll 
Custom Field Type:
	Custom Hidden Field
Name:
	custom_hidden_field_props.cfm
Summary:
	Custom hidden field type, that allows to assign a field ID and class name to the hidden field.
ADF Requirements:
	None
History:
	2009-09-01 - MFC - Created
--->
<cfscript>
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	
	if( not structKeyExists(currentValues, "fieldID") )
		currentValues.fieldID = "";
	if( not structKeyExists(currentValues, "fieldClass") )
		currentValues.fieldClass = "";
	if ( not StructKeyExists(currentValues, 'defaultValue') )
		currentValues.defaultValue = '';
	if ( not StructKeyExists(currentValues, 'useUdef') )
		currentValues.useUdef = 0;
</cfscript>
<cfoutput>
	<script type="text/javascript"]>
		fieldProperties['#typeid#'].paramFields = "#prefix#fieldID,#prefix#fieldClass,#prefix#useUdef";
		fieldProperties['#typeid#'].defaultValueField = '#prefix#defaultValue';
		// allows this field to support the orange icon (copy down to label from field name)
		fieldProperties['#typeid#'].jsLabelUpdater = '#prefix#doLabel';
		// allows this field to have a common onSubmit Validator
		//fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
		// handling the copy label function
		function #prefix#doLabel(str)
		{
			document.#formname#.#prefix#label.value = str;
		}
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
	<cfinclude template="/commonspot/metadata/form_control/input_control/default_value.cfm">
</table>
</cfoutput>