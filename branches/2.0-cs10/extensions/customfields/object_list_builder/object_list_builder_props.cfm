<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
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
	Object List Builder
Name:
	object_list_builder_props.cfm
Summary:
	This is the properties module for Object List Builderr field
ADF Requirements:
	scripts_1_2
History:
	2015-04-17 - SU/SFS - Created
	2015-05-12 - DJM - Updated the field version to 2.0
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	fieldVersion = "2.0"; // Variable for the version of the field - Display in Props UI
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	
	// Setup the default values
	defaultValues = StructNew();
	defaultValues.componentPath = "";
	defaultValues.forceScripts = "0";
	
	// This will override the current values with the default values.
	// In normal use this should not need to be modified.
	defaultValueArray = StructKeyArray(defaultValues);
	// Create the unique id
	persistentUniqueID = '';
	valueWithoutParens = '';
	hasParens = 0;
	cfmlFilterCriteria = StructNew();
	if (NOT Len(persistentUniqueID))
		persistentUniqueID = CreateUUID();
	for(i=1;i lte ArrayLen(defaultValueArray); i++)
	{
		// If there is a default value to exists in the current values
		//	AND the current value is an empty string
		//	OR the default value does not exist in the current values
		if( ( StructKeyExists(currentValues, defaultValueArray[i]) 
				AND (NOT LEN(currentValues[defaultValueArray[i]])) )
				OR (NOT StructKeyExists(currentValues, defaultValueArray[i])) )
		{
			currentValues[defaultValueArray[i]] = defaultValues[defaultValueArray[i]];
		}
	}
</cfscript>


<cfif IsStruct(cfmlFilterCriteria)>
	<!--- Add the filter criteria to the session scope --->
	<cflock scope="session" timeout="5" type="Exclusive"> 
	    <cfscript>
			Session['#persistentUniqueID#'] = cfmlFilterCriteria;
		</cfscript>
	</cflock>
</cfif>

<cfoutput>
<script type="text/javascript">

	fieldProperties['#typeid#'].paramFields = "#prefix#componentPath,#prefix#forceScripts";


</script>
<table cellpadding="2" cellspacing="2" summary="" border="0">
	<tr>
		<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Component Name:</td>
		<td class="cs_dlgLabelSmall"><input type="text" name="#prefix#componentPath" id="#prefix#componentPath" value="#currentValues.componentPath#" size="50">
			
			<!--- <input type="text" name="#prefix#customElement" id="#prefix#customElement" value="#currentValues.customElement#" size="40"> --->
		</td>
	</tr>
	<tbody id="childInputs">
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Force Loading Scripts:</td>
			<td class="cs_dlgLabelSmall">
				<label style="color:black;font-size:12px;font-weight:normal;">Yes <input type="radio" id="#prefix#forceScripts" name="#prefix#forceScripts" value="1" <cfif currentValues.forceScripts EQ "1">checked</cfif>></label>
				&nbsp;&nbsp;&nbsp;
				<label style="color:black;font-size:12px;font-weight:normal;">No <input type="radio" id="#prefix#forceScripts" name="#prefix#forceScripts" value="0" <cfif currentValues.forceScripts EQ "0">checked</cfif>></label>
				<br />Force the JQuery script to load.
			</td>
		</tr>
	</tbody>
	<tr>
		<td class="cs_dlgLabelSmall" colspan="2" style="font-size:7pt;">
			<hr noshade="noshade" size="1" align="center" width="98%" />
			ADF Custom Field v#fieldVersion#
		</td>
	</tr>				
</table>
</cfoutput>							