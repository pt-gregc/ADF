<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->
<!---
/* *********************************************************************** */
Author:
	PaperThin, Inc.
Name:
	genericElementManagement.cfm
Summary:
	Renders a custom element datasheet management page 
	- Adds a datasheet element on a tabbed interface when more than one custom element is specified 
	- An optional 'Add Button' is added above each datasheet element
Attributes:
	elementName - a comma-delimited list of Custom Element Names (required: at least one elementName is needed)
	themeName - the name of a jQueryUI theme (default: the ADF standard theme for jQueryUI - ui-lightness)
	showAddButtons -  a comma-delimited list of true/false for each element name to show the 'Add Button' or not  on each tab (default: true)
	useAddButtonSecurity - true/false to enable or disable security for the 'Add Button' (default: true)
	customAddButtonText - a comm-delimited list of custom "Add Button" names (default: Add New {{elementName}})
	formBeanName - Override the form bean (component) to open for the form.
	// App Level Override Parameters
	appBeanName - the AppBeanName of the app from the appBeanConfig.cfm file
	appParamsVarName - a variable name of a struct that contains key/values for the custom script attrubutes
	
	/* NOTE: When both of the  App Level Override Params (appBeanName and appParamsVarName) are defined in the Custom Script Parameters and together they can be evaluated to create a data structure 
	that defines key/value pairs, then the keys that match the standard Attributes will be used to OVERRIDE any additional attributes passed in. */

Custom Script Parameters Tab Examples:
	elementName=My Element One,My Element Two,My Element Three
	themeName=redmond
	showAddButtons=true,false,true 
	useAddButtonSecurity=true
	customAddButtonText=Add New Item 1, Add New Item 2, Add New Three
	appBeanName = ptBlog
	appParamsVarName = elementManagementParams
History:
	2011-09-01 - RAK - Created
	2011-09-01 - RAK - Added multiple element support
	2011-12-08 - GAC - Added attribute for themeName that can be passed via the customcf parameters dialog 
	2012-01-05 - GAC - Added attribute for hiding the 'Add Button' 
					 - Added attrubutes for securing the 'Add Button' 
	2012-01-10 - MFC - Updated HTML to make the tabs work. 
					 - Added condition to not render tabs when only 1 element.
					 - Added JQuery Cookie to remember the last tab visited. 
	2012-01-10 - GAC - Fixed the logic for the show/hide of the 'Add Button'
					 - Fixed the logic for securing 'Add Button' 
					 - Fixed the 'Add Button' Lightbox Title so it doesn't pass the full list of the elementNames
					 - Added additional comments for the attributes that can be passed in via the custom script parameters tab
					 - Added logic to handle a display option to show or hide the 'Add Button' on each tab using a a comma-delimited list of true/false values 
	2012-01-13 - GAC - Fixed logic for checking the comma-delimited list of boolean values passed in with the 'showAddButtons' attribute
	2012-03-08 - MFC - Call Forms buildAddEditLink for the Add New button.
	2012-03-09 - GAC - Updated the form.buildAddEditLink to use the buildAddEditLink in the UI lib (buildAddEditLink in form_1_0 is deprecated)
					 - Added a trim to the ceName value generated from the items passed in via the elementName parameter
					 - Updated comments for the code that builds structure key names and datasheet element names based on ceName values
	2012-05-08 - GAC - Fixed an issue with the displayAddButtonList variable name
					 - Added a option for custom "Add New" button text
	2013-01-15 - GAC - If tabs are not being rendered, then don't add additional line breaks.
	2013-02-13 - GAC - Added a hook to override the Attributes passed in from the Custom Script Parameters tab with a structure from an App 
					 - Updated to use a UTILS lib function to process the override 
	2013-02-22 - MFC - Added the "formBeanName" into the attributes.
	2013-10-15 - GAC - Updated the App Level Override Parameters comments
					 - Removed 'themeName' value from the paramsExceptionList in the appOverrideCSParams function. 
--->

<!--- // Optional ADF App Override Attributes for the Custom Script Parameters tab --->
<!--- // !!!! DO NOT MODIFY THIS OVERRIDE LOGIC to force changes via the Custom Script Parameters from the CommonSpot UI!!! --->
<cfscript>
	if ( StructKeyExists(attributes,"appBeanName") AND LEN(TRIM(attributes.appBeanName)) AND StructKeyExists(attributes,"appParamsVarName") AND LEN(TRIM(attributes.appParamsVarName)) ) {
		attributes = application.ADF.utils.appOverrideCSParams(
													csParams=attributes,
													appName=attributes.appBeanName,
													appParamsVarName=attributes.appParamsVarName,
													paramsExceptionList="appBeanName,appParamsVarName"
												);
	}
</cfscript>

<cfoutput>
	<cfif structKeyExists(attributes,"elementName") and Len(attributes.elementName)>
		<cfscript>
			application.ADF.scripts.loadJQuery();
			
			if ( StructKeyExists(attributes,"themeName") AND LEN(TRIM(attributes.themeName)) )
				application.ADF.scripts.loadJQueryUI(themeName=attributes.themeName);
			else
				application.ADF.scripts.loadJQueryUI();
				
			// Load jquery cookie to remember the last tab visited
			application.ADF.scripts.loadJQueryCookie();	
			application.ADF.scripts.loadADFLightbox();
			
			// Bean Name for the Add Button
			beanName = "Forms_1_1";
			// Check to see if the attribute 'formBeanName' was passed in.
			//	This will override the bean to open for the form
			if ( StructKeyExists(attributes,"formBeanName")
					AND LEN(TRIM(attributes.formBeanName)) )
				beanName = attributes.formBeanName;
			
			// Set the 'Add Button' display defaults
			displayAddButtonDefault = true; // Display the 'Add Button'
			secureAddButtons = true;  // Only show 'Add Button' if user is logged in 
			
			// Set the flag for the locking a secured 'Add Button'
			enableAddButton = true; 	
			// Create the struct for the 'Add Button' status  
			displayAddBtnOptions = StructNew();
			displayAddButtonList = "";
			
			// Set the Add Button Defualt Text
			addButtonTextDefault = "Add New {{elementName}}";
			customAddButtonTextList = "";
			
			// Check to see if the attribute 'showAddButtons' was passed in with a list of display option values
			// - attributes.showAddButtons=false takes presidence over enableAddButton=true
			if ( StructKeyExists(attributes,"showAddButtons") AND LEN(TRIM(attributes.showAddButtons)) )
			{				
				// Set the default if only one showAddButton option is passed in use it as the default for all
				if ( ListLen(attributes.showAddButtons) EQ 1 AND IsBoolean(attributes.showAddButtons) )
					displayAddButtonDefault = attributes.showAddButtons;
				else
					displayAddButtonList = attributes.showAddButtons;
			}
					
			// Build structure with CEName as the key and the 'Add Button' display option as the value
			for ( a=1;a LTE ListLen(attributes.elementName);a=a+1 ){
				ce = TRIM(ListGetAt(attributes.elementName,a));
				
				// Build a structure Key (without spaces) based on the CEName
				// to be used to store the Add Button display options for each element passed in
				elmt = REREPLACE(ce,"[\s]","","all");
				abtn = displayAddButtonDefault;

				// set the display value for each 'Add Button' for each element tab
				if ( a LTE ListLen(displayAddButtonList) )
					abtn = ListGetAt(displayAddButtonList,a);	
				// Set the elementName key of the struct with the status value
				if ( IsBoolean(abtn) )
					displayAddBtnOptions[elmt] = abtn;
				else
					displayAddBtnOptions[elmt] = displayAddButtonDefault;		
			}		

			// Check to see if the attribute 'useAddButtonSecurity' was passed in
			if ( StructKeyExists(attributes,"useAddButtonSecurity") AND IsBoolean(attributes.useAddButtonSecurity) )
				secureAddButtons = attributes.useAddButtonSecurity;
			
			// Security Check for 'Add Button'
			// - enableAddButton=false takes presidence over attributes.showAddButtons=true	
			if ( secureAddButtons AND (LEN(request.user.userid) EQ 0 OR request.user.userid EQ "anonymous") )
				enableAddButton = false;	

			// Check to see if the attribute 'customAddButtonText' was passed in with a list of display values
			if ( StructKeyExists(attributes,"customAddButtonText") AND LEN(TRIM(attributes.showAddButtons)) )
				customAddButtonTextList = attributes.customAddButtonText;
			
			// Check the list of elements to see if need the tabs.
			//	Set flag to render tabs or not
			//  Set the class name for the surrounding div based on if
			//		we are rendering tabs or not.
			if ( ListLen(attributes.elementName) GT 1 ) {
				renderTabFormat = true;
				divClass = "tabs";
			}
			else {
				renderTabFormat = false;			
				divClass = "no-tabs";
			}	
		</cfscript>
		<style>
			a.ui-button:hover{
				cursor:pointer;
			}
			a.ui-button {
				padding: 10px;
			}
		</style>
		<script type="text/javascript">
			jQuery(document).ready(function(){
				// Load jquery cookie to remember the last tab visited
				jQuery('##tabs').tabs( { cookie: { expires: 30 } } );
				// Hover states on the static widgets
				jQuery("a.ui-button").hover(
					function() {
						jQuery(this).addClass('ui-state-hover');
					},
					function() {
						jQuery(this).removeClass('ui-state-hover');
					}
				);
			});
		</script>
		<div id="#divClass#">
			<!--- Check if we want to render tabs --->
			<cfif renderTabFormat>
				<ul>
					<cfloop from="1" to="#listLen(attributes.elementName)#" index="i">
						<li><a href="##tabs-#i#" title="tabs-#i#">#TRIM(ListGetAt(attributes.elementName,i))#</a></li>
					</cfloop>
				</ul>
			</cfif>
			<cfloop from="1" to="#listLen(attributes.elementName)#" index="i">
				<div id="tabs-#i#">
					<cfscript>
						ceName = TRIM(ListGetAt(attributes.elementName,i));
						// Build an 'elementName' based on the CEName without spaces 
						// for the datasheet  "ct-render-named-element.cfm" call 
						custel = REREPLACE(ceName,"[\s]","","all");
						customControlName = "customManagementFor#custel#";
					</cfscript>
					<cfif renderTabFormat>
					<br/>
					<br/>
					</cfif>
					<cfif enableAddButton>
						<cfif StructKeyExists(displayAddBtnOptions,custel) AND displayAddBtnOptions[custel]>
							<!--- // Get the Custom Add Button Text if it was provided --->
							<cfif ListLen(customAddButtonTextList) GTE i>
								<cfset addBtnText = TRIM(ListGetAt(customAddButtonTextList,i))> 
							<cfelse>
								<cfset addBtnText = REPLACE(addButtonTextDefault,"{{elementName}}","#ceName#","one")><!--- // "New #ceName#" --->
							</cfif>
							<!--- // Call UI buildAddEditLink for the Add New button --->
							#application.ADF.UI.buildAddEditLink(linkTitle=addBtnText,
																	formName=ceName,
																	dataPageID=0,
																	refreshparent=true,
																	formBean=beanName,
																	formMethod="renderAddEditForm",
																	lbTitle=addBtnText,
																	linkClass="ui-button ui-state-default ui-corner-all")#
							<br/>
							<br/>
						</cfif>
					<cfelse>
						<cfif StructKeyExists(displayAddBtnOptions,custel) AND displayAddBtnOptions[custel]>
							Please <a href="#request.subsitecache[1].url#login.cfm">LOGIN</a> to add new records.
							<br/>
							<br/>
						</cfif>
					</cfif>
					<CFMODULE TEMPLATE="/commonspot/utilities/ct-render-named-element.cfm"
						elementtype="datasheet"
						elementName="#customControlName#">
				</div>
			</cfloop>
		</div>
	<cfelse>
		Please add the parameter of 'elementName=<strong>My Element Name</strong>'.  At least one Custom Element name is required for this administration custom script.
	</cfif>
</cfoutput>