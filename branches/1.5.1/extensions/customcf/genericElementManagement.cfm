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
/* *********************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	genericElementManagement.cfm
Summary:
	Renders a custom element datasheet management page 
	- Adds a datasheet element on a tabbed interface when more than one custom element is specified 
	- An optional 'Add Button' is added above each datasheet element
Attributes:
	elementName - a comma-delimited list of Custom Element Names (required: at least one elementName is needed)
	themeName - the name of a jQueryUI theme (default: the ADF standard theme for jQueryUI - ui-lightness)
	showAddButton -  true/false to show the 'Add Button' or not (default: true)
	useAddButtonSecurity - true/false to enable or disable security for the 'Add Button' (default: true)
Attributes Examples:
	elementName=My Element One,My Element Two,My Element Three
	themeName=redmond
	showAddButton=true
	useAddButtonSecurity=true
History:
	2011-09-01 - RAK - Created
	2011-09-01 - RAK - Added multiple element support
	2011-12-08 - GAC - Added attribute for themeName that can be passed via the customcf parameters dialog 
	2012-01-05 - GAC - Added attribute for hiding the 'Add Button' 
					 - Added attrubutes for securing the 'Add Button' 
	2012-01-10 - MFC - Updated HTML to make the tabs work. 
						Added condition to not render tabs when only 1 element.
						Added JQuery Cookie to remember the last tab visited. 
	2012-01-10 - GAC - Fixed the logic for the show/hide of the 'Add Button'
					 - Fixed the logic for securing 'Add Button' 
					 - Fixed the 'Add Button' Lightbox Title so it doesn't pass the full list of the elementNames
					 - Added additional comments for the attributes that can be passed in via the custom script parameters tab
--->
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
			
			// Set the 'Add Button' display defaults
			displayAddButton = true; // Display the 'Add Button'
			secureAddButton = true;  // Only show 'Add Button' if user is logged in 
			
			// Set the flag for the locking a secured 'Add Button'
			enableAddButton = true; 			 
			
			// Check to see if the attribute 'showAddButton' was passed in
			// - attributes.showAddButton=false takes presidence over enableAddButton=true
			if ( StructKeyExists(attributes,"showAddButton") AND IsBoolean(attributes.showAddButton) )				
				displayAddButton = attributes.showAddButton; 

			// Check to see if the attribute 'useAddButtonSecurity' was passed in
			if ( StructKeyExists(attributes,"useAddButtonSecurity") AND IsBoolean(attributes.useAddButtonSecurity) )
				secureAddButton = attributes.useAddButtonSecurity;
			
			// Security Check for 'Add Button'
			// - enableAddButton=false takes presidence over attributes.showAddButton=true	
			if ( secureAddButton AND (LEN(request.user.userid) EQ 0 OR request.user.userid EQ "anonymous") )
				enableAddButton = false;	

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
			input.ui-button:hover{
				cursor:pointer;
			}
		</style>
		<script type="text/javascript">
			jQuery(document).ready(function(){
				// Load jquery cookie to remember the last tab visited
				jQuery('##tabs').tabs( { cookie: { expires: 30 } } );
				// Hover states on the static widgets
				jQuery("input.ui-button").hover(
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
						<li><a href="##tabs-#i#" title="tabs-#i#">#ListGetAt(attributes.elementName,i)#</a></li>
					</cfloop>
				</ul>
			</cfif>
			<cfloop from="1" to="#listLen(attributes.elementName)#" index="i">
				<div id="tabs-#i#">
					<cfscript>
						ceName = ListGetAt(attributes.elementName,i);
						ceFormID = application.ADF.ceData.getFormIDByCEName(ceName);
						customControlName = "customManagementFor#replace(ceName,' ','','ALL')#";
					</cfscript>
					<br/>
					<br/>
					<cfif enableAddButton>
						<cfif displayAddButton>
							<input type="button"
								rel="#application.ADF.ajaxProxy#?bean=#beanName#&method=renderAddEditForm&formID=#ceFormID#&lbAction=refreshparent&title=New #ceName#&datapageid=0"
								class="ADFLightbox ui-button ui-state-default ui-corner-all"
								value="New #ceName#" />
							<br/>
							<br/>
						</cfif>
					<cfelse>
						<cfif displayAddButton>
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