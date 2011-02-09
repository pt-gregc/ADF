<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2010.
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
	ajax_1_0.cfc
Summary:
	AJAX functions for the ADF Library
Version
	1.0.0
History:
	2011-01-26 - GAC - Created
--->
<cfcomponent displayname="ajax" extends="ADF.core.Base" hint="AJAX functions for the ADF Library">
	
<cfproperty name="version" value="1_0_0">
<cfproperty name="type" value="singleton">
<cfproperty name="csSecurity" type="dependency" injectedBean="csSecurity_1_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_1">
<cfproperty name="data" type="dependency" injectedBean="data_1_1">
<cfproperty name="wikiTitle" value="ajax_1_0">

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$buildAjaxProxyData
Summary:	
	Returns a struct which has a reString key whose value is string built from a method call
Returns:
	Struct
Arguments:
	none - only handle values found in the request.params struct
History:
	For full history see: /lib/ajax/ajaxProxy.cfm 
	2011-02-01 - GAC - Created - Copied the parameter and data processing code from ajaxProxy.cfm and moved it into this method
	2011-02-02 - GAC - Modified - fixed debug code conditional logic
								- Added proxyFile check to see if the method is being called from inside the proxy file
	2011-02-07 - RLW/GAC - Modified - Added a logic to check if the runCommand method call returns a query, if so, convert the query to an array of structs	
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<!--- // ATTENTION: 
		Do not call is method directly. Call from inside the AjaxProxy.cfm file (method properties are subject to change) 
--->
<cffunction name="buildAjaxProxyString" access="public" returntype="struct" hint="Returns a struct which has a reString key whose value is string built from a method call">
	<cfargument name="proxyFile" required="false" default="#CGI.SCRIPT_NAME#"><!--- // Must NOT be required so the Lightbox will display the error --->
	<cfscript>
		var local = StructNew();
		var hasCommandError = 0;
		var hasProcessingError = 0;
		var callingFileName = "ajaxProxy.cfm";
		var bean = "";
		var method = "";
		var appName = "";
		var returnFormat = "";
		var debug = 0;
		var params = StructNew();
		var args = StructNew();
		var debugRaw = "";
		var debugProcessed = "";
		var reDebugRaw = "";
		var reDebugProcessed = "";
		var passedSecurity = false;
		var json = '';
		var strFormatsList = "string,plain,html,text,txt";
		// list of parameters in request.params to exclude
		var argExcludeList = "bean,method,appName,addMainTable,returnFormat,debug";
		// initalize the reString key of the local struct
		local.reString = "";
		// set the flag that controls whether additional code is added to the reHTML output
		local.forceOutput = false;
		// Since we are relying on the request.params scope make sure the main params are available
		if ( StructKeyExists(request,"params") ) {
			params = request.params;
			if ( StructKeyExists(request.params,"bean") ) 
				bean = request.params.bean;
			if ( StructKeyExists(request.params,"method") ) 
				method = request.params.method;
			if ( StructKeyExists(request.params,"appName") ) 
				appName = request.params.appName;
			if ( StructKeyExists(request.params,"returnFormat") ) 
				returnFormat = request.params.returnFormat;
			if ( StructKeyExists(request.params,"debug") ) 
				debug = request.params.debug;
		}
		if ( arguments.proxyFile NEQ callingFileName ) {
			// Verify if the bean and method combo are allowed to be accessed through the ajax proxy
			passedSecurity = variables.csSecurity.validateProxy(bean,method);
			if ( passedSecurity )
			{
				// convert the params that are passed in to the args struct before passing them to runCommand method
				args = variables.utils.buildRunCommandArgs(request.params,argExcludeList);
				try 
				{
					// Run the Bean, Method and Args and get a return value
					local.reString = variables.utils.runCommand(trim(bean),trim(method),args,trim(appName));
				} 
				catch( Any e ) 
				{
					debug = 1;
					hasCommandError = 1; // try/catch thows and error skip the runCommand return data processing
					// Set Error output to the return String
					local.reString = e;
				}	
				// Build the DUMP for debugging the RAW value of local.reString
				if ( debug ) {
					// If the variable local.reString doesn't exist set the debug output to the string: void 
					if ( !StructKeyExists(local,"reString") ){debugRaw="void";}else{debugRaw=local.reString;}
					reDebugRaw = variables.utils.doDump(debugRaw,"RAW OUTPUT",1,1);
				}
				// if runCommand throws an error skip processing jump down to the debug output
				if ( !hasCommandError ) 
				{
					// Check to see if local.reString was destroyed by a method that returns void before attempting to process the return
					if ( StructKeyExists(local,"reString") ) 
					{
						// Convert Query to an Array of Structs for Processing
						if ( IsQuery(local.reString) ) 
						{
							local.reString = variables.data.queryToArrayOfStructures(local.reString,true);
							if ( !isArray(local.reString) ) 
							{
								hasProcessingError = 1; 
								returnFormat = "plain";
								// set forceOutput to true to allow error string to be displayed in the ADFLightbox
								local.forceOutput = true; // for legacy lightbox calls
								local.reString = "Error: unable to convert the return query to an array of structures";
							} 
						}
						// if JSON is set as the returnFormat convert return data to an JSON
						if ( returnFormat eq "json" )
						{
							json = server.ADF.objectFactory.getBean("json");
							// when jsonp calls are made there will be a variable called "jsonpCallback" it will
							// represent the method in the caller to be executed - wrap the content in that function call
							if( structKeyExists(request.params, "jsonpCallback") )
								local.reString = "#request.params.jsonpCallback#(" & json.encode(local.reString) & ");";
							else 
							{
								local.reString = json.encode(local.reString);
								if ( !IsJSON(local.reString) ) 
								{
									hasProcessingError = 1; 
									// set forceOutput to true to allow error string to be displayed in the ADFLightbox
									local.forceOutput = true; // for legacy lightbox calls
									local.reString = "Error: unable to convert the return value to json";
								}
							}	
						}
						else if ( returnFormat eq "xml" )
						{
							// convert return data to XML using CS internal serialize function
							local.reString = Server.CommonSpot.MapFactory.serialize(local.reString,"data",0); //Server.CommonSpot.MapFactory.serialize(Arguments.bean,Arguments.tagName,JavaCast("boolean",Arguments.forceLCase));
							// make return is an XML string
							if ( IsXML(local.reString) ) 
								local.reString = XmlParse(local.reString);
							if ( !IsXmlDoc(local.reString) ) 
							{
								hasProcessingError = 1; 
								// set forceOutput to true to allow error string to be displayed in the ADFLightbox
								local.forceOutput = true; // for legacy lightbox calls
								local.reString = "Error: unable to convert the return value to xml";
							}
						}
						if ( isStruct(local.reString) or isArray(local.reString) or isObject(local.reString) ) 
						{
							hasProcessingError = 1; 
							// set forceOutput to true to allow error string to be displayed in the ADFLightbox
							local.forceOutput = true; // for legacy lightbox calls
							local.reString = "Error: unable to convert the return value to a string";
						}
					}
					else
					{
						// The method call returned void and destroyed the local.reString variable
						hasProcessingError = 0;  // returning void is not considered an error
						// local.reString = "Error: return value came back as 'void'"; 
					}
				}
			}
			else
			{
				hasProcessingError = 1; 
				// set forceOutput to true to allow error string to be displayed in the ADFLightbox
				local.forceOutput = true; // for legacy lightbox calls
				if ( len(trim(appName)) )
					local.reString = "Error: The Bean: #bean# with method: #method# in the App: #appName# is not accessible remotely via Ajax Proxy.";	
				else
					local.reString = "Error: The Bean: #bean# with method: #method# is not accessible remotely via Ajax Proxy.";	
			}
			// build the dump for debugging the Processed value of local.reString
			if ( debug AND passedSecurity AND ListFindNoCase(strFormatsList,returnformat) EQ 0 ) 
			{
				// If the variable reHTML doesn't exist set the debug output to the string: void 
				if ( !StructKeyExists(local,"reString") ){debugProcessed="void";}else{debugProcessed=local.reString;}
				reDebugProcessed = variables.utils.doDump(debugProcessed,"PROCESSED OUTPUT",1,1);
			}
			// pass the debug dumps to the reHTML for output
			if ( debug ) 
			{
				// set forceOutput to true to allow the debug dump to be displayed in the ADFLightbox
				local.forceOutput = true; // for legacy lightbox calls
				if ( hasCommandError OR (IsSimpleValue(debugRaw) AND debugRaw EQ "void") )
				{
					// if runCommand has error, return only the first DUMP which contains the CATCH info
					local.reString = reDebugRaw;
				}
				else if ( hasProcessingError ) 
				{
					// if processing has an error, return the processing error and the first DUMP
					local.reHTML = local.reString & reDebugRaw;
				} 
				else
				{
					// for a debug with no errors, return both the runCommand DUMP and the processing DUMP
					local.reString = reDebugRaw & reDebugProcessed;
				}
			}
		} else {
			// set forceOutput to true to allow error string to be displayed in the ADFLightbox
			local.forceOutput = true; // for legacy lightbox calls
			local.reString = "Error: This method can not be called directly. Use the AjaxProxy.cfm file.";	
		}
		return local;
	</cfscript>
</cffunction>

</cfcomponent>