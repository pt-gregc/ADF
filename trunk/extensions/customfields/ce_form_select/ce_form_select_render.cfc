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
	M. Carroll
Name:
	ce_form_select_render.cfc
Summary:
	CFT to select a custom element from a select field.
	Stores the CE Form ID.
Version:
	1.0.0
History:
	2011-04-08 - MFC - Created
	2011-09-16 - MFC - Loaded JQuery for the validation.
	2012-04-11 - GAC - Added the fieldPermission parameter to the wrapFieldHTML function call
					 - Added the includeLabel and includeDescription parameters to the wrapFieldHTML function call
					 - Added readOnly field security code with the cs6 fieldPermission parameter					 
					 - Updated the wrapFieldHTML explanation comment block
	2015-05-12 - DJM - Converted to CFC
	2015-09-10 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 
--->
<cfcomponent displayName="CEFormSelect Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		var customElementQry = application.ADF.ceData.getAllCustomElements();
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);
		
		// Load JQuery
		application.ADF.scripts.loadJQuery();
	</cfscript>

	<cfoutput>
		<select name="#arguments.fieldName#" id='#inputParameters.fldID#' <cfif readOnly>disabled="disabled"</cfif>>
			<option value=""> -- select --
			<!--- Loop over the query --->
			<cfloop query="customElementQry">
				<option value="#customElementQry.ID#" <cfif currentValue EQ ID>selected</cfif>>#customElementQry.FormName#
			</cfloop>
		</select>
	</cfoutput>
</cffunction>

<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		
		// Validate if the property field has been defined
		if ( NOT StructKeyExists(inputParameters, "fldID") OR LEN(inputParameters.fldID) LTE 0 )
			inputParameters.fldID = arguments.fieldName;
		
		return inputParameters;
	</cfscript>
</cffunction>

<cfscript>
	private any function getValidationJS(required string formName, required string fieldName, required boolean isRequired)
	{
		if (arguments.isRequired)
			return 'hasValue(document.#arguments.formName#.#arguments.fieldName#, "TEXT")';
		return "";
	}
	
	private string function getValidationMsg()
	{
		return "Please select a value for the #arguments.label# field.";
	}

	public string function getResourceDependencies()
	{
		return listAppend(super.getResourceDependencies(), "jQuery");
	}
</cfscript>

</cfcomponent>