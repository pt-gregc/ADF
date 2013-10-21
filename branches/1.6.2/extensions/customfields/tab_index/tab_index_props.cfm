<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2013.
All Rights Reserved.
 
By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->
<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$tab_index_props.cfm
Summary:
	Tab Index custom field to add the "tabindex" attributes to the fields in the 
		simple form.
History:
 	2012-11-27 - MFC - Created
--->
<cfscript>
	fieldVersion = "1.0"; // Variable for the version of the field - Display in Props UI.
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;

	// Setup the default values
	defaultValues = StructNew();
	
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
		fieldProperties['#typeid#'].paramFields = '';
		// allows this field to support the orange icon (copy down to label from field name)
		fieldProperties['#typeid#'].jsLabelUpdater = '#prefix#doLabel';
		// allows this field to have a common onSubmit Validator
		//fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';

		// handling the copy label function. **bug - This is not actually getting called, keeping it in here until future update fixes**
		function #prefix#doLabel(str){
			document.#formname#.#prefix#label.value = str;
		}

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
			<td class="cs_dlgLabelSmall" colspan="2">
				No Properties
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" colspan="2" style="font-size:7pt;">
				ADF Custom Field v#fieldVersion#
			</td>
		</tr>
	</table>
</cfoutput>