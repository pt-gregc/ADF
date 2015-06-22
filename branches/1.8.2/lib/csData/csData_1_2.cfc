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
Name:
	csData_1_2.cfc
Summary:
	CommonSpot Data Utils functions for the ADF Library
Version:
	1.2
History:
	2012-12-07 - MFC - Created - New v1.1
	2013-01-02 - MFC - Added new functions:
						getSubsiteStructBySubsiteID
						getSubsiteURLbySubsiteID
						createUniquePageInfofromPageTitle
						createUniquePageTitle
						createUniquePageName
						getCSPageIDByTitle
	2013-02-20 - SFS - Updated the "data" dependency to data_1_2, updated all references to application.ADF.data to variables.data, updated version to 1_2_4.
	2013-07-02 - GAC - Updated the version cfproperty since updates were on 2013-05-29 but the version was not incremented
	2013-10-17 - SFS - Added new function: parse_url_el - Parses URLs passed via data sheets
	2013-10-22 - GAC - Renamed and Updated the parse_url_el to 
	2013-10-22 - GAC - Added new functions: csPageExistsByTitle,getCSPageIDlistByTitle,getCSPageQueryByTitle, getCSPageQueryByName,getCSPageIDlistByName
					 - Updated the createUniquePageTitle,getCSPageIDByTitle functions
	2014-02-24 - GAC - Added getCSFileURL function based on the old getCSPageURL function
	2014-03-16 - JTP - Added getPaddedID function
	2014-09-25 - GAC - Added getCSPageIDByURL function	
	2015-01-05 - GAC - Added isTemplate function
	2015-01-08 - GAC - Moved isTemplated to csData_1_3	
--->
<cfcomponent displayname="csData_1_2" extends="ADF.lib.csData.csData_1_1" hint="CommonSpot Data Utils functions for the ADF Library">

<cfproperty name="version" value="1_2_21">
<cfproperty name="type" value="singleton">
<cfproperty name="data" type="dependency" injectedBean="data_1_2">
<cfproperty name="taxonomy" type="dependency" injectedBean="taxonomy_1_1">
<cfproperty name="wikiTitle" value="CSData_1_2">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$getCustomMetadataFieldParamValue
Summary:
	Returns the value of a field parameter based on the Custom Metadata form name and field name
Returns:
	String 
Arguments:
	Numeric cspageid
	String fromname - Custom Metadata form name
	String fieldname - Custom Metadata field name
	String fieldparam - Custom Metadata param name
History:
	2012-02-17 - GAC - Created
	2012-02-22 - GAC - Added comments
	2012-03-19 - GAC - Removed the call to application.ADF.ceData
--->
<cffunction name="getCustomMetadataFieldParamValue" access="public" returntype="String" hint="Returns the value of a field parameter based on the Custom Metadata form name and field name">
	<cfargument name="cspageid" type="numeric" required="true" hint="commonspot pageID">
	<cfargument name="formname" type="string" required="true" hint="Custom Metadata form name">
	<cfargument name="fieldname" type="string" required="true" hint="Custom Metadata field name">
	<cfargument name="fieldparam" type="string" required="false" default="label" hint="Custom Metadata field param">
	<cfscript>
		var rtnValue = "";
		// Get the Custom Metadata field struct with params as values
		var cmDataStruct = getCustomMetadataFieldsByCSPageID(cspageid=arguments.cspageid,fieldtype="",addFieldParams=true);
		// Does the provided formname exist in the Custom Metadata field struct
		if ( StructKeyExists(cmDataStruct,arguments.formname) )
		{
			// Does the provided fieldname exist in the Custom Metadata field struct in formname struct
			if  ( StructKeyExists(cmDataStruct[arguments.formname],arguments.fieldname) )
			{
				// Does the provided field aram (default: label) exist in the Custom Metadata field struct in the form[field] struct
				if  ( StructKeyExists(cmDataStruct[arguments.formname][arguments.fieldname],arguments.fieldparam) )
				{
					// if the form[field][param] exists get the value of the param and set it as the return value
					rtnValue = cmDataStruct[arguments.formname][arguments.fieldname][arguments.fieldparam];
				}			
			}
		}
		return rtnValue;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$getCustomMetadatawithFieldLabelsKeys
Summary:
	Returns a custom metadata structure with the field name keys converted to field labels (keeping the values for each)
Returns:
	Struct 
Arguments:
	Numeric cspageid
History:
	2012-02-17 - GAC - Created
--->
<cffunction name="getCustomMetadatawithFieldLabelsKeys" access="public" returntype="Struct" hint="Returns a custom metadata structure with the field name keys converted to field labels (keeping the values for each)">
	<cfargument name="cspageid" type="numeric" required="true" hint="commonspot pageID">
	<!--- <cfargument name="customMetadata" type="struct" required="true" hint="commonspot custom meta data stucture"> --->
	<cfscript>
		var rtnStruct = StructNew();
		var cmDataStuct = getCustomMetadata(pageid=arguments.cspageid,convertTaxonomyTermsToIDs=1);
		//var cmDataStuct = arguments.customMetadata;
		var thisForm = "";
		var thisField = "";
		var paramType = "label";
		var custMetadataLabel = "";
		// Loop over the custom metadata structure that was passed in
		for ( key in cmDataStuct ) {
			// set the Key to the thisForm variable
			thisForm = key;
			// check to see if the thisForm contains stucture
			if ( IsStruct(cmDataStuct[thisForm]) )
			{
				// Create the new return struct for this form
				rtnStruct[thisForm] = StructNew();
				// loop over the field in the current form
				for (key in cmDataStuct[thisForm]) {
					// Set the Key to the thisField variable
					thisField = key;
					// Get the LABEL value for this field
					custMetadataLabel = getCustomMetadataFieldParamValue(cspageid=arguments.cspageid,formname=thisForm,fieldname=thisField,fieldparam=paramType);
					// Set the new LABEL key for the return struct for this form
					rtnStruct[thisForm][custMetadataLabel] = cmDataStuct[thisForm][thisField];
				}
			}
		}	
		return rtnStruct;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$getUserNameFromUserID
Summary:
	Returns CommonSpot username when given a numeric userID.
Returns:
	String
Arguments:
	userID the numeric ID for the user to get data for
History:
	2012-02-03 - GAC - Created
--->
<cffunction name="getUserNameFromUserID" access="public" returntype="String" hint="Returns CommonSpot username when given a numeric userID.">
	<cfargument name="userID" required="yes" type="numeric" default="" hint="the numeric ID for the user to get data for">
	<cfscript>
		var qryData = QueryNew("temp");
	</cfscript>
	<cfquery name="qryData" datasource="#request.site.usersdatasource#" maxrows="1"><!--- USERS DATASOURCE --->
		SELECT UserID AS UserName
		FROM users
		WHERE ID = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer">
	</cfquery>
	<cfreturn TRIM(qryData.UserName)>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getSubsiteStructBySubsiteID
Summary:
	Given a subsiteID return a structure that contains subsite information
Returns:
	Struct 
Arguments:
	Numeric - subsiteID
History:
	2012-03-22 - GAC - Created
	2013-07-09 - GAC - Added the Subsite Title struct Key
--->
<cffunction name="getSubsiteStructBySubsiteID" access="public" returntype="struct" hint="Given a subsiteID return a structure that contains subsite information">
	<cfargument name="subsiteID" type="numeric" required="true">
	<cfscript>
		var rtnStruct = structNew();
		var subsiteQry = getSubsiteQueryByID(arguments.subsiteID);
		if ( StructKeyExists(subsiteQry,"name") )
			rtnStruct.subsiteName = subsiteQry["name"][1];
		if ( StructKeyExists(subsiteQry,"subsiteID") )
			rtnStruct.subsiteID = subsiteQry["subsiteID"][1];
		if ( StructKeyExists(subsiteQry,"subsiteURL") )
			rtnStruct.subsiteURL = subsiteQry["subsiteURL"][1];
		if ( StructKeyExists(subsiteQry,"subsiteDir") )
			rtnStruct.subsiteDir = subsiteQry["subsiteDir"][1];
		if ( StructKeyExists(subsiteQry,"Title") )
			rtnStruct.Title = subsiteQry["Title"][1];
		return rtnStruct; 
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getSubsiteURLbySubsiteID
Summary:
	Given a subsiteID return a valid SubsiteURL
Returns:
	String 
Arguments:
	Numeric - subsiteID
History:
	2012-03-22 - GAC - Created
--->
<cffunction name="getSubsiteURLbySubsiteID" access="public" returntype="string" hint="Given a subsiteID return a valid SubsiteURL">
	<cfargument name="subsiteID" type="numeric" required="true">
	<cfscript>
		var rtnStr = "";
		var subsiteStruct = getSubsiteStructBySubsiteID(arguments.subsiteID);
		if ( StructKeyExists(subsiteStruct,"subsiteURL") )
			rtnStr = subsiteStruct["subsiteURL"];
		return rtnStr; 
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$createUniquePageInfofromPageTitle
Summary:
	Creates a unique page title, page name and file name for a page from a passed in pageTitle
Returns:
	Struct
Arguments:
	String csPageTitle
	String csPageName
	Numeric csSubsiteID
	Numeric csPageID
	Numeric pageNameWordMax
	Boolean verbose
History:
	2012-03-26 - GAC - Created 
	2013-05-29 - GAC - Updated the newUniqueNamePath to switch forward slashes to back slashes
--->
<cffunction name="createUniquePageInfofromPageTitle" access="public" returntype="struct" output="true" hint="Creates a unique page title, page name and file name for a page from a passed in pageTitle">
	<cfargument name="csPageTitle" type="string" required="true" hint="a page title to build a page name and file name from">
	<cfargument name="csPageName" type="string" required="true" hint="a page name to build a page name and file name from">
	<cfargument name="csSubsiteID" type="numeric" required="false" default="0" hint="if subsite is 0 check whole, else check only the specified subsite">
	<cfargument name="csPageID" type="numeric" required="false" default="0" hint="if a cs pageid is passed in and it matches an existing and valid cs page DO NOT create unique name">
	<cfargument name="pageTitleWordMax" type="numeric" required="false" default="10" hint="Word limit for page and file names">
	<cfargument name="verbose" type="boolean" required="false" default="false" hint="Toggle debugging dump outputs">
	<cfscript>
		var retResult = StructNew();
		var newPageTitle = arguments.csPageTitle;
		var newPageName = arguments.csPageName;
		var newFileName = "";
		var newFullFileName = "";
		var newFullFileURL = "";
		var newFullFilePath = "";
		var qSubsite = QueryNew("temp");
		var subsiteURL = "/";
		var qNewPageData = QueryNew("temp");
		var existingFullFilePath = "";
		var newUniqueNamePath = "";
				
		// Strip HTML tags
		newPageTitle = TRIM(variables.data.stripHTMLtags(str=newPageTitle,replaceStr=" "));
		if ( arguments.verbose )					
			application.ADF.utils.doDump(newPageTitle, "newPageTitle - Strip HTML tags", 1);
	
		// Convert HTML entities to text
		newPageTitle = TRIM(variables.data.unescapeHTMLentities(str=newPageTitle));
		if ( arguments.verbose )					
			application.ADF.utils.doDump(newPageTitle, "newPageTitle - Strip HTML entities", 1);

		// Shorten the newPageTitle by a set number of words ( Zero '0' would bypass this modification )
		if ( arguments.pageTitleWordMax NEQ 0 ) 	
			newPageTitle = variables.data.trimStringByWordCount(newPageTitle,arguments.pageTitleWordMax,false);
		if ( arguments.verbose )					
			application.ADF.utils.doDump(newPageTitle, "newPageTitle - Shortened", 1);		
		
		// Create a unique Page Title from the passed in csPageTitle 
		// - check the whole site if a SubsiteID is 0
		// - if a cs pageid is passed in and it matches an existing and valid cs page DO NOT create unique name 
		newPageTitle = createUniquePageTitle(csPageTitle=newPageTitle,csSubsiteID=arguments.csSubsiteID,csPageID=arguments.csPageID);
		if ( arguments.verbose )					
			application.ADF.utils.doDump(newPageTitle, "newPageTitle - Unique", 1);			
			
		// Build New PageName from the new unique PageTitle 
		newPageName = createUniquePageName(csPageName=newPageName,csSubsiteID=arguments.csSubsiteID,csPageID=arguments.csPageID);
		if ( arguments.verbose )	
			application.ADF.utils.doDump(newPageName, "newPageName", 1);		
		
		// Assign to FileName variable from the shortend PageName
		newFileName = newPageName;
		
		// Filter out any international characters
		newFileName = variables.data.filterInternationlChars(newFileName);

		// Make the File Name it CS safe (add dashes, etc.)		
		newFileName = application.ADF.csData.makeCSSafe(newFileName);	
		if ( arguments.verbose )	
			application.ADF.utils.doDump(newFileName, "newFileName", 1);
		
		newFullFileName = newFileName & ".cfm";
		if ( arguments.verbose )	
			application.ADF.utils.doDump(newFullFileName, "newFullFileName", 1);
				
		// Make the file name Unique if needed
		// - Get the subsite data from destSubsiteID 
		qSubsite = application.ADF.CSData.getSubsiteQueryByID(arguments.csSubsiteID);
		if ( arguments.verbose )
			application.ADF.utils.doDump(qSubsite, "qSubsite", 0);
		
		if ( qSubsite.RecordCount ) {
			// Get the Destination Subsite URL 
			subsiteURL = qSubsite.SUBSITEURL;
			if ( arguments.verbose )					
				application.ADF.utils.doDump(subsiteURL,"subsiteURL",1);
		}			

		// Build potential page URL to Check to see if page name is unique
		newFullFileURL = subsiteURL & newFullFileName;
		if ( arguments.verbose )
			application.ADF.utils.doDump(newFullFileURL,"newFullFileURL",1);
		
		// Check to see if file name is unique 
		// - Get the page query but the fullFileURL
		qNewPageData = application.ADF.csData.getCSPageDataByURL(newFullFileURL);
		if ( arguments.verbose )
			application.ADF.utils.doDump(qNewPageData,"qNewPageData",1);	
		
		// If pageID exists then create a new unique name
		if ( structKeyExists(qNewPageData,"ID") 
				AND LEN(TRIM(qNewPageData.ID)) 
				AND IsNumeric(qNewPageData.ID) ) {	
			// Full File Path of the existing page
			existingFullFilePath = ExpandPath(newFullFileURL);	
			
			if ( qNewPageData.ID NEQ 0 AND qNewPageData.ID NEQ arguments.csPageID ) {
				if ( arguments.verbose )				
					application.ADF.utils.doDump(existingFullFilePath,"existingFullFilePath",1);
			
				// new unique File path
				newUniqueNamePath = application.ADF.utils.createUniqueFileName(existingFullFilePath);
			}
			else {
				newUniqueNamePath = existingFullFilePath;		
			}
			
			if ( arguments.verbose )
				application.ADF.utils.doDump(newUniqueNamePath,"newUniqueNamePath",1);
		
			// Convert Slashes
			newUniqueNamePath = Replace(newUniqueNamePath,"\","/","all");
			// New Full Unique File Name (full w/ ext)
			newFullFileName = ListLast(newUniqueNamePath,"/");
			
			if ( arguments.verbose )
				application.ADF.utils.doDump(newFullFileName,"newFullFileName",1);
		
			// New Full URL with File Name
			newFullFileURL = subsiteURL & newFullFileName;
			if ( arguments.verbose )
				application.ADF.utils.doDump(newFullFileURL,"newFullFileURL",1);
				
			// New unique File Name (w/o ext)
			newFileName = ListFirst(newFullFileName,".");
			if ( arguments.verbose )	
				application.ADF.utils.doDump(newFileName,"newFileName",1);	
		}
		
		retResult["title"] = newPageTitle; 
		retResult["name"] = newPageName; 
		retResult["filename"] = newFullFileName; 
		retResult["filenameNoExt"] = newFileName; 
		retResult["url"] = newFullFileURL;
		retResult["type"] = newFullFileURL; 
		 
		return retResult;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$createUniquePageTitle
Summary:
	From given a page title check if it exists. If so, create a unique page title. 
	Can check the whole site or a specified subsite.
Returns:
	String
Arguments:
	String - csPageTitle
	Numeric - csSubsiteID
	string - csPageID
History:
	2011-05-13 - GAC - Created
	2013-10-22 - GAC - Update to better handle the case when multiple pages with the same title are found 
--->
<cffunction name="createUniquePageTitle" access="public" returntype="string" output="true" hint="From given a page title check if it exists. If so, create a unique page title. Can check the whole site or a specified subsite.">
	<cfargument name="csPageTitle" type="string" required="true">
	<cfargument name="csSubsiteID" type="numeric" required="false" default="0" hint="if subsite is 0 check whole, else check only the specified subsite">
	<cfargument name="csPageID" type="numeric" required="false" default="0" hint="if a cs pageid is passed in and it matches an existing and valid cs pageID DO NOT create unique name">
	<cfscript>
		var newTitle = TRIM(arguments.csPageTitle);
		var counter = 0;
		var pageTitleExists = true;
		var pageIDlist = "";
		// Continue to create new PageTitles if pageTitleExists is true
		while ( pageTitleExists ) {
			// increment the counter	
			counter = counter + 1; 
			// Get the list of pageIDs for the current Page Title
			pageIDlist = getCSPageIDlistByTitle(newTitle,arguments.csSubsiteID);
			// if the pageIDlist has values but contains the passed in pageid DO NOT create a unique page title
			if ( ListLen(pageIDlist) AND ListFind(pageIDlist,arguments.csPageID) EQ 0 )  {
				pageTitleExists = true; 
				newTitle = arguments.csPageTitle & "-" & counter;
			} 
			else {
				pageTitleExists = false;
			}
		}
		return newTitle; 
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCSPageIDByTitle 
Summary:
	Given a page title get the pageID. 
	
	!! IMPORTANT !!!
	This function should be used more like a CSPageExists because when csSubsiteID=0 and multiple pages are found 
	this function will only return the pageid of the first page it finds
	
	// TODO: Change the returnType so no longer returns only a single numeric value or change the function name
Returns:
	Numeric csPageID
Arguments:
	String  csPageTitle
	Numeric csSubsiteID
	Boolean includeRegisteredURLS
History:
	2010-01-27 - GAC - Created
	2011-05-13 - GAC - Added an OR to also check page title using the ToHTML function
	2013-10-22 - GAC - Updated to use getCSPageQueryByTitle query
--->
<cffunction name="getCSPageIDByTitle" access="public" returntype="numeric" output="true">
	<cfargument name="csPageTitle" type="string" required="true">
	<cfargument name="csSubsiteID" type="numeric" required="false" default="0" hint="if subsite is 0 check whole site, else check only the specified subsite">
	<cfargument name="includeRegisteredURLS" type="boolean" required="false" default="true" hint="If set to false it will not search for registered URLS">
	<cfscript>
		var csPageID = 0;
		var pageQry = getCSPageQueryByTitle(csPageTitle=arguments.csPageTitle,csSubsiteID=arguments.csSubsiteID,includeRegisteredURLS=arguments.includeRegisteredURLS);
		if ( pageQry.recordCount )
			csPageID = pageQry.ID;
		return csPageID;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$csPageExistsByTitle 
Summary:
	Given a page title get the pageID. 
Returns:
	Boolean
Arguments:
	String  csPageTitle
	Numeric csSubsiteID
	Boolean includeRegisteredURLS
History:
	2013-10-22 - GAC - Created
--->
<cffunction name="csPageExistsByTitle" access="public" returntype="boolean" output="true">
	<cfargument name="csPageTitle" type="string" required="true">
	<cfargument name="csSubsiteID" type="numeric" required="false" default="0" hint="if subsite is 0 check whole site, else check only the specified subsite">
	<cfargument name="includeRegisteredURLS" type="boolean" required="false" default="true" hint="If set to false it will not search for registered URLS">
	<cfscript>
		var pageQry = getCSPageQueryByTitle(csPageTitle=arguments.csPageTitle,csSubsiteID=arguments.csSubsiteID,includeRegisteredURLS=arguments.includeRegisteredURLS);
		if ( pageQry.recordCount )
			return true;
		else
			return false;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCSPageIDlistByTitle
Summary:
	Given a page title get the a list of matching pageIDs
Returns:
	String csPageIDlist
Arguments:
	String - csPageTitle
	String - csSubsiteID
	Boolean -  csSubsiteID
History:
	2013-10-22 - GAC - Created
--->
<cffunction name="getCSPageIDlistByTitle" access="public" returntype="string" output="false">
	<cfargument name="csPageTitle" type="string" required="true">
	<cfargument name="csSubsiteID" type="string" required="false">
	<cfargument name="includeRegisteredURLS" type="boolean" required="false" default="true" hint="If set to false it will not search for registered URLS">
	<cfscript>
		var csPageIDlist = "";
	    var pageQry = getCSPageQueryByTitle(csPageTitle=arguments.csPageTitle,csSubsiteID=arguments.csSubsiteID,includeRegisteredURLS=arguments.includeRegisteredURLS);
	    if ( pageQry.recordCount ) 
	    	csPageIDlist = ValueList(pageQry.ID);
	    return csPageIDlist;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCSPageQueryByTitle
Summary:
	Given a page title get all of the cspages as a query
Returns:
	query 
Arguments:
	String  csPageTitle
	Numeric csSubsiteID
	Boolean includeRegisteredURLS
History:
	2013-10-22 - GAC - Created
	2015-06-17 - GAC - Switched data.ToHTML and data.FromHTML calls to use Server.CommonSpot.UDF instead of deprecated Application.CS
--->
<cffunction name="getCSPageQueryByTitle" access="public" returntype="query" output="false">
	<cfargument name="csPageTitle" type="string" required="true">
	<cfargument name="csSubsiteID" type="numeric" required="false" default="0" hint="if subsite is 0 check whole, else check only the specified subsite">
	<cfargument name="includeRegisteredURLS" type="boolean" required="false" default="true" hint="If set to false it will not search for registered URLS">
	<cfset var pageQry = QueryNew('temp')>
	<cfquery name="pageQry" datasource="#request.site.datasource#">
		select  ID, subsiteid, name, Title, FileName
		  from  sitePages
		 where  ( title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.csPageTitle#">
				  or  title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Server.CommonSpot.UDF.data.ToHTML(arguments.csPageTitle)#"> )
		<cfif IsNumeric(arguments.csSubsiteID) AND arguments.csSubsiteID GT 0>
		   and  subsiteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.csSubsiteID#">
		</cfif>
		   and (
				pageType = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.constants.pgTypeNormal#">
				<cfif includeRegisteredURLS>
					or pageType = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.constants.pgTypeRegisteredURL#">
				</cfif>
			)
	</cfquery>
	<cfreturn pageQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$createUniquePageName
Summary:
	From given a page title check if it exists. If so, create a unique page title. 
	Can check the whole site or a specified subsite.
Returns:
	String
Arguments:
	String - csPageName
	Numeric - csSubsiteID
	string - csPageID
History:
	2012-06-10 - GAC - Created
--->
<cffunction name="createUniquePageName" access="public" returntype="string" output="true" hint="From given a page title check if it exists. If so, create a unique page title. Can check the whole site or a specified subsite.">
	<cfargument name="csPageName" type="string" required="true">
	<cfargument name="csSubsiteID" type="numeric" required="false" default="0" hint="if subsite is 0 check whole, else check only the specified subsite">
	<cfargument name="csPageID" type="numeric" required="false" default="0" hint="if a cs pageid is passed in and it matches an existing and valid cs pageID DO NOT create unique name">
	<cfscript>
		var cleanedPageName = buildCSPageName(TRIM(LCASE(arguments.csPageName)));
		var newName = cleanedPageName;
		var counter = 0;
		var pageNameExists = true;
		var pageIDlist = "";
		// Continue to create new PageName if pageNameExists is true
		while ( pageNameExists ) {
			// increment the counter	
			counter = counter + 1; 
			// Get the list of pageIDs for the current Page name
			pageIDlist = getCSPageIDlistByName(newName,arguments.csSubsiteID);
			// if the pageIDlist has values but contains the passed in pageid DO NOT create a unique page name
			if ( ListLen(pageIDlist) AND ListFind(pageIDlist,arguments.csPageID) EQ 0 )  {
				pageNameExists = true; 
				newName = cleanedPageName & "-" & counter;
			} 
			else {
				pageNameExists = false;
			}
		}
		return newName; 
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCSPageIDlistByName
Summary:
	Given a page name get the a list of matching pageIDs
Returns:
	String csPageIDlist
Arguments:
	String - csPageName
	String - csSubsiteID
	Boolean -  csSubsiteID
History:
	2013-10-22 - GAC - Created
--->
<cffunction name="getCSPageIDlistByName" access="public" returntype="string" output="false">
	<cfargument name="csPageName" type="string" required="true">
	<cfargument name="csSubsiteID" type="string" required="false">
	<cfargument name="includeRegisteredURLS" type="boolean" required="false" default="true" hint="If set to false it will not search for registered URLS">
	<cfscript>
		var csPageIDlist = "";
	    var pageQry = getCSPageQueryByName(csPageName=arguments.csPageName,csSubsiteID=arguments.csSubsiteID,includeRegisteredURLS=arguments.includeRegisteredURLS);
	    if ( pageQry.recordCount ) 
	    	csPageIDlist = ValueList(pageQry.ID);
	    return csPageIDlist;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$csPageExistsByTitle 
Summary:
	Check if a page name exists 
Returns:
	Boolean
Arguments:
	String  csPageName
	Numeric csSubsiteID
	Boolean includeRegisteredURLS
History:
	2013-10-22 - GAC - Created
--->
<cffunction name="csPageExistsByName" access="public" returntype="boolean" output="true" hint="Check if a page name exists ">
	<cfargument name="csPageName" type="string" required="true">
	<cfargument name="csSubsiteID" type="numeric" required="false" default="0" hint="if subsite is 0 check whole site, else check only the specified subsite">
	<cfargument name="includeRegisteredURLS" type="boolean" required="false" default="true" hint="If set to false it will not search for registered URLS">
	<cfscript>
		var pageQry = getCSPageQueryByName(csPageName=arguments.csPageName,csSubsiteID=arguments.csSubsiteID,includeRegisteredURLS=arguments.includeRegisteredURLS);
		if ( pageQry.recordCount )
			return true;
		else
			return false;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCSPageQueryByName
Summary:
	Given a page name get all of the cspages as a query
Returns:
	query 
Arguments:
	String  csPageName
	Numeric csSubsiteID
	Boolean includeRegisteredURLS
History:
	2013-10-22 - GAC - Created
	2015-06-17 - GAC - Switched data.ToHTML and data.FromHTML calls to use Server.CommonSpot.UDF instead of deprecated Application.CS
--->
<cffunction name="getCSPageQueryByName" access="public" returntype="query" output="false">
	<cfargument name="csPageName" type="string" required="true">
	<cfargument name="csSubsiteID" type="numeric" required="false" default="0" hint="if subsite is 0 check whole, else check only the specified subsite">
	<cfargument name="includeRegisteredURLS" type="boolean" required="false" default="true" hint="If set to false it will not search for registered URLS">
	<cfset var pageQry = QueryNew('temp')>
	<cfquery name="pageQry" datasource="#request.site.datasource#">
		select  ID, subsiteid, name, Title, FileName
		  from  sitePages
		 where  ( name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.csPageName#">
				  or  name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Server.CommonSpot.UDF.data.ToHTML(arguments.csPageName)#"> )
		<cfif IsNumeric(arguments.csSubsiteID) AND arguments.csSubsiteID GT 0>
		   and  subsiteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.csSubsiteID#">
		</cfif>
		   and (
				pageType = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.constants.pgTypeNormal#">
				<cfif includeRegisteredURLS>
					or pageType = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.constants.pgTypeRegisteredURL#">
				</cfif>
			)
	</cfquery>
	<cfreturn pageQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$metadataStructToArray
Summary:
	Converts the Metadata structure to an array of MetadataValue structures:
	The sub-structure has the following keys:
		FieldName = The name of the field in the metadata form.
		FormName = The name of the metadata form.
		Value = The value of the metadata field.
Returns:
	Array
Arguments:
	Struct - metadata
History:
	2013-02-11 - MFC - Created
--->
<cffunction name="metadataStructToArray" access="public" returntype="array" output="true">
	<cfargument name="metadata" type="struct" required="true">
	<cfscript>
		var metadataArray = ArrayNew(1);
		var currFormName = "";
		var currFormKeyList = "";
		var currFieldName = "";
		var tempStruct = structNew();
		var i=1;
		var j=1;
		
		// Loop over the struct
		var metadataKeyList = StructKeylist(arguments.metadata);
		for ( i=1; i LTE ListLen(metadataKeyList); i++ ){
			currFormName = ListGetAt(metadataKeyList, i);
			currFormKeyList = StructKeylist(arguments.metadata[currFormName]);
			// Loop over the fields in the form
			for ( j=1; j LTE ListLen(currFormKeyList); j++ ){
				currFieldName = ListGetAt(currFormKeyList, j);
				tempStruct = structNew();
				tempStruct['FormName'] = currFormName;
				tempStruct['FieldName'] = currFieldName;
				tempStruct['Value'] = arguments.metadata[currFormName][currFieldName];
				// Add the struct back into the array
				ArrayAppend(metadataArray, tempStruct);
			}
		}
		
		return metadataArray;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	Henry Ivry, Monaco Lange
	Added to the ADF by Samuel Smith, PaperThin
Name:
	$parseCSURL
Summary:
	Converts a CommonSpot URL that contain a pageID url parameter to a standard URL
Returns:
	String full_url
Arguments:
	String str
History:
	2013-03-06 - HI  - Created
	2013-10-17 - SFS - Added
	2013-10-21 - GAC - Renamed the function 
					 - Var'ing un-var'd variables
					 - Fixed the function to be backward compatible with ACF8
	2014-01-14 - JTP - Updated to use the CommonSpot ct-decipher-linkurl module call
	2014-11-11 - GAC - Added try/catch around ct-decipher-linkurl the CS Modules to log when the passed in value could not be converted to a URL				 
--->
<cffunction name="parseCSURL" access="public" returntype="string" output="false" displayname="parseDatasheetURL" hint="Converts a CommonSpot URL that contain a pageID url parameter to a standard URL">
    <cfargument name="str" type="string" required="true" hint="Provide a string value that is a CommonSpot URL that contains a pageid key/value pair">

	<cfscript>
          var targetURL = '';
          var matchArray = REMatchNoCase("PAGEID=[\d]+", arguments.str);
          var PageID = 0;
          var errorStr = "";
		  var logMsg = "";
		  
          // If str is a pageID use it
          if ( isNumeric(str) )
              PageID = int(str);
          // Check to see if the string contains a 'PAGEID='
          else if ( arrayLen(matchArray) GT 0 )
              pageID = int( ReReplaceNoCase(matchArray[1],"PAGEID=","") );         
     </cfscript>  

	<cftry>  
	     <cfif PageID neq 0>
	          <CFMODULE TEMPLATE="/commonspot/utilities/ct-decipher-linkurl.cfm"
		          PageID="#PageID#"
		          VarName="targetURL">
		         
	     <cfelse>     
	          <CFMODULE TEMPLATE="/commonspot/utilities/ct-decipher-linkurl.cfm"
		          URL="#arguments.str#"
		          VarName="targetURL">
	     </cfif>
	    
	    <!--- // If ct-decipher-linkurl module blows up handle the exception --->   
 		<cfcatch type="any">
			<cfscript>
				// Set the targetURL to the broken-link-{pageid} text
				targetURL = "broken-link-#PageID#--see-logs";
				
				if ( PageID neq 0 )
					errorStr = "CS Page ID: #pageID#";
				else
					errorStr = "URL: #arguments.str#";
				
				// Create Log Msg 
				logMsg = "[csData_1_2.parseCSURL] Error attempting to decipher #errorStr# using the ct-decipher-linkurl module#Chr(10)##cfcatch.message#";
				if ( StructKeyExists(cfcatch,"detail") AND LEN(TRIM(cfcatch.detail)) )
						logMsg = logMsg & "#Chr(10)#Details: #cfcatch.detail#";	
				server.ADF.objectFactory.getBean("utils_1_2").logAppend(logMsg);
			</cfscript>
		</cfcatch>   
	</cftry>  
		
     <cfreturn targetURL>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$decipherCPPAGEID
Summary:	
	Returns a URL string based on the 'CP___PAGEID=' text provided by CEData() calls
Returns:
	String strURL
Arguments:
	String CP___PAGEID
	Example argument: var containing "CP___PAGEID=48083,index.cfm,646" 
History:
	2013-10-02 - DMB - Created
	2014-11-11 - GAC - Removed the reference to application.ADF.csdata... since we are in csdata
	2015-04-28 - GAC - Updated to use parseCSURL() 
--->
<cffunction name="decipherCPPAGEID" access="public" returntype="string" output="true">
	<cfargument name="cpPageID" type="string" required="true">
	<cfscript>
		var strPageID = "";
		var strURL = "";

		if (arguments.cpPageID contains "CP___PAGEID=") 
		{
			strPageID = replacenocase(arguments.cpPageID,"CP___PAGEID=","");
			strPageID = listFirst(strPageID,",");
			// Get the url for this PageID
			strURL = parseCSURL(str=strPageID);
		}
		return strURL;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$getCSFileURL
Summary:
	given a CS PageID build a URL to that page
	
	NOTE: If you want the CSPageURL use getCSPageURL() or parseCSURL().
	      This method will also return the loader.cfm secure file string for documents.
Returns:
	String csFileURL
Arguments:
	Numeric pageID
History:
	2008-06-20 - RLW - Created
	2009-10-22 - MFC - Updated: Added IF block to get the uploaded doc page url.
	2013-08-23 - GAC - Update to return template URLs as well as page URLs.
	2014-02-24 - GAC - Moved and renamed based on what this function actually returns.
--->
<cffunction name="getCSFileURL" access="public" returntype="string">
	<cfargument name="pageID" type="numeric" required="true">
	<cfscript>
		var csFileURL = "";
		var getPageData = queryNew("test");
	</cfscript>
	<cfquery name="getPageData" datasource="#request.site.datasource#">
		SELECT 	fileName, subsiteID, PageType, DocType 
		FROM 	sitePages
		WHERE 	ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageID#">
	</cfquery>
	<cfif getPageData.recordCount>
		<!--- // Check the doctype AND pagetype --->
		<cfif (getPageData.DocType EQ 0  OR getPageData.DocType EQ "") AND ListFind("0,1,2",getPageData.PageType)>
			<!--- We are working with a CS page --->
			<cfset csFileURL = request.subsiteCache[getPageData.subsiteID].url & getPageData.fileName>
		<cfelse>
			<!--- We are working with an uploaded file --->
			<cfset csFileURL = getUploadedDocPageURL(arguments.pageID, getPageData.subsiteID)>
		</cfif>
	</cfif>
	<cfreturn csFileURL>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getPaddedID
Summary:
	Builds a CommonSpot uniqueID string which is Zero (0) padded for textbased sorting
Returns:
	string
Arguments:
	String - padSize (number of chars of padding)
History:
	2013-12-31 - JTP - Created
	2014-07-25 - GAC - Added a parameter to set custom pad sizes (default: 9)
--->
<cffunction name="getPaddedID" access="public" returntype="string" hint="Builds a CommonSpot uniqueID string which is Zero (0) padded for textbased sorting">
	<cfargument name="padSize" type="numeric" required="false" default="9" hint="Size of padded string">
	
	<cfscript>
		var padMaskStr = "";
		// Get a safe pad size
		if ( IsNumeric(arguments.padsize) )
		{
			if ( arguments.padsize GTE 2 )
				arguments.padsize = arguments.padsize - 1;
			else
				arguments.padsize = 1;
		}	
		// Build the string for the padding mask 		
		padMaskStr = RepeatString("0",arguments.padsize) & 9;
		// Pad the Unique ID
		return NumberFormat( Request.Site.IDMaster.getID(), padMaskStr );
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCSPageIDByURL
Summary:
	Given a page URL get the pageID. 
Returns:
	Numeric csPageID
Arguments:
	String  csPageURL
History:
	2014-09-25 - GAC - Created
--->
<cffunction name="getCSPageIDByURL" access="public" returntype="numeric" output="false">
	<cfargument name="csPageURL" type="string" required="true">
	<cfscript>
		var csPageID = 0;
		var pageQry = getCSPageDataByURL(csPageURL=arguments.csPageURL);
		
		if ( pageQry.recordCount )
			csPageID = pageQry.ID;	
	
		return csPageID;
	</cfscript>
</cffunction>	

</cfcomponent>