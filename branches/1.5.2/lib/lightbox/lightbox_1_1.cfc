<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2012.
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
	lightbox_1_1.cfc
Summary:
	Lightbox functions for the ADF Library
Version
	1.1
History:
	2012-01-30 - MFC - Created
--->
<cfcomponent displayname="lightbox" extends="ADF.lib.lightbox.lightbox_1_0" hint="Lightbox functions for the ADF Library">
	
<cfproperty name="version" value="1_1_0">
<cfproperty name="type" value="singleton">
<cfproperty name="csSecurity" type="dependency" injectedBean="csSecurity_1_1">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_1">
<cfproperty name="data" type="dependency" injectedBean="data_1_1">
<cfproperty name="wikiTitle" value="lightbox_1_1">

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
	</cfscript>

	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<!-- ADF Lightbox Framework Loaded @ #now()# -->
			<!--- Load lightbox override styles --->
			<cfif application.ADF.csVersion GTE 6.1>
				<link href="/ADF/extensions/lightbox/1.0/css/lightbox_overrides_6_1.css" rel="stylesheet" type="text/css">
			<cfelse>
		    	<link href="/ADF/extensions/lightbox/1.0/css/lightbox_overrides.css" rel="stylesheet" type="text/css">
			</cfif>
		</cfoutput>
		<!--- Load the CommonSpot Lightbox when not in version 6.0 --->
		<cfif application.ADF.csVersion LT 6>
			<cfoutput>
				<!--- Load the Lightbox Framework for CS 5.x --->
				#loadLighboxCS5()#
			</cfoutput>
		<cfelse>
			<script type='text/javascript' src='/ADF/extensions/lightbox/2.0/js/framework.js'></script>	
		</cfif>
		<cfoutput>
			<script type="text/javascript">
				jQuery(document).ready(function(){
					/*
						Set the Jquery to initialize the ADF Lightbox
					*/
					initADFLB();
				});
			</script>
		</cfoutput>
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
			<script type='text/javascript' src='/ADF/extensions/lightbox/1.0/js/framework.js'></script>					
			<script type='text/javascript' src='/ADF/extensions/lightbox/1.0/js/browser-all.js'></script>
			
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
			<script type='text/javascript' src='/ADF/extensions/lightbox/1.0/js/cs5-overrides.js'></script>
		</cfoutput>
		
	</cfsavecontent>
	<cfreturn retHTML>
</cffunction>

</cfcomponent>