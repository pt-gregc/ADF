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
	general chooser v2.0
Name:
	general_chooser_2_0.cfc
Summary:
	General Chooser component.
Version:
	2.0
History:
	2009-10-16 - MFC - Created
	2009-11-13 - MFC - Updated the Ajax calls to the CFC to call the controller 
						function.  This allows only the "controller" function to 
						listed in the proxy white list XML file.
	2011-03-20 - MFC - Updated component to simplify the customizations process and performance.
						Removed Ajax loading process.
	2012-01-30 - GAC - Added a Display_Feild varaible to the General Chooser init variables.
	2013-01-10 - MFC - Disabled the Delete icon/action in the selection.
	2013-01-30 - GAC - Updated to use the ceData 2.0 lib component
	2013-10-22 - GAC - Updated to inject the data_1_2 lib in to the variables.data scope since we are extending ceData_2_0
	2013-10-23 - GAC - Removed data_1_2 injection due to ADF reset errors on startup
	2014-02-24 - JTP - Fixed the Search button class	
	2015-05-26 - DJM - Added the 2.0 version
	2015-07-08 - GAC - Moved all of the Javascript from the render file a function in the the general_chooser.cfc to allow JS overrides in the Site Level GC file
	2015-07-09 - GAC - Added datapageID and controlID params to the  loadTopics() ajax call an the 
					 - Moved the building of the initArgs and selectionArgs struct to the general_chooser.cfc file to allow overrides in the Site Level GC file
--->
<cfcomponent name="general_chooser" extends="ADF.lib.ceData.ceData_2_0">

<cfproperty name="version" value="2_0_0">

<cfscript>
	// CUSTOM ELEMENT INFO
	variables.CUSTOM_ELEMENT = "";
	variables.CE_FIELD = ""; // Must have the matching case as the field name in the element.
	variables.SEARCH_FIELDS = "";
	variables.ORDER_FIELD = "";
	// Display Text for the Chooser Items ( Defaults to the ORDER_FIELD )
	variables.DISPLAY_FIELD = "";

	// STYLES
	variables.MAIN_WIDTH = 580;
	variables.SECTION1_WIDTH = 270;
	variables.SECTION2_WIDTH = 270;
	variables.SECTION3_WIDTH = 580;
	variables.SELECT_BOX_HEIGHT = 350;
	variables.SELECT_BOX_WIDTH = 265;
	variables.SELECT_ITEM_HEIGHT = 30;
	variables.SELECT_ITEM_WIDTH = 225;
	variables.SELECT_ITEM_CLASS = "ui-state-default";
	variables.JQUERY_UI_THEME = "ui-lightness";
	
	// VARIABLES for v1.1
	variables.SHOW_SEARCH = true;  // Boolean
	variables.SHOW_ALL_LINK = true;  // Boolean
	variables.SHOW_ADD_LINK = true;  // Boolean
	variables.SHOW_EDIT_DELETE_LINKS = false;  	// Boolean - 'false' Disables both Edit and Delete options, 'true' Enables the SHOW_EDIT_LINKS and SHOW_DELETE_LINKS options
	
	// VARIABLES for v1.2 for ADF 1.6.2+
	variables.AVAILABLE_LABEL = "Available Items";
	variables.SELECTED_LABEL = "Selected Items";
	variables.NEW_ITEM_LABEL = "Add New Item";
	variables.SHOW_EDIT_LINKS = false;  			// Boolean - SHOW_EDIT_DELETE_LINKS must be true to enable this option 
	variables.SHOW_DELETE_LINKS = false;  		// Boolean - SHOW_EDIT_DELETE_LINKS must be true to enable this option
	variables.SHOW_INSTRUCTIONS = true;			// Boolean
</cfscript>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$controller
Summary:
	Handles the processing of the ajax calls.
Returns:
	String
Arguments:
	
History:
	2009-11-13 - MFC - Created
	2014-10-10 - GAC - Added appName to the parameters being filtered
--->
<cffunction name="controller" access="public" returntype="string" hint="">
	<cfscript>
		var itm = 1;
		var thisParam = "";
		var argStr = "";
		var reHTML = "";
	
		// loop through request.params parameters to get arguments
		for( itm=1; itm lte listLen(structKeyList(arguments)); itm=itm+1 ) 
		{
			thisParam = listGetAt(structKeyList(arguments), itm);
			if( thisParam neq "method" and thisParam neq "bean" and thisParam neq "chooserMethod" and thisParam neq "appName" ) 
			{
				argStr = listAppend(argStr, "#thisParam#='#arguments[thisParam]#'");
			}
		}

		if( len(argStr) )
			reHTML = Evaluate("#arguments.chooserMethod#(#argStr#)");
		else
			reHTML = Evaluate("#arguments.chooserMethod#()");
		
		return reHTML;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$getInitArgs
Summary:
	Build the initArgs General Chooser Parameters for the render file
Returns:
	Struct
Arguments:
	String - fieldName
	String - formname
	String - currentValue
	Boolean - readOnly
	Numeric - rendertabindex
	Struct - inputParameters
History:
	2015-07-09 - GAC - Created
--->
<cffunction name="getInitArgs" access="public" returntype="struct" hint="Build the initArgs General Chooser Parameters for the render file">
	<cfargument name="fieldName" type="string" required="true">
	<cfargument name="formname" type="string" required="true">
	<cfargument name="currentValue" type="string" required="false" default="">
	<cfargument name="readOnly" type="boolean" required="false" default="false">
	<cfargument name="rendertabindex" type="numeric" default="0" required="false">
	<cfargument name="inputParameters" type="struct" required="false" default="#StructNew()#">	
	
	<cfscript>
		var initArgs = StructNew();
		
		initArgs.fieldName = arguments.fieldName;
		initArgs.formname = arguments.formname;
		initArgs.currentValue = arguments.currentValue;
		initArgs.readOnly = arguments.readOnly;
		initArgs.rendertabindex = arguments.rendertabindex;
		initArgs.fieldID = arguments.fieldName;
		initArgs.csPageID = request.page.id;
		initArgs.dataPageID = structKeyExists(request.params, "dataPageID") ? request.params.dataPageID : structKeyExists(request.params, "pageID") ? request.params.pageID : request.page.id;
   		initArgs.controlID = structKeyExists(request.params, "controlID") ? request.params.controlID : 0;	
		initArgs.inputParameters = arguments.inputParameters;
		initArgs.gcCustomParams = getCustomGCparams();
		
		return initArgs;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$getSelectionArgs
Summary:
	Build the selectionArgs General Chooser Parameters for the render file
Returns:
	Struct
Arguments:
	String - fieldName
	String - formname
	String - currentValue
	Boolean - readOnly
	Struct - inputParameters
History:
	2015-07-09 - GAC - Created
--->
<cffunction name="getSelectionArgs" access="public" returntype="struct" hint="Build the selectionArgs General Chooser Parameters for the render file">
	<cfargument name="fieldName" type="string" required="true">
	<cfargument name="formname" type="string" required="true">
	<cfargument name="currentValue" type="string" required="false" default="">
	<cfargument name="readOnly" type="boolean" required="false" default="false">
	<cfargument name="inputParameters" type="struct" required="false" default="#StructNew()#">
	
	<cfscript>
		var selectionArgs = StructNew();
		
		selectionArgs.fieldName = arguments.fieldName;
		selectionArgs.formname = arguments.formname;
		selectionArgs.item = arguments.currentValue;
		selectionArgs.queryType = "selected"; // default initial selected GET 
		selectionArgs.fieldID = arguments.fieldName;
		selectionArgs.readOnly = arguments.readOnly;
		selectionArgs.csPageID = request.page.id;
		selectionArgs.dataPageID = structKeyExists(request.params, "dataPageID") ? request.params.dataPageID : structKeyExists(request.params, "pageID") ? request.params.pageID : request.page.id;
   		selectionArgs.controlID = structKeyExists(request.params, "controlID") ? request.params.controlID : 0;
		selectionArgs.inputParameters = arguments.inputParameters;
		selectionArgs.gcCustomParams = getCustomGCparams();
		
		return selectionArgs;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$getCustomGCparams
Summary:
	Additional General Chooser Parameters to be injected in to the render file's initArgs and selectionArgs to be passed to custom method calls.
Returns:
	Struct
Arguments:
	NA
History:
	2015-07-08 - GAC - Created
--->
<cffunction name="getCustomGCparams" access="public" returntype="struct" hint="Additional General Chooser Parameters to be injected in to the render file and passed to other method calls.">
	<cfreturn StructNew()>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadStyles
Summary:
	Loads the Chooser Styles with the variable sizes defined in the variables.
Returns:
	string
Arguments:
	ARGS
History:
	2011-01-14 - MFC - Created
	2011-03-27 - MFC - Updates for IE styling.
	2011-04-28 - GAC - Updates for styling the Show All Items link
--->
<cffunction name="loadStyles" access="public" returntype="string" output="true" hint="">
	<cfargument name="fieldName" type="string" required="true">
	<cfargument name="readonly" type="boolean" default="false" required="false">
	
	<cfset var retInitHTML = "">
	<cfsavecontent variable="retInitHTML">
		<cfoutput>
			<!--- <cfdump var="#arguments#"> --->
			<style>
				div###arguments.fieldName#-gc-main-area {
					width: #variables.MAIN_WIDTH#px;
				}
				div###arguments.fieldName#-gc-main-area ul { 
					list-style-type: none; 
					margin: 0; 
					padding: 0; 
					margin-bottom: 10px; 
					min-height: #variables.SELECT_BOX_HEIGHT-10#px; 
					height: #variables.SELECT_BOX_HEIGHT-10#px; 
				}
				div###arguments.fieldName#-gc-main-label{
					padding-bottom: 4px;
				}
				div###arguments.fieldName#-gc-top-area-instructions{
					margin-bottom: 8px;
					width: #variables.MAIN_WIDTH#px;
				}
				
				/* Item box inner html classes */
				.itemCell .itemCellLeft{
					width: 60px;
					float: left;
				}
				.itemCell .itemCellRight{
					width: 150px;
					float: right;
				}
				.serializer{
					clear: both;
				}
				
				/* Top Area - Left Section */
				div###arguments.fieldName#-gc-top-area div###arguments.fieldName#-gc-section1 {
					width: #variables.SECTION1_WIDTH#px;
					float: left;
				}
				
				/* Top Area - Right Section */
				div###arguments.fieldName#-gc-top-area div###arguments.fieldName#-gc-section2 {
					width: #variables.SECTION2_WIDTH#px;
					float: right;
					text-align: right;
					margin-right: 10px;
				}
				
				/* Main Area Selection Section */
				div###arguments.fieldName#-gc-main-area div###arguments.fieldName#-gc-section3 {
					clear:  both;
					/*padding-top: 10px;*/
				}
				
				/* Search Box */
				div###arguments.fieldName#-gc-top-area div##search-chooser {
					/* margin-bottom: 10px; */
					border: none;
					width: 250px;
					/* height: 25px; */ 
				}
				/* Show All Items Link Box */
				div###arguments.fieldName#-gc-top-area div##search-chooser div##show-all-items {
					margin-top: 4px;
				}
				
				div###arguments.fieldName#-gc-main-area input {
					border-color: ##fff;
				}
				
				/* Select Boxes */
				div###arguments.fieldName#-gc-main-area div###arguments.fieldName#-gc-select-left-box-label {
					width: #variables.SELECT_BOX_WIDTH#px;
					float: left;
					height: 10px;
					margin: 10px 0 10px 0;
					padding: 2px;
					text-align: left;
				}
				div###arguments.fieldName#-gc-main-area div###arguments.fieldName#-gc-select-left-box {
					width: #variables.SELECT_BOX_WIDTH#px;
					float: left;
					min-height: #variables.SELECT_BOX_HEIGHT#px;
					height: #variables.SELECT_BOX_HEIGHT#px;
					border: 1px solid ##000000;
					margin: 0 10px 0 0;
					padding: 2px;
					overflow-y: auto;
					<cfif arguments.readonly>
					background-color: ##cccccc;
					</cfif>
				}
				div###arguments.fieldName#-gc-main-area div###arguments.fieldName#-gc-select-right-box-label {
					width: #variables.SELECT_BOX_WIDTH#px;
					float: right;
					height: 10px;
					margin: 10px;
					padding: 2px;
					text-align: left;
				}
				div###arguments.fieldName#-gc-main-area div###arguments.fieldName#-gc-select-right-box {
					width: #variables.SELECT_BOX_WIDTH#px;
					float: right;
					min-height: #variables.SELECT_BOX_HEIGHT#px;
					height: #variables.SELECT_BOX_HEIGHT#px;
					border: 1px solid ##000000;
					margin: 0 10px 0 10px;
					padding: 2px;
					overflow-y: auto;
				}
				###arguments.fieldName#-sortable1 li,
				###arguments.fieldName#-sortable2 li { 
					margin: 5px; 
					padding: 5px; 
					width: #variables.SELECT_ITEM_WIDTH#px;
					height: #variables.SELECT_ITEM_HEIGHT#px;
				}
				
				/* ITEM CLASS w/ EDIT/DELETE LINKS */
				/* ###arguments.fieldName#-sortable1 li.itemEditDelete,
				###arguments.fieldName#-sortable2 li.itemEditDelete { 
					height: #variables.SELECT_ITEM_HEIGHT+20#px;
				} */
				
				/* ADD LINK */
				div###arguments.fieldName#-gc-section2 div##add-new-items a.#arguments.fieldName#-ui-buttons {
					padding: 1px 10px;
					text-decoration: none;
					margin-left: 20px;
					width: 120px;
					height: 16px;
				}
				
				/* SEARCH BUTTON */
				div###arguments.fieldName#-gc-section1 a.#arguments.fieldName#-ui-buttons {
					font-size: 11px;
					padding: 1px 10px;
					text-decoration: none;
					margin-left: 5px;
					/* width: 115px; */
					height: 16px;
				}
			</style>
		</cfoutput>
	</cfsavecontent>
	<cfreturn retInitHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$renderChooserJS
Summary:
	Renders the Chooser CFT's JavaScript.
Returns:
	string
Arguments:
	ARGS
History:
	2015-07-08 - GAC - Created
	2015-07-10 - GAC - Added the arguments scope to the readonly variables
--->
<cffunction name="renderChooserJS" access="public" returntype="void" output="true" hint="Renders the Chooser CFT's JavaScript.">
	<cfargument name="fieldName" type="string" required="true">
	<cfargument name="formname" type="string" required="true">
	<cfargument name="currentValue" type="string" default="" required="false">
	<cfargument name="readonly" type="boolean" default="false" required="false">
	<cfargument name="rendertabindex" type="numeric" default="0" required="false">
	<cfargument name="csPageID" type="numeric" default="#request.page.id#" required="false">
	<cfargument name="inputParameters" type="struct" default="#StructNew()#" required="false">
	<cfargument name="gcCustomParams" type="struct" default="#StructNew()#" required="false">
	
	<cfscript>
		// Set inputParameters Default values
		if ( NOT StructKeyExists(arguments.inputParameters,"chooserCFCName")  )
			arguments.inputParameters.chooserCFCName = ListLast(getMetadata().name,".");
		if ( NOT StructKeyExists(arguments.inputParameters,"chooserAppName")  )
			arguments.inputParameters.chooserAppName = "";
		if ( NOT StructKeyExists(arguments.inputParameters,"req")  )
			arguments.inputParameters.req = false;
		if ( NOT StructKeyExists(arguments.inputParameters,"minSelections")  )
			arguments.inputParameters.minSelections = "";
		if ( NOT StructKeyExists(arguments.inputParameters,"maxSelections")  )
			arguments.inputParameters.maxSelections = "";
	</cfscript>
	
<cfoutput><script type="text/javascript">
//<!--
var #arguments.fieldName#_ajaxProxyURL = "#application.ADF.ajaxProxy#";
var #arguments.fieldName#_currentValue = "#arguments.currentValue#";
var #arguments.fieldName#_searchValues = "";

jQuery(function(){
	
	// Resize the window on the page load
	checkResizeWindow();
	
	// JQuery use the LIVE event b/c we are adding links/content dynamically		    
	// click for show all not-selected items
	// TODO: update to jQuery ON (LIVE is deprected) !!!
	jQuery('###arguments.fieldName#-showAllItems').live("click", function(event){
		// Load all the not-selected options
		#arguments.fieldName#_loadTopics('notselected');
	});
	
	// JQuery use the LIVE event b/c we are adding links/content dynamically
	jQuery('###arguments.fieldName#-searchBtn').live("click", function(event){
		//load the search field into currentItems
		#arguments.fieldName#_searchValues = jQuery('input###arguments.fieldName#-searchFld').val();
		#arguments.fieldName#_currentValue = jQuery('input###arguments.fieldName#').val();
		#arguments.fieldName#_loadTopics('search');
	});
	
	<cfif !arguments.readOnly>
	// Load the effects and lightbox - this is b/c we are auto loading the selections
	#arguments.fieldName#_loadEffects();
	</cfif>
	
	// Re-init the ADF Lightbox
	initADFLB();
});

// 2013-12-02 - GAC - Updated to allow 'ADD NEW' to be used multiple times before submit
function #arguments.fieldName#_loadTopics(queryType) 
{
	var cValue = jQuery("input###arguments.fieldName#").val();		
		
	// Put up the loading message
	if ( queryType == "selected" )
		jQuery("###arguments.fieldName#-sortable2").html("Loading ... <img src='/ADF/extensions/customfields/general_chooser/ajax-loader-arrows.gif'>");
	else
		jQuery("###arguments.fieldName#-sortable1").html("Loading ... <img src='/ADF/extensions/customfields/general_chooser/ajax-loader-arrows.gif'>");
	
	// load the initial list items based on the top terms from the chosen facet
	jQuery.get( #arguments.fieldName#_ajaxProxyURL,
	{ 	
		<cfif LEN(arguments.inputParameters.chooserAppName)>
		appName: '#arguments.inputParameters.chooserAppName#',
		</cfif>
		bean: '#arguments.inputParameters.chooserCFCName#',
		method: 'controller',
		chooserMethod: 'getSelections',
		item: cValue,
		queryType: queryType,
		searchValues: #arguments.fieldName#_searchValues,
		csPageID: '#request.page.id#',
		fieldID: '#arguments.fieldName#',
		dataPageID: <cfif structKeyExists(request.params, "dataPageID")>#request.params.dataPageID#<cfelseif structKeyExists(request.params, "pageID")>#request.params.pageID#<cfelse>#request.page.id#</cfif>,
		controlID: <cfif structKeyExists(request.params, "controlID")>#request.params.controlID#<cfelse>0</cfif>
	},
	function(msg)
	{
		if ( queryType == "selected" )
			jQuery("###arguments.fieldName#-sortable2").html(jQuery.trim(msg));
		else
			jQuery("###arguments.fieldName#-sortable1").html(jQuery.trim(msg));
			
		#arguments.fieldName#_loadEffects();
		
		// Re-init the ADF Lightbox
		initADFLB();
	});
}

function #arguments.fieldName#_loadEffects() 
{
	<cfif !arguments.readOnly>
	jQuery("###arguments.fieldName#-sortable1, ###arguments.fieldName#-sortable2").sortable({
		connectWith: '.connectedSortable',
		stop: function(event, ui) { #arguments.fieldName#_serialize(); }
	}).disableSelection();
	</cfif>
}

// serialize the selections
function #arguments.fieldName#_serialize() 
{
	// get the serialized list
	var serialList = jQuery('###arguments.fieldName#-sortable2').sortable( 'toArray' );
	// Check if the serialList is Array
	if ( serialList.constructor==Array ) 
	{
		serialList = serialList.join(",");
	}
	
	// load serial list into current values
	#arguments.fieldName#_currentValue = serialList;
	// load current values into the form field
	jQuery("input###arguments.fieldName#").val(#arguments.fieldName#_currentValue);
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
function #arguments.fieldName#_formCallback(formData)
{
	formData = typeof formData !== 'undefined' ? formData : {};
	var cValue = jQuery("input###arguments.fieldName#").val();

	// Call the utility function to make sure the JS object keys are all lowercase 
	formData = #arguments.fieldName#_ConvertCaseOfDataObjKeys(formData,'lower');

	// Load the newest item onto the selected values
	// 2012-07-31 - MFC - Replaced the CFJS function for "ListLen" and "ListFindNoCase".
	if ( cValue.length > 0 )
	{
		// Check that the record does not exist in the list already
		tempValue = cValue.search(formData[js_#arguments.fieldName#_CE_FIELD]); 
		if ( tempValue <= 0 ) 
			cValue = jQuery.ListAppend(formData[js_#arguments.fieldName#_CE_FIELD], cValue);
	}
	else 
		cValue = formData[js_#arguments.fieldName#_CE_FIELD];

	// load current values into the form field
	jQuery("input###arguments.fieldName#").val(cValue);
	
	// Reload the selected Values
	#arguments.fieldName#_loadTopics("selected");
	
	// Close the lightbox
	closeLB();
}

// 2013-11-26 - Fix for duplicate items on edit issue
function #arguments.fieldName#_formEditCallback()
{
	// Reload the selected Values
	#arguments.fieldName#_loadTopics("selected");
	// Reload the non-selected Values
	#arguments.fieldName#_loadTopics("notselected");
	// Close the lightbox
	closeLB();
}

// Validation function to validate required field and max/min selections
function #arguments.fieldName#_validate()
{
	//Get the list of selected items
	var selections = jQuery("###arguments.fieldName#").val();
	var lengthOfSelections = 0;
	//.split will return an array with 1 item if there is an empty string. Get around that.
	if(selections.length)
	{
		var arraySelections = selections.split(",");
		lengthOfSelections = arraySelections.length;
	}
	<cfif IsBoolean(arguments.inputParameters.req) AND arguments.inputParameters.req>
		// If the field is required, check that a select has been made.
		if (lengthOfSelections <= 0) 
		{
			alert("Please make a selection from the available items list.");
			return false;
		}
	</cfif>
	<cfif isNumeric(arguments.inputParameters.minSelections) and arguments.inputParameters.minSelections gt 0>
		if(lengthOfSelections < #arguments.inputParameters.minSelections#)
		{
			alert("Minimum number of selections is #arguments.inputParameters.minSelections# you have only selected "+lengthOfSelections+" items");
			return false;
		}
	</cfif>
	<cfif isNumeric(arguments.inputParameters.maxSelections) and arguments.inputParameters.maxSelections gt 0>
		if(lengthOfSelections > #arguments.inputParameters.maxSelections#)
		{
			alert("Maximum number of selections is #arguments.inputParameters.maxSelections# you have selected "+lengthOfSelections+" items");
			return false;
		}
	</cfif>
	return true;
}

// A Utility function convert the case of keys of a JS Data Object
function #arguments.fieldName#_ConvertCaseOfDataObjKeys(dataobj,keycase)
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

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	M. Carroll
Name:
	$loadSearchBox
Summary:
	General Chooser - Search box HTML content.
	REQUIRED: 
		- Search button must have the ID field of: id="#arguments.fieldName#-searchBtn"
Returns:
	String html code
Arguments:
	String - fieldName - custom element unique fqFieldName
History:
	2009-05-29 - MFC - Created
	2011-01-14 - MFC - Removed the styles to the loadStyles function. 
						Merged in the code for the show all link.
	2011-03-10 - SFS - The loadSearchBox function had an invalid field name of "search-box". 
						ColdFusion considers variables with a "-" as invalid. Removed "-".
	2011-04-28 - GAC - Added a check to see if the old "SHOW_SECTION1" variable was being used 
						via site or app level override file. If so, then it will pass the value to the SHOW_SEARCH variable
	2014-01-24 - TP - Updated to allow the the enter key to tigger the submit.
--->
<cffunction name="loadSearchBox" access="public" returntype="string" hint="General Chooser - Search box HTML content.">
	<cfargument name="fieldName" type="String" required="true">
	<cfargument name="readonly" type="boolean" default="false" required="false">
	<cfargument name="gcCustomParams" type="struct" default="#StructNew()#" required="false">
	
	<cfscript>
		var retSearchBoxHTML = "";
		
		// Backward compatibility to allow the variables from General Chooser v1.0 site and app override GC files to honored
		if ( StructKeyExists(variables,"SHOW_SECTION1") )
			variables.SHOW_SEARCH = variables.SHOW_SECTION1;
	</cfscript>
	
	<!--- Check the variable flags for rendering --->
	<cfif variables.SHOW_SEARCH EQ true AND !arguments.readonly>
		<cfsavecontent variable="retSearchBoxHTML">
			<!--- Render out the search box to the field type --->
			<cfoutput>
				<div id="search-chooser">
					<input type="text" class="searchFld-chooser" id="#arguments.fieldName#-searchFld" name="searchbox" tabindex="1" onblur="this.value = this.value || this.defaultValue;" onfocus="this.value='';" value="Search" />
					<a href="javascript:;" id="#arguments.fieldName#-searchBtn" class="ui-state-default ui-corner-all #arguments.fieldName#-ui-buttons clsPushButton">Search</a>
					<cfif variables.SHOW_ALL_LINK EQ true>
					<!--- Render out the show all link to the field type --->
					<div id="show-all-items">
						<a id="#arguments.fieldName#-showAllItems" href="javascript:;">Show All Items</a>
					</div>	
					</cfif>
				</div>
				<script type="text/javascript">
					jQuery('###arguments.fieldName#-searchFld').keydown( function(e) 
						{
							if(e.keyCode == 13)
							{
								// stop from submitting form
    							e.preventDefault();
								
								// do the search
								jQuery('###arguments.fieldName#-searchBtn').click();
								return false;
							}		
						});
				</script>
			</cfoutput>
		</cfsavecontent>
	</cfif>
	<cfreturn retSearchBoxHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M Carroll
Name:
	$loadAddNewLink
Summary:
	General Chooser - Add New Link HTML content.
Returns:
	String html code
Arguments:
	None
History:
	2009-05-29 - MFC - Created
	2011-01-14 - MFC - Updated Add new link to utilize forms_1_1 by default.
	2011-04-28 - GAC - Added a check to see if the old "ADD_NEW_FLAG" or "SHOW_SECTION2" variables were being used 
						via site or app level override files. If so, then passed appropriate value to the SHOW_ADD_LINK variable
	2012-01-20 - GAC - Updating the Comments for the Backward Compatibility  fixes
	2012-03-19 - MFC - Added - Load CE Field name into JS for adding new records to the "selected" side.
	2013-12-12 - GAC - Added the ready only parameter to disable ADD button if the FIELD is set to READ ONLY
	2013-12-12 - GAC - Added the newItemLabel parameter to allow the ADD NEW button to have a custom label
	2014-03-05 - JTP - Var declarations
	2014-03-20 - GAC - To be safe force the value of the js_fieldName_CE_FIELD to lowercase so it is sure to match keys data from the callback 
--->
<cffunction name="loadAddNewLink" access="public" returntype="string" hint="General Chooser - Add New Link HTML content.">
	<cfargument name="fieldName" type="String" required="true">
	<cfargument name="readonly" type="boolean" default="false" required="false">
	<cfargument name="newItemLabel" type="String" default="#variables.NEW_ITEM_LABEL#" required="false">
	<cfargument name="gcCustomParams" type="struct" default="#StructNew()#" required="false">
	
	<cfscript>
		var retAddLinkHTML = "";
		var ceFormID = 0;
	
		// Backward Compatibility to allow the variables from General Chooser v1.0 site and app override GC files to be honored
		// - if the section2 variable is used and set to false... not ADD button should be displayed
		if ( StructKeyExists(variables,"SHOW_SECTION2") AND variables.SHOW_SECTION2 EQ false )
			variables.SHOW_ADD_LINK = false;
		
		// - if SHOW_ADD_LINK is still true (and SHOW_SECTION2 is true) then check for the ADD_NEW_FLAG variable	
		if ( StructKeyExists(variables,"ADD_NEW_FLAG") AND variables.SHOW_ADD_LINK NEQ false )
			variables.SHOW_ADD_LINK = variables.ADD_NEW_FLAG;
	</cfscript>
	
	<!--- Check if we want to display show all link --->
	<cfif variables.SHOW_ADD_LINK EQ true AND !arguments.readonly>
		<!--- Get the form ID for the custom element --->
		<cfset ceFormID = getFormIDByCEName(variables.CUSTOM_ELEMENT)>
		<!--- Render out the show all link to the field type --->
		<cfsavecontent variable="retAddLinkHTML">
			<cfoutput>
				<!--- // Load CE Field name into JS for adding new records to the "selected" side. --->
				<!--- // Also... to be safe force the CE_FIELD to lowercase so it is sure to match the CE_FIELD key in callback data objecy --->
				<script type="text/javascript">
					js_#arguments.fieldName#_CE_FIELD = '#LCASE(variables.CE_FIELD)#';
				</script>
				<div id="add-new-items">
					<a href="javascript:;" rel="#application.ADF.ajaxProxy#?bean=Forms_1_1&method=renderAddEditForm&formID=#ceFormID#&dataPageId=0&callback=#arguments.fieldName#_formCallback&title=#variables.NEW_ITEM_LABEL#" class="ADFLightbox ui-state-default ui-corner-all #arguments.fieldName#-ui-buttons">#variables.NEW_ITEM_LABEL#</a>
				</div>
			</cfoutput>
		</cfsavecontent>
	</cfif>
	
	<cfreturn retAddLinkHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadEditDeleteItemLinks
Summary:
	General Chooser - HTML for the Edit and Delete Item Links  
Returns:
	String html code
Arguments:
	String - fieldName
	String - bean
	Numeric - formid
	Numeric - csPageID
	String - readonly
History:
	2013-12-11 - GAC - Created
	2015-07-10 - GAC - Added the displayText argument
--->
<cffunction name="loadEditDeleteItemLinks" access="public" returntype="string" hint="General Chooser - HTML for the Edit and Delete Item Links">
	<cfargument name="fieldName" type="String" required="true">
	<cfargument name="bean" type="string" required="false" default="Forms_1_1">
	<cfargument name="formid" type="numeric" required="false" default="-1">
	<cfargument name="csPageID" type="numeric" required="false" default="-1">
	<cfargument name="readonly" type="boolean" default="false" required="false">
	<cfargument name="displayText" type="string" default="Item" required="false">
	<cfargument name="gcCustomParams" type="struct" default="#StructNew()#" required="false">
	
	<cfscript>
		var retItemLinksHTML = ""; 
		var editMethod = "renderAddEditForm";
		var deleteMethod = "renderDeleteForm";
		var editButtonHTML = "";
		var deleteButtonHTML = "";
		
		if ( variables.SHOW_EDIT_DELETE_LINKS AND !arguments.readonly ) {		 
			retItemLinksHTML = "<table style='border: 0'><tr>";
			
			// Build the ITEM Edit button
		    if ( variables.SHOW_EDIT_LINKS ) {
		    	editButtonHTML = loadEditItemLink(fieldName=arguments.fieldName,bean=arguments.bean,method=editMethod,formid=arguments.formid,csPageID=arguments.csPageID,readonly=arguments.readonly,displayText=arguments.displayText);	    
		    	if ( LEN(TRIM(editButtonHTML)) ) { 	    
			    	retItemLinksHTML = retItemLinksHTML & "<td>";
			   	 	retItemLinksHTML = retItemLinksHTML & TRIM(editButtonHTML);
			    	retItemLinksHTML = retItemLinksHTML & "</td>";
		    	}
		    }
		    // Build the ITEM Delete button
		    if ( variables.SHOW_DELETE_LINKS ) {
		    	deleteButtonHTML = loadDeleteItemLink(fieldName=arguments.fieldName,bean=arguments.bean,method=deleteMethod,formid=arguments.formid,csPageID=arguments.csPageID,readonly=arguments.readonly,displayText=arguments.displayText);	    
		    	if ( LEN(TRIM(deleteButtonHTML)) ) {    
			    	retItemLinksHTML = retItemLinksHTML & "<td>";
			   		retItemLinksHTML = retItemLinksHTML & TRIM(deleteButtonHTML);
			    	retItemLinksHTML = retItemLinksHTML & "</td>";
		    	}
		    } 
		    
		    retItemLinksHTML = retItemLinksHTML & "</tr></table>";
		} 
	
		return retItemLinksHTML;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadEditItemLink
Summary:
	General Chooser - Edit Item Link HTML
Returns:
	String 
Arguments:
	String - fieldName
	String - bean
	String - method
	Numeric - formid
	Numeric - csPageID
	String - readonly
History:
	2013-12-10 - GAC - Created
	2015-07-10 - GAC - Added a title attribute to the <a> tag
					 - Added the displayText argument
--->
<cffunction name="loadEditItemLink" access="public" returntype="string" hint="General Chooser - Edit Item Link HTML">
	<cfargument name="fieldName" type="string" required="true">
	<cfargument name="bean" type="string" required="false" default="Forms_1_1">
	<cfargument name="method" type="string" required="false" default="renderAddEditForm">
	<cfargument name="formid" type="numeric" required="false" default="-1">
	<cfargument name="csPageID" type="numeric" required="false" default="-1">
	<!--- <cfargument name="callback" type="sting" required="false" default=""> --->
	<cfargument name="readonly" type="boolean" default="false" required="false">
	<cfargument name="displayText" type="string" default="Item" required="false">
	<cfargument name="gcCustomParams" type="struct" default="#StructNew()#" required="false">
	
	<cfscript>
		var retEditLinkHTML = "";
	</cfscript>
	<!--- // Check if we want to display edit pencil icon link --->
	<cfif variables.SHOW_EDIT_LINKS EQ true AND !arguments.readonly>
		<!--- // Render out the edit pencil icon link for the item --->
		<cfsavecontent variable="retEditLinkHTML">
			<cfoutput>
				<a href='javascript:;' rel='#application.ADF.ajaxProxy#?bean=#arguments.bean#&method=#arguments.method#&formID=#arguments.formID#&datapageId=#arguments.cspageID#&callback=#arguments.fieldName#_formEditCallback&title=Edit #arguments.displayText#' class='ADFLightbox ui-icon ui-icon-pencil' title="Edit #arguments.displayText#"></a>
			</cfoutput>
		</cfsavecontent>
	</cfif>
	<cfreturn retEditLinkHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadDeleteItemLink
Summary:
	General Chooser - Delete Item Link HTML 
Returns:
	String 
Arguments:
	String - fieldName
	String - bean
	String - method
	Numeric - formid
	Numeric - csPageID
	String - readonly
	String - displayText
History:
	2013-12-10 - GAC - Created
	2015-07-10 - GAC - Added a title attribute to the <a> tag
					 - Added the displayText argument
--->
<cffunction name="loadDeleteItemLink" access="public" returntype="string" hint="General Chooser - Delete Item Link HTML">
	<cfargument name="fieldName" type="string" required="true">
	<cfargument name="bean" type="string" required="false" default="Forms_1_1">
	<cfargument name="method" type="string" required="false" default="renderDeleteForm">
	<cfargument name="formid" type="numeric" required="false" default="-1">
	<cfargument name="csPageID" type="numeric" required="false" default="-1">
	<!--- <cfargument name="callback" type="sting" required="false" default=""> --->
	<cfargument name="readonly" type="boolean" default="false" required="false">
	<cfargument name="displayText" type="string" default="Item" required="false">
	<cfargument name="gcCustomParams" type="struct" default="#StructNew()#" required="false">
	
	<cfscript>
		var retDeleteLinkHTML = "";
	</cfscript>
	
	<!--- // Check if we want to display edit pencil icon link --->
	<cfif variables.SHOW_DELETE_LINKS EQ true AND !arguments.readonly>
		<!--- // Render out the edit pencil icon link for the item --->
		<cfsavecontent variable="retDeleteLinkHTML">
			<cfoutput>
				<a href='javascript:;' rel='#application.ADF.ajaxProxy#?bean=#arguments.bean#&method=#arguments.method#&formID=#arguments.formID#&datapageId=#arguments.cspageID#&callback=#arguments.fieldName#_formEditCallback&title=Delete #arguments.displayText#' class='ADFLightbox ui-icon ui-icon-trash' title="Delete #arguments.displayText#"></a>
			</cfoutput>
		</cfsavecontent>
	</cfif>
	<cfreturn retDeleteLinkHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadAvailableLabel
Summary:
	Loads the Available Items column header
Returns:
	String
Arguments:
	String - fieldName
	Boolean - readonly
History:
	2013-12-12 - GAC - Created
--->
<cffunction name="loadAvailableLabel" access="public" returntype="string" hint="General Chooser - Loads the Available Items column header">
	<cfargument name="fieldName" type="String" required="true">
	<cfargument name="readonly" type="boolean" default="false" required="false">
	<cfargument name="gcCustomParams" type="struct" default="#StructNew()#" required="false">
	
	<cfscript>
		var retLabelHTML = "";
		var aLabel = variables.AVAILABLE_LABEL;
	</cfscript>
	<cfsavecontent variable="retLabelHTML">
		<cfoutput>
				<strong>#aLabel#:</strong><cfif arguments.readonly> (DISABLED)</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfreturn retLabelHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadSelectedLabel
Summary:
	Loads the Selected Items column header
Returns:
	String
Arguments:
	String - fieldName
	Boolean - readonly
History:
	2013-12-12 - GAC - Created
--->
<cffunction name="loadSelectedLabel" access="public" returntype="string" hint="Loads the Selected Items column header">
	<cfargument name="fieldName" type="String" required="true">
	<cfargument name="readonly" type="boolean" default="false" required="false">
	<cfargument name="gcCustomParams" type="struct" default="#StructNew()#" required="false">
	
	<cfscript>
		var retLabelHTML = "";
		var sLabel = variables.SELECTED_LABEL;
	</cfscript>
	<cfsavecontent variable="retLabelHTML">
		<cfoutput>
				<strong>#sLabel#:</strong><cfif arguments.readonly> (DISABLED)</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfreturn retLabelHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadChooserInstructions
Summary:
	Loads the instructions text for the Chooser field
Returns:
	String
Arguments:
	String - fieldName
	Boolean - readonly
History:
	2013-12-12 - GAC - Created
--->
<cffunction name="loadChooserInstructions" access="public" returntype="string" hint="General Chooser - Loads the instructions text for the Chooser field">
	<cfargument name="gcCustomParams" type="struct" default="#StructNew()#" required="false">
	
	<cfscript>
		var retInstructionsHTML = "";
		var aLabel = variables.AVAILABLE_LABEL;
		var sLabel = variables.SELECTED_LABEL;
		var renderInstructions = true;
		
		if ( StructKeyExists(variables,"SHOW_INSTRUCTIONS") AND variables.SHOW_INSTRUCTIONS )
			variables.SHOW_INSTRUCTIONS = false;
	</cfscript>
	<!--- // Check if we want to display the instructions --->
	<cfif renderInstructions>
		<!--- // Instructions text --->
		<cfsavecontent variable="retInstructionsHTML">
			<cfoutput>
					Select the records you want to include in the selections by dragging 
					items into or out of the '#aLabel#' list. Order the columns 
					within the datasheet by dragging items within the '#sLabel#' field.
			</cfoutput>
		</cfsavecontent>
	</cfif>
	<cfreturn retInstructionsHTML>
</cffunction>

<!------------------------------------- DATA FUNCTION ------------------------------------->
<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getSelections
Summary:
	Wrapper to get the CE Data returned in HTML DIV Format.
	Returns the html code for the selections of the profile select custom element.
Returns:
	String html code
Arguments:
	String - item - Items values for the CE records
	String - queryType - Query Type, options [selected,notSelected,search]
	String - searchValues - Search value
	Numeric - csPageID
	String - fieldID
History:
	2009-10-16 - MFC - Created
	2011-01-14 - MFC - Updated for ADF V1.5 to build in edit/delete icons and actions.
	2011-03-20 - MFC - Added flag for Edit/Delete links to the item row.
	2011-03-27 - MFC - Updates for IE styling.
	2011-08-01 - GAC - Added a closing DIV to the itemCell inside the LI tags in the retHTML
	2012-01-20 - GAC - Added the title attribute to the DIV wrapper around Item info since the display is truncated
					 - Added logic to display an ellipsis if the the Display text for an Item get truncated
	2012-01-23 - GAC - Added a DISPLAY_TEXT variable to allow different item Display Text from what is used for the ORDER_FIELD
	2012-09-06 - MFC - Updated to build the display text outside of the main string build.
	2013-01-10 - MFC - Disabled the Delete icon/action in the selection.
	2013-12-02 - GAC - Updated the edit/delete options to call a new callback function that reloads the selected items after an edit or a delete
	2014-03-05 - JTP - Var declarations
--->
<cffunction name="getSelections" access="public" returntype="string" hint="Returns the html code for the selections of the profile select custom element.">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="queryType" type="string" required="false" default="selected">
	<cfargument name="searchValues" type="string" required="false" default="">
	<cfargument name="csPageID" type="numeric" required="false" default="-1">
	<cfargument name="fieldID" type="string" required="false" default="">
	<cfargument name="readonly" type="boolean" default="false" required="false">
	<cfargument name="gcCustomParams" type="struct" default="#StructNew()#" required="false">
	
	<cfscript>
		var retHTML = "";
		var i = 1;
		var displayTextTrimSize = 26;
		var itemCls = "";
		var editDeleteLinks = "";
		var editDeleteButtonHTML = "";
		var itemEditDeleteCls = "itemEditDelete";
		var ceDataArray = getChooserData(arguments.item, arguments.queryType, arguments.searchValues, arguments.csPageID);
		var displayText = '';
		
		// Backward Compatibility - if a DISPLAY_TEXT variable not given or is not defined the ORDER_FIELD will still be used for the Item display text
		if ( NOT StructKeyExists(variables,"DISPLAY_FIELD") OR LEN(TRIM(variables.DISPLAY_FIELD)) EQ 0 )
			variables.DISPLAY_FIELD = variables.ORDER_FIELD;
		
		// Loop over the data 	
		for ( i=1; i LTE ArrayLen(ceDataArray); i=i+1) 
		{
			// Assemble the render HTML
			if ( StructKeyExists(ceDataArray[i].Values, "#variables.DISPLAY_FIELD#") 
					AND LEN(ceDataArray[i].Values[variables.DISPLAY_FIELD])
					AND StructKeyExists(ceDataArray[i].Values, "#variables.CE_FIELD#") 
					AND LEN(ceDataArray[i].Values[variables.CE_FIELD]) ) 
			{
				// Reset the item class on every loop iteration
				itemCls = variables.SELECT_ITEM_CLASS;
				
				// Build the Edit/Delete links
				if ( variables.SHOW_EDIT_DELETE_LINKS AND !arguments.readonly ) 
				{
					// Render the Buttons HTML
					editDeleteButtonHTML = loadEditDeleteItemLinks(fieldName=arguments.fieldID,formid=ceDataArray[i].formID,csPageID=ceDataArray[i].pageID,readonly=arguments.readonly,displayText=ceDataArray[i].Values[variables.DISPLAY_FIELD]);			
				    
				    if ( LEN(TRIM(editDeleteButtonHTML)) ) 
					 {
					    editDeleteLinks = "<div>";
					    editDeleteLinks = editDeleteLinks & TRIM(editDeleteButtonHTML);
					    editDeleteLinks = editDeleteLinks & "</div>";
					    
					    // Set the item class to add the spacing for the edit/delete links
				    	itemCls = itemCls & " " & itemEditDeleteCls;
				    }  
				}
				
				// Set the display text and determine if need "..."
				displayText = LEFT(ceDataArray[i].Values[variables.DISPLAY_FIELD], displayTextTrimSize);
				if ( LEN(displayText) GT displayTextTrimSize )
					displayText = displayText & "...";
					
				// Build the item, and add the Edit/Delete links
				retHTML = retHTML & "<li id='#ceDataArray[i].Values[variables.CE_FIELD]#' class='#itemCls#'><div class='itemCell' title='#ceDataArray[i].Values[variables.DISPLAY_FIELD]#'>#displayText##editDeleteLinks#</div></li>";
			}
		}
	</cfscript>
	<cfreturn retHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.
	M. Carroll
Name:
	$getChooserData
Summary:
	Wrapper to get the CE Data returned in HTML DIV Format.
	Primary work is completed in getCEData function.
Returns:
	Array of Structures
Arguments:
	String - item - Item Values to Search
	String - queryType - Query Type, options [selected,notSelected,search]
	String - searchValues - Search value
History:
	2009-10-16 - MFC - Created
--->
<cffunction name="getChooserData" access="private" returntype="Array">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="queryType" type="string" required="false" default="selected">
	<cfargument name="searchValues" type="string" required="false" default="">
	<cfargument name="csPageID" type="numeric" required="false" default="-1">
		
	<cfscript>
		// Initialize the return variable
		var retHTML = "";
		// Get the CE Data
		var dataArray = ArrayNew(1);
		// clean the search text
		if ( arguments.queryType eq "search" )
			arguments.searchValues = cleanChooserSearchText(arguments.searchValues);
		// Get custom element data
		// Check if we are returning all the records when items is empty string and querytype is NOTselected
		if ( (arguments.queryType EQ "notselected") AND (LEN(arguments.item) LTE 0) )
			dataArray = getCEData(variables.CUSTOM_ELEMENT);
		else
			dataArray = getCEData(variables.CUSTOM_ELEMENT, variables.CE_FIELD, arguments.item, arguments.queryType, arguments.searchValues, variables.SEARCH_FIELDS);
		// if are returning the selected items
		// 	sort the dataArray array order to match the passed in items ID order
		if ( arguments.queryType NEQ "selected" ) {
			// sort the dataArray
			dataArray = arrayOfCEDataSort(dataArray, variables.ORDER_FIELD);
		}
	</cfscript>
	<cfreturn dataArray>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$cleanChooserSearchText
Summary:
	Chooser search text cleaner
Returns:
	Query 
Arguments:
	String - Search Text
History:
	2009-04-06 - MFC - Created
--->
<cffunction name="cleanChooserSearchText" access="public" returnType="String" hint="Chooser search text cleaner.">
	<cfargument name="inText" type="string" required="true">
	<cfscript>
		var retText = arguments.inText;	
		// remove the single quote
		retText = Replace(retText,chr(39),"&##39;","all");
		// remove the double quote
		retText = Replace(retText,chr(34),"&##34;","all");
		return retText;
	</cfscript>
	
</cffunction>

</cfcomponent>