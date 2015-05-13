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
	Ron West
Custom Field Type:
	allow_edit_hidden
Name:
	allow_edit_hidden_render.cfc
Summary:
	Hidden field type that will run the default value on edit of the data.
	
	Primarily used to store the user id for the last updated.
ADF Requirements:
	None.
History:
	2009-06-29 - RLW - Created
	2010-11-04 - MFC - Updated props and render for the defaultValue in the paramFields variable.
	2012-10-01 - MFC - Updated to support fieldname containing "_" in a simple form.
	2015-05-12 - DJM - Converted to CFC
--->
<cfcomponent displayName="AllowEditHidden Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = Duplicate(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value

		// reset the currentValue to the currentDefault
		try
		{
			// if there is a user defined function for the default value
			if( inputParameters.useUDef )
				currentValue = evaluate(inputParameters.DEFAULTVALUE);
			else // standard text value
				currentValue = inputParameters.DEFAULTVALUE;
		}
		catch( any e)
		{
			; // let the current default value stand
		}
	</cfscript>
	<cfoutput>
		<input type="hidden" id="#arguments.fieldName#" name="#arguments.fieldName#" value="#currentValue#">
	</cfoutput>
</cffunction>

<cfscript>
	// all of these do nothing, field render only a hidden control
	public void function renderLabel() {}
	public void function renderFieldContainerStart() {}
	public void function renderFieldContainerEnd() {}
	public void function renderLabelContainerStart() {}
	public void function renderLabelContainerEnd() {}
	public void function renderControlContainerStart() {}
	public void function renderControlContainerEnd() {}
	public void function renderRequiredIndicator() {}
</cfscript>

</cfcomponent>