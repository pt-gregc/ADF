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
	csData_1_1.cfc
Summary:
	CommonSpot Data Utils functions for the ADF Library
Version:
	1.1.0
History:
	2011-01-25 - MFC - Created - New v1.1
--->
<cfcomponent displayname="csData_1_1" extends="ADF.lib.csData.csData_1_0" hint="CommonSpot Data Utils functions for the ADF Library">
	
<cfproperty name="version" value="1_1_0">
<cfproperty name="type" value="singleton">
<cfproperty name="data" type="dependency" injectedBean="data_1_1">
<cfproperty name="taxonomy" type="dependency" injectedBean="taxonomy_1_1">
<cfproperty name="wikiTitle" value="CSData_1_1">

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	Ryan Kahn
Name:
	$getTextblockData
Summary:	
	Given a pageID and name, get the textblock data
Returns:
	struct
Arguments:
	name - string
	pageID - numeric
History:
 	Dec 15, 2010 - RAK - Created
--->
<cffunction name="getTextblockData" access="public" returntype="struct" hint="Given a pageID and name, get the textblock data">
	<cfargument name="name" type="string" required="true" default="" hint="Textblock Name">
	<cfargument name="pageID" type="numeric" required="true" default="-1" hint="PageID that contains the textblock">
	<cfset var returnData = StructNew()>
	<cfif Len(name) eq 0 or pageID lt 1>
		<cfreturn returnData>
	</cfif>
	
	<cfquery name="textblockData" datasource="#request.site.datasource#">
		 SELECT 	*
			FROM 	Data_TextBlock dtb
   INNER JOIN 	controlInstance ci on ci.controlID = dtb.controlID
		  where 	ci.controlName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">
			 and 	ci.pageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageID#">
			 and 	dtb.versionState = 2;
	</cfquery>
	<cfscript>
		if(textblockData.recordCount){
			returnData.dateAdded = textblockData.DateAdded;
			returnData.dateApproved = textblockData.DateApproved;
			returnData.controlID = textblockData.controlID;
			returnData.controlName = textblockData.controlName;
			returnData.pageID = textblockData.pageID;
			returnData.values = StructNew();
			returnData.values.caption = textblockData.caption;
			returnData.values.TextBlock = server.commonspot.udf.html.DECODEENTITIES(textblockData.TextBlock);
		}
		return returnData;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	G. Cronkright
Name:
	$getCustomMetadataFieldsByCSPageID
Summary:
	Returns a structure of custom metadata forms and fields from a CSPageID
Returns:
	Struct 
Arguments:
	String cspageid
	String fieldtype
History:
	2011-01-14 - GAC - Created
--->
<cffunction name="getCustomMetadataFieldsByCSPageID" access="public" returntype="struct">
	<cfargument name="cspageid" type="numeric" required="true">
	<cfargument name="fieldtype" type="string" default="" hint="Optional - taxonomy, text, select, etc. or a CFT name">
	
	<cfscript>
		var inheritedPageIDList = "";
		var stdMetadata = getStandardMetadata(arguments.cspageid);
		var getFormFields = queryNew("temp");
		var thisForm = StructNew(); 
		var thisField = "";
		var rtnStruct = StructNew();
		
		// Get the inheritedTemplateList from the stdMetadata
		if ( StructKeyExists(stdMetadata,"inheritedTemplateList") )
			inheritedPageIDList = ListAppend(stdMetadata.inheritedTemplateList,arguments.cspageid);
		else 
			inheritedPageIDList = arguments.cspageid;
	</cfscript>

	<!--- // Query to get the data for the element by pageid --->
	<cfquery name="getFormFields" datasource="#request.site.datasource#">
		SELECT     FormInputControl.FieldName,FormInputControlMap.FieldID,FormInputControl.Params,FormInputControl.Type,FormControl.FormName,FormControl.ID AS FormID
		FROM      FormControl 
			INNER JOIN FormInputControlMap 
				ON FormControl.ID = FormInputControlMap.FormID 
			INNER JOIN FormInputControl 
				ON FormInputControlMap.FieldID = FormInputControl.ID
		WHERE      FormInputControlMap.FormID IN ( SELECT	DISTINCT FormID
													 FROM      Data_FieldValue 
													 WHERE     PageID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#inheritedPageIDList#" list="true" />)
													 AND 	   VersionState = 2
													)
		<cfif LEN(TRIM(arguments.fieldtype))>
		AND FormInputControl.Type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fieldtype#" />	
       	</cfif>  	
		ORDER BY   FormControl.FormName,FormInputControl.FieldName
	</cfquery>

	<cfscript>
		// Convert the Query into a Struct of Structs [formName][FieldName]
		for( itm=1; itm lte getFormFields.recordCount; itm=itm+1 ) {
			 thisForm = getFormFields.FormName[itm];
			 // add the Form Name to the Struct
			 if ( NOT StructKeyExists(rtnStruct,thisForm ) ) {
			 	rtnStruct[thisForm] = StructNew();			  
			 }
			 // replace the FIC_ from the beginning
			 thisField = ReplaceNoCase(getFormFields.FieldName[itm], "FIC_", "", "all");
			 // add this field to the form
			 if( NOT StructKeyExists(rtnStruct[thisForm], thisField) )
			    rtnStruct[thisForm][thisField] = "";				
		}
		return rtnStruct;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ryan Kahn
Name:
	$getRSSFeedURLFromElementID
Summary:
	Given an elementID get the RSS feed url
Returns:
	String rssFeedURL
Arguments:
	Numeric elementID
History:
	2010-10-15 - RAK - Created
--->
<cffunction name="getRSSFeedURLFromElementID">
	<cfargument name="elementID" required="true" type="numeric" hint="attributes.elementinfo.id">
	<cfscript>
		var rssData = "";
		var pageURL = "";
	</cfscript>
	<cfquery name="rssData" datasource="#request.site.datasource#">
		select xpub.pageid, xfmt.name as fmtName, xpub.name as pubName from xmlpublications xpub
		join xmlpublicationformat xfmt on xfmt.XMLPublicationFormatID = xpub.XMLPublicationFormatID
		where xpub.controlid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.elementID#">
	</cfquery>
	<cfif rssData.recordCount>
		<cfscript>
			pageURL = application.ADF.csData.getCSPageURL(rssData.pageID);
			pageURL = pageURL&"?xml="&rssData.pubName&","&rssData.fmtName;
		</cfscript>
	</cfif>
	<cfreturn pageURL>
</cffunction>

<!---
/* *************************************************************** */
Author: 	Greg Cronkright
Name:
	$findReplaceStandardMetadata
Summary:
	From a pageID get the Standard Metadata for the page and then does a find/replace on values in the Standard Metadata
	structure. Uses a Array of structs that contains findText and replaceText to go through the designated fields.
	For use with createPage when build a new page from and existing page.
	When building findReplaceTextArray, each array item requires two keys: findText and replaceText 
	Example:
		foo = ArrayNew(1);
		foo[1].findtext = "Test Home";
		foo[1].replacetext = "New Dev";
		--This will change instances of the text: "Test Home Page" to "New Dev Page" 
		--and then returns the normal standardMetadata structure
	Remember it processes the array in order, so the last find/replace array item will take precedence
Returns:
	Struct struct
Arguments:
	numeric - csPageID 
	array - findReplaceTextArray 
	string - fieldList
History:
	201a-01-26 - GAC - Created
--->
<cffunction name="findReplaceStandardMetadata" access="public" returntype="struct" 
	hint="From a pageID get the Standard Metadata for the page and then does a find/replace on values in the Standard Metadata structure. Uses a Array of structs that contains findText and replaceText to go through the designated fields.">
	<cfargument name="csPageID" type="numeric" required="true">
	<cfargument name="findReplaceTextArray" type="array" required="false" default="#ArrayNew(1)#" hint="An array of structs with the source text to find and destination text to replace when creating the destination page.">
	<cfargument name="fieldList" type="string" required="false" default="Name,Title,Caption,Description,FileName" hint="List of standardMetadata fields to process. If blank, it will check them all.">
	<cfscript>
		var stndMetaStruct = getStandardMetadata(arguments.csPageID);
		var newStndMetaStruct = StructNew();
		var findReplaceArray = arguments.findReplaceTextArray;
		var structKeyList = TRIM(arguments.fieldList);
		var findTxt = "";
		var replaceTxt = "";
		var findFileName = "";
		var replaceFileName = "";
		var key = "";
		var findPos = 0;
		var findFilePos = 0;	
		var s = 1;
		
		// structKeyList has no value get a list of all the keys in the structure
		if ( LEN(structKeyList) EQ 0 )
			structKeyList = StructKeyList(stndMetaStruct);
		
		// If findReplace data was provided, do the work on the standard metadata
		if ( ArrayLen(findReplaceArray) ) {
			// Loop over the findReplace Array
			for( s=1; s LTE ArrayLen(findReplaceArray); s=s+1 ) {
				// Get the Find Text and the Replace text
				findTxt = "";
				if ( StructKeyExists(findReplaceArray[s],"findtext") ) 
					findTxt = findReplaceArray[s].findtext;
				replaceTxt = "";
				if ( StructKeyExists(findReplaceArray[s],"replacetext") ) 
					replaceTxt = findReplaceArray[s].replacetext;
				// Do not process if the findTxt has no value
				if ( LEN(findTxt) ) {
					// Loop over the metadata value that match the KEY LIST
					for ( key IN stndMetaStruct ) {
						if ( ListFindNoCase(structKeyList,key) ) {
							if ( key EQ "FILENAME" ) {
						  		// Add dashes to the find and replace text for file name matching
						  		findFileName  = REReplaceNoCase(findTxt,"[\s]","-","all");
						 		replaceFileName  = REReplaceNoCase(replaceTxt,"[\s]","-","all");
						  		// If the FIND text is found, replace it with the REPLACE text
						  		findFilePos = FindNoCase(findFileName, stndMetaStruct["FILENAME"]);
						  		if ( findFilePos ) 
						   			stndMetaStruct["FILENAME"] = ReplaceNoCase(stndMetaStruct["FILENAME"],findFileName,replaceFileName,"all");
						 	} else {
						 		// If the FIND text is found, replace it with the REPLACE text
						  		findPos = FindNoCase(findTxt, stndMetaStruct[key]);
						  		if ( findPos ) 
						  			stndMetaStruct[key] = ReplaceNoCase(stndMetaStruct[key],findTxt,replaceTxt,"all");
						 	}
						}
					}
				}
			}
		}
		return stndMetaStruct;
	</cfscript>
</cffunction>

</cfcomponent>