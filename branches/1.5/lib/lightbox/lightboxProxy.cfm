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
	lightboxProxy.cfm
Summary:
	A proxy file for lightbox calls that builds the HTML to be output in a Lightbox window
	allows for central security model
History:
	For full history see: /lib/ajax/ajaxProxy.cfm 
	2011-01-26 - GAC - Created
	2011-01-27 - GAC - Modified - added parameter for forceScripts, addLBHeaderFooter
	2011-01-27 - GAC - Modified - moved parameter processing code to a lightbox_1_0 component to allow versioning of processing code
	2011-01-30 - RLW/GAC - Added a new parameter that allows commands to be run from ADF applications
	2011-02-01 - GAC - Modified - Changed the main method call to buildLightboxProxyHTML
								- removed the argument: params from the buildLightboxProxyHTML() call
	2011-02-02 - GAC - Added proxyFile check to see if the method is being called from inside the proxy file
	2011-02-09 - GAC - Removed the addMainTable parameter
	2011-02-16 - MFC - Reordered the HTML build process to build the lightbox headers/footer
						inline with the HTML content block.
						This is required for the FORMS_1_1 when implementing the UDF.UI.RenderSimpleForm function.
							The dialog header must be loaded before the UDF HTML.
	2011-03-10 - MFC - Added check for subsiteURL param, then load the APPLICATION.CFC 
						to load the lightbox within the specific subsites application scope.
	2011-03-11 - MFC - Updated the APPLICATION.CFC to use the ADF Application file
						and loading the sites Application space function directly.
--->
	<cfheader name="Expires" value="#now()#">
  	<cfheader name="Pragma" value="no-cache">

	<cfparam name="request.params.method" default="" type="string">
	<cfparam name="request.params.bean" default="" type="string">
	<cfparam name="request.params.appName" default="" type="string">
	<!--- // Use Force the lightbox header Scripts  --->
	<cfparam name="request.params.forceScripts" default="0" type="boolean">
	<!--- // Use to add the CS 6.x LB Header and Footer --->
	<cfparam name="request.params.addLBHeaderFooter" default="1" type="boolean">
	<!--- // Debug parameter to force a DUMP of the processed method, bean and other passed in parameters  --->
	<cfparam name="request.params.debug" default="0" type="boolean">
	<!--- Default the subsiteURL param --->
	<cfparam name="request.params.subsiteURL" default="" type="string">
	
	<cfscript>
		/*	Check if the subsiteURL is defined.
	     *	If defined, then load the APPLICATION.CFC to load the lightbox within 
		 * 		the specific subsites application scope.
		 */
		if ( LEN(request.params.subsiteURL) )
			CreateObject("component","ADF.Application").loadSiteAppSpace(request.params.subsiteURL);	
	</cfscript>
</cfsilent>

<!--- // Add CS 6.x lightbox Header  --->
<cfif request.params.addLBHeaderFooter><cfoutput>#application.ADF.ui.lightboxHeader()#</cfoutput></cfif>
<!--- // Add ADF lightbox Scripts Header  --->
<cfscript>application.ADF.scripts.loadADFLightbox(force=request.params.forceScripts);</cfscript>
<!--- // 2011-02-16 - Call the Lightbox Proxy to build the HTML, then Output the HTML string --->
<cfoutput>#TRIM(Application.ADF.lightbox.buildLightboxProxyHTML())#</cfoutput>
<!--- // Add CS 6.x lightbox Footer  --->
<cfif request.params.addLBHeaderFooter><cfoutput>#application.ADF.ui.lightboxFooter()#</cfoutput></cfif>
