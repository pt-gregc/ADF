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
--->
<cfcomponent displayName="Sample Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = Duplicate(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;

		// Validate the property fields are defined
		if(!Len(currentvalue) AND StructKeyExists(inputParameters, "defaultText")){
			currentValue = inputParameters.defaultText;
		}
		
		// Load JQuery
		application.ADF.scripts.loadJQuery();
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

	public string function getResourceDependencies()
	{
		return listAppend(super.getResourceDependencies(), "jQuery");
	}
</cfscript>
</cfcomponent>