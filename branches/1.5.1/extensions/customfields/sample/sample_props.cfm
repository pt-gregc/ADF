<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2011.
All Rights Reserved.
 
By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->
<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$sample_props.cfm
Summary:
	Sample properties file for the sample custom field type.
History:
 	2011-09-26 - RAK - Created
	2011-12-19 - MFC - Updated to load the current values with the default values.
--->
<cfscript>
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;

	// Setup the default values
	defaultValues = StructNew();
	defaultValues.defaultText = "This is the defaulted text";

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
	
	// Load JQuery
	application.ADF.scripts.loadJQuery();
</cfscript>

<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object, this uses the name of the field
		fieldProperties['#typeid#'].paramFields = '#prefix#defaultText';
		// allows this field to support the orange icon (copy down to label from field name)
		fieldProperties['#typeid#'].jsLabelUpdater = '#prefix#doLabel';
		// allows this field to have a common onSubmit Validator
		fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';

		// handling the copy label function. **bug - This is not actually getting called, keeping it in here until future update fixes**
		function #prefix#doLabel(str){
			document.#formname#.#prefix#label.value = str;
		}

		//Validation function, this specific instance checks to verify they entered a valid value.
		function #prefix#doValidate(){
			if(jQuery("###prefix#defaultText").val().length){
				return true;
			}
			alert("Please enter a value for the default text.");
			return false;
		}
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelSmall">
				<label for="#prefix#defaultValue">Default Text:</label>
			</td>
			<!---
				Example text field, allowing people to specify the default value in the properties dialog
				name is specified in paramFields
				value is updated in the defaultValues structure
			--->
			<td class="cs_dlgLabelSmall">
				<input type="text" id="#prefix#defaultText" name="#prefix#defaultText" value="#currentValues.defaultText#">
			</td>
		</tr>
	</table>
</cfoutput>