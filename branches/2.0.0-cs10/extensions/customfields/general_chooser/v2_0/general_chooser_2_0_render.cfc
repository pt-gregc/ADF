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
	general chooser v2.0
Name:
	general_chooser_2_0_render.cfc
Summary:
	General Chooser field type.
	Allows for selection of the custom element records.
Version:
	2.0
History:
	2009-10-16 - MFC - Created
	2009-11-13 - MFC - Updated the Ajax calls to the CFC to call the controller 
							function.  This allows only the "controller" function to
							listed in the proxy white list XML file.
	2010-11-09 - MFC - Updated the Scripts loading methods to dynamically load the latest 
							script versions from the Scripts Object.
	2011-03-20 - MFC - Updated component to simplify the customizations process and performance.
							Removed Ajax loading process.
	2011-03-27 - MFC - Updated for Add/Edit/Delete callback.
	2011-09-21 - RAK - Added max/min selections
	2011-10-20 - GAC - Added defualt value check for the minSelections and maxSelections xParams varaibles
	2012-01-04 - SS - The field now honors the "required" setting in Standard Options.
	2012-03-19 - MFC - Added "loadAvailable" option to set if the available selections load
							when the form loads.
					   	Added the new records will load into the "selected" area when saved.
	2012-07-31 - MFC - Replaced the CFJS function for "ListLen" and "ListFindNoCase".
	2013-01-10 - MFC - Fixed issue with the to add the new records into the "selected" area when saved.
	2013-12-02 - GAC - Added a new callback function for the the edit/delete to reload the selected items after an edit or a delete
						  - Updated to allow 'ADD NEW' to be used multiple times before submit
	2014-03-20 - GAC - Force the keys in the formData object from the 'ADD NEW' callback to lowercase so it is sure to match js_fieldName_CE_FIELD  value 
	2014-10-10 - GAC - Added a new props field to allow the app name used for resolving the Chooser Bean Name to be specified
	2015-04-23 - DJM - Added own CSS
	2015-05-26 - DJM - Added the 2.0 version
	2015-09-10 - GAC - Added a isMultiline() call so the label renders at the top
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 
	2015-09-10 - GAC - Re-added a isMultiline() call so the label renders at the top
	2015-11-11 - GAC - General Dev Code clean up
	2016-02-09 - GAC - Updated duplicateBean() to use data_2_0.duplicateStruct()
	2016-02-17 - GAC - Added getResourceDependencies support
	                 - Added loadResourceDependencies support
	                 - Moved resource loading to the loadResourceDependencies() method
	                 - Moved UI theme property to the CFT props
--->
<cfcomponent displayName="GeneralChooser_Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

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
	</cfscript>

	<cfoutput>
		<!--- //Load the General Chooser Styles --->
		#application.ADF.utils.runCommand(beanName=inputParameters.chooserCFCName,
											methodName="loadStyles",
											args=initArgs,
											appName=inputParameters.chooserAppName)#
											
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
						<!--- Auto load the available selections --->
						<cfscript>
							// Set the query type flag before running the command
							selectionArgs.queryType = "notselected";
						</cfscript>
						<cfif inputParameters.loadAvailable>
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
			inputParameters.minSelections = "0"; //	0 = selections are optional
		if( NOT StructKeyExists(inputParameters, "maxSelections") )
			inputParameters.maxSelections = "0"; //	0 = infinite selections are possible
		if( NOT StructKeyExists(inputParameters, "loadAvailable") )
			inputParameters.loadAvailable = "0"; //	0 = boolean - 0/1
			
		if ( NOT StructKeyExists(inputParameters,"chooserCFCName") )
			inputParameters.chooserCFCName = "";
		else
			inputParameters.chooserCFCName = TRIM(inputParameters.chooserCFCName);
			
		if ( NOT StructKeyExists(inputParameters,"chooserAppName") )
			inputParameters.chooserAppName = "";
		else
			inputParameters.chooserAppName = TRIM(inputParameters.chooserAppName);

		if ( NOT StructKeyExists(inputParameters, "uiTheme") OR LEN(inputParameters.uiTheme) LTE 0 )
			inputParameters.uiTheme = "ui-lightness";
		
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
		return "jQuery,jQueryUI,ADFLightbox";
	}
</cfscript>

</cfcomponent>