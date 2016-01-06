<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2016.
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
	sample.cfm
Summary:
	Sample mobile detection framework which can be included into custom-application.cfm
Version:
	1.0
History:
	2012-07-20 - PaperThin, Inc. - Created
--->
<cfparam name="cgi.script_name" default="">
<cfparam name="url.forcefullSite" default="False">
<cfparam name="cookie.forceFullSite" default="False">
<cfscript>
	  PageFileName = listLast(cgi.script_name,"/");
	  if (url.forcefullSite is 1) { 
			// Set a cookie that the user wants to view the full desktop version of the site --->
			 cookie.forceFullSite = "True";
	  }
	  if (not (isDefined("cookie.isMobileBrowser"))) { 
			 // Run our device detection to see if this is a mobile device.  Set cookie either way. 
			 null = application.ADF.mobile.mobileDetect(setCookie="1");
	  }
	  if (cookie.forceFullSite is "false") { 
		if ((isDefined("cookie.isMobileBrowser") and (cookie.isMobileBrowser is "true"))) { 
		// we have a mobile device.  See if we have previously redirected it to the mobile site  
			 redirected = application.ADF.mobile.getMobileRedirectCookie();
				// User has not been previously redirected.  See if we're on the home page. 
				if ((request.subsite.id is 1) and (pageFileName is "index.cfm")) {
					// Set our cookie flagging that a redirect has occurred. 
					redirected = application.ADF.mobile.setMobileRedirectCookie();
					// redirect to mobile site	
					application.ADF.utils.pageRedirect("/mobile/index.cfm");
				}
	    }   
	}		
</cfscript>

