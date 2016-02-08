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
	PaperThin Inc.
Name:
	bootstrap_glyphicon_select_props.cfm
Summary:
	renders properties panel for bootstrap glyphicon custom field type
Version:
	1.0
History:
	2015-09-15 - Created
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	prefix = attributes.prefix;
	currentValues = attributes.currentValues;
	typeid = attributes.typeid;
	formname = attributes.formname;	
//writedump( var="#currentValues#", expand="no" );
	
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "1.0.0";
	
	// initialize some of the attributes variables
	showSize = 0;
	glyphiconDataFile = "";
	
	defaultBootstrapVersion = "3.3";
	
	// Default file path to the CSV file that contain the icon class name and codes
	defaultGlyphiconDataFile = "/ADF/thirdParty/jquery/bootstrap/#defaultBootstrapVersion#/data/glyphicon-data.csv";

	// Default location for the Required Resouce to be registered in CommonSpot
	requiredResourceLocation = "/ADF/thirdParty/jquery/bootstrap/#defaultBootstrapVersion#/css/bootstrap-ADF-ext.css";

	if( StructKeyExists(currentValues, "ShowSize") )
		ShowSize = currentValues.ShowSize;
		
	if( StructKeyExists(currentValues, "glyphiconDataFile") AND LEN(TRIM(currentValues.glyphiconDataFile)) )	
		glyphiconDataFile = currentValues.glyphiconDataFile;
</cfscript>

<cfoutput>
	<script type="text/javascript"]>
		fieldProperties['#typeid#'].paramFields = "#prefix#ShowSize,#prefix#ShowFixedWidth,#prefix#ShowBorder,#prefix#ShowSpin,#prefix#ShowPull,#prefix#glyphiconDataFile";
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelSmall" nowrap="nowrap" valign="top">Show:</td>
			<td class="cs_dlgLabelSmall">
				<input type="checkbox" name="#prefix#ShowSize" id="#prefix#ShowSize" value="1" class="cs_dlgControl" <cfif ShowSize eq 1>checked="checked"</cfif>><label for="#prefix#ShowSize">Size</label> &nbsp;
				
				<br/>The <strong>SIZE</strong> option requires the "bootstrap-ADF-ext.css" file be registered as a resouce along with Bootstrap's library CSS file. 
				Otherwise glyphicon size class definitions (eg. glyphicon-2x, etc.) will need to be added to the sites custom style sheet.
				<br/>(<em>Resource Location: #requiredResourceLocation#</em> )
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" nowrap="nowrap" valign="top">Icon Data File (csv):</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#glyphiconDataFile" id="#prefix#glyphiconDataFile" class="cs_dlgControl" value="#glyphiconDataFile#" size="60">
				<br/>Specify a relative path to a comma-delimited (.csv) override icon data file.
				<br/>If left blank, will use the default Icon data file.
				<br/>(<em>Default: #defaultGlyphiconDataFile#</em> )
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" colspan="2" style="font-size:7pt;">
				<hr noshade="noshade" size="1" align="center" width="98%" />
				ADF Custom Field v#fieldVersion#
			</td>
		</tr>
	</table>
</cfoutput>