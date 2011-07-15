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
	2011-03-10 - MFC/GAC - Moved getGlobalKeywords function to CSData v1.1, and moved the latest
						getCustomMetadata and getStandardMetadata functions to CSData v1.1.
						Reverted getCustomMetadata and getStandardMetadata functions to later revisions
						to avoid dependencies on functions in CSData v1.1.
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
Author: 	Ron West
Name:
	$getCustomMetadata
Summary:
	CFC Function wrapper around the <cfmodule> call that returns
	the custom metadata for a page
Returns:
	Struct metadata
Arguments:
	Numeric pageID
	Numeric categoryID
	Numeric templateHierarchy
	Boolean convertTaxonomyTermsToIDs
History:
	2008-09-15 - RLW - Created
	2011-01-14 - GAC - Modified - Added an option to convert Taxonomy terms to a termID list
	2011-01-18 - GAC - Modified - Removed debugging code and updated some in-line comments
	2011-01-28 - RLW - Modified - Added doctype as an optional argument to handle document metadata bindings
	2011-02-23 - DMB - Modified - Added logic to pass doctype automatically for all non-pages.
	2011-03-10 - MFC/GAC - Moved method into v1.1 for new functionality.
--->
<cffunction name="getCustomMetadata" access="public" returntype="struct">
	<cfargument name="pageID" type="numeric" required="yes">
    <cfargument name="categoryID" type="numeric" required="no" default="-1">
    <cfargument name="subsiteID" type="numeric" required="no" default="-1">
    <cfargument name="inheritedTemplateList" type="string" required="no" default="">
	<cfargument name="convertTaxonomyTermsToIDs" type="boolean" required="no" default="false">
	<cfargument name="docType" type="string" required="no" default="">
	<cfscript>
		var stdMetadata = "";
		var custMetadata = StructNew();
		var metaFormsStruct = StructNew();
		var metaFormFieldStruct = StructNew();
		var formKey = "";
		var fieldKey = "";
		var taxTermTextList = "";
		var taxTermIDList = "";
	</cfscript>
	<!--- // If we are missing categoryID, subsiteID OR inheritedTemplateList get them! --->
    <cfif arguments.categoryID eq -1 or arguments.subsiteID eq -1 or Len(inheritedTemplateList) eq 0>
    	<cfscript>
    		stdMetadata = getStandardMetadata(arguments.pageID);
    		arguments.categoryID = stdMetadata.categoryID;
    		arguments.subsiteID = stdMetadata.subsiteID;
    		arguments.inheritedTemplateList = stdMetadata.inheritedTemplateList;
    	</cfscript>
    </cfif>
	
	
	<!--- If item is not a page (e.g. metadata form bound to a pdf) get the doctype --->
	<cfquery name="getDocType" datasource="#request.site.datasource#">
		SELECT  doctype from sitepages 
                 where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageid#"> AND
				 ((doctype <> '' or doctype <> null) and (doctype <> '0'))
    </cfquery>

	<!--- pass doctype for non-pages --->
	<cfscript>
	             if ((getDocType.recordcount gt 0) and (len(getDocType.doctype)))  {
	                	arguments.doctype   = getDocType.doctype; 
	                   }
	</cfscript>
	
    <!--- // call the standard build struct module with the argument collection --->
    <cfmodule template="/commonspot/metadata/build-struct.cfm" attributecollection="#arguments#">
     <!---  <cfreturn request.metadata>  ---> 
	 <cfscript>
		// Copy the Module Struct to a local custMetaData variable
		if ( StructKeyExists(request,"metadata") )
			custMetadata = request.metadata;
		
		// Convert Taxonomy Term Lists in CustomMetadata Taxonomy Fields to a TermID lists
		if ( arguments.convertTaxonomyTermsToIDs ) {
			// Get the CustomMetaData fields that are Taxonomy Fields
			metaFormsStruct = getCustomMetadataFieldsByCSPageID(arguments.pageID,"taxonomy");
			// Loop over the formkeys (MetaData Form Names) in the struct
			for ( formKey in metaFormsStruct ) {
				metaFormFieldStruct = metaFormsStruct[formKey];
				// Loop over the fieldkeys (MetaData Feild Names) in the FormName struct
				for ( fieldKey in metaFormFieldStruct ) {
					if ( StructKeyExists(custMetadata,formKey) AND StructKeyExists(custMetadata[formKey],fieldkey) ) {
						taxTermTextList = custMetadata[formKey][fieldkey];    
						if ( LEN(TRIM(taxTermTextList)) ) {
							// Convert the List Terms to a List of TermIDs
							taxTermIDList = Application.ADF.taxonomy.getTermIDs(termList=taxTermTextList);
							// Reset The CustomMetadata to the Term ID List
							custMetadata[formKey][fieldkey] = taxTermIDList;
						} 		    
					}		    
				}			  	  
			}
		}
		return custMetadata;
	</cfscript>  
</cffunction>

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
 	2010-12-15 - RAK - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="getTextblockData" access="public" returntype="struct" hint="Given a pageID and name, get the textblock data">
	<cfargument name="name" type="string" required="true" default="" hint="Textblock Name">
	<cfargument name="pageID" type="numeric" required="true" default="-1" hint="PageID that contains the textblock">
	<cfscript>
		var textblockData = '';
		var returnData = StructNew();
	</cfscript>
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
	2011-02-09 - RAK - Var'ing un-var'd variables
	2011-02-09 - GAC - Removed self-closing CF tag slashes
--->
<cffunction name="getCustomMetadataFieldsByCSPageID" access="public" returntype="struct">
	<cfargument name="cspageid" type="numeric" required="true">
	<cfargument name="fieldtype" type="string" default="" hint="Optional - taxonomy, text, select, etc. or a CFT name">
	<cfscript>
		var itm = '';
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
													 WHERE     PageID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#inheritedPageIDList#" list="true">)
													 AND 	   VersionState = 2
													)
		<cfif LEN(TRIM(arguments.fieldtype))>
		AND FormInputControl.Type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fieldtype#">	
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

<!---
/* *************************************************************** */
Author: 	Ron West
Name:
	$getStandardMetadata
Summary:
	Return the standard metadata for a page
Returns:
	Struct metadata
Arguments:
	Numeric csPageID
History:
	2008-06-05 - RLW - Created
	2010-03-08 - RLW - Added approvalStatus to check for "Active" state
	2010-11-08 - MFC - Added PublicReleaseDate to return data
	2010-12-16 - GAC - Added Confidentiality and IncludeInIndex to return data
	2010-12-16 - GAC - Added globalKeywords to return data
	2011-02-09 - RAK - Var'ing un-var'd variables
	2011-02-23 - GAC - Added global keyword compatibility for CS5.x and CS6.x by moving the global keyword retrieval
					   to a helper method getGlobalKeywords which has CS version detection
	2011-03-10 - MFC/GAC - Moved method into v1.1 for new KEYWORD functionality.
--->
<cffunction name="getStandardMetadata" access="public" returntype="struct">
	<cfargument name="csPageID" required="true" type="numeric">
	<cfscript>
		var getData = '';
		var stdMetadata = structNew();
		var keywordsArray = ArrayNew(1);
		// build Standard Metadata return structure
		stdMetadata.name = "";
		stdMetadata.title = "";
		stdMetadata.caption = "";
		stdMetadata.description = "";
		stdMetadata.globalKeywords = "";
		stdMetadata.categoryName = "";
		stdMetadata.subsiteID = "";
		stdMetadata.templateID = "";
		stdMetadata.fileName = "";
		stdMetadata.pageID = "";
		stdMetadata.languageID = "";
		stdMetadata.language = "";
		stdMetadata.approvalStatus = "";
		stdMetadata.PublicReleaseDate = "";
		// IncludeInIndex list: ie. 1,2,4,8 |  1-include Page Index, 8-include in full text search
		stdMetadata.IncludeInIndex = "";  
		// confidentiality: 0-Unknown, 4-Confidential, 3-Highly Confidential, 5-Internal, 2-Public
		stdMetadata.confidentiality = "";
	</cfscript>
	<!--- // get the data from site pages record --->
	<cfquery name="getData" datasource="#request.site.datasource#">
		select title,
			description,
			dateAdded,
			caption,
			inheritedTemplateList,
			categoryID,
			subsiteID,
			name,
			lang,
			fileName,
			approvalStatus,
			PublicReleaseDate,
			IsPublic,
			Confidentiality
		from sitePages
		where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.csPageID#">
	</cfquery>
	<!--- // get category name
		TODO need to get the category name
	--->
	<cfscript>
		if( getData.recordCount )
		{
			stdMetadata.pageID = arguments.csPageID;
			stdMetadata.name = getData.name;
			stdMetadata.title = getData.title;
			stdMetadata.caption = getData.caption;
			stdMetadata.description = getData.description;
			// If page has a title get global Keywords (same criteria as CommonSpot )
			if ( LEN(TRIM(stdMetadata.title)) ) {
				keywordsArray = getGlobalKeywords(arguments.csPageID);
				stdMetadata.globalKeywords = ArrayToList(keywordsArray, ", ");
			}
			stdMetadata.categoryName = "";
			stdMetadata.subsiteID = getData.subsiteID;
			stdMetadata.templateID = listFirst(getData.inheritedTemplateList);
			// used primarily to retrieve custom metadata
			stdMetadata.inheritedTemplateList = getData.inheritedTemplateList;
			stdMetadata.categoryID = getData.categoryID;
			if( getData.lang eq 0 )
				stdMetadata.language = "en";
			else if ( getData.lang eq 9 )
				stdMetadata.language = "es";
			stdMetadata.fileName = getData.fileName;
			stdMetadata.languageID = getData.lang;
			stdMetadata.approvalStatus = getData.approvalStatus;
			stdMetadata.PublicReleaseDate = getData.PublicReleaseDate;
			stdMetadata.Confidentiality = getData.Confidentiality;
			if ( IsNumeric(getData.IsPublic) AND getData.IsPublic gt 0 ) 
				stdMetadata.IncludeInIndex = Application.CS.site.IsPublicGetOptions(getData.IsPublic);
		}
	</cfscript>
	<cfreturn stdMetadata>
</cffunction>

<!---
/* *************************************************************** */
Author: 	G. Cronkright
Name:
	$getGlobalKeywords
Summary:
	Returns a array of Global Keywords from a csPageID
Returns:
	Array 
Arguments:
	numeric csPageID
History:
	2011-02-23 - GAC - Created - Added to allow CommonSpot version detection for retrieving global keywords
								 This is a helper method for the getStandardMetadata
	2011-03-10 - MFC/GAC - Moved method into v1.1 for new functionality.
--->
<cffunction name="getGlobalKeywords" access="public" returntype="array" output="true" hint="Returns a array of Global Keywords from a csPageID">
	<cfargument name="csPageID" type="numeric" required="true" hint="CommonSpot Page ID">
	<cfscript>
		var keywordsArray = ArrayNew(1);
	 	var globalKeywordsList = "";
	 	var qryGlobalKeywords = QueryNew("tmp");
	 	var productVersion = ListFirst(ListLast(request.cp.productversion," "),".");
	 	var keywordObj = "";
	</cfscript>
	<cfif productVersion LT 6>
		<!--- // If CS 5.x get the Keywords directly from the DB --->
		<cfquery name="qryGlobalKeywords" datasource="#Request.Site.DataSource#">
			  SELECT Distinct Keyword
			    FROM Keywords,UserKeywords
			   WHERE Keywords.ID=UserKeywords.KeywordID
				 AND UserID=0
				 AND PageID=<cfqueryparam value="#arguments.csPageID#" cfsqltype="CF_SQL_INTEGER">
			ORDER BY Keyword
		</cfquery>
		<cfscript>
			// Get the list of global keywords from the qryGlobalKeywords query
			if ( qryGlobalKeywords.RecordCount gt 0 ) 
				globalKeywordsList = ValueList(qryGlobalKeywords.Keyword);
		</cfscript>
	<cfelse>
		<cfscript>
			// If CS 6.x or greater create the Keywords Object
			keywordObj = Server.CommonSpot.ObjectFactory.getObject("keywords");
			// Get the list of global keywords from the keywordObj
			if ( StructKeyExists(keywordObj,"getDelimitedListForObject") ) 
				globalKeywordsList = keywordObj.getDelimitedListForObject(objectID=arguments.csPageID);
		</cfscript>
	</cfif>
	<cfscript>
		// Parse the list of global keywords into an Array
		if ( LEN(TRIM(globalKeywordsList)) )
			keywordsArray = ListToArray(globalKeywordsList,',');
				
		return keywordsArray;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	R. West
Name:
	$getElementsByPageID
Summary:
	Returns an array of elements from the given pageID
Returns:
	Array elements
Arguments:
	String pageIDList
	Boolean TBandCEOnly
	Boolean onlyNamedElements
History:
	2011-03-19 - RLW - Created
--->
<cffunction name="getElementsByPageID" access="public" returnType="array" hint="Returns an array of elements from the given CS PageID">
	<cfargument name="pageIDList" type="string" required="true" hint="List of CommonSpot PageIDs">
	<cfargument name="TBandCEOnly" type="boolean" required="false" default="true" hint="Only return Custom Elements and Textblock Elements">
	<cfargument name="onlyNamedElements" type="boolean" required="false" default="true" hint="Only return elements that have a specified name">
	<cfscript>
		var elements = arrayNew(1);
		var qryGetElements = queryNew("");
	</cfscript>
	<cfquery name="qryGetElements" dataSource="#request.site.datasource#">
		select DISTINCT ci.controlID, ci.controlName, ci.controlType, ci.pageID, ac.name, ac.shortDesc, ac.longDesc
		from controlInstance ci, availableControls ac
		where ci.pageID in (<cfqueryparam CFSQLType="CF_SQL_INTEGER" list="Yes" value="#arguments.pageIDList#">)
		<cfif arguments.TBandCEOnly>
			and ( ci.controlType in (<cfqueryparam CFSQLType="CF_SQL_INTEGER" list="Yes" value="#request.constants.elementTEXTBLOCK#,#request.constants.elementTEXTBLOCK_NOHDR#">)
			or ci.controlType > <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#request.constants.elementMaxFactory#">)
		</cfif>
		<cfif arguments.onlyNamedElements>
			and ci.controlName IS NOT NULL
		</cfif>
		and ci.controlType = ac.ID
		order by controlName, controlID
	</cfquery>
	<!--- // convert the elements query to an array of structs --->
	<cfreturn variables.data.queryToArrayOfStructures(qryGetElements)>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$getCSPageByTitle
Summary:
	Returns CSPage from a specified subsite with a specified title
Returns:
	numeric
Arguments:

History:
 	2011-07-15 - RAK - Created
--->
<cffunction name="getCSPageByTitle" access="public" returntype="numeric" hint="Returns CSPage from a specified subsite with a specified title">
	<cfargument name="csPagetitle" type="string" required="true">
	<cfargument name="csSubsiteID" type="numeric" required="true">
	<cfargument name="includeRegisteredURLS" type="boolean" required="false" default="true" hint="If set to false it will not search for registered URLS">
	<cfset var csPageID = 0>
	<cfset var getPageData = ''>
	<cfquery name="getPageData" datasource="#request.site.datasource#">
		select ID, subsiteID
		from sitePages
		where title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.csPagetitle#">
		and subsiteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.csSubsiteID#">
		and (
			pageType = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.constants.pgTypeNormal#">
			<cfif includeRegisteredURLS>
				or pageType = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.constants.pgTypeRegisteredURL#">
			</cfif>
		)
	</cfquery>
	<cfif getPageData.recordCount>
		<cfset csPageID = getPageData.ID>
	</cfif>
	<cfreturn csPageID>
</cffunction>
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getUploadedDocPageURL
Summary:
	Returns the CS page url for the uploaded document.
Returns:
	String
Arguments:
	Numeric - pageID - CommonSpot Page ID
	Numeric - subsiteID - CommonSpot subsite ID for the document.
History:
	2009-10-22 - MFC - Created
	2010-02-04 - MFC - Updated to use the getUploadedDocPublicName to get the document public name
	2011-06-17 - MFC - Updated the function to build the path to loader to pass through the security module.
--->
<cffunction name="getUploadedDocPageURL" access="public" returntype="string" hint="Returns the CS page url for the uploaded document.">
	<cfargument name="pageID" type="numeric" required="true" hint="CommonSpot Page ID">
	
	<cfscript>
		// Get the subsite URL for the uploaded doc
		var docSubisteID = application.ptImport.csData.getSubsiteIDByPageID(pageid=arguments.pageID);
		// Build the doc path for the subsite security for get file
		var docGetFilePath = request.subsiteCache[docSubisteID].DLGLOADER & "?csModule=security/getfile&PageID=" & arguments.pageID;
		return docGetFilePath;
	</cfscript>
</cffunction>

</cfcomponent>