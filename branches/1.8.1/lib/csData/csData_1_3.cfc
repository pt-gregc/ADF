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
--->
<cfcomponent displayname="csData_1_3" extends="ADF.lib.csData.csData_1_2" hint="CommonSpot Data Utils functions for the ADF Library">

<cfproperty name="version" value="1_3_3">
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
--->
<cffunction name="getCSObjectType" returntype="string" access="public" hint="Returns the commonspot object type from a pageid">
	<cfargument name="csPageID" type="numeric" required="true" hint="a commonspot pageid">
	
	<cfscript>
		var retStr = "";
		var contentComponent = Server.CommonSpot.api.getObject('Content');
		var objInfo = StructNew();
		
		/*if ( arguments.csPageID GT 0 )	
		{
			objInfo = contentComponent.getSummary(id=arguments.csPageID);
		
			if ( StructKeyExists(objInfo,"ObjectType") )
				retStr = objInfo.ObjectType;
		}*/
	</cfscript>
	
	<cfif arguments.csPageID GT 0 >
		<cfquery name="pageQry" datasource="#request.site.datasource#">
		   SELECT pageType, doctype, Uploaded
			FROM 	sitePages
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.csPageID#">
		</cfquery>

		<!--- pagetype = 1 or 2 & DOCTYPE = 1 or "" : cs template --->
		<!--- pagetype = 0 & DOCTYPE = 0 & Uploaded = 0 : cs page  --->
		<!--- pagetype = 0 & DOCTYPE = string & Uploaded = 1 : uploaded doc  --->
		<!--- pagetype = 8 : regurl & DOCTYPE = string //  8 = External URLs	 --->
		<!--- <cfdump var="#pageQry#" expand=true> --->

		<cfscript>
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
		reData = Duplicate(retMetadata);

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

</cfcomponent>