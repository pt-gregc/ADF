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
	M. Carroll
Name:
	delete_element_handler.cfm
Summary:
	Invokes the CommonSpot datasheet delete form data modules.
History:
	2010-03-12 - MFC - Created
	2010-12-14 - MFC - Added Callback functionality for the Lightbox and
						Dialog header and footers.
	2011-01-25 - RAK - Updating to use ADF lightbox, fixed bugs with callback 
						functionality and improved ability
	2011-03-31 - MFC - Updated for the security check before running the delete function.
	2011-04-05 - MFC - Fixed the variable name in the callback JS.
--->

<!--- // if we are returning then handle the delete --->
<cfif (StructKeyExists(Request.Params,"doDelete")) AND (Request.Params.doDelete neq 0)>
	<!--- Load ADF Lightbox for callback function --->
	<cfscript>
		application.ADF.scripts.loadADFLightbox();
	</cfscript>
	
	<!--- Render the dlg header --->
	<cfoutput>#application.ADF.ui.lightboxHeader(lbCheckLogin=true)#</cfoutput>
	
	<!--- Verify the security for the logged in user --->
	<cfif application.ADF.csSecurity.isValidContributor() OR application.ADF.csSecurity.isValidCPAdmin()>
		<!--- Delete the CE record --->
		<cfif (Request.Params.FormID NEQ 0) AND (Request.Params.PageID NEQ 0)>
			<cfscript>
				application.ADF.cedata.deleteCE(datapageidList=Request.Params.PageID);
			</cfscript>
		</cfif>
		<cfoutput><div style="width:100%;text-align:center;" class="cs_dlgNormal">Record deleted successfully</div></cfoutput>
		<!--- Call the Callback function if defined --->
		<cfif StructKeyExists(request.params,"callback") and LEN(request.params.callback)>
			<cfoutput>
			<script type="text/javascript">
				// Set back the lightbox callback
				var values = {
					dataPageID: #request.params.PageID#,
					formID: #request.params.FormID#
				};
				getCallback('#request.params.callback#',values);
			</script>
			</cfoutput>
		<cfelse>
			<cfoutput>#application.ADF.forms.closeLBAndRefresh()#</cfoutput>
		</cfif>
	<cfelse>
		<cfoutput>
			<div style="width:100%;text-align:center;" class="cs_dlgNormal">
				Access denied to delete records through this module.<br /><br />
				Please contact the site administrator.
			</div>
		</cfoutput>
	</cfif>

	<!--- Render the dlg footer --->
	<cfoutput>#application.ADF.ui.lightboxFooter()#</cfoutput>
<cfelse>
	<!--- // Include the CommonSpot process for a datasheet --->	
	<cfinclude template="/commonspot/controls/datasheet/cs-delete-form-data.cfm">
</cfif>