<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2012.
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
 edit-delete.cfc
Summary:
	Prints out edit/delete buttons for your datasheet. This uses forms_1_1 and auto detects its information.
History:
	2011-02-07 - RAK - Created
	2011-02-15 - RAK - Updated to handle client side sorting in a better way.
	2011-03-11 - MFC - Updated to add class "ADF-Edit-Delete" to TD for custom styling.
	2012-03-08 - MFC - Updated the styles for the buttons to align left and be a fixed width.
	2012-08-27 - MFC - Updated the styles for the buttons to be fixed width.
	2012-09-18 - MFC - Add a blank sort value to field.
--->
<cfscript>
	//Path to open the ligthbox to
	AjaxPath = application.ADF.ajaxProxy;
	//Bean to preform add/edit
	AjaxBean = "forms_1_1";
	AjaxMethod = "renderAddEditForm";
	//Bean to preform deletion
	AjaxDeleteBean = "forms_1_1";
	AjaxDeleteMethod = "renderDeleteForm";


//*******Modification below this should not be needed.*******

	formID = edata.MetadataForm;

	mouseoverJS = "jQuery(this).addClass('ui-state-hover')";
	mouseoutJS = "jQuery(this).removeClass('ui-state-hover')";

	addEditLink = "#ajaxPath#?bean=#AjaxBean#&method=#AjaxMethod#&formid=#formID#&dataPageId=#Request.DatasheetRow.pageid#&lbAction=refreshparent&title=Edit";
	deleteLink = "#ajaxPath#?bean=#AjaxDeleteBean#&method=#AjaxDeleteMethod#&formid=#formID#&dataPageid=#Request.DatasheetRow.pageid#&title=Delete";
</cfscript>

<!--- Need to use cfhtmlhead because if I have a </script> tag it will break the javascript sorting on the datasheet--->
<cfsavecontent variable="headerData">
	<cfoutput>
		#application.ADF.scripts.loadJQuery()#
		#application.ADF.scripts.loadJQueryUI()#
		#application.ADF.scripts.loadADFLightbox()#
	</cfoutput>
</cfsavecontent>
<!---If client side sorting is enabled we need to put stuff in the headers--->
<cfif eparam.permitClientSideSort>
	<cfhtmlhead text="#headerData#">
</cfif>

<cfsavecontent variable="tdHTML">
	<cfoutput>
		<!---	If client side sorting is disabled put the load JQuery information in the better location--->
		<td align="left" valign="middle" class="ADF-Edit-Delete" style="width:150px;">
			<cfif not eparam.permitClientSideSort>
				#headerData#
			</cfif>
			<style>
				.ds-icons {
					padding: 1px 5px;
					text-decoration: none;
					margin-left: 5px;
					margin-right: 5px;
					width: 16px;
				}
				.ds-icons:hover{
					cursor:pointer;
				}
			</style>
			<table>
				<tr>
					<td>
						<div rel="#addEditLink#" title="Edit" class="ADFLightbox">
							<div class='ds-icons ui-state-default ui-corner-all' title='edit' onmouseover="#mouseoverJS#" onmouseout="#mouseoutJS#">
								<div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-pencil'>
								</div>
							</div>
						</div>
					</td>
					<td>
						<div rel="#deleteLink#" title="Delete" class="ADFLightbox">
							<div class='ds-icons ui-state-default ui-corner-all' title='delete' onmouseover="#mouseoverJS#" onmouseout="#mouseoutJS#">
								<div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-trash'>
								</div>
							</div>
						 </div>
					</td>
				</tr>
			</table>
		</td>
	</cfoutput>
</cfsavecontent>
<cfset request.datasheet.currentFormattedValue = tdHTML>
<!--- Add a blank sort value --->
<cfset request.datasheet.currentSortValue = "">