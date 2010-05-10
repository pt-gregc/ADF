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

<cfscript>
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQueryUI();
	application.ADF.scripts.loadADFLightbox();
	formID = application.ADF.ceData.getFormIDFromPageID(Request.DatasheetRow.pageid);
</cfscript>
<cfsavecontent variable="Request.Datasheet.CurrentFormattedValue">
	<cfoutput>
		<td>
			<a style="float: left;" rel='#application.ADF.ajaxProxy#?bean=forms_1_0&method=renderAddEditForm&dataPageid=#Request.DatasheetRow.pageid#&formID=#formID#&height=400&width=550' class='ADFLightbox' title='Edit'>
				<div class='ds-icons ui-state-default ui-corner-all' title='edit' >
					<div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-pencil'></div>
				</div>
			</a>
			<a style="float: left; margin-left: 3px; margin-right: 3px;" rel='#application.ADF.ajaxProxy#?bean=forms_1_0&method=renderDeleteForm&dataPageid=#Request.DatasheetRow.pageid#&formID=#formID#&height=250&width=550' class='ADFLightbox' title='Edit'>
				<div class='ds-icons ui-state-default ui-corner-all' title='delete' >
					<div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-trash'></div>
				</div>
			</a>
			<span style="clear: both;">&nbsp;</span>
		</td>
	</cfoutput>
</cfsavecontent>