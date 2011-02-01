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
--->
	<cfheader name="Expires" value="#now()#">
  	<cfheader name="Pragma" value="no-cache">

	<cfparam name="request.params.method" default="" type="string" />
	<cfparam name="request.params.bean" default="" type="string" />
	<cfparam name="request.params.appName" default="" type="string" />
	<!--- // Force the lightbox Scripts unless not needed --->
	<cfparam name="request.params.forceScripts" default="1" type="boolean" />
	<!--- // If needed, add the CS 6.x LB Header and Footer --->
	<cfparam name="request.params.addLBHeaderFooter" default="1" type="boolean" />
	<!--- // Add the MainTable table tags unless not needed --->
	<!--- // addMainTable param will be disabled by the UI.lightboxHeader if a 6.x LB header is output --->
	<cfparam name="request.params.addMainTable" default="1" type="boolean" />
	<!--- // Debug parameter to force a DUMP of the processed method, bean and other passed in parameters  --->
	<cfparam name="request.params.debug" default="0" type="boolean" /> 
	<cfscript>
		reHTML = Application.ADF.lightbox.buildLightboxProxyHTML();
	</cfscript>
</cfsilent>
<cfif StructKeyExists(variables,"reHTML")>
	<!--- // Add CS 6.x lightbox Header  --->
	<cfif request.params.addLBHeaderFooter><cfoutput>#application.ADF.ui.lightboxHeader()#</cfoutput></cfif>
	<!--- // Add ADF lightbox Scripts Header  --->
	<cfscript>application.ADF.scripts.loadADFLightbox(force=request.params.forceScripts);</cfscript>
	<!--- // add in the main table unless intentionally disabled 
		  // the MainTable tags are not needed when using 6.x LB header footer --->
	<cfif request.params.addMainTable><cfoutput><table id="MainTable"><tr><td></cfoutput></cfif>
	<!--- // Output the HTML string --->
	<cfoutput>#TRIM(reHTML)#</cfoutput>
	<!--- // add in the main table unless intentionally disabled --->
	<cfif request.params.addMainTable><cfoutput></td></tr></table></cfoutput></cfif>
	<!--- // Add CS 6.x lightbox Footer  --->
	<cfif request.params.addLBHeaderFooter><cfoutput>#application.ADF.ui.lightboxFooter()#</cfoutput></cfif>
</cfif>