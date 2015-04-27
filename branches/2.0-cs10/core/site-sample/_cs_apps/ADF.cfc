<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin Inc.
Name:
	ADF.cfc
Summary:
	ADF Component for loading the ADF, ADF apps, proxys, and Library into the site.
Version:
	2.0.0
History:
	2011-07-11 - MFC - Updated for ADF V1.5.
	2013-10-21 - GAC - Added the enable/disable Development Mode function call
	2014-02-26 - GAC - Updated for version 1.7.0
	2014-10-07 - GAC - Updated for version 1.8.0
--->
<cfcomponent name="ADF" extends="ADF.core.SiteBase">
	
<cfproperty name="version" value="2_0_0">
<cfproperty name="file-version" value="7">

<cffunction name="init" returntype="void" access="public">
	<cfscript>
		/*
		 *	Load the Site Environment Configs/Elements and 
		 *		Components ('/_cs_apps/components') into the site.
		 *  
		 */
		loadSite();
		
		/*
		 *	Set the sites AjaxProxy URL
		 *	By default this file will be located in your sites /_cs_apps/ directory
		 */
		setAjaxProxyURL("#request.site.csAppsWebURL#ajaxProxy.cfm");
		
		/*
		 *	Set the sites lightboxProxy URL
		 *	By default this file will be located in your sites /_cs_apps/ directory
		 */
		setLightboxProxyURL("#request.site.csAppsWebURL#lightboxProxy.cfm");	
		
		/*
		 *	Set the sites enableADFsiteDevMode status
		 *	By default the ADF runs with development mode disabled (false) to enable set to (true)
		 *  (Note: if this line is commented, removed or if no value is passed development mode will disabled)
		 *  options: true or false 
		 */
		enableADFsiteDevMode(false);
		
		/*
		 *	Load the ADF Application into application space
		 *  
		 *  SAMPLE:
		 *		loadApp("CustomAppBeanName"); 
		 *	
		 */
		//loadApp("ptProfile");		
		
		/*
		 *	Define the ADF Lib components to load into the sites application space.
		 *	Loading the most recent versions of the ADF Lib components
		 *	
		 *	Note: you can pass a previous ADF version number (e.g. 1.0) to this function to load that
		 *	versions ADF Library Components
		 *	
		 *	See /ADF/lib/version.xml to see which ADF Library Components are loaded for that ADF Version
		 *
		 */
		loadLibrary();	
	</cfscript>
</cffunction>

</cfcomponent>