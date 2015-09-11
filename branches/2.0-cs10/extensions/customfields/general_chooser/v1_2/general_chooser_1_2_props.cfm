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
	general chooser v1.2
Name:
	general_chooser_1_2_props.cfm
Summary:
	General Chooser field type.
	Allows for selection of the custom element records.
Version:
	1.2
History:
	2009-05-29 - MFC - Created
	2011-03-20 - MFC - Updated component to simplify the customizations process and performance.
						Removed Ajax loading process.
	2011-09-21 - RAK - Added max/min selections
	2011-09-21 - RAK - Updated default values to load in an easier to configure manner
	2011-10-20 - GAC - Updated the descriptions for the minSelections and maxSelections fields
	2012-03-19 - MFC - Added "loadAvailable" option to set if the available selections load
						when the form loads.
	2013-11-21 - TP  - Fixed typos with props option descriptions
	2013-12-05 - GAC - Added standard CS text formatting to the props options 
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2014-09-19 - GAC - Removed deprecated doLabel and jsLabelUpdater js calls
	2014-10-10 - GAC - Added a new props field to allow the app name used for resolving the Chooser Bean Name to be specified
	2015-07-21 - GAC - Additional work to remove the dependency for the jQuery CFJS library
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "1.2.8"; 
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;

	//Setup the default values
	defaultValues = StructNew();
	defaultValues.chooserCFCName = "";
	defaultValues.chooserAppName = "";
    defaultValues.forceScripts = "0";
    defaultValues.minSelections = "0";
    defaultValues.maxSelections = "0";
    defaultValues.loadAvailable = "0";

   //This will override the default values with the current values.
   currentValueArray = StructKeyArray(currentValues);
   for(i=1;i<=ArrayLen(currentValueArray);i++)
   {
      if(StructKeyExists(defaultValues,currentValueArray[i]))
	  {
         defaultValues[currentValueArray[i]] = currentValues[currentValueArray[i]];
      }
   }
</cfscript>
<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object
		fieldProperties['#typeid#'].paramFields = '#prefix#chooserCFCName,#prefix#chooserAppName,#prefix#forceScripts,#prefix#minSelections,#prefix#maxSelections,#prefix#loadAvailable';
		// allows this field to have a common onSubmit Validator
		fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';

		function #prefix#doValidate()
		{
			// Check the chooserCFCName
			if ( document.getElementById('#prefix#chooserCFCName').value.length <= 0 ) {
				alert("Please enter the Chooser CFC Name property field.");
				return false;
			}
			// Everything is OK, submit form
			return true;
		}
	</script>
	<table>
		<tr valign="top">
			<td class="cs_dlgLabelBold" nowrap="nowrap">Chooser Bean Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" id="#prefix#chooserCFCName" name="#prefix#chooserCFCName" value="#defaultValues.chooserCFCName#" size="50"><br />
				Name of the Object Factory Bean that will be used when rendering and
				<br />populating chooser data. (i.e. profileGC).
				<br />Note: Do NOT include ".cfc" in the name.
			</td>
		</tr>
		<tr valign="top">
			<td class="cs_dlgLabelBold" nowrap="nowrap">Chooser App Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" id="#prefix#chooserAppName" name="#prefix#chooserAppName" value="#defaultValues.chooserAppName#" size="50"><br />
				The App Name that will be used to resolve the Chooser Bean Name
				<br />entered above. (i.e. ptProfile).
				<br />Note: This is optional. If left blank, it will use the first matching Bean Name found in the ADF object.
			</td>
		</tr>
		<tr valign="top">
			<td class="cs_dlgLabelBold" nowrap="nowrap">Force Loading Scripts:</td>
			<td class="cs_dlgLabelSmall">
				<label style="color:black;font-size:12px;font-weight:normal;">Yes <input type="radio" id="#prefix#forceScripts" name="#prefix#forceScripts" value="1" <cfif defaultValues.forceScripts EQ "1">checked</cfif>></label>
				&nbsp;&nbsp;&nbsp;
				<label style="color:black;font-size:12px;font-weight:normal;">No <input type="radio" id="#prefix#forceScripts" name="#prefix#forceScripts" value="0" <cfif defaultValues.forceScripts EQ "0">checked</cfif>></label>
				<br />Force the JQuery, JQuery UI, and Thickbox scripts to load on the chooser loading.
			</td>
		</tr>
		<tr valign="top">
			<td class="cs_dlgLabelBold" nowrap="nowrap">Minimum Number of Selections:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" id="#prefix#minSelections" name="#prefix#minSelections" value="#defaultValues.minSelections#" size="10"><br />
				<span>Default: 0 (Use 0 to make a selection optional)</span>
			</td>
		</tr>
		<tr valign="top">
			<td class="cs_dlgLabelBold" nowrap="nowrap">Maximum Number of Selections:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" id="#prefix#maxSelections" name="#prefix#maxSelections" value="#defaultValues.maxSelections#" size="10"><br />
				<span>Default: 0 (Use 0 for unlimited selections)</span>
			</td>
		</tr>
		<tr valign="top">
			<td class="cs_dlgLabelBold" nowrap="nowrap">Load All Available Selections:</td>
			<td class="cs_dlgLabelSmall">
				<label style="color:black;font-size:12px;font-weight:normal;">Yes <input type="radio" id="#prefix#loadAvailable" name="#prefix#loadAvailable" value="1" <cfif defaultValues.loadAvailable EQ "1">checked</cfif>></label>
				&nbsp;&nbsp;&nbsp;
				<label style="color:black;font-size:12px;font-weight:normal;">No <input type="radio" id="#prefix#loadAvailable" name="#prefix#loadAvailable" value="0" <cfif defaultValues.loadAvailable EQ "0">checked</cfif>></label>
				<br />Select 'Yes' to load all the available selections on the form load.
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" colspan="2" style="font-size:7pt;">
				<hr />
				ADF Custom Field v#fieldVersion#
			</td>
		</tr>
	</table>
</cfoutput>