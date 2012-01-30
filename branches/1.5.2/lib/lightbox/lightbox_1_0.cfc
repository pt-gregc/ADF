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
	lightbox_1_0.cfc
Summary:
	Lightbox functions for the ADF Library
Version
	1.0.0
History:
	2011-01-26 - GAC - Created
	2011-10-04 - GAC - Updated csSecurity dependency to csSecurity_1_1
	2012-01-30 - MFC - Updated the wikiTitle cfproperty.
--->
<cfcomponent displayname="lightbox" extends="ADF.core.Base" hint="Lightbox functions for the ADF Library">
	
<cfproperty name="version" value="1_0_1">
<cfproperty name="type" value="singleton">
<cfproperty name="csSecurity" type="dependency" injectedBean="csSecurity_1_1">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_1">
<cfproperty name="data" type="dependency" injectedBean="data_1_1">
<cfproperty name="wikiTitle" value="lightbox_1_0">

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$buildLightboxProxyHTML
Summary:	
	Returns a HTML string for content that displays inside an ADF lightbox 
Returns:
	String
Arguments:
	none - only handle values found in the request.params struct
History:
	2011-01-19 - GAC - Created
	2011-01-30 - RLW/GAC - Added a new parameter that allows commands to be run from ADF applications
	2011-02-01 - GAC - Modified - Removed the args processing code and replaced it with a call to the utils_1_1 buildRunCommandArgs method
								- Changed the method name to buildLightboxProxyHTML
								- Removed the arguments: params to restrict processing to only the values found in the request.params struct
								- Updated the proxyWhiteList error to include the appName
	2011-02-02 - GAC - Modified - Added proxyFile check to see if the method is being called from inside the proxy file
	2011-02-09 - GAC - Modified - renamed the 'local' variable to 'result' since local is a reserved word in CF9
	2011-10-03 - MFC - Modified - Added check to return the CFCATCH error message.
--->
<!--- // ATTENTION: 
		Do not call is method directly. Call from inside the LightboxProxy.cfm file  (method properties are subject to change)
--->
<cffunction name="buildLightboxProxyHTML" access="public" returntype="string" hint="Returns a HTML string for content that displays inside an ADF lightbox">
	<cfargument name="proxyFile" required="false" default="#CGI.SCRIPT_NAME#" hint="Proxyfile to load lightbox proxy from"><!--- // Must NOT be required so the Lightbox will display the error --->
	<cfscript>
		var hasError = 0;
		var callingFileName = "lightboxProxy.cfm";
		var bean = "";
		var method = "";
		var appName = "";
		var params = StructNew();
		var debug = 0;
		var result = StructNew();
		var reDebugRaw = "";
		var args = StructNew();
		// list of parameters in request.params to exclude
		var argExcludeList = "bean,method,appName,forceScripts,addLBHeaderFooter,addMainTable,debug";
		// Verify if the bean and method combo are allowed to be accessed through the ajax proxy
		var passedSecurity = false;
		// Initalize the reHTML key of the local struct
		result.reHTML = "";
		// Since we are relying on the request.params scope make sure the key params are available
		if ( StructKeyExists(request,"params") ) {
			params = request.params;
			if ( StructKeyExists(request.params,"bean") ) 
				bean = request.params.bean;
			if ( StructKeyExists(request.params,"method") ) 
				method = request.params.method;
			if ( StructKeyExists(request.params,"appName") ) 
				appName = request.params.appName;
			if ( StructKeyExists(request.params,"debug") ) 
				debug = request.params.debug;
		}
		if ( arguments.proxyFile NEQ callingFileName ) {
			// Verify if the bean and method combo are allowed to be accessed through the lightbox proxy
			passedSecurity = variables.csSecurity.validateProxy(bean, method);
			if ( passedSecurity )
			{
				// convert the params that are passed in to the args struct before passing them to runCommand method
				args = variables.utils.buildRunCommandArgs(params,argExcludeList);
				try 
				{
					// Run the Bean, Method and Args and get a return value
					result.reHTML = variables.utils.runCommand(trim(bean),trim(method),args,trim(appName));
				} 
				catch( Any e ) 
				{
					hasError = 0; // if set to true, this will output the error html twice, so let debug handle it
					debug = 1;
					result.reHTML = e;
				}	
				// Build the DUMP for debugging the RAW value of reHTML
				if ( debug ) {
					// If the variable reHTML doesn't exist set the debug output to the string: void 
					if ( !StructKeyExists(result,"reHTML") ){reDebugRaw="void";}else{reDebugRaw=result.reHTML;}
					reDebugRaw = variables.utils.doDump(reDebugRaw,"DEBUG OUTPUT",1,1);
				}
				
				// Check to see if reHTML was destroyed by a method that returns void before attempting to process the return
				if ( StructKeyExists(result,"reHTML") ) 
				{
					// 2011-10-03 - MFC - Determine if the result has a CF Error Structure, return CFCATCH error message
					if ( isObject(result.reHTML) 
							AND structKeyExists(result.reHTML,"message") 
							AND structKeyExists(result.reHTML,"ErrNumber") 
							AND structKeyExists(result.reHTML,"StackTrace") ) {
						hasError = 1;
						result.reHTML = "Error: " & result.reHTML.message;
					}
					else if ( isStruct(result.reHTML) or isArray(result.reHTML) or isObject(result.reHTML) ) 
					{
						hasError = 1;
						result.reHTML = "Error: unable to convert the return value into string";
					}
				}
				else
				{
					// The method call returned void and destroyed the result.reHTML variable
					hasError = 1;
					result.reHTML = "Error: return value came back as 'void'"; 
				}
			}
			else
			{
				// Show error since the bean and/or method are not in the proxyWhiteList.xml file
				hasError = 1;
				if ( len(trim(appName)) )
					result.reHTML = "Error: The Bean: #bean# with method: #method# in the App: #appName# is not accessible remotely via Lightbox Proxy.";	
				else
					result.reHTML = "Error: The Bean: #bean# with method: #method# is not accessible remotely via Lightbox Proxy.";	
			}
			// pass the debug dumps to the result.reHTML for output
			if ( debug ) 
			{
				if ( hasError )
					result.reHTML = result.reHTML & reDebugRaw;
				else
					result.reHTML = reDebugRaw;
			}
		} 
		else 
		{
			result.reHTML = "Error: This method can not be called directly. Use the AjaxProxy.cfm file.";	
		}
		return result.reHTML;
	</cfscript>
</cffunction>

</cfcomponent>