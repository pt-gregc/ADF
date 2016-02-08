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
	general chooser v1.2
Name:
	general_chooser_1_2_render.cfm
Summary:
	General Chooser field type.
	Allows for selection of the custom element records.
Version:
	1.2
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
	2015-04-29 - DJM - Modified code to use join to fix ArrayToList not a function error
	2015-07-08 - GAC - Moved all of the Javascript from the render file a function in the the general_chooser.cfc to allow JS overrides in the Site Level GC file
	2015-07-09 - GAC - Removed the dependancy for the jQuery CFJS library
	                 - Added datapageID and controlID params to the  loadTopics() ajax call an the 
					 - Moved the building of the initArgs and selectionArgs struct to the general_chooser.cfc file to allow overrides in the Site Level GC file
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	// overwrite the field ID to be unique
	xParams.fieldID = fqFieldName;
	
	// Set the defaults
	if( StructKeyExists(xParams, "forceScripts") AND (xParams.forceScripts EQ "1") )
		xParams.forceScripts = true;
	else
		xParams.forceScripts = false;
		
	if( NOT StructKeyExists(xParams, "minSelections") )
		xParams.minSelections = "0"; //	0 = selections are optional
	if( NOT StructKeyExists(xParams, "maxSelections") )
		xParams.maxSelections = "0"; //	0 = infinite selections are possible
	if( NOT StructKeyExists(xParams, "loadAvailable") )
		xParams.loadAvailable = "0"; //	0 = boolean - 0/1
		
	if ( NOT StructKeyExists(xParams,"chooserCFCName") )
		xParams.chooserCFCName = "";
	else
		xParams.chooserCFCName = TRIM(xParams.chooserCFCName);
		
	if ( NOT StructKeyExists(xParams,"chooserAppName") )
		xParams.chooserAppName = "";
	else
		xParams.chooserAppName = TRIM(xParams.chooserAppName);
		
	// find if we need to render the simple form field
	renderSimpleFormField = false;
	if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) )
		renderSimpleFormField = true;
	
	// Set the label start and end tags
	labelStart = attributes.itemBaselineParamStart;
	labelEnd = attributes.itemBaseLineParamEnd;	
	//If the fields are required change the label start and end
	if ( xparams.req eq "Yes" ) 
	{
		labelStart = attributes.reqItemBaselineParamStart;
		labelEnd = attributes.reqItemBaseLineParamEnd;
	}

	// Set defaults for the label and description 
	includeLabel = false;
	includeDescription = false; 

	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";

	//-- Read Only Check with the cs6 fieldPermission parameter --
	//-- Also check to see if this field is FORCED to be READ ONLY for CS 9+ by looking for attributes.currentValues[fqFieldName_doReadonly] variable --
	readOnly = application.ADF.forms.isFieldReadOnly(xparams,variables.fieldPermission,fqFieldName,attributes.currentValues);
	
	if ( readOnly ) 
		xParams.loadAvailable = 0;
</cfscript>

<cfoutput>
	<cfscript>
		// Load the scripts
		application.ADF.scripts.loadJQuery(force=xParams.forceScripts);
		application.ADF.scripts.loadJQueryUI(force=xParams.forceScripts);
		application.ADF.scripts.loadADFLightbox();
		
		// init the cftArgs struct to pass to getInitArgs() and getSelectionsArgs()
		cftArgs = StructNew();
		cftArgs.fieldName = fqFieldName;
		cftArgs.formname = attributes.formname;
		cftArgs.currentValue = currentValue;
		cftArgs.readOnly = readOnly;
		cftArgs.rendertabindex = rendertabindex;
		cftArgs.inputParameters = xParams;

		// init the initArgs struct
		initArgs = application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
														methodName="getInitArgs",
														args=cftArgs,
														appName=xParams.chooserAppName);

		// Build the argument structure to pass into the getSelections calls
		selectionArgs = application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
															methodName="getSelectionArgs",
															args=cftArgs,
															appName=xParams.chooserAppName);																									
	</cfscript>

	<!--- // Load the General Chooser Styles --->
	#application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
											methodName="loadStyles",
											args=initArgs,
											appName=xParams.chooserAppName)#
											
	<!--- // Load the General Chooser JavaScript functions --->
	#application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
											methodName="renderChooserJS",
											args=initArgs,
											appName=xParams.chooserAppName)#
	
	<cfsavecontent variable="inputHTML">
		<cfoutput>
			<!--- // Build Label --->
			<div id="#xParams.fieldID#-gc-main-label" class="cs_dlgLabelBoldNoAlign">
				#labelStart#
				<label for="#fqFieldName#" id="#fqFieldName#_LABEL">#TRIM(xParams.label)#:</label>
				#labelEnd#
			</div>
			
			<!--- // Instructions --->
			<div id="#xParams.fieldID#-gc-top-area-instructions" class="cs_dlgLabelSmall">
				#TRIM(application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
															methodName="loadChooserInstructions",
															args=initArgs,
															appName=xParams.chooserAppName))#
			</div>
			
			<div id="#xParams.fieldID#-gc-main-area" class="cs_dlgLabelSmall">
			
				<div id="#xParams.fieldID#-gc-top-area">
					<!--- SECTION 1 - TOP LEFT --->
					<div id="#xParams.fieldID#-gc-section1">
						<!--- Load the Search Box --->
						#application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
															methodName="loadSearchBox",
															args=initArgs,
															appName=xParams.chooserAppName)#
					</div>									
					<!--- SECTION 2 - TOP RIGHT --->
					<div id="#xParams.fieldID#-gc-section2">
						<!--- Load the Add New Link --->
						#application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
															methodName="loadAddNewLink",
															args=initArgs,
															appName=xParams.chooserAppName)#
					</div>
				</div>
				
				<!--- SECTION 3 --->
				<div id="#xParams.fieldID#-gc-section3">
				
					<!--- Select Boxes --->
					<div id="#xParams.fieldID#-gc-select-left-box-label">
						#TRIM(application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
															methodName="loadAvailableLabel",
															args=initArgs,
															appName=xParams.chooserAppName))#
					</div>
					<div id="#xParams.fieldID#-gc-select-right-box-label">
						#TRIM(application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
															methodName="loadSelectedLabel",
															args=initArgs,
															appName=xParams.chooserAppName))#
					</div>
					<div id="#xParams.fieldID#-gc-select-left-box">
						<ul id="#xParams.fieldID#-sortable1" class="connectedSortable">
							<!--- Auto load the available selections --->
							<cfscript>
								// Set the query type flag before running the command
								selectionArgs.queryType = "notselected";
							</cfscript>
							<cfif xParams.loadAvailable>
								#application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
																methodName="getSelections",
																args=selectionArgs,
																appName=xParams.chooserAppName)#
							</cfif>
						</ul>
					</div>
					
					<div id="#xParams.fieldID#-gc-select-right-box">
						<ul id="#xParams.fieldID#-sortable2" class="connectedSortable">
							<!--- Check if we have current values and load the selected data --->
							<cfif LEN(currentValue)>
								<cfscript>
									// Set the query type flag before running the command
									selectionArgs.queryType = "selected";
								</cfscript>
								#application.ADF.utils.runCommand(beanName=xParams.chooserCFCName,
																methodName="getSelections",
																args=selectionArgs,
																appName=xParams.chooserAppName)#
							</cfif>
						</ul>
					</div>
				</div>
			</div>	
			<input type="hidden" id="#fqFieldName#" name="#fqFieldName#" value="#currentValue#">
		</cfoutput>
	</cfsavecontent>
	
	<!---
		This CFT is using the forms lib wrapFieldHTML functionality. The wrapFieldHTML takes
		the Form Field HTML that you want to put into the TD of the right section of the CFT 
		table row and helps with display formatting, adds the hidden simple form fields (if needed) 
		and handles field permissions (other than read-only).
		Optionally you can disable the field label and the field discription by setting 
		the includeLabel and/or the includeDescription variables (found above) to false.  
	--->
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission,includeLabel,includeDescription)#
</cfoutput>