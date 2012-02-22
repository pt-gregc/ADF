<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2011.
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
	general_chooser.cfc
Name:
	general_chooser.cfc
Summary:
	General Chooser component.
Version:
	1.1.0
History:
	2009-10-16 - MFC - Created
	2009-11-13 - MFC - Updated the Ajax calls to the CFC to call the controller 
						function.  This allows only the "controller" function to 
						listed in the proxy white list XML file.
	2011-03-20 - MFC - Updated component to simplify the customizations process and performance.
						Removed Ajax loading process.
	2012-01-30 - GAC - Added a Display_Feild varaible to the General Chooser init variables.
--->
<cfcomponent name="general_chooser" extends="ADF.lib.ceData.ceData_1_0">

<cfproperty name="version" value="1_1_0">

<cfscript>
	// CUSTOM ELEMENT INFO
	variables.CUSTOM_ELEMENT = "";
	variables.CE_FIELD = "";
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
	variables.SELECT_BOX_WIDTH = 250;
	variables.SELECT_ITEM_HEIGHT = 30;
	variables.SELECT_ITEM_WIDTH = 210;
	variables.SELECT_ITEM_CLASS = "ui-state-default";
	variables.JQUERY_UI_THEME = "ui-lightness";
	
	// NEW VARIABLES v1.1
	variables.SHOW_SEARCH = true;  // Boolean
	variables.SHOW_ALL_LINK = true;  // Boolean
	variables.SHOW_ADD_LINK = true;  // Boolean
	variables.SHOW_EDIT_DELETE_LINKS = false;  // Boolean
</cfscript>

<!---
/* ***************************************************************
/*
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
			if( thisParam neq "method" and thisParam neq "bean" and thisParam neq "chooserMethod" )
			{
				argStr = listAppend(argStr, "#thisParam#='#arguments[thisParam]#'");
			}
		}
		if( len(argStr) )
			reHTML = Evaluate("#arguments.chooserMethod#(#argStr#)");
		else
			reHTML = Evaluate("#arguments.chooserMethod#()");
			
	</cfscript>
	<cfreturn reHTML>
	
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
				/* Item box inner html classes */
				.itemCell .itemCellLeft{
					width: 60px;
					float: left;
				}
				.itemCell .itemCellRight{
					width: 150px;
					float: right;
				}
				.serializer
				{
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
					margin-right: 20px;
				}
				
				/* Main Area Selection Section */
				div###arguments.fieldName#-gc-main-area div###arguments.fieldName#-gc-section3 {
					clear:  both;
					padding-top: 10px;
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
					margin: 10px;
					padding: 2px;
					text-align: center;
				}
				div###arguments.fieldName#-gc-main-area div###arguments.fieldName#-gc-select-left-box {
					width: #variables.SELECT_BOX_WIDTH#px;
					float: left;
					min-height: #variables.SELECT_BOX_HEIGHT#px;
					height: #variables.SELECT_BOX_HEIGHT#px;
					border: 1px solid ##000000;
					margin: 10px;
					padding: 2px;
					overflow-y: auto;
				}
				div###arguments.fieldName#-gc-main-area div###arguments.fieldName#-gc-select-right-box-label {
					width: #variables.SELECT_BOX_WIDTH#px;
					float: right;
					height: 10px;
					margin: 10px;
					padding: 2px;
					text-align: center;
				}
				div###arguments.fieldName#-gc-main-area div###arguments.fieldName#-gc-select-right-box {
					width: #variables.SELECT_BOX_WIDTH#px;
					float: right;
					min-height: #variables.SELECT_BOX_HEIGHT#px;
					height: #variables.SELECT_BOX_HEIGHT#px;
					border: 1px solid ##000000;
					margin: 10px;
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
				###arguments.fieldName#-sortable1 li.itemEditDelete,
				###arguments.fieldName#-sortable2 li.itemEditDelete { 
					height: #variables.SELECT_ITEM_HEIGHT+20#px;
				}
				
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
--->
<cffunction name="loadSearchBox" access="public" returntype="string" hint="General Chooser - Search box HTML content.">
	<cfargument name="fieldName" type="String" required="true">
	
	<cfscript>
		var retSearchBoxHTML = "";
		
		// Backward compatibility to allow the variables from General Chooser v1.0 site and app override GC files to honored
		if ( StructKeyExists(variables,"SHOW_SECTION1") )
			variables.SHOW_SEARCH = variables.SHOW_SECTION1;
	</cfscript>
	
	<!--- Check the variable flags for rendering --->
	<cfif variables.SHOW_SEARCH EQ true>
		<cfsavecontent variable="retSearchBoxHTML">
			<!--- Render out the search box to the field type --->
			<cfoutput>
				<div id="search-chooser">
					<input type="text" class="searchFld-chooser" id="#arguments.fieldName#-searchFld" name="searchbox" tabindex="1" onblur="this.value = this.value || this.defaultValue;" onfocus="this.value='';" value="Search" />
					<a href="javascript:;" id="#arguments.fieldName#-searchBtn" class="ui-state-default ui-corner-all #arguments.fieldName#-ui-buttons">Search</a>
					<cfif variables.SHOW_ALL_LINK EQ true>
					<!--- Render out the show all link to the field type --->
					<div id="show-all-items">
						<a id="#arguments.fieldName#-showAllItems" href="javascript:;">Show All Items</a>
					</div>	
					</cfif>
				</div>
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
--->
<cffunction name="loadAddNewLink" access="public" returntype="string" hint="General Chooser - Add New Link HTML content.">
	<cfargument name="fieldName" type="String" required="true">
	
	<cfscript>
		var retAddLinkHTML = "";
	
		// Backward Compatibility to allow the variables from General Chooser v1.0 site and app override GC files to be honored
		// - if the section2 variable is used and set to false... not ADD button should be displayed
		if ( StructKeyExists(variables,"SHOW_SECTION2") AND variables.SHOW_SECTION2 EQ false )
			variables.SHOW_ADD_LINK = false;
		
		// - if SHOW_ADD_LINK is still true (and SHOW_SECTION2 is true) then check for the ADD_NEW_FLAG variable	
		if ( StructKeyExists(variables,"ADD_NEW_FLAG") AND variables.SHOW_ADD_LINK NEQ false )
			variables.SHOW_ADD_LINK = variables.ADD_NEW_FLAG;
	</cfscript>
	
	<!--- Check if we want to display show all link --->
	<cfif variables.SHOW_ADD_LINK EQ true>
		<!--- Get the form ID for the custom element --->
		<cfset ceFormID = getFormIDByCEName(variables.CUSTOM_ELEMENT)>
		<!--- Render out the show all link to the field type --->
		<cfsavecontent variable="retAddLinkHTML">
			<cfoutput>
				<div id="add-new-items">
					<a href="javascript:;" rel="#application.ADF.ajaxProxy#?bean=Forms_1_1&method=renderAddEditForm&formID=#ceFormID#&dataPageId=0&callback=#arguments.fieldName#_formCallback&title=Add New Record" class="ADFLightbox ui-state-default ui-corner-all #arguments.fieldName#-ui-buttons">Add New Item</a>
				</div>
			</cfoutput>
		</cfsavecontent>
	</cfif>
	<cfreturn retAddLinkHTML>
</cffunction>


<!------------------------------------- DATA FUNCTION ------------------------------------->
<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M Carroll
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
--->
<cffunction name="getSelections" access="public" returntype="string" hint="Returns the html code for the selections of the profile select custom element.">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="queryType" type="string" required="false" default="selected">
	<cfargument name="searchValues" type="string" required="false" default="">
	<cfargument name="csPageID" type="numeric" required="false" default="-1">
	<cfargument name="fieldID" type="string" required="false" default="">
	
	<cfscript>
		var retHTML = "";
		var i = 1;
		var editDeleteLinks = "";
		var itemCls = "";
		var ceDataArray = getChooserData(arguments.item, arguments.queryType, arguments.searchValues, arguments.csPageID);
		
		// Backward Compatibility - if a DISPLAY_TEXT variable not given or is not defined the ORDER_FIELD will still be used for the Item display text
		if ( NOT StructKeyExists(variables,"DISPLAY_FIELD") OR LEN(TRIM(variables.DISPLAY_FIELD)) EQ 0 )
			variables.DISPLAY_FIELD = variables.ORDER_FIELD;
		
		// Loop over the data 	
		for ( i=1; i LTE ArrayLen(ceDataArray); i=i+1) {
			// Assemble the render HTML
			if ( StructKeyExists(ceDataArray[i].Values, "#variables.DISPLAY_FIELD#") 
					AND LEN(ceDataArray[i].Values[variables.DISPLAY_FIELD])
					AND StructKeyExists(ceDataArray[i].Values, "#variables.CE_FIELD#") 
					AND LEN(ceDataArray[i].Values[variables.CE_FIELD]) )
			{
				// Reset the item class on every loop iteration
				itemCls = variables.SELECT_ITEM_CLASS;
				// Build the Edit/Delete links
				if ( variables.SHOW_EDIT_DELETE_LINKS ) {
					editDeleteLinks = "<br /><table><tr><td><a href='javascript:;' rel='#application.ADF.ajaxProxy#?bean=Forms_1_1&method=renderAddEditForm&formID=#ceDataArray[i].formID#&datapageId=#ceDataArray[i].pageID#&callback=#arguments.fieldID#_formCallback&title=Edit Record' class='ADFLightbox ui-icon ui-icon-pencil'></a></td>";
					editDeleteLinks = editDeleteLinks & "<td><a href='javascript:;' rel='#application.ADF.ajaxProxy#?bean=Forms_1_1&method=renderDeleteForm&formID=#ceDataArray[i].formID#&datapageId=#ceDataArray[i].pageID#&callback=#arguments.fieldID#_formCallback&title=Delete Record' class='ADFLightbox ui-icon ui-icon-trash'></a></td></tr></table>";
				    // Set the item class to add the spacing for the edit/delete links
				    itemCls = itemCls & " itemEditDelete";
				}
				// Build the item, and add the Edit/Delete links
				retHTML = retHTML & "<li id='#ceDataArray[i].Values[variables.CE_FIELD]#' class='#itemCls#'><div class='itemCell' title='#ceDataArray[i].Values[variables.DISPLAY_FIELD]#'>#LEFT(ceDataArray[i].Values[variables.DISPLAY_FIELD],26)#<cfif LEN(ceDataArray[i].Values[variables.DISPLAY_FIELD])) GT 26>...</cfif>#editDeleteLinks#</div></li>";
			}
		}
	</cfscript>
	<cfreturn retHTML>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
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
/* ***************************************************************
/*
Author: 	M. Carroll
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