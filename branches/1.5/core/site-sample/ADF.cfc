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

<cfcomponent name="ADF" extends="ADF.core.SiteBase">

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
		 */
		loadLibrary();
		
		/*
		 *	Define specific ADF Lib component version to load into the sites application space.
		 *	
		 *	SAMPLE:
		 *		resetLibrary("csdata_1_0", "csdata");
		 *
		 */
	</cfscript>
</cffunction>

</cfcomponent>