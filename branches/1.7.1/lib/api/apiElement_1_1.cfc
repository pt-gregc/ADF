<cfcomponent displayname="apiElement_1_1" extends="ADF.lib.api.apiElement_1_0" hint="">

<cfproperty name="version" value="1_1_0">
<cfproperty name="api" type="dependency" injectedBean="api_1_1">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">
<cfproperty name="wikiTitle" value="API Elements">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$populateCustom
Summary:
	Populates a custom element record.
	Return structure will have a status code and message
Returns:
	Struct status - returns the status of the update with the following keys
		status - Did the content get updated
		msg - Error message if available
		data - Structure to return data
Arguments:
	String - elementName - the named element which content will be added for
	Struct - data - the data for the element
	Numeric - forceSubsiteID - DEPRECATED: We now get the SubsiteID dynamically since we know pageID.
	Numeric - forcePageID - If set this will override the pageID in the data.
	Boolean - forceLogout - Flag to keep the API session logged in for a continuous process. 
	String - forceControlName - Field to override the element control name from the config.
	Numeric - forceControlID - Field to override the element control name with the control ID.
History:
	2014-09-08 - GAC - Created 
					 - Added Global Custom Element Conduit Page Pool for using multiple conduit pages to increase performance
					 - Cleaned up the logic for passing in PageID and SubsiteID values via the data or using the Force Arguments 
					 - Removed the dependancy for setting a subsiteID in the config or passing in a ForceSubsiteID
--->
<cffunction name="populateCustom" access="public" returntype="struct" output="true">
	<cfargument name="elementName" type="string" required="true" hint="The name of the element from the CCAPI configuration">
	<cfargument name="data" type="struct" required="true" hint="Data for either the Texblock element or the Custom Element">
	<cfargument name="forceSubsiteID" type="numeric" required="false" default="-1" hint="DEPRECATED: We now get the SubsiteID dynamically since we know pageID.">
	<cfargument name="forcePageID" type="numeric" required="false" default="-1" hint="If set this will override the pageID in the data.">
	<cfargument name="forceLogout" type="boolean" required="false" default="true" hint="Flag to keep the API session logged in for a continuous process.">
	<cfargument name="forceControlName" type="string" required="false" default="" hint="Field to override the element control name from the config.">
	<cfargument name="forceControlID" type="numeric" required="false" default="-1" hint="Field to override the element control name with the control ID.">
	<cfargument name="forceUsername" type="string" required="false" default="" hint="Field to override the CCAPI username used to login to the conduit page.">
	<cfargument name="forcePassword" type="string" required="false" default="" hint="Field to override the password used to login to the conduit page."> 
	
	<cfscript>
		var apiConfig = "";
		var result = structNew();
		var logStruct = structNew();
		var logArray = arrayNew(1);
		var thisElementConfig = structNew();
		var contentStruct = structNew();
		var apiResponse = "";
		var loggingEnabled = true;
		var logFileName = "API_Element_populateCustom.log";
		var logErrorFileName = "API_Element_populateCustom_error.log";
		
		var csData = server.ADF.objectFactory.getBean("csdata_1_2");
		
		var runPopulateCustom = true;
		
		var usePagePool = false;
		var pagePoolRequestID = "";
		var poolPageReleased = false;
		var pagePoolRequestStart = "";
		var pagePoolRequestEndBy = "";
		var pagePoolRequestCurrentTime = "";
		
		var pagePoolParams = StructNew();
		var pagePoolMaxAttempts = 15;
		var pagePoolAttemptCount = 0;
		var pagePoolRequestWaitTime = variables.api.getRequestWaitTimeSetting(); //ms
		var pagePoolRequestTimeout = variables.api.getGlobalTimeoutSetting(); // seconds
		var pagePoolLogging = variables.api.getLoggingSetting();
		
		var pagePoolLog = StructNew();
		var pagePoolLogText = "";
		
		pagePoolLog.msg = "";
		pagePoolLog.logFile = "API_Element_populateCustom_pagepool.log";
		
		// Init the return data structure
		result.status = false;
		result.msg = "";
		result.data = StructNew();
		
		// Check the element is in the API Config file and defined		
		apiConfig = variables.api.getAPIConfig();
		
		// Set the logging flag
		if ( isStruct(apiConfig) AND StructKeyExists(apiConfig, "logging")
				AND StructKeyExists(apiConfig.logging, "enabled") AND IsBoolean(apiConfig.logging.enabled) )
			loggingEnabled = apiConfig.logging.enabled;
		else
			loggingEnabled = false;
		
		// Get the configuration options from the specific element node
		if ( isStruct(apiConfig) AND StructKeyExists(apiConfig, "elements") AND StructKeyExists(apiConfig.elements,arguments.elementName) )
			thisElementConfig = apiConfig.elements[arguments.elementName];
		
		// Check if the "forceControlName", "forceSubsiteID", and "forcePageID" arguments are defined, 
		// then setup the element config to bypass the config file.
		if ( arguments.forcePageID GT 0  AND ( LEN(TRIM(arguments.controlName)) OR arguments.controlID GT 0 ) )
		{
			// Override any value set from the config
			thisElementConfig['pageID'] = arguments.forcePageID;
			thisElementConfig['subsiteID'] = csData.getSubsiteIDByPageID(pageid=thisElementConfig['pageID']);
			thisElementConfig['elementType'] = "custom";
			
			// Check if we want to use the control name of control id
			if ( LEN(TRIM(arguments.forceControlName)) )
				thisElementConfig['controlName'] = arguments.forceControlName;
			else if ( arguments.forceControlID GT 0 )
				thisElementConfig['controlID'] = arguments.forceControlID;	
		}
		else if ( StructKeyExists( arguments.data,"pageID" ) AND IsNumeric(arguments.data.pageID) AND arguments.data.pageID GT 0 )
		{
			// Override with the PageID passed in from the arguments.data
			thisElementConfig["pageID"] = arguments.data.pageID;
			thisElementConfig['subsiteID'] = csData.getSubsiteIDByPageID(pageid=thisElementConfig['pageID']);
			thisElementConfig['elementType'] = "custom";
			
			// Check if controlName or the controlID were passed in via the data structure
			if ( StructKeyExists(arguments.data,"controlName") AND LEN(TRIM(arguments.data.controlName)) )
				thisElementConfig['controlName'] = arguments.data.controlName;
			else if ( StructKeyExists(arguments.data,"controlID") AND arguments.data.controlID GT 0 )
				thisElementConfig['controlID'] = arguments.data.controlID;	
		}
		else if ( isStruct(apiConfig) AND StructKeyExists(apiConfig, "elements") AND StructKeyExists(apiConfig.elements,arguments.elementName) ) 
		{		
			if ( StructKeyExists(thisElementConfig,"pageID") AND IsNumeric(thisElementConfig['pageID']) AND thisElementConfig['pageID'] GT 0 )	
				thisElementConfig["subsiteID"] = csData.getSubsiteIDByPageID(pageid=thisElementConfig['pageID']);
			
			// -- START - Page Pool Logic -- //	
			// If conduit pages are configured use the Page Pool system to get the conduit pageID for the request			
			if ( StructKeyExists(apiConfig.elements[arguments.elementName],"elementType") AND apiConfig.elements[arguments.elementName].elementType EQ "custom"
				AND StructKeyExists(apiConfig.elements[arguments.elementName],"gceConduitConfig") AND IsStruct(apiConfig.elements[arguments.elementName].gceConduitConfig) )
			{
				usePagePool = true;
				
				// Get the current Page Request and store it locally;
				//pagePoolRequestID = Request.ADF.apiPagePool.requestID;
				pagePoolRequestID = CreateUUID();
				pagePoolRequestStart = variables.API.pagePoolDateTimeFormat(Now());
				pagePoolRequestTimeout = variables.api.getElementConfigTimeout(CEconfigName=arguments.elementName);
				
				pagePoolRequestEndBy = DateAdd("s",pagePoolRequestTimeout,pagePoolRequestStart);
				
				
application.ADF.utils.doDUMP(pagePoolRequestID,"pagePoolRequestID");
application.ADF.utils.doDUMP(pagePoolRequestStart,"pagePoolRequestStart");
application.ADF.utils.doDUMP(pagePoolRequestEndBy,"pagePoolRequestEndBy");

				
				// Run REQUEST until a Conduit page becomes available
				while( true )
				{
					
					pagePoolParams = variables.api.getConduitPageFromPool(CEconfigName=arguments.elementName, requestID=pagePoolRequestID);

application.ADF.utils.doDUMP(pagePoolParams.pageID,"page Pool pageID");					
application.ADF.utils.doDUMP(pagePoolParams,"pagePoolParams");
application.ADF.utils.doDUMP(Application.ADF.apipool,"Application.ADF.apipool");
					
					if ( pagePoolLogging )
					{
						pagePoolLogText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - Conduit PageID Requested: #pagePoolParams.pageID#";
						pagePoolLog.msg = _apiLogMsgWrapper(logMsg=pagePoolLog.msg,logEntry=pagePoolLogText);
					}
					
					// check if slot in pool is returned
					if ( pagePoolParams.pageID neq 0 )
					{	
						thisElementConfig["pageID"]	= pagePoolParams.pageID;	
						thisElementConfig["subsiteID"] = pagePoolParams.subsiteID;
						thisElementConfig["controlID"] = variables.api.getCCAPIcontrolID(csPageID=pagePoolParams.pageID,formID=pagePoolParams.FormID);
						
						// TODO: set the control name
						thisElementConfig["controlName"] = "ccapiGCEPoolControl_#pagePoolParams.pageID#_#pagePoolParams.FormID#";
						 
						arguments.forceUsername = pagePoolParams.csuserid;
				 		arguments.forcePassword = variables.api.getConduitPoolPagePasswordFromAPIConfig(pageID=pagePoolParams.pageID);
						
						// If a valid pageID is returned the BREAK the WHILE loop
						break;	
					}
					else
					{
						
						pagePoolRequestCurrentTime = variables.API.pagePoolDateTimeFormat(Now());
						// Befroe Moving on Check to make sure the request has not timed out
						if ( DateCompare(pagePoolRequestCurrentTime,pagePoolRequestEndBy,"s") GTE 1 )
						{
							runPopulateCustom = false;
							if ( pagePoolLogging ) 
							{
								pagePoolLogText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - NO OPEN PAGE FOUND! Request Timed Out!!";
								pagePoolLog.msg = _apiLogMsgWrapper(logMsg=pagePoolLog.msg,logEntry=pagePoolLogText);
							}
							break;
						}
						
						
						if ( pagePoolLogging ) 
						{
							pagePoolLogText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - NO OPEN PAGE FOUND! Sleeping...";
							pagePoolLog.msg = _apiLogMsgWrapper(logMsg=pagePoolLog.msg,logEntry=pagePoolLogText);
						}
						
						// Wait for a page to be available from the conduit page pool
						sleep(pagePoolRequestWaitTime);	 //default:200
						
						if ( pagePoolLogging ) 
						{
							pagePoolLogText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - NO OPEN PAGE FOUND! Waking up to try again...";
							pagePoolLog.msg = _apiLogMsgWrapper(logMsg=pagePoolLog.msg,logEntry=pagePoolLogText);
						}
					}
					
					
					
					// Count the attempt to request a conduit page from the pool
					pagePoolAttemptCount = pagePoolAttemptCount + 1;
					
					// If the attempts are greater than the max attempts use the default conduit page (and get in line to WAIT)
					// ( DO WE KILL THE WHOLE REQUEST or DO WE USE DEFAULT CONDUIT PAGEID )
					if ( pagePoolAttemptCount GTE pagePoolMaxAttempts)
					{
						// Log the issue!!  
						runPopulateCustom = false;
						if ( pagePoolLogging ) 
						{
							pagePoolLogText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - Warning: Requested a Conduit Page #pagePoolAttemptCount# Times. Max Exceeded!";
							pagePoolLog.msg = _apiLogMsgWrapper(logMsg=pagePoolLog.msg,logEntry=pagePoolLogText);
						}
						break;
						
						//result.msg = pagePoolLog.msg;
						//return result;	
						
						// Use the default page and just wait inline like normal (OR DO WE KILL THE WHOLE REQUEST)
						//thisElementConfig["pageID"]	= apiConfig.elements[arguments.elementName].pageID;	
						//thisElementConfig["subsiteID"] = apiConfig.elements[arguments.elementName].subsiteID;
						//usePagePool = false;
						
						//pagePoolLogText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - Use Default Conduit Page: #thisElementConfig["pageID"]#";
						//pagePoolLog.msg = _apiLogMsgWrapper(logMsg=pagePoolLog.msg,logEntry=pagePoolLogText);
					}
				}	
			}
			// -- END - Page Pool Logic --//
			
		}
		else 
		{
			// Log the error message also
			if ( loggingEnabled ) 
			{
				logStruct.msg = "#request.formattedTimestamp# - Element [#arguments.elementName#] is not defined in the API Configuration.";
				logStruct.logFile = logErrorFileName;
				arrayAppend(logArray, logStruct);
				variables.utils.bulkLogAppend(logArray);
			}
			
			result.msg = "Element [#arguments.elementName#] is not defined in the API Configuration.
				arguments.forceSubsiteIDID = #arguments.forceSubsiteID# - 
				arguments.forcePageID = #arguments.forcePageID# - 
				arguments.forceControlID = #arguments.forceControlID#";
			
			return result;	
		}
		
		// Check that we are updating a custom element
		if( thisElementConfig["elementType"] NEQ "custom" )
		{
			if ( loggingEnabled ) 
			{
				// Log the error message also
				logStruct.msg = "#request.formattedTimestamp# - Element [#arguments.elementName#] is not defined as a custom element in the API Configuration.";
				logStruct.logFile = logErrorFileName;
				arrayAppend(logArray, logStruct);
				variables.utils.bulkLogAppend(logArray);
			}
			
			result.msg = "Element [#arguments.elementName#] is not defined as a custom element in the API Configuration.";
			return result;
		}
		
		// Construct REQUIRED keys for the content creation API
		contentStruct.subsiteID = thisElementConfig["subsiteID"];
		contentStruct.pageID = thisElementConfig["pageID"];
		
		// 2013-06-24 - Each check needs to be done separately.
		if ( StructKeyExists(thisElementConfig, "controlID") )
			contentStruct.controlID = thisElementConfig["controlID"];
			
		if ( StructKeyExists(thisElementConfig, "controlName") )
			contentStruct.controlName = thisElementConfig["controlName"];
		
		// If we find the option to submit change in the data
		if( StructKeyExists(arguments.data, "submitChange") )
			contentStruct.submitChange = arguments.data.submitChange;
		else
			contentStruct.submitChange = "1";
		
		// If we find the comment for the submission in the data struct
		if( StructKeyExists(arguments.data, "submitChangeComment") )
			contentStruct.submitChange_comment = arguments.data.submitChangeComment;
		else
			contentStruct.submitChange_comment = "Submit data for Custom element through API";
		
		// Following structure contains the data.  The structure keys are the 'field names'
		contentStruct.data = arguments.data;
		
application.ADF.utils.doDUMP(contentStruct,"contentStruct",true);
	</cfscript>
	
	<!--- LOCK to prevent multiple CCAPI calls to update 
			custom elements through a single CCAPI page.
			Prevents the "security-exception -- conflict" error message.
	 --->
	<cfif runPopulateCustom>
		<cflock type="exclusive" name="CCAPIPopulateContent-#Request.SiteID#-#contentStruct.pageID#" timeout="30">
			<cfscript>
				// Error handling
				try 
				{
					//pagePoolLogText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - Conduit PageID Used: #contentStruct.pageID#";
					//pagePoolLog.msg = _apiLogMsgWrapper(logMsg=pagePoolLog.msg,logEntry=pagePoolLogText);
				
					// Call the API to run the CCAPI Command
					if ( LEN(TRIM(arguments.forceUsername)) AND LEN(TRIM(arguments.forcePassword)) )
					{
				
						apiResponse = variables.api.runCCAPI(method="populateCustomElement",
															 sparams=contentStruct,
															 forceUserName=arguments.forceUsername,
															 forcePassword=arguments.forcePassword);
					}
					else
					{
						apiResponse = variables.api.runCCAPI(method="populateCustomElement",
															 sparams=contentStruct);			
					}
													 
	//application.ADF.utils.dodump(apiResponse,"apiResponse",false);

	//sleepTime = (RandRange(3,7)*1000);
	//application.ADF.utils.dodump(sleepTime,"Sleep Time",true);
	//sleep(sleepTime);

					// Check that the API ran
					if ( apiResponse.status )
					{	
						// Pass back the API return to the results
						result = apiResponse;
					
						// Log the success
						if ( listFirst(result.data, ":") eq "Success" )
						{
							logStruct.msg = "#request.formattedTimestamp# - Element Updated/Created: #thisElementConfig['elementType']# [#arguments.elementName#]. ContentUpdateResponse: #result.data#";
							logStruct.logFile = logFileName;
							arrayAppend(logArray, logStruct);
						
							if ( pagePoolLogging ) 
							{
								pagePoolLogText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - Success Populating Element...";
								pagePoolLog.msg = _apiLogMsgWrapper(logMsg=pagePoolLog.msg,logEntry=pagePoolLogText);
							}
						}
						else 
						{
							// Log the error message also
							result.msg = listRest(result.data, ":");
							logStruct.msg = "#request.formattedTimestamp# - Error updating element: #thisElementConfig['elementType']# [#arguments.elementName#]. Error recorded: #result.msg#";
							logStruct.logFile = logErrorFileName;
							arrayAppend(logArray, logStruct);
						
							if ( pagePoolLogging ) 
							{
								pagePoolLogText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - Error Populating Element...";
								pagePoolLog.msg = _apiLogMsgWrapper(logMsg=pagePoolLog.msg,logEntry=pagePoolLogText);
							}
						}
					}
					else 
					{
						// Error while running the API Command
						result = apiResponse;
						// Log the error message also
						logStruct.msg = "#request.formattedTimestamp# - Error [Message: #result.msg#]";
						if ( StructKeyExists(result.data, "detail") )
							logStruct.msg = logStruct.msg & " [Details: #result.data.detail#]";
						logStruct.logFile = logErrorFileName;
						arrayAppend(logArray, logStruct);
					}
				}
				catch ( ANY e )
				{
					// Error caught, send back the error message
					result.status = false;
					result.msg = e.message;
					result.data = e;
				
					// Log the error message also
					logStruct.msg = "#request.formattedTimestamp# - Error [Message: #e.message#] [Details: #e.detail#]";
					logStruct.logFile = logErrorFileName;
					arrayAppend(logArray, logStruct);
				}
			</cfscript>	
		</cflock>
	</cfif>
	
	<cfscript>
		if ( usePagePool )
		{
			poolPageReleased = variables.api.markRequestComplete(requestID=pagePoolRequestID);
			
			if ( pagePoolLogging )
			{
				if ( poolPageReleased )
					pagePoolLogText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - Conduit PageID Released: #contentStruct.pageID#";
				else
					pagePoolLogText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - Error: Issue releasing Conduit PageID: #contentStruct.pageID#";		
	
				pagePoolLog.msg = _apiLogMsgWrapper(logMsg=pagePoolLog.msg,logEntry=pagePoolLogText);
			}
			
			if ( pagePoolLogging )
				application.ADF.utils.logAppend(msg=pagePoolLog.msg,logfile=pagePoolLog.logFile);

application.ADF.utils.doDUMP(Application.ADF.apipool,"Application.ADF.apipool");

		}
		
		// Write the log files
		if ( loggingEnabled and arrayLen(logArray) )
			variables.utils.bulkLogAppend(logArray);
		
		// Check if we want to force the logout
		if ( arguments.forceLogout )
			variables.api.ccapiLogout();

		return result;
	</cfscript>
</cffunction>

<!---
	_apiLogMsgWrapper(logMsg,msg)
---->
<cffunction name="_apiLogMsgWrapper" access="private" output="false" hint="log Msg wrapper" returntype="string">
	<cfargument name="logMsg" required="false" type="string"  default="" hint="captured log text">
	<cfargument name="logEntry" required="false" type="string" default="" hint="new log entry">
	<cfscript>
		var timeStamp = "#DateFormat(Now(), 'yyyy-mm-dd')# #TimeFormat(Now(), 'HH:mm:ss.L')#";
		
		if ( LEN(TRIM(arguments.logEntry)) )
			return arguments.logMsg & CHR(13) & timeStamp & " - " & arguments.logEntry;
		else
			return arguments.logMsg & CHR(13) & timeStamp;
	</cfscript>
</cffunction>

</cfcomponent>