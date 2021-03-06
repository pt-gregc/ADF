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
	R. Kahn
Custom Field Type:
	file uploader
Name:
	file_uploader_props.cfm
Summary:
	Gives a text field allowing user to enter file locations. Then verifies them.
ADF Requirements:
History:
	2010-10-26 - RAK - Created
	2012-03-08 - GAC - Added jQuery the noConflict option
	2012-07-08 - SFS - Added comment to the bean name field to clarify what to enter and where the config component should go.
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
    2014-09-19 - GAC - Removed deprecated doLabel and jsLabelUpdater js calls
	2015-05-26 - DJM - Added the 3.0 version
	2015-09-02 - DRM - Add getResourceDependencies support, bump version
	2016-02-19 - GAC - Added getResourceDependencies and loadResourceDependencies support to the Render
					  	  - Added the getResources check to the Props
					  	  - Moved resource loading to the the top of the props file
					  	  - Bumped field version
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<!--- // this module has resources to load --->
<cfscript>
    application.ADF.scripts.loadJQuery(noConflict=true);
</cfscript>

<!--- ... then exit if all we're doing is detecting required resources --->
<cfif Request.RenderState.RenderMode EQ "getResources">
  <cfexit>
</cfif>

<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "3.0.5";
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	if( not structKeyExists(currentValues, "beanName") )
		currentValues.beanName = "file_uploader";
	if( not structKeyExists(currentValues, "uiTheme") )
		currentValues.uiTheme = "ui-lightness";
</cfscript>
<cfoutput>
	<script type="text/javascript">
		fieldProperties['#typeid#'].paramFields = "#prefix#beanName,#prefix#uiTheme";
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Bean Name:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#beanName" id="#prefix#beanName" value="#currentValues.beanName#" size="40"><br>
				Name of the Object Factory Bean that will hold the configuration for the file uploader. By default it is
				"file_uploader" and to be put into the /_cs_apps/components/ of the site. Note: Do NOT include ".cfc" in the name.
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">UI Theme:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#uiTheme" id="#prefix#uiTheme" class="cs_dlgControl" value="#currentValues.uiTheme#" size="50">
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