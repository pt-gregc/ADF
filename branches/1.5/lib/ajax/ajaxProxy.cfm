<cfsetting requesttimeout="2500" showdebugoutput="false">
<cfsilent>
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
	2011-02-02 - GAC - Moved all of the parameter and data processing code into a method in the ajax_1_0 lib component
	2011-02-02 - GAC - Added proxyFile check to see if the method is being called from inside the proxy file
	2011-02-09 - GAC - Removed ADFlightbox specific code
	2011-03-10 - MFC - Added check for subsiteURL param, then load the APPLICATION.CFC 
						to load the lightbox within the specific subsites application scope.
--->
	<cfheader name="Expires" value="#now()#">
  	<cfheader name="Pragma" value="no-cache">
	
	<cfparam name="request.params.method" default="" type="string">
	<cfparam name="request.params.bean" default="" type="string">
	<cfparam name="request.params.returnformat" default="plain">
	<!--- // When attempting to DEGUG a RETURNFORMAT of JSON or XML, 
			you may need to set the ajax call dataType to 'text', 'html' or nothing (ie. best guess) --->
	<cfparam name="request.params.debug" default="0" type="boolean">
	<cfparam name="request.params.appName" default="" type="string">
	<!--- Default the subsiteURL param --->
	<cfparam name="request.params.subsiteURL" default="" type="string">
	
	<cfscript>
		/*	Check if the subsiteURL is defined.
	     *	If defined, then load the APPLICATION.CFC to load the lightbox within 
		 * 		the specific subsites application scope.
		 */
		if ( LEN(request.params.subsiteURL) )
			CreateObject("component","ADF.lib.ajax.Application").onRequestStart();	
	
		// reAJAX = ""; //Don't initalize the reAJAX allows for a return: void
		ajaxData = Application.ADF.ajax.buildAjaxProxyString();
		if ( StructKeyExists(ajaxData,"reString") )
			reAJAX = ajaxData.reString;
	</cfscript>
</cfsilent>
<cfif StructKeyExists(variables,"reAJAX")>
	<cfif request.params.returnFormat eq "xml"><cfcontent type="text/xml; charset=utf-8"></cfif>
	<cfoutput>#TRIM(reAJAX)#</cfoutput>
</cfif>