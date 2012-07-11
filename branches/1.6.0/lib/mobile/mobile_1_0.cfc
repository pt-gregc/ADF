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
	mobile_1_0.cfc
Summary:
	Data Utils component functions for the ADF Library
Version:
	1.0.1
History:
	2012-07-09 - PaperThin, Inc. - Created
	2012-07-11 - DMB - injected scriptsService and added function to load jQueryMobile.
--->
<cfcomponent displayname="mobile_1_0" extends="ADF.core.Base" hint="Mobile component functions for the ADF Library">
<cfproperty name="version" value="1_0_0">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Mobile_1_0">
<cfproperty name="scriptsService" injectedBean="scriptsService_1_0" type="dependency">

<!---
/* ***************************************************************
/*
Author: 	D. Beckstrom
Name:
	$getDeviceType
Summary:
	Returns type of device (mobile or desktop).
Returns:
	Query
Arguments:
	userAgent -  Provides a mechanism for testing of different devices.
	accept  -  
History:
	2012-07-09 - DMB - Created based on http://detectmobilebrowsers.com
--->
<cffunction name="getDeviceType" output="no" returnType="string" access="public">
	<cfargument name="userAgent" type="string" default="#cgi.http_user_agent#">
	<cfscript>
		var deviceType = "Desktop";
		if 
			(
				reFindNoCase("android.+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|meego.+mobile|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino",arguments.userAgent) GT 0
				|| 
				reFindNoCase("1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(di|rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-",Left(arguments.userAgent,4)) GT 0
			) {
			deviceType="Mobile";
			}
		return deviceType;
	</cfscript>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	D. Beckstrom
Name:
	$mobileDetect
Summary:
	Returns type of device (mobile, desktop or tablet).
Returns:
	Struct - struct containing device type, user_agent, accept and flag indicating if mobile.
	cookie - Optional.  
Arguments:
	userAgent -  Provides a mechanism for testing of different devices.
	accept  -  
	setCookie -  Flag controlling if the isMobileBrowser cookie is set for mobile devices.
History:
	2012-07-09 - DMB - Created based on http://www.mobileesp.com
--->
<cffunction name="mobileDetect" output="no" returnType="struct" access="public">
 <cfargument name="userAgent" type="string" default="#cgi.http_user_agent#">
 <cfargument name="accept"    type="string" default="#cgi.http_accept#">
 <cfargument name="setCookie" type="boolean" default="0">
 <cfscript>
	  var deviceStuct = structNew();
 	  var deviceType = "desktop";
	  var isMblBrowser = "False";
	  var paths = ListToArray(expandPath("/ADF/thirdparty/uagentinfo/UAgentInfo.jar"));
	  var loader = createObject("component", "ADF.thirdparty.javaloader.JavaLoader").init(paths);
	  var detector = loader.create("com.handinteractive.mobile.UAgentInfo").init(arguments.userAgent, arguments.accept);	  
	  //
	  // Start of device detection.  Default device is a desktop.  Check for anything else.
	  //
	  if (detector.DetectTierTablet()) {
	  		// this device is a tablet like an ipad
	   		deviceType = 'tablet';
			isMblBrowser = "True";
	  }
	  else if (detector.DetectMobileQuick()) {
	  		// this device is a phone
	   		deviceType =  'handheld';
			isMblBrowser = "True";
	  }
	  // populate deviceStruct with info on our mobile device
	    deviceStuct["isMobileBrowser"] = isMblBrowser;
		deviceStuct["mobileBrowserType"] = TRIM(deviceType);
		deviceStuct["useragent"] = TRIM(userAgent);
		deviceStuct["httpaccept"] = TRIM(accept);
	// set a cookie flagging the device as a mobile device	
	if ((arguments.setCookie) and (isMblBrowser is "True")) {
		 cookie.isMobileBrowser = "True";
	   }
	   else if ((arguments.setCookie) and (isMblBrowser is "False")) {
		 cookie.isMobileBrowser = "False";
	   }
	return deviceStuct;
 </cfscript>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	D. Beckstrom
Name:
	$setMobileRedirectCookie
Summary:
	Sets cookie indicating if the mobile device has been redirected.
Returns:
	cookie .  
Arguments:
	
History:
	2012-07-011 - DMB - Created 
--->
<cffunction name="setMobileRedirectCookie" output="no" returnType="any" access="public">
	<cfscript>
		 //set our cookie
		 cookie.MobileRedirect = "True";
	</cfscript>
 </cffunction>
 <!---
/* ***************************************************************
/*
Author: 	D. Beckstrom
Name:
	$getMobileRedirectCookie
Summary:
	Gets the MobileRedirectCookie.
Returns:
	True if cookie exists.  False if cookie not defined.  
Arguments:
	
History:
	2012-07-011 - DMB - Created 
--->
<cffunction name="getMobileRedirectCookie" output="no" returnType="any" access="public">
	<cftry>
		<cfscript>
			return  cookie.MobileRedirect;
		</cfscript>
		<cfcatch>
			<cfscript>
				return  "False";
			</cfscript>
		</cfcatch>
	</cftry>
 </cffunction>
 <!---
/* ***************************************************************
/*
Author: 	D. Beckstrom
Name:
	$loadJQueryMobile
Summary:
	Loads the JQuery Mobile script.
Returns:
	None
Arguments:
	String - version - JQuery version to load.
	Boolean - force - Forces JQuery script header to load.
History:
	2012-07-11 - DMB - Created
--->
<cffunction name="loadJQueryMobile" access="public" output="true" returntype="void" hint="Loads the JQuery Mobile script if not loaded.">
<cfargument name="version" type="string" required="false" default="1.1.0" hint="JQuery Mobile version to load.">
<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery Mobile to load.">
<cfif (not variables.scriptsService.isScriptLoaded("jquerymobile")) OR (arguments.force)>
	<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/jquery/mobile/jquery.mobile-#arguments.version#.js"></script>
	</cfoutput>
	<!--- If we force, then don't record the loaded script --->
	<cfif NOT arguments.force>
		<cfset variables.scriptsService.loadedScript("jquerymobile")>
	</cfif>
</cfif>
</cffunction>
</cfcomponent>

