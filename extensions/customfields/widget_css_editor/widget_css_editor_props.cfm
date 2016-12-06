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
	$widget_css_editor_render.cfc
Summary:
	Widget CSS Resource Editor
History:
 	2016-06-01 - GAC - Created
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
	defaultValues.resourceName = "";
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
	
	// Inject Extra linebreaks before each open bracket (since thw textarea removes them)
	//defaultValues.widgetScript = REReplace(defaultValues.widgetScript, "(\r\n|\n\r|\n|\r)\[","&##013;&##010;&##013;&##010;[", "all");
</cfscript>

<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object, this uses the name of the field
		fieldProperties['#typeid#'].paramFields = '#prefix#resourceName';

		//fieldProperties['#typeid#'].paramFields = '#prefix#defaultText,#prefix#useUdef,#prefix#currentDefault';
		//fieldProperties['#typeid#'].defaultValueField = '#prefix#defaultValue';

		// allows this field to have a common onSubmit Validator
		fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';

		//Validation function, this specific instance checks to verify they entered a valid value.
		function #prefix#doValidate(){
			if(jQuery("###prefix#resourceName").val().length){
				return true;
			}
			alert("Please enter the resource name for the CSS file to edit.");
			return false;
		}
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelSmall">
				<label for="#prefix#resourceName">Resource Name:</label>
			</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" id="#prefix#resourceName" name="#prefix#resourceName" value="#defaultValues.resourceName#" class="cs_dlgControl" size="60">
			</td>
		</tr>
		
		<!--- <cfinclude template="/commonspot/metadata/form_control/input_control/default_value.cfm"> --->
		
		<tr>
			<td class="cs_dlgLabelSmall" colspan="2" style="font-size:7pt;">
				<hr />
				ADF Custom Field v#fieldVersion#
			</td>
		</tr>
	</table>
</cfoutput>