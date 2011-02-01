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
<cfsetting requesttimeout="2500" showdebugoutput="false">
<cfsilent>
<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
Name:
	ajaxProxy.cfm
Summary:
	A proxy file for ajax calls = allows for central security model
History:
	2009-06-12 - GAC - Created
	2009-07-21 - RLW - Made generic - requires method and current subsite everything else is packaged
						and sent to cfc specified
	2009-08-03 - MFC - Updated building argStr to use URLEncodedFormat for the arguments.
					   Added isdefined check for rending the reHTML variable.
	2009-09-15 - MFC - Updated params to take a serialized CS Simple Form string and pass
						the simple form as a structure to the function. 
	2009-10-14 - RLW - Updated code to accept the bean name instead of the full path to the component
						removed the subsiteURL requirement since this file exists in the root subsite already
	2009-11-05 - MFC - Updated the proxy white list security.
	2009-12-03 - MFC - Updated IF block to add an "else if", removed dump
	2010-02-24 - GAC - Updated to allow AjaxProxy error messages to be displayed when returning results in an ADFLightbox 
	2010-03-04 - MFC - Added cfheader to not cache the ajax call.
	2011-01-06 - RAK - Changed up to use runCommand from utils to avoid the evaluate.
	2011-01-19 - GAC - Updated the runCommand call reHTML variable to allow calls to methods that return void 
						also replaced IsDefined with StructKeyExists
	2011-01-19 - GAC - Added a debug parameter and debug dumps before and after the reHTML processing
						also added a try/catch around runCommand call, if an error is caught then debugging is auto enabled
	2011-01-24 - GAC - Added the Return type of XML
	2011-01-30 - RLW - Added a new parameter that allows commands to be run from ADF applications
	2011-02-01 - GAC - Removed the args loop and replaced it with a method call to convert the parameters that are passed in to the args struct before calling the runCommand method
--->
	
	<cfheader name="Expires" value="#now()#">
  	<cfheader name="Pragma" value="no-cache">
	
	<cfparam name="request.params.method" default="" />
	<cfparam name="request.params.bean" default="" />
	<cfparam name="request.params.returnformat" default="plain" />
	<cfparam name="request.params.addMainTable" default="0" type="boolean" />
	<!--- // When using a returnformat of JSON or XML and the debug parameter, you may need to set the ajax call dataType to 'text' or 'html' --->
	<cfparam name="request.params.debug" default="0" type="boolean" />
	<cfparam name="request.params.appName" default="" type="string" />
	<cfscript>
		bean = structNew();
		reHTML = "";
		argStr = "";
		reDebugRaw = "";
		reDebugProcessed = "";
		// list of parameters in request.params to exclude
		argExcludeList = "bean,method,appName,addMainTable,returnFormat,debug";
		args = StructNew();
		// set the flag that controls whether additional code is added to the reHTML output
		forceOutput = false;
		// set the flag for if we have a serialized form to pass to the function as a structure 
		containsSerializedForm = false;
		// get the utils, scripts amd csSecurity beans 
		utils = server.ADF.objectFactory.getBean("utils_1_1");
		// Verify if the bean and method combo are allowed to be accessed through the ajax proxy
		passedSecurity = server.ADF.objectFactory.getBean("csSecurity_1_0").validateProxy(request.params.bean, request.params.method);
		if ( passedSecurity )
		{
			// convert the params that are passed in to the args struct before passing them to runCommand method
			args = application.ADF.utils.buildRunCommandArgs(request.params,argExcludeList);
			try 
			{
				// Run the Bean, Method and Args and get a return value
				reHTML = utils.runCommand(trim(request.params.bean),trim(request.params.method),args,request.params.appName);
			} 
			catch( Any e ) 
			{
				request.params.debug = 1;
				reHTML = e;
			}	
			// Build the DUMP for debugging the RAW value of reHTML
			if ( request.params.debug ) {
				// If the variable reHTML doesn't exist set the debug output to the string: void 
				if ( !StructKeyExists(variables,"reHTML") ){debugRaw="void";}else{debugRaw=reHTML;}
				reDebugRaw = utils.doDump(debugRaw,"RAW OUTPUT",1,1);
			}
			// Check to see if reHTML was destroyed by a method that returns void before attempting to process the return
			if ( StructKeyExists(variables,"reHTML") ) 
			{
				if ( request.params.returnFormat eq "json" )
				{
					json = server.ADF.objectFactory.getBean("json");
					// when jsonp calls are made there will be a variable called "jsonpCallback" it will
					// represent the method in the caller to be executed - wrap the content in that function call
					if( structKeyExists(request.params, "jsonpCallback") )
						reHTML = "#request.params.jsonpCallback#(" & json.encode(reHTML) & ");";
					else
						reHTML = json.encode(reHTML);
				}
				else if ( request.params.returnFormat eq "xml" )
				{
					reHTML = Server.CommonSpot.MapFactory.serialize(reHTML,"data",0); //Server.CommonSpot.MapFactory.serialize(Arguments.bean,Arguments.tagName,JavaCast("boolean",Arguments.forceLCase));
					if ( IsXML(reHTML) ) 
						reHTML = XmlParse(reHTML);
					if ( !IsXmlDoc(reHTML) ) {
						forceOutput = true;
						reHTML = "Error converting return format into xml";
					}
				}
				if ( isStruct(reHTML) or isArray(reHTML) or isObject(reHTML) ) 
				{
					// set forceOutput to true to allow error string to be displayed in the ADFLightbox
					forceOutput = true;
					reHTML = "Error converting return format into string";
				}
			}
			else
			{
				// The method call returned void and destroyed the reHTML variable
				// reHTML = ""; 
			}
		}
		else
		{
			// set forceOutput to true to allow error string to be displayed in the ADFLightbox
			forceOutput = true;
			reHTML = "The Bean: #request.params.bean# with method: #request.params.method# is not accessible remotely via Ajax Proxy.";	
		}
		// build the dump for debugging the Processed value of reHTML
		if ( !passedSecurity OR request.params.returnformat NEQ "plain" ) 
		{
			// If the variable reHTML doesn't exist set the debug output to the string: void 
			if ( !StructKeyExists(variables,"reHTML") ){debugProcessed="void";}else{debugProcessed=reHTML;}
			reDebugProcessed = utils.doDump(debugProcessed,"PROCESSED OUTPUT",1,1);
		}
		// pass the debug dumps to the reHTML for output
		if ( request.params.debug ) 
		{
			// set forceOutput to true to allow the debug dump to be displayed in the ADFLightbox
			forceOutput=true;
			reHTML = reDebugRaw & reDebugProcessed;
		}
	</cfscript>
</cfsilent>
<cfif StructKeyExists(variables,"reHTML")>
	<cfif request.params.returnFormat eq "xml" AND forceOutput IS false><cfcontent type="text/xml; charset=utf-8"></cfif>
	<cfscript>if ( forceOutput IS true ) { application.ADF.scripts.loadADFLightbox(force=1); }</cfscript>
	<!--- // if this is a lighbox window then add in the main table --->
	<cfif request.params.addMainTable><cfoutput><table id="MainTable"><tr><td></cfoutput></cfif>
		<cfoutput>#TRIM(reHTML)#</cfoutput>
	<cfif request.params.addMainTable><cfoutput></td></tr></table></cfoutput></cfif>
</cfif>