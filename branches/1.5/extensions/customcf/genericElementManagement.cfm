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
--->
<cfoutput>
	<cfif structKeyExists(attributes,"elementName")>
		<cfscript>
			application.ADF.scripts.loadJQuery();
			application.ADF.scripts.loadJQueryUI();
			application.ADF.scripts.loadADFLightbox();
			elementFormID = application.ADF.ceData.getFormIDByCEName(attributes.elementName);
			customControlName = "customManagementFor#replace(attributes.elementName,' ','','ALL')#";
		</cfscript>
		<style>
			input.ui-button:hover{
				cursor:pointer;
			}
		</style>
		<script type="text/javascript">
			jQuery(document).ready(function(){
				// Hover states on the static widgets
				jQuery("input.ui-button").hover(
					function() {
						$(this).addClass('ui-state-hover');
					},
					function() {
						$(this).removeClass('ui-state-hover');
					}
				);
			});
		</script>
		<input type="button"
				rel="#application.ADF.ajaxProxy#?bean=Forms_1_1&method=renderAddEditForm&formID=#elementFormID#&lbAction=refreshparent&title=New #attributes.elementName#&datapageid=0"
				class="ADFLightbox ui-button ui-state-default ui-corner-all"
				value="New #attributes.elementName#" />
		<br/>
		<br/>
		<CFMODULE TEMPLATE="/commonspot/utilities/ct-render-named-element.cfm"
			elementtype="datasheet"
			elementName="#customControlName#">
	<cfelse>
		Please add the parameter of elementName=My Element Name so this administration page can function.
	</cfif>
</cfoutput>