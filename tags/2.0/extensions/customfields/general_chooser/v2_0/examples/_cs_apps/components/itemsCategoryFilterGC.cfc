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
Custom Field Type:
	General Chooser
Name:
	itemsCategoryFilterGC.cfc
Summary:
	Sample General Chooser Property Component with Category Filtering 
History:
	2015-11-12 - GAC - Created
--->
<cfcomponent name="itemsCategoryFilterGC" extends="ADF.extensions.customfields.general_chooser.general_chooser">

<cfscript>
	// CUSTOM ELEMENT INFO
	variables.CUSTOM_ELEMENT = "gcItems";
	variables.CE_FIELD = "uniqueID"; // Must have the matching case as the field name in the element.
	variables.SEARCH_FIELDS = "Name";
	variables.ORDER_FIELD = "Name";
	// Display Text for the Chooser Items ( Defaults to the ORDER_FIELD )
	variables.DISPLAY_FIELD = "Name";
	
	// Custom Category Filter Variables
	variables.renderCatFilter = true;
	variables.catCustomElement = "gcCategories";
	variables.catCEField = "uniqueID";
	variables.catOrderField = "Name";
	variables.catDisplayField = "Name";
	variables.catUrlParam = "catIDFilter";
	variables.cefilterField = "category"; // Field from the Chooser Items Custom Element	
	
	// STYLES
	variables.MAIN_WIDTH = 580;
	variables.SECTION1_WIDTH = 270;
	variables.SECTION2_WIDTH = 270;
	variables.SECTION3_WIDTH = 580;
	variables.SELECT_BOX_HEIGHT = 350;
	variables.SELECT_BOX_WIDTH = 265;
	variables.SELECT_ITEM_HEIGHT = 15;
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
	variables.SHOW_DELETE_LINKS = false;  			// Boolean - SHOW_EDIT_DELETE_LINKS must be true to enable this option
	variables.SHOW_INSTRUCTIONS = true;				// Boolean
</cfscript>

<!--- 
	// getCustomGCparams - Custom Override
--->
<cffunction name="getCustomGCparams" access="public" returntype="struct" hint="Additional General Chooser Parameter Defaults to be injected in to the render file and passed to other method calls.">
	<cfscript>
		var custParams = StructNew();
		
		// Custom Parameters
		// - Category ID Filter Default
		// -- Option 1: Just set the default 
		// custParams[variables.catUrlParam] = ""; 
		// -- Option 2: Allow the Category to be pre-selected by passing in the catUrlParam from calling page (?catIDfilter=)
		custParams[variables.catUrlParam] = StructKeyExists(request.params,variables.catUrlParam) ? request.params[variables.catUrlParam] : "";
		
		return custParams;
	</cfscript>
</cffunction>

<!--- 
	// loadSearchBox - Custom Override
--->
<cffunction name="loadSearchBox" access="public" returntype="string" hint="General Chooser - Search box HTML content.">
	<cfargument name="fieldName" type="String" required="true">
	<cfargument name="readonly" type="boolean" default="false" required="false">
	<cfargument name="gcCustomParams" type="struct" default="#getCustomGCparams()#" required="false">
	
	<cfscript>
		var retSearchBoxHTML = "";
		var catDataArray = ArrayNew(1);
		var cat_i = 1;
		
		catDataArray = application.ADF.ceData.getCEData(variables.catCustomElement);
		catDataArray = application.ADF.ceData.arrayOfCEDataSort(catDataArray,variables.catOrderField);
		
		// Backward compatibility to allow the variables from General Chooser v1.0 site and app override GC files to honored
		if ( StructKeyExists(variables,"SHOW_SECTION1") )
			variables.SHOW_SEARCH = variables.SHOW_SECTION1;
	</cfscript>
	
	<!--- Check the variable flags for rendering --->
	<cfif variables.SHOW_SEARCH EQ true AND !arguments.readonly>
		<cfsavecontent variable="retSearchBoxHTML">
			<!--- Render out the search box to the field type --->
			<cfoutput>
				<cfif StructKeyExists(variables,"renderCatFilter") AND variables.renderCatFilter> 
				<style>
					div###arguments.fieldName#_catFilterBlock {
						padding-bottom: 10px;
					}
					span###arguments.fieldName#_catFilterShowAllLink {
						display: none
					}
				</style>
				<div id="#arguments.fieldName#_catFilterBlock">
					<!--- // Render a select for the category filter --->
					Category Filter:<br> 
					<select id="#arguments.fieldName#_categorySelect" name="#fieldName#_categorySelect">
						<option value=""<cfif gcCustomParams.catIDFilter EQ ""> selected="selected"</cfif>>All Categories</option>
						<cfloop index="cat_i" from="1" to="#ArrayLen(catDataArray)#">
							<option value="#catDataArray[cat_i].values[variables.catCEField]#"<cfif gcCustomParams[variables.catUrlParam] EQ catDataArray[cat_i].values[variables.catCEField]> selected="selected"</cfif>>#catDataArray[cat_i].values[variables.catDisplayField]#</option>
						</cfloop>
					</select>
					<a href="javascript:;" id="#arguments.fieldName#-filterBtn" class="ui-state-default ui-corner-all #arguments.fieldName#-ui-buttons">Filter</a>
				</div> 
				</cfif>
				<div id="search-chooser">
					<input type="text" class="searchFld-chooser" id="#arguments.fieldName#-searchFld" name="searchbox" value="" placeholder="Search" />
					<a href="javascript:;" id="#arguments.fieldName#-searchBtn" class="ui-state-default ui-corner-all #arguments.fieldName#-ui-buttons">Search</a>
					<cfif variables.SHOW_ALL_LINK EQ true>
					<!--- Render out the show all link to the field type --->
					<div id="show-all-items">
						<a id="#arguments.fieldName#-showAllItems" href="javascript:;">Show All Items</a> 
						<cfif StructKeyExists(variables,"renderCatFilter") AND variables.renderCatFilter> 
						<span id="#arguments.fieldName#_catFilterShowAllLink"> | <a id="#arguments.fieldName#-showAllFilteredItems" href="javascript:;">Show All Filtered Items</a></span>
						</cfif>
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
	// loadAddNewLink - Custom Override
--->
<cffunction name="loadAddNewLink" access="public" returntype="string" hint="General Chooser - Add New Link HTML content.">
	<cfargument name="fieldName" type="String" required="true">
	<cfargument name="readonly" type="boolean" default="false" required="false">
	<cfargument name="newItemLabel" type="String" default="#variables.NEW_ITEM_LABEL#" required="false">
	<cfargument name="inputParameters" type="struct" default="#StructNew()#" required="false">
	<cfargument name="gcCustomParams" type="struct" default="#getCustomGCparams()#" required="false">
	
	<cfscript>
		var retAddLinkHTML = "";
		var ceFormID = 0;
		var passthroughParamsStr = getPassthroughParamsString(arguments.inputParameters);
	
		// Backward Compatibility to allow the variables from General Chooser v1.0 site and app override GC files to be honored
		// - if the section2 variable is used and set to false... not ADD button should be displayed
		if ( StructKeyExists(variables,"SHOW_SECTION2") AND variables.SHOW_SECTION2 EQ false )
			variables.SHOW_ADD_LINK = false;
		
		// - if SHOW_ADD_LINK is still true (and SHOW_SECTION2 is true) then check for the ADD_NEW_FLAG variable	
		if ( StructKeyExists(variables,"ADD_NEW_FLAG") AND variables.SHOW_ADD_LINK NEQ false )
			variables.SHOW_ADD_LINK = variables.ADD_NEW_FLAG;
			
		//WriteDump(var="#arguments.inputParameters#",expand=false,label="inputParameters");
		//WriteDump(var="#passthroughParamsStr#",expand=false,label="passthroughParamsStr");
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
					
					jQuery(function(){
						jQuery("a###arguments.fieldName#-add-new-btn").click(function() { 
							var lightboxURL = "#application.ADF.lightboxProxy#?bean=Forms_2_0&method=renderAddEditForm&formID=#ceFormID#&dataPageId=0&callback=#arguments.fieldName#_formCallback&title=#variables.NEW_ITEM_LABEL##passthroughParamsStr#";
							
							<cfif StructKeyExists(arguments.inputParameters, "passthroughParams") AND ListFindNoCase(arguments.inputParameters.passthroughParams,variables.catUrlParam,",")>
							<!--- // To have the ADD NEW dialog auto select the Selected Category Filter: --->
							<!--- // 1) Must add the URL Param (ie. catIDFilter) to the 'Passthrough Params' in the General Chooser field definition --->
							<!--- // 2) Need to add the following logic as the Default value of the Category Selection List/Custom Element Select in the 'Items' element: 
										iif(StructKeyExists(request.params,"catIDFilter"),request.params.catIDFilter,"") - using the correct URL Param name --->
							var #variables.catUrlParam# = jQuery('select###arguments.fieldName#_categorySelect').find(':selected').val();	
							if ( #variables.catUrlParam#.length )
								lightboxURL = lightboxURL + '&#variables.catUrlParam#=' + #variables.catUrlParam#;
							</cfif>
							
							// Open the ADD NEW Dialog lighbox
							openLB(lightboxURL);
						});	
					});
				</script>
				<div id="add-new-items">
					<a href="javascript:;" id="#arguments.fieldName#-add-new-btn" class="ui-state-default ui-corner-all #arguments.fieldName#-ui-buttons">#variables.NEW_ITEM_LABEL#</a>
					<!--- <a href="javascript:;" rel="#application.ADF.ajaxProxy#?bean=Forms_2_0&method=renderAddEditForm&formID=#ceFormID#&dataPageId=0&callback=#arguments.fieldName#_formCallback&title=#variables.NEW_ITEM_LABEL##passthroughParamsStr#" class="ADFLightbox ui-state-default ui-corner-all #arguments.fieldName#-ui-buttons">#variables.NEW_ITEM_LABEL#</a> --->
				</div>
			</cfoutput>
		</cfsavecontent>
	</cfif>
	
	<cfreturn retAddLinkHTML>
</cffunction>

<!--- 
	// renderChooserJS - Custom Override
--->
<cffunction name="renderChooserJS" access="public" returntype="void" output="true" hint="Renders the Chooser CFT's JavaScript.">
	<cfargument name="fieldName" type="string" required="true">
	<cfargument name="formname" type="string" required="true">
	<cfargument name="currentValue" type="string" default="" required="false">
	<cfargument name="readonly" type="boolean" default="false" required="false">
	<cfargument name="rendertabindex" type="numeric" default="0" required="false">
	<cfargument name="csPageID" type="numeric" default="#request.page.id#" required="false">
	<cfargument name="inputParameters" type="struct" default="#StructNew()#" required="false">
	<cfargument name="gcCustomParams" type="struct" default="#getCustomGCparams()#" required="false">
	
	<cfscript>
		var passthroughParamsStr = getPassthroughParamsString(arguments.inputParameters);
		
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
var #arguments.fieldName#_ajaxProxyURL = "#application.ADF.ajaxProxy#?#passthroughParamsStr#";
var #arguments.fieldName#_currentValue = "#arguments.currentValue#";
var #arguments.fieldName#_searchValues = "";
<cfif StructKeyExists(variables,"renderCatFilter") AND variables.renderCatFilter> 
var #arguments.fieldName#_useFilter = 0;
</cfif>
	
jQuery(function(){
		
	// Resize the window on the page load
	checkResizeWindow();
		
	// Click Event for Show all Items link
	jQuery('###arguments.fieldName#-showAllItems').click(function() {
		jQuery('select###arguments.fieldName#_categorySelect').val('');
		jQuery('input###arguments.fieldName#-searchFld').val('');
		
		<cfif StructKeyExists(variables,"renderCatFilter") AND variables.renderCatFilter> 
		jQuery('span###arguments.fieldName#_catFilterShowAllLink').hide();
		#arguments.fieldName#_useFilter = 0;
		</cfif>
		
		// Load all the not-selected options
		#arguments.fieldName#_loadTopics('notselected');
	});
	    
	// Click event for search button
	jQuery('###arguments.fieldName#-searchBtn').click(function() {
		//load the search field into currentItems
		#arguments.fieldName#_searchValues = jQuery('input###arguments.fieldName#-searchFld').val();
		
		<cfif StructKeyExists(variables,"renderCatFilter") AND variables.renderCatFilter> 
		#arguments.fieldName#_useFilter = 1;
		</cfif>
		
		#arguments.fieldName#_loadTopics('search');
	});
	
	<cfif StructKeyExists(variables,"renderCatFilter") AND variables.renderCatFilter> 
	// Click Event for Filter Button link
	jQuery('###arguments.fieldName#-filterBtn').click(function() {
		var filterVal = jQuery('select###arguments.fieldName#_categorySelect').find(':selected').val();
	
		if ( filterVal != '' )
			jQuery('span###arguments.fieldName#_catFilterShowAllLink').show();
		else
			jQuery('span###arguments.fieldName#_catFilterShowAllLink').hide();
		
		jQuery('input###arguments.fieldName#-searchFld').val('');
		#arguments.fieldName#_useFilter = 1;
			
		// Load all the not-selected options
		#arguments.fieldName#_loadTopics('notselected');
	});
	// Click Event for Show all Filtered Items link
	jQuery('###arguments.fieldName#-showAllFilteredItems').click(function() {
		jQuery('input###arguments.fieldName#-searchFld').val('');
		#arguments.fieldName#_useFilter = 1;
		// Load all the not-selected options
		#arguments.fieldName#_loadTopics('notselected');
	});
	</cfif>
		
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
	// Update the currentValue Global variable 
	#arguments.fieldName#_currentValue = jQuery('input###arguments.fieldName#').val();
	
	<cfif StructKeyExists(variables,"renderCatFilter") AND variables.renderCatFilter AND StructKeyExists(variables,"catUrlParam") AND LEN(TRIM(variables.catUrlParam))>
	// Get the value of the selected Category	
	var #variables.catUrlParam# = "";
	if ( #arguments.fieldName#_useFilter )
		#variables.catUrlParam# = jQuery('select###arguments.fieldName#_categorySelect').find(':selected').val();	
	</cfif>
			
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
		item: #arguments.fieldName#_currentValue,
		queryType: queryType,
		searchValues: #arguments.fieldName#_searchValues,
		csPageID: '#arguments.csPageID#',
		fieldID: '#arguments.fieldName#',
		dataPageID: <cfif structKeyExists(request.params, "dataPageID")>#request.params.dataPageID#<cfelseif structKeyExists(request.params, "pageID")>#request.params.pageID#<cfelse>#request.page.id#</cfif>,
		controlID: <cfif structKeyExists(request.params, "controlID")>#request.params.controlID#<cfelse>0</cfif>
		<cfif StructKeyExists(variables,"renderCatFilter") AND variables.renderCatFilter AND StructKeyExists(variables,"catUrlParam") AND LEN(TRIM(variables.catUrlParam))>
		,#variables.catUrlParam#: #variables.catUrlParam#
		</cfif>
		<!--- <cfloop collection="#arguments.gcCustomParams#" item="key">
		,#key#: #key#
		</cfloop> --->
		<!--- ,debug: 1 --->
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
			cValue = #arguments.fieldName#_ListAppend(formData[js_#arguments.fieldName#_CE_FIELD], cValue);
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
	if ( selections.length )
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

// A utility function for appending values to a list 
function #arguments.fieldName#_ListAppend(a,b,e)
{
	var c="";
	a+="";
	
	if(!e)
		e=",";

	if( #arguments.fieldName#_ListLen(a,e) )
		c=a+e+b;
	else
		c=b;
		
	return c;
}

// A utility function for counting items in a list 
function #arguments.fieldName#_ListLen(a,b)
{
	a+="";
	if ( !b )
		b=",";
	
	if ( a.length )
		return a.split(b).length;
		
	return 0;
}

-->
</script></cfoutput>	
</cffunction>

<!--- 
	// getChooserData - Custom Override
--->
<cffunction name="getChooserData" access="public" returntype="Array">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="queryType" type="string" required="false" default="selected">
	<cfargument name="searchValues" type="string" required="false" default="">
	<cfargument name="csPageID" type="numeric" required="false" default="-1">
	<cfargument name="gcCustomParams" type="struct" default="#getCustomGCparams()#" required="false">
		
	<cfscript>
		// Initialize the return variable
		var retHTML = "";
		// Get the CE Data
		var dataArray = ArrayNew(1);
		var filterDataArray = ArrayNew(1); 
		var i = 1;

		// clean the search text
		if ( arguments.queryType eq "search" )
			arguments.searchValues = cleanChooserSearchText(arguments.searchValues);
			
		// Get custom element data
		// Check if we are returning all the records when items is empty string and querytype is NOTselected
		if ( (arguments.queryType EQ "notselected") AND (LEN(arguments.item) LTE 0) )
			dataArray = getCEData(variables.CUSTOM_ELEMENT);
		else
			dataArray = getCEData(variables.CUSTOM_ELEMENT, variables.CE_FIELD, arguments.item, arguments.queryType, arguments.searchValues, variables.SEARCH_FIELDS);
		// Filter the out the record not from the selected category
		if ( variables.renderCatFilter AND arguments.queryType NEQ "selected" 
				AND StructKeyExists(arguments.gcCustomParams,variables.catUrlParam) 
				AND arguments.gcCustomParams[variables.catUrlParam] NEQ "" )
		{	
			for ( i=1; i LTE ArrayLen(dataArray); i=i+1) {
				// Check the current rows category value
				if ( dataArray[i].values[variables.cefilterField] EQ arguments.gcCustomParams[variables.catUrlParam] )
					arrayAppend(filterDataArray,dataArray[i]);
				
			}
			dataArray = filterDataArray;
		}
		
		// if are returning the selected items
		// 	sort the dataArray array order to match the passed in items ID order
		if ( arguments.queryType NEQ "selected" ) 
		{
			dataArray = arrayOfCEDataSort(dataArray, variables.ORDER_FIELD);
		}
		
		return dataArray;
	</cfscript>
</cffunction>

</cfcomponent>