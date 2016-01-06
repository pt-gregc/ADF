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
	PaperThin Inc.
	M. Carroll
Name:
	date_time_builder_actions.cfm
Summary:
	Custom field to build the Date/Time records.
	This field generates a collection of Date and Times for the field.
Version:
	1.0.0
History:
	2010-09-15 - MFC - Created
	2011-02-09 - RAK - Fixing issue where deletions were not processing properly
	2013-02-20 - MFC - Replaced Jquery "$" references.
	2014-10-08 - GAC - Removed version declarations from the loadJQuery and loadJQueryUI calls
--->
<!--- Check the params --->
<cfscript>
	// Create a script obj
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQueryUI();
	application.ADF.scripts.loadADFLightbox();
	
	// Action Param
	if ( NOT StructKeyExists(request.params, "action"))
		request.params.action = "form";

	// Form ID Param
	if ( NOT StructKeyExists(request.params, "formid"))
		request.params.formid = 0;
		
	// Data Page ID Param
	if ( NOT StructKeyExists(request.params, "datapageid"))
		request.params.datapageid = 0;

	// Call Back Function Param
	if ( NOT StructKeyExists(request.params, "cbFunct"))
		request.params.cbFunct = "";

	// UUID Param
	if ( NOT StructKeyExists(request.params, "uuid"))
		request.params.uuid = "";
		
	// UUID Param
	if ( NOT StructKeyExists(request.params, "linkUUID"))
		request.params.linkUUID = "";
		
	// Form status
	if ( NOT StructKeyExists(request.params, "renderResult"))
		request.params.renderResult = false;

	// Get the CE element form fields
	formElementFlds = application.ADF.forms.getCEFieldNameData("Date Time Builder Data");
	
	// Run this only if we are not in the select action
	if ( request.params.action NEQ "select" )
	{
		//	Check if we have the UUID but not the data page id.
		//		Then use cedata to get the data page id for the UUID.
		if ( (request.params.datapageid LTE 0) AND (LEN(request.params.uuid)) )
		{
			// Get the CE data for the uuid
			linkDataArray = application.ADF.ceData.getCEData(application.ADF.cedata.getCENameByFormID(request.params.formID), "uuid", request.params.uuid);
			// Check that we have linkDataArray
			if ( ArrayLen(linkDataArray) )
				request.params.datapageid = linkDataArray[1].pageid;
			
		}
	}
</cfscript>

<!--- build out the DIV blocks to render --->
<cfif request.params.action EQ "form">
	<cfoutput>
		<script>
			jQuery(document).ready(function() {
				// load the initial list items based on the top terms from the chosen facet
				jQuery.get( "#application.ADF.ajaxProxy#",
				{ 	
					bean: "date_time_builder",
					method: 'htmlAddEditLinkBuilder',
					callbackFunct: '#request.params.cbFunct#',
					formid: '#request.params.formid#',
					datapageid: '#request.params.datapageid#',
					renderResult: '#request.params.renderResult#',
					linkUUID: '#request.params.linkUUID#'
				},
				function(msg){
					jQuery("div##form").html(msg);
					ResizeWindow();
				});
          	});
		</script>	
		<div id="form" align="center">
			Loading Form ... <img src="/ADF/lib/ajax/images/ajax-loader-arrows.gif"><br />
		</div>
	</cfoutput>

<cfelseif request.params.action EQ "remove">	
	<cfoutput>
		<script>
			jQuery(document).ready(function() {
				
				// Hover states on the Submit Button
				jQuery("div.ds-icons").hover(
					function() {
						jQuery(this).css("cursor", "hand");
						jQuery(this).addClass('ui-state-hover');
					},
					function() {
						jQuery(this).css("cursor", "pointer");
						jQuery(this).removeClass('ui-state-hover');
					}
				);
				
				jQuery('div##removeLB').show();
				
				// Handle the delete
				jQuery('div##deleteBtn').live("click", function(){
					jQuery('div##removeLB').hide();
					jQuery('div##loadingLB').show();
					
					// load the initial list items based on the top terms from the chosen facet
					jQuery.get( "#application.ADF.ajaxProxy#",
					{ 	
						bean: "date_time_builder",
						method: 'removeLink',
						formid: '#request.params.formid#',
						datapageid: '#request.params.datapageid#'
					},
					function(data){
						if (data == 'true'){
							// Call the call backk and Close the lightbox
							getCallback("#request.params.cbFunct#",['#request.params.uuid#','remove']);
							closeLB();
							
							jQuery('div##loadingLB').hide();	
							jQuery('div##completeLB').show();
						}
						else
						{
							jQuery('div##loadingLB').hide();	
							jQuery('div##errorLB').show();
						}
					});
				});
			});
		</script>
		<div id="removeLB" style="display:none;">
			<div id="removeLBText" style="text-align:center;">
				<p><strong>Are you sure you wish to delete this Date/Time?</strong></p>
				<div id="deleteBtn" style="margin-left:70px;width:30%;float:left;" class='ds-icons ui-state-default ui-corner-all' title='delete'>Delete</div>
				<div id="cancelBtn" style="margin-right:70px;width:30%;float:right;" class='ds-icons ui-state-default ui-corner-all' onclick="closeLB();" title='cancel'>Cancel</div>
			</div>
		</div>
		<div id="errorLB" style="display:none;">
			<div id="errorLBText" style="text-align:center;">
				<p><strong>Error occurred deleting the Date/Time.</strong><br /><br />
				Please close this message box and try again.  If the problem continues, please contact your CommonSpot administrator.</p>
			</div>
		</div>
		<div id="completeLB" style="display:none;">
			<div id="completeLBText" style="text-align:center;">
				<p><strong>Date/Time has been deleted.</strong></p>
				<a href='javascript:;' onclick='window.parent.#request.params.cbFunct#(["#request.params.uuid#","remove"]);parent.window.tb_remove();'>Return to the Link Builder</a>
			</div>
		</div>
		<div id="loadingLB" style="display:none;">
			<div id="loadingLBText" style="text-align:center;">
				<p><strong>Deleting Date/Time ... <img src="/ADF/lib/ajax/images/ajax-loader-arrows.gif"></strong></p>
			</div>
		</div>
	</cfoutput>
</cfif>
