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
	CE_Select
Name:
	ce_select_props.cfm
Summary:
	Custom Element selection field type.  
	Provides connections with the CE_FIELD_SELECT custom field type.  Define the properties 
	in the CE_FIELD_SELECT and CE_SELECT field to connect the fields. 
ADF Requirements:
	lib/ceData/ceData_1_0
	lib/scripts/SCRIPTS_1_0
History:
	2009-05-21 - MFC - Created
--->
<cfscript>
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	
	// Set the defaults
	if( not structKeyExists(currentValues, "fieldID") )
		currentValues.fieldID = "";
	if( not structKeyExists(currentValues, "ceFldsFieldID") )
		currentValues.ceFldsFieldID = "";
</cfscript>
<!--- <cfdump var="#attributes#"> --->

<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object
		fieldProperties['#typeid#'].paramFields = '#prefix#fieldID,#prefix#ceFldsFieldID';
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
		<tr valign="top">
			<td class="cs_dlgLabelSmall">Field ID</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#fieldID" id="#prefix#fieldID" value="#currentValues.fieldID#">
			</td>
		</tr>
		<tr valign="top">
			<td class="cs_dlgLabelSmall">CE Fields - Field ID</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#ceFldsFieldID" id="#prefix#ceFldsFieldID" value="#currentValues.ceFldsFieldID#">
			</td>
		</tr>
	</table>
</cfoutput>