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
	2015-09-02 - DRM - Add getResourceDependencies support, bump version
	2016-02-17 - GAC - Added getResourceDependencies and loadResourceDependencies support to the Render
			     		  - Added the getResources check to the Props
			     		  - Bumped field version
	2016-02-25 - GAC - In the _base.cfc added load once protection around the loadUnregisteredResource loading
						  - Removed obsolete tr/td tags used with pre-CS10 forms
						  - Added a field specific style fix full-width field rendering issue
				  - SU  - Updated to fix the field from rendering off the page
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<!--- // if this module loads resources, do it here.. --->
<!---<cfscript>
    // No resources to load
</cfscript>--->

<!--- ... then exit if all we're doing is detecting required resources --->
<cfif Request.RenderState.RenderMode EQ "getResources">
  <cfexit>
</cfif>

<cfscript>
	fieldVersion = "2.0.7"; // Variable for the version of the field - Display in Props UI
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	
	// Setup the default values
	defaultValues = StructNew();
	defaultValues.componentPath = "";
	defaultValues.uiTheme = "ui-lightness";
	
	// Deprecated Settings
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

	fieldProperties['#typeid#'].paramFields = "#prefix#componentPath,#prefix#forceScripts,#prefix#uiTheme";

</script>

<!--- // Deprecated Settings --->
<input type="hidden" name="#prefix#forceScripts" id="#prefix#forceScripts" value="#currentValues.forceScripts#">

<table cellpadding="2" cellspacing="2" summary="" border="0">
	<tr>
		<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Component Name:</td>
		<td class="cs_dlgLabelSmall"><input type="text" name="#prefix#componentPath" id="#prefix#componentPath" value="#currentValues.componentPath#" size="50">
			
			<!--- <input type="text" name="#prefix#customElement" id="#prefix#customElement" value="#currentValues.customElement#" size="40"> --->
		</td>
	</tr>
	<tbody id="childInputs">
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">UI Theme:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#uiTheme" id="#prefix#uiTheme" class="cs_dlgControl" value="#currentValues.uiTheme#" size="50">
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