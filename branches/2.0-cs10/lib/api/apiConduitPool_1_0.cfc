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
	apiConduitPool_1_0.cfc
Summary:
	API Conduit Page Pool functions for the ADF Library
Version:
	1.0
History:
	2014-09-08 - GAC - Created
	2014-10-08 - GAC - Updated dev comments
	2014-12-19 - GAC - Updated apiConfig logic to protect against apiConfig config issues
					 - Added additional header comments 
	2015-06-11 - GAC - Updated the component extends to use the libraryBase path
--->

<cfcomponent displayname="apiConduitPool_1_0" extends="ADF.lib.libraryBase" hint="API Conduit Page Pool functions for the ADF Library">

<cfproperty name="version" value="1_0_4">
<cfproperty name="api" type="dependency" injectedBean="api_1_0">
<cfproperty name="ccapi" type="dependency" injectedBean="ccapi_2_0">
<cfproperty name="csData" type="dependency" injectedBean="csData_2_0">
<cfproperty name="ceData" type="dependency" injectedBean="ceData_3_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_2_0">
<cfproperty name="wikiTitle" value="APIConduitPool_1_0">

<cfscript>
	// API Pool Default Variables
	variables.defaultApiPoolRequestWaitTime = 200; // ms
	variables.defaultApiPoolGlobalTimeout = 15; 	// seconds
</cfscript>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name: 
	postInit()
	
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="postInit" returntype="void" output="false" access="public" hint="Runs by default after the standard ADF has been built by the loadLibrary command.">
	<cfscript>
	
		// initialize the API POOL memory variables
		initApiPoolVars();
		
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	$initApiPoolVars
Summary:
	Initializes the API Conduit Page Pool variables
Returns:
	Void
Arguments:
	None
History:
	2014-09-08 - GAC - Created
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 
--->
<cffunction name="initApiPoolVars" returntype="void" output="false" access="private" hint="Initializes the API Conduit Page Pool variables">
	<cfscript>
		var adfAPIpoolVars = StructNew();
		var adfAPIpoolConfig = StructNew();

		//-----//
		// Build the ADF API POOL Configuration data structure
		
		// associative array of configured pages
		adfAPIpoolConfig.Pages = buildPoolConduitPagesFromAPIConfig();
		
		adfAPIpoolConfig.Elements = buildElementConfigFromAPIConfig();
		// CEConfigName : "poolDevCE"
		// - formID : 5630
		// - ceName : "Pool Dev Custom Element"
		// - timeout: 30 
		
		// Request Wait Time in milliseconds
		adfAPIpoolConfig.requestWaitTime = getRequestWaitTimeFromAPIConfig(); 
		// Global Timeout in seconds
		adfAPIpoolConfig.globalTimeout = getGlobalTimeoutFromAPIConfig();
		// Page Pool Logging Flag
		adfAPIpoolConfig.logging = getLoggingFlagFromAPIConfig();
		
		//-----//
		// Build the ADF API POOL data structure. 
		
		// associative array of available pages
		adfAPIpoolVars.AvailablePoolPages = Server.CommonSpot.UDF.util.duplicateBean(adfAPIpoolConfig.Pages); // Duplicate Config Page for the Pool Available pages
		// associative array of Pages that are being processed
		adfAPIpoolVars.ProcessingPoolPages = StructNew();
		// An array of pending Requests
		adfAPIpoolVars.RequestQueueArray = ArrayNew(1);
		
		//-----//
		// Setup the Config Application variables (static)
		WritePagePoolConfig(configData=adfAPIpoolConfig);
		// Setup the Pool Vars Application variables (dynamic)
		WritePagePool(poolData=adfAPIpoolVars);
	</cfscript>
</cffunction>

<!--- ///////////////////////////////////////////////////////////////// --->
<!--- ///                PAGE POOL CONFIG SETTINGS                  /// --->
<!--- ///////////////////////////////////////////////////////////////// --->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	$getGlobalTimeoutSetting()
Summary:
	Returns Page Pool Global Timeout value in milliseconds from the API Pool configuration settings
Returns:
	Numeric
Arguments:
	None
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="getGlobalTimeoutSetting" returntype="numeric" access="public" output="false" hint="Returns Page Pool Global Timeout value in milliseconds API Pool configuration settings">
	<cfscript>
		var retData = getGlobalTimeoutFromAPIConfig();
		var apiPoolConfig = ReadPagePoolConfig();
		
		if ( StructKeyExists(apiPoolConfig,"GLOBALTIMEOUT") AND IsNumeric(apiPoolConfig.GLOBALTIMEOUT) AND apiPoolConfig.GLOBALTIMEOUT GT 0 )
			retData = apiPoolConfig.GLOBALTIMEOUT;

		return retData;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	$getRequestWaitTimeSetting()
Summary:
	Returns the Page Pool request wait time value in milliseconds from the API Pool configuration Settings
Returns:
	Numeric
Arguments:
	None
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="getRequestWaitTimeSetting" returntype="numeric" access="public" output="false" hint="Returns the Page Pool request wait time value in milliseconds API Pool configuration settings">
	<cfscript>
		var retData = getRequestWaitTimeFromAPIConfig();
		var apiPoolConfig = ReadPagePoolConfig();
		
		if ( StructKeyExists(apiPoolConfig,"REQUESTWAITTIME") AND IsNumeric(apiPoolConfig.requestWaitTime) AND apiPoolConfig.requestWaitTime GT 0 )
			retData = apiPoolConfig.REQUESTWAITTIME;

		return retData;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	$getLoggingSetting()
Summary:
	Returns the Page Pool Logging enabled status from the API Pool configuration settings
Returns:
	Boolean
Arguments:
	None
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="getLoggingSetting" returntype="boolean" access="public" output="false" hint="Returns the Page Pool Logging enabled status from the API Pool configuration settings">
	<cfscript>
		var retData = false;
		var apiPoolConfig = ReadPagePoolConfig();
		
		if ( StructKeyExists(apiPoolConfig,"LOGGING") AND IsBoolean(apiPoolConfig.LOGGING) )
			retData = apiPoolConfig.LOGGING;

		return retData;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	$getElementConfigTimeout(CEconfigName)
Summary:
	 Returns timeout value for a specific ce config name in seconds
Returns:
	String
Arguments:
	String - CEconfigName
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="getElementConfigTimeout" returntype="string" access="public" output="false" hint="Returns timeout value for a specific ce config name in seconds">
	<cfargument name="CEconfigName" type="string" required="Yes">
	
	<cfscript>
		var retTimeout = getGlobalTimeoutFromAPIConfig();
		var apiPoolConfig = ReadPagePoolConfig();
		
		if ( StructKeyExists(apiPoolConfig,"ELEMENTS") AND StructKeyExists(apiPoolConfig.ELEMENTS,arguments.CEconfigName) 
			AND StructKeyExists(apiPoolConfig.ELEMENTS[arguments.CEconfigName],"TIMEOUT") )
			retTimeout = apiPoolConfig.ELEMENTS[arguments.CEconfigName].TIMEOUT;
		
		return retTimeout;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	$getElementConfigFormID(CEconfigName)
Summary:
	Returns FormID value for a specific ce config name
Returns:
	String
Arguments:
	String - CEconfigName
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="getElementConfigFormID" returntype="numeric" access="private" output="false" hint="Returns FormID value for a specific ce config name">
	<cfargument name="CEconfigName" type="string" required="Yes">
	
	<cfscript>
		var retVal = 0;
		var apiPoolConfig = ReadPagePoolConfig();
		
		if ( StructKeyExists(apiPoolConfig,"ELEMENTS") AND StructKeyExists(apiPoolConfig.ELEMENTS,arguments.CEconfigName) 
			AND StructKeyExists(apiPoolConfig.ELEMENTS[arguments.CEconfigName],"FormID") AND IsNumeric(apiPoolConfig.ELEMENTS[arguments.CEconfigName].FormID) )
			retVal = apiPoolConfig.ELEMENTS[arguments.CEconfigName].FormID;
			
		return retVal;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:	
	$getElementConfigCEName(CEconfigName) - Returns CustomElementName value for a specific ce config name
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="getElementConfigCEName" returntype="string" access="private" output="false">
	<cfargument name="CEconfigName" type="string" required="Yes">
	
	<cfscript>
		var retVal = "";
		var apiPoolConfig = ReadPagePoolConfig();
		
		// Get the Custom Element Name ... if not available use the CEconfigName (in this case most likely the same value)
		if ( StructKeyExists(apiPoolConfig,"ELEMENTS") AND StructKeyExists(apiPoolConfig.ELEMENTS,arguments.CEconfigName) 
			AND StructKeyExists(apiPoolConfig.ELEMENTS[arguments.CEconfigName],"CustomElementName") )
			retVal = apiPoolConfig.ELEMENTS[arguments.CEconfigName].CustomElementName;
		else
			retVal = arguments.CEconfigName;
		
		return retVal;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:	
	$getConduitPageSubsiteID(pageid) - Returns SubsiteID for a specific Conduit Page 
History:
	2014-09-08 - GAC - Created 
--->
<cffunction name="getConduitPageSubsiteID" returntype="numeric" access="private" output="false">
	<cfargument name="pageid" type="string" required="Yes">
	
	<cfscript>
		var retVal = 0;
		var apiPoolConfig = ReadPagePoolConfig();
		
		if ( StructKeyExists(apiPoolConfig,"PAGES") AND StructKeyExists(apiPoolConfig.PAGES,arguments.pageid) 
			AND StructKeyExists(apiPoolConfig.PAGES[arguments.pageid],"SubsiteID") AND IsNumeric(apiPoolConfig.PAGES[arguments.pageid].SubsiteID) )
			retVal = apiPoolConfig.PAGES[arguments.pageid].SubsiteID;
		
		return retVal;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:	
	$getConduitPageCSUserID(pageid) - Returns CSUserID for a specific Conduit Page
History:
	2014-09-08 - GAC - Created  
--->
<cffunction name="getConduitPageCSUserID" returntype="string" access="private" output="false">
	<cfargument name="pageid" type="string" required="Yes">
	
	<cfscript>
		var retVal = "";
		var apiPoolConfig = ReadPagePoolConfig();
		
		if ( StructKeyExists(apiPoolConfig,"PAGES") AND StructKeyExists(apiPoolConfig.PAGES,arguments.pageid) 
			AND StructKeyExists(apiPoolConfig.PAGES[arguments.pageid],"csUserID") )
			retVal = apiPoolConfig.PAGES[arguments.pageid].csUserID;
		
		return retVal;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:
	$getConfigConduitPages() - Returns all of the Conduit Pages
History:
	2014-09-08 - GAC - Created  
--->
<cffunction name="getConfigConduitPages" returntype="struct" access="private" output="false">
	<cfscript>
		var retData = StructNew();
		var apiPoolConfig = ReadPagePoolConfig();
		
		if ( StructKeyExists(apiPoolConfig,"PAGES") )
			retData = apiPoolConfig.PAGES;
		
		return retData;
	</cfscript>
</cffunction>

<!--- ///////////////////////////////////////////////////////////////// --->
<!--- ///                   PAGE POOL PROCESSING                    /// --->
<!--- ///////////////////////////////////////////////////////////////// --->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name: 
	$getConduitPageFromPool(CEconfigName,requestID) - gets a page ID for a conduit page from the Conduit Page Pool
		- 1) Checks if the Request is at the top of the Queue 
		- 2) Checks if the there is an open conduit page
			- if there is not an open conduit page adds the request to the Queue
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="getConduitPageFromPool" returntype="struct" access="public" output="false">
	<cfargument name="CEconfigName" type="string" required="yes">
	<cfargument name="requestID" type="string" required="Yes">

	<cfscript>
		var results = StructNew();
		var pos = 0;

		results.PageID = 0;
		results.Status = false;
	</cfscript>   
	
	<!--- // LOCK the apiPoolVars when REQUESTING an available page --->
	<cflock name="apiPoolVarsRequest" type="exclusive" timeout="10">
		<cfscript>	
			// check if request is in array, but not first in line
			pos = getRequestsPlaceInQueue(requestID=arguments.RequestID);
			if( pos neq 1 )
				return results;
			
			// only process if first in line
			results.PageID = getOpenConduitPageIDFromPool(requestID=arguments.RequestID); // returns 0 if none
			
			if ( results.PageID NEQ 0 )
			{
				// if we have a pageID get the API Config Info for this page (subsiteID,csuserid)
				results.SubsiteID = getConduitPageSubsiteID(pageID=results.PageID);  
				results.csuserid  = getConduitPageCSUserID(pageID=results.PageID);   

				results.FORMID = getElementConfigFormID(CEconfigName=arguments.CEconfigName);   			
				results.TIMEOUT = getElementConfigTimeout(CEconfigName=arguments.CEconfigName);  			
				results.CUSTOMELEMENTNAME = getElementConfigCEName(CEconfigName=arguments.CEconfigName);  
				
				// if we have a PageID remove the Pending Request from the Queue
				if ( pos EQ 1 )
					results.Status = removeRequestFromQueue(queuePos=pos);
			}
		</cfscript>	
	</cflock>
		
	<cfreturn results>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name: 
	$getRequestsPlaceInQueue(requestID) - gets the position of the request in the request queue
History:
	2014-09-08 - GAC - Created
 --->
<cffunction name="getRequestsPlaceInQueue" returntype="numeric" access="private" output="false">
	<cfargument name="requestID" type="string" required="yes">

	<cfscript>
		var i = 0;
		var pos = 0;
		var addToQueue = false;
		var requestQueue = ReadRequestQueueArray();
	    
	  	// LOCKing handle here by the parent calling method getConduitPageFromPool()
	    for( i=1; i lte ArrayLen(requestQueue); i=i+1 )
		{
			if ( requestQueue[i] eq arguments.requestID )
			{
				pos = i;
				break;
			}
		}
		
		if ( pos eq 0 )	// didn't find the request in the queue 
		{
			// LOCKing handle here by the parent calling method getConduitPageFromPool()
			// Add to queue
			addToQueue = addRequestToQueue(requestID=arguments.requestID);
			pos = getRequestQueueCount();
		}
			
		return pos;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:	
	$addRequestToQueue(requestID)
History:
	2014-09-08 - GAC - Created
 --->
<cffunction name="addRequestToQueue" returntype="boolean" access="private" output="false">
	<cfargument name="requestID" type="string" required="yes">
	
	<cfscript>
		var addRequest = false;
		var requestQueue = ReadRequestQueueArray();
		var requestQueueList = ArrayToList(requestQueue);
		
		// add the request to the queue array
		if ( !ListFindNoCase(requestQueueList, arguments.requestID) )
			addRequest = ArrayAppend( requestQueue, arguments.requestID );
		
		// write array data to the Queue
		WriteRequestQueueArray(queueData=requestQueue);

		return addRequest;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$getRequestQueueCount() - Count items in the Request Queue 
History:
	2014-09-08 - GAC - Created
 --->
<cffunction name="getRequestQueueCount" returntype="numeric" access="private" output="false">
	<cfscript>
		var retCnt = 0;
		var requestQueue = ReadRequestQueueArray();
		
		retCnt = ArrayLen(requestQueue);
		
		return retCnt;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$removeRequestFromQueue(requestID) - 
History:
	2014-09-08 - GAC - Created
 --->
<cffunction name="removeRequestFromQueue" returntype="boolean" access="private" output="false">
	<cfargument name="queuePos" type="numeric" required="false" default="1">

	<cfscript>
		var delStatus = false;
		var requestQueue = ReadRequestQueueArray();
		
	    // LOCKing handled here by the parent calling method getConduitPageFromPool()
	    if ( ArrayLen(requestQueue) GTE arguments.queuePos )
	  		delStatus = ArrayDeleteAt(requestQueue,arguments.queuePos);
	  	
	  	// Update the Request Queue array	
	  	WriteRequestQueueArray(queueData=requestQueue);	
	 		
		return delStatus;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$getOpenConduitPageIDFromPool(CEconfigName,requestID) - returns a pageid for a page that is open for use
		- if an open page is found...
			1) add the page to the processing assoc array
			2) remove the page for the available assoc array 
		- if an open page is NOT found
			1) return 0
History:
	2014-09-08 - GAC - Created
 --->
<cffunction name="getOpenConduitPageIDFromPool" returntype="numeric" access="private" output="false">
	<cfargument name="requestID" type="string" required="yes">
	
	<cfscript>
		var retPageID = 0;
		var availablePagesInPool = ReadPoolAvailablePages();
		var processingPages = ReadPoolProcessingPages();
		var key = 0;
		var processingPageData = StructNew();
	
		for ( key IN availablePagesInPool )
		{
			// Check to make sure the page is not currently processing
			if ( !StructKeyExists(processingPages,key) )
			{
				// Check if Page is LOCKED in the LOCKS table 
				// - if no CommonSpot lock set for this pageid then use it, if there is a LOCK on this Page move on to the next pageID
				if ( !IsPageLocked(csPageID=key) )
				{
				
					// If we are here... the Page is OPEN!!
					retPageID = key;
					
					// LOCKing handled here by the parent calling method getConduitPageFromPool()
					
					// Add to Processing Page Assoc array
					processingPageData = StructNew();
					processingPageData.requestID = arguments.requestID;
					processingPageData.timestamp = pagePoolDateTimeFormat(Now());
					//processingPage.timestamp = createObject('java','java.text.SimpleDateFormat').init('yyyy-MM-dd HH:mm:ss.SSS Z').format(now());
					
					processingPages[retPageID] = processingPageData;
					
					// Update the Processing Pool Pages
					WritePoolProcessingPages(pagesData=processingPages);
					
					// LOCKing handled here by the parent calling method getConduitPageFromPool()
					
					// Remove from Available Pages Assoc array 
					StructDelete(availablePagesInPool,retPageID);
					WritePoolAvailablePages(pagesData=availablePagesInPool);
					
					// Force the loop to quit once we have provided an open pageID
					break;
				}
			}
		}	
		
		return retPageID;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$getAvailablePoolPagesCount() - Count the AVAILABLE Conduit Pages currently in the Pool
History:
	2014-09-08 - GAC - Created
 --->
<cffunction name="getAvailablePoolPagesCount" returntype="numeric" access="private" output="false">
	<cfscript>
		var retCnt = 0;
		var poolPages = ReadPoolAvailablePages();
		
		retCnt = StructCount(poolPages);
		
		return retCnt;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$getProcessingPoolPagesCount() - Count the PROCESSING Conduit Pages currently being used
History:
	2014-09-08 - GAC - Created
 --->
<cffunction name="getProcessingPoolPagesCount" returntype="numeric" access="private" output="false">
	
	<cfscript>
		var retCnt = 0;
		var poolPages = ReadPoolProcessingPages();
		
		retCnt = StructCount(poolPages);
		
		return retCnt;
	</cfscript>
</cffunction>

<!--- ///////////////////////////////////////////////////////////////// --->
<!--- ///                  POOL REQUEST COMPLETION                  /// --->
<!--- ///////////////////////////////////////////////////////////////// --->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:	
	$markRequestComplete() - mark the request complete by removing the page from the processing page and put it back in available page
History:
	2014-09-08 - GAC - Created 
--->
<cffunction name="markRequestComplete" returntype="boolean" access="public" output="false">
	<cfargument name="requestID" type="string" required="yes">
	
	<cfscript>
		var retStatus = false;
		var requestPageID = 0;
		var openPageID = 0;
	</cfscript>
	
	<!--- // LOCK the apiPoolVars when Marking the request as complete --->
	<cflock name="apiPoolVarsRelease" type="exclusive" timeout="10">
		<cfscript>
			requestPageID = getPageIDFromProcessingRequests(requestID=arguments.requestID);
			
			openPageID = setPoolPageAsOpen(pageID=requestPageID);
			
			// Clear the lock on the page when putting in back in the Pool
			clearLock(csPageID=requestPageID);
		</cfscript>
	</cflock>
	
	<cfscript>	
		if ( requestPageID NEQ 0 AND openPageID NEQ 0 )
			retStatus = true;
		
		return retStatus;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$setPoolPageAsOpen(pageID)
History:
	2014-09-08 - GAC - Created
 --->
<cffunction name="setPoolPageAsOpen" returntype="numeric" access="private" output="false">
	<cfargument name="pageID" type="string" required="yes">
	
	<cfscript>
		var retPageID = 0;
		var openPoolPage = StructNew();
		var configPoolPages = getConfigConduitPages(); 
		var processingPoolPages = ReadPoolProcessingPages();
		var availablePoolPages = ReadPoolAvailablePages();
		
		//var csData = server.ADF.objectFactory.getBean("csdata_1_2");
		
		// LOCKing handled here by the parent calling method getConduitPageFromPool()
		if ( StructKeyExists(processingPoolPages,arguments.pageID) )
		{
			// Remove the Processing PageID from the ProcessingPoolPages
			StructDelete(processingPoolPages,arguments.pageID);
			// Update the Processing pages Struture
			WritePoolProcessingPages(pagesData=processingPoolPages);
				
			// Add PageID back to available pages
			if ( variables.csData.isCSPageActive(pageid=arguments.pageID) )
			{ 	
				
				if ( !StructKeyExists(availablePoolPages,arguments.pageID) )
					availablePoolPages[arguments.pageID] = StructNew();
				
				availablePoolPages[arguments.pageID].SubsiteID = getConduitPageSubsiteID(pageID=arguments.PageID);  
				availablePoolPages[arguments.pageID].csuserid  = getConduitPageCSUserID(pageID=arguments.PageID); 
				
				// Add back to the AvailablePoolPages
				WritePoolAvailablePages(pagesData=availablePoolPages);
				
				retPageID = arguments.pageID;
			}
			else
			{
					//TODO: Add logging	
			}
		}

		return retPageID;
	</cfscript>	
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$getPageIDFromProcessingRequests(requestID)
History:
	2014-09-08 - GAC - Created 
--->
<cffunction name="getPageIDFromProcessingRequests" returntype="numeric" access="private" output="false">
	<cfargument name="requestID" type="string" required="yes">

	<cfscript>
		var retPageID = 0;
		var key = "";
		var processingPages = ReadPoolProcessingPages();
			
		for ( key IN processingPages )
		{
			if ( StructKeyExists(processingPages[key],"requestID") AND processingPages[key].requestID EQ arguments.requestID )
			{
				retPageID = key;
				break;	
			}	
					
		}
		
		return retPageID;
	</cfscript>	
</cffunction>

<!--- ///////////////////////////////////////////////////////////////// --->
<!--- ///          COMMONSPOT CMD API AND CCAPI METHODS             /// --->
<!--- ///////////////////////////////////////////////////////////////// --->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:	
	$getCCAPIcontrolID(csPageID,FormID,controlName) - DEV ONLY
History:
	2014-09-08 - GAC - Created 
--->
<cffunction name="getCCAPIcontrolID" returntype="numeric" access="public" output="false">
	<cfargument name="csPageID" type="numeric" required="yes" hint="CCAPI conduit pageID">
	<cfargument name="formID" type="numeric" required="yes" hint="Custom Element FormID / ContolTypeID">
	<cfargument name="ControlName" type="string" required="false" default="ccapiGCEPoolControl_#arguments.csPageID#_#arguments.FormID#" hint="ControlName to be assigned to the control instance record.">
	
	<cfscript>
		var retValue = 0;
		var qryControlInstance = QueryNew("temp");
		var controlID = 0;
		var CreationDate = "";
	</cfscript>
	
	<cfquery name="qryControlInstance" datasource="#request.site.datasource#">
		SELECT * 
		FROM controlinstance
		WHERE ControlType = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.FormID#">  
		AND PageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.csPageID#"> 
	</cfquery>
	
	<cfif qryControlInstance.RecordCount LT 1>
		<cfset controlID = request.site.IDMaster.getID()>
		<cfset CreationDate = Application.ADF.date.csDateFormat(Now(),Now())>
		
		<cfquery name="updateControlInstance" datasource="#request.site.datasource#">
			INSERT INTO controlinstance 
			(
				PageID,ControlID,ControlName,ControlType,ParentControlID,ParentControlType,CreationDate,OwnerID
			) 
			VALUES 
			(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.csPageID#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#controlID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ControlName#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.FormID#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="0">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="0">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#CreationDate#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.user.id#">
			);
		</cfquery>
		
		<cfset retValue = controlID>
	<cfelse>
		<cfset retValue = qryControlInstance.ControlID>
	</cfif>
	
	<cfreturn retValue>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:	
	$getPageLockStatus(csPageID)
History:
	2014-09-08 - GAC - Created 
--->
<cffunction name="getPageLockStatus" returntype="struct" access="private" output="false">
	<cfargument name="csPageID" type="numeric" required="yes">
	
	<cfscript>
		var pageComponent = server.CommonSpot.api.getObject('page');
		var lockStatus = pageComponent.getLockStatus(pageID=arguments.csPageID);
		
		return lockStatus;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$IsPageLocked(csPageID)
History:
	2014-09-08 - GAC - Created
 --->
<cffunction name="IsPageLocked" returntype="boolean" access="private" output="false">
	<cfargument name="csPageID" type="numeric" required="yes">
	
	<cfscript>
		var lockStatus = getPageLockStatus(csPageID=arguments.csPageID);
		var isLocked = false;
		
		if ( StructKeyExists(lockStatus,"userID") AND IsNumeric(lockStatus.userID) AND  lockStatus.userID GT 0 )
			isLocked = true;
		
		return isLocked;
	</cfscript>
</cffunction>

<!--- /////////////////////////////////////////////////////////////////// --->
<!--- ///           API CONDUIT PAGE POOL UTILITY METHODS             /// --->
<!--- /////////////////////////////////////////////////////////////////// --->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$getAPIConfig() 
History:
	2014-09-08 - GAC - Created
 --->
<cffunction name="getAPIConfig" returntype="struct" access="private" output="false">
	<!--- <cfset var api = server.ADF.objectFactory.getBean("api_1_0")> --->
	<cfreturn variables.api.getAPIConfig()>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$clearLock(csPageID) - Clears the lock for a page id passed in
History:
	2014-09-08 - GAC - Created
 --->
<cffunction name="clearLock" returntype="boolean" access="private" output="false">
	<cfargument name="csPageID" type="numeric" required="yes">
	<!--- <cfset var ccapi = server.ADF.objectFactory.getBean("ccapi_2_0")> --->
	<cfreturn variables.ccapi.clearLock(pageID=arguments.csPageID)>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$pagePoolDateTimeFormat()
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="pagePoolDateTimeFormat" returntype="date" access="public" output="false">	
	<cfargument name="datetime" required="false" type="string" default="#now()#">

	<cfscript>
		var poolDateTime = '';
		if ( isDate(arguments.datetime) )
			poolDateTime = createObject('java','java.text.SimpleDateFormat').init('yyyy-MM-dd HH:mm:ss.SSS').format(arguments.datetime); // yyyy-MM-dd HH:mm:ss.SSS Z
		return poolDateTime;
	</cfscript>
</cffunction>

<!--- /////////////////////////////////////////////////////////////////// --->
<!--- ///        BUILD CONFIG AND POOL FROM THE API CONFIG            /// --->
<!--- /////////////////////////////////////////////////////////////////// --->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$buildPoolConduitPagesFromAPIConfig() - builds the pool structure from the ccapi config values
History:
	2014-09-08 - GAC - Created
	2014-12-18 - GAC - Added additional logic to protect against bad apiConfig data
 --->
<cffunction name="buildPoolConduitPagesFromAPIConfig" returntype="struct" output="false" access="private">
	<cfscript>
		var retData = StructNew();
		var apiConfig = getAPIConfig();
		var key = "";
		
		var poolPages = StructNew();
		var poolPageID = 0;
		var poolPageConfig = StructNew();
		
		var configNodeStatus = true;
		//var csData = server.ADF.objectFactory.getBean("csdata_1_2");
		
		// Do we have a Conduit Page Pool in the Config element
		if ( StructKeyExists(apiConfig,"gceConduitPagePool") AND StructKeyExists(apiConfig.gceConduitPagePool,"conduitPages") )
		{
			poolPages = apiConfig.gceConduitPagePool.conduitPages;

			if ( IsStruct(poolPages) )
			{	
				// Rip through the gceConduitPagePool nodes and find element that have conduit pool pages configured	
				for ( key IN poolPages )
				{
					poolPageConfig = StructNew();			
					configNodeStatus = true;
					
					// Make sure we have a valid pageID
					if ( StructKeyExists(poolPages[key],"pageid") AND IsNumeric(poolPages[key].pageid) AND poolPages[key].pageid GT 0 )
					{
						// Make sure the config pageid value is an active page 
						if ( variables.csData.isCSPageActive(pageid=poolPages[key].pageid) )
						{
							// Set the Conduit PageID
							poolPageID = poolPages[key].pageid;
							
							// Set the Conduit SubsiteID
							poolPageConfig.subsiteID  = variables.csData.getSubsiteIDByPageID(pageid=poolPageID);
							 
							if ( poolPageConfig.subsiteID LTE 0 )
							 	configNodeStatus = false;
						}
						else
							configNodeStatus = false;
						
						if ( configNodeStatus )	
							poolPageConfig.pageURL = variables.csData.getCSPageURL(pageID=poolPageID);
						
					}
					// If PageURL is configured, make sure it converts to a valid pageID
					else if ( StructKeyExists(poolPages[key],"pageURL") AND LEN(TRIM(poolPages[key].pageURL)) )
					{
						// Add the Page URL to the page pool config struct
						poolPageConfig.pageURL = poolPages[key].pageURL;
						
						poolPageID = variables.csData.getCSPageIDByURL(csPageURL=poolPageConfig.pageURL);
						
						// Make sure the pageid value valid and an active page 
						if ( IsNumeric(poolPageID) AND poolPageID GT 0 AND variables.csData.isCSPageActive(pageid=poolPageID) )
						{
							// Set the Conduit SubsiteID
							poolPageConfig.subsiteID  = variables.csData.getSubsiteIDByPageID(pageid=poolPageID);
							 
							if ( poolPageConfig.subsiteID LTE 0 )
							 	configNodeStatus = false;
						}
						else
							configNodeStatus = false;	
					}
					else
						configNodeStatus = false;
					
					// Make sure the page has a configured CSUserID
					if ( configNodeStatus AND StructKeyExists(poolPages[key],"csuserid") AND LEN(TRIM(poolPages[key].csuserid)) )
						poolPageConfig.csuserid = poolPages[key].csuserid;
					else
						configNodeStatus = false;
	
					// Don't add the PW to the config struct but we still want to check if the PW was added to the pool page config
					// - TODO: we may want to add a quick login/logout check to make sure the userid and password are valid before adding the to the POOL
					if ( configNodeStatus )
					{
						if ( !StructKeyExists(poolPages[key],"cspassword") OR LEN(TRIM(poolPages[key].cspassword)) EQ 0 )
							configNodeStatus = false;			
					} 					
						
					// If we successfully build a pool page config node, then add it to the array 	
					if ( configNodeStatus AND !StructKeyExists(retData, poolPageID) )	
						retData[poolPageID]	= poolPageConfig;
					else
					{
						// TODO: Add logging	
					}
				}
			}
			else
			{
				// The GCE Conduit Page Pool nodes is configured incorrectly (not returning as a structure)
				// TODO: Add logging		
			}
		}
		else
		{
			// No GCE Conduit Page Pool nodes configured
			// TODO: Add logging		
		}
		
		return retData;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:	
	$buildElementConfigFromAPIConfig() - 
History:
	2014-09-08 - GAC - Created
	2014-12-18 - GAC - Added additional logic to protect against bad apiConfig data
 --->
<cffunction name="buildElementConfigFromAPIConfig" returntype="struct" access="private" output="false">
	<cfscript>
		var retData = StructNew();
		var poolElements = StructNew();
		var apiConfig = getAPIConfig();
		var key = "";
		var poolPageID = 0;
		var i = 1;
		
		//var ceData = server.ADF.objectFactory.getBean("cedata_2_0");
		
		var timeoutDefault = getGlobalTimeoutFromAPIConfig(); 
		
		if ( IsStruct(apiConfig) )
		{
			if ( StructKeyExists(apiConfig,"elements") AND IsStruct(apiConfig.elements) )
			{
				// Rip through the element nodes and find elements that have conduit pool pages configured	
				for ( key IN apiConfig.elements )
				{
					if ( StructKeyExists(apiConfig.elements[key],"elementType") AND apiConfig.elements[key].elementType EQ "custom"
						AND StructKeyExists(apiConfig.elements[key],"gceConduitConfig") AND IsStruct(apiConfig.elements[key].gceConduitConfig) )
					{
						poolElements = apiConfig.elements[key].gceConduitConfig;
						
						if ( !StructKeyExists(retData, key) )
							retData[key] = StructNew();
						
						retData[key].timeout = timeoutDefault;
						if ( StructKeyExists(poolElements,"timeout") AND IsNumeric(poolElements.timeout) AND poolElements.timeout GT 0 )
							retData[key].timeout = poolElements.timeout;
						
						if ( StructKeyExists(poolElements,"formID") AND IsNumeric(poolElements.formID) AND poolElements.formID GT 0 )
						{
							retData[key].formID = poolElements.formID;
							retData[key].customElementName = variables.ceData.getCENameByFormID(FormID=poolElements.formID);
						}
						else if ( StructKeyExists(poolElements,"customElementName") AND LEN(TRIM(poolElements.customElementName)) )
						{
							retData[key].customElementName = poolElements.customElementName;
							retData[key].formID = variables.ceData.getFormIDByCEName(CEName=poolElements.customElementName);
						}
					}
					else
					{
						// TODO: Add logging					
					}		
				}
			}
			else
			{
				// TODO: Add logging
				// apiConfig.elements is not building correctly (should be a structure of CCAPI element and settings)				
			}	
		}
		else
		{
			// TODO: Add logging
			// apiConfig is not building correctly (should be a structure of CCAPI config settings)				
		}		
		
		return retData;
	</cfscript>
</cffunction>

<!--- /////////////////////////////////////////////////////////////////// --->
<!--- ///       GET CONFIG AND POOL VALUES FROM THE API CONFIG        /// --->
<!--- /////////////////////////////////////////////////////////////////// --->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$getGlobalTimeoutFromAPIConfig() -  Page Pool Global Timeout value in seconds
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="getGlobalTimeoutFromAPIConfig" returntype="numeric" access="private" output="false">
	<cfscript>
		var retData = variables.defaultApiPoolGlobalTimeout;
		var apiConfig = getAPIConfig();
		
		if ( StructKeyExists(apiConfig,"gceConduitPagePool") AND StructKeyExists(apiConfig.gceConduitPagePool,"globalTimeout")  
			AND IsNumeric(apiConfig.gceConduitPagePool.globalTimeout) AND apiConfig.gceConduitPagePool.globalTimeout GT 0 )
			retData = apiConfig.gceConduitPagePool.globalTimeout;

		return retData;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$getLoggingFlagFromAPIConfig() -  Page Pool Global Timeout value in seconds
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="getLoggingFlagFromAPIConfig" returntype="boolean" access="private" output="false">
	<cfscript>
		var retData = 0; // default: false
		var apiConfig = getAPIConfig();
		
		if ( StructKeyExists(apiConfig,"gceConduitPagePool") AND StructKeyExists(apiConfig.gceConduitPagePool,"logging") 
			AND IsBoolean(apiConfig.gceConduitPagePool.logging) )
			retData = apiConfig.gceConduitPagePool.logging;
		
		return retData;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$getRequestWaitTimeFromAPIConfig() -  Page Pool request wait time value in milliseconds from the API config
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="getRequestWaitTimeFromAPIConfig" returntype="boolean" access="private" output="false">
	<cfscript>
		var retData = variables.defaultApiPoolRequestWaitTime;
		var apiConfig = getAPIConfig();
		
		if ( StructKeyExists(apiConfig,"gceConduitPagePool") AND StructKeyExists(apiConfig.gceConduitPagePool,"requestWaitTime") 
			AND IsNumeric(apiConfig.gceConduitPagePool.requestWaitTime) AND apiConfig.gceConduitPagePool.requestWaitTime GT 0 )
			retData = apiConfig.gceConduitPagePool.requestWaitTime;
		
		return retData;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$getConduitPoolPagePasswordFromAPIConfig(pageID) - Returns Page Pool Password for a given PageID
History:
	2014-09-08 - GAC - Created
	2014-12-18 - GAC - Added additional logic to protect against bad apiConfig data
--->
<cffunction name="getConduitPoolPagePasswordFromAPIConfig" returntype="string" access="public" output="false">
	<cfargument name="pageID" type="string" required="Yes">
	
	<cfscript>
		var apiConfig = getAPIConfig();
		var poolPages = StructNew();
		var retPassword = "";
		
		if ( StructKeyExists(apiConfig,"gceConduitPagePool") AND StructKeyExists(apiConfig.gceConduitPagePool,"conduitPages") )
		{
			poolPages = apiConfig.gceConduitPagePool.conduitPages;
		
			for ( key IN poolPages )
			{
				if ( StructKeyExists(poolPages[key],"pageid") AND poolPages[key].pageid EQ arguments.pageID AND StructKeyExists(poolPages[key],"cspassword") )
				{
					// TODO: encrypt/decrypt this password 
					retPassword = poolPages[key].cspassword;	
					break;
				}
			}
		}
		
		return retPassword;
	</cfscript>
</cffunction>

<!--- ///////////////////////////////////////////////////////////////// --->
<!--- ///               CONFIG AND POOL DAO METHODS                 /// --->
<!--- ///////////////////////////////////////////////////////////////// --->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$ReadPagePoolConfig()
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="ReadPagePoolConfig" returntype="struct" access="private" output="false">	
	<cflock name="apiPoolConfig" type="readonly" timeout="10">
		<cfreturn Application.ADF.apiPoolConfig>
	</cflock>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$WritePagePoolConfig(configData)
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="WritePagePoolConfig" returntype="void" access="private" output="false">
	<cfargument name="configData" type="struct" required="Yes">	

	<cflock name="apiPoolConfig" type="exclusive" timeout="10">
		<cfscript>
			if ( !StructKeyExists(Application.ADF,"apiPoolConfig") )
				Application.ADF.apiPoolConfig = StructNew();
			
			 Application.ADF.apiPoolConfig = arguments.configData;
		</cfscript>
	</cflock>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:	
	$ReadPagePool()
History:
	2014-09-08 - GAC - Created
	2015-02-18 - GAC - Updated the lock name and the lock type
--->
<cffunction name="ReadPagePool" returntype="struct" access="private" output="false">
	<cflock name="apiPoolVars" type="readonly" timeout="10">
		<cfreturn Application.ADF.apipool>
	</cflock>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$WritePagePool(poolData)
History:
	2014-09-08 - GAC - Created
	2015-02-18 - GAC - Updated the lock name
--->
<cffunction name="WritePagePool" returntype="void" access="private" output="false">
	<cfargument name="poolData" type="struct" required="Yes">	
	
	<cflock name="apiPoolVars" type="exclusive" timeout="10">
		<cfscript>
			if ( !StructKeyExists(Application.ADF,"apipool") )
				Application.ADF.apipool = StructNew();
			
			 Application.ADF.apipool = arguments.poolData;
		</cfscript>
	</cflock>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:	
	$ReadPoolAvailablePages()
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="ReadPoolAvailablePages" returntype="struct" access="private" output="false">	
	<cfscript>
		if ( !StructKeyExists(Application.ADF.apipool,"AvailablePoolPages") OR !IsStruct(Application.ADF.apipool.AvailablePoolPages) )
			Application.ADF.apipool.AvailablePoolPages = StructNew();
		
		return Application.ADF.apipool.AvailablePoolPages;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:	
	$WritePoolAvailablePages(pagesData)
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="WritePoolAvailablePages" returntype="void" access="private" output="false">
	<cfargument name="pagesData" type="struct" required="Yes">	
	
	<cfscript>
		if ( !StructKeyExists(Application.ADF.apipool,"AvailablePoolPages") OR !IsStruct(Application.ADF.apipool.AvailablePoolPages) )
			Application.ADF.apipool.AvailablePoolPages = StructNew();
	
		Application.ADF.apipool.AvailablePoolPages = arguments.pagesData;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$ReadPoolProcessingPages()
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="ReadPoolProcessingPages" returntype="struct" access="private" output="false">
	<cfscript>
		if ( !StructKeyExists(Application.ADF.apipool,"ProcessingPoolPages") OR !IsStruct(Application.ADF.apipool.ProcessingPoolPages) )
			Application.ADF.apipool.ProcessingPoolPages = StructNew();
			
		return Application.ADF.apipool.ProcessingPoolPages;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:	
	$WritePoolProcessingPages(pagesData)
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="WritePoolProcessingPages" returntype="void" access="private" output="false">
	<cfargument name="pagesData" type="struct" required="Yes">	

	<cfscript>
		if ( !StructKeyExists(Application.ADF.apipool,"ProcessingPoolPages") OR !IsStruct(Application.ADF.apipool.ProcessingPoolPages) )
			Application.ADF.apipool.ProcessingPoolPages = StructNew();
	
		Application.ADF.apipool.ProcessingPoolPages = arguments.pagesData;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
Name:	
	$ReadRequestQueueArray()
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="ReadRequestQueueArray" returntype="array" access="private" output="false">		
	<cfscript>
		if ( !StructKeyExists(Application.ADF.apipool,"RequestQueueArray") OR !IsArray(Application.ADF.apipool.RequestQueueArray) )
			Application.ADF.apipool.RequestQueueArray = ArrayNew(1);
			
		return Application.ADF.apipool.RequestQueueArray;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:	
	$WriteRequestQueueArray(queueData)
History:
	2014-09-08 - GAC - Created
--->
<cffunction name="WriteRequestQueueArray" returntype="void" access="private" output="false">
	<cfargument name="queueData" type="array" required="Yes">
		
	<cfscript>
		if ( !StructKeyExists(Application.ADF.apipool,"RequestQueueArray") OR !IsArray(Application.ADF.apipool.RequestQueueArray) )
			Application.ADF.apipool.RequestQueueArray = ArrayNew(1);

		 Application.ADF.apipool.RequestQueueArray = arguments.queueData;
	</cfscript>
</cffunction>

</cfcomponent>