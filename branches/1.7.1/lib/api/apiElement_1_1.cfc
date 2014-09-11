<cfcomponent displayname="apiElement_1_1" extends="ADF.lib.api.apiElement_1_0" hint="">

<cfproperty name="version" value="1_1_0">
<cfproperty name="api" type="dependency" injectedBean="api_1_1">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">
<cfproperty name="wikiTitle" value="API Elements">

<cffunction name="populateCustom" access="public" returntype="struct" output="true">
	<cfargument name="elementName" type="string" required="true" hint="The name of the element from the CCAPI configuration">
	<cfargument name="data" type="struct" required="true" hint="Data for either the Texblock element or the Custom Element">
	<cfargument name="forceSubsiteID" type="numeric" required="false" default="-1" hint="If set this will override the subsiteID in the data.">
	<cfargument name="forcePageID" type="numeric" required="false" default="-1" hint="If set this will override the pageID in the data.">
	<cfargument name="forceLogout" type="boolean" required="false" default="true" hint="Flag to keep the API session logged in for a continuous process.">
	<cfargument name="forceControlName" type="string" required="false" default="" hint="Field to override the element control name from the config.">
	<cfargument name="forceControlID" type="numeric" required="false" default="-1" hint="Field to override the element control name with the control ID.">
	
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
		
		var usePagePool = false;
		var pagePoolRequestID = "";
		var poolPageReleased = false;
		var pagePoolParams = StructNew();
		var pagePoolMaxAttempts = 5;
		var pagePoolAttemptCount = 0;
		
		var debugStruct = StructNew();
		var debugArray = ArrayNew(1);
		var debugText = "";
		
		debugStruct.msg = "";
		debugStruct.logFile = "API_Element_populateCustom_pagepool.log";
		//debugStruct.logFile2 = "API_Element_populateCustom_pagepool2.log";
		
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
		
		
		// Check if the "forceControlName", "forceSubsiteID", and "forcePageID" arguments are defined, 
		// then setup the element config to bypass the config file.
		if ( arguments.forceSubsiteID neq -1 AND arguments.forcePageID neq -1 AND (LEN(arguments.forceControlName) OR arguments.forceControlID neq -1) )
		{
			thisElementConfig['subsiteID'] = arguments.forceSubsiteID;
			thisElementConfig['pageID'] = arguments.forcePageID;
			thisElementConfig['elementType'] = "custom";
			
			// Check if we want to use the control name of control id
			if ( LEN(arguments.forceControlName) )
				thisElementConfig['controlName'] = arguments.forceControlName;
			else if ( arguments.forceControlID neq -1 )
				thisElementConfig['controlID'] = arguments.forceControlID;
		}
		else if ( isStruct(apiConfig) AND StructKeyExists(apiConfig, "elements") AND StructKeyExists(apiConfig.elements,arguments.elementName) ) 
		{
			// set up local variable for the element
			thisElementConfig = apiConfig.elements[arguments.elementName];
			
			// If there is no subsite default to 1
			if( !StructKeyExists(thisElementConfig,"subsiteID") )
				thisElementConfig["subsiteID"] = 1;
			
			// -- START - Page Pool Logic --//	
			// If conduit pages are configured use the Page Pool system to get the conduit pageID for the request
			if ( StructKeyExists(thisElementConfig,"conduitPoolIDlist") AND LEN(TRIM(thisElementConfig.conduitPoolIDlist)) )
			{
				usePagePool = true;
				// Get the current Page Request and store it locally;
				//pagePoolRequestID = Request.ADF.apiPagePool.requestID;
				pagePoolRequestID = CreateUUID();
				
application.ADF.utils.doDUMP(pagePoolRequestID,"pagePoolRequestID");
				
				// Run REQUEST until a Conduit page becomes available
				while( true )
				{
					
					pagePoolParams = variables.api.getConduitPageFromPool(CEconfigName=arguments.elementName, requestID=pagePoolRequestID);
					
application.ADF.utils.doDUMP(pagePoolParams.pageID,"pagePoolPageID");
application.ADF.utils.doDUMP(Application.ADF.apipool,"Application.ADF.apipool");
					
					debugText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - Conduit PageID Requested: #pagePoolParams.pageID#";
					debugStruct.msg = _apiLogMsgWrapper(logMsg=debugStruct.msg,logEntry=debugText);
					
//debugText = _apiLogMsgWrapper(logMsg="",logEntry=debugText);
//application.ADF.utils.logAppend(msg=debugText,logfile=debugStruct.logFile2);
					
					// check if slot in pool is returned
					if( pagePoolParams.pageID neq 0 )
					{	
						thisElementConfig["pageID"]	= pagePoolParams.pageID;	
						thisElementConfig["subsiteID"] = pagePoolParams.subsiteID;
						
						// If a valid pageID is returned the BREAK the WHILE loop
						break;	
					}
					else
					{
						debugText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - NO OPEN PAGE FOUND! Sleeping...";
						debugStruct.msg = _apiLogMsgWrapper(logMsg=debugStruct.msg,logEntry=debugText);
						
//debugText = _apiLogMsgWrapper(logMsg="",logEntry=debugText);
//application.ADF.utils.logAppend(msg=debugText,logfile=debugStruct.logFile2);
						
						// Wait for a page to be available from the conduit page pool
						sleep(200);	
						
						debugText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - NO OPEN PAGE FOUND! Waking up to try again...";
						debugStruct.msg = _apiLogMsgWrapper(logMsg=debugStruct.msg,logEntry=debugText);
						
//debugText = _apiLogMsgWrapper(logMsg="",logEntry=debugText);
//application.ADF.utils.logAppend(msg=debugText,logfile=debugStruct.logFile2);
					}
					
					
					pagePoolAttemptCount = pagePoolAttemptCount + 1;
					
					if ( pagePoolAttemptCount GTE pagePoolMaxAttempts)
					{
						// Log the issue!!  (or DO WE KILL THE WHOLE REQUEST or DO WE SET TO USE DEFAULT CONDUIT PAGEID)
						debugText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - Warning: Requested a Conduit Page #pagePoolAttemptCount# Times. Max Exceeded!";
						debugStruct.msg = _apiLogMsgWrapper(logMsg=debugStruct.msg,logEntry=debugText);

//debugText = _apiLogMsgWrapper(logMsg="",logEntry=debugText);
//application.ADF.utils.logAppend(msg=debugText,logfile=debugStruct.logFile2);
						
						//result.msg = debugStruct.msg;
						//return result;	
						
						// Use the default page (OR DO WE KILL THE WHOLE REQUEST)
						//thisElementConfig["pageID"]	= apiConfig.elements[arguments.elementName].pageID;	
						//thisElementConfig["subsiteID"] = apiConfig.elements[arguments.elementName].subsiteID;
						//usePagePool = false;
						
						//debugText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - Use Default Conduit Page: #thisElementConfig["pageID"]#";
						//debugStruct.msg = _apiLogMsgWrapper(logMsg=debugStruct.msg,logEntry=debugText);
						
						//break;
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
				arguments.forceControlID = #arguments.forceControlID#apiConfig";
			
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
		
//WHAT??
//if ( StructKeyExists(arguments.data, "pageID") OR StructKeyExists(arguments.data, "subsiteID") )

/* 
	// If they forced the subsite ID, then set in the config
	if (arguments.forceSubsiteID neq -1)
	{
		thisElementConfig["subsiteID"] = arguments.forceSubsiteID;
	} 
	else if ( StructKeyExists(arguments.data, "subsiteID"))
	{
		//Otherwise check to see if subsiteID has been passed into data (signifying a local custom element)
		thisElementConfig["subsiteID"] = arguments.data.subsiteID;
	}
	
	// If they forced the page ID, then set in the config
	if (arguments.forcePageID neq -1)
	{
		thisElementConfig["pageID"] = arguments.forcePageID;
	} 
	else if ( StructKeyExists(arguments.data, "pageID") )
	{
		//Otherwise check to see if the data passed in for this element contains "pageID"
		thisElementConfig["pageID"] = arguments.data.pageID;
	}
*/
		
		// Construct specific data for the content creation API
		contentStruct.subsiteID = thisElementConfig["subsiteID"];
		contentStruct.pageID = thisElementConfig["pageID"];
		
		// 2013-06-24 - Each check needs to be done separately.
		if( StructKeyExists(thisElementConfig, "controlID") )
			contentStruct.controlID = thisElementConfig["controlID"];
			
		if( StructKeyExists(thisElementConfig, "controlName") )
			contentStruct.controlName = thisElementConfig["controlName"];
			
//WHAT??	
// 2013-06-24 - Override the config control name based on the argument
//if ( LEN(arguments.forceControlName) )
//	contentStruct.controlName = arguments.forceControlName;
			
// 2013-06-24 - Override the config control ID based on the argument
//if ( arguments.forceControlID neq -1 )
//	contentStruct.controlID = arguments.forceControlID;
		
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
	</cfscript>
	
	<!--- LOCK to prevent multiple CCAPI calls to update 
			custom elements through a single CCAPI page.
			Prevents the "security-exception -- conflict" error message.
	 --->
	<cflock type="exclusive" name="CCAPIPopulateContent-#contentStruct.pageID#" timeout="30">
		<cfscript>
			// Error handling
			try 
			{
				//debugText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - Conduit PageID Used: #contentStruct.pageID#";
				//debugStruct.msg = _apiLogMsgWrapper(logMsg=debugStruct.msg,logEntry=debugText);
				
				// Call the API to run the CCAPI Command
				apiResponse = variables.api.runCCAPI(method="populateCustomElement",
													 sparams=contentStruct);
													 
//application.ADF.utils.dodump(apiResponse,"apiResponse",false);
			
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
					}
					else 
					{
						// Log the error message also
						result.msg = listRest(result.data, ":");
						logStruct.msg = "#request.formattedTimestamp# - Error updating element: #thisElementConfig['elementType']# [#arguments.elementName#]. Error recorded: #result.msg#";
						logStruct.logFile = logErrorFileName;
						arrayAppend(logArray, logStruct);
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
	
	<cfscript>
		if ( usePagePool )
		{
			poolPageReleased = variables.api.markRequestComplete(CEconfigName=arguments.elementName,requestID=pagePoolRequestID);
			
			if ( poolPageReleased )
				debugText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - Conduit PageID Released: #contentStruct.pageID#";
			else
				debugText = "Element [#arguments.elementName#] RequestID: #pagePoolRequestID# - Error: Issue releasing Conduit PageID: #contentStruct.pageID#";		

			debugStruct.msg = _apiLogMsgWrapper(logMsg=debugStruct.msg,logEntry=debugText);
			
			application.ADF.utils.logAppend(msg=debugStruct.msg,logfile=debugStruct.logFile);

//debugText = _apiLogMsgWrapper(logMsg="",logEntry=debugText);
//application.ADF.utils.logAppend(msg=debugText,logfile=debugStruct.logFile2);

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