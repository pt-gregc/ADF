<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2012.
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
	apiPage.cfc
Summary:
	API Page functions for the ADF Library
Version:
	1.0
History:
	2012-12-26 - MFC - Created
--->
<cfcomponent displayname="apiPage" extends="ADF.core.Base" hint="API Page functions for the ADF Library">

<cfproperty name="version" value="1_0_1">
<cfproperty name="api" type="dependency" injectedBean="api_1_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">
<cfproperty name="wikiTitle" value="API Page">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$delete
Summary:
	Deletes a commonspot page using the public command API
	http://{servername}/commonspot/help/api_help/Content/Components/Page/delete.html
Returns:
	Struct
Arguments:
	Numeric csPageID			
History:
	2012-10-25 - MFC/GAC - Created
--->
<cffunction name="delete" access="public" returntype="struct" hint="Adds a keywords to an object. If a keyword does not exit, CommonSpot creates and adds it.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	<cfscript>
		var pageCmdResult = StructNew();
		// Use the CS 6.x Command API to SET page keywords
		var pageComponent = Server.CommonSpot.api.getObject('page');
		try {
			pageComponent.delete(arguments.csPageID,0);
			pageCmdResult["CMDSTATUS"] = true;
			pageCmdResult["CMDRESULTS"] = true;
		} 
		catch (any e) {
			pageCmdResult["CMDSTATUS"] = false;
			if ( StructKeyExists(e,"Reason") AND StructKeyExists(e['Reason'],"pageID") ) 
				pageCmdResult["CMDRESULTS"] = e['Reason']['pageID']; 
			else if ( StructKeyExists(e,"message") )
				pageCmdResult["CMDRESULTS"] = e.message;
			else
				pageCmdResult["CMDRESULTS"] = e;
		}
		return pageCmdResult;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getInfo
Summary:
	Returns array containing page properties (standard and custom) based on a page id.
	http://{servername}/commonspot/help/api_help/content/components/page/getinfo.html
Returns:
	struct - CS API Return Struct
		 CMDSTATUS
		 CMDRESULTS 
Arguments:
	Numeric csPageID
History:
	2012-10-22 - MFC/GAC - Created
--->
<cffunction name="getInfo" access="public" returntype="struct" hint="Returns array containing page properties (standard and custom) based on a page id.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	<cfscript>
       var pageResult = StructNew();
       // Use the CS 6.x Command API to RENAME the page
       var pageComponent = Server.CommonSpot.api.getObject('Page');
       var pageCmdResults = StructNew();

       try {
           pageCmdResults = pageComponent.getInfo(pageID=arguments.csPageID);
           //doErrorLogging("getCommonspotPageInfo","pageCmdResults",pageCmdResults);
           
           // Check the return status has a LENGTH
           if ( isStruct(pageCmdResults) )
               pageResult["CMDSTATUS"] = true;
           else
               pageResult["CMDSTATUS"] = false;
           
           pageResult["CMDRESULTS"] = pageCmdResults;
       }
       catch (any e) {
           pageResult["CMDSTATUS"] = false;
           pageResult["CMDRESULTS"] = pageCmdResults;
           pageResult["CFCATCH"] = e;
       }
       return pageResult;
   </cfscript>	
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$rename
Summary:
	Updates the file name for a page
	http://{servername}/commonspot/help/api_help/content/components/page/rename.html
Returns:
	struct - CS API Return Struct
		 CMDSTATUS
		 CMDRESULTS
Arguments:
	Struct pageData
		id		RealPageID_NonBaseTemplate						Required	A page's ID.
		name	PlainText_NonNull_NoSpace_NoSpecialChars_255	Required	The name of the page.
		title	PlainText_255									Optional. 	Defaults to an empty string.	The title of the page. If an empty string the title will not be changed.	
		caption	PlainText_255									Optional. 	Defaults to an empty string.	The title bar caption of the page. If an empty string the caption will not be changed.	
	
History:
	2012-10-22 - MFC/GAC - Created
--->
<cffunction name="rename" access="public" returntype="struct" hint="Updates the file name for a page">
   <cfargument name="pageData" type="struct" required="true" hint="a structure that contains page the required fields as page data.">
     <cfscript>
       var pageResult = StructNew();
       // Use the CS 6.x Command API to RENAME the page
       var pageComponent = Server.CommonSpot.api.getObject('Page');
       var pageCmdResults = StructNew();
       var newPageTitle = "";
       var newCaption = "";
       
       // Build the Optional Field Nodes
       if ( StructKeyExists(arguments.pageData,"title") )        
           newPageTitle = arguments.pageData.title;    
       if ( StructKeyExists(arguments.pageData,"caption") )
           newCaption = arguments.pageData.caption;
       
       try {
           pageCmdResults = pageComponent.rename(id=arguments.pageData.id,
                                                 name=arguments.pageData.name,
                                                 title=newPageTitle,
                                                 caption=newCaption);
           //doErrorLogging("setCommonspotPageFileName","pageCmdResults",pageCmdResults);
           
           // Check the return status has a LENGTH
           if ( LEN(pageCmdResults) )
               pageResult["CMDSTATUS"] = true;
           else
               pageResult["CMDSTATUS"] = false;
           
           pageResult["CMDRESULTS"] = pageCmdResults;
       }
       catch (any e) {
           pageResult["CMDSTATUS"] = false;
           pageResult["CMDRESULTS"] = pageCmdResults;
           pageResult["CFCATCH"] = e;
       }
       return pageResult;
   </cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$saveInfo
Summary:
	Updates the properties for a page (standard and custom)
	http://{servername}/commonspot/help/api_help/content/components/page/saveinfo.html
Returns:
	struct - CS API Return Struct
		 CMDSTATUS
		 CMDRESULTS
Arguments:
	Struct pageData
		id						RealPageID_NonBaseTemplate		Required	A page's ID.
		title					PlainText_NonNull_255			Required	The title of the page.
		caption					PlainText_255					Required	The title bar caption of the page.
		publicationDate			Datetime						Required	The date and time at which the page will be published.
		categoryID				PageCategoryID					Required	The ID of the category under which the page is classified.
		description				PlainText_2000					Required	A description of the page.
		confidentialityID		ConfidentialityID_0				Optional. 	Defaults to '0'.	 
		showInList				ShowInList_EmptyString_Inherit	Optional. 	Defaults to 'PageIndex,SearchResults'.	A comma-delimited list of one or more 'showIn' values; for example, 'PageIndex', 'SearchResults', or an empty string.
		expirationDate			FutureTimestamp_EmptyString		Optional. 	Defaults to an empty string.	The date and time at which the page will expire.
		expirationAction		ExpirationAction_EmptyString	Optional. 	Defaults to an empty string.	The action that occurs at the document's expiration date; for example, 'Warn', 'DenyAll', 'DenyPublic', or 'Redirect'. Specify an empty string for no action.
		expirationRedirectURL	ValidURL_EmptyString			Optional. 	Defaults to an empty string.	If the value of this method's 'expirationAction' argument is 'Redirect', this argument is the fully-qualified URL to which CommonSpot redirects the viewer.
		expirationWarningMsg	PlainText_255					Optional. 	Defaults to an empty string.	If the value of this method's 'expirationAction' argument is 'Warn', this argument is the warning message that CommonSpot displays.
		(Not Available) 
		metadata				MetadataValueArray				Optional. 	Defaults to '#ArrayNew(1)#'.	An array of MetadataValue structures that describes the metadata field(s) for the specified page, or an empty array if no metadata is to be specified. Note, you should pass data in the array for all the metadata fields that have data. Any existing data, for any non-specified fields will be either be deleted (if no default value is defined for that field) or updated with the default value.
	
History:
	2012-10-22 - GAC - Created
--->
<cffunction name="saveInfo" access="public" returntype="struct" hint="Updates the properties for a page (standard and custom)">
	<cfargument name="pageData" type="struct" required="true" hint="a structure that contains page the required fields as page data.">
	<cfscript>
		var pageResult = StructNew();
		// Use the CS 6.x Command API to SET page Metadata
		var pageComponent = Server.CommonSpot.api.getObject('Page');
		var pageCmdResults = StructNew();
		var newConfidentialityID = 0;
		var newShowInList = "PageIndex,SearchResults";
		var newExpirationDate = "";
		var newExpirationAction = "";
		var newExpirationRedirectURL = "";
		var newMetadata = ArrayNew(1);
		       
		// Build the Optional Field Nodes	
		if ( StructKeyExists(arguments.pageData,"confidentialityID") )
			newConfidentialityID = arguments.pageData.confidentialityID;	
		if ( StructKeyExists(arguments.pageData,"showInList") )
			newShowInList = arguments.pageData.showInList;
		if ( StructKeyExists(arguments.pageData,"expirationDate") )
			newExpirationDate = arguments.pageData.expirationDate;
		if ( StructKeyExists(arguments.pageData,"expirationAction") )
			newExpirationAction = arguments.pageData.expirationAction;
		if ( StructKeyExists(arguments.pageData,"expirationRedirectURL") )
			newExpirationRedirectURL = arguments.pageData.expirationRedirectURL;
		if ( StructKeyExists(arguments.pageData,"expirationDate") )
			newExpirationDate = arguments.pageData.expirationWarningMsg;
		
		if ( StructKeyExists(arguments.pageData,"metadata") )
			newMetadata = arguments.pageData.metadata;

		try {
			pageCmdResults = pageComponent.saveInfo(id=arguments.pageData.id,
		                                            title=arguments.pageData.title,
		                                            caption=arguments.pageData.caption,
		                                            publicationDate=arguments.pageData.publicationDate,
		                                            categoryID=arguments.pageData.categoryID,
		                                            description=arguments.pageData.description,
		                                            confidentialityID=newConfidentialityID,
		                                            showInList=newShowInList,
		                                            expirationDate=newExpirationDate,
		                                            expirationAction=newExpirationAction,
		                                            expirationRedirectURL=newExpirationRedirectURL,
		                                            expirationWarningMsg=newExpirationDate,
		                                            metadata=newMetadata);
		    
		    // Check the return status has a LENGTH
		    pageResult["CMDSTATUS"] = true;
		    pageResult["CMDRESULTS"] = "";
		}
		catch (any e) {
		    doErrorLogging("setCommonspotPageInfo","CFCATCH",e);
		    pageResult["CMDSTATUS"] = false;
		    pageResult["CMDRESULTS"] = "";
		    pageResult["CFCATCH"] = e;
		}
		return pageResult;
		</cfscript>
</cffunction>

</cfcomponent>