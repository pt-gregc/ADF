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
--->
<cfcomponent name="general_chooser" extends="ADF.extensions.customfields.general_chooser.general_chooser">

<cfproperty name="version" value="2_0_0">

<cfscript>
	// CUSTOM ELEMENT INFO
	variables.CUSTOM_ELEMENT = "";
	variables.CE_FIELD = "";
	variables.SEARCH_FIELDS = "";
	variables.ORDER_FIELD = "";

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
--->
<cffunction name="loadStyles" access="public" returntype="string" output="true" hint="">
	<cfargument name="fieldName" type="string" required="true">
	
	<cfset var retInitHTML = "">
	<cfsavecontent variable="retInitHTML">
		<cfoutput>
			<style>
				div##dialogFooter{
					font-weight: bold;
				    height: 28px;
				    margin-top: 15px;
				}
				/* ul.connectedSortable li {
					z-index: 100;
				} */
				div##pageListTableAvailableColumns, div##pageListTableSelectedColumns {
					position: inherit !important;
				}
				ul##availSelections, ul##selSelections {
					min-height: 285px;
				}
				div##filterBar {
					float:left;
					padding: 5px 0px;
				}
				div##saveBar {
					float:right;
					padding: 5px 0px;
				}
				div##infoBar {
					padding: 10px 0px;
				}
				.activeItem {
					background-color: ##FFFFFF;
					border: 1px solid ##CCCCCC;
					z-index: 2000;
				}
				/* ul##availSelections li {
					background-color: ##FFFFFF;
				} */
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
--->
<cffunction name="loadSearchBox" access="public" returntype="string" hint="General Chooser - Search box HTML content.">
	<cfargument name="fieldName" type="String" required="true">
	
	<cfset var retSearchBoxHTML = "">
	<!--- Check the variable flags for rendering --->
	<cfif variables.SHOW_SEARCH EQ true>
		<cfsavecontent variable="retSearchBoxHTML">
			<!--- Render out the search box to the field type --->
			<cfoutput>
				<div id="search-chooser">
					<input type="text" class="searchFld-chooser" id="#arguments.fieldName#-searchFld" name="searchbox" tabindex="1" onblur="this.value = this.value || this.defaultValue;" onfocus="this.value='';" value="Search" />
					<a href="javascript:;" id="#arguments.fieldName#-searchBtn" class="ui-state-default ui-corner-all #arguments.fieldName#-ui-buttons">Search</a>
				</div>
			</cfoutput>
			<cfif variables.SHOW_ALL_LINK EQ true>
				<!--- Render out the show all link to the field type --->
				<cfoutput>
					<div id="show-all-items">
						<a id="#arguments.fieldName#-showAllItems" href="javascript:;">Show All Items</a>
					</div>	
				</cfoutput>
			</cfif>
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
	2011-01-14 - MFC - Updated Add new link to utilize forms_1_5 by default.
--->
<cffunction name="loadAddNewLink" access="public" returntype="string" hint="General Chooser - Add New Link HTML content.">
	<cfargument name="fieldName" type="String" required="true">
	
	<cfset var retAddLinkHTML = "">
	
	<!--- Check if we want to display show all link --->
	<cfif variables.SHOW_ADD_LINK EQ true>
		<!--- Get the form ID for the custom element --->
		<cfset ceFormID = getFormIDByCEName(variables.CUSTOM_ELEMENT)>
		<!--- Render out the show all link to the field type --->
		<cfsavecontent variable="retAddLinkHTML">
			<cfoutput>
				<div id="add-new-items">
					<a href="javascript:;" rel="#application.ADF.ajaxProxy#?bean=Forms_1_1&method=renderAddEditForm&formID=#ceFormID#&dataPageId=0&callback=#arguments.fieldName#_addNewCallback&title=Add New Record" class="ADFLightbox ui-state-default ui-corner-all #arguments.fieldName#-ui-buttons">Add New Item</a>
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
		var editLink = "";
		var deleteLink = "";
		var ceDataArray = getChooserData(arguments.item, arguments.queryType, arguments.searchValues, arguments.csPageID);
		// Loop over the data 	
		for ( i=1; i LTE ArrayLen(ceDataArray); i=i+1) {
			// Assemble the render HTML
			if ( StructKeyExists(ceDataArray[i].Values, "#variables.ORDER_FIELD#") 
					AND LEN(ceDataArray[i].Values[variables.ORDER_FIELD])
					AND StructKeyExists(ceDataArray[i].Values, "#variables.CE_FIELD#") 
					AND LEN(ceDataArray[i].Values[variables.CE_FIELD]) )
			{
				editLink = "<a href='javascript:;' rel='#application.ADF.ajaxProxy#?bean=Forms_1_1&method=renderAddEditForm&formID=#ceDataArray[i].formID#&datapageId=#ceDataArray[i].pageID#&callback=#arguments.fieldID#_editCallback&title=Edit Record' class='ADFLightbox ui-icon ui-icon-pencil' style='float:left;'></a>";
				deleteLink = "<a href='javascript:;' rel='#application.ADF.ajaxProxy#?bean=Forms_1_1&method=renderDeleteForm&formID=#ceDataArray[i].formID#&datapageId=#ceDataArray[i].pageID#&callback=#arguments.fieldID#_deleteCallback&title=Delete Record' class='ADFLightbox ui-icon ui-icon-trash' style='float:left;'></a>";
				retHTML = retHTML & "<li id='#ceDataArray[i].Values[variables.CE_FIELD]#' class='#variables.SELECT_ITEM_CLASS#'><div class='itemCell'>#LEFT(ceDataArray[i].Values[variables.ORDER_FIELD],26)#<br />#editLink#&nbsp;#deleteLink#</li>";
			}
		}
	</cfscript>
	<cfreturn retHTML>
</cffunction>

</cfcomponent>