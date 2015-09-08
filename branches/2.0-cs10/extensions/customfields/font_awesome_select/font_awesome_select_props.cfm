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
	PaperThin Inc.
Name:
	font_awesome_select_props.cfm
Summary:
	renders properties panel for font awesome icon custom field type
Version:
	1.0
History:
	2014-09-15 - Created
	2014-09-29 - GAC - Added an updated list of icon classes and code via a FileRead of a CSV file 
	2014-12-03 - GAC - Updated to fix for bad version folder "Major.Minor.Maintenance" for thirdParty folder. Now is only "Major.Minor" version folder.
	2015-05-12 - DJM - Updated the field version to 2.0
	2015-09-02 - DRM - Add getResourceDependencies support, bump version
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	prefix = attributes.prefix;
	currentValues = attributes.currentValues;
	typeid = attributes.typeid;
	formname = attributes.formname;	
//writedump( var="#currentValues#", expand="no" );
	
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "2.0.1";
	
	// initialize some of the attributes variables
	showSize = 0;
	showFixedWidth = 0;
	showBorder = 0;
	showSpin = 0;
	showPull = 0;
	iconDataFile = "";
	
	defaultFAversion = "4.2";	
	// Default file path to the CSV file that contain the icon class name and codes
	defaultIconDataFile = "/ADF/thirdParty/css/font-awesome/#defaultFAversion#/data/icon-data.csv";
	
	if( StructKeyExists(currentValues, "ShowSize") )
		ShowSize = currentValues.ShowSize;
	if( StructKeyExists(currentValues, "ShowFixedWidth") )	
		ShowFixedWidth = currentValues.ShowFixedWidth;
	if( StructKeyExists(currentValues, "ShowBorder") )	
		ShowBorder = currentValues.ShowBorder;
	if( StructKeyExists(currentValues, "ShowSpin") )	
		ShowSpin = currentValues.ShowSpin;
	if( StructKeyExists(currentValues, "ShowPull") )	
		ShowPull = currentValues.ShowPull;
		
	if( StructKeyExists(currentValues, "iconDataFile") AND LEN(TRIM(currentValues.iconDataFile)) )	
		iconDataFile = currentValues.iconDataFile;
		
	// Fix for bad version folder "Major.Minor.Maintenance". Should only be "Major.Minor" version.
	// - If the "4.2.0" folder is found, set to {blank} to use the default value in the render file
	if ( FindNoCase("/ADF/thirdParty/css/font-awesome/4.2.0/",iconDataFile) ) 	
		iconDataFile = ""; 	
</cfscript>

<cfoutput>
	<script type="text/javascript"]>
		fieldProperties['#typeid#'].paramFields = "#prefix#ShowSize,#prefix#ShowFixedWidth,#prefix#ShowBorder,#prefix#ShowSpin,#prefix#ShowPull,#prefix#iconDataFile";
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelSmall" nowrap="nowrap" valign="top">Show:</td>
			<td class="cs_dlgLabelSmall">
				<input type="checkbox" name="#prefix#ShowSize" id="#prefix#ShowSize" value="1" class="cs_dlgControl" <cfif ShowSize eq 1>checked="checked"</cfif>><label for="#prefix#ShowSize">Size</label> &nbsp;
				<input type="checkbox" name="#prefix#ShowFixedWidth" id="#prefix#ShowFixedWidth" value="1" class="cs_dlgControl" <cfif ShowFixedWidth eq 1>checked="checked"</cfif>><label for="#prefix#ShowFixedWidth">Fixed Width</label> &nbsp;
				<input type="checkbox" name="#prefix#ShowBorder" id="#prefix#ShowBorder" value="1" class="cs_dlgControl" <cfif ShowBorder eq 1>checked="checked"</cfif>><label for="#prefix#ShowBorder">Border</label> &nbsp;
				<input type="checkbox" name="#prefix#ShowSpin" id="#prefix#ShowSpin" value="1" class="cs_dlgControl" <cfif ShowSpin eq 1>checked="checked"</cfif>><label for="#prefix#ShowSpin">Spin</label> &nbsp;
				<input type="checkbox" name="#prefix#ShowPull" id="#prefix#ShowPull" value="1" class="cs_dlgControl" <cfif ShowPull eq 1>checked="checked"</cfif>><label for="#prefix#ShowPull">Pull</label> &nbsp;
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" nowrap="nowrap" valign="top">Icon Data File (csv):</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#iconDataFile" id="#prefix#iconDataFile" class="cs_dlgControl" value="#iconDataFile#" size="60">
				<br/>Specify a relative path to a comma-delimited (.csv) override icon data file.
				<br/>If left blank, will use the default Icon data file.
				<br/>(<em>Default: #defaultIconDataFile#</em> )
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