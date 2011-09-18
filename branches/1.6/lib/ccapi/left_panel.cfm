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
	left_panel.cfm
Summary:
	Left panel HTML for the CCAPI tools and samples
Version:
	1.0.1
History:
	2011-03-20 - RLW - Created
	
	
	NOTE: originally designed to be loaded through the ADF dashboard application
	
--->
<cfscript>
	config = arrayNew(1);
	configElementLoaded = 0;
	hasConfig = 0;
	configMsg = "";
	configAction = "Add";
	dataPageID = 0;
	// is the custom configuration element loaded correctly
	if( variables.ceData.elementExists(variables.configElementName) ){
		configElementLoaded = 1;
		// check to see if the element has data
		config = variables.ceData.getCEData(variables.configElementName);
		if( arrayLen(config) )
			hasConfig = 1;
	else
		configMsg = "Please import the CCAPI Configuration element.  It is located in the /ADF/lib/ccapi/exported-objects/ directory";
	}
	// if we have config element but no data show the "add" link"
	if( configElementLoaded and not hasConfig ){
		configMsg = "You have successfully imported the CCAPI Configuration element - please configure below";
	}
	else if( configElementLoaded and hasConfig ){
		configMsg = "CCAPI Configuration can be edited at any time (does not require ADF Reset)";
		configAction = "Edit";
		dataPageID = config[1].pageID;
	}
</cfscript>

<cfoutput>
	#application.ADF.scripts.loadJQuery()#
	#application.ADF.scripts.loadJQueryUI()#
	<!--- // include the dashboard css --->
	<cfset server.ADF.objectFactory.getBean("dashboard_render").renderDashboardCSS()>
	<script type="text/javascript">
		jQuery( function(){
			jQuery("##tabs").tabs();
		});
	</script>
	<div id="tabs">
		<ul>
			<li><a href="##tab1">Configuration</a></li>
			<li><a href="##tab2">Tools</a></li>
			<li><a href="##tab3">Samples</a></li>
		</ul>
		<!--- // configuration tab --->
		<div id="tab1">
			<p>#configMsg#</p>
			<cfif configElementLoaded>
				#application.ADF.forms.buildAddEditLink(linkTitle="#configAction# CCCAPI Configuration", formName=variables.configElementName, dataPageID=dataPageID, refreshParent=true, makeButton=true)#
			</cfif>
		</div>
		<!--- // tools tab --->
		<div id="tab2">
			<p>Convert ccapi.xml/ccapi.cfm to Configuration Element</p>
		</div>
		<!--- // samples tab --->
		<div id="tab3">
			<p>Coming Soon</p>
		</div>
	
	</div>
</cfoutput>
