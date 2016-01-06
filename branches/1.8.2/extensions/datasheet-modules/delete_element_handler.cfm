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
	2011-04-07 - RAK - Created display for CS 6.1 and above because we cant do our previous schemes for the confirmation
	2011-06-22 - GAC - Added a callback ID list param in the request.params that are being passed to the callback function 
						to include IDs of records to be modified by the callback other than the one being deleted 
	2012-11-01 - DMB - Added exclusion to field loop to prevent the doDelete form field from appearing twice in the form and breaking the logic of the app.
--->
<cfscript>
	if (NOT StructKeyExists(Request.Params,"doDelete"))
		Request.Params.doDelete = 0;
</cfscript>

<!---If its 6.1 we need to render the forms ourseleves because we cant specify the action properly.--->
<cfif application.ADF.csVersion GTE 6.1 and Request.Params.doDelete EQ 0>
	<cfoutput>
		#application.ADF.ui.lightboxHeader(lbCheckLogin=true)#
		<tr>
			<td class="cs_dlgNormal">
				<form action="/ADF/extensions/datasheet-modules/delete_element_handler.cfm?subsiteURL=#request.subsite.url#" method="post">
					<input type="hidden" value="1" name="dodelete">
					<CFLOOP index="fld" list="#StructKeyList(Request.Params)#">
						<cfif (fld NEQ 'csModule') and (fld NEQ 'doDelete')>
							<input type="hidden" name="#fld#" value="#Request.Params[fld]#"/>
						</CFIF>
					</CFLOOP>
					<div align="center">
						Are you sure you wish to delete this record?
						<br /><br />
						<CFMODULE TEMPLATE="/commonspot/dlgcontrols/ct-common-pushbuttons.cfm"
								HelpID="#CD_dialogName#"
								OK="1"
								OKLabel="Yes"
								OKButtonClass="clsGeneralButton"
								Cancel="1"
								CancelLabel="No"
								CancelButtonClass="clsCancelButton">
					</div>
				</form>
			</td>
		</tr>
		<!--- Render the dlg footer --->
		#application.ADF.ui.lightboxFooter()#
	</cfoutput>
	<!---We dont want to process anymore because we already displayed the form.--->
	<CFEXIT>
</cfif>


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
					<cfif StructKeyExists(request.params,"cbIDlist") AND LEN(TRIM(request.params.cbIDlist))>
					,cbIDlist: '#request.params.cbIDlist#'
					</cfif>
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
