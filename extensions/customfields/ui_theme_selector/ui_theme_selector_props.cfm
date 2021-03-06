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
	G. Cronkright
Name:
	ui_theme_selector_props.cfm
Summary:
	CFT to render a list for jquery UI theme options
Version:
	2.0
History:
	2011-06-14 - GAC - Created
	2011-06-16 - GAC - Fixed the default jqueryUIurl and slashes for non Windows OS's
	2011-07-07 - GAC - Fixed a typo in the property field label
	2012-01-11 - GAC - set jqueryUIurl to match the case of the directory structure
	2012-02-21 - GAC - added fixes additional fixes for slashes 
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2014-09-19 - GAC - Removed deprecated doLabel and jsLabelUpdater js calls
	2015-05-12 - DJM - Updated the field version to 2.0
	2015-09-02 - DRM - Add getResourceDependencies support, bump version
	2016-02-16 - GAC - Added getResourceDependencies and loadResourceDependencies support to the Render
			     		  - Added the getResources check to the Props
			     		  - Bumped field version
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
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "2.0.4";
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	
	uiFilterStr = "jquery-ui";
	defaultVersion = "jquery-ui-1.11";
	jQueryUIurl = "/ADF/thirdParty/jquery/ui";
	jQueryUIpath = Replace(ExpandPath(jQueryUIurl),"\","/","all");

	if( not structKeyExists(currentValues, "uiVersionPath") )
		currentValues.uiVersionPath = Replace(jQueryUIpath & '/' & defaultVersion,"\","/","all");
</cfscript>

<!--- // Get a list of jQuery UI versions --->
<cfdirectory action="list" directory="#jQueryUIpath#" name="qVersions" type="dir">
<!--- <cfdump var ="#qVersions#" expand="false"> --->

<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object
		fieldProperties['#typeid#'].paramFields = '#prefix#uiVersionPath';
		// allows this field to have a common onSubmit Validator
		//fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
		
		/*	function #prefix#doValidate()
			{
				//set the default msgvalue
				document.#formname#.#prefix#msg.value = 'Please enter some text to be converted';
				if( document.#formname#.#prefix#foo.value.length == 0 )
				{
					alert('please Enter some data for foo');
					return false;
				}
				return true;
			}
		*/
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Select an installed jQuery UI Version:</td>
			<td class="cs_dlgLabelSmall">
				<select name="#prefix#uiVersionPath" id="#prefix#uiVersionPath" class="cs_dlgControl">
		           	<cfloop query="qVersions">
			           	<cfif FindNoCase(uiFilterStr,name)>
				            <cfset uiThemePath = Replace(qVersions.directory & '/' & qVersions.name,"\","/","all")>
				           	<option value="#uiThemePath#"<cfif currentValues.uiVersionPath EQ uiThemePath> selected="selected"</cfif>>#qVersions.name#</option>
		            	</cfif>
					</cfloop>
		        </select>
				<!--- <br/><span>Prop Field Description Text.</span> --->
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