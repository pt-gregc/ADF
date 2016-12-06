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
	M Carroll 
Custom Field Type:
	general chooser v2.1
Name:
	general_chooser_2_1_render.cfc
Summary:
	General Chooser field type.
	Allows for selection of the custom element records.
Version:
	2.1
History:
	2016-12-06 - GAC - Created
--->
<cfcomponent displayName="GeneralChooser_Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cfscript>
	public void function renderStandard(required string fieldName, required string fieldDomID, required string value, required string description, required boolean isRequired, required string displayMode)
	{
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);

		inputParameters = setDefaultParameters(argumentCollection=arguments);
			
		if ( inputParameters.renderFieldLabelAbove OR inputParameters.hideFieldLabelContainer ) 	
		{
			writeOutput('<div style="padding-left:14px;padding-right:14px;">');
			
				renderFieldContainerStart(argumentCollection=arguments);				
				
					if ( !inputParameters.hideFieldLabelContainer )
					{
						renderLabelContainerStart(argumentCollection=arguments);			
							renderLabelWrapper(argumentCollection=arguments);
						renderLabelContainerEnd(argumentCollection=arguments);
					}
					
					renderControlContainerStart(argumentCollection=arguments);
						renderControlWrapper(argumentCollection=arguments); // handles control UI itself, required indicator, validation js, and field permission
					renderControlContainerEnd(argumentCollection=arguments);
				
				renderFieldContainerEnd(argumentCollection=arguments);

				if (arguments.description != "" && useDescription())
				{
					renderDescrContainerStart(argumentCollection=arguments); // descr container is analogous to fieldContainer, w empty label and control container w descr text inside
						renderLabelContainerStart(noLabelTag=true); // empty, to keep layout consistent w control rendering
						renderLabelContainerEnd(noLabelTag=true);
						renderControlContainerStart(className=getComponentClasses("Description"));
							renderDescriptionWrapper(argumentCollection=arguments);
						renderControlContainerEnd();
					renderDescrContainerEnd();
				}
			
			writeOutput('</div');
		}
		else
		{
			// Use the Standard CFT Rendering
			super.renderStandard(argumentCollection=arguments);
		}
	}
	
	// Overriding renderLabelContainerStart
	public void function renderLabelContainerStart(boolean isRequired=0, string id="", string labelClass="", string fieldDomID="", boolean noLabelTag=0)
	{
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);
		
		if ( !inputParameters.renderFieldLabelAbove ) 
			super.renderLabelContainerStart(argumentCollection=arguments);
		else
		{
			var _labelClass = (arguments.labelClass != "") ? " #arguments.labelClass#" : "";
			var containerClass = getComponentClasses("FormFieldLabelContainer");
			var idHTML = (arguments.fieldDomID != "") ? ' id="#arguments.fieldDomID#_label"': '';
			var forHTML = (useLabelFor() && arguments.fieldDomID != "") ? ' for="#arguments.fieldDomID#"' : '';
			var labelTagHTML = (arguments.noLabelTag || arguments.fieldDomID == "") ? "" : "<label#forHTML#>";
			if (containerClass != "")
				containerClass = " " & containerClass;
			
			
			writeOutput('<div#idHTML# class="CS_FormFieldLabelContainer#_labelClass##containerClass#" style="padding-left:4px; width:96% !important; text-align:left !important;">#labelTagHTML#');
			//original - writeOutput('<div#idHTML# class="CS_FormFieldLabelContainer#_labelClass##containerClass#">#labelTagHTML#');
		}
	}
	
	public void function renderLabelContainerEnd(boolean noLabelTag=0)
	{
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);
		
		super.renderLabelContainerEnd(argumentCollection=arguments);
		
		if ( inputParameters.renderFieldLabelAbove ) 
		{
			// add the clear:both
			writeOutput('<div style="clear: both"></div>');
		}
	}
</cfscript>

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		var initArgs = StructNew();
		var selectionArgs = StructNew();
		var cftGCheaderCSS = "";
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);

		if ( readOnly ) 
			inputParameters.loadAvailable = 0;
		
		// init the cftArgs struct to pass to getInitArgs() and getSelectionsArgs()
		cftArgs = StructNew();
		cftArgs.fieldName = arguments.fieldName;
		cftArgs.formname = arguments.formname;
		cftArgs.currentValue = arguments.value;
		cftArgs.readOnly = readOnly;
		cftArgs.rendertabindex = arguments.rendertabindex;
		cftArgs.inputParameters = inputParameters;


		// init the initArgs struct
		initArgs = application.ADF.utils.runCommand(beanName=inputParameters.chooserCFCName,
														methodName="getInitArgs",
														args=cftArgs,
														appName=inputParameters.chooserAppName);


		// Build the argument structure to pass into the getSelections calls
		selectionArgs = application.ADF.utils.runCommand(beanName=inputParameters.chooserCFCName,
															methodName="getSelectionArgs",
															args=cftArgs,
															appName=inputParameters.chooserAppName);
	
		// Load the General Chooser Styles from the loadStyles function as a string
		cftGCheaderCSS = application.ADF.utils.runCommand(beanName=inputParameters.chooserCFCName,
																				methodName="loadStyles",
																				args=initArgs,
																				appName=inputParameters.chooserAppName);
		// Load the HeaderCSS
		application.ADF.scripts.addHeaderCSS(cftGCheaderCSS,"SECONDARY");
	</cfscript>
	
	<cfoutput>
		<!--- // Load the General Chooser JavaScript functions --->
		#application.ADF.utils.runCommand(beanName=inputParameters.chooserCFCName,
													methodName="renderChooserJS",
													args=initArgs,
													appName=inputParameters.chooserAppName)#
	
		<!--- // Instructions --->
		<div id="#inputParameters.fieldID#-gc-top-area-instructions" class="cs_dlgLabelSmall" style="white-space:normal !important;">
			#TRIM(application.ADF.utils.runCommand(beanName=inputParameters.chooserCFCName,
														methodName="loadChooserInstructions",
														args=initArgs,
														appName=inputParameters.chooserAppName))#
		</div>
		
		<div id="#inputParameters.fieldID#-gc-main-area" class="cs_dlgLabelSmall">
		
			<div id="#inputParameters.fieldID#-gc-top-area">
				<!--- SECTION 1 - TOP LEFT --->
				<div id="#inputParameters.fieldID#-gc-section1">
					<!--- Load the Search Box --->
					#application.ADF.utils.runCommand(beanName=inputParameters.chooserCFCName,
														methodName="loadSearchBox",
														args=initArgs,
														appName=inputParameters.chooserAppName)#
				</div>									
				<!--- SECTION 2 - TOP RIGHT --->
				<div id="#inputParameters.fieldID#-gc-section2">
					<!--- Load the Add New Link --->
					#application.ADF.utils.runCommand(beanName=inputParameters.chooserCFCName,
														methodName="loadAddNewLink",
														args=initArgs,
														appName=inputParameters.chooserAppName)#
				</div>
			</div>
			
			<!--- SECTION 3 --->
			<div id="#inputParameters.fieldID#-gc-section3">
			
				<!--- Select Boxes --->
				<div id="#inputParameters.fieldID#-gc-select-left-box-label">
					#TRIM(application.ADF.utils.runCommand(beanName=inputParameters.chooserCFCName,
														methodName="loadAvailableLabel",
														args=initArgs,
														appName=inputParameters.chooserAppName))#
				</div>
				<div id="#inputParameters.fieldID#-gc-select-right-box-label">
					#TRIM(application.ADF.utils.runCommand(beanName=inputParameters.chooserCFCName,
														methodName="loadSelectedLabel",
														args=initArgs,
														appName=inputParameters.chooserAppName))#
				</div>
				<div id="#inputParameters.fieldID#-gc-select-left-box">
					<ul id="#inputParameters.fieldID#-sortable1" class="connectedSortable">
						<!--- // Standard Server Side loading. Use Javascript when override loading (eg. category filter, etc.) --->
						<cfif inputParameters.loadAvailable AND inputParameters.loadAvailableOption EQ "useServerSide">
							<cfscript>
								// Set the query type flag before running the command
								selectionArgs.queryType = "notselected";
							</cfscript>
							#application.ADF.utils.runCommand(beanName=inputParameters.chooserCFCName,
															methodName="getSelections",
															args=selectionArgs,
															appName=inputParameters.chooserAppName)#
						</cfif>
					</ul>
				</div>
				
				<div id="#inputParameters.fieldID#-gc-select-right-box">
					<ul id="#inputParameters.fieldID#-sortable2" class="connectedSortable">
						<!--- Check if we have current values and load the selected data --->
						<cfif LEN(currentValue)>
							<cfscript>
								// Set the query type flag before running the command
								selectionArgs.queryType = "selected";
							</cfscript>
							#application.ADF.utils.runCommand(beanName=inputParameters.chooserCFCName,
															methodName="getSelections",
															args=selectionArgs,
															appName=inputParameters.chooserAppName)#
						</cfif>
					</ul>
				</div>
			</div>
		</div>	
		<input type="hidden" id="#arguments.fieldName#" name="#arguments.fieldName#" value="#currentValue#">
	</cfoutput>
</cffunction>

<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		
		// overwrite the field ID to be unique
		inputParameters.fieldID = arguments.fieldName;
		
		// Set the defaults
		if( StructKeyExists(inputParameters, "forceScripts") AND (inputParameters.forceScripts EQ "1") )
			inputParameters.forceScripts = true;
		else
			inputParameters.forceScripts = false;
			
		if( NOT StructKeyExists(inputParameters, "minSelections") )
			inputParameters.minSelections = "0"; 							//	0 = selections are optional
		if( NOT StructKeyExists(inputParameters, "maxSelections") )
			inputParameters.maxSelections = "0"; 							//	0 = infinite selections are possible
		if( NOT StructKeyExists(inputParameters, "loadAvailable") )
			inputParameters.loadAvailable = "0"; 							//	0 = boolean - 0/1
		if( NOT StructKeyExists(inputParameters, "loadAvailableOption") )
			inputParameters.loadAvailableOption = "useServerSide"; 	//	useServerSide or useJavascript

		if ( NOT StructKeyExists(inputParameters,"chooserCFCName") )
			inputParameters.chooserCFCName = "";
		else
			inputParameters.chooserCFCName = TRIM(inputParameters.chooserCFCName);
			
		if ( NOT StructKeyExists(inputParameters,"chooserAppName") )
			inputParameters.chooserAppName = "";
		else
			inputParameters.chooserAppName = TRIM(inputParameters.chooserAppName);

		if ( NOT StructKeyExists(inputParameters,"uiTheme") OR LEN(inputParameters.uiTheme) LTE 0 )
			inputParameters.uiTheme = "ui-lightness";
		
		if ( NOT StructKeyExists(inputParameters,"renderFieldLabelAbove") OR LEN(inputParameters.renderFieldLabelAbove) LTE 0 )
			inputParameters.renderFieldLabelAbove = false;	//	0 = boolean - 0/1
		
		if ( NOT StructKeyExists(inputParameters,"hideFieldLabelContainer") OR LEN(inputParameters.hideFieldLabelContainer) LTE 0 )
			inputParameters.hideFieldLabelContainer = false;	//	0 = boolean - 0/1
		
		return inputParameters;
	</cfscript>
</cffunction>

<cfscript>
	private any function getValidationJS(required string formName, required string fieldName, required boolean isRequired)
	{
		return "#arguments.fieldName#_validate()";
	}
	
	private string function getValidationMsg()
	{
		return ''; // validator does alert itself dynamically, this keeps the default alert from happening too
	}

	private boolean function isMultiline()
	{
		return true;
	}

	private boolean function useDescription()
	{
		return false;
	}

	/*
		IMPORTANT: Since loadResourceDependencies() is using ADF.scripts loadResources methods, getResourceDependencies() and
		loadResourceDependencies() must stay in sync by accounting for all of required resources for this Custom Field Type.
	*/
	public void function loadResourceDependencies()
	{
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);

		inputParameters = setDefaultParameters(argumentCollection=arguments);

		// Load registered Resources via the ADF scripts_2_0
		application.ADF.scripts.loadJQuery();
		application.ADF.scripts.loadJQueryUI(themeName=inputParameters.uiTheme);
		application.ADF.scripts.loadADFLightbox();
	}
	public string function getResourceDependencies()
	{
		return "jQuery,jQueryUI,ADFLightbox,jQueryUIDefaultTheme";
	}
</cfscript>

</cfcomponent>