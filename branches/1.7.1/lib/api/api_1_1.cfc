<cfcomponent displayname="api_1_1" extends="ADF.lib.api.api_1_0" hint="">

<cfproperty name="version" value="1_1_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">
<cfproperty name="wikiTitle" value="API">

<!--- 
	init()
--->
<cffunction name="init">
	<cfscript>
		super.init();
		
		// initialize the API POOL memory variables
		initApiPoolVars();
		
		return this;
	</cfscript>
</cffunction>

<!--- 
	initApiPoolVars()
--->
<cffunction name="initApiPoolVars" returntype="void">
	<cfscript>
		var adfAPIpool = StructNew();
		
		// associative array of Pages that are being processed
		adfAPIpool.ProcessingPoolPages = StructNew();
		// associative array of requests that are being processed
		adfAPIpool.ProcessingPoolRequests = StructNew();
		
		// associative array of available pages
		adfAPIpool.AvailablePoolPages = getPoolConduitPagesFromAPIConfig();
		
		// An array of requests
		adfAPIpool.RequestQueueArray = StructNew(); // the structure hold Arrays for each element
		
		// Request Wait time in milliseconds
		adfAPIpool.requestWait = 200; // ms
	</cfscript>
	
	<cflock name="apiPoolVars" type="exclusive" timeout="30">
		<cfscript>
			// If we are initializing then clear the apipool 
			// - (may want to move out of the application.ADF scope)
			Application.ADF.apipool = StructNew();

			StructAppend(Application.ADF.apipool, adfAPIpool, false);
		</cfscript>
	</cflock>
</cffunction>

<!--- 
	getConduitPageFromPool(CEconfigName,requestID) - gets a page ID for a conduit page from the Conduit Page Pool
		- 1) Checks if the Request is at the top of the Queue 
		- 2) Checks if the there is an open conduit page
			- if there is not an open conduit page adds the request to the Queue
--->
<cffunction name="getConduitPageFromPool" returntype="struct">
	<cfargument name="CEconfigName" type="string" required="yes">
	<cfargument name="requestID" type="string" required="Yes">

	<cfscript>
		var results = StructNew();
		var pos = 0;
		var csData = server.ADF.objectFactory.getBean("csdata_1_2");
		
		results.PageID = 0;
		results.Status = false;
		
		// check if request is in array, but not first in line
		pos = getRequestsPlaceInQueue(CEconfigName=arguments.CEconfigName,requestID=arguments.RequestID);
		if( pos neq 1 )
			return results;

		// only process if first in line
		results.PageID = getOpenConduitPageIDFromPool(CEconfigName=arguments.CEconfigName,requestID=arguments.RequestID); // returns 0 if none
		
		if ( results.PageID NEQ 0 )
		{
			// if we have a pageID get the subsiteID
			results.SubsiteID = csData.getSubsiteIDByPageID(pageid=results.PageID);
			
			// if we have a PageID remove the Pending Request from the Queue
			if ( pos EQ 1 )
				results.Status = removeRequestFromQueue(CEconfigName=arguments.CEconfigName,queuePos=pos);
		}
		
		return results;
	</cfscript>
</cffunction>

<!--- 
	getPoolConduitPagesFromAPIConfig() -  builds the pool from the ccapi config values
 --->
<cffunction name="getPoolConduitPagesFromAPIConfig" returntype="struct">
	<cfscript>
		var retData = StructNew();
		var poolPages = StructNew();
		var apiConfig = getAPIConfig();
		var key = "";
		var poolPageID = 0;
		var i = 1;
		var csData = server.ADF.objectFactory.getBean("csdata_1_2");
		
		// Rip through the element nodes and find element that have conduit pool pages configured	
		for ( key IN apiConfig.elements )
		{
			if ( StructKeyExists(apiConfig.elements[key],"conduitPoolIDlist") AND LEN(TRIM(apiConfig.elements[key].conduitPoolIDlist)) )
			{
				if ( !StructKeyExists(retData, key) )
					retData[key] = StructNew();

				for ( i=1; i LTE ListLen(apiConfig.elements[key].conduitPoolIDlist); i=i+1 ) 
				{
					poolPageID = ListGetAt(apiConfig.elements[key].conduitPoolIDlist,i); 
					if ( csData.isCSPageActive(pageid=poolPageID) AND !StructKeyExists(retData[key], poolPageID) )
						retData[key][poolPageID] = csData.getSubsiteIDByPageID(pageid=poolPageID); // maybe return subsite ID
				}
			}		
		}
		
		return retData;
	</cfscript>
</cffunction>

<!--- 
	getRequestsPlaceInQueue(CEconfigName,requestID) - 
 --->
<cffunction name="getRequestsPlaceInQueue" returntype="numeric">
	<cfargument name="CEconfigName" type="string" required="yes">
	<cfargument name="requestID" type="string" required="yes">

	<cfscript>
		var i = 0;
		var pos = 0;
		
	    //TODO: Add READ LOCK
	    if ( StructKeyExists(Application.ADF.apipool.RequestQueueArray,arguments.CEconfigName) )
	    {
			for( i=1; i lte ArrayLen(Application.ADF.apipool.RequestQueueArray[arguments.CEconfigName]); i=i+1 )
			{
				if ( Application.ADF.apipool.RequestQueueArray[arguments.CEconfigName][i] eq arguments.requestID )
					pos = i;
			}
	    }
	    else
	  		Application.ADF.apipool.RequestQueueArray[arguments.CEconfigName] = ArrayNew(1);  
	    
		if( pos eq 0 )	// didn't find it 
		{
			//TODO: Add an EXCLUSIVE LOCK with short timeout
			// Add to queue
			ArrayAppend( Application.ADF.apipool.RequestQueueArray[arguments.CEconfigName], arguments.requestID );
			pos = ArrayLen(Application.ADF.apipool.RequestQueueArray[arguments.CEconfigName]);
		}
		
		return pos;
	</cfscript>
</cffunction>

<!--- 
	removeRequestFromQueue(CEconfigName,requestID) - 
 --->
<cffunction name="removeRequestFromQueue" returntype="boolean">
	<cfargument name="CEconfigName" type="string" required="yes">
	<cfargument name="queuePos" type="numeric" required="false" default="1">

	<cfscript>
		var delStatus = false;
		
	    //TODO: Add an EXCLUSIVE LOCK with short timeout
	    if ( StructKeyExists(Application.ADF.apipool.RequestQueueArray,arguments.CEconfigName) AND ArrayLen(Application.ADF.apipool.RequestQueueArray[arguments.CEconfigName]) GTE arguments.queuePos )
	  		delStatus = ArrayDeleteAt(Application.ADF.apipool.RequestQueueArray[arguments.CEconfigName],arguments.queuePos);	
	   	
		return delStatus;
	</cfscript>
</cffunction>

<!--- 
	getOpenConduitPageIDFromPool(CEconfigName,requestID) - returns a pageid for a page that is open for use
		- if an open page is found...
			1) add the page to the processing assoc array
			2) remove the page for the available assoc array 
		- if an open page is NOT found
			1) return 0
 --->
<cffunction name="getOpenConduitPageIDFromPool" returntype="numeric">
	<cfargument name="CEconfigName" type="string" required="yes">
	<cfargument name="requestID" type="string" required="yes">
	
	<cfscript>
		var retPageID = 0;
		var availablePagesInPool = getAvailablePoolPages(CEconfigName=arguments.CEconfigName);
		var key = 0;

		for ( key IN availablePagesInPool )
		{
			if( NOT StructKeyExists(Application.ADF.apipool.ProcessingPoolPages,arguments.CEconfigName) OR NOT StructKeyExists(Application.ADF.apipool.ProcessingPoolPages[arguments.CEconfigName], key) )
			{
				// Its OPEN
				retPageID = key;
				
				// TODO: Add excusive locking for ProcessingPoolPages
				// Add to Processing Assoc array 
				Application.ADF.apipool.ProcessingPoolPages[arguments.CEconfigName][retPageID] = arguments.requestID;
				Application.ADF.apipool.ProcessingPoolRequests[arguments.CEconfigName][arguments.requestID] = retPageID;
				
				// TODO: Add excusive locking for AvailablePoolPages
				// Remove from Available Assoc array 
				StructDelete(Application.ADF.apipool.AvailablePoolPages[arguments.CEconfigName],retPageID);
				
				// Force the loop to quit once we have provided an open pageID
				break;
			}
		}	
		
		return retPageID;
	</cfscript>
</cffunction>

<!--- 
	getAvailablePoolPages() - Get the AVAILABLE Conduit Pages from the Pool
		- if no config CE name passed in... you get the full nested struct of elements with pageIDs
 --->
<cffunction name="getAvailablePoolPages" returntype="struct">
	<cfargument name="CEconfigName" type="string" required="false" default="">
	
	<cfset var retData = StructNew()>
	<cfset var poolType = "AvailablePoolPages">
	
	<cflock name="apiPoolVars" type="READ" timeout="30">
		<cfscript>
			if ( StructKeyExists(Application.ADF.apipool,"availablepoolpages") )
			{
				if ( LEN(TRIM(arguments.CEconfigName)) )
				{
					if ( StructKeyExists(Application.ADF.apipool.AVAILABLEPOOLPAGES,arguments.CEconfigName) )
						retData = Application.ADF.apipool.AVAILABLEPOOLPAGES[arguments.CEconfigName];
				}
				else
					retData = Application.ADF.apipool.AVAILABLEPOOLPAGES;
			}
		</cfscript>
	</cflock>
	
	<cfreturn retData>
</cffunction>

<!--- 
	getProcessingPoolPages() - Get the cuurent PROCESSING Conduit Pages from the Pool
 --->
<cffunction name="getProcessingPoolPages" returntype="struct">
	<cfargument name="CEconfigName" type="string" required="false" default="">
	
	<cfset var retData = StructNew()>
	<cfset var poolType = "ProcessingPoolPages">
	
	<cflock name="apiPoolVars" type="READ" timeout="30">
		<cfscript>
			if ( StructKeyExists(Application.ADF.apipool,"ProcessingPoolPages") )
			{
				if ( LEN(TRIM(arguments.CEconfigName)) )
				{
					if ( StructKeyExists(Application.ADF.apipool.ProcessingPoolPages,arguments.CEconfigName) )
						retData = Application.ADF.apipool.ProcessingPoolPages[arguments.CEconfigName];
				}
				else
					retData = Application.ADF.apipool.ProcessingPoolPages;
			}
		</cfscript>
	</cflock>
	
	<cfreturn retData>
</cffunction>

<!--- 
	markRequestComplete() -
 --->
<cffunction name="markRequestComplete" returntype="boolean">
	<cfargument name="CEconfigName" type="string" required="false" default="">
	<cfargument name="requestID" type="string" required="yes">
	
	<cfscript>
		var retStatus = false;
		var requestPageID = 0;
		var openPageID = 0;
		
		requestPageID = cleanupRequestFromPool(CEconfigName=arguments.CEconfigName,requestID=arguments.requestID);
		
		openPageID = setPoolPageAsOpen(CEconfigName=arguments.CEconfigName,pageID=requestPageID);
		
		if ( requestPageID NEQ 0 AND openPageID NEQ 0 )
			retStatus = true;
		
		return retStatus;
	</cfscript>
</cffunction>

<!--- 
	setPoolPageAsOpen(CEconfigName,pageID)
 --->
<cffunction name="setPoolPageAsOpen" returntype="numeric">
	<cfargument name="CEconfigName" type="string" required="false" default="">
	<cfargument name="pageID" type="string" required="yes">
	
	<cfscript>
		var retPageID = 0;
		var openPoolPage = StructNew();
		var availablePagesPool = StructNew();
		var csData = server.ADF.objectFactory.getBean("csdata_1_2");
		
		// TODO: Add Locking
		if ( StructKeyExists(Application.ADF.apipool.ProcessingPoolPages,arguments.CEconfigName) AND StructKeyExists(Application.ADF.apipool.ProcessingPoolPages[arguments.CEconfigName],arguments.pageID) )
		{
			// Remove the Processing PageID from the ProcessingPoolPages
			StructDelete(Application.ADF.apipool.ProcessingPoolPages[arguments.CEconfigName],arguments.pageID);
			
			if ( !StructKeyExists(Application.ADF.apipool.AVAILABLEPOOLPAGES,arguments.CEconfigName) )
				Application.ADF.apipool.AVAILABLEPOOLPAGES[arguments.CEconfigName] = StructNew();
			else
				availablePagesPool = Application.ADF.apipool.AVAILABLEPOOLPAGES[arguments.CEconfigName];
			
			// Add PageID back to available pages
			if ( csData.isCSPageActive(pageid=arguments.pageID) AND !StructKeyExists(availablePagesPool, arguments.pageID) )
			{
				openPoolPage[arguments.pageID] = csData.getSubsiteIDByPageID(pageid=arguments.pageID); 
				
				// Add back to the AvailablePoolPages
				StructAppend( Application.ADF.apipool.AVAILABLEPOOLPAGES[arguments.CEconfigName], openPoolPage);
				
				//Application.ADF.apipool.AVAILABLEPOOLPAGES[arguments.CEconfigName] = openPoolPages;
				retPageID = arguments.pageID;
			}
		}
		
		return retPageID;
	</cfscript>	
</cffunction>

<!--- 
	cleanupRequestFromPool(CEconfigName,requestID)
 --->
<cffunction name="cleanupRequestFromPool" returntype="numeric">
	<cfargument name="CEconfigName" type="string" required="false" default="">
	<cfargument name="requestID" type="string" required="yes">

	<cfscript>
		var retPageID = 0;
		
		// TODO: Add Locking
		if ( StructKeyExists(Application.ADF.apipool.ProcessingPoolRequests,arguments.CEconfigName) AND StructKeyExists(Application.ADF.apipool.ProcessingPoolRequests[arguments.CEconfigName],arguments.requestID) )
		{
			// Get the PageID for the Processing Request
			retPageID = Application.ADF.apipool.ProcessingPoolRequests[arguments.CEconfigName][arguments.requestID];
			
			// Remove the Processing RequestID from the ProcessingPoolRequests
			StructDelete(Application.ADF.apipool.ProcessingPoolRequests[arguments.CEconfigName],arguments.requestID);
		}
		
		return retPageID;
	</cfscript>	
</cffunction>

<!---  
	- ReadAvailablePoolPages()
	WriteAvailabelPoolPage()
	DeleteAvailabelPoolPage()
	
	ReadProcessingPoolPages()
	WriteProcessingPoolPages()
	DeleteProcessingPoolPages()
	
	ReadProcessingPoolRequests()
	WriteProcessingPoolRequests()
	DeleteProcessingPoolRequest()
	
	ReadRequestQueueArray()
	WriteRequestQueueArray()
	DeleteRequestQueueArray()
	
	-ReadApiPool()
	-WriteApiPool()
	
	ProcessingPoolPages = StructNew();
	ProcessingPoolRequests = StructNew();
	AvailablePoolPages = StructNew();
	RequestQueueArray = StructNew();  
	RequestQueueArray[cename] = ArrayNew(1);
--->

<!---	
	ReadAvailablePoolPages()
--->
<cffunction name="ReadAvailablePoolPages" returntype="struct">
	<cfargument name="ceName" type="string" required="false" default="">
	<cflock name="apiPoolVars" type="read" timeout="10">
		<cfscript>
			if ( LEN(TRIM(arguments.ceName)) AND StructKeyExists(Application.ADF,arguments.ceName)  )
				return	Application.ADF.apipool.AvailablePoolPages[arguments.ceName];
			else
				return Application.ADF.apipool.AvailablePoolPages;
		</cfscript>
	</cflock>
	<cflock name="apiPoolVars" type="read" timeout="10">
		<cfscript>
			return	Application.ADF.apipool.AvailablePoolPages;
		</cfscript>
	</cflock>
</cffunction>

<!---	
	WriteAvailabelPoolPage()
--->
<cffunction name="WriteAvailabelPoolPage" returntype="void">
	<cflock name="apiPoolVars" type="read" timeout="10">
		<cfscript>
			return	Application.ADF.apipool.AvailablePoolPages;
		</cfscript>
	</cflock>
</cffunction>

<!---	
	ReadApiPool()
--->
<cffunction name="ReadApiPool" returntype="struct">
	<cfargument name="poolType" type="string" required="false" default="">
	
	<cflock name="apiPoolVars" type="read" timeout="10">
		<cfscript>
			if ( LEN(TRIM(arguments.poolType)) AND StructKeyExists(Application.ADF,arguments.poolType)  )
				return	Application.ADF.apipool[arguments.poolType];
			else
				return Application.ADF.apipool;
		</cfscript>
	</cflock>
</cffunction>

<!---	
	WriteApiPool()
--->
<cffunction name="WriteApiPool" returntype="void">
	<cfargument name="poolStruct" type="struct" required="false" default="#StructNew()#">
	<cfargument name="initVar" type="boolean" required="false" default="false">
	
	<cflock name="apiPoolVars" type="exclusive" timeout="10">
		<cfscript>
			if ( !StructKeyExists(Application.ADF,"apipool") OR arguments.initVar )
				Application.ADF.apipool = StructNew();

			StructAppend(Application.ADF.apipool, arguments.adfAPIpool, true);
		</cfscript>
	</cflock>
</cffunction>

</cfcomponent>