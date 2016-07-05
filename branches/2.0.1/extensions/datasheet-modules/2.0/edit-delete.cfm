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
Name:
	edit-delete.cfm
Summary:
	Renders Buttons (jQueryUI/Bootstrap/FontAwesome) edit/delete buttons for your datasheet. 
	This uses forms_2_0 and auto detects its information.
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
	2016-06-28 - GAC - Updated to use request scope to work with ceManagement 2.1
							- Updated to work with other JS/CSS button/icon libs beside jQueryUI
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
	adfDataSheetModHeaderCSS = "";
	adfDataSheetModFooterJS = "";
	
	// Check for Local Button Rendering Overrides
	if ( !StructKeyExists(request,"adfDSmodule") )
		request.adfDSmodule = StructNew();

	if ( !StructKeyExists(request.adfDSmodule,"renderEditBtn") OR !IsBoolean(request.adfDSmodule.renderEditBtn) )
		request.adfDSmodule.renderEditBtn = true;
	if ( !StructKeyExists(request.adfDSmodule,"renderDeleteBtn") OR !IsBoolean(request.adfDSmodule.renderDeleteBtn) )
		request.adfDSmodule.renderDeleteBtn = true;
	if ( !StructKeyExists(request.adfDSmodule,"useJQueryUI") OR !IsBoolean(request.adfDSmodule.useJQueryUI) )
		request.adfDSmodule.useJQueryUI = true;
		
	// Bootstrap and FontAwesome: set to False by default
	if ( !StructKeyExists(request.adfDSmodule,"useBootstrap") OR !IsBoolean(request.adfDSmodule.useBootstrap) )
		request.adfDSmodule.useBootstrap = false;
	if ( !StructKeyExists(request.adfDSmodule,"useFontAwesome") OR !IsBoolean(request.adfDSmodule.useFontAwesome) )
		request.adfDSmodule.useFontAwesome = false;
	
	if ( !StructKeyExists(request.adfDSmodule,"buttonStyle") OR LEN(TRIM(request.adfDSmodule.buttonStyle)) EQ 0 )
		request.adfDSmodule.buttonStyle = "";
	if ( !StructKeyExists(request.adfDSmodule,"buttonSize") OR LEN(TRIM(request.adfDSmodule.buttonSize)) EQ 0 )
		request.adfDSmodule.buttonSize = "";
		
	formID = edata.MetadataForm;

	if ( request.adfDSmodule.useBootstrap )
	{
		if ( LEN(TRIM(request.adfDSmodule.buttonStyle)) EQ 0 ) 
			request.adfDSmodule.buttonStyle = "btn-primary";
			
		if ( LEN(TRIM(request.adfDSmodule.buttonSize)) EQ 0 ) 
			request.adfDSmodule.buttonSize = "btn-xs";
	}
	
	if ( request.adfDSmodule.useFontAwesome )
	{
		if ( LEN(TRIM(request.adfDSmodule.buttonStyle)) EQ 0 ) 
			request.adfDSmodule.buttonStyle = "fa-square";
			
		if ( LEN(TRIM(request.adfDSmodule.buttonSize)) EQ 0 ) 
			request.adfDSmodule.buttonSize = "fa-1x";
	}

	mouseoverJS = "";
	mouseoutJS = "";
	if ( request.adfDSmodule.useJQueryUI )
	{
		mouseoverJS = "jQuery(this).addClass('ui-state-hover')";
		mouseoutJS = "jQuery(this).removeClass('ui-state-hover')";

		if ( LEN(TRIM(request.adfDSmodule.buttonStyle)) EQ 0 )
			request.adfDSmodule.buttonStyle = "ui-corner-all";
	}
	
	urlParams = "";
	if (StructKeyExists(request.adfDSmodule, "urlParams"))
		urlParams = TRIM(request.adfDSmodule.urlParams);

	if ( LEN(urlParams) AND Find("&",urlParams,"1") NEQ 1 )
		urlParams = "&" & urlParams;
	
	addEditLink = "";
	if ( request.adfDSmodule.renderEditBtn )
		addEditLink = "#ajaxPath#?bean=#AjaxBean#&method=#AjaxMethod#&formid=#formID#&dataPageId=#Request.DatasheetRow.pageid#&lbAction=refreshparent&title=Edit#urlParams#";

	deleteLink = "";
	if ( request.adfDSmodule.renderDeleteBtn )
		deleteLink = "#ajaxPath#?bean=#AjaxDeleteBean#&method=#AjaxDeleteMethod#&formid=#formID#&dataPageid=#Request.DatasheetRow.pageid#&title=Delete#urlParams#";

	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadADFLightbox();

	// Load Icon Library Script (if not already loaded)
	if ( request.adfDSmodule.useBootstrap )
		application.ADF.scripts.loadBootstrap();

	if ( request.adfDSmodule.useFontAwesome )
		application.ADF.scripts.loadFontAwesome();

	if ( request.adfDSmodule.useJQueryUI )
		application.ADF.scripts.loadJQueryUI();
</cfscript>

<!--- // Add the ADF DS modules STYLE as a CSS Resource but only render it once --->
<cfif Request.DataSheetRow.CurrentRow EQ 1>
	<cfsavecontent variable="adfDataSheetModHeaderCSS">
		<cfoutput>
		<style>
		<cfif request.adfDSmodule.useBootstrap>
			.ds-icons {
				margin: 1px;
			}
			
		<cfelseif request.adfDSmodule.useFontAwesome>
			.ds-icons {
				/* margin: 1px; */
			}
			
		<cfelse>
			.ds-icons {
				padding: 1px 5px;
				text-decoration: none;
				margin-left: 5px;
				margin-right: 5px;
				width: 16px;
			}
			
		</cfif>
			.ds-icons:hover {
				cursor: pointer;
			}
		</style>
		</cfoutput>
	</cfsavecontent>
	
	<cfif eparam.permitClientSideSort>
	<cfsavecontent variable="adfDataSheetModFooterJS">
		<cfoutput>
		    <script>
				//initADFLB();
			
				jQuery(document).on('click','.ds-icons,.CS_DataSheet_HeaderItem_First_Column,.CS_DataSheet_HeaderItem_Column',function() {
			    	initADFLB();
				});
			</script>
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
</cfif>

<cfsavecontent variable="tdHTML">
	<cfoutput>		
		<td align="left" valign="middle" class="ADF-Edit-Delete" style="width:150px;">
			<table>
				<tr>
				<cfif request.adfDSmodule.renderEditBtn>
					<td>
						<cfif request.adfDSmodule.useBootstrap>
							<a href="javascript:;" rel="#addEditLink#" title="Edit" class="ADFLightbox btn #request.adfDSmodule.buttonStyle# #request.adfDSmodule.buttonSize# ds-icons">
								<span class="glyphicon glyphicon-pencil"></span>
							</a>
						<cfelseif request.adfDSmodule.useFontAwesome>
							<a href="javascript:;" rel="#addEditLink#" title="Edit" class="ADFLightbox ds-icons">
								<span class="fa-stack #request.adfDSmodule.buttonSize#">
								  <i class="fa #request.adfDSmodule.buttonStyle# fa-stack-2x"></i>
								  <i class="fa fa-pencil fa-stack-1x fa-inverse"></i>
								</span>
							</a>
						<cfelse>
							<div rel="#addEditLink#" title="Edit" class="ADFLightbox">
								<div class='ds-icons ui-state-default #request.adfDSmodule.buttonStyle#' title='edit' onmouseover="#mouseoverJS#" onmouseout="#mouseoutJS#">
									<div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-pencil'></div>
								</div>
							</div>
						</cfif>
					</td>
				</cfif>
				<cfif request.adfDSmodule.renderDeleteBtn>
					<td>
						<cfif request.adfDSmodule.useBootstrap>
							<a href="javascript:;" rel="#deleteLink#" title="Delete" class="ADFLightbox btn #request.adfDSmodule.buttonStyle# #request.adfDSmodule.buttonSize# ds-icons">
								<span class="glyphicon glyphicon-trash"></span>
							</a>
						<cfelseif request.adfDSmodule.useFontAwesome>
							<a href="javascript:;" rel="#deleteLink#" title="Delete" class="ADFLightbox ds-icons">
								<span class="fa-stack #request.adfDSmodule.buttonSize#">
									<i class="fa #request.adfDSmodule.buttonStyle# fa-stack-2x"></i>
									<i class="fa fa-trash-o fa-stack-1x fa-inverse"></i>
								</span>
							</a>
						<cfelse>
							<div rel="#deleteLink#" title="Delete" class="ADFLightbox">
								<div class='ds-icons ui-state-default #request.adfDSmodule.buttonStyle#' title='delete' onmouseover="#mouseoverJS#" onmouseout="#mouseoutJS#">
									<div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-trash'></div>
								</div>
							 </div>
						</cfif>
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