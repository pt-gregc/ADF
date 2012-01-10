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
	Renders a generic element management page
	Remember to specify the parameter of elementName=My Element Name
History:
	2011-09-01 - RAK - Created
	2011-09-01 - RAK - Added multiple element support
	2011-12-08 - GAC - Added attribute for themeName that can be passed via the customcf parameters dialog 
	2012-01-05 - GAC - Added attributes for hiding the 'add new' button and for securing the 'add new' button
	2012-01-10 - MFC - Updated HTML to make the tabs work. 
						Added condition to not render tabs when only 1 element.
						Added JQuery Cookie to remember the last tab visited. 
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
			
			// Set the Add New Button defaults
			displayAddNewButton = true; // Display the add new button
			secureAddNewButton = true;
			lockAddNewButton = false;  
			
			if ( StructKeyExists(attributes,"showAddNewButton") AND IsBoolean(attributes.showAddNewButton) )
				displayAddNewButton = attributes.showAddNewButton; 
					
			if ( StructKeyExists(attributes,"useAddNewSecurity") AND IsBoolean(attributes.useAddNewSecurity) )
				secureAddNewButton = attributes.useAddNewSecurity;
			
			// Security Check for Add New Button	
			if ( secureAddNewButton AND LEN(request.user.userid) EQ 0 )	
				lockAddNewButton = true;	
				
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
						elementName = ListGetAt(attributes.elementName,i);
						elementFormID = application.ADF.ceData.getFormIDByCEName(elementName);
						customControlName = "customManagementFor#replace(elementName,' ','','ALL')#";
					</cfscript>
					<br/>
					<br/>
					<cfif lockAddNewButton>
						<cfif displayAddNewButton>
							<input type="button"
								rel="#application.ADF.ajaxProxy#?bean=#beanName#&method=renderAddEditForm&formID=#elementFormID#&lbAction=refreshparent&title=New #attributes.elementName#&datapageid=0"
								class="ADFLightbox ui-button ui-state-default ui-corner-all"
								value="New #elementName#" />
							<br/>
							<br/>
						</cfif>
					<cfelse>
						<cfif displayAddNewButton>
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
		Please add the parameter of elementName=My Element Name so this administration page can function.
	</cfif>
</cfoutput>