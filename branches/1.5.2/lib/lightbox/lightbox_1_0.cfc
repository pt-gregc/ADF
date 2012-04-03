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
	2012-03-08 - MFC - Added loadADFLightbox and loadLighboxCS5.
--->
<cfcomponent displayname="lightbox" extends="ADF.core.Base" hint="Lightbox functions for the ADF Library">
	
<cfproperty name="version" value="1_0_6">
<cfproperty name="type" value="singleton">
<cfproperty name="csSecurity" type="dependency" injectedBean="csSecurity_1_1">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_1">
<cfproperty name="data" type="dependency" injectedBean="data_1_1">
<cfproperty name="wikiTitle" value="lightbox_1_0">

<!---
/* *************************************************************** */
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
	2012-03-08 - MFC - Added the cfcatch error message to the default error message display.
	2012-03-12 - GAC - Added logic to the reHTML error struct to check if a message key was returned
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
						// 2012-03-10 - GAC - we need to check if we have a 'message' before we can output it
						if ( StructKeyExists(result.reHTML,"message") )
							result.reHTML = "Error: Unable to convert the return value into string [" & result.reHTML.message & "]";
						else
							result.reHTML = "Error: Unable to convert the return value into string";
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

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadADFLightbox
Summary:
	Loads the ADF lightbox framework to the page.
Returns:
	string
Arguments:
	Void
History:
	2012-01-30 - MFC - Created
	2012-02-01 - MFC - Replaced all single quotes in script tags with double quotes.
						Added cfouput around the loading script for 2.0.
	2012-02-03 - MFC - Rearchitected commonspot.lightbox loading process for CS 7.0.
	2012-02-24 - MFC - Updated to loading process for CS 5.x and 6.x.  Setup lightbox v2.0 override CSS.
	2012-04-03 - MFC - Cleaned code, removed old commented code.
--->
<cffunction name="loadADFLightbox" access="public" returntype="string" output="true" hint="Loads the ADF Lightbox Framework into the page.">
	
	<cfscript>
		var outputHTML = "";
		
		// Check if we have LB properties
		// Default Title
		if ( NOT StructKeyExists(request.params, "title") )
			request.params.title = "";

		// Default Subtitle
		if ( NOT StructKeyExists(request.params, "subtitle") )
			request.params.subtitle = "";
		
		// Default Width
		if ( NOT StructKeyExists(request.params, "width") )
			request.params.width = 500;

		// Default Height
		if ( NOT StructKeyExists(request.params, "height") )
			request.params.height = 500;
	</cfscript>

	<cfsavecontent variable="outputHTML">
		<!--- Load the CommonSpot Lightbox when not in version 6.0 --->
		<cfif application.ADF.csVersion LT 6>
			<cfoutput>
				<!-- ADF Lightbox Framework Loaded @ #now()# -->
				<!--- Load lightbox override styles --->
				<link href="/ADF/extensions/lightbox/1.0/css/lightbox_overrides.css" rel="stylesheet" type="text/css">
				<!--- Load the Lightbox Framework for CS 5.x --->
				#loadLighboxCS5()#
				<script type="text/javascript">
					jQuery(document).ready(function(){
						/*
							Set the Jquery to initialize the ADF Lightbox
						*/
						initADFLB();
						
						if ( (typeof commonspot != 'undefined') && (typeof commonspot.lightbox != 'undefined') ) {
							commonspot.lightbox.initCurrent(#request.params.width#, #request.params.height#, { title: '#request.params.title#', subtitle: '#request.params.subtitle#', close: 'true', reload: 'true' });
						}
					});
				</script>
			</cfoutput>
		<cfelse>
			<cfoutput>
				<script type="text/javascript" src="/ADF/extensions/lightbox/2.0/js/framework.js"></script>	
				<!--- Load lightbox override styles --->
				<link href="/ADF/extensions/lightbox/2.0/css/lightbox_overrides.css" rel="stylesheet" type="text/css">
				
				<script type="text/javascript">
					// Check if in CS LVIEW
					if (top.commonspot && top.commonspot.lightbox) 
						var commonspot = top.commonspot;
					else if (parent.commonspot && parent.commonspot.lightbox)
						var commonspot = parent.commonspot;
					else
					{
						// Load the files for the CS LVIEW
						if (typeof parent.commonspot == 'undefined' || typeof parent.commonspot.lview == 'undefined')
							loadNonDashboardFiles();
						else if (parent.commonspot && typeof newWindow == 'undefined')
						{
							var arrFiles = 
									[
										{fileName: '/commonspot/javascript/lightbox/overrides.js', fileType: 'script', fileID: 'cs_overrides'},
										{fileName: '/commonspot/javascript/lightbox/window_ref.js', fileType: 'script', fileID: 'cs_windowref'}
									];
							
							loadDashboardFiles(arrFiles);
						}
					}
					
					jQuery(document).ready(function(){
						/*
							Set the Jquery to initialize the ADF Lightbox
						*/
						initADFLB();
					});
				</script>
				<!--- Load this CSS for when in CS 7 and IE mode --->
				<cfif application.ADF.csVersion GTE 7>
					<link rel="stylesheet" type="text/css" href="/commonspot/javascript/lightbox/lightbox.css"></link>
				</cfif>
			</cfoutput>
		</cfif>
	</cfsavecontent>
	<cfreturn outputHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadLighboxCS5
Summary:
	Loads the lightbox framework for CommonSpot v5.x
Returns:
	string
Arguments:
	Void
History:
	2012-01-30 - MFC - Created
	2012-02-01 - MFC - Replaced all single quotes in script tags with double quotes.
--->
<cffunction name="loadLighboxCS5" access="private" returntype="string" output="true">

	<cfscript>
		// Initialize the variables
		var retHTML = "";
	</cfscript>
	<cfsavecontent variable="retHTML">
		<cfscript>
			// Default Width
			if ( NOT StructKeyExists(request.params, "width") )
				request.params.width = 500;
	
			// Default Height
			if ( NOT StructKeyExists(request.params, "height") )
				request.params.height = 500;
		</cfscript>
		
		<!--- Load the CommonSpot 6.0 Lightbox Framework --->
		<cfoutput>
			<script type="text/javascript" src="/ADF/extensions/lightbox/1.0/js/framework.js"></script>					
			<script type="text/javascript" src="/ADF/extensions/lightbox/1.0/js/browser-all.js"></script>
			
			<!--- Setup the CommonSpot 6.0 Lightbox framework --->
			<script type="text/javascript">	
				if ((typeof commonspot == 'undefined' || !commonspot.lightbox) && (!top.commonspot || !top.commonspot.lightbox))
					loadNonDashboardFiles();
				else if ( typeof parent.commonspot != 'undefined' ){
					var commonspot = parent.commonspot;
				}
				else if ( typeof top.commonspot != 'undefined' ){
					var commonspot = top.commonspot;
				}
				
				/*
				 Loads in the Commonspot.util space for CS 5. This exists already in CS 6.
				 
	   			 Check if the commonspot.util.dom space exists,
					If none, then build this from the Lightbox Util.js
				*/
				if ( (typeof commonspot.util == 'undefined') || (typeof commonspot.util.dom == 'undefined') )
				{
					IncludeJs('/ADF/extensions/lightbox/1.0/js/util.js', 'script');
				}
			</script>
			
			<!--- Load the CS5 Resize override functions --->
			<script type="text/javascript" src="/ADF/extensions/lightbox/1.0/js/cs5-overrides.js"></script>
		</cfoutput>
		
	</cfsavecontent>
	<cfreturn retHTML>
</cffunction>

</cfcomponent>