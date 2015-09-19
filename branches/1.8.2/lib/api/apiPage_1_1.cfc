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
	apiPage_1_1.cfc
Summary:
	API Page functions for the ADF Library
Version:
	1.1
History:
	2015-09-11 - GAC - Created
--->
<cfcomponent displayname="apiPage_1_1" extends="ADF.lib.api.apiPage_1_0" hint="API Page functions for the ADF Library">

<cfproperty name="version" value="1_1_0">
<cfproperty name="api" type="dependency" injectedBean="api_1_0">
<cfproperty name="apiRemote" type="dependency" injectedBean="apiRemote_1_0">
<!---<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">--->
<cfproperty name="wikiTitle" value="APIPage_1_1">

<!---//////////////////////////////////////////////////////--->
<!---//            REMOTE COMMAND API METHODS            //--->
<!---//////////////////////////////////////////////////////--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$createRemote
Summary:
	Creates a commonspot page using the public command API
	http://{servername}/commonspot/help/api_help/Content/Components/Page/create.html
Returns:
	Struct
Arguments:
	Numeric csPageID			
History:
	2015-09-01 - GAC - Created
--->
<cffunction name="createRemote" access="public" returntype="struct" hint="Creates a page.">
	<cfargument name="pageData" type="struct" required="true" hint="a structure that contains page the required fields as page data.">
	<cfargument name="activatePage" type="boolean" required="false" default="1" hint="Flag to make the new page active or inactive"> 
	
	<cfscript>
		var pageResult = StructNew();
		var createArgs = StructNew();
		var pageCmdResults = StructNew();
		var newTargetedAudienceID = 0;
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
		if ( StructKeyExists(arguments.pageData,"targetedAudienceID") AND IsNumeric(arguments.pageData.targetedAudienceID) AND arguments.pageData.targetedAudienceID GT 0 )
			newTargetedAudienceID = arguments.pageData.targetedAudienceID;
			
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
			
		// Metdata Array
		if ( StructKeyExists(arguments.pageData,"metadata") )
			newMetadata = arguments.pageData.metadata;
		
		commandArgs['Target'] = "page";
		commandArgs['method'] = "create";
		commandArgs['args'] = StructNew();
		commandArgs['args'].subsiteIDOrURL = arguments.pageData.subsiteID;
		commandArgs['args'].name = arguments.pageData.name;
		commandArgs['args'].title = arguments.pageData.title;
		commandArgs['args'].caption = caption;
		commandArgs['args'].publicationDate = arguments.pageData.publicationDate;
		commandArgs['args'].categoryID = arguments.pageData.categoryID;
		commandArgs['args'].templateID = arguments.pageData.templateID;
		commandArgs['args'].description = arguments.pageData.description;
		commandArgs['args'].targetedAudienceID = newTargetedAudienceID;
		commandArgs['args'].confidentialityID = newConfidentialityID;
		commandArgs['args'].showInList = newShowInList;
		commandArgs['args'].expirationDate = newExpirationDate;
		commandArgs['args'].expirationAction = newExpirationAction;
		commandArgs['args'].expirationRedirectURL = newExpirationRedirectURL;
		commandArgs['args'].expirationWarningMsg = newExpirationWarningMsg;
		commandArgs['args'].metadata = newMetadata;
		
		try 
		{
			// Returns Void
			pageCmdResults = variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);
		    
			
			if ( StructKeyExists(pageCmdResults,"data") )
		   { 
		   		pageResult["CMDRESULTS"] = pageCmdResults.data;
		   		pageResult["CMDSTATUS"] = true;
		   }
		   else
		   {
			   	if ( StructKeyExists(pageCmdResults,"status") AND  StructKeyExists(pageCmdResults.status,"text") )
			   		pageResult["CMDRESULTS"] = pageCmdResults.status.text;
			   	else	
			   		pageResult["CMDRESULTS"] = pageCmdResults;	
				
				pageResult["CMDSTATUS"] = false;
		   }
			
		    // Activate the page
		    if ( arguments.activatePage AND IsNumeric(pageResult["CMDRESULTS"]) AND pageResult["CMDRESULTS"] GT 0 )
		    	activateState = saveActivationStateRemote(pageResult["CMDRESULTS"], "Active");

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
	$deleteRemote
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
	2015-09-01 - GAC - Created
--->
<cffunction name="deleteRemote" access="public" returntype="struct" hint="Deletes a page or template.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	<cfargument name="ignoreWarnings" type="boolean"  default="false" required="false" hint="a flag to delete the page even if page warning are thrown. Use with caution!">
	<cfargument name="removeRedirects" type="boolean" default="false" required="false" hint="a flag for removing page redirects so the page can be deleted.">
	
	<cfscript>
		var pageCmdResult = StructNew();
		var commandArgs = StructNew();

		if ( arguments.removeRedirects )
			deletePageRedirectsRemote(csPageID=arguments.csPageID);
		
		commandArgs['Target'] = "Page";
		commandArgs['method'] = "delete";
		commandArgs['args'] = StructNew();
		commandArgs['args'].pageID = arguments.csPageID;
		commandArgs['args'].ignoreWarnings = arguments.ignoreWarnings;
		
		try 
		{
			// Returns Void
			variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);
			
			pageCmdResult["CMDSTATUS"] = true;
			pageCmdResult["CMDRESULTS"] = true;
		} 
		catch ( any e ) 
		{
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
	$moveRemote
Summary:
	Moves a page to a selected subsite
	http://{servername}/commonspot/help/api_help/content/components/page/move.html
Returns:
	struct - CS API Return Struct
		 CMDSTATUS
		 CMDRESULTS
Arguments:
	Numeric csPageID
	Numeric csSubsiteID
	Boolean addPermanentRedirect		
History:
	2015-09-01 - GAC - Created
--->
<cffunction name="moveRemote" access="public" returntype="struct" hint="Moves a page to a selected subsite.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	<cfargument name="csSubsiteID" type="numeric" required="true" hint="numeric commonspot subsite id">
	<cfargument name="addPermanentRedirect" type="boolean" required="false" default="true" hint="boolean flag commonspot adding a permanent redirect">
	
	<cfscript>
		var pageResult = StructNew();
		var pageCmdResults = StructNew();
		var commandArgs = StructNew();
		
		commandArgs['Target'] = "Page";
		commandArgs['method'] = "move";
		commandArgs['args'] = StructNew();
		commandArgs['args'].subsiteIDOrURL = arguments.csSubsiteID;
		commandArgs['args'].pageID = arguments.csPageID;
		commandArgs['args'].addPermanentRedirect = arguments.addPermanentRedirect;
		
		try 
		{
			pageCmdResults = variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);
			
			if ( StructKeyExists(pageCmdResults,"status") AND StructKeyExists(pageCmdResults.status,"data") AND StructKeyExists(pageCmdResults.status.data,"fielderrors")   )
			{
		   		pageResult["CMDRESULTS"] = pageCmdResults.status.data.fielderrors;
		   		pageResult["CMDSTATUS"] = false;
		   		pageResult["MSG"] = "Fail: Page move failed!";
		    }
		    else
		    {
				pageResult["CMDSTATUS"] = true;
				pageResult["CMDRESULTS"] = true;
				pageResult["MSG"] = "Success: Page was succesfully moved!";
			}
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
	$renameRemote
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
	2015-09-01 - GAC - Created
--->
<cffunction name="renameRemote" access="public" returntype="struct" hint="Updates the file name for a page">
	<cfargument name="pageData" type="struct" required="true" hint="a structure that contains page the required fields as page data.">
     
	<cfscript>
       var pageResult = StructNew();
       var pageCmdResults = StructNew();
       var newPageTitle = "";
       var newCaption = "";
       
       // Build the Optional Field Nodes
       if ( StructKeyExists(arguments.pageData,"title") )        
           newPageTitle = arguments.pageData.title;    
       if ( StructKeyExists(arguments.pageData,"caption") )
           newCaption = arguments.pageData.caption;
       
	   commandArgs['Target'] = "Page";
	   commandArgs['method'] = "rename";
	   commandArgs['args'] = StructNew();
	   commandArgs['args'].id = arguments.pageData.id;
	   commandArgs['args'].name = arguments.pageData.name;
	   commandArgs['args'].title = newPageTitle;
	   commandArgs['args'].caption = newCaption;
	   
       try 
	   {
           pageCmdResults = variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);
           
           // Check the return status has a LENGTH
           if ( IsStruct(pageCmdResults) AND StructKeyExists(pageCmdResults,"data") )
		   {
           		pageResult["CMDRESULTS"] = pageCmdResults.data;
			    pageResult["CMDSTATUS"] = true;
           }
		   else
		   {
               pageResult["CMDSTATUS"] = false;
			   pageResult["CMDRESULTS"] = pageCmdResults;
		   }
       }
       catch ( any e ) 
	   {
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
	$saveActivationStateRemote
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
	2015-09-01 - GAC - Created
--->
<cffunction name="saveActivationStateRemote" access="public" returntype="struct" hint="Sets the activation state for a page to 'Activate', 'AutoActivate', or 'Inactive'.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	<cfargument name="state" type="string" required="true" hint="A string describing a page's activation state; for example, 'Active', 'AutoActivate', or 'Inactive'.">
	
	<cfscript>
		var pageCmdResult = StructNew();
		var commandArgs = StructNew();
		
		commandArgs['Target'] = "Page";
		commandArgs['method'] = "saveActivationState";
		commandArgs['args'] = StructNew();
		commandArgs['args'].pageID = arguments.csPageID;
		commandArgs['args'].state = arguments.state;
		
		try 
		{
			// page.saveActivationState Returns Void
			variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);
			
			pageCmdResult["CMDSTATUS"] = true;
			pageCmdResult["CMDRESULTS"] = true;
		} 
		catch ( any e ) 
		{
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
	$getInfoRemote
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
	2015-09-01 - GAC - Created
--->
<cffunction name="getInfoRemote" access="public" returntype="struct" hint="Returns array containing page properties (standard and custom) based on a page id.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	
	<cfscript>
		var pageResult = StructNew();
		var commandArgs = StructNew();
      	var pageCmdResults = StructNew();
		
		commandArgs['Target'] = "Page";
		commandArgs['method'] = "getInfo";
		commandArgs['args'] = StructNew();
		commandArgs['args'].pageID = arguments.csPageID;

       try 
	   {
           pageCmdResults = variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);

		   if ( StructKeyExists(pageCmdResults,"data") )
		   { 
		   		pageResult["CMDRESULTS"] = pageCmdResults.data;
		   		pageResult["CMDSTATUS"] = true;
		   }
		   else
		   {
		   		if ( StructKeyExists(pageCmdResults,"status") AND StructKeyExists(pageCmdResults.status,"data") AND StructKeyExists(pageCmdResults.status.data,"fielderrors")   )
		   			pageResult["CMDRESULTS"] = pageCmdResults.status.data.fielderrors;
		   		else
		   			pageResult["CMDRESULTS"] = pageCmdResults;
		   			
				pageResult["CMDSTATUS"] = false;
		   }
       }
       catch ( Any e ) 
       {
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
	$saveInfoRemote
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
	2015-09-01 - GAC - Created
--->
<cffunction name="saveInfoRemote" access="public" returntype="struct" hint="Updates the properties for a page (standard and custom)">
	<cfargument name="pageData" type="struct" required="true" hint="a structure that contains page the required fields as page data.">
	
	<cfscript>
		var pageResult = StructNew();
		var commandArgs = StructNew();
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
		
		// An array of structs
		if ( StructKeyExists(arguments.pageData,"metadata") )
			newMetadata = arguments.pageData.metadata;

		commandArgs['Target'] = "Page";
		commandArgs['method'] = "saveInfo";
		commandArgs['args'] = StructNew();
		commandArgs['args'].id = arguments.pageData.id;
		commandArgs['args'].title = arguments.pageData.title;
		commandArgs['args'].caption = arguments.pageData.caption;
		commandArgs['args'].publicationDate = arguments.pageData.publicationDate;
		commandArgs['args'].categoryID = arguments.pageData.categoryID;
		commandArgs['args'].description = arguments.pageData.description;
		commandArgs['args'].confidentialityID = newConfidentialityID;
		commandArgs['args'].showInList = newShowInList;
		commandArgs['args'].expirationDate = newExpirationDate;
		commandArgs['args'].expirationAction = newExpirationAction;
		commandArgs['args'].expirationRedirectURL = newExpirationRedirectURL;
		commandArgs['args'].expirationWarningMsg = newExpirationWarningMsg;
		commandArgs['args'].metadata = newMetadata;
	
		try 
		{
			// page.SaveInfo returns VOID
			variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);
		    
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
	$deletePageRedirectsRemote
Summary:
	Deletes a commonspot page redirects using the public command API
	http://{servername}commonspot/help/api_help/content/components/redirects/delete.html
Returns:
	Struct
Arguments:
	Numeric csPageID			
History:
	2015-09-01 - GAC - Created
--->
<cffunction name="deletePageRedirectsRemote" access="public" returntype="struct" hint="Deletes a commonspot page redirects using the public command API.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	
	<cfscript>
		var pageResult = StructNew();
		var pageCmdResult = StructNew();
		var commandArgs = StructNew();
		var redirectData = getPageRedirectsRemote(csPageID=arguments.csPageID);
		var redirectIDlist = "";
		
		if ( StructKeyExists(redirectData,"CMDRESULTS") AND IsQuery(redirectData.CMDRESULTS) AND redirectData.CMDRESULTS.RecordCount )
			redirectIDlist = ValueList(redirectData.CMDRESULTS.ID); 
		
		commandArgs['Target'] = "Redirects";
		commandArgs['method'] = "delete";
		commandArgs['args'] = StructNew();
		commandArgs['args'].idList = redirectIDlist;
		
		try 
		{
			if ( LEN(TRIM(redirectIDlist)) )
			{
				// Retruns Void
				variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);
				
				pageResult["CMDSTATUS"] = true;
				pageResult["CMDRESULTS"] = true;
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
	$getPageRedirectsRemote
Summary:
	Gets a query of commonspot page redirects using the public command API.
	http://{servername}commonspot/help/api_help/content/components/redirects/getListForPage.html
Returns:
	Struct
Arguments:
	Numeric csPageID			
History:
	2015-09-01 - GAC - Created
--->
<cffunction name="getPageRedirectsRemote" access="public" returntype="struct" hint="Gets a query of commonspot page redirects using the public command API.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	
	<cfscript>
		var redirectQry = QueryNew("temp");
		var pageCmdResults = StructNew();
		var commandArgs = StructNew();
		
		commandArgs['Target'] = "Redirects";
		commandArgs['method'] = "getListForPage";
		commandArgs['args'] = StructNew();
		commandArgs['args'].pageID = arguments.csPageID;
		
		try 
		{
			pageCmdResults = variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);
			
		    if ( IsStruct(pageCmdResults) AND StructKeyExists(pageCmdResults,"data") )
		    {
           		if ( IsArray(pageCmdResults.data) AND ArrayLen(pageCmdResults.data) ) 
				 	redirectQry = application.ADF.data.arrayOfStructuresToQuery(theArray=pageCmdResults.data,forceColsToVarchar=true,allowComplexValues=false);
				
				pageResult["CMDSTATUS"] = true;
			    pageResult["CMDRESULTS"] = redirectQry;
            }
		    else
		    {
                pageResult["CMDSTATUS"] = false;
			    pageResult["CMDRESULTS"] = pageCmdResults;
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
	$invalidatePageCacheRemote
Summary:
	Invalidates the Page Cache for the specified page.
Returns:
	Struct
Arguments:
	Numeric csPageID				
History:
	2015-09-01 - GAC - Created
--->
<cffunction name="invalidatePageCacheRemote" access="public" returntype="struct" hint="Invalidates the Page Cache for the specified page.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	
	<cfscript>
		var pageResult = StructNew();
		//var pageComponent = Server.CommonSpot.api.getObject('Page');
		var pageCmdResults = "";
		var commandArgs = StructNew();
		
		commandArgs['Target'] = "Page";
		commandArgs['method'] = "invalidateCache";
		commandArgs['args'] = StructNew();
		commandArgs['args'].pageID = arguments.csPageID;
		
		try 
		{
			variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);
			
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