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
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	Michael Carroll 
Custom Field Type:
	Custom Text Field
Name:
	custom_text_field_render.cfc
Summary:
	Custom text field to specify a field ID and action property set to allow one edit, 
		then the field is read only.
ADF Requirements:
	data_1_0
History:
	2009-10-15 - MFC - Created
	2011-02-08 - MFC - Updated the "fldName" prop to "fldID" variable.
	2011-06-30 - MFC - Changed ADF server object call to Data_1_0 to call "application.ADF.data".
	2013-01-10 - MFC - Updated the field to use the "forms.wrapFieldHTML" function.
	2013-02-14 - GAC - Updated to add in the CS6+ security setting for the wrapFieldHTML function
					 - Cleaned up old and unnecessary code
	2015-04-27 - DJM - Added own CSS
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean()
	2016-02-09 - GAC - Updated duplicateBean() to use data_2_0.duplicateStruct()
--->
<cfcomponent displayName="CustomTextField Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);
		
		// if no current value entered
		if ( NOT LEN(currentValue) ){
			// reset the currentValue to the currentDefault
			try
			{
				// if there is a user defined function for the default value
				if( inputParameters.useUDef )
					currentValue = evaluate(inputParameters.currentDefault);
				else // standard text value
					currentValue = inputParameters.currentDefault;
			}
			catch( any e)
			{
				; // let the current default value stand
			}
		}
		
		// Check the Edit Once flag 
		if ( LEN(currentValue) AND inputParameters.editOnce )
			readOnly = true;
			
		// Load JQuery
		application.ADF.scripts.loadJQuery();
	</cfscript>
	
	<cfoutput>
		<!--- // Render the input field --->
		<input type="text" name="#arguments.fieldName#" value="#currentValue#" id="#inputParameters.fldID#" size="#inputParameters.fldSize#"<cfif LEN(TRIM(inputParameters.fldClass))> class="#inputParameters.fldClass#"</cfif> tabindex="#arguments.renderTabIndex#" <cfif readOnly>readonly="true"</cfif>>
	</cfoutput>
</cffunction>

<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		
		if ( NOT StructKeyExists(inputParameters, "fldName") )
		inputParameters.fldName = arguments.fieldName;
		
		// Set the field ID from the field name
		inputParameters.fldID = inputParameters.fldName;
		
		if ( NOT StructKeyExists(inputParameters, "fldClass") )
			inputParameters.fldClass = "";
		if ( not structKeyExists(inputParameters, "fldSize") )
			inputParameters.fldSize = "40";
		if ( NOT StructKeyExists(inputParameters, "editOnce") )
			inputParameters.editOnce = 0;
		
		return inputParameters;
	</cfscript>	
</cffunction>

<cfscript>
	private any function getValidationJS(required string formName, required string fieldName, required boolean isRequired)
	{
		if (arguments.isRequired)
			return 'hasValue(document.#arguments.formName#.#arguments.fieldName#, "TEXT")';
		return '';
	}

	public string function getResourceDependencies()
	{
		return listAppend(super.getResourceDependencies(), "jQuery");
	}
</cfscript>

</cfcomponent>