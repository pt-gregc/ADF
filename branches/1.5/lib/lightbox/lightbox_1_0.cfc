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
--->
<cfcomponent displayname="lightbox" extends="ADF.core.Base" hint="Lightbox functions for the ADF Library">
	
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
	$buildLightboxHTML
Summary:	
	Returns HTML for the CS 6.x lightbox header (use with the lightboxFooter)
Returns:
	String
Arguments:
	struct params - Structure of parameters for the specified call
History:
	2011-01-19 - GAC - Created
	2011-01-28 - GAC - Modified - Removed the parameter isForm and added the parameter for tdClass so CSS classes can be added to the inner TD of the lightBox header
	2011-01-30 - RLW/GAC - Added a new parameter that allows commands to be run from ADF applications
	2011-02-01 - GAC - Modified - Removed the args processing code and replaced it with a call to the utils_1_1 buildRunCommandArgs method
--->
<cffunction name="buildLightboxHTML" access="public" returntype="string" hint="Runs the given command">
	<cfargument name="params" type="struct" required="false" default="#StructNew()#" hint="Structure of parameters for the specified call">
	<cfscript>
		var hasError = 0;
		var local = StructNew();
		var reDebugRaw = "";
		var args = StructNew();
		// list of parameters in request.params to exclude
		var argExcludeList = "bean,method,appName,forceScripts,addLBHeaderFooter,addMainTable,debug";
		// set the flag for if we have a serialized form to pass to the function as a structure 
		var containsSerializedForm = false;
		// Verify if the bean and method combo are allowed to be accessed through the ajax proxy
		var passedSecurity = Application.ADF.csSecurity.validateProxy(arguments.params.bean, arguments.params.method);
		// Initalize the reHTML key of the local struct
		local.reHTML = "";
		if ( passedSecurity )
		{
			// convert the params that are passed in to the args struct before passing them to runCommand method
			args = application.ADF.utils.buildRunCommandArgs(arguments.params,argExcludeList);
			try 
			{
				// Run the Bean, Method and Args and get a return value
				local.reHTML = application.ADF.utils.runCommand(trim(arguments.params.bean),trim(arguments.params.method),args,trim(arguments.params.appName));
			} 
			catch( Any e ) 
			{
				hasError = 0; // if set to true, this will output the error html twice, so let debug handle it
				arguments.params.debug = 1;
				local.reHTML = e;
			}	
			// Build the DUMP for debugging the RAW value of reHTML
			if ( arguments.params.debug ) {
				// If the variable reHTML doesn't exist set the debug output to the string: void 
				if ( !StructKeyExists(local,"reHTML") ){reDebugRaw="void";}else{reDebugRaw=local.reHTML;}
				reDebugRaw = Application.ADF.utils.doDump(reDebugRaw,"DEBUG OUTPUT",1,1);
			}
			// Check to see if reHTML was destroyed by a method that returns void before attempting to process the return
			if ( StructKeyExists(local,"reHTML") ) 
			{
				if ( isStruct(local.reHTML) or isArray(local.reHTML) or isObject(local.reHTML) ) 
				{
					hasError = 1;
					local.reHTML = "Error: unable to convert the return value into string";
				}
			}
			else
			{
				// The method call returned void and destroyed the local.reHTML variable
				hasError = 1;
				local.reHTML = "Error: return value came back as 'void'"; 
			}
		}
		else
		{
			// Show error since the bean and/or method are not in the proxyWhiteList.xml file
			hasError = 1;
			local.reHTML = "Error: The Bean: #arguments.params.bean# with method: #arguments.params.method# is not accessible remotely via Lightbox Proxy.";	
		}
		// pass the debug dumps to the reData.htmlStr for output
		if ( arguments.params.debug ) 
		{
			if ( hasError )
				local.reHTML = local.reHTML & reDebugRaw;
			else
				local.reHTML = reDebugRaw;
		}
		return local.reHTML;
	</cfscript>
</cffunction>

</cfcomponent>