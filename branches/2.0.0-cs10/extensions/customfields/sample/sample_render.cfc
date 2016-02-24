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
	Ryan Kahn
Name:
	$sample_render.cfc
Summary:
	Sample render file, this will output a simple text element for the user to enter data in
History:
 	2011-09-26 - RAK - Created
	2011-12-19 - MFC - Updated the validation for the property fields.
	2012-03-19 - GAC - Added the fieldPermission parameter to the wrapFieldHTML function call
	2012-04-11 - GAC - Added the includeLabel and includeDescription parameters to the wrapFieldHTML function call
					 - Updated the readOnly check to also use the cs6 fieldPermission parameter
					 - Updated the wrapFieldHTML explanation comment block
	2015-04-29 - DJM - Converted to CFC
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean()
	2016-02-09 - GAC - Updated duplicateBean() to use data_2_0.duplicateStruct()
	2016-02-16 - GAC - Added getResourceDependencies support
						  - Added loadResourceDependencies support
						  - Moved resource loading to the loadResourceDependencies() method
--->
<cfcomponent displayName="Sample Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;

		// Validate the property fields are defined
		if( !Len(currentvalue) AND StructKeyExists(inputParameters, "defaultText") )
		{
			currentValue = inputParameters.defaultText;
		}
	</cfscript>

	<cfoutput>
		<input name="#arguments.fieldName#" id='#arguments.fieldName#' value="#currentValue#" <cfif readOnly>disabled="disabled"</cfif>>
	</cfoutput>
</cffunction>

<cfscript>
	private any function getValidationJS(required string formName, required string fieldName, required boolean isRequired)
	{
		if (arguments.isRequired)
			return 'hasValue(document.#arguments.formName#.#arguments.fieldName#, "TEXT")';
		return "";
	}

	/*
		IMPORTANT: Since loadResourceDependencies() is using ADF.scripts loadResources methods, getResourceDependencies() and
		loadResourceDependencies() must stay in sync by accounting for all of required resources for this Custom Field Type.
	*/
	public void function loadResourceDependencies()
	{
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		
		if ( !StructKeyExists(inputParameters,"uiTheme") )
			inputParameters.uiTheme = "ui-lightness";
		
		// Load registered Resources via the ADF scripts_2_0
		application.ADF.scripts.loadJQuery();
		application.ADF.scripts.loadJQueryUI(themeName=inputParameters.uiTheme);
	}
	public string function getResourceDependencies()
	{
		return "jQuery,jQueryUI,jQueryUIDefaultTheme";
	}
</cfscript>
</cfcomponent>