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
Name:
	csPage_1_1.cfc
Summary:
	CCAPI Page functions for the ADF Library
Version:
	1.1.0
History:
	2011-01-25 - RLW - Created - New v1.1
---> 
<cfcomponent displayname="csPage_1_1" extends="ADF.lib.ccapi.csPage_1_0" hint="Constructs a CCAPI instance and then creates or deletes a page with the given information">
<cfproperty name="version" value="1_1_0">
<cfproperty name="type" value="transient">
<cfproperty name="ccapi" type="dependency" injectedBean="ccapi">
<cfproperty name="csData" type="dependency" injectedBean="csData_1_1">
<cfproperty name="ceData" type="dependency" injectedBean="ceData_1_1">
<cfproperty name="taxonomy" type="dependency" injectedBean="taxonomy_1_1">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_1">
<cfproperty name="wikiTitle" value="CSPage_1_1">

<cfscript>
	// standard metadata structures
	variables.stdMetadata = structNew();
	// variables.stdMetadata.pageID = 0;
	variables.stdMetadata.name = "";
	variables.stdMetadata.title = "";
	variables.stdMetadata.caption = "";
	variables.stdMetadata.description = "";
	variables.stdMetadata.globalKeywords = "";
	variables.stdMetadata.categoryName = "";
	variables.stdMetadata.subsiteID = "";
	variables.stdMetadata.templateID = "";
	// custom metadata structure
	variables.custMetadata = structNew();
	// page data
	variables.pageID = 0;
</cfscript>

<!---
/* ***************************************************************
/*
Author: 	Ryan Kahn
Name:
	$copyPage
Summary:
	Duplicates the page from source to destination using destination template. 
	IF sourceNames and destCCAPINames are defined it will attempt a ccapi set on the destCCAPINames from the source set.
Returns:
	Struct boolean
Arguments:
	numeric: sourcePageID 
	numeric: destinationSubsiteID 
	numeric: destinationTemplateID 
	array: sourceNames
		The elements (including textblocks) must have names declared (More -> Name)
	array: destCCAPINames
		The elements (including textblocks) must have ccapi mapping information.
	array: findReplaceStandardMetadata
		An array of structs with the source text to find and destination text to replace in the values of the
		Standard Metadata struct when creating the destination page.
History:
	2010-11-05 - RAK - Created
	2011-01-14 - GAC - Modified - Coverted Applicatio.ADF calls to Global
	2011-01-14 - GAC - Added logic to Get convert Taxonomy terms to a termID list
	2011-01-15 - GAC - Moved the convert Taxonomy terms to termids into the getCustomMetadata function
	2011-01-26 - GAC - Added a call to a method that does a find and replace of Standard Metadata values (ie. Name, Title, Caption, Description and FileName)
						the function replaces the source info with the new info for destination before creating the destination page
--->
<cffunction name="copyPage" access="public" returntype="boolean" hint="Duplicates the page from source to destination using destination template. ">
	<cfargument name="sourcePageID" type="numeric" required="true">
	<cfargument name="destinationSubsiteID" type="numeric" required="true">
	<cfargument name="destinationTemplateID" type="numeric" required="false">
	<cfargument name="sourceNames" type="array" required="false" default="#ArrayNew(1)#" hint="The elements (including textblocks) must have names declared (More -> Name)">
	<cfargument name="destCCAPINames" type="array" required="false" default="#ArrayNew(1)#" hint="The elements (including textblocks) must have ccapi mapping information.">
	<cfargument name="findReplaceStandardMetadata" type="array" required="false" default="#ArrayNew(1)#" hint="An array of structs with the source text to find and destination text to replace in the values of the Standard Metadata struct when creating the destination page.">

	<cfscript>
		var i = 1;
		var j = 1;
		var k = 1;
		var customElementFormID = "";
		var elementInformation = "";
		var customData = "";
		var stdMetadata = StructNew();
		var textblockData ="";
		var data = StructNew();
		var currentField = "";
		// Use the flag in getCustomMetadata to convert Taxonomy Term Lists to TermID lists in taxonomy custom metadata fields
		var custMetadata = variables.csData.getCustomMetadata(pageid=arguments.sourcePageID,convertTaxonomyTermsToIDs=1);
		var sourcePage = variables.csData.getStandardMetadata(arguments.sourcePageID);
		var ccapiElements = "";
		 
		//Error checking
		if ( ArrayLen(sourceNames) neq ArrayLen(destCCAPINames) ) {
			variables.utils.logAppend("Source custom element list is not the same length of custom element names.","copyPageLog.txt");
			return false;
		}
		
		// If a findReplaceStandardMetadata Array was provided, do some work on the standard metadata
		if ( ArrayLen(arguments.findReplaceStandardMetadata) ) 
			sourcePage = variables.csData.findReplaceStandardMetadata(arguments.sourcePageID,arguments.findReplaceStandardMetadata); 
		
		//Does the page exist? If so throw an exception telling them so
		if ( variables.csData.getCSPageByName(sourcePage.name,arguments.destinationSubsiteID) ) {
			variables.utils.logAppend("Page already exists: '#sourcePage.name#' in subsiteID: #arguments.destinationSubsiteID#","copyPageLog.txt");
			return false;
		}
		
		//setup the stdMetadata from our source page
		stdMetadata = sourcePage;
		stdMetadata.templateID = arguments.destinationTemplateID;
		stdMetadata.subsiteID = arguments.destinationSubsiteID;
		
		//remove the pageid from the standard metadata
		StructDelete(stdMetadata,"pageid");

		//Create the page
		newPage = Application.ADF.csPage.createPage(stdMetadata,custMetadata);
		if(!newPage.pageCreated){//we couldnt create the page! Log the error and return out false.
			variables.utils.logAppend("There was an error while creating page: '#stdMetadata.name#' in subsiteID: #stdMetadata.subsiteID#","copyPageLog.txt");
			return false;
		}
		//Page creation successful!
		newPageID = newPage.newPageID;

		variables.ccapi.initCCAPI();
		ccapiElements = variables.ccapi.getElements();

		//Iterate over each element and process the imports!
		for(i=1;i<=ArrayLen(arguments.sourceNames);i++){
			//Verify the mapping exists
			if( !StructKeyExists(ccapiElements,arguments.destCCAPINames[i]) ){
				variables.utils.logAppend("Destination element name #arguments.destCCAPINames[i]# is not mapped correctly in CCAPI configuration","copyPageLog.txt");
				return false;
			}

			//Setup the data for each custom element
			data = StructNew();
			data.subsiteID = arguments.destinationSubsiteID;
			data.pageID = newPageID;
			data.submitChange = 1;


			//If the element we are working with is a textblock handle things differently
			if(ccapiElements[arguments.destCCAPINames[i]].elementType eq "textblock"){
				data.submitChange_comment = "Submit data for TextBlock through API";
				//Get the textblock's data
				textblockData = variables.csData.getTextblockData(arguments.sourceNames[i],arguments.sourcePageID);

				data.textblock = textblockData.values.textblock;
				data.caption = textblockdata.values.caption;

			}else{ //this is a custom element. we know how to handle it!
				data.submitChange_comment = "Submit data for Custom element through API";

				//Get the custom data
				customData = variables.ceData.getElementByNameAndCSPageID(arguments.sourceNames[i],arguments.sourcePageID);
				if(structIsEmpty(customData)){
           			variables.utils.logAppend("There was an error while getting element: '#sourceNames[i]#' from page: '#arguments.sourcePageID#'","copyPageLog.txt");
					return false;
				}

				//Get the tabs, iterate over
				elementTabs = variables.ceData.getTabsFromFormID(customData.formID,true);
				//Iterate over each tab
				for(k=1;k<=ArrayLen(elementTabs);k++){
					//Iterate over each field in the tab
					for(j=1;j<=ArrayLen(elementTabs[k].fields);j++){
						//Get the current field for the current tab
						currentField = elementTabs[k].fields[j];
						//Its a formatted text block! Fix the entities!}
						if(currentField.defaultValues.type == "formatted_text_block"){
							customData.values[currentField.fieldName] = server.commonspot.udf.html.DECODEENTITIES(customData.values[currentField.fieldName]);
						}
						//Fill out data with the updated value
						data[currentField.fieldName] = customData.values[currentField.fieldName];
					}
				}
			}
			//Populate the element with the data
			populateContentResults = application.ADF.csContent.populateContent(destCustomElementNames[i],data);
			if(!populateContentResults.contentUpdated){
				variables.utils.logAppend("There was an error while updating element: '#destCustomElementNames[i]#' on page: '#stdMetadata.name#' in subsiteID: #stdMetadata.subsiteID#","copyPageLog.txt");
				return false;
			}

		}
		//Log our success!
		variables.utils.logAppend("Page '#stdMetadata.name#' created in subsiteID: #stdMetadata.subsiteID# succesfully.","copyPageLog.txt");
		return true;
	</cfscript>
</cffunction>

</cfcomponent>