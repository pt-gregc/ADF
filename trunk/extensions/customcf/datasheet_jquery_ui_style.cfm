<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2011.
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
	datasheet_jquery_ui_style.cfm
Summary:
	Renders the JQuery UI headers for a datasheet.
	
	THIS IS ONLY A STARTER FILE! 
	FOLLOW the steps below to implement.
History:
	2009-07-20 - MFC - Created
	2011-03-09 - MFC - Updated to include the ADD button, 
						removed JQuery "$", 
						and added comments to customize
	2011-05-10 - GAC -  Added a variable to set the jQueryUI theme 
						Replaced link code with the UI lib component call to the buildAddEditLink method
						- This moves the hardcoded "Forms_1_1" method url parameter to inside the buildAddEditLink method call
						- This moves the call to getFormIDByCEName inside the buildAddEditLink method call
						- This moves the lightbox URL variable "application.ADF.ajaxProxy" to inside the buildAddEditLink and updates it to application.ADF.lightboxProxy for ADF 1.5
	2011-06-23 - MFC - Updated to allow for adding this custom script directly to the page using attributes.
	2011-08-23 - MFC - Updated to allow JQuery UI theme as custom element attributes.
--->

<!--- STEPS TO IMPLEMENT
Option 1:
	1. Add a custom script element to a page and define the custom module as:
		/ADF/extensions/customcf/datasheet_jquery_ui_style.cfm
	2. Define the Custom Script parameters with the following variables:
		ceName={NAME OF THE CUSTOM ELEMENT}
	3. Optional - Define the JQuery UI Theme parameters with the following variables:
		uiTheme={NAME OF THE JQuery UI Theme}
Option 2:
	1. Copy this script to your site "/customcf/" directory.
	2. Rename the copied file to specify the custom element name
		(ex. "profile_manager.cfm", "myElement_manager.cfm")
	3. Edit the "TODO" comment lines to define the custom element name, the text for the Add New button 
		and the jQuery UI theme name.
	4. Add this custom script to a page and then configure the datasheet.
 --->
<cfscript>
	// TODO - Add in custom element name that this manager is working with.
	ceName = "";
	// TODO - Add the text for the button to Add New.
	request.params.addButtonTitle = "Add New Record";
	// TODO - Set the jQuery UI Theme 
	uiTheme = "ui-lightness";
	
	// Check if the "ceName" is defined in the attributes
	if ( StructKeyExists(attributes,"ceName") ) {
		ceName = attributes.ceName;
		request.params.addButtonTitle = "Add New #ceName#";
	}
	
	// Check if the "ceName" is defined in the attributes
	if ( StructKeyExists(attributes,"uiTheme") ) {
		uiTheme = attributes.uiTheme;
	}
	
	// Load the jQuery scripts 
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQueryUI(themeName=UItheme);
	application.ADF.scripts.loadADFLightbox();
	
	
	// TODO: Uncomment the "request.params.formid" line if you would like the formid available to
	//       your datasheet modules or other scripts on your page
	// Get the CE Form ID
	//request.params.formid = application.ADF.cedata.getFormIDByCEName(ceName);
</cfscript>

<cfoutput>
<script type="text/javascript">
	jQuery(function() {
		// Hover states on the static widgets
		jQuery("div.ds-icons, a.add-button").hover(
			function() { jQuery(this).addClass('ui-state-hover'); },
			function() { jQuery(this).removeClass('ui-state-hover'); }
		);
	});
</script>

<style>
	a.add-button {
		padding: 1px 10px;
		text-decoration: none;
		margin-left: 20px;
		width: 115px;
		height: 16px;
	}
	div.ds-icons {
		padding: 1px 10px;
		text-decoration: none;
		margin-left: 20px;
		width: 30px;
	}
</style>

<div id="addNew" style="padding:20px;">
	<cfif LEN(request.user.userid)>
		<!--- <a href="javascript:;" rel="#application.ADF.ajaxProxy#?bean=Forms_1_1&method=renderAddEditForm&formid=#request.params.formid#&datapageid=0&lbAction=refreshparent&title=#request.params.addButtonTitle#&addMainTable=false" id="addNew" title="#request.params.addButtonTitle#" class="ADFLightbox add-button ui-state-default ui-corner-all">#request.params.addButtonTitle#</a><br /> --->
		#application.ADF.ui.buildAddEditLink(
					linkTitle=request.params.addButtonTitle
					,formName=ceName
					,dataPageID=0
					,refreshparent=true
					,urlParams=""
					,lbTitle=request.params.addButtonTitle
					,linkClass="add-button ds-icons ui_button ui-state-default ui-corner-all"
					,uiTheme=uiTheme
				)#
	<cfelse>
		Please <a href="#request.subsitecache[1].url#login.cfm">LOGIN</a> to add new records.<br />
	</cfif>
</div>
</cfoutput>

<!--- Render for the datasheet module --->
<CFMODULE TEMPLATE="/commonspot/utilities/ct-render-named-element.cfm"
	elementtype="datasheet"
	elementName="customDatasheetJQueryUIStyles">
