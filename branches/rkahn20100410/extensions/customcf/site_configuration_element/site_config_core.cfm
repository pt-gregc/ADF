<!---
	/* ***************************************************************
	/*
	Author: 	Ron West
	Name:
		$site_config_core.cfm
	Summary: Each ADF Application can have configuration variables which can
				be configured via a Custom Element.  This file will help manage
				configurations for your Applications
	History:
		2010-04-11 - RLW - Created
--->
<cfparam name="appName" default="foo">
<cfparam name="formWidth" default="600">
<cfparam name="formHeight" default="400">
<cfscript>
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
		});
	</script>
	<style type="text/css">
		##configBtn { cursor: pointer; padding: 2px; width: 175px; margin-top: 8px; }
		##config { padding: 3px; }
		##config dt { background-color: ##c0c0c0; float: left; clear: left; border: 1px solid ##000; padding: 5px; }
		##config dd { float: left; border: 1px solid ##000; padding: 5px; }
	</style>
	<div id="configuration">
		<cfif dataPageID gt 0>
			<div rel="#application.ADF.ajaxProxy#?bean=Forms_1_0&method=renderAddEditForm&formID=#formID#&dataPageID=#dataPageID#&width=#formWidth#&formHeight=#formHeight#" class="ADFLightbox ui_button ui-state-default ui-corner-all">Edit Configuration</div>
			<div id="configBtn" class="ui_button ui-state-default ui-corner-all">Show/Hide Configuration</div>
			<dl id="config" style="display:none;">
				<cfloop list="#structKeyList(appConfig)#" index="key">
				<dt>#key#</dt>
				<dd>#appConfig[key]#</dd>
				</cfloop>
			</dl>
		<cfelse>
			<div href="javascript:;" rel="#application.ADF.ajaxProxy#?bean=Forms_1_0&method=renderAddEditForm&formID=#formID#&dataPageID=0&width=#formWidth#&formHeight=#formHeight#" class="ADFLightbox ui_button ui-state-default ui-corner-all">Edit Configuration</div>
		</cfif>
	</div>
</cfoutput>