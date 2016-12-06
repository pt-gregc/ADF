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
	general chooser v2.1
Name:
	general_chooser_2_1_props.cfm
Summary:
	General Chooser field type.
	Allows for selection of the custom element records.
Version:
	2.1
History:
	2016-12-06 - GAC - Created
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<!--- // if this module loads resources, do it here.. --->
<cfscript>
	application.ADF.scripts.loadJQuery(noConflict=true);
</cfscript>

<!--- ... then exit if all we're doing is detecting required resources --->
<cfif Request.RenderState.RenderMode EQ "getResources">
  <cfexit>
</cfif>

<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "2.1.0";
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;

	//Setup the default values
	defaultValues = StructNew();
	defaultValues.chooserCFCName = "";
	defaultValues.chooserAppName = "";
	defaultValues.uiTheme = "ui-lightness";
	defaultValues.minSelections = "0";
	defaultValues.maxSelections = "0";
	defaultValues.loadAvailable = "0";
	defaultValues.loadAvailableOption = "useServerSide";
	defaultValues.passthroughParams = "";
	defaultValues.renderFieldLabelAbove = false;
	defaultValues.hideFieldLabelContainer = false;
	
	// Deprecated Settings
	defaultValues.forceScripts = "0";

   //This will override the default values with the current values.
   currentValueArray = StructKeyArray(currentValues);
   for(i=1;i<=ArrayLen(currentValueArray);i++)
	{
		if(StructKeyExists(defaultValues,currentValueArray[i]))
			defaultValues[currentValueArray[i]] = currentValues[currentValueArray[i]];
	}
</cfscript>

<cfsavecontent variable="cftGeneralChooserPropsCSS">
<cfoutput>
<style>
	###prefix#loadAvailableOptions {
		<cfif defaultValues.loadAvailable EQ "1">
		visibility: visible;
		<cfelse>
		display: none;
		</cfif>
	}
</style>
</cfoutput>
</cfsavecontent>

<cfsavecontent variable="cftGeneralChooserPropsJS">
<cfoutput>
<script language="JavaScript" type="text/javascript">
<!--
	jQuery.noConflict();


	// register the fields with global props object
	fieldProperties['#typeid#'].paramFields = '#prefix#chooserCFCName,#prefix#chooserAppName,#prefix#forceScripts,#prefix#minSelections,#prefix#maxSelections,#prefix#loadAvailable,#prefix#loadAvailableOption,#prefix#passthroughParams,#prefix#uiTheme,#prefix#renderFieldLabelAbove,#prefix#hideFieldLabelContainer';
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

	jQuery(function()
	{
		
		jQuery('input[type=radio][name=#prefix#loadAvailable]').change(function(){
			jQuery("###prefix#loadAvailableOptions").toggle();
	  	});

	});
</script>
</cfoutput>
</cfsavecontent>

<cfscript>
	application.ADF.scripts.addHeaderCSS(cftGeneralChooserPropsCSS,"SECONDARY");
	application.ADF.scripts.addFooterJS(cftGeneralChooserPropsJS,"SECONDARY");
</cfscript>

<cfoutput>
	<!--- // Deprecated Settings --->
	<input type="hidden" name="#prefix#forceScripts" id="#prefix#forceScripts" value="#defaultValues.forceScripts#">

	<table>
		<tr valign="top">
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Chooser Bean Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" id="#prefix#chooserCFCName" name="#prefix#chooserCFCName" value="#defaultValues.chooserCFCName#" size="50"><br />
				Name of the Object Factory Bean that will be used when rendering and
				<br />populating chooser data. (i.e. profileGC).
				<br />Note: Do NOT include ".cfc" in the name.
			</td>
		</tr>
		<tr valign="top">
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Chooser App Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" id="#prefix#chooserAppName" name="#prefix#chooserAppName" value="#defaultValues.chooserAppName#" size="50"><br />
				The App Name that will be used to resolve the Chooser Bean Name
				<br />entered above. (i.e. ptProfile).
				<br />Note: This is optional. If left blank, it will use the first matching Bean Name found in the ADF object.
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">UI Theme:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#uiTheme" id="#prefix#uiTheme" class="cs_dlgControl" value="#defaultValues.uiTheme#" size="50">
			</td>
		</tr>
		<tr valign="top">
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Minimum Number of Selections:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" id="#prefix#minSelections" name="#prefix#minSelections" value="#defaultValues.minSelections#" size="10"><br />
				<span>Default: 0 (Use 0 to make a selection optional)</span>
			</td>
		</tr>
		<tr valign="top">
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Maximum Number of Selections:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" id="#prefix#maxSelections" name="#prefix#maxSelections" value="#defaultValues.maxSelections#" size="10"><br />
				<span>Default: 0 (Use 0 for unlimited selections)</span>
			</td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Passthrough Params:</th>
			<td valign="baseline" class="cs_dlgLabelSmall">
				#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#passthroughParams", name="#prefix#passthroughParams", value="#defaultValues.passthroughParams#", size="70", class="InputControl")#
				<br />Optional comma-delimited list of Form or URL fields to pass through to dialogs invoked when the user presses the 'Add New Record' button.
			</td>
		</tr>
		<tr>
			<td colspan="2"><hr noshade="noshade" size="1" align="center" width="98%" /></td>
		</tr>
		<tr valign="top">
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Load All Available Selections:</td>
			<td class="cs_dlgLabelSmall">
				<label style="color:black;font-size:12px;font-weight:normal;">Yes <input type="radio" id="#prefix#loadAvailableYes" name="#prefix#loadAvailable" value="1" <cfif defaultValues.loadAvailable EQ "1">checked</cfif>></label>
				&nbsp;&nbsp;&nbsp;
				<label style="color:black;font-size:12px;font-weight:normal;">No <input type="radio" id="#prefix#loadAvailableNo" name="#prefix#loadAvailable" value="0" <cfif defaultValues.loadAvailable EQ "0">checked</cfif>></label>
				<br />Select 'Yes' to load all the available selections on the form load.
			</td>
		</tr>
		<tr valign="top" id="#prefix#loadAvailableOptions">
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Initial Load Style:</td>
			<td class="cs_dlgLabelSmall">
				<label style="color:black;font-size:12px;font-weight:normal;">Use Server Side <input type="radio" id="#prefix#loadAvailableOptionSS" name="#prefix#loadAvailableOption" value="useServerSide" <cfif defaultValues.loadAvailableOption EQ "useServerSide">checked</cfif>></label>
				&nbsp;&nbsp;&nbsp;
				<label style="color:black;font-size:12px;font-weight:normal;">Use JavaScript <input type="radio" id="#prefix#loadAvailableOptionJS" name="#prefix#loadAvailableOption" value="useJavascript" <cfif defaultValues.loadAvailableOption EQ "useJavascript">checked</cfif>></label>
				<br />Default is 'Use Server Side'. Select 'Use JavaScript' to force the initial load via an ajax request.
			</td>
		</tr>
		<tr>
			<td colspan="2"><hr noshade="noshade" size="1" align="center" width="98%" /></td>
		</tr>
		<tr valign="top">
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Render Field Label Above:</td>
			<td class="cs_dlgLabelSmall">
				<label style="color:black;font-size:12px;font-weight:normal;">Yes <input type="radio" id="#prefix#renderFieldLabelAboveYes" name="#prefix#renderFieldLabelAbove" value="1" <cfif defaultValues.renderFieldLabelAbove EQ "1">checked</cfif>></label>
				&nbsp;&nbsp;&nbsp;
				<label style="color:black;font-size:12px;font-weight:normal;">No <input type="radio" id="#prefix#renderFieldLabelAboveNo" name="#prefix#renderFieldLabelAbove" value="0" <cfif defaultValues.renderFieldLabelAbove EQ "0">checked</cfif>></label>
				<br />Select 'Yes' to render the field label above the selection lists.
			</td>
		</tr>
		<tr valign="top">
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Hide Field Label:</td>
			<td class="cs_dlgLabelSmall">
				<label style="color:black;font-size:12px;font-weight:normal;">Yes <input type="radio" id="#prefix#hideFieldLabelContainerYes" name="#prefix#hideFieldLabelContainer" value="1" <cfif defaultValues.hideFieldLabelContainer EQ "1">checked</cfif>></label>
				&nbsp;&nbsp;&nbsp;
				<label style="color:black;font-size:12px;font-weight:normal;">No <input type="radio" id="#prefix#hideFieldLabelContainerNo" name="#prefix#hideFieldLabelContainer" value="0" <cfif defaultValues.hideFieldLabelContainer EQ "0">checked</cfif>></label>
				<br />Select 'Yes' to not render the field label container. (Overrides the Render Label Above option.)
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