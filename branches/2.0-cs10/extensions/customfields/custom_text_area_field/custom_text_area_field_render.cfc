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
Custom Field Type:
	Custom Text Area Field
Name:
	custom_text_area_field_render.cfc
Summary:
	Allows for an text area field to have a specific class name. 
ADF Requirements:
	forms_1_1
Version:
	2.0.0
History:
	2009-07-06 - MFC - Created
	2009-08-14 - GAC - Converted to Custom Text Area With Class
	2009-08-20 - GAC - Added code for the required field option
	2010-07-08 - DMB - Added support for custom field name
	2010-08-02 - DMB - Modified to display the label using Commonspot CSS for a required field.
	2011-12-06 - GAC - Updated to use the wrapFieldHTML from ADF lib forms_1_1
	2012-01-05 - GAC - Added a default variables for the props parameters
	2012-01-10 - GAC - Removed obsolete show/hide field description logic
	2012-04-11 - GAC - Changed the includeDescription option to be true by default
					 - Updated the readOnly check to use the cs6 fieldPermission parameter
					 - Updated the wrapFieldHTML explanation comment block
	2012-04-13 - GAC - Fixed an issue with the Textarea Field ID not getting a value if a xparams.fldName was not entered in the props 
					 - Added an optional parameter to assign a CSS property to the textarea field resizing handle
	2014-12-15 - GAC - Fixed the Default Value and the user defined expression functionality
	2015-04-27 - DJM - Added own CSS
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 
--->
<cfcomponent displayName="CustomTextAreaField Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		
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
		
		renderStyles(argumentCollection=arguments);
	</cfscript>
	<cfoutput>
		<textarea name="#arguments.fieldName#" id="#inputParameters.fldName#" cols="#inputParameters.columns#" rows="#inputParameters.rows#"<cfif LEN(TRIM(inputParameters.fldClass))> class="#inputParameters.fldClass#"</cfif> wrap="#inputParameters.wrap#"<cfif readOnly> readonly="readonly"</cfif>>#currentValue#</textarea>
	</cfoutput>
</cffunction>

<cffunction name="renderStyles" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		// Valid Textarea resize handle options
		var resizeOptions = "none,both,horizontal,vertical";
	</cfscript>
	<!--- // If the browser supports a textarea resizing handle apply the option --->
	<cfif LEN(TRIM(inputParameters.resizeHandleOption)) AND ListFindNoCase(resizeOptions,inputParameters.resizeHandleOption)>
		<cfoutput><style>
			textarea###inputParameters.fldName# {
				<cfif inputParameters.resizeHandleOption EQ "none">
				resize: #inputParameters.resizeHandleOption#;
				<cfelse>
				overflow: auto; /* overflow is needed */  
				resize: #inputParameters.resizeHandleOption#; 
				</cfif> 
			}
		</style></cfoutput>
	</cfif>	
</cffunction>

<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		
		if ( NOT StructKeyExists(inputParameters, "fldName") OR LEN(TRIM(inputParameters.fldName)) EQ 0 )
			inputParameters.fldName = arguments.fieldName;
		if ( NOT StructKeyExists(inputParameters, "columns") )
			inputParameters.columns = "40";
		if ( NOT StructKeyExists(inputParameters, "rows") )
			inputParameters.rows = "4";
		if ( NOT StructKeyExists(inputParameters, "wrap") )
			inputParameters.wrap = 'virtual';
		if ( NOT StructKeyExists(inputParameters, "fldClass") )
			inputParameters.fldClass = "";
		if ( NOT StructKeyExists(inputParameters,"resizeHandleOption" ) )
			inputParameters.resizeHandleOption = "default";
		
		return inputParameters;
	</cfscript>
</cffunction>

<cfscript>
	private any function getValidationJS(required string formName, required string fieldName, required boolean isRequired)
	{
		return 'checkTxtArea(document.#arguments.formName#.#arguments.fieldName#.value, "#arguments.label#", 0, "#arguments.isRequired#")';
	}
	private string function getValidationMsg()
	{
		return ''; // validator does alert itself dynamically, this keeps the default alert from happening too
	}
	private boolean function isMultiline()
	{
		return true;
	}
</cfscript>

</cfcomponent>