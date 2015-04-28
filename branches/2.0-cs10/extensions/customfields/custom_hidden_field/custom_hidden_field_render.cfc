<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
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
	Custom Hidden Field
Name:
	custom_hidden_field_render.cfc
Summary:
	Custom hidden field type, that allows to assign a field ID and class name to the hidden field.
ADF Requirements:
	None
History:
	2009-09-01 - MFC - Created
	2015-04-28 - DJM - Added own CSS
--->
<cfcomponent displayName="CustomHiddenField Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">

	<cfscript>
		var inputParameters = Duplicate(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);
		
		// if no current value entered
		if ( NOT LEN(currentValue) )
		{
			// reset the currentValue to the currentDefault
			try
			{
				// if there is a user defined function for the default value
				if ( inputParameters.useUDef )
					currentValue = evaluate(inputParameters.currentDefault);
				else // standard text value
					currentValue = inputParameters.currentDefault;
			}
			catch( any e)
			{
				; // let the current default value stand
			}
		}
</cfscript>
<cfoutput>
	<!--- hidden field to store the value --->
	<input type="hidden" name="#arguments.fieldName#" value="#currentValue#" id="#inputParameters.fieldID#" class="#inputParameters.fieldClass#">
</cfoutput>
</cffunction>

<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = Duplicate(arguments.parameters);
		
		if ( NOT StructKeyExists(inputParameters, "fieldID") )
			inputParameters.fieldID = arguments.fieldName;
		if ( (NOT StructKeyExists(inputParameters, "fieldClass")) OR ( LEN(TRIM(inputParameters.fieldClass)) LTE 0) )
			inputParameters.fieldClass = "";
		
		return inputParameters;
	</cfscript>
</cffunction>

</cfcomponent>