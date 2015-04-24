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
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	M Carroll 
Custom Field Type:
	general_chooser.cfc
Name:
	general_chooser.cfc
Summary:
	General Chooser component.
History:
	2009-10-16 - MFC - Created
	2009-11-13 - MFC - Updated the Ajax calls to the CFC to call the controller 
						function.  This allows only the "controller" function to 
						listed in the proxy white list XML file.
	2011-07-13 - MFC - Deprecated - Version "1.0" for new version "1.1".
						[TBD - Insert Link to ADF V1.5 Release Notes Here]
--->
<cfcomponent name="general_chooser" extends="ADF.lib.ceData.ceData_1_0">

<cfproperty name="version" value="1_0_0">

<cfscript>
	// CUSTOM ELEMENT INFO
	variables.CUSTOM_ELEMENT = "";
	variables.CE_FIELD = "";
	variables.SEARCH_FIELDS = "";
	variables.ORDER_FIELD = "";
	
	// LAYOUT FLAGS
	variables.SHOW_SECTION1 = true;  // Boolean
	variables.SHOW_SECTION2 = true;  // Boolean
	
	// STYLES
	variables.MAIN_WIDTH = 580;
	variables.SECTION1_WIDTH = 270;
	variables.SECTION2_WIDTH = 270;
	variables.SECTION3_WIDTH = 580;
	variables.SELECT_BOX_HEIGHT = 350;
	variables.SELECT_BOX_WIDTH = 250;
	variables.SELECT_ITEM_HEIGHT = 15;
	variables.SELECT_ITEM_WIDTH = 210;
	variables.SELECT_ITEM_CLASS = "ui-state-default";
	variables.JQUERY_UI_THEME = "ui-lightness";
	
	// ADDITIONS
	variables.SHOW_ALL_LINK = true;  // Boolean
	variables.ADD_NEW_FLAG = false;	// Boolean
	variables.ADD_NEW_URL = "";
	variables.ADD_NEW_LB_WIDTH = 600;
	variables.ADD_NEW_LB_HEIGHT = 420;

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
/* ***************************************************************
/*
Author: 	M Carroll
Name:
	$initChooser
Summary:
	General Chooser - Loads any global settings/styles for the chooser.
Returns:
	String html code
Arguments:
	Void
History:
	2009-10-16 - MFC - Created
--->
<cffunction name="initChooser" access="public" returntype="string" hint="General Chooser - Loads any global settings/styles for the chooser.">
	
	<cfset var retInitHTML = "">
	<cfsavecontent variable="retInitHTML">
		<cfoutput>
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
			</style>
		</cfoutput>
	</cfsavecontent>
	<cfreturn retInitHTML>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M Carroll
Name:
	$loadSection1
Summary:
	General Chooser section 1 HTML content.
Returns:
	String html code
Arguments:
	Void
History:
	2009-10-16 - MFC - Created
--->
<cffunction name="loadSection1" access="public" returntype="string" hint="General Chooser section 1 HTML content.">
		
	<cfset var retSect1HTML = "">
	<!--- Check the flag --->
	<cfif variables.SHOW_SECTION1 eq true>
		<cfsavecontent variable="retSect1HTML">
			<cfoutput>
				<style>
					div###arguments.fieldName#-gc-top-area div###arguments.fieldName#-gc-section1 {
						width: #variables.SECTION1_WIDTH#px;
						float: left;
					}	
				</style>
				#loadSearchBox(arguments.fieldName)#
				#loadShowAllLink(arguments.fieldName)#
			</cfoutput>
		</cfsavecontent>
	</cfif>
	<cfreturn retSect1HTML>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M Carroll
Name:
	$loadSection2
Summary:
	General Chooser section 2 HTML content.
Returns:
	String html code
Arguments:
	Void
History:
	2009-10-16 - MFC - Created
--->
<cffunction name="loadSection2" access="public" returntype="string" hint="General Chooser section 2 HTML content.">
	
	<cfset var retSect2HTML = "">
	<!--- Check the flag --->
	<cfif variables.SHOW_SECTION2 eq true>
		<cfsavecontent variable="retSect2HTML">
			<cfoutput>
				<style>
					div###arguments.fieldName#-gc-top-area div###arguments.fieldName#-gc-section2 {
						width: #variables.SECTION2_WIDTH#px;
						float: right;
						text-align: right;
						margin-right: 20px;
					}
				</style>
				#loadAddNewLink(arguments.fieldName)#
			</cfoutput>
		</cfsavecontent>
	</cfif>
	<cfreturn retSect2HTML>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M Carroll
Name:
	$loadSection3
Summary:
	General Chooser section 3 HTML content.
Returns:
	String html code
Arguments:
	Void
History:
	2009-10-16 - MFC - Created
--->
<cffunction name="loadSection3" access="public" returntype="string" hint="General Chooser section 3 HTML content.">
	
	<cfscript>
		var retSect3HTML = "";
		retSect3HTML = loadInstructions(arguments.fieldName);
		retSect3HTML = retSect3HTML & loadSelectBoxes(arguments.fieldName);
	</cfscript>
	<cfreturn retSect3HTML>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M Carroll
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
	2011-03-10 - SFS - The loadSearchBox function had an invalid field name of "search-box". ColdFusion considers variables with a "-" as invalid. Removed "-".
--->
<cffunction name="loadSearchBox" access="private" returntype="string" hint="General Chooser - Search box HTML content.">
	<cfargument name="fieldName" type="String" required="true">
	
	<cfset var retSearchBoxHTML = "">
	
	<!--- Render out the search box to the field type --->
	<cfsavecontent variable="retSearchBoxHTML">
		<cfoutput>
		<style>
			div###arguments.fieldName#-gc-top-area div##search-chooser {
				margin-bottom: 10px;
				border: none;
				width: 250px;
				height: 25px;
			}
			div###arguments.fieldName#-gc-main-area input {
				border-color: ##fff;
			}
		</style>
		<div id="search-chooser">
			<input type="text" class="searchFld-chooser" id="#arguments.fieldName#-searchFld" name="searchbox" tabindex="1" onblur="this.value = this.value || this.defaultValue;" onfocus="this.value='';" value="Search" />
			<input type="button" id="#arguments.fieldName#-searchBtn" value="Search" style="width:60px;"> 
		</div>
		</cfoutput>
	</cfsavecontent>
	<cfreturn retSearchBoxHTML>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M Carroll
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
	2014-03-05 - JTP - Var declarations
--->
<cffunction name="loadAddNewLink" access="private" returntype="string" hint="General Chooser - Add New Link HTML content.">
	
	<cfscript>
		var retAddLinkHTML = "";
		var ceFormID = 0;
	</cfscript>	
	
	<!--- Check if we want to display show all link --->
	<cfif variables.ADD_NEW_FLAG EQ true>
		<!--- Get the form ID for the custom element --->
		<cfset ceFormID = getFormIDByCEName(variables.CUSTOM_ELEMENT)>
		<!--- Render out the show all link to the field type --->
		<cfsavecontent variable="retAddLinkHTML">
			<cfoutput>
				<div id="add-new-items">
					<a href="#variables.ADD_NEW_URL#?formid=#ceFormID#&keepThis=true&TB_iframe=true&width=#variables.ADD_NEW_LB_WIDTH#&height=#variables.ADD_NEW_LB_HEIGHT#&title=Add New Item" title="Add New Item" class="ADFLightbox">Add New Item</a>
				</div>
			</cfoutput>
		</cfsavecontent>
	</cfif>
	<cfreturn retAddLinkHTML>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M Carroll
Name:
	$loadShowAllLink
Summary:
	General Chooser - Show All Link HTML content.
	REQUIRED: 
		- Link must have the ID field of: id="#arguments.fieldName#-showAllItems"
Returns:
	String html code
Arguments:
	String - fieldName - custom element unique fqFieldName
History:
	2009-05-29 - MFC - Created
--->
<cffunction name="loadShowAllLink" access="private" returntype="string" hint="General Chooser - Show All Link HTML content.">
	<cfargument name="fieldName" type="String" required="true">
	
	<cfset var retShowAllHTML = "">
	
	<!--- Check if we want to display show all link --->
	<cfif variables.SHOW_ALL_LINK EQ true>
		<!--- Render out the show all link to the field type --->
		<cfsavecontent variable="retShowAllHTML">
			<cfoutput>
			<div id="show-all-items">
				<a id="#arguments.fieldName#-showAllItems" href="##">show all items</a>
			</div>	
			</cfoutput>
		</cfsavecontent>
	</cfif>
	<cfreturn retShowAllHTML>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M Carroll
Name:
	$loadInstructions
Summary:
	General Chooser - Show Instructions HTML content.
	REQUIRED: 
		- Link must have the ID field of: id="#arguments.fieldName#-showAllItems"
Returns:
	String html code
Arguments:
	String - fieldName - custom element unique fqFieldName
History:
	2009-05-29 - MFC - Created
--->
<cffunction name="loadInstructions" access="private" returntype="string" hint="General Chooser - Show Instructions HTML content.">
	<cfargument name="fieldName" type="String" required="true">
	
	<cfset var retInstructHTML = "">
	<!--- Render out the search box to the field type --->
	<cfsavecontent variable="retInstructHTML">
		<cfoutput>
		<style>
			div###arguments.fieldName#-gc-top-area-instructions {
				clear: both;
				margin-top: 10px;
				margin-bottom: 10px;
				text-align: center;
			}
		</style>
		<div id="#arguments.fieldName#-gc-top-area-instructions">
			To make selections, drag and drop boxes from left to right box.
		</div>
		</cfoutput>
	</cfsavecontent>
	<cfreturn retInstructHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadSelectBoxes
Summary:
	General Chooser - Select Boxes HTML content.
	REQUIRED: 
		- Left UL must have the id as: id="#arguments.fieldName#-sortable1"
		- Right UL must have the id as: id="#arguments.fieldName#-sortable2"
Returns:
	String html code
Arguments:
	String - fieldName - custom element unique fqFieldName
History:
	2009-05-29 - MFC - Created
	2010-09-07 - MFC - Commented out the load Jquery UI.  This is done in the render file already.
						This load jquery UI call will throw error when updating JQuery UI versions.
--->
<cffunction name="loadSelectBoxes" access="private" returntype="string" hint="General Chooser - Select Boxes HTML content.">
	<cfargument name="fieldName" type="String" required="true">
	
	<cfset var retSelectBoxHTML = "">
	<!--- Render out the search box to the field type --->
	<cfsavecontent variable="retSelectBoxHTML">
		<cfoutput>
			<!--- <cfscript>
				server.ADF.objectFactory.getBean("scripts_1_0").loadJQueryUI("1.7.2", variables.JQUERY_UI_THEME);
			</cfscript> --->
			<style>
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
			</style>
			<div id="#arguments.fieldName#-gc-select-left-box">
				<ul id="#arguments.fieldName#-sortable1" class="connectedSortable">
				</ul>
			</div>
			<div id="#arguments.fieldName#-gc-select-right-box">
				<ul id="#arguments.fieldName#-sortable2" class="connectedSortable">
				</ul>
			</div>
		</cfoutput>
	</cfsavecontent>
	<cfreturn retSelectBoxHTML>
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
	<cfargument name="csPageID" type="numeric" required="false" default="">
		
	<cfscript>
		var retHTML = "";
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

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$getShowAllLinksFlag
Summary:
	Returns the Show All Link flag back to the field type.
Returns:
	String -  variables.SHOW_ALL_LINK
Arguments:
	None
History:
	2009-04-06 - MFC - Created
--->
<cffunction name="getShowAllLinksFlag" access="public" returntype="string" hint="Returns the Show All Link flag back to the field type.">
	<cfreturn variables.SHOW_ALL_LINK>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M Carroll
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
History:
	2009-10-16 - MFC - Created
--->
<cffunction name="getSelections" access="public" returntype="string" hint="Returns the html code for the selections of the profile select custom element.">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="queryType" type="string" required="false" default="selected">
	<cfargument name="searchValues" type="string" required="false" default="">
	<cfargument name="csPageID" type="numeric" required="false" default="">
	
	<cfscript>
		var retHTML = "";
		var i = 1;
		var ceDataArray = getChooserData(arguments.item, arguments.queryType, arguments.searchValues, arguments.csPageID);
		// Loop over the data 	
		for ( i=1; i LTE ArrayLen(ceDataArray); i=i+1) {
			// Assemble the render HTML
			if ( StructKeyExists(ceDataArray[i].Values, "#variables.ORDER_FIELD#") 
					AND LEN(ceDataArray[i].Values[variables.ORDER_FIELD])
					AND StructKeyExists(ceDataArray[i].Values, "#variables.CE_FIELD#") 
					AND LEN(ceDataArray[i].Values[variables.CE_FIELD]) ) {
				retHTML = retHTML & "<li id='#ceDataArray[i].Values[variables.CE_FIELD]#' class='#variables.SELECT_ITEM_CLASS#'><div class='itemCell'>#LEFT(ceDataArray[i].Values[variables.ORDER_FIELD],50)#</li>";
			}
		}
	</cfscript>
	<cfreturn retHTML>
</cffunction>

</cfcomponent>