<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc.  Copyright (c) 2009-2016.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$site_config_core.cfm
Summary: 
	Each ADF Application can have configuration variables which can
	be configured via a Custom Element.  This file will help manage
	configurations for your Applications
History:
	2010-04-11 - RLW - Created
	2011-04-08 - MFC - Updated the styles for the Edit and Show/Hide buttons
	2011-05-13 - RAK - Updated to allow for adding this script directly to the page using attributes
	2012-03-08 - MFC - Updated to call Forms_1_1.
	2015-10-14 - GAC - Updated the forms call to Forms_2_0
--->
<cfparam name="appName" default="foo">
<cfparam name="formWidth" default="600">
<cfparam name="formHeight" default="400">
<cfscript>
	if(StructKeyExists(attributes,"appName")){
		appName = attributes.appName;
	}
	elementName = "#appName# Configuration";
	appConfigArray = arrayNew(1);
	appConfig = structNew();
	formID = 0;
	dataPageID = 0;
	// check to see if the application configuration element exists
	elementExists = application.ADF.ceData.elementExists(elementName);
	if( elementExists )
	{
		formID = application.ADF.ceData.getFormIDByCEName(elementName);
		// get the results for the element
		appConfigArray = application.ADF.ceData.getCEData(elementName);
		if( arrayLen(appConfigArray) )
		{
			// setup some variables for the configuration links
			appConfig = appConfigArray[1].values;
			formID = appConfigArray[1].formID;
			dataPageID = appConfigArray[1].pageID;
		}
	}
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQueryUI();
	application.ADF.scripts.loadADFLightbox();
</cfscript>
<!--- // render out link to manage application configuration --->
<cfoutput>
	<script type="text/javascript">
		jQuery( function() {
			jQuery("##configBtn").bind("click", function(event){
				// add show/hide to the configuration content
				jQuery("##config").slideToggle('slow');
			});
			
			// Hover states on the Config button
			jQuery("div##configuration div##editConfig").hover(
				function() { 
					jQuery(this).css("cursor", "hand");
					jQuery(this).addClass('ui-state-hover'); 
				},
				function() { 
					jQuery(this).css("cursor", "pointer");
					jQuery(this).removeClass('ui-state-hover'); 
				}
			);
		});
	</script>
	<style type="text/css">
		##configBtn { cursor: pointer; padding: 2px; width: 125px; margin-top: 8px; }
		##config { padding: 3px; }
		##config dt { background-color: ##c0c0c0; float: left; clear: left; border: 1px solid ##000; padding: 5px; }
		##config dd { float: left; border: 1px solid ##000; padding: 5px; }
		div##configuration div##editConfig { padding: 1px 10px; width: 125px; height: 16px; }
		div##configuration div##configBtn { padding: 1px 10px; width: 175px; height: 16px; }
	</style>
	<div id="configuration">
		<cfif dataPageID gt 0>
			<div id="editConfig" rel="#application.ADF.ajaxProxy#?bean=Forms_2_0&method=renderAddEditForm&formID=#formID#&dataPageID=#dataPageID#&lbAction=refreshparent&width=#formWidth#&formHeight=#formHeight#&title=Edit Configuration" class="ADFLightbox ui_button ui-state-default ui-corner-all">Edit Configuration</div>
			<div id="configBtn" class="ui_button ui-state-default ui-corner-all">Show/Hide Configuration</div>
			<dl id="config" style="display:none;">
				<cfloop list="#structKeyList(appConfig)#" index="key">
					<dt>#key#</dt>
					<dd>#appConfig[key]#</dd>
				</cfloop>
			</dl>
		<cfelse>
			<div id="editConfig" href="javascript:;" rel="#application.ADF.ajaxProxy#?bean=Forms_2_0&method=renderAddEditForm&formID=#formID#&dataPageID=0&lbAction=refreshparent&width=#formWidth#&formHeight=#formHeight#&title=Edit Configuration" class="ADFLightbox ui_button ui-state-default ui-corner-all">Edit Configuration</div>
		</cfif>
	</div>
</cfoutput>