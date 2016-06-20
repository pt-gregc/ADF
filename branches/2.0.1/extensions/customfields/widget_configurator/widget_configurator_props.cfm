<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the Starter App directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2016.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$widget_configurator_props.cfm
Summary:
	Widget Option Configurator Props
History:
 	2016-05-20 - GAC - Created
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
	fieldVersion = "1.0.0";

	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;

	//Setup the default values
	defaultValues = StructNew();
	defaultValues.widgetScript = defaultScriptText();
	defaultValues.defaultText = "This is the defaulted text";
	//defaultValues.useUdef = 0;
	//defaultValues.defaultValue = "";

   //This will override the default values with the current values.
   //In normal use this should not need to be modified.
   currentValueArray = StructKeyArray(currentValues);
   for(i=1;i<=ArrayLen(currentValueArray);i++){
      //If there is a default value set AND there is a current value set update the default value with the current value
      if(StructKeyExists(defaultValues,currentValueArray[i])){
         defaultValues[currentValueArray[i]] = currentValues[currentValueArray[i]];
      }
   }
	
	// Get the cfmlEngine type
	cfmlEngine = server.coldfusion.productname;
	if ( !FindNoCase(cfmlEngine,'ColdFusion Server') )
	{
		// For Lucee Inject Extra linebreaks before each open bracket (since the textarea removes them)
		defaultValues.widgetScript = REReplace(defaultValues.widgetScript, "(\r\n|\n\r|\n|\r)(\[)","&##013;&##010;&##013;&##010;[", "all");
		defaultValues.widgetScript = REReplace(defaultValues.widgetScript, "(\r\n|\n\r|\n|\r)(##\[)","&##013;&##010;&##013;&##010;##[", "all");
	}
</cfscript>

<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object, this uses the name of the field
		fieldProperties['#typeid#'].paramFields = '#prefix#defaultText,#prefix#widgetScript';
		//fieldProperties['#typeid#'].paramFields = '#prefix#defaultText,#prefix#useUdef,#prefix#currentDefault';
		//fieldProperties['#typeid#'].defaultValueField = '#prefix#defaultValue';

		// allows this field to have a common onSubmit Validator
		fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';

		//Validation function, this specific instance checks to verify they entered a valid value.
		function #prefix#doValidate(){
			if(jQuery("###prefix#widgetScript").val().length){
				return true;
			}
			alert("Please enter configuration syntax for the Widget Script value.");
			return false;
		}
	</script>
	<style>
			textarea###prefix#widgetScript {
				overflow: auto; /* overflow is needed */
				resize: vertical;
			}
		</style>
	<table>
		<tr>
			<td class="cs_dlgLabelSmall" valign="top">
				<label for="#prefix#widgetScript">Widget Script:</label>
			</td>
			<td class="cs_dlgLabelSmall">
				<div>Enter Widget Script syntax to generate Widget Option Configuration Fields.</div>
				<textarea id="#prefix#widgetScript" name="#prefix#widgetScript" cols="80" rows="20" wrap="off">#defaultValues.widgetScript#</textarea>
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

	widgetScript Syntax:

	[Config]
	fields = field1,field2,field2
		## Comma-Delimited List of fields

	[{fieldname}]
	group_{groupname} = option1,option2,option3
		## Optional
	group_default = option1,option2;
		## Required
	description = Option Display Name
		## Optional
--->
<cffunction name="defaultScriptText" access="public" returntype="string" output="true">

	<cfset var retVal = "">

<cfsavecontent variable="retVal"><cfoutput>[Config]
fields=Color,Alignement

[Color]
group_admin=Red,Yellow,Orange,Purple
group_default=Red,Yellow,Orange
description=Select a color

[Alignement]
group_default=Left,Center,Right
description=Select an Alignement
</cfoutput></cfsavecontent>

	<cfset retVal = REReplace(retVal, "(\r\n|\n\r|\n|\r)","&##013;&##010;", "all")>

	<cfreturn retVal>
</cffunction>