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
	G. Cronkright / M. Carroll 
Custom Field Type:
	Page Layout
Name:
	page_layout_props.cfm
Summary:
	Custom field to render predefined page layout options in metadata forms.
History:
	2010-09-09 - GAC/MFC - Created
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2014-09-19 - GAC - Removed deprecated doLabel and jsLabelUpdater js calls
	2015-05-12 - DJM - Updated the field version to 2.0
	2015-09-02 - DRM - Add getResourceDependencies support, bump version
	2016-02-16 - GAC - Added getResourceDependencies and loadResourceDependencies support to the Render
						  - Added the getResources check to the Props
						  - Bumped field version
	2016-06-07 - GAC - Updated to use config ini props format
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<!--- if this module loads resources, do it here.. --->
<cfscript>
   application.ADF.scripts.loadJQuery();
</cfscript>

<!--- ... then exit if all we're doing is detecting required resources --->
<cfif Request.RenderState.RenderMode EQ "getResources">
  <cfexit>
</cfif>


<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "2.0.0";

	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;

	//Setup the default values
	defaultValues = StructNew();
	defaultValues.pageLayoutScript = defaultScriptText();

	//defaultValues.defaultText = "This is the defaulted text";
	//defaultValues.useUdef = 0;
	//defaultValues.defaultValue = "";

   //This will override the default values with the current values.
   //In normal use this should not need to be modified.
   currentValueArray = StructKeyArray(currentValues);
   for(i=1;i<=ArrayLen(currentValueArray);i++){
      //If there is a default value set AND there is a current value set update the default value with the current value
      if( StructKeyExists(defaultValues,currentValueArray[i]) AND LEN(TRIM(currentValues[currentValueArray[i]])) )
      {
         defaultValues[currentValueArray[i]] = currentValues[currentValueArray[i]];
      }
   }

	// Get the cfmlEngine type
	cfmlEngine = server.coldfusion.productname;
	if ( !FindNoCase(cfmlEngine,'ColdFusion Server') )
	{
		// For Lucee Inject Extra linebreaks before each open bracket (since the textarea removes them)
		defaultValues.pageLayoutScript = REReplace(defaultValues.pageLayoutScript, "(\r\n|\n\r|\n|\r)(\[)","&##013;&##010;&##013;&##010;[", "all");
		defaultValues.pageLayoutScript = REReplace(defaultValues.pageLayoutScript, "(\r\n|\n\r|\n|\r)(##\[)","&##013;&##010;&##013;&##010;##[", "all");
	}
</cfscript>

<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object, this uses the name of the field
		fieldProperties['#typeid#'].paramFields = '#prefix#defaultText,#prefix#pageLayoutScript';
		//fieldProperties['#typeid#'].paramFields = '#prefix#defaultText,#prefix#useUdef,#prefix#currentDefault';
		//fieldProperties['#typeid#'].defaultValueField = '#prefix#defaultValue';

		// allows this field to have a common onSubmit Validator
		fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';

		//Validation function, this specific instance checks to verify they entered a valid value.
		function #prefix#doValidate(){
			if(jQuery("###prefix#pageLayoutScript").val().length){
				return true;
			}
			alert("Please enter configuration syntax.");
			return false;
		}
	</script>
	<style>
			textarea###prefix#pageLayoutScript {
				overflow: auto; /* overflow is needed */
				resize: vertical;
			}
		</style>
	<table>
		<tr>
			<td class="cs_dlgLabelSmall" valign="top">
				<label for="#prefix#pageLayoutScript">Layout Script:</label>
			</td>
			<td class="cs_dlgLabelSmall">
				<div>Enter PageLayoutScript configuration syntax to generate Page Layout Options.</div>
				<textarea id="#prefix#pageLayoutScript" name="#prefix#pageLayoutScript" cols="80" rows="20" wrap="off">#defaultValues.pageLayoutScript#</textarea>
			</td>
		</tr>

		<!--- <tr>
			<td class="cs_dlgLabelSmall">
				<label for="#prefix#defaultValue">Default Text:</label>
			</td>
			<!---
				Example text field, allowing people to specify the default value in the properties dialog
				name is specified in paramFields
				value is updated in the defaultValues structure
			--->
			<td class="cs_dlgLabelSmall">
				<input type="text" id="#prefix#defaultText" name="#prefix#defaultText" value="#defaultValues.defaultText#">
			</td>
		</tr> --->

		<!--- <cfinclude template="/commonspot/metadata/form_control/input_control/default_value.cfm"> --->

		<tr>
			<td class="cs_dlgLabelSmall" colspan="2" style="font-size:7pt;">
				<hr />
				ADF Custom Field v#fieldVersion#
			</td>
		</tr>
	</table>
</cfoutput>

<!---
	defaultScriptText()
	
	pageLayoutScript Syntax:
	
	[Config]
	options = Home,Three-Column,Left-Column
		## Comma-Delimited List of Layout Option Values in the order of display. (NO-SPACES-IN-OPTION-VALUES)
	imagepath = /customfields/page_layout/thumbs/ 
		## Server relative path to the layout thumbnail image directory (with trailing slash / )
	disabledpages = 1001,1002
		## Optional
		## Omit or set to no value to render options for All bound pages
		## Comma-Delimited List of Pages that will not render any Layout Option Values
		## Overriden by allowedpages and allowedgroups
			
	[option-value]
	description = Option Display Name
		## Required
		## Renders above the thumbnail image	
	image = home.gif
		## Optional
		## Can be overridden by using the imageURL parameter
		## image file name
	imageURL = /images/thumbs/home.gif
		## Optional 
		## Use as an override for the 'image' parameter
		## Server relative path to the image file
	allowedgroups = site administrator,admin-commonspot
		## Optional 
		## Omit or set to no value to render option for All contributors
		## Comma-Delimited List of CommonSpot User Group Names that can view the option	
		## Overrides allowedpages 
	allowedpages = 1001,1002
		## Optional
		## Omit or set to no value to render option for All contributors
		## Comma-Delimited List of CommonSpot Page Ids (or template Ids) that allow this option		
--->
<cffunction name="defaultScriptText" access="public" returntype="string" output="true">

	<cfset var retVal = "">

<cfsavecontent variable="retVal"><cfoutput>[Config]
options=Home,Three-Column,Left-Column,Right-Column,Full-Width,Equal-Width
imagespath=/ADF/extensions/customfields/page_layout/thumbs/
disabledpages=

[Home]
description=Home
image=home.gif
allowedgroups=
allowedpages=

[Three-Column]
description=Three Columns
image=landing.gif
allowedgroups=
allowedpages=

[Left-Column]
description=Left Column
image=right_channel.gif
allowedgroups=
allowedpages=

[Right-Column]
description=Right Column
image=right_channel.gif
allowedgroups=
allowedpages=

[Full-Width]
description=Full Width
image=full_width.gif
allowedgroups=
allowedpages=

[Equal-Width]
description=Equal Width
image=equal_width.gif
allowedgroups=
allowedpages=
</cfoutput></cfsavecontent>
	
	<cfset retVal = REReplace(retVal, "(\r\n|\n\r|\n|\r)","&##013;&##010;", "all")>
	
	<cfreturn retVal>
</cffunction>