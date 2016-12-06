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
	padding_settings_render.cfc
Summary:
	Custom field to build the Date/Time records.
	This field generates a collection of Date and Times for the field.
Version:
	1.0.0
History:
	2014-09-15 - Created
	2014-09-29 - GAC - Added Padding Value normalization to remove the label from the default values
	2015-04-28 - DJM - Added own CSS
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean()
	2016-02-09 - GAC - Updated duplicateBean() to use data_2_0.duplicateStruct()
	2016-02-16 - GAC - Added getResourceDependencies support
	                 - Added loadResourceDependencies support
	                 - Moved resource loading to the loadResourceDependencies() method
--->
<cfcomponent displayName="PaddingSettings Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var top = '';
		var right = '';
		var bottom = '';
		var left = '';

		inputParameters = setDefaultParameters(argumentCollection=arguments);
		
		if( currentValue eq '' )
		{
			top = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=inputParameters.top);	
			right = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=inputParameters.right);	
			bottom = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=inputParameters.bottom);	
			left = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=inputParameters.left);	
		}		
		else
		{
			top = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=ListGetAt( currentValue, 1, ' ' ) );	
			right = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=ListGetAt( currentValue, 2, ' ' ) );	
			bottom = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=ListGetAt( currentValue, 3, ' ' ) );	
			left = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=ListGetAt( currentValue, 4, ' ' ) );	
		}
		
		currentValue = top & 'px ' & right & 'px ' & bottom & 'px ' & left & 'px';
		
		// TODO: add a function that strips the px off of each value in the possible values string
		// TODO: make sure each value in the possible values string is numeric
		// TODO: strip the px off of the current value string before converting to individual values
	</cfscript>
	
	<cfoutput>
		<div>
			<cfif LEN(TRIM(inputParameters.possibleValues))>
				#application.ADF.paddingSettings.renderSelectionList(inputParameters.showTop,'Top:',inputParameters.FieldID,'Top',top,inputParameters.possibleValues)#
				#application.ADF.paddingSettings.renderSelectionList(inputParameters.showRight,'Right:',inputParameters.FieldID,'Right',right,inputParameters.possibleValues)#
				#application.ADF.paddingSettings.renderSelectionList(inputParameters.showBottom,'Bottom:',inputParameters.FieldID,'Bottom',bottom,inputParameters.possibleValues)#
				#application.ADF.paddingSettings.renderSelectionList(inputParameters.showLeft,'Left:',inputParameters.FieldID,'Left',left,inputParameters.possibleValues)#
			<cfelse>
				#application.ADF.paddingSettings.renderTextInput(inputParameters.showTop,'Top:',inputParameters.FieldID,'Top',top)#
				#application.ADF.paddingSettings.renderTextInput(inputParameters.showRight,'Right:',inputParameters.FieldID,'Right',right)#
				#application.ADF.paddingSettings.renderTextInput(inputParameters.showBottom,'Bottom:',inputParameters.FieldID,'Bottom',bottom)#
				#application.ADF.paddingSettings.renderTextInput(inputParameters.showLeft,'Left:',inputParameters.FieldID,'Left',left)#
			</cfif>
			<!--- // hidden field to store the value --->
			<input type="hidden" name="#arguments.fieldName#" value="#currentValue#" id="#inputParameters.fieldID#" class="#inputParameters.fieldClass#">
		</div>
	</cfoutput>
	<cfscript>
		renderJSFunctions(argumentCollection=arguments,fieldParameters=inputParameters);
	</cfscript>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="fieldParameters" type="struct" required="yes">
	
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.fieldParameters);
	</cfscript>
<cfoutput>
<script type="text/javascript">
<!--
function onChange_#inputParameters.fieldID#()
{
	var t = jQuery('###inputParameters.fieldID#_Top').val();
	var r = jQuery('###inputParameters.fieldID#_Right').val();
	var b = jQuery('###inputParameters.fieldID#_Bottom').val();
	var l = jQuery('###inputParameters.fieldID#_Left').val();
	
	<!--- // TODO: Add a JS function to parse the input values and build the valid padding string --->
	
	jQuery('###inputParameters.fieldID#').val(t + 'px ' + r + 'px ' + b + 'px ' + l + 'px'); 
}
//-->
</script></cfoutput>
</cffunction>

<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		
		// Validate if the property field has been defined
		if ( NOT StructKeyExists(inputParameters, "fldID") OR LEN(inputParameters.fldID) LTE 0 )
			inputParameters.fldID = arguments.fieldName;
		if ( NOT StructKeyExists(inputParameters, "fieldID") )
			inputParameters.fieldID = arguments.fieldName;
		if ( (NOT StructKeyExists(inputParameters, "fieldClass")) OR ( LEN(TRIM(inputParameters.fieldClass)) LTE 0) )
			inputParameters.fieldClass = "";
		
		// Remove any labels from the possibleValues String
		if ( StructKeyExists(inputParameters, "possibleValues") AND LEN(TRIM(inputParameters.possibleValues)) )
			inputParameters.possibleValues = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=inputParameters.possibleValues);
		else
			inputParameters.possibleValues = "";
		
		if( NOT StructKeyExists( inputParameters, 'ShowTop' ) )
			inputParameters.ShowTop = 0;
		if( NOT StructKeyExists( inputParameters, 'ShowRight' ) )
			inputParameters.ShowRight = 0;
		if( NOT StructKeyExists( inputParameters, 'ShowBottom' ) )
			inputParameters.ShowBottom = 0;
		if( NOT StructKeyExists( inputParameters, 'ShowLeft' ) )
			inputParameters.ShowLeft = 0;
		
		return inputParameters;
	</cfscript>
</cffunction>


<cfscript>
	/*
		IMPORTANT: Since loadResourceDependencies() is using ADF.scripts loadResources methods, getResourceDependencies() and
		loadResourceDependencies() must stay in sync by accounting for all of required resources for this Custom Field Type.
	*/
	public void function loadResourceDependencies()
	{
		// Load registered Resources via the ADF scripts_2_0
		application.ADF.scripts.loadJQuery();
	}
	public string function getResourceDependencies()
	{
		return "jQuery";
	}
</cfscript>

</cfcomponent>