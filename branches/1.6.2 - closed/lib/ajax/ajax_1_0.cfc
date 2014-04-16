<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
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
	1.0
History:
	2011-01-26 - GAC - Created
	2011-10-04 - GAC - Updated csSecurity dependency to csSecurity_1_1
	2013-11-18 - GAC - Updated the lib dependencies to csSecurity_1_2, utils_1_2, data_1_2
--->
<cfcomponent displayname="ajax" extends="ADF.core.Base" hint="AJAX functions for the ADF Library">
	
<cfproperty name="version" value="1_0_7">
<cfproperty name="type" value="singleton">
<cfproperty name="csSecurity" type="dependency" injectedBean="csSecurity_1_2">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">
<cfproperty name="data" type="dependency" injectedBean="data_1_2">
<cfproperty name="wikiTitle" value="ajax_1_0">

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$buildAjaxProxyString
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
	2011-02-09 - GAC - Modified - renamed the 'local' variable to 'result' since local is a reserved word in CF9
	2011-02-09 - GAC - Removed ADFlightbox specific forceOutput variable
	2012-03-08 - MFC - Added the cfcatch error message to the default error message display.
	2012-03-12 - GAC - Added logic to the reString error struct to check if a message key was returned
	2013-10-18 - MS  - Updated to comment out the verbose error messages which caused security issues
	2013-10-19 - GAC - Updated to use application.ADF.siteDevMode to control the verbose error msgs 
--->
<!--- // ATTENTION: 
		Do not call is method directly. Call from inside the AjaxProxy.cfm file (method properties are subject to change) 
--->
<cffunction name="buildAjaxProxyString" access="public" returntype="struct" hint="Returns a struct which has a reString key whose value is string built from a method call">
	<cfargument name="proxyFile" required="false" default="#CGI.SCRIPT_NAME#" hint="Proxyfile to build the proxy string from"><!--- // Must NOT be required so the Lightbox will display the error --->
	<cfscript>
		var result = StructNew();
		var hasCommandError = 0;
		var hasProcessingError = 0;
		var callingFileName = "ajaxProxy.cfm";
		var bean = "";
		var method = "";
		var appName = "";
		var returnFormat = "";
		var debug = 0;
		var query2array = 1; //default is true for backwards compatiblity
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
		// initalize the reString key of the result struct
		result.reString = "";
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
			if ( StructKeyExists(request.params,"query2array") ) 
				query2array = request.params.query2array;
		}
		if ( arguments.proxyFile NEQ callingFileName ) {
			// Verify if the bean and method combo are allowed to be accessed through the ajax proxy
			passedSecurity = variables.csSecurity.validateProxy(bean,method);
			if ( passedSecurity ) {
				// convert the params that are passed in to the args struct before passing them to runCommand method
				args = variables.utils.buildRunCommandArgs(request.params,argExcludeList);
				try {
					// Run the Bean, Method and Args and get a return value
					result.reString = variables.utils.runCommand(trim(bean),trim(method),args,trim(appName));
				} 
				catch( Any e ) {
					debug = 1;
					hasCommandError = 1; // try/catch thows and error skip the runCommand return data processing
					// Set Error output to the return String
					result.reString = e;
				}	
				// Build the DUMP for debugging the RAW value of result.reString
				if ( debug AND application.ADF.siteDevMode ) {
					// If the variable result.reString doesn't exist set the debug output to the string: void 
					if ( !StructKeyExists(result,"reString") ){debugRaw="void";}else{debugRaw=result.reString;}
						reDebugRaw = variables.utils.doDump(debugRaw,"RAW OUTPUT",1,1);
				}
				// if runCommand throws an error skip processing jump down to the debug output
				if ( !hasCommandError ) {
					// Check to see if result.reString was destroyed by a method that returns void before attempting to process the return
					if ( StructKeyExists(result,"reString") ) {
						// Convert Query to an Array of Structs for Processing
						if ( IsQuery(result.reString) AND query2array EQ 1 ) {
							result.reString = variables.data.queryToArrayOfStructures(result.reString,true);
							if ( !isArray(result.reString) ) {
								hasProcessingError = 1; 
								returnFormat = "plain";
								result.reString = "Error: unable to convert the return query to an array of structures";
							} 
						}
						// if JSON is set as the returnFormat convert return data to an JSON
						if ( returnFormat eq "json" ) {
							json = server.ADF.objectFactory.getBean("json");
							// when jsonp calls are made there will be a variable called "jsonpCallback" it will
							// represent the method in the caller to be executed - wrap the content in that function call
							if( structKeyExists(request.params, "jsonpCallback") )
								result.reString = "#request.params.jsonpCallback#(" & json.encode(result.reString) & ");";
							else {
								result.reString = json.encode(result.reString);
								if ( !IsJSON(result.reString) ) {
									hasProcessingError = 1; 
									result.reString = "Error: unable to convert the return value to json";
								}
							}	
						}
						else if ( returnFormat eq "xml" ) {
							// convert return data to XML using CS internal serialize function
							result.reString = server.CommonSpot.UDF.util.serializeBean(result.reString,"data",0); //server.CommonSpot.UDF.util.serializeBean(Arguments.bean,Arguments.tagName,JavaCast("boolean",Arguments.forceLCase));
							// make return is an XML string
							if ( IsXML(result.reString) ) 
								result.reString = XmlParse(result.reString);
							if ( !IsXmlDoc(result.reString) ) {
								hasProcessingError = 1; 
								result.reString = "Error: unable to convert the return value to xml";
							}
						}
						if ( isStruct(result.reString) or isArray(result.reString) or isObject(result.reString) ) {
							hasProcessingError = 1; 
							// 2012-03-10 - GAC - we need to check if we have a 'message' before we can output it
							if ( StructKeyExists(result.reString,"message") AND application.ADF.siteDevMode )
								result.reString = "Error: Unable to convert the return value into string. [" & result.reString.message & "]";
							else
								result.reString = "Error: Unable to convert the return value into string.";
						}
					}
					else {
						// The method call returned void and destroyed the result.reString variable
						hasProcessingError = 0;  // returning void is not considered an error
						// result.reString = "Error: return value came back as 'void'"; 
					}
				}
			}
			else {
				hasProcessingError = 1; 
				if ( !application.ADF.siteDevMode ) {
					result.reString = "Error: The request is not accessible remotely via Ajax Proxy.";
					// TODO: Do Proxy Logging				
				}
				else {
					if ( len(trim(appName)) )
						result.reString = "Error: The Bean: #bean# with method: #method# in the App: #appName# is not accessible remotely via Ajax Proxy.";	
					else
						result.reString = "Error: The Bean: #bean# with method: #method# is not accessible remotely via Ajax Proxy.";	
				}
			}
			// build the dump for debugging the Processed value of result.reString
			if ( debug AND application.ADF.siteDevMode AND passedSecurity AND ListFindNoCase(strFormatsList,returnformat) EQ 0 ) {
				// If the variable reHTML doesn't exist set the debug output to the string: void 
				if ( !StructKeyExists(result,"reString") ){debugProcessed="void";}else{debugProcessed=result.reString;}
					reDebugProcessed = variables.utils.doDump(debugProcessed,"PROCESSED OUTPUT",1,1);
			}
			// pass the debug dumps to the reHTML for output
			if ( debug AND application.ADF.siteDevMode ) {
				if ( hasCommandError OR (IsSimpleValue(debugRaw) AND debugRaw EQ "void") ) {
					// if runCommand has error, return only the first DUMP which contains the CATCH info
					result.reString = reDebugRaw;
				}
				else if ( hasProcessingError ) {
					// if processing has an error, return the processing error and the first DUMP
					result.reHTML = result.reString & reDebugRaw;
				} 
				else {
					// for a debug with no errors, return both the runCommand DUMP and the processing DUMP
					result.reString = reDebugRaw & reDebugProcessed;
				}
			}
		} 
		else {
			result.reString = "Error: This method can not be called directly. Use the AjaxProxy.cfm file.";	
		}
		return result;
	</cfscript>
</cffunction>

</cfcomponent>