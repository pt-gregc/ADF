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
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Custom Field Type:
	Custom Text Area Field
Name:
	custom_text_area_field_props.cfm
Summary:
	Allows for an text area field to have a specific class name. 
	
ADF Requirements:

History:
	2009-07-06 - MFC - Created
	2009-08-14 - GAC - Modified - Converted to Custom Text Area With Class
	2009-08-19 - GAC - Modified - Added Default Value Property
	2010-07-08 - DMB - Modified - Added support for custom field name
	2011-12-06 - GAC - Modified - Updated to use the wrapFieldHTML from ADF lib forms_1_1
--->
<cfscript>
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	if( not structKeyExists(currentValues, "fldClass") )
		currentValues.fldClass = "";
	//if( not structKeyExists(currentValues, "maxLength") )
		//currentValues.maxLength = "1000";
	if( not structKeyExists(currentValues, "fldName") )
		currentValues.fldName = "";
	if( not structKeyExists(currentValues, "columns") )
		currentValues.columns = "40";
	if( not structKeyExists(currentValues, "rows") )
		currentValues.rows = "4";
	if ( not StructKeyExists(currentValues, 'defaultValue') )
		currentValues.defaultValue = '';
	if ( not StructKeyExists(currentValues, 'useUdef') )
		currentValues.useUdef = 0;
</cfscript>

<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object
		fieldProperties['#typeid#'].paramFields = '#prefix#fldClass,#prefix#fldName,#prefix#columns,#prefix#rows,#prefix#useUdef'; //,#prefix#maxLength
		fieldProperties['#typeid#'].defaultValueField = '#prefix#defaultValue';
		// allows this field to support the orange icon (copy down to label from field name)
		fieldProperties['#typeid#'].jsLabelUpdater = '#prefix#doLabel';
		// allows this field to have a common onSubmit Validator
		fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
		// handling the copy label function
		function #prefix#doLabel(str)
		{
			document.#formname#.#prefix#label.value = str;
		}
		function #prefix#doValidate()
		{
			if ( !checkinteger(document.#formname#.#prefix#columns.value) )
			{
				showMsg('Please enter a valid number of columns for this field.');
				setFocus(document.#formname#.#prefix#columns);
				return false;
			}
			if ( !checkinteger(document.#formname#.#prefix#rows.value) )
			{
				showMsg('Please enter a valid number of rows for this field.');
				setFocus(document.#formname#.#prefix#rows);
				return false;
			}
			return true;
		}
	</script>
	<table>
		<tr>
		<td class="cs_dlgLabelSmall">Field Name:</td>
		<td class="cs_dlgLabelSmall">
			<input type="text" name="#prefix#fldName" id="#prefix#fldName" class="cs_dlgControl" value="#currentValues.fldName#" size="40">
			<br/><span>Please enter the field name to be used via JavaScript.  If blank, will use default name.</span>
		</td>
	</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Class Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#fldClass" id="#prefix#fldClass" class="cs_dlgControl" value="#currentValues.fldClass#" size="40">
				<br/><span>Please enter a class name to be used by JavaScript.  If blank, a class attribute will not be added.</span>
			</td>
		</tr>
		<!--- <tr>
			<td class="cs_dlgLabelSmall">Maximum Length:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#maxLength" id="#prefix#maxLength" value="#currentValues.maxLength#" size="5"><br />
				Indicate the maximum length (count of characters) that can be entered in this field.
			</td>
		</tr> --->
		<tr>
			<td class="cs_dlgLabelSmall">Columns:</td>
			<td class="cs_dlgLabelSmall"><input type="text" name="#prefix#columns" id="#prefix#columns" value="#currentValues.columns#" size="5"></td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Rows:</td>
			<td class="cs_dlgLabelSmall"><input type="text" name="#prefix#rows" id="#prefix#rows" value="#currentValues.rows#" size="5"></td>
		</tr>
		<input type="hidden" name="#prefix#wrap" value="virtual" />
</cfoutput>
<cfset useTextArea = 1>
<cfinclude template="/commonspot/metadata/form_control/input_control/default_value.cfm">
<cfoutput>
	</table>
</cfoutput>