<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2012.
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
	2009-08-14 - GAC - Converted to Custom Text Area With Class
	2009-08-19 - GAC - Added Default Value Property
	2010-07-08 - DMB - Added support for custom field name
	2011-12-06 - GAC - Updated to use the wrapFieldHTML from ADF lib forms_1_1
	2012-01-05 - GAC - Created a default 'wrap' variable and added '#prefix#wrap' to JS paramFields
	2012-04-12 - GAC - Changed the label for the ID of the textarea tag from Field Name to Field ID
	2012-04-13 - GAC - Added an optional parameter to assign a CSS property to the textarea field resizing handle
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
	if ( not StructKeyExists(currentValues, 'wrap') )
		currentValues.wrap = "virtual";
	if ( not StructKeyExists(currentValues, 'defaultValue') )
		currentValues.defaultValue = '';
	if ( not StructKeyExists(currentValues, 'useUdef') )
		currentValues.useUdef = 0;	
	if (  not StructKeyExists(currentValues, 'resizeHandleOption') )
		currentValues.resizeHandleOption = "default";
</cfscript>

<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object
		fieldProperties['#typeid#'].paramFields = '#prefix#fldClass,#prefix#fldName,#prefix#columns,#prefix#rows,#prefix#wrap,#prefix#useUdef,#prefix#resizeHandleOption'; //,#prefix#maxLength
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
		<td class="cs_dlgLabelSmall">Field ID:</td>
		<td class="cs_dlgLabelSmall">
			<input type="text" name="#prefix#fldName" id="#prefix#fldName" class="cs_dlgControl" value="#currentValues.fldName#" size="40">
			<br/><span>Please enter the field id to be used via JavaScript.  If blank, will use default name.</span>
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
		<input type="hidden" name="#prefix#wrap" value="#currentValues.wrap#" />
		<!--- // If the browser supports a textarea resizing handle use the props to disable it if needed --->
		<tr>
			<td class="cs_dlgLabelSmall">Resize Handle Option:</td>
			<td class="cs_dlgLabelSmall">
				<input type="radio" name="#prefix#resizeHandleOption" id="#prefix#resizeHandleOption" value="default" <cfif currentValues.resizeHandleOption eq 'default'>checked</cfif>>Default
				<input type="radio" name="#prefix#resizeHandleOption" id="#prefix#resizeHandleOption" value="none" <cfif currentValues.resizeHandleOption eq 'none'>checked</cfif>>None
				<input type="radio" name="#prefix#resizeHandleOption" id="#prefix#resizeHandleOption" value="both" <cfif currentValues.resizeHandleOption eq 'both'>checked</cfif>>Both
				<input type="radio" name="#prefix#resizeHandleOption" id="#prefix#resizeHandleOption" value="horizontal" <cfif currentValues.resizeHandleOption eq 'horizontal'>checked</cfif>>Horizontal
				<input type="radio" name="#prefix#resizeHandleOption" id="#prefix#resizeHandleOption" value="vertical" <cfif currentValues.resizeHandleOption eq 'vertical'>checked</cfif>>Vertical
				<br/><span>Apply an option for the resize handle that appears in the corner of this textarea field (if the browser supports it).</span>
			</td>
		</tr>
</cfoutput>
<cfset useTextArea = 1>
<cfinclude template="/commonspot/metadata/form_control/input_control/default_value.cfm">
<cfoutput>
	</table>
</cfoutput>