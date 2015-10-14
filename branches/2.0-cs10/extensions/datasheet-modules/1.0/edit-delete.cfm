<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
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
	edit-delete.cfm
Summary:
	Renders jQueryUI edit/delete buttons for your datasheet. 
	This uses forms_1_1 and auto detects its information.
History:
	2011-02-07 - RAK - Created
	2011-02-15 - RAK - Updated to handle client side sorting in a better way.
	2011-03-11 - MFC - Updated to add class "ADF-Edit-Delete" to TD for custom styling.
	2012-03-08 - MFC - Updated the styles for the buttons to align left and be a fixed width.
	2012-08-27 - MFC - Updated the styles for the buttons to be fixed width.
	2012-09-18 - MFC - Add a blank sort value to field.
	2014-10-03 - GAC - Added renderOnce login around the .ds-icon style block
	2015-06-26 - GAC - Added logic to disable the edit or disable the delete button
	2015-10-13 - GAC - Updated so the ADFlighbox calls use forms_2_0  
					 - Updated to pass in a callback from the request scope set in a header script
					 - Updated for ADF 2.0 and CommonSpot 10 loadResources()
	2015-10-14 - GAC - Updated to allow Client Side JS sorting to be enabled
--->
<cfscript>
	//Path to open the ligthbox to
	AjaxPath = application.ADF.lightboxProxy;
	//Bean to preform add/edit
	AjaxBean = "forms_2_0";
	AjaxMethod = "renderAddEditForm";
	//Bean to preform deletion
	AjaxDeleteBean = "forms_2_0";
	AjaxDeleteMethod = "renderDeleteForm";

//*******Modification below this should not be needed.*******

	// Check for Local Button Rendering Overrides
	if ( !StructKeyExists(variables,"adfDSmodule") )
		variables.adfDSmodule = StructNew();

	if ( !StructKeyExists(variables.adfDSmodule,"renderEditBtn") OR !IsBoolean(variables.adfDSmodule.renderEditBtn) )
		variables.adfDSmodule.renderEditBtn = true;
	if ( !StructKeyExists(variables.adfDSmodule,"renderDeleteBtn") OR !IsBoolean(variables.adfDSmodule.renderDeleteBtn) )
		variables.adfDSmodule.renderDeleteBtn = true;

	formID = edata.MetadataForm;

	addEditLink = "";
	deleteLink = "";

	urlParams = "";

	mouseoverJS = "jQuery(this).addClass('ui-state-hover')";
	mouseoutJS = "jQuery(this).removeClass('ui-state-hover')";

	// Check for global ADF Datasheet Module overrides in request scope
	if ( StructKeyExists(request,"adfDSmodule") )
	{
		if (StructKeyExists(request.adfDSmodule, "urlParams"))
			urlParams = TRIM(request.adfDSmodule.urlParams);

		if ( LEN(urlParams) AND Find("&",urlParams,"1") NEQ 1 )
			urlParams = "&" & urlParams;
	}

	if ( variables.adfDSmodule.renderEditBtn )
		addEditLink = "#ajaxPath#?bean=#AjaxBean#&method=#AjaxMethod#&formid=#formID#&dataPageId=#Request.DatasheetRow.pageid#&lbAction=refreshparent&title=Edit#urlParams#";
	
	if ( variables.adfDSmodule.renderDeleteBtn )
		deleteLink = "#ajaxPath#?bean=#AjaxDeleteBean#&method=#AjaxDeleteMethod#&formid=#formID#&dataPageid=#Request.DatasheetRow.pageid#&title=Delete#urlParams#";

	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQueryUI();
	application.ADF.scripts.loadADFLightbox();
</cfscript>

<!--- // REMOVE - the headerData to switch to the ADF 2.0 and CommonSpot 10 loadResources() style --->
<!--- Need to use cfhtmlhead because if I have a </script> tag it will break the javascript sorting on the datasheet--->
<!--- <cfsavecontent variable="headerData">
	<cfoutput>
		#application.ADF.scripts.loadJQuery()#
		#application.ADF.scripts.loadJQueryUI()#
		#application.ADF.scripts.loadADFLightbox()#
	</cfoutput>
</cfsavecontent> --->
<!---If client side sorting is enabled we need to put stuff in the headers--->
<!--- <cfif eparam.permitClientSideSort>
	<cfhtmlhead text="#headerData#">
</cfif> --->

<!--- // Add the ADF DS modules STYLE as a CSS Resource but only render it once --->
<cfif !StructKeyExists(request,"dsEditDeleteRenderOnce")>
	<cfsavecontent variable="adfDataSheetModHeaderCSS">
		<cfoutput>
		<!--- <style> --->
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
		<!--- </style> --->
		</cfoutput>
	</cfsavecontent>
	
	<cfif eparam.permitClientSideSort>
	<cfsavecontent variable="adfDataSheetModFooterJS">
		<cfoutput>
		<!--- <script> --->
			jQuery(document).on('click','.CS_DataSheet_HeaderItem_First_Column,.CS_DataSheet_HeaderItem_Column',function() {
		    	initADFLB();
			});
		<!--- </script> --->
		</cfoutput>
	</cfsavecontent>
	</cfif>
	
	<cfscript>
		// Load the inline CSS as a CSS Resource
		application.ADF.scripts.addHeaderCSS(adfDataSheetModHeaderCSS, "TERTIARY"); //  PRIMARY, SECONDARY, TERTIARY
		// Load the inline JS as a JS Resource
		if ( eparam.permitClientSideSort )
			application.ADF.scripts.addFooterJS(adfDataSheetModFooterJS, "TERTIARY"); //  PRIMARY, SECONDARY, TERTIARY
	</cfscript>
	<cfset request.dsEditDeleteRenderOnce = true>
</cfif>

<cfsavecontent variable="tdHTML">
	<cfoutput>		
		<td align="left" valign="middle" class="ADF-Edit-Delete" style="width:150px;">
			<!--- // REMOVE - If client side sorting is disabled put the load JQuery information in the better location--->
			<!--- <cfif not eparam.permitClientSideSort>
				#headerData#
			</cfif> --->
			<!--- <cfif !StructKeyExists(request,"dsEditDeleteRenderOnce")>
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
				<cfset request.dsEditDeleteRenderOnce = true>
			</cfif> --->
			<table>
				<tr>
				<cfif variables.adfDSmodule.renderEditBtn>
					<td>
						<div rel="#addEditLink#" title="Edit" class="ADFLightbox">
							<div class='ds-icons ui-state-default ui-corner-all' title='edit' onmouseover="#mouseoverJS#" onmouseout="#mouseoutJS#">
								<div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-pencil'>
								</div>
							</div>
						</div>
					</td>
				</cfif>
				<cfif variables.adfDSmodule.renderDeleteBtn>
					<td>	
						<div rel="#deleteLink#" title="Delete" class="ADFLightbox">
							<div class='ds-icons ui-state-default ui-corner-all' title='delete' onmouseover="#mouseoverJS#" onmouseout="#mouseoutJS#">
								<div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-trash'>
								</div>
							</div>
						 </div>
					</td>
				</cfif>
				</tr>
			</table>
		</td>
	</cfoutput>
</cfsavecontent>
<cfset request.datasheet.currentFormattedValue = tdHTML>
<!--- Add a blank sort value --->
<cfset request.datasheet.currentSortValue = "">