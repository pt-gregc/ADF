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
	apiPage_1_0.cfc
Summary:
	API Page functions for the ADF Library
Version:
	1.0
History:
	2012-12-26 - MFC - Created
	2015-02-27 - GAC - Added the deletePageRedirects method
	2015-06-11 - GAC - Updated the component extends to use the libraryBase path
	2015-09-09 - GAC - Added the move method
					 - Added the invalidatePageCache method
--->
<cfcomponent displayname="apiPage_1_0" extends="ADF.lib.libraryBase" hint="API Page functions for the ADF Library">

<cfproperty name="version" value="1_0_14">
<cfproperty name="api" type="dependency" injectedBean="api_1_0">
<!---<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">--->
<cfproperty name="wikiTitle" value="APIPage_1_0">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$create
Summary:
	Creates a commonspot page using the public command API
	http://{servername}/commonspot/help/api_help/Content/Components/Page/create.html
Returns:
	Struct
Arguments:
	Numeric csPageID			
History:
	2013-01-02 - MFC - Created
	2013-07-07 - GAC - Fixed an issue with the publicationDate and the PublicReleaseDate
	2014-10-28 - AW@EA - Fixed issue with expirationWarningMsg and misplaced newExpirationDate variables
	2015-01-13 - GAC - Fixed issue with newExpirationWarningMsg variable 
	2015-04-07 - GAC - Added logic to use the Title for the caption when no Caption value is passed in
	2015-06-16 - GAC - Updated the activatePage argument to be type=boolean 
	2015-08-22 - GAC - Minor formatting changes
--->
<cffunction name="create" access="public" returntype="struct" hint="Creates a page.">
	<cfargument name="pageData" type="struct" required="true" hint="a structure that contains page the required fields as page data.">
	<cfargument name="activatePage" type="boolean" required="false" default="1" hint="Flag to make the new page active or inactive"> 
	
	<cfscript>
		var pageResult = StructNew();
		// Use the CS 6.x Command API to SET page Metadata
		var pageComponent = server.CommonSpot.api.getObject('Page');
		var pageCmdResults = StructNew();
		var newConfidentialityID = 0;
		var newShowInList = "PageIndex,SearchResults";
		var newExpirationDate = "";
		var newExpirationAction = "";
		var newExpirationRedirectURL = "";
		var newExpirationWarningMsg = "";
		var newMetadata = ArrayNew(1);
		var activateState = "";
		var caption = "";
		
		// If no Caption use the Title
		if ( StructKeyExists(arguments.pageData,"caption") AND LEN(TRIM(arguments.pageData.caption)) )
			caption = arguments.pageData.caption;	
		else
			caption = arguments.pageData.title;	
		
		// Convert PUBLICRELEASEDATE to publicationDate if exists
		if ( !StructKeyExists(arguments.pageData,"publicationDate") AND StructKeyExists(arguments.pageData,"PublicReleaseDate") )
			arguments.pageData.publicationDate = arguments.pageData.PublicReleaseDate;
		
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
		if ( StructKeyExists(arguments.pageData,"expirationWarningMsg") )
			newExpirationWarningMsg = arguments.pageData.expirationWarningMsg;
		
		if ( StructKeyExists(arguments.pageData,"metadata") )
			newMetadata = arguments.pageData.metadata;

		try 
		{
			// Returns the PageID of the new page
			pageCmdResults = pageComponent.create(subsiteIDOrURL=arguments.pageData.subsiteID,
																	name=arguments.pageData.name,
																	title=arguments.pageData.title,
																	caption=caption,
																	publicationDate=arguments.pageData.publicationDate,
																	categoryID=arguments.pageData.categoryID,
																	templateID=arguments.pageData.templateID,
																	description=arguments.pageData.description,
																	targetedAudienceID=0,
																	confidentialityID=newConfidentialityID,
																	showInList=newShowInList,
																	expirationDate=newExpirationDate,
																	expirationAction=newExpirationAction,
																	expirationRedirectURL=newExpirationRedirectURL,
																	expirationWarningMsg=newExpirationWarningMsg,
																	metadata=newMetadata);
		    
		    // Activate the page
		    if ( arguments.activatePage )
		    	activateState = saveActivationState(pageCmdResults, "Active");
		    
		    // Check the return status has a LENGTH
		    pageResult["CMDSTATUS"] = true;
		    pageResult["CMDRESULTS"] = pageCmdResults;
		}
		catch ( any e ) 
		{
			//application.ADF.utils.logAppend(e,"APIPage_Errors.log");
		    pageResult["CMDSTATUS"] = false;
		    pageResult["CMDRESULTS"] = e;
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
	$delete
Summary:
	Deletes a commonspot page using the public command API
	http://{servername}/commonspot/help/api_help/Content/Components/Page/delete.html
Returns:
	Struct
Arguments:
	Numeric csPageID	
	Boolean ignoreWarnings
	Boolean removeRedirects 		
History:
	2012-10-25 - MFC/GAC - Created
	2015-02-27 - GAC - Added a parameter to ignoreWarnings and delete the page even if error is thrown from the api delete page command
				     - Added a parameter to remove page redirects before attempting to delete the page
--->
<cffunction name="delete" access="public" returntype="struct" hint="Deletes a page or template.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	<cfargument name="ignoreWarnings" type="boolean"  default="false" required="false" hint="a flag to delete the page even if page warning are thrown. Use with caution!">
	<cfargument name="removeRedirects" type="boolean" default="false" required="false" hint="a flag for removing page redirects so the page can be deleted.">
	
	<cfscript>
		var pageCmdResult = StructNew();
		// Use the CS 6.x Command API to delete the page whose pageID was passed in
		var pageComponent = server.CommonSpot.api.getObject('page');

		if ( arguments.removeRedirects )
			deletePageRedirects(csPageID=arguments.csPageID);
		
		try {
			pageComponent.delete(arguments.csPageID,arguments.ignoreWarnings);
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
       var pageComponent = server.CommonSpot.api.getObject('Page');
       var pageCmdResults = StructNew();

       try {
           pageCmdResults = pageComponent.getInfo(pageID=arguments.csPageID);
           
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
       var pageComponent = server.CommonSpot.api.getObject('Page');
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
	$saveActivationState
Summary:
	Saves Activation State on a commonspot page using the public command API
	http://{servername}/commonspot/help/api_help/Content/Components/Page/saveActivationState.html
Returns:
	Struct
		CMDSTATUS
		CMDRESULTS
Arguments:
	Numeric csPageID
	String state - A string describing a page's activation state; for example, 'Active', 'AutoActivate', or 'Inactive'.			
History:
	2013-01-02 - MFC - Created
--->
<cffunction name="saveActivationState" access="public" returntype="struct" hint="Sets the activation state for a page to 'Activate', 'AutoActivate', or 'Inactive'.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	<cfargument name="state" type="string" required="true" hint="A string describing a page's activation state; for example, 'Active', 'AutoActivate', or 'Inactive'.">
	<cfscript>
		var pageCmdResult = StructNew();
		// Use the CS 6.x Command API to SET page keywords
		var pageComponent = server.CommonSpot.api.getObject('page');
		try {
			pageComponent.saveActivationState(arguments.csPageID, arguments.state);
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
	2013-04-29 - MFC - Removed reference to function "DOERRORLOGGING" that was removed.
	2015-01-09 - GAC - Fixed issues with expirationWarningMsg and newExpirationDate variables
	2015-08-23 - GAC - Removed the pageCmdResults since the page.SaveInfo returns Void.
	2015-09-01 - GAC - Added update to convert PUBLICRELEASEDATE to publicationDate if it exists 
--->
<cffunction name="saveInfo" access="public" returntype="struct" hint="Updates the properties for a page (standard and custom)">
	<cfargument name="pageData" type="struct" required="true" hint="a structure that contains page the required fields as page data.">
	
	<cfscript>
		var pageResult = StructNew();
		// Use the CS 6.x Command API to SET page Metadata
		var pageComponent = server.CommonSpot.api.getObject('Page');
		var newConfidentialityID = 0;
		var newShowInList = "PageIndex,SearchResults";
		var newExpirationDate = "";
		var newExpirationAction = "";
		var newExpirationRedirectURL = "";
		var newExpirationWarningMsg = "";
		var newMetadata = ArrayNew(1);
		
		// Convert PUBLICRELEASEDATE to publicationDate if it exists
		if ( !StructKeyExists(arguments.pageData,"publicationDate") AND StructKeyExists(arguments.pageData,"PublicReleaseDate") )
			arguments.pageData.publicationDate = arguments.pageData.PublicReleaseDate;
		       
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
		if ( StructKeyExists(arguments.pageData,"expirationWarningMsg") )
			newExpirationWarningMsg = arguments.pageData.expirationWarningMsg;
		
		if ( StructKeyExists(arguments.pageData,"metadata") )
			newMetadata = arguments.pageData.metadata;

		try 
		{
			// page.SaveInfo returns VOID
			pageComponent.saveInfo(id=arguments.pageData.id,
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
                                     expirationWarningMsg=newExpirationWarningMsg,
                                     metadata=newMetadata);
		    
		    // Check the return status has a LENGTH
		    pageResult["CMDSTATUS"] = true;
		    pageResult["CMDRESULTS"] = "Success: Page Metadata info was successful saved.";
		}
		catch (any e) 
		{
		    pageResult["CMDSTATUS"] = false;
		    pageResult["CMDRESULTS"] = "Failed: Page Metadata info was not saved.";
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
	$deletePageRedirects
Summary:
	Deletes a commonspot page redirects using the public command API
	http://{servername}commonspot/help/api_help/content/components/redirects/delete.html
Returns:
	Struct
Arguments:
	Numeric csPageID			
History:
	2015-02-27 - GAC - Created
--->
<cffunction name="deletePageRedirects" access="public" returntype="struct" hint="Deletes a commonspot page redirects using the public command API.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	
	<cfscript>
		var pageResult = StructNew();
		var pageCmdResult = StructNew();
		// Use the CS 6.x Command API to delete the page whose pageID was passed in
		var redirectComponent = server.CommonSpot.api.getObject('Redirects');
		var redirectQry = redirectComponent.getListForPage(pageID=arguments.csPageID);
		var redirectIDlist = ValueList(redirectQry.ID); 
		
		try 
		{
			if ( LEN(TRIM(redirectIDlist)) )
			{
				pageCmdResult = redirectComponent.delete(idList=redirectIDlist);
				
				if ( StructKeyExists(pageCmdResult,"success") AND pageCmdResult.success EQ 1 ) 
				{
					pageResult["CMDSTATUS"] = true;
					pageResult["CMDRESULTS"] = true;
				}
				else
				{
					pageResult["CMDSTATUS"] = false;
					pageResult["CMDRESULTS"] = pageCmdResult;		
				}
			}
			else
			{
				pageResult["CMDSTATUS"] = true;
				pageResult["CMDRESULTS"] = "No Redirect IDs Found for this CommonSpot PageID";		
			}
		} 
		catch (any e) 
		{
			pageResult["CMDSTATUS"] = false;
			if ( StructKeyExists(e,"Reason") AND StructKeyExists(e['Reason'],"pageID") ) 
				pageResult["CMDRESULTS"] = e['Reason']['pageID']; 
			else if ( StructKeyExists(e,"message") )
				pageResult["CMDRESULTS"] = e.message;
			else
				pageResult["CMDRESULTS"] = e;
		}
		return pageResult;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$movePage
Summary:
	Moves an updated page to a new subsite.
Returns:
	Struct
Arguments:
	Numeric csPageID				
History:
	2015-08-28 - GAC - Created
--->
<cffunction name="move" access="public" returntype="struct" hint="Invalidates the Page Cache for the specified page.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	<cfargument name="csSubsiteID" type="numeric" required="true" hint="numeric commonspot subsite id">
	<cfargument name="addPermanentRedirect" type="boolean" required="false" default="true" hint="boolean flag commonspot adding a permanent redirect">
	
	<cfscript>
		var pageResult = StructNew();
		var pageComponent = Server.CommonSpot.api.getObject('Page');

		try 
		{
			// Returns void
			pageComponent.move(
								subsiteIDOrURL=arguments.csSubsiteID,
								pageID=arguments.csPageID,
								addPermanentRedirect=arguments.addPermanentRedirect
							);
							
			pageResult["CMDSTATUS"] = true;
			pageResult["CMDRESULTS"] = true;
			pageResult["MSG"] = "Success: Page was succesfully moved!";
		} 
		catch ( any e ) 
		{
			pageResult["CMDSTATUS"] = false;
			pageResult["CMDRESULTS"] = e;
			pageResult["MSG"] = "Fail: Page move failed!";
			
			// TODO: Add Error logging
		}
		
		return pageResult;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$invalidatePageCache
Summary:
	Invalidates the Page Cache for the specified page.
Returns:
	Struct
Arguments:
	Numeric csPageID				
History:
	2015-08-21 - GAC - Created
--->
<cffunction name="invalidatePageCache" access="public" returntype="struct" hint="Invalidates the Page Cache for the specified page.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	
	<cfscript>
		var pageResult = StructNew();
		// Use the CS 6.x Command API to SET page keywords
		var pageComponent = Server.CommonSpot.api.getObject('Page');
		var pageCmdResults = "";
		try 
		{
			pageComponent.invalidateCache(pageID=arguments.csPageID);
			pageResult["CMDSTATUS"] = true;
			pageResult["CMDRESULTS"] = true;
		} 
		catch ( any e ) 
		{
			pageResult["CMDSTATUS"] = false;
			pageResult["CMDRESULTS"] = false;
		}
		return pageResult;
	</cfscript>
</cffunction>

</cfcomponent>