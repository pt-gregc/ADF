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
	general_chooser_1_2_render.cfc
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
	2011-10-20 - GAC - Added defualt value check for the minSelections and maxSelections xParams variables
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
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean()
	2016-02-09 - GAC - Updated duplicateBean() to use data_2_0.duplicateStruct()
--->
<cfcomponent displayName="GeneralChooser Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfoutput>
		<cfscript>
			var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
			var currentValue = arguments.value;	// the field's current value
			var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
			var initArgs = StructNew();
			var selectionsArg = StructNew();
			
			inputParameters = setDefaultParameters(argumentCollection=arguments);
			if ( readOnly ) 
				inputParameters.loadAvailable = 0;
			
			// Load the scripts
			application.ADF.scripts.loadJQuery(force=inputParameters.forceScripts);
			application.ADF.scripts.loadJQueryUI(force=inputParameters.forceScripts);
			application.ADF.scripts.loadADFLightbox();
			application.ADF.scripts.loadCFJS();
			
			// init Arg struct
			initArgs.fieldName = arguments.fieldName;
			initArgs.readOnly = readOnly;
			
			// Build the argument structure to pass into the Run Command
			selectionsArg.item = arguments.value;
			selectionsArg.queryType = "selected";
			selectionsArg.csPageID = request.page.id;
			selectionsArg.fieldID = inputParameters.fieldID;
			selectionsArg.readOnly = readOnly;
		</cfscript>
	</cfoutput>
	<cfscript>
		renderJSFunctions(argumentCollection=arguments,fieldParameters=inputParameters);
	</cfscript>
	<cfoutput>
	
		<!--- //Load the General Chooser Styles --->
		#application.ADF.utils.runCommand(beanName=inputParameters.chooserCFCName,
											methodName="loadStyles",
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
							selectionsArg.queryType = "notselected";
						</cfscript>
						<cfif inputParameters.loadAvailable>
							#application.ADF.utils.runCommand(beanName=inputParameters.chooserCFCName,
															methodName="getSelections",
															args=selectionsArg,
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
								selectionsArg.queryType = "selected";
							</cfscript>
							#application.ADF.utils.runCommand(beanName=inputParameters.chooserCFCName,
															methodName="getSelections",
															args=selectionsArg,
															appName=inputParameters.chooserAppName)#
						</cfif>
					</ul>
				</div>
			</div>
		</div>	
		<input type="hidden" id="#arguments.fieldName#" name="#arguments.fieldName#" value="#currentValue#">
	</cfoutput>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="fieldParameters" type="struct" required="yes">
	
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.fieldParameters);
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
	</cfscript>

<cfoutput>
<script type="text/javascript">
<!--
var #inputParameters.fieldID#_ajaxProxyURL = "#application.ADF.ajaxProxy#";
var #inputParameters.fieldID#currentValue = "#arguments.value#";
var #inputParameters.fieldID#searchValues = "";
var #inputParameters.fieldID#queryType = "all";

jQuery(document).ready(function(){
	
	// Resize the window on the page load
	checkResizeWindow();
	
	// JQuery use the LIVE event b/c we are adding links/content dynamically		    
	// click for show all not-selected items
	jQuery('###arguments.fieldName#-showAllItems').live("click", function(event){
		// Load all the not-selected options
		#inputParameters.fieldID#_loadTopics('notselected');
	});
	
	// JQuery use the LIVE event b/c we are adding links/content dynamically
	jQuery('###arguments.fieldName#-searchBtn').live("click", function(event){
		//load the search field into currentItems
		#inputParameters.fieldID#searchValues = jQuery('input###arguments.fieldName#-searchFld').val();
		#inputParameters.fieldID#currentValue = jQuery('input###arguments.fieldName#').val();
		#inputParameters.fieldID#_loadTopics('search');
	});
	
	<cfif !readOnly>
	// Load the effects and lightbox - this is b/c we are auto loading the selections
	#inputParameters.fieldID#_loadEffects();
	</cfif>
	
	// Re-init the ADF Lightbox
	initADFLB();
});

// 2013-12-02 - GAC - Updated to allow 'ADD NEW' to be used multiple times before submit
function #inputParameters.fieldID#_loadTopics(queryType) 
{
	var cValue = jQuery("input###arguments.fieldName#").val();		
		
	// Put up the loading message
	if (queryType == "selected")
		jQuery("###inputParameters.fieldID#-sortable2").html("Loading ... <img src='/ADF/extensions/customfields/general_chooser/ajax-loader-arrows.gif'>");
	else
		jQuery("###inputParameters.fieldID#-sortable1").html("Loading ... <img src='/ADF/extensions/customfields/general_chooser/ajax-loader-arrows.gif'>");
	
	// load the initial list items based on the top terms from the chosen facet
	jQuery.get( #inputParameters.fieldID#_ajaxProxyURL,
	{ 	
		<cfif LEN(inputParameters.chooserAppName)>
		appName: '#inputParameters.chooserAppName#',
		</cfif>
		bean: '#inputParameters.chooserCFCName#',
		method: 'controller',
		chooserMethod: 'getSelections',
		// item: #inputParameters.fieldID#currentValue, // removed since this value was not dynamically updating after 'ADD NEW'
		item: cValue,
		queryType: queryType,
		searchValues: #inputParameters.fieldID#searchValues,
		csPageID: '#request.page.id#',
		fieldID: '#inputParameters.fieldID#'
	},
	function(msg)
	{
		if (queryType == "selected")
			jQuery("###inputParameters.fieldID#-sortable2").html(jQuery.trim(msg));
		else
			jQuery("###inputParameters.fieldID#-sortable1").html(jQuery.trim(msg));
			
		#inputParameters.fieldID#_loadEffects();
		
		// Re-init the ADF Lightbox
		initADFLB();
	});
}

function #inputParameters.fieldID#_loadEffects() 
{
	<cfif !readOnly>
	jQuery("###inputParameters.fieldID#-sortable1, ###inputParameters.fieldID#-sortable2").sortable({
		connectWith: '.connectedSortable',
		stop: function(event, ui) { #inputParameters.fieldID#_serialize(); }
	}).disableSelection();
	</cfif>
}

// serialize the selections
function #inputParameters.fieldID#_serialize() 
{
	// get the serialized list
	var serialList = jQuery('###inputParameters.fieldID#-sortable2').sortable( 'toArray' );
	// Check if the serialList is Array
	if ( jQuery.isArray(serialList) )
	{
		serialList = serialList.join(",");
	}
	
	// load serial list into current values
	#inputParameters.fieldID#currentValue = serialList;
	// load current values into the form field
	jQuery("input###arguments.fieldName#").val(#inputParameters.fieldID#currentValue);
}

// Resize the window function
function checkResizeWindow()
{
	// Check if we are in a loader.cfm page
	if ( '#ListLast(cgi.SCRIPT_NAME,"/")#' == 'loader.cfm' ) 
	{
		ResizeWindow();
	}
}

// 2013-12-02 - GAC - Updated to allow 'ADD NEW' to be used multiple times before submit
function #inputParameters.fieldID#_formCallback(formData)
{
	formData = typeof formData !== 'undefined' ? formData : {};
	var cValue = jQuery("input###arguments.fieldName#").val();

	// Call the utility function to make sure the JS object keys are all lowercase 
	formData = #inputParameters.fieldID#_ConvertCaseOfDataObjKeys(formData,'lower');

	// Load the newest item onto the selected values
	// 2012-07-31 - MFC - Replaced the CFJS function for "ListLen" and "ListFindNoCase".
	if ( cValue.length > 0 )
	{
		// Check that the record does not exist in the list already
		tempValue = cValue.search(formData[js_#inputParameters.fieldID#_CE_FIELD]); 
		if ( tempValue <= 0 ) 
			cValue = jQuery.ListAppend(formData[js_#inputParameters.fieldID#_CE_FIELD], cValue);
	}
	else 
		cValue = formData[js_#inputParameters.fieldID#_CE_FIELD];

	// load current values into the form field
	jQuery("input###arguments.fieldName#").val(cValue);
	
	// Reload the selected Values
	#inputParameters.fieldID#_loadTopics("selected");
	
	// Close the lightbox
	closeLB();
}

// 2013-11-26 - Fix for duplicate items on edit issue
function #inputParameters.fieldID#_formEditCallback()
{
	// Reload the selected Values
	#inputParameters.fieldID#_loadTopics("selected");
	// Reload the non-selected Values
	#inputParameters.fieldID#_loadTopics("notselected");
	// Close the lightbox
	closeLB();
}

// Validation function to validate required field and max/min selections
function #inputParameters.fieldID#_validate()
{
	//Get the list of selected items
	var selections = jQuery("###arguments.fieldName#").val();
	var lengthOfSelections = 0;
	//.split will return an array with 1 item if there is an empty string. Get around that.
	if(selections.length){
		var arraySelections = selections.split(",");
		lengthOfSelections = arraySelections.length;
	}
	<cfif inputParameters.req EQ 'Yes'>
		// If the field is required, check that a select has been made.
		if (lengthOfSelections <= 0) {
			alert("Please make a selection from the available items list.");
			return false;
		}
	</cfif>
	<cfif isNumeric(inputParameters.minSelections) and inputParameters.minSelections gt 0>
		if(lengthOfSelections < #inputParameters.minSelections#){
			alert("Minimum number of selections is #inputParameters.minSelections# you have only selected "+lengthOfSelections+" items");
			return false;
		}
	</cfif>
	<cfif isNumeric(inputParameters.maxSelections) and inputParameters.maxSelections gt 0>
		if(lengthOfSelections > #inputParameters.maxSelections#){
			alert("Maximum number of selections is #inputParameters.maxSelections# you have selected "+lengthOfSelections+" items");
			return false;
		}
	</cfif>
	return true;
}

// A Utility function convert the case of keys of a JS Data Object
function #inputParameters.fieldID#_ConvertCaseOfDataObjKeys(dataobj,keycase)
{
	dataobj = typeof dataobj !== 'undefined' ? dataobj : {};
	keycase = typeof keycase !== 'undefined' ? keycase : "lower"; //lower OR upper
	var key, keys = Object.keys(dataobj);
	var n = keys.length;
	var newobj={};
	while (n--) {
	  key = keys[n];
	  if ( keycase == 'lower' )
		newobj[key.toLowerCase()] = dataobj[key];
	  else if ( keycase == 'upper' ) 
		newobj[key.toUpperCase()] = dataobj[key];
	  else
		newobj[key] = dataobj[key]; // NOT upper or lower... pass the data back with keys unchanged
	}
	return newobj;
}
//-->
</script></cfoutput>
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
</cfscript>

</cfcomponent>