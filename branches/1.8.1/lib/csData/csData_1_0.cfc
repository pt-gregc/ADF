<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
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
	csData_1_0.cfc
Summary:
	CommonSpot Data Utils functions for the ADF Library
Version:
	1.0
History:
	2009-06-22 - MFC - Created
	2011-02-23 - GAC - Added a helper method getGlobalKeywords that is used by getStandardMetadata to handle 
					   the retrieval of Global Keywords from either CommonSpot 5.x or 6.x
	2011-03-10 - MFC/GAC - Moved getGlobalKeywords function to CSData v1.1, and moved the latest
						getCustomMetadata and getStandardMetadata functions to CSData v1.1.
						Reverted getCustomMetadata and getStandardMetadata functions to later revisions
						to avoid dependencies on functions in CSData v1.1.
	2011-09-22 - GAC - Updated and cleaned up comments 
--->
<cfcomponent displayname="csData_1_0" extends="ADF.core.Base" hint="CommonSpot Data Utils functions for the ADF Library">
	
<cfproperty name="version" value="1_0_15">
<cfproperty name="type" value="singleton">
<cfproperty name="data" type="dependency" injectedBean="data_1_0">
<cfproperty name="taxonomy" type="dependency" injectedBean="taxonomy_1_0">
<cfproperty name="wikiTitle" value="CSData_1_0">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$getPageMetadata
Summary:
	CFC Function wrapper around the <cfmodule> call that returns
	the custom metadata for a page
Returns:
	Struct metadata
Arguments:
	Numeric pageID
	Numeric categoryID
	Numeric subsiteID
	String inheritedTemplateList
History:
	2008-09-15 - RLW - Created
	2011-09-21 - RAK - Added the ability for this to detect and validate that we got valid standard metadata
--->
<cffunction name="getCustomMetadata" access="public" returntype="struct">
	<cfargument name="pageID" type="numeric" required="yes">
	<cfargument name="categoryID" type="numeric" required="no" default="-1">
	<cfargument name="subsiteID" type="numeric" required="no" default="-1">
	<cfargument name="inheritedTemplateList" type="string" required="no" default="">
	<cfset var stdMetadata = "">
	<!--- IF we are missing categoryID, subsiteID OR inheritedTemplateList get them! --->
	<cfif arguments.categoryID eq -1 or arguments.subsiteID eq -1 or Len(inheritedTemplateList) eq 0>
		<cfscript>
			stdMetadata = getStandardMetadata(arguments.pageID);
			if(structIsEmpty(stdMetadata) || !StructKeyExistS(stdMetadata,"categoryID")){
				return StructNew();
			}
			arguments.categoryID = stdMetadata.categoryID;
			arguments.subsiteID = stdMetadata.subsiteID;
			arguments.inheritedTemplateList = stdMetadata.inheritedTemplateList;
		</cfscript>
	</cfif>
	<!--- // call the standard build struct module with the argument collection --->
	<cfmodule template="/commonspot/metadata/build-struct.cfm" attributecollection="#arguments#">
	<cfreturn request.metadata>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$getCSPageURL
Summary:
	given a CS PageID build a URL to that page
Returns:
	String csPageURL
Arguments:
	Numeric pageID
History:
	2008-06-20 - RLW - Created
	2009-10-22 - MFC - Updated: Added IF block to get the uploaded doc page url.
	2013-08-23 - GAC - Update to return template URLs as well as page URLs
	2014-01-14 - JTP - Updated to use the CommonSpot ct-decipher-linkurl module call
	2014-11-03 - GAC - Added logic for backwards compatibility for expected behavior of this function
					 - Added a parameter to allow the 'broken-link-{pageid}' string to be returned instead of an empty string
	2014-11-11 - GAC - Added try/catch around ct-decipher-linkurl CS Module to log when pageID can not be converted to a URL
--->
<cffunction name="getCSPageURL" access="public" returntype="string">
	<cfargument name="pageID" type="numeric" required="true">
	<cfargument name="renderBrokenLink" type="boolean" default="false" required="false" hint="set to true to return broken-link={pageid} instead of an empty string">
	
	<cfscript>
		var csPageURL = "";
		var logMsg = "";
	</cfscript>
	
	<cfif arguments.PageID neq 0>
		<cftry>
			<CFMODULE TEMPLATE="/commonspot/utilities/ct-decipher-linkurl.cfm"
				PageID="#arguments.PageID#"
				VarName="csPageURL">
				
			<cfcatch type="any">
				<cfscript>
					// If ct-decipher-linkurl module blows up handle the exception
					csPageURL = "broken-link-#arguments.pageID#--see-logs";
					
					logMsg = "[csData_1_0.getCSPageURL] Error attempting to decipher CS PageID: #arguments.pageID# using the ct-decipher-linkurl module#Chr(10)##cfcatch.message#";
					if ( StructKeyExists(cfcatch,"detail") AND LEN(TRIM(cfcatch.detail)) )
						logMsg = logMsg & "#Chr(10)#Details: #cfcatch.detail#";
						
					server.ADF.objectFactory.getBean("utils_1_2").logAppend(logMsg);
				</cfscript>
			</cfcatch>   
		</cftry>     
		
        <!--- // Added for backwards compatiblity with how this method has always worked --->
        <!--- // -  Will return empty string if the pageID could not be found --->
    	<cfif FindNoCase("broken-link-",csPageURL) AND !arguments.renderBrokenLink>
			<cfset csPageURL = "">
		</cfif> 
    </cfif> 
	
	<cfreturn csPageURL>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	getPhotoPageURL
Summary:
	Creates the URL for the Photo Page ID
Returns:
	String
Arguments:
	Numeric pageid
History:
	2009-05-27 - MFC - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
	2015-03-03 - DJM - Updated code to set the image filename depending on the CS version
--->
<cffunction name="getImagePageURL" returntype="String" access="public">
	<cfargument name="pageid" type="numeric" required="true">
	<cfscript>
		var retURL = '';
		var sitePageMap = '';
		var csVersion = ListFirst(ListLast(request.cp.productversion," "),".");
		var requiredCSVersion = 10;
		var imgGalleryObj = '';
		var galleryDetails = '';
		var getLargestSpec = '';
		var sizeSpecifications = QueryNew('');
		var vNewFileName = '';
		var orderByClause = 'Width DESC';
	</cfscript>
	
	<cfquery name="sitePageMap" datasource="#request.site.datasource#">
		SELECT	SitePages.SubSiteID, SitePages.FileName
	<cfif csVersion GTE requiredCSVersion>
		, ImageGallery.GalleryID
	</cfif>
		FROM    SitePages INNER JOIN
		        	SubSites ON SitePages.SubSiteID = SubSites.ID
	<cfif csVersion GTE requiredCSVersion>
		INNER JOIN
					ImageGallery ON ImageGallery.PageID = SitePages.ID
	</cfif>
		WHERE	SitePages.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageid#">
	</cfquery>
	
	<cfif sitePageMap.RecordCount>
		<cfscript>
			vNewFileName = sitePageMap.FileName;
		</cfscript>
		
		<cfif csVersion GTE requiredCSVersion>
			<cfscript>
				imgGalleryObj = Server.CommonSpot.api.getObject('ImageGallery');
				galleryDetails = imgGalleryObj.getInfo(id=sitePageMap.GalleryID);			
			</cfscript>
			
			<cfif galleryDetails.SizeRestrictionType NEQ 1>
				<cfscript>
					sizeSpecifications = imgGalleryObj.getSizeList(id=sitePageMap.galleryID);
					if (galleryDetails.SizeRestrictionType EQ 4)
						orderByClause = 'Height DESC';
				</cfscript>
				
				<cfif sizeSpecifications.RecordCount>
					<cfquery name="getLargestSpec" dbtype="query">
						SELECT ID, Width, Height
						FROM SizeSpecifications
						ORDER BY #orderByClause#
					</cfquery>
					
					<cfscript>
						vNewFileName = imgGalleryObj.getImageFileName(baseFileName=sitePageMap.FileName, id=sitePageMap.GalleryID, width=getLargestSpec.Width[1], height=getLargestSpec.Height[1]);
					</cfscript>
				</cfif>
			</cfif>
		</cfif>
		
		<cfscript>
			retURL = request.subsitecache[sitePageMap.SubSiteID].imagesUrl & vNewFileName;
		</cfscript>
	</cfif>
	
	<cfscript>
		return retURL;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getSubsiteID
Summary:
	Returns the subsite id for subsite URL passed in
Returns:
	Numeric Subsite ID
Arguments:
	String Subsite URL
History:
	2008-12-22 - MFC - Created
	2010-06-03 - MFC - Updated to correct bugs
--->
<cffunction name="getSubsiteID" access="public" returntype="numeric">
	<cfargument name="subsiteURL" type="string" required="true">

	<cfset var getSubsiteIDQry = QueryNew("null")>
	<cfquery name="getSubsiteIDQry" datasource="#request.site.datasource#">
		SELECT 	ID
		FROM 	subsites
		WHERE  	SubSiteURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.subsiteURL#">
	</cfquery>
	<cfscript>
		if (getSubsiteIDQry.RecordCount)
			return getSubsiteIDQry.ID;
		else
			return 0;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Michael Carroll
Name:
	getSubsiteIDByPageID
Summary:
	Returns the Subsite ID for the Page ID.
Returns:
	Numeric Subsite ID
Arguments:
	Numeric pageid
History:
	2009-06-12 - MFC - Created
	2010-06-08 - MFC - Updated to correct bugs
--->
<cffunction name="getSubsiteIDByPageID" returntype="numeric" access="public" hint="Returns the Subsite ID for the Page ID.">
	<cfargument name="pageid" type="numeric" required="true">
	
	<cfset var sitePageMap = QueryNew("null")>
	<cfquery name="sitePageMap" datasource="#request.site.datasource#">
		SELECT	SitePages.SubSiteID
		FROM    SitePages
		WHERE	SitePages.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageid#">
	</cfquery>

	<cfscript>
		if ( sitePageMap.RecordCount )
			return sitePageMap.SubSiteID;
		else
			return 0;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$getSubsiteStruct
Summary:	
	Returns a structure with subsiteID and subsiteURL
Returns:
	Struct subsiteStruct
Arguments:
	String - filterValueList
	String - orderby
History:
	2009-05-14 - RLW - Created
	2013-02-14 - GAC - Added filter list parameter to allow subsites to be filtered out of the return struct
	2013-03-12 - GAC - Modified the filtering logic to do the work mostly in the SQL rather than a complex loop
					 - Added the ORDER BY parameter to allow the list to be sorted by id or subsiteURL
	2014-01-03 - GAC - Updated SQL 'IN' statements to use the CS module 'handle-in-list.cfm'
--->
<cffunction name="getSubsiteStruct" access="public" returntype="struct" output="false" hint="Returns a structure with subsiteID and subsiteURL">
	<cfargument name="filterValueList" type="string" required="false" default="" hint="A list of subsiteIDs OR subsiteNames to filter out of the return struct">
	<cfargument name="orderby" type="string" required="false" default="SubsiteURL" hint="Order By Column Name. Options: ID or SubsiteURL. Default: SubsiteURL">
	<cfscript>
		var getSubsites = QueryNew("tmp");
		var subsiteStruct = structNew();
		var s = "";
	</cfscript>
	<!--- // retrieve the available susbsites --->
	<cfquery name="getSubsites" datasource="#request.site.datasource#">
		SELECT ss.id, ss.subsiteURL
		FROM subsites ss, sitePages sp
		WHERE ss.securityPageID = sp.id
		<cfif LEN(TRIM(arguments.filterValueList))>
			<cfif IsNumeric(ListFirst(arguments.filterValueList))>
				AND <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="ss.ID" LIST="#arguments.filterValueList#" isNot=1>
				<!--- and ss.ID not in (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.filterValueList#" list="true">) --->
			<cfelse>
				<cfloop list="#arguments.filterValueList#" index="s">
					AND ss.subsiteURL NOT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#s#%">
				</cfloop>
			</cfif>
		</cfif>
		<cfif arguments.orderby EQ "ID">
			ORDER BY ss.id
		<cfelse>
			ORDER BY ss.subsiteURL
		</cfif>
	</cfquery>
	<cfscript>
		if ( getSubsites.recordCount )
			subsiteStruct = variables.data.queryColumnsToStruct(getSubsites, "ID", "subsiteURL");
		return subsiteStruct;	
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getCommonSpotSites
Summary:
	Returns the CommonSpot sites for the server.
Returns:
	Query CommonSpot sites on the server
Arguments:
	Numeric siteID
History:
	2009-06-05 - MFC - Created
	2011-04-08 - MFC - Updated query to return 'DataSourceName' and 'RootURL' fields.
						Added parameter for the site ID.
--->
<cffunction name="getCommonSpotSites" access="public" returntype="query" output="false" hint="Returns the CommonSpot sites for the server.">
	<cfargument name="siteID" type="numeric" required="false" default="0">
	
	<cfset var siteQuery = QueryNew("tmp")>
	<cfquery name="siteQuery" datasource="#request.serverdatasource#">
		SELECT 		SiteID, SiteName, RootPath, DataSourceName, RootURL
		FROM 		ServerSites
		WHERE		SiteState = 1
		<cfif arguments.siteID GT 0>
			AND     SiteID = <cfqueryparam value="#arguments.siteID#" cfsqltype="cf_sql_numeric">
		</cfif>
		ORDER BY	SiteName
	</cfquery>
	<cfreturn siteQuery>
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
	2011-03-10 - MFC/GAC - Removed KEYWORDS from Standard metadata due to specific to CS6.
							KEYWORDS have been fixed in CSData v1.1.
--->
<cffunction name="getStandardMetadata" access="public" returntype="struct">
	<cfargument name="csPageID" required="true" type="numeric">
	<cfscript>
		var getData = '';
		var stdMetadata = structNew();
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
				stdMetadata.IncludeInIndex = application.CS.site.IsPublicGetOptions(getData.IsPublic);
		}
	</cfscript>
	<cfreturn stdMetadata>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M Carroll
Name:
	$getPageMetadata
Summary:
	Return the standard and custom metadata for a page.
Returns:
	Struct metadata
Arguments:
	Numeric pageID
	Numeric categoryID
	Numeric subsiteID
	Numeric templateHierarchy
History:
	2009-06-22 - MFC - Created
	2011-09-21 - RAK - Added validation for when the getStandardMetadata returns bad data.
--->
<cffunction name="getPageMetadata" access="public" returntype="Struct" hint="Return the standard and custom metadata for a page.">
	<cfargument name="pageID" required="true" type="numeric">
	<cfargument name="categoryID" type="numeric" required="no">
   <cfargument name="subsiteID" type="numeric" required="no">
   <cfargument name="inheritedTemplateList" type="string" required="no" default="">
	<cfscript>
		var pageMetadata = StructNew();
		pageMetadata.standard = getStandardMetadata(arguments.pageID);
		if(StructIsEmpty(pageMetadata.standard) || !StructKeyExists(pageMetadata.standard,"categoryID")){
			pageMetadata.custom = StructNew();
		}else{
			pageMetadata.custom = getCustomMetadata(pageMetadata.standard.pageID, pageMetadata.standard.categoryID, pageMetadata.standard.subsiteID, pageMetadata.standard.inheritedTemplateList);
		}
	</cfscript>
	<cfreturn pageMetadata>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$buildPageName
Summary:
	Builds a CS safe page name
Returns:
	String csPageName
Arguments:
	String contentTitle
History:
	2008-05-30 - RLW - Created
--->
<cffunction name="buildCSPageName" access="public" returntype="string">
	<cfargument name="contentTitle" required="true" type="string">
	<cfscript>
		// first replace any "acute" symbols
		var csPageName = replaceNoCase(contentTitle, "&0acute;", "o");
		// rip out any unfriendly strings
		var regEx = "[^a-zA-Z0-9]";
		// do replacement of other bad strings
		csPageName = REReplaceNoCase(arguments.contentTitle, regEx, "-", "all");
		// replace any double "--" because CS removes one during page creation
		csPageName = ReplaceList(csPageName, "--,---,----,-----,------", "-,-,-,-,-");
	</cfscript>
	<cfreturn csPageName>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc
	Ron West
Name:
	$makeCSSafe
Summary:	
	Removes characters from a string that can cause CS to behave poorly
	Use this for building proper file names or subsite names etc...
Returns:
	String fixedString
Arguments:
	String stringToFix
	Boolean makeLowerCase [Default: false]
	Boolean addDashes [Default: true]
History:
	2009-07-01 - RLW - Created
	2010-07-29 - MFC - Implemented the makeLowerCase argument
	2014-09-09 - GAC - Added an argument to set whether or not replace spaces and other non-alpha/numeric chars with dashes
--->
<cffunction name="makeCSSafe" access="public" returntype="String" hint="">
	<cfargument name="stringToFix" type="string" required="true" hint="The string that needs to be fixed">
	<cfargument name="makeLowerCase" type="Boolean" required="false" default="false" hint="Determine whether or not the string returned should be lowercase">
	<cfargument name="addDashes" type="Boolean" required="false" default="true" hint="Determine whether or not to replace spaces and other non-alpha/numeric chars with dashes">
	<cfscript>
		var fixedString = arguments.stringToFix;
		// replace leading and trailing characters 
		fixedString = rereplace(fixedString,"^[^[:alnum:]]*", "");
		// remove trailing non-alphanumeric characters
		fixedString = rereplace(fixedString,"[^[:alnum:]]*$", "");
		// remove apofixedStringophies
		fixedString = Replace(fixedString,"'","","ALL");
		
		// replace groups of non alphanumerical with dashes
		if ( arguments.addDashes )
			fixedString = REReplace(fixedString,"[^[:alnum:]]+","-","ALL");

		// Check if we want the lowercase
		if ( arguments.makeLowerCase ) {
			// to lower case
			fixedString = LCase(fixedString);		
		}
		
		return fixedString;	
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$formatSubsiteURL
Summary:	
	Allows the subsiteURL to have a proper format
Returns:
	String formattedSubsiteURL
Arguments:
	String subsiteURL
History:
	2009-06-30 - RLW - Created
	2011-06-09 - MFC - Moved the "replace" line to the start of the function.
--->
<cffunction name="formatSubsiteURL" access="public" returntype="String" hint="Allows the subsiteURL to have a proper format">
	<cfargument name="subsiteURL" type="string" required="true" hint="The URL that needs to be formatted">
	<cfscript>
		var formattedSubsiteURL = trim(arguments.subsiteURL);
		// make sure all the slashes are forward slashes
		formattedSubsiteURL = replace(formattedSubsiteURL, "\", "/", "all");
		// make sure there is a previous slash
		if( not left(formattedSubsiteURL, 1) eq "/" )
			formattedSubsiteURL = "/" & formattedSubsiteURL;
		if( not right(formattedSubsiteURL, 1) eq "/" )
			formattedSubsiteURL = formattedSubsiteURL & "/";
	</cfscript>
	<cfreturn formattedSubsiteURL>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$getCSPageByName
Summary:
	Given a page name get the pageID
Returns:
	Numeric csPageID
Arguments:
	String csPageName
	Numeric csSubsiteID
History:
	2008-07-10 - RLW - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="getCSPageByName" access="public" returntype="numeric">
	<cfargument name="csPageName" type="string" required="true">
	<cfargument name="csSubsiteID" type="numeric" required="true">
	<cfset var csPageID = 0>
	<cfset var getPageData = ''>
	<cfquery name="getPageData" datasource="#request.site.datasource#">
		select ID, subsiteID
		from sitePages
		where name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.csPageName#">
		and subsiteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.csSubsiteID#">
	</cfquery>
	<cfif getPageData.recordCount>
		<cfset csPageID = getPageData.ID>
	</cfif>
	<cfreturn csPageID>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$findUploadFileExistsInSubsite
Summary:
	Returns T/F for if the file exists in the subsite directory
Returns:
	String T/F
Arguments:
	Numeric subsiteID
	String  file name
History:
	2008-07-25 - MFC - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="findUploadFileExistsInSubsite" returntype="string" hint="Function returns T/F is file exists in subsite upload folder">
	<cfargument name="inSubSiteID" type="numeric" required="Yes">
	<cfargument name="inFileName" type="string" required="Yes">
	<cfscript>
		var fileDLoadPath = '';
		var getSubSiteDir = '';
	</cfscript>
	<!--- // get the subsite folder path --->
	<cfquery name="getSubSiteDir" datasource="#request.site.datasource#">
		SELECT SubSiteDir
		FROM SubSites
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.inSubSiteID#">
	</cfquery>

	<cfset fileDLoadPath = getSubSiteDir.SubSiteDir & "upload/" & arguments.inFileName>

	<cfif (FileExists(fileDLoadPath))>
		<cfreturn "true"> <!--- True - File does exist in subsite --->
	<cfelse>
		<cfreturn "false"> <!--- False - File does not exist in subsite --->
	</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$copyUploadFileToSubsite
Summary:
	Copies the uploaded file from the _cs_uploads to the subsite upload folder.
Returns:
	Void
Arguments:
	Numeric Subsite ID
	Numeric File Page ID
	String FileName
History:
	2008-07-30 - MFC - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="copyUploadFileToSubsite" returntype="void" hint="Copies the uploaded file from the _cs_uploads to the subsite upload folder.">
	<cfargument name="inSubSiteID" type="numeric" required="Yes">
	<cfargument name="inFilePageID" type="numeric" required="Yes">
	<cfargument name="inFileName" type="string" required="Yes">
	<cfscript>
		var uploadedFileName = '';
		var updateUploadedDocsFileName = '';
	</cfscript> 
	<!--- Get the name for the file in the _cs_uploads folder --->
	<cfset uploadedFileName = inFilePageID & "_1" & right(inFileName,4)>
	<!--- copy the file to the subsites upload folder --->
	<cffile action = "copy" source = "#request.subsitecache[arguments.inSubSiteID].uploaddir##uploadedFileName#" destination = "#request.subsitecache[arguments.inSubSiteID].publicuploaddir##arguments.inFileName#">

	<!--- Update the PublicFileName field in the UploadedDocs table --->
	<cfquery name="updateUploadedDocsFileName" datasource="#request.site.datasource#">
		UPDATE UploadedDocs
		SET PublicFileName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.inFileName#">
		WHERE PageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.inFilePageID#">
	</cfquery>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getUploadedDocPublicName
Summary:
	Returns the public file name for the uploaded document
Returns:
	String public file name
Arguments:
	Numeric inCSPageID - CommonSpot Page ID
History:
	2008-08-19 - MFC - Created
	2010-02-04 - MFC - Updated the getDocPublicNames query to add condition "VersionState = 2"
						to return the current document
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="getUploadedDocPublicName" returntype="string" hint="Returns the public file name for the uploaded document">
	<cfargument name="inCSPageID" type="numeric" required="Yes">
	<cfscript>
		var getDocPublicNames = '';
	</cfscript>
	<!--- // get the subsite folder path --->
	<cfquery name="getDocPublicNames" datasource="#request.site.datasource#">
		SELECT 	PublicFileName
		FROM 	UploadedDocs
		WHERE 	PageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.inCSPageID#">
		AND 	VersionState = 2
	</cfquery>
	<cfif getDocPublicNames.RecordCount>
		<cfreturn getDocPublicNames.PublicFileName>
	<cfelse>
		<cfreturn "">
	</cfif>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getFullCurrentPageURL
Summary:
	Returns the full page url for the current page using CS request variables. 
Returns:
	String - Full url
Arguments:
	NA
History:
	2009-06-11 - MFC - Created
--->
<cffunction name="getFullCurrentPageURL" access="public" returntype="string" hint="Returns the full page url for the current page using CS request variables.">
	<cfscript>
		var retPageURL = Replace(request.site.url,"/#request.site.name#/","","all");
		retPageURL = retPageURL & request.subsitecache[request.subsite.id].url & request.page.filename;
	</cfscript>
	<cfreturn retPageURL>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Sam Smith
Name:
	$getCSPageByIndexTitle
Summary:
	Given a index page title get the pageID
Returns:
	Numeric csPageID
Arguments:
	String csPageTitle
History:
	2009-05-22 - SFS - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="getCSPageByIndexTitle" access="public" returntype="numeric">
	<cfargument name="csPageTitle" type="string" required="true">
	<cfset var csPageID = 0>
	<cfscript>
		var getPageData = '';
	</cfscript>
	<cfquery name="getPageData" datasource="#request.site.datasource#">
		select ID, subsiteID
		from sitePages
		where title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.csPageTitle#">
		and filename = <cfqueryparam cfsqltype="cf_sql_varchar" value="index.cfm">
	</cfquery>
	<cfif getPageData.recordCount>
		<cfset csPageID = getPageData.ID>
	</cfif>
	<cfreturn csPageID>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Sam Smith
Name:
	$getCSPageDataByURL
Summary:
	Given a page's full URL, get the page's ID and title
Returns:
	Numeric csPageID
Arguments:
	String csPageURL
History:
	2009-07-24 - SFS - Created
	2010-12-22 - GAC - VAR scoped variables for both queries
	2015-03-13 - GAC - Updated to handle CS URLs with PageID params
	2015-04-01 - GAC - Updated to test the csPageURL as a slash separated list with more than 0 items when attempting match the subsiteURL in the Subsites table 
--->
<cffunction name="getCSPageDataByURL" access="public" returntype="query" hint="Returns a query containing the page ID and page title of the page URL provided">
	<cfargument name="csPageURL" type="string" required="true">
	
	<cfscript>
		var getSubsiteID = QueryNew("ID");
		var getPageData = QueryNew("ID,Title");
		
		var csPageID = 0;
		var matchRegEx = "PAGEID=[\d]+";
		var matchArray = ArrayNew(1);
		
		if ( ArrayLen(REMatchNoCase(matchRegEx, arguments.csPageURL)) )
		{
		 	matchArray = REMatchNoCase(matchRegEx, arguments.csPageURL);
		 	csPageID = int( ReReplaceNoCase(matchArray[1],"PAGEID=","") );   	
		}
	</cfscript>
	
	<!--- // if we have the PageID... lets just query to sitepage by ID --->
	<cfif IsNumeric(csPageID) AND csPageID GT 0>
		<cfquery name="getPageData" datasource="#request.site.datasource#">
			select ID, title
			from sitePages
			where ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#csPageID#">
		</cfquery>
	<cfelseif ListLen(csPageURL,"/") GT 0>
		<cfquery name="getSubsiteID" datasource="#request.site.datasource#">
			select ID
			from SubSites
			where subsiteURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#listDeleteAt(arguments.csPageURL,Listlen(arguments.csPageURL,"/"),"/")#/">
		</cfquery>
		<cfif getSubsiteID.recordcount>
			<cfquery name="getPageData" datasource="#request.site.datasource#">
				select ID, title
				from sitePages
				where filename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(arguments.csPageURL,"/")#">
				and subsiteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#getSubsiteID.ID#">
			</cfquery>
		</cfif>
	</cfif>
	
	<cfreturn getPageData>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getUploadedFilePageID
Summary:
	Returns Page ID for the subsite id and uploaded filename.
Returns:
	Numeric PageID
Arguments:
	Numeric subsiteID
	String file name
History:
	2008-07-31 - MFC - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="getUploadedFilePageID" returntype="string" hint="Returns Page ID for the subsite id and uploaded filename.">
	<cfargument name="inSubSiteID" type="numeric" required="Yes">
	<cfargument name="inFileName" type="string" required="Yes">
	<cfscript>
		var getPageID = '';
	</cfscript>
	<!--- // get the page id for the subsite and filename --->
	<cfquery name="getPageID" datasource="#request.site.datasource#">
		SELECT  SitePages.ID, SitePages.SubSiteID, UploadedDocs.PublicFileName
		FROM    SitePages INNER JOIN UploadedDocs ON SitePages.ID = UploadedDocs.PageID
		WHERE	SitePages.SubSiteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.inSubSiteID#">
		AND 	UploadedDocs.PublicFileName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.inFileName#">
	</cfquery>
	<cfreturn getPageID.ID>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Sam Smith
Name:
	$getContactData
Summary:
	Retrieves CommonSpot user data when given a user ID.
Returns:
	Query
Arguments:
	userID the numeric ID for the user to get data for
History:
	2009-05-12 - SFS - Initial Version
	2009-05-13 - GAC - Update - Added cfqueryparam
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="getContactData" access="public" returntype="query" hint="Retrieves CommonSpot user data when given a user ID.">
	<cfargument name="userID" required="yes" type="numeric" default="" hint="the numeric ID for the user to get data for">
	<cfscript>
		var selectContactData = '';
	</cfscript>
	<cfquery name="selectContactData" datasource="#request.site.usersdatasource#" maxrows="1"><!--- USERS DATASOURCE --->
		SELECT *
		FROM contacts
		WHERE contactID = <cfqueryparam value="#userID#" cfsqltype="cf_sql_integer">
	</cfquery>
	<cfreturn selectContactData>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$getParentSubsiteFromURL
Summary:	
	Returns the parentSubsiteID given a subsiteURL
Returns:
	Numeric parentSubsiteID
Arguments:
	String subsiteURL
History:
	2009-07-01 - RLW - Created
--->
<cffunction name="getParentSubsiteFromURL" access="public" returntype="numeric" hint="Returns the parentSubsiteID given a subsiteURL">
	<cfargument name="subsiteURL" type="string" required="true" hint="The full subsiteURL from which to extract the parentSubsite from">
	<cfscript>
		var parentSubsiteURL = "";
		var thisSubsiteID = 0;
		var parentSubsiteID = 0;
		// see if this subsiteURL is a valid subsite
		thisSubsiteID = getSubsiteID(arguments.subsiteURL);
		if( thisSubsiteID gt 0 )
			parentSubsiteID = request.subsiteCache[thisSubsiteID].parentID;
		else
		{
			// remove the last part of the URL
			if( right(arguments.subsiteURL, 1) eq "/" )
				arguments.subsiteURL = left( arguments.subsiteURL, len(arguments.subsiteURL) - 1);
			// strip off the last part of the subsiteURL (leaving the parent)
			parentSubsiteURL = listDeleteAt(arguments.subsiteURL, listLen(arguments.subsiteURL, "/"), "/");
			// fix up the parentSubsiteURL (make sure there is a trailing/leading slash)
			parentSubsiteURL = formatSubsiteURL(parentSubsiteURL);
			// find the subsiteURL for the parent subsite
			parentSubsiteID = getSubsiteID(parentSubsiteURL);				
		}
	</cfscript>
	<cfreturn parentSubsiteID>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$getSiteTemplates
Summary:	
	Returns a structure with the templates available for this site
Returns:
	Struct templates
Arguments:
	String - filterValueList
	String - orderby
History:
	2009-07-30 - RLW - Created
	2013-03-12 - GAC - Added filter list parameter to allow subsites to be filtered out of the return struct
					 - Added the ORDER BY parameter to allow the struct to be sorted by title or ID
	2014-01-03 - GAC - Updated SQL 'IN' statements to use the CS module 'handle-in-list.cfm'
--->
<cffunction name="getSiteTemplates" access="public" returntype="struct" hint="Returns a structure with the templates available for this site">
	<cfargument name="filterValueList" type="string" required="false" default="" hint="A list of pageIDs or Template Names to filter out of the return struct">
	<cfargument name="orderby" type="string" required="false" default="ID" hint="Order By Column Name. Options: ID or Title. Default: ID">
	<cfscript>
		var templates = structNew();
		var getTemplates = "";
		var t = "";
	</cfscript>
	<cfquery name="getTemplates" datasource="#request.site.datasource#">
		SELECT id,title
		FROM sitePages
		WHERE pageType = 1
		<cfif LEN(TRIM(arguments.filterValueList))>
			<cfif IsNumeric(ListFirst(arguments.filterValueList))>
				AND <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="id" LIST="#arguments.filterValueList#" isNot=1>
				<!--- AND id NOT IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.filterValueList#" list="true">) --->
			<cfelse>
				<cfloop list="#arguments.filterValueList#" index="t">
				AND title NOT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#t#%">
				</cfloop>
			</cfif>
		</cfif>
		<cfif arguments.orderby EQ "title" OR arguments.orderby EQ "name">
			ORDER BY title
		<cfelse>
			ORDER BY ID
		</cfif>
	</cfquery>
	<cfscript>
		if ( getTemplates.recordCount )
			templates = variables.data.queryColumnsToStruct(getTemplates, "ID", "Title");
		return templates;	
	</cfscript>
</cffunction>
		
<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getTemplateByID
Summary:	
	Returns the query of the sites templates
Returns:
	Query Site Templates
Arguments:
	Numeric templateID
History:
	2009-08-05 - MFC - Created
--->
<cffunction name="getTemplateByID" access="public" returntype="query" hint="">
	<cfargument name="templateID" type="numeric" required="true">
	<cfset var templateQry = QueryNew("tmp")>
	<cfquery name="templateQry" datasource="#request.site.datasource#">
		SELECT 	Name, Title
		FROM 	SitePages
		WHERE 	PageType = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		AND 	ID = <cfqueryparam value="#arguments.templateID#" cfsqltype="cf_sql_integer">
	</cfquery>
	<cfreturn templateQry>
</cffunction>
	
<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Greg Cronkright
Name:
	getDefaultRenderHandler
Summary:
	Returns the Path for the Default Render Handler for an Element
Returns:
	String Default Render Handler - String
Arguments:
	String Element Name
History:
	2009-08-12 - GAC - Created
	2009-09-14 - MFC - Updated the SQL statement to work with Oracle DB.
	2009-09-23 - GAC - Set the request.subsitecache to [1]
	2011-02-09 - GAC - Removed self-closing CF tag slashes
	2015-07-25 - DMB - Modified query to work with changes in CS 9
--->
<cffunction name="getDefaultRenderHandlerPath" returntype="string" access="public" 
			hint="Returns the Path for the Default Render Handler for an Element.">
	<cfargument name="elementName" type="string" required="true">
	<cfscript>
		var isCS9Plus = (val(ListLast(ListFirst(Request.CP.ProductVersion, "."), " ")) >= 9);
		var getRenderHandler = QueryNew("temp");
		var rhpath = "";
	</cfscript>
	
	<cfif isCS9Plus>
		<cfquery name="getRenderHandler" datasource="#request.site.datasource#">
			SELECT cem.ModulePath, 1 AS IsDefault
		  		FROM   AvailableControls, CustomElementModules cem, ElementDefaults ed
		    		where ed.DisplayTemplateID = 0
		  		and AvailableControls.ID = cem.ElementType and ed.HandlerID = cem.ID
				AND LTRIM(RTRIM(AvailableControls.ShortDesc)) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#TRIM(arguments.elementName)#">
			  
		</cfquery>
	<cfelse>
		<cfquery name="getRenderHandler" datasource="#request.site.datasource#">
			SELECT CustomElementModules.ModulePath
				FROM   AvailableControls, CustomElementModules
				WHERE AvailableControls.ID = CustomElementModules.ElementType
				AND LTRIM(RTRIM(AvailableControls.ShortDesc)) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#TRIM(arguments.elementName)#">
				AND CustomElementModules.IsDefault = <cfqueryparam cfsqltype="cf_sql_bit" value="1">
		</cfquery>
	</cfif>
	
	<cfscript>
		if ( ListLen(getRenderHandler.ModulePath,"/") LTE 1 ) 
			rhpath = request.subsitecache[1].url & 'renderhandlers/' & getRenderHandler.ModulePath[1];
		else
			rhpath = getRenderHandler.ModulePath[1];
	</cfscript>
	<cfreturn rhpath>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$validateADFBeanObject
Summary:
	Search the Application spaces on the site for the for the bean object.
	Search application.ADF and all loads apps space.
Returns:
	Struct Status - Stores validated and application name space.
Arguments:
	String beanName - Bean Name object to search
History:
	2009-08-21 - MFC - Created
	2011-05-17 - RAK - Replaced evaluate with a more appropriate efficient method
--->
<cffunction name="validateADFBeanObject" access="public" returntype="struct" hint="Search the Application spaces on the site for the for the bean object.">
	<cfargument name="beanName" type="String" required="true">
	<cfscript>
		var statusStruct = StructNew();
		var appSpaceList = ListInsertAt(application.ADF.siteAppList, 1, "ADF");
		var i = 1;
		statusStruct.validated = false;
		statusStruct.nameSpace = "";
		// Loop over the list and search the App space 
		for ( i = 1; i LTE ListLen(appSpaceList); i = i + 1)
		{
			// Find the bean name in the application space
			if ( StructKeyExists(application,ListGetAt(appSpaceList,i)) && StructKeyExists( StructFind(application,ListGetAt(appSpaceList,i)), arguments.beanName) )
			{
				statusStruct.validated = true;
				statusStruct.nameSpace = ListGetAt(appSpaceList,i);
				break;
			}
		}
	</cfscript>
	<cfreturn statusStruct>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$isCSPageActive
Summary:
	Returns T/F for the active status of the page id.
Returns:
	Boolean 
Arguments:
	Numeric pageID - Page ID to verify the active/inactive status
History:
	2009-09-01 - MFC - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="isCSPageActive" access="public" returntype="boolean" hint="Returns T/F for the active status of the page id.">
	<cfargument name="pageID" type="numeric" required="true" hint="Page ID to verify the active/inactive status">
	<cfscript>
		var csPageStatus = '';
		var retStatus = false;
	</cfscript>
	<cfquery name="csPageStatus" datasource="#request.site.datasource#">
		SELECT 	approvalStatus
		FROM 	sitepages 
		WHERE 	id = <cfqueryparam value="#arguments.pageID#" cfsqltype="cf_sql_integer">
	</cfquery>
	<!--- Check the return values --->
	<cfscript>
		if ( (csPageStatus.RecordCount) AND (csPageStatus.approvalStatus EQ 0) )
			retStatus = true;
	</cfscript>
	<cfreturn retStatus>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	M. Carroll
Name:
	$getSubsiteQueryByID
Summary:	
	Returns a Query for the subsite information
Returns:
	Query Subsite Data
Arguments:
	Numeric subsiteID - Subsite ID to return the subsite info.
History:
	2009-09-01 - MFC - Created
	2011-01-05 - GAC - Modified - Added additional fields to return query results
--->
<cffunction name="getSubsiteQueryByID" access="public" returntype="query" hint="Returns a Query for the subsite information">
	<cfargument name="subsiteID" type="numeric" required="true" hint="Subsite ID to return the subsite info.">
	<cfscript>
		var getSubsites = QueryNew("tmp");
	</cfscript>
	<!--- // retrieve the susbsite info--->
	<cfquery name="getSubsites" datasource="#request.site.datasource#">
		SELECT     	SubSites.SubSiteDir, SubSites.SubSiteURL, SubSites.ParentID, SitePages.Name, SitePages.Title, SitePages.Description, 
                      SubSites.ID AS subsiteID, SubSites.Lang, SubSites.UploadDir, SubSites.UploadURL
		FROM        SitePages INNER JOIN
                      SubSites ON SitePages.ID = SubSites.SecurityPageID
		WHERE		SubSites.ID = <cfqueryparam value="#arguments.subsiteID#" cfsqltype="cf_sql_integer">
	</cfquery>
	<cfreturn getSubsites>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getDefaultRenderHandlerHTML
Summary:
	Returns the HTML for the default render handler with the passed in element name.
	
	Updates need to be added to the RH file to make this work correctly!!
Returns:
	String HTML
Arguments:
	String elementName - Custom element name
	Array dataArray - Render Handler data array
History:
	2009-09-11 - MFC - Created
	2011-02-09 - GAC - Removed self-closing CF tag slashes
--->
<cffunction name="getDefaultRenderHandlerHTML" access="public" returntype="string" hint="Returns the HTML for the default render handler with the passed in element name.">
	<cfargument name="elementName" type="string" required="true" hint="Custom element name">
	<cfargument name="dataArray" type="Array" required="true" hint="Render Handler data array">
	<cfset var retHTML = "">
	<cfset var renderHandlerPath = getDefaultRenderHandlerPath(arguments.elementName)>
	<cfset var RHDataArray = StructNew()>
	<cfif LEN(TRIM(renderHandlerPath))>
		<cfsavecontent variable="retHTML">
			<cfset RHDataArray = arguments.dataArray>
			<cfinclude template="#renderHandlerPath#">
		</cfsavecontent>
	<cfelse>
		retHTML = "<em>Can not find the Default Render Handler for this Content Type!</em>";
	</cfif>
	<cfreturn retHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$serializedFormStringToStruct
Summary:
	Returns a structure of the element fields containing the serialized form data.
Returns:
	Struct
Arguments:
	String serializedString
History:
	2009-09-15 - MFC - Created
	2009-12-06 - MFC - Updated: Check the element field is in the struct
	2010-05-13 - MFC - Updated: Added checks to prevent the field value returned to be the field FIC name.
--->
<cffunction name="serializedFormStringToStruct" access="public" returntype="struct" hint="Returns a structure of the element fields containing the serialized form data.">
	<cfargument name="serializedString" type="string" required="true" hint="">
	<cfscript>
		var retStruct = StructNew();
		var i = 1;
		var currKey = "";
		var dataObj = server.ADF.objectFactory.getBean("data_1_0");
		var dataStruct = dataObj.queryStringToStruct(arguments.serializedString);
		// Get the element fields that match the simple form
		var elementFormFields = server.ADF.objectFactory.getBean("forms_1_0").getCEFieldNameData(dataStruct.formName);
		var elementFldList = StructKeyList(elementFormFields);
		// Loop over the element fields
		for ( i = 1; i LTE ListLen(elementFldList); i = i + 1 )
		{
			// Get the FIC field from the serialized form 
			//	and insert into struct with the element field name
			currKey = ListGetAt(elementFldList, i);
			// Check the element field is in the struct
			if ( StructKeyExists(dataStruct, elementFormFields[currKey]) ){
				// Check if any dups in the field ID value
				if ( ListLen(dataStruct[elementFormFields[currKey]]) GT 1 ){
					dataStruct[elementFormFields[currKey]] = dataObj.listRemoveDuplicates(dataStruct[elementFormFields[currKey]]);
					dataStruct[elementFormFields[currKey]] = dataObj.deleteFromList(dataStruct[elementFormFields[currKey]],elementFormFields[currKey]);
				}
				
				// Check if the field name eqs the value, then set to blank
				if ( dataStruct[elementFormFields[currKey]] EQ elementFormFields[currKey] ){
					StructInsert(retStruct, currKey, "");
				}
				else{
					StructInsert(retStruct, currKey, dataStruct[elementFormFields[currKey]]);
				}
			}
		}		
	</cfscript>
	<cfreturn retStruct>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	Ron West
Name:
	$decipherCPIMAGE
Summary:	
	Returns the proper structure for an image based on the 'CPIMAGE:' text provided by CEData() calls
Returns:
	Struct resolvedURL
Arguments:
	String cpimage
History:
	2009-09-17 - RLW - Created
	2009-11-20 - RLW - clearing HTML entities from the CPIMAGE string via trick (xmlParse())
	2010-03-08 - MFC - Added logic when checking for numeric characters to exit the loop when
						find the first non-numeric character.
	2011-06-24 - RLW - Added "imageID" into the structure returned
	2011-09-06 - RAK - Removed the bulk of the logic to get the ID and replaced it with a single regular expression
	2014-11-07 - GAC - Updated to output most of the standard render mode filter data keys using the CS CMD API (cs version dependant)
	2014-12-05 - GAC - Removed duplicate 'var'd imageData' variable 
	2015-03-18 - GAC - Updated to account for private images when using the CMD API to get additional image data
--->
<cffunction name="decipherCPIMAGE" access="public" returntype="struct" hint="Returns the proper structure for an image based on the 'CPIMAGE:' text provided by CEData() calls">
	<cfargument name="cpimage" type="string" required="true" hint="The 'CPIMAGE:' text that is returned from the CEData() call">
	
	<cfscript>
		var retData = structNew();
		var imageData = structNew();
		var imageID = "";
		var imageURL = "";
		var csVersion = ListFirst(ListLast(request.cp.productversion," "),".");
		var requiredCSversion = 8;
		var imgComponent = "";
		var reqProtocol = "http://";
		var reResults = "";
		
		//Search for a string that starts with CPIMAGE: and then in the second result set return all the numbers
		reResults = reFind("^CPIMAGE:([0-9]*)",arguments.cpimage ,0,true);
		
		if ( ArrayLen(reResults.LEN) gt 1 )
		{
			//If we have more than 1 result we found the ID
			//Get the ID out of the string by getting the mid to length of the second result in the RE find.
			imageID = Mid(arguments.cpimage,reResults.pos[2],reResults.len[2]);
		}
		
		if( IsNumeric(imageID) )
		{
			imageURL = getImagePageURL(pageid=imageID);
			
			// imageID is not found in the standard render mode filter data struct 
			// - but we will add it since this method has returned it in the past
			retData.imageID = imageID; 	
			
			retData.resolvedURL = StructNew();
			retData.resolvedURL.serverRelative = imageURL;
			
			if ( cgi.https EQ "on" )
				reqProtocol = "https://";
					
			retData.resolvedURL.Absolute = reqProtocol & request.CGIVars.SERVER_NAME & imageURL;
					
			//retData.OrigHeight = "";
			//retData.OrigWidth = "";
			//retData.SubsiteID = "";
			retData.FileName = ListLast(imageURL,"/");
			//retData.AltText = "";
			//retData.OrigSize = "";
			
			//retData.errorMsg = "";
			retData.privateImage = false;
			
			// Original Image Data return Struct
			if ( csVersion GTE requiredCSversion )
			{ 
				try 
				{
					// Get Image Data using the CS CMD API image object
					imgComponent = Server.CommonSpot.api.getObject('image');
					imageData = imgComponent.getInfo(imageID=imageID);
					
					if ( !StructIsEmpty(imageData) )
					{
						retData.OrigHeight = imageData.OrigHeight;
						retData.OrigWidth = imageData.OrigWidth;
						retData.SubsiteID = imageData.SubsiteID;
						retData.FileName = imageData.FileName;
						retData.AltText = imageData.Description;
						retData.OrigSize = imageData.Size;
					
						// Other standard render mode image keys (not in the CMD API image data)
						// - ImageFound - boolean (1/0)
						// - MIMEType - string (eg. image/png) 
					}
				}
				catch ( any expt ) 
				{
					if ( StructKeyExists(expt,"message") AND LEN(TRIM(expt.message)) )
					{ 
						retData.errorMsg = expt.message;
						if ( FindNoCase("private image",expt.message) )
							retData.privateImage = true;
					}
					//WriteDump(expt, 0);
				}
			}		
		}
		return retData;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	Greg Cronkright
Name:
	getTopLevelParentSubsiteID
Summary:
	Returns the top level parent Subsite ID from child subsiteid.
Returns:
	Numeric SubsiteID
Arguments:
	Numeric childsubsiteid 
History:
	2009-09-11 - GAC - Created
--->
<cffunction name="getTopLevelParentSubsiteID" returntype="numeric" access="public" hint="Returns the Subsite ID for the Page ID.">
	<cfargument name="childsubsiteid" type="numeric" required="true">
	<cfscript>
		var subsiteparentlist = request.subsitecache[arguments.childsubsiteid].SUBSITEINHERITANCE;
		var rootpos = ListFind(subsiteparentlist,1);
		var toplevelsubsiteid = 0;
		
		if ( (ListLen(subsiteparentlist) GT 1) AND (rootpos NEQ 0) )    
			subsiteparentlist = ListDeleteAt(subsiteparentlist,rootpos);

		toplevelsubsiteid = ListLast(subsiteparentlist);
		
		return toplevelsubsiteid;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.	
	Greg Cronkright
Name:
	$CSFile
Summary:
	CFC Function wrapper around the <cfmodule> call that handles 
	cffile operations
Returns:
	Struct 
Arguments:
	String action
	String output 
	Numeric mode
	String source
	String destination
	String file
	String filefield
	String newfilename
	String nameconflict
	String directory
	String filter
	string direxists
	String addnewline
Actions:
	WRITE,APPEND,UPLOAD,COPY,MOVE,DELETE,RENAME
	COPY &  MOVE: Must supply a filename along with the path in the destination for the file to 
	replicate to other servers. Using just the Path (standard CFFILE style) will only copy 
	the file on the local server.
History:
	2009-09-30 - GAC - Created
	2010-08-12 - GAC - Modified - Cleaned up old debug code
	2011-02-09 - GAC - Removed self-closing CF tag slashes
	2011-09-22 - GAC - Moved VAR variables to to a cfscript block
--->
<cffunction name="CSFile" access="public" returntype="struct">
	<cfargument name="action" type="string" required="yes" hint="MOVE,COPY,WRITE,APPEND,UPLOAD,COPY,MOVE,DELETE,RENAME">
	<cfargument name="output" type="string" required="no" default="" hint="Content of the file to be created.">
	<cfargument name="mode" type="numeric" required="no" default="775">
	<cfargument name="source" type="string" required="no" default="">
	<cfargument name="destination" type="string" required="no" default="">
	<cfargument name="file" type="string" required="no" default="">
	<cfargument name="filefield" type="string" required="no" default="">
	<cfargument name="newfilename" type="string" required="no" default="">
	<cfargument name="nameconflict" type="string" required="no" default="Error">
	<cfargument name="directory" type="string" required="no" default="">
	<cfargument name="filter" type="string" required="no" default="">
	<cfargument name="direxists" type="string" required="no" default="1">
	<cfargument name="addnewline" type="string" required="no" default="Yes">
   	<cfscript>
		var retStruct = StructNew();
		var CFfile = "";
		var CPfile = "";
		var CFDirectory = "";
		var deletedFiles = "";
		var failedDeletions = "";
		var filesFound = "";
		var ActionSuccess = false;
	</cfscript>
	<cftry>
		<cfif Arguments.Action IS "MOVE"> <!--- // No "Move" Action in CP-CFFILE --->
			<!--- // copy file --->
			<cfset Arguments.Action = "COPY">
			<cfmodule template="/commonspot/utilities/cp-cffile.cfm"
	    			attributecollection="#arguments#">
			<!--- // delete file --->
			<cfset Arguments.Action = "DELETE">
			<cfset Arguments.file = Arguments.Source>
			<cfset Arguments.Source = "">
			<cfset Arguments.destination = "">
			<cfmodule template="/commonspot/utilities/cp-cffile.cfm"
	    			attributecollection="#arguments#">
	    	<cfset Arguments.Action = "MOVE">
		<cfelse>
			<!--- // call the standard build struct module with the argument collection --->
			<cfmodule template="/commonspot/utilities/cp-cffile.cfm"
	    		attributecollection="#arguments#">
		</cfif>
		<cfset ActionSuccess = true>
		<cfcatch>
			<cfset ActionSuccess = false>
		</cfcatch>
	</cftry>
	<cfscript>
		retStruct["Arguments"] = Arguments;
		retStruct["CFfile"] = CFfile;
		retStruct["CPfile"] = CPfile;
		retStruct["CFDirectory"] = CFDirectory;
		retStruct["Success"] = ActionSuccess;
	</cfscript>
    <cfreturn retStruct>
</cffunction>

<!---
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
	Numeric pageID - CommonSpot Page ID
	Numeric subsiteID - CommonSpot subsite ID for the document.
History:
	2009-10-22 - MFC - Created
	2010-02-04 - MFC - Updated to use the getUploadedDocPublicName to get the document public name
--->
<cffunction name="getUploadedDocPageURL" access="public" returntype="string" hint="Returns the CS page url for the uploaded document.">
	<cfargument name="pageID" type="numeric" required="true" hint="CommonSpot Page ID">
	<cfargument name="subsiteID" type="numeric" required="true" hint="CommonSpot subsite ID for the document.">

	<cfset var pageURL = "">
	<cfset var docPublicName = getUploadedDocPublicName(arguments.pageID)>
	
	<cfif LEN(docPublicName)>
		<cfset pageURL = request.subsitecache[arguments.subsiteID].uploadURL & docPublicName>
	</cfif>
	<cfreturn pageURL>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	Ron West
Name:
	$pagesContainingScript
Summary:	
	Returns the page data for the CommonSpot page(s) that have the script loaded on them
Returns:
	Array pageData
Arguments:
	String templateURL
History:
 	2009-11-30 - RLW - Created
	2010-02-24 - GAC - Updated to eliminate empty metadata arrays and duplicate pageids
--->
<cffunction name="pagesContainingScript" access="public" returntype="array" hint="">
	<cfargument name="templateURL" type="string" required="true">
	<cfscript>
		var pageDataAry = arrayNew(1);
		var getPages = queryNew('');
		var itm = 1;
		var pageMetadata = structNew();
	</cfscript>
	<cfquery name="getPages" datasource="#request.site.datasource#">
		select distinct pageID
		from data_customCF
		where moduleFileName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.templateURL#">
	</cfquery>
	<cfscript>
		if( getPages.recordCount )
		{
			for( itm; itm lte getPages.recordCount; itm=itm+1 )
			{
				pageMetadata = getStandardMetadata(getPages.pageID[itm]);
				// Added to prevent appending a Metadata array that has fields but no values
				if ( structKeyExists(pageMetadata,"pageid") AND LEN(TRIM(pageMetadata.pageid)) )
					arrayAppend(pageDataAry, pageMetadata);
			}
		}
	</cfscript>
	<cfreturn pageDataAry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$pagesContainingRH
Summary:	
	Returns the page data for the CommonSpot page(s) that have the RH loaded on them
Returns:
	Array pageData
Arguments:
	String modulePath
History:
 	2009-11-30 - RLW - Created
	2010-02-24 - GAC - Modified - Updated to eliminate empty metadata arrays and duplicate pageids
	2010-08-03 - GAC - Modified - Strip the provided path for comparison from RH files in the root RH directory
	2011-02-09 - RAK - Var'ing un-var'd variables
	2011-03-20 - SFS - Modified getModuleData to be database agnostic
	2010-06-29 - GAC - Modified - Set the getModuleData query to return multiple module IDs instead of maxrow=1 from the CustomElementModule table. 
									Then the returned Module IDs are converted to a List to be used in the WHERE statement using an IN to get all the PageIDs 
									from the data_custom_render table. This will allow the correct pageData will be returned if multiple elements  use the same render handler.
	2014-01-03 - GAC - Updated SQL 'IN' statements to use the CS module 'handle-in-list.cfm'
--->
<cffunction name="pagesContainingRH" access="public" returntype="array" hint="">
	<cfargument name="modulePath" type="string" required="true">
	<cfscript>
		var getModuleData = '';
		var pageDataAry = arrayNew(1);
		var getPages = queryNew('');
		var itm = 1;
		var pageMetadata = structNew();
		var modPath = TRIM(arguments.modulePath);
		var moduleIDlist = "";
		
		// If the passed in ModulePath is in the CS Default RH directory, strip the path info and just leave the file name
		if ( Lcase(ListFirst(modPath,"/")) IS "renderhandlers" OR FindNoCase(request.site.renderhandlerURL,modPath) ) 
			modPath = ListLast(modPath,"/");
	</cfscript>
	<!--- // retrieve the moduleID --->
	<cfquery name="getModuleData" datasource="#request.site.datasource#">
		SELECT ID
		FROM CustomElementModules
		WHERE modulePath = <cfqueryparam cfsqltype="cf_sql_varchar" value="#modPath#">
	</cfquery>
	<cfif getModuleData.recordCount>
		<cfset moduleIDlist = ValueList(getModuleData.ID)>
		<cfquery name="getPages" datasource="#request.site.datasource#">
			SELECT DISTINCT pageID
			FROM data_custom_render
			WHERE <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="moduleID" LIST="#moduleIDlist#">
			<!--- where moduleID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#moduleIDlist#" list="true">) --->
		</cfquery>
		<cfscript>
			if( getPages.recordCount )
			{
				for( itm; itm lte getPages.recordCount; itm=itm+1 )
				{
					pageMetadata = getStandardMetadata(getPages.pageID[itm]);
					// Added to prevent appending a Metadata array that has fields but no values
					if ( structKeyExists(pageMetadata,"pageid") AND LEN(TRIM(pageMetadata.pageid)) )
						arrayAppend(pageDataAry, pageMetadata);
				}
			}
		</cfscript>
	</cfif>
	<cfreturn pageDataAry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$getLanguageCounterPart
Summary:	
	Returns a metadata structure for this pages lanugage counterpart
Returns:
	Struct metadata
Arguments:
	Numeric pageID
History:
 2009-12-11 - RLW - Created
--->
<cffunction name="getLanguageCounterPart" access="public" returntype="struct" hint="Returns a metadata structure for this pages lanugage counterpart">
	<cfargument name="pageID" type="numeric" required="true">
	<cfscript>
		var pageQuery = queryNew('');
		var metadata = structNew();	
	</cfscript>
	<!--- // search for this page's counterpart --->
	<cfquery name="pageQuery" datasource="#request.site.datasource#">
		select languageSet.pageID
		from languageSet, sitePages
		where sitePages.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageID#">
		and languageSet.ID = sitePages.langSetID
		and pageID <> <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageID#">
	</cfquery>
	<cfif pageQuery.recordCount>
		<cfset metadata = getStandardMetadata(pageQuery.pageID)>
	</cfif>
	<cfreturn metadata>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$getLanguageName
Summary:	
	Given a languageID retrieve the language name
Returns:
	String langName
Arguments:
	Numeric langID
History:
 2009-12-11 - RLW - Created
--->
<cffunction name="getLanguageName" access="public" returntype="String" hint="Given a languageID retrieve the language name">
	<cfargument name="langID" type="numeric" required="true">
	<cfscript>
		var getData = '';
		var langName = "";
	</cfscript>
	<cfquery name="getData" datasource="#request.site.datasource#">
		select name
		from languages
		where ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.langID#">
	</cfquery>
	<cfif getData.recordCount>
		<cfset langName = getData.name>
	</cfif>
	<cfreturn langName>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$getDocIcon
Summary:	
	Returns the document Icon based on the MIME type
Returns:
	String iconPath
Arguments:
	String MIMEType
History:
 	2010-01-16 - RLW - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="getDocIcon" access="public" returntype="string" hint="Returns the document Icon based on the MIME type">
	<cfargument name="MIMEType" type="string" required="true" hint="The MIME type for the document">
	<cfscript>
		var getDocInfo = '';
		var iconPath = "";
	</cfscript>
	<cfquery name="getDocInfo" datasource="#request.site.datasource#">
		select iconPath
		from formats
		where MIMEType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.MIMEType#">
	</cfquery>
	<cfif getDocInfo.recordCount>
		<cfset iconPath = getDocInfo.iconPath>
	</cfif>
	<cfreturn iconPath>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$getPagesBySubsiteID
Summary:
	Retrieves a query of pages (with URL's and ID's) for a given subsite
Returns:
	Query pageQry
Arguments:
	Numeric subsiteID
	Boolean recurse
	Boolean includeDocs
	Boolean includeExternalURLs
	Boolean includeTemplates
History:
	2010-01-27 - RLW - Created
	2014-01-03 - GAC - Updated SQL 'IN' statements to use the CS module 'handle-in-list.cfm'
	2015-01-05 - GAC - Added logic to include templates in the returned results
--->
<cffunction name="getPagesBySubsiteID" access="public" returntype="array">
	<cfargument name="subsiteID" type="numeric" required="true">
    <cfargument name="recurse" type="boolean" required="false" default="false">
    <cfargument name="includeDocs" type="boolean" required="false" default="true">
    <cfargument name="includeExternalURLs" type="boolean" required="false" default="true">
	<cfargument name="includeTemplates" type="boolean" required="false" default="false">
	
    <cfscript>
    	var pageQry = queryNew("");
		var subsiteList = arguments.subsiteID;
		var pageTypeList = 0; // 0 = Pages
		var uploaded = 0;

		if( arguments.includeDocs )
			uploaded = "0,1";

		//pageTypeList = "0,3";
		if( arguments.includeExternalURLs )
			pageTypeList = ListAppend(pageTypeList,3); // 3 = External URLs	
			
		if ( arguments.includeTemplates )
			pageTypeList = ListAppend(pageTypeList,1); // 1 = Templates
			
		if( arguments.recurse and structKeyExists(request.subsiteCache, arguments.subsiteID) )
		{
			subsiteList = request.subsiteCache[arguments.subsiteID].descendantList;
			// add in the current subsite too
			subsiteList = listAppend(subsiteList, arguments.subsiteID);
		}
    </cfscript>
	
   	<cfquery name="pageQry" datasource="#request.site.datasource#">
   		SELECT 	ID, filename, title, subsiteID, uploaded, pageType, DocType
		FROM 	sitePages
		WHERE <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="subsiteID" LIST="#subsiteList#" cfsqltype="cf_sql_numeric">
		AND <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="uploaded" LIST="#uploaded#" cfsqltype="cf_sql_numeric">
		AND <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="pageType" LIST="#pageTypeList#" cfsqltype="cf_sql_numeric">
	</cfquery>
	
    <cfreturn variables.data.queryToArrayOfStructures(pageQry)>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$getPageDataArray
Summary:	
	Returns an array of a page data based on a list of pageID's
Returns:
	Array pageData
Arguments:
	String pageIDList
History:
 2010-02-18 - RLW - Created
--->
<cffunction name="getPageDataArray" access="public" returntype="array" hint="Returns an array of a page data based on a list of pageID's">
	<cfargument name="pageIDList" type="string" required="true">
	<cfscript>
		var pageData = arrayNew(1);
		var metadata = "";
		var pageID = "";
		var itm = 1;
		for( itm; itm lte listLen(arguments.pageIDList); itm=itm + 1 )
		{
			pageID = listGetAt(arguments.pageIDList, itm);
			metadata = getStandardMetadata(pageID);
			arrayAppend(pageData, metadata);
		}
	</cfscript>
	<cfreturn pageData>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$pageExists
Summary:	
	Determines whether there is a page with this title and name
Returns:
	Boolean isAPage
Arguments:
	Numeric subsiteID
	String pageTitle
	String pageName
History:
 2010-03-18 - RLW - Created
--->
<cffunction name="pageExists" access="public" returntype="Boolean">
	<cfargument name="subsiteID" type="numeric" required="true">
	<cfargument name="pageTitle" type="string" required="true">
	<cfargument name="pageName" type="string" required="true">
	<cfscript>
		var isAPage = false;
		var checkPage = "";
	</cfscript>
	<cfquery name="checkPage" datasource="#request.site.datasource#">
		select ID
		from sitePages
		where subsiteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subsiteID#">
		and title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageTitle#">
		and name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageName#">
	</cfquery>
	<cfif checkPage.recordCount><cfset isAPage = true></cfif>
	<cfreturn isAPage>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ryan Kahn
Name:
	$getPageIdsUsingTemplateID
Summary:	
	Returns an array of page ids that DIRECTLY utilize the template
Returns:
	Array pageID's
Arguments:
	Numeric templateID
	Numeric subsiteID
	Boolean includeSubsiteDescendants
History:
 	2010-10-08 - RAK - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
	2014-01-03 - GAC - Updated SQL 'IN' statements to use the CS module 'handle-in-list.cfm'
--->
<cffunction name="getPageIdsUsingTemplateID" access="public" returntype="array" hint="Returns an array of page ids that DIRECTLY utilize the template">
	<cfargument name="templateID" type="numeric" required="true">
	<cfargument name="subsiteID" type="numeric" required="false" default="-1" hint="Gets only pages that reside within this subsite that directly utilize the template">
	<cfargument name="includeSubsiteDescendants" type="boolean" required="false" default="false" hint="If true and subsiteID is selected will return pages that directly utilize the template within the subsite and its ancestors">
	<cfscript>
		var templatePages = '';
		var subsiteList = "";
		var decendants = "";
		if(arguments.subsiteID neq -1){
			subsiteList="#arguments.subsiteID#";
			if(arguments.includeSubsiteDescendants and StructKeyExists(application.subsitecache,arguments.subsiteID)){
				subsiteList = subsiteList&","&request.subsitecache[arguments.subsiteID].DESCENDANTLIST;
			}
		}
	</cfscript>
	<cfquery name="templatePages" datasource="#request.site.datasource#">
		SELECT id
		  FROM sitePages
		 WHERE InheritedTemplateList like <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.templateID#,%">
		<cfif Len(subsiteList)>
			AND <cfmodule template="/commonspot/utilities/handle-in-list.cfm" field="SubSiteID" list="#subsiteList#">
		</cfif>
	</cfquery>
	<cfreturn ListToArray(valueList(templatePages.ID))>
</cffunction>

</cfcomponent>