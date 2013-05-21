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
	Ron West
Custom Field Type:
	allow_edit_hidden
Name:
	allow_edit_hidden_props.cfm
Summary:
	Hidden field type that will run the default value on edit of the data.
	
	Primarily used to store the user id for the last updated.
ADF Requirements:
	None.
History:
	2009-06-29 - RLW - Created
	2010-11-04 - MFC - Updated props for the defaultValue in the paramFields variable.
--->
<cfscript>
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	if ( not structKeyExists(attributes.currentValues, 'useUdef') )
		attributes.currentValues.useUdef = 0;
</cfscript>
<cfparam name="currentValues.useUDef" default="0">
<cfparam name="currentValues.defaultValue" default="">
<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object
		fieldProperties['#typeid#'].paramFields = '#prefix#useUdef,#prefix#defaultValue';
		// allows this field to support the orange icon (copy down to label from field name)
		//fieldProperties['#typeid#'].jsLabelUpdater = '#prefix#doLabel';
		fieldProperties['#typeid#'].defaultValueField = '#prefix#defaultValue';
		// allows this field to have a common onSubmit Validator
		//fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
		// handling the copy label function
		function #prefix#doLabel(str)
		{
			document.#formname#.#prefix#label.value = str;
		}
		/*function #prefix#doValidate()
		{
			// get the function added in default value to use again
			if( document.#formName#.#prefix#useUdef.value.length != 0 )
				document.getElementById("#prefix#theUDF").value = document.#formName#.#prefix#defaultValue.value;
			return true;
		}*/
	</script>
	<table>
		<cfinclude template="/commonspot/metadata/form_control/input_control/default_value.cfm">
	</table>
</cfoutput>