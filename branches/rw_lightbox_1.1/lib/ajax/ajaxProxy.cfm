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
--->
	
	<cfheader name="Expires" value="#now()#">
  	<cfheader name="Pragma" value="no-cache">
	
	<cfparam name="request.params.method" default="" />
	<cfparam name="request.params.bean" default="" />
	<cfparam name="request.params.returnformat" default="plain">
	<cfparam name="request.params.addMainTable" default="0">
	<!--- // set up default window width --->
	<cfparam name="request.params.width" default="450">
	<cfscript>
		bean = structNew();
		reHTML = "";
		argStr = "";
		// set the flag that controls whether additional code is added to the reHTML output
		forceOutput = false;
		// set the flag for if we have a serialized form to pass to the function as a structure 
		containsSerializedForm = false;
		// Verify if the bean and method combo are allowed to be accessed
		//	through the ajax proxy
		passedSecurity = server.ADF.objectFactory.getBean("csSecurity_1_0").validateProxy(request.params.bean, request.params.method);
		if ( passedSecurity )
		{
			// load the bean that we will call - check in application scope first
			if( application.ADF.objectFactory.containsBean(request.params.bean) )
				bean = application.ADF.objectFactory.getBean(request.params.bean);
			else if( server.ADF.objectFactory.containsBean(request.params.bean) )
				bean = server.ADF.objectFactory.getBean(request.params.bean);
			methodname = trim(request.params.method);
			// loop through request.params parameters to get arguments
			for( itm=1; itm lte listLen(structKeyList(request.params)); itm=itm+1 )
			{
				thisParam = listGetAt(structKeyList(request.params), itm);
				if( thisParam neq "method" and thisParam neq "bean" )
				{
					// Check if the argument name is 'serializedForm'
					if ( thisParam EQ 'serializedForm' )
					{
						// Set the flag, and get the serialized form string into a structure
						containsSerializedForm = true;
						serialFormStruct = server.ADF.objectFactory.getBean("csData_1_0").serializedFormStringToStruct(request.params[thisParam]);
					}
					else
						argStr = listAppend(argStr, "#thisParam#='#request.params[thisParam]#'");
				}
			}
			// Check if we have a structure to pass to the function
			if ( containsSerializedForm )
				reHTML = Evaluate("bean.#methodname#(#argStr#,serializedForm=serialFormStruct)");
			else if ( len(argStr) )
				reHTML = Evaluate("bean.#methodname#(#argStr#)");
			else
				reHTML = Evaluate("bean.#methodname#()");
			
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
			if ( isStruct(reHTML) or isArray(reHTML) or isObject(reHTML) ) 
			{
				// set forceOutput to true to allow error string to be displayed in the ADFLightbox
				forceOutput = true;
				reHTML = "Error converting return format into string";
			}
		}
		else
		{
			// set forceOutput to true to allow error string to be displayed in the ADFLightbox
			forceOutput = true;
			reHTML = "The Bean: #request.params.bean# with method: #request.params.method# is not accessible remotely via Ajax Proxy.";	
		}
	</cfscript>
</cfsilent>
<cfif IsDefined("reHTML")>
	<cfscript>
		if ( forceOutput IS true )
			{ application.ADF.scripts.loadADFLightbox(force=1);}
		// don't check the lock for the page since this may be done in Read Mode
		CD_CheckLock = 0;
	</cfscript>
	<!--- // if this is a lighbox window then add in the main table --->
	<cfif request.params.addMainTable><cfinclude template="/commonspot/dlgcontrols/dlgcommon-head.cfm"><cfoutput><table id="MainTable" width="#request.params.width#"><tr><td></cfoutput></cfif>
		<cfoutput>#TRIM(reHTML)#</cfoutput>
	<cfif request.params.addMainTable><cfoutput></td></tr></table></cfoutput><cfinclude template="/commonspot/dlgcontrols/dlgcommon-foot.cfm"></cfif>
</cfif>



