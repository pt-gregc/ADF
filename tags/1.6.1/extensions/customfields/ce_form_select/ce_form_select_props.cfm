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
	PaperThin Inc.
	M. Carroll
Name:
	ce_form_select_props
Summary:
	CFT to select a custom element from a select field.
	Stores the CE Form ID.
Version:
	1.0.0
History:
	2011-04-08 - MFC - Created
--->
<cfscript>
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	
	if( not structKeyExists(currentValues, "fldID") )
		currentValues.fldID = "";
</cfscript>

<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object
		fieldProperties['#typeid#'].paramFields = '#prefix#fldID';
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
				<input type="text" name="#prefix#fldID" id="#prefix#fldID" class="cs_dlgControl" value="#currentValues.fldID#" size="40">
				<br/><span>Please enter the field ID to be used via JavaScript.  If blank, will use default CS field name.</span>
			</td>
		</tr>
	</table>
</cfoutput>