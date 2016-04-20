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
Name:
	csData_1_3.cfc
Summary:
	CommonSpot Data Utils functions for the ADF Library
Version:
	1.3
History:
	2015-01-08 - GAC - Created - New v1.3	
	2015-01-08 - GAC - Added isTemplate function
	2015-01-09 - GAC - Added CMD API versions of the Metadata functions that return standard and custom metadata 
					   from CS Pages, Registered URLs and Uploaded Documents
	2015-01-13 - GAC - Added getCSObjectStandardMetadata
	2015-04-06 - GAC - Added getUploadedDocFileSize and getUploadedDocServerPath
	2015-04-09 - GAC - Added getCSExtURLString 
	2015-11-06 - GAC - Added the getTemplateIDByName function
--->
<cfcomponent displayname="csData_1_3" extends="ADF.lib.csData.csData_1_2" hint="CommonSpot Data Utils functions for the ADF Library">

<cfproperty name="version" value="1_3_10">
<cfproperty name="type" value="singleton">
<cfproperty name="data" type="dependency" injectedBean="data_1_2">
<cfproperty name="taxonomy" type="dependency" injectedBean="taxonomy_1_1">
<cfproperty name="wikiTitle" value="CSData_1_3">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$isTemplate
Summary:
	Given a CS pageID return if the page is a CommonSpot Template. 
Returns:
	Boolean 
Arguments:
	Numeric  csPageID
History:
	2015-01-05 - GAC - Created
	2015-01-28 - GAC - Update to use the getCSObjectType() method
--->
<cffunction name="isTemplate" access="public" returntype="boolean" hint="Given a CS pageID return if the page is a CommonSpot Template.">
	<cfargument name="csPageID" type="numeric" required="true">
	
	<cfscript>
		var isTemplate = false;
		var objType = getCSObjectType(csPageID=arguments.csPageID);
		if ( objType EQ "user template" )
			isTemplate = true;
		return isTemplate;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Greg Cronkright
Name:
	$getCSObjectMetadata
Summary:
	Gets the standard and custom metadata for a commonspot object (page,doc,url) from its pageID
Returns:
	Struct
Arguments:
	Numeric csPageID
Usage:
	application.ADF.csData.getCSObjectMetadata(csPageID)
History:
	2014-07-24 - GAC - Created
	2015-01-28 - GAC - Added Standard Metadata for Templates. 
--->
<cffunction name="getCSObjectMetadata" returntype="struct" access="public" hint="Gets the standard and custom metadata for an commonspot object (page,doc,url) from its pageID">
	<cfargument name="csPageID" type="numeric" required="true" hint="a commonspot pageid">

	<cfscript>
		var retMetadata = StructNew();
		var sMetadata = StructNew();
		var cMetadata = StructNew();
		var objType = getCSObjectType(csPageID=arguments.csPageID);
		var objLinkURL = getCSPageURL(pageid=arguments.csPageID);
		var isCSobject = false;
		
		switch(objType)
		{
			case "commonspot page": 
			case "user template":
		         sMetadata = getPageStandardMetadata(csPageID=arguments.csPageID);
		         isCSobject = true;
		         break;
		    case "uploaded document":
		         sMetadata = getUploadedDocStandardMetadata(csPageID=arguments.csPageID);
		         isCSobject = true;	
		         break;
		    case "registered URL":
		         sMetadata = getRegisteredURLStandardMetadata(csPageID=arguments.csPageID);
		         isCSobject = true;
		         break;		
		}
		
		// Get the Custom Metadata Structure for the pageID
		if ( isCSobject )
			cMetadata = getCSObjectCustomMetadata(csPageID=arguments.csPageID); 

		retMetadata["pageid"] = arguments.csPageID;
		retMetadata["objectType"] = objType;
		retMetadata["standard"] = sMetadata;
		retMetadata["custom"] = cMetadata;	
		retMetadata["linkURL"] = objLinkURL;
			
		return retMetadata;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Greg Cronkright
Name:
	$getCSObjectType
Summary:
	Returns the commonspot object type from a pageid
Returns:
	String
Arguments:
	Numeric csPageID
Usage:
	application.ADF.csData.getCSObjectType(csPageID)
History:
	2014-07-23 - GAC - Created 
	2015-03-02 - GAC - Updated to query the SitePages db directly due to CMD API limitation
	2015-04-02 - GAC - Updated to var the pageQry variable
--->
<cffunction name="getCSObjectType" returntype="string" access="public" hint="Returns the commonspot object type from a pageid">
	<cfargument name="csPageID" type="numeric" required="true" hint="a commonspot pageid">
	
	<cfscript>
		var retStr = "";
		var pageQry = QueryNew("temp");
	</cfscript>
	
	<cfif arguments.csPageID GT 0 >
		<cfquery name="pageQry" datasource="#request.site.datasource#">
		   SELECT pageType, doctype, Uploaded
			FROM 	sitePages
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.csPageID#">
		</cfquery>

		<!--- // pageType, DocType and Uploaded values // 
			pagetype = 1 or 2 & DOCTYPE = 1 or "" : cs template 
			pagetype = 0 & DOCTYPE = 0 & Uploaded = 0 : cs page 
			pagetype = 0 & DOCTYPE = string & Uploaded = 1 : uploaded doc
			pagetype = 8 : regurl & DOCTYPE = string //  8 = External URLs	 
		// --->

		<cfscript>
			if ( pageQry.RecordCount )
			{
				if ( pageQry.pageType EQ 2 AND pageQry.DOCTYPE EQ "" AND pageQry.Uploaded EQ 0 )
					retStr = "base template"; 	
				else if ( pageQry.pageType EQ 1 AND (pageQry.DOCTYPE EQ 0 OR pageQry.DOCTYPE EQ "") AND pageQry.Uploaded EQ 0 )
					retStr = "user template"; 	
				else if ( pageQry.pageType EQ 0 AND pageQry.DOCTYPE EQ 0 AND pageQry.Uploaded EQ 0)
					retStr = "commonspot page"; 
				else if ( pageQry.pageType EQ 0 AND !IsNumeric(pageQry.DOCTYPE) AND pageQry.Uploaded EQ 1 )
				  	retStr = "uploaded document"; 
				else if ( pageQry.pageType EQ 8 AND !IsNumeric(pageQry.DOCTYPE) AND pageQry.Uploaded EQ 0 )
					retStr = "registered URL";  
			} 
		</cfscript>
	</cfif>
	
	<cfreturn retStr>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Greg Cronkright
Name:
	$getCSObjectStandardMetadata
Summary:
	Gets the standard metadata for a commonspot object (page,doc,url) from its pageID
Returns:
	Struct
Arguments:
	Numeric csPageID
Usage:
	application.ADF.csData.getCSObjectStandardMetadata(csPageID)
History:
	2015-01-13 - GAC - Created
	2015-01-28 - GAC - Added Standard Metadata for Templates.
					 - Added objectType key
	2015-09-10 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 
	2015-09-23 - GAC - duplicateBean() is a CS 9.0.3 specific update ... rolling back to Duplicate()
--->
<cffunction name="getCSObjectStandardMetadata" returntype="struct" access="public" hint="Gets the standard metadata for a commonspot object (page,doc,url) from its pageID">
	<cfargument name="csPageID" type="numeric" required="true" hint="a commonspot pageid">

	<cfscript>
		var reData = StructNew();
		var retMetadata = StructNew();
		var objType = getCSObjectType(csPageID=arguments.csPageID);
		
		switch(objType)
		{
			case "commonspot page": 
			case "user template":
		         retMetadata = getPageStandardMetadata(csPageID=arguments.csPageID);
		         break;
		    case "uploaded document":
		         retMetadata = getUploadedDocStandardMetadata(csPageID=arguments.csPageID);
		         break;
		    case "registered URL":
		         retMetadata = getRegisteredURLStandardMetadata(csPageID=arguments.csPageID);
		         break;		
		}
		
		// Duplicate the LOCKED Struture and add the object type string 
		// a CS 9.0.3 specific update ... rolling back to Duplicate()
		//reData = Server.CommonSpot.UDF.util.duplicateBean(retMetadata);
		reData = duplicate(retMetadata);
		
		if ( !StructIsEmpty(reData) )
			reData["objectType"] = objType;
			
		return reData;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Greg Cronkright
Name:
	$getPageStandardMetadata
Summary:
	Returns a commonspot page's standard metadata
Returns:
	struct
Arguments:
	Numeric cspageid
Usage:
	application.ADF.csData.getPageStandardMetadata(csPageID)
History:
	2014-07-23 - GAC - Created 
--->
<cffunction name="getPageStandardMetadata" returntype="struct" access="public" hint="Returns a commonspot page's standard metadata">
	<cfargument name="csPageID" type="numeric" required="true" hint="a commonspot pageid">
	
	<cfscript>
		var retMetadata = StructNew();
		var pageComponent = Server.CommonSpot.api.getObject('Page');
		
		if ( arguments.csPageID GT 0 )	
			retMetadata = pageComponent.getInfo(pageID=arguments.csPageID);
		
		return retMetadata;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Greg Cronkright
Name:
	$getUploadedDocStandardMetadata
Summary:
	Returns a commonspot uploaded document's standard metadata
Returns:
	struct
Arguments:
	Numeric csPageID
Usage:
	application.ADF.csData.getUploadedDocStandardMetadata(csPageID)
History:
	2014-07-23 - GAC - Created 
--->
<cffunction name="getUploadedDocStandardMetadata" returntype="struct" access="public" hint="Returns a commonspot uploaded document's standard metadata">
	<cfargument name="csPageID" type="numeric" required="true" hint="a commonspot pageid">
	
	<cfscript>
		var retMetadata = StructNew();
		var docComponent = Server.CommonSpot.api.getObject('UploadedDocument');
		
		if ( arguments.csPageID GT 0 )
			retMetadata = docComponent.getInfo(uploadedDocumentID=arguments.csPageID);
			
		return retMetadata;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Greg Cronkright
Name:
	$getRegisteredURLStandardMetadata
Summary:
	Returns a commonspot registered url's standard metadata
Returns:
	struct
Arguments:
	Numeric csPageID
Usage:
	application.ADF.csData.getRegisteredURLStandardMetadata(csPageID)
History:
	2014-07-23 - GAC - Created 
--->
<cffunction name="getRegisteredURLStandardMetadata" returntype="struct" access="public" hint="Returns a commonspot registered url's standard metadata">
	<cfargument name="csPageID" type="numeric" required="true" hint="a commonspot pageid">
	
	<cfscript>
		var retMetadata = StructNew();
		var urlComponent = Server.CommonSpot.api.getObject('RegisteredURL');
		
		if ( arguments.csPageID GT 0 )
			retMetadata = urlComponent.getInfo(id=arguments.csPageID);
			
		return retMetadata; 	
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Greg Cronkright
Name:
	$getCSObjectCustomMetadata
Summary:
	Returns custom metadata for a commonspot object (page,url,doc)
Returns:
	struct
Arguments:
	Numeric csPageID
Usage:
	application.ADF.csData.getCSObjectCustomMetadata(csPageID)
History:
	2014-07-23 - GAC - Created 
--->
<cffunction name="getCSObjectCustomMetadata" returntype="struct" output="false" access="public" hint="Returns custom metadata for a commonspot object (page,url,doc)">
	<cfargument name="csPageID" type="numeric" required="true" hint="a commonspot pageid">
	
	<cfscript>
		var retMetadata = StructNew();
		var contentComponent = Server.CommonSpot.api.getObject('Content');
		
		if ( arguments.csPageID GT 0 )
			retMetadata = contentComponent.getMetadata(pageID=arguments.csPageID);

		return retMetadata;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Greg Cronkright
Name:
	$getUploadedDocServerPath
Summary:
	Returns a commonspot uploaded document actual server file path
Returns:
	string
Arguments:
	Numeric csPageID
Usage:
	application.ADF.csData.getUploadedDocServerPath(csPageID)
History:
	2015-04-02 - GAC - Created
	2016-03-04 - GAC - Updated to fix the double slash issue
--->
<cffunction name="getUploadedDocServerPath" returntype="string" access="public" hint="Returns a commonspot uploaded document actual server file path">
	<cfargument name="csPageID" type="numeric" required="true" hint="a commonspot pageid">
	
	<cfscript>
		var retStr = "";
		var pageQry = QueryNew("temp");
		var subsiteURL = "/";
		var fileName = "";
		var uploadDir  = request.subsiteCache[1].UploadDir;
		var fileServerPath = "";

		// remove trailing slash from the uploadDir
		if( Right( uploadDir,1) EQ "/" )
			uploadDir = MID(uploadDir, 1, Len(uploadDir)-1);
	</cfscript>

	<cfif arguments.csPageID GT 0 >
		<cfquery name="pageQry" datasource="#request.site.datasource#">
		   SELECT FileName, SubSiteID
			FROM  sitePages
			WHERE Uploaded = <cfqueryparam cfsqltype="cf_sql_bit" value="1">
			AND	  pageType = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND   ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.csPageID#">
			
			<!--- SELECT * 
			FROM UploadedDocs
			AND  ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.csPageID#">
			AND VersionState = <cfqueryparam cfsqltype="cf_sql_integer" value="2"> --->
		</cfquery>
	</cfif>
	
	<cfscript>
		if ( pageQry.RecordCount )
		{
			if ( IsNumeric(pageQry.SubSiteID[1]) AND pageQry.SubSiteID[1] GT 0 )
				subsiteURL = getSubsiteURLbySubsiteID(subsiteID=pageQry.SubSiteID[1]);
		
			if ( LEN(TRIM(pageQry.FileName[1])) )
				fileName = pageQry.FileName;
			
			fileServerPath = uploadDir & subsiteURL & fileName;
			
			if ( FileExists(fileServerPath) )
				retStr = fileServerPath;
		}
		return retStr;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Greg Cronkright
Name:
	$getUploadedDocFileSize
Summary:
	Returns a commonspot uploaded document file size
Returns:
	struct
Arguments:
	Numeric csPageID
Usage:
	application.ADF.csData.getUploadedDocFileSize(csPageID)
History:
	2015-04-02 - GAC - Created 
--->
<cffunction name="getUploadedDocFileSize" returntype="numeric" access="public" hint="Returns a commonspot uploaded document file size">
	<cfargument name="csPageID" type="numeric" required="true" hint="a commonspot pageid">
	
	<cfscript>
		var retVal = 0;
		var fileServerPath = getUploadedDocServerPath(csPageID=arguments.csPageID);
		var fileInfoData = StructNew();
		
		if ( LEN(TRIM(fileServerPath)) )
			fileInfoData = GetFileInfo(fileServerPath);
		
		if ( StructKeyExists(fileInfoData,"size") AND IsNumeric(fileInfoData.size) )
			retVal = fileInfoData.size;
			
		return retVal;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$getCSExtURLString
Summary:
	Returns a Commonspot Extended URL String data
Returns:
	String
Arguments:
	Numeric csPageID
Usage:
	application.ADF.csData.getCSExtURLString(csPageID)
History:
	2015-04-07 - DJM/GAC - Created 
	2015-04-29 - GAC - Added logic and error logging for the case when no valid page was found
--->
<cffunction name="getCSExtURLString" returntype="string" output="true" access="public" hint="Returns a Commonspot Extended URL String data">
	<cfargument name="csPageID" type="numeric" required="true" hint="">
	<cfargument name="logError" type="boolean" required="false" default="false" hint="">
	
	<cfscript>
		var returnString = arguments.csPageID;
		var getPageInfo = '';
		var hasError = false;
		var logMsg = "";
	</cfscript>
	
	<cfquery name="getPageInfo" DATASOURCE="#Request.Site.Datasource#">
		SELECT FileName, SubsiteID, PageType, Uploaded
		  FROM SitePages
		 WHERE ID = <cfqueryparam value="#arguments.csPageID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfscript>
		if ( getPageInfo.RecordCount )
		{
			if ( getPageInfo.PageType EQ Request.Constants.pgTypeNormal AND getPageInfo.Uploaded EQ 0 )
			 	returnString = 'CP___PAGEID=#arguments.csPageID#,#getPageInfo.FileName#,#getPageInfo.SubsiteID#';
			else if ( (getPageInfo.PageType EQ Request.Constants.pgTypeNormal AND getPageInfo.Uploaded EQ 1) OR getPageInfo.PageType EQ Request.Constants.pgTypeMultimedia OR getPageInfo.PageType EQ Request.Constants.pgTypeMultimediaPlaylist )
			 	returnString = 'CP___PAGEID=#arguments.csPageID#';
			else if ( getPageInfo.PageType EQ Request.Constants.pgTypeImage )
			 	returnString = 'CP___PAGEID=#arguments.csPageID#,#getPageInfo.FileName#';
			else // PageType as user template,pageset,registered url
			 	returnString = 'CP___PAGEID=#arguments.csPageID#,#getPageInfo.FileName#,#getPageInfo.SubsiteID#';
		}
		else
		{
			// Set the returnString to CP___PAGEID={pageid},invalid-pageid--see-logs,0 
			returnString = 'CP___PAGEID=#arguments.csPageID#,invalid-pageid--see-logs,0';	
			
			// Create Log Msg 
			if ( arguments.logError )
			{
				logMsg = "[csData_1_3.getCSExtURLString] Error attempting to build the CSExtURL string. No valid page found.";
				server.ADF.objectFactory.getBean("utils_1_2").logAppend(logMsg);	
			}
		}
	
		return returnString;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$getTemplateIDByName
Summary:
	Returns a Commonspot Extended URL String data
Returns:
	Numeric
Arguments:
	String Name
Usage:
	application.ADF.csData.getTemplateIDByName(Name)
History:
	2015-11-09 - GAC - Added 
--->
<cffunction name="getTemplateIDByName" access="public" returntype="numeric" hint="return the PageID of the template or 0 if not found">
	<cfargument name="name" required="Yes" type="string" hint="The Template Name">

	<cfscript>
		var q = QueryNew("temp");
		var templateID = 0;
	</cfscript>

	<cfquery name="q" datasource="#request.site.datasource#">
		select PageID
			from AvailableTemplates
		Where ShortDesc = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.name#">
	</cfquery>

	<cfscript>
		if ( q.recordcount eq 1 )
			templateID = q.PageID;

		return templateID;
	</cfscript>
</cffunction>

</cfcomponent>