<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the Starter App directory

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
	G. Cronkright 
Custom Field Type:
	Custom Section Label Field
Name:
	$custom_section_label_render.cfc
Summary:
	Label Custom Field
History:
 	2012-03-19 - GAC - Created
	2015-05-13 - DJM - Converted to CFC
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean()
	2016-02-09 - GAC - Updated duplicateBean() to use data_2_0.duplicateStruct()
	2016-02-22 - GAC - Added getResourceDependencies support
	                 - Added loadResourceDependencies support
			 			  - Moved resource loading to the loadResourceDependencies() method
	2016-02-22 - DRM - Fixed a missing DIV issue
--->
<cfcomponent displayName="CustomSectionLabel Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderStandard" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		// Get the Description 
		var description = "";
		var idHTML = (arguments.fieldDomID != "") ? ' id="#arguments.fieldDomID#_label"': '';
		var className = '';
		var classHTML = '';
		var _labelClass = (arguments.labelClass != "") ? " #arguments.labelClass#" : "";
		var labelTagHTML = '';
		var labelTagAppend = '';
		var descAppend = '';

		inputParameters = setDefaultParameters(argumentCollection=arguments);
		
		if ( StructKeyExists(fieldQuery,"DESCRIPTION") )
			description = fieldQuery.DESCRIPTION[fieldQuery.currentRow];
		if (Len(inputParameters.labelID))
			labelTagAppend = labelTagAppend & ' id="#inputParameters.labelID#"';
		if (Len(inputParameters.labelClass))
			labelTagAppend = labelTagAppend & ' class=#inputParameters.labelClass#';
		
		if (inputParameters.hideLabelText)
			labelTagHTML = "<span#labelTagAppend#>";
		else
			labelTagHTML = ((StructKeyExists(arguments, 'noLabelTag') AND arguments.noLabelTag) || arguments.fieldDomID == "") ? "" : "<label#labelTagAppend#>";

		renderFieldContainerStart(argumentCollection=arguments);
		
		// Overriding renderLabelContainerStart
		writeOutput('<div#idHTML# class="CS_FormFieldLabelContainer#_labelClass#" style="width:100% !important; text-align:left !important;">#labelTagHTML#');
		
		// Conditional overriding renderLabelContainerEnd
		if (inputParameters.hideLabelText)
			writeOutput('</span>');
		else
			renderLabel(argumentCollection=arguments);

		renderLabelContainerEnd(argumentCollection=arguments);
		
		renderControlContainerStart(argumentCollection=arguments);
		renderControlContainerEnd(argumentCollection=arguments);
		renderFieldContainerEnd(argumentCollection=arguments);
		
		if (LEN(TRIM(description)))
		{
			renderDescrContainerStart(argumentCollection=arguments);
			
			// Overriding renderLabelContainerStart
			writeOutput('<div class="CS_FormFieldLabelContainer" style="text-align:left !important; display: none !important;">');
			
			renderLabelContainerEnd(noLabelTag=true);
			
			// Overriding renderControlContainerStart
			className = getComponentClasses("Description");
			idHTML = (arguments.fieldDomID != "") ? ' id="#arguments.fieldDomID#_controls"': '';
			classHTML = (className != "") ? " #className#" : "";
			writeOutput('<div class="CS_FormFieldControlContainer#classHTML#"#idHTML# style="padding-left:0px">');
			
			// Aditional DIV added for description ID and class
			if (LEN(inputParameters.descptID) OR LEN(inputParameters.descptClass))
			{
				if (Len(inputParameters.descptID))
					descAppend = descAppend & ' id="#inputParameters.descptID#"';
				if (Len(inputParameters.descptClass))
					descAppend = descAppend & ' class=#inputParameters.descptClass#';
				WriteOutput('<div#descAppend#>');
			}
			
			renderDescriptionWrapper(argumentCollection=arguments);
			
			if (LEN(inputParameters.descptID) OR LEN(inputParameters.descptClass))
			{
				WriteOutput('</div>');
			}
			renderControlContainerEnd();
			renderDescrContainerEnd();
		}
	</cfscript>
</cffunction>

<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		
		// Set the label ID from the field name
		//if ( NOT StructKeyExists(inputParameters, "labelID") OR LEN(TRIM(inputParameters.labelID)) EQ 0 )
			//inputParameters.labelID = TRIM(ReplaceNoCase(arguments.fieldName,'fic_','')) & "_LABEL";
		
		// Set the Label Class Name 
		if ( NOT StructKeyExists(inputParameters, "labelClass") )
			inputParameters.labelClass = "";
		
		// Set the decription DIV ID 
		if ( NOT StructKeyExists(inputParameters, "descptID") )
			inputParameters.descptID = "";
		
		// Set the decription DIV Class 
		if ( NOT StructKeyExists(inputParameters, "descptClass") )
			inputParameters.descptClass = "";

		// Set the hideLabelText flag 
		if ( NOT StructKeyExists(inputParameters, "hideLabelText") )
			inputParameters.hideLabelText = false;

		// Remove leading and trailing spaces
		inputParameters.labelID = TRIM(inputParameters.labelID);
		inputParameters.labelClass = TRIM(inputParameters.labelClass);
		inputParameters.descptID = TRIM(inputParameters.descptID);
		inputParameters.descptClass = TRIM(inputParameters.descptClass);
		
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