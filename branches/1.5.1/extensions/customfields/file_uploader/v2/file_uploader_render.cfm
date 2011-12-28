<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the Starter App directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2010.
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
	file_Upload_Render.cfm
Summary:
	Renders the file upload form
History:
	2011-08-05 - RAK - Created
	2011-08-05 - RAK - fixed issue where the file uploader would try to generate images for non-pdf files.
	2011-09-22 - RAK - Updated file uploader to be able to get more detailed information if they choose to override the props.
--->
<cfscript>
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadADFLightbox();
	application.ADF.scripts.loadJQueryUI();

	uploadUUID = CreateUUID();

	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	currentFilename = "";

	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	// find if we need to render the simple form field
	renderSimpleFormField = false;
	if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) )
		renderSimpleFormField = true;

	fieldDefaultValues = application.ADF.ceData.getFieldParamsByID(fieldQuery.inputID);

	valueRenderParams = StructNew();
	valueRenderParams.currentValue = currentValue;
	currentValueRenderData = application.ADF.utils.runCommand(fieldDefaultValues.beanName,"getCurrentValueRenderData",valueRenderParams);


	imageURL = "/ADF/extensions/customfields/file_uploader/v2/handleFileDownload.cfm?subsiteURL=#request.subsite.url#&fieldID=#fieldQuery.inputID#&filename=";
	concatenator = "";
</cfscript>
<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;

		jQuery(document).ready( function(){
			#fqFieldName#setView(false);
			<cfif Len(currentValue)>
				#fqFieldName#setView(true);
				jQuery("###fqFieldName#_currentSelection").show();
			</cfif>
		});

		function #fqFieldName#handleFileUploadComplete(fileName){
			<cfif application.ADF.utils.runCommand(fieldDefaultValues.beanName,"_isThumbnailGenerationOn")>
				jQuery.post("#application.ADF.ajaxProxy#",{
					bean: "#fieldDefaultValues.beanName#",
					method:"_getThumbnail",
					fileName:fileName,
					fieldID: "#fieldQuery.inputID#"
				},function(results){
					jQuery("###fqFieldName#_thumbnail").html(results);
				});
			</cfif>

			jQuery("###fqFieldName#_currentSelection").html(fileName);
			jQuery("###fqFieldName#").val(fileName);
			#fqFieldName#setView(true);
			jQuery("###fqFieldName#_currentSelection").show();
		}
		
		function #fqFieldName#setView(selected){
			if(!selected){
				jQuery("###fqFieldName#_currentSelection").hide();
				jQuery("##clear_btn_#fqFieldName#").hide();
				jQuery("##uploadHolder_#fqFieldName#").show();
			}else{
				jQuery("##clear_btn_#fqFieldName#").show();
				jQuery("##uploadHolder_#fqFieldName#").hide();
			}
		}
		
		function #fqFieldName#clearButtonClick(){
			jQuery("###fqFieldName#").val("");
			jQuery("###fqFieldName#_thumbnail").html("");
			jQuery("##errorMsg_#fqFieldName#").html("");
			jQuery("###fqFieldName#_currentSelection").html("");
			#fqFieldName#setView(false);
		}
		
	</script>
	<!--- // determine if this is rendererd in a simple form or the standard custom element interface --->
	<cfscript>
		if ( structKeyExists(request, "element") ){
			labelText = '<span class="CS_Form_Label_Baseline"><label for="#fqFieldName#">#xParams.label#:</label></span>';
			tdClass = 'CS_Form_Label_Baseline';
		}else{
			labelText = '<label for="#fqFieldName#">#xParams.label#:</label>';
			tdClass = 'cs_dlgLabel';
		}
	</cfscript>
	<tr>
		<td class="#tdClass#" valign="top">#labelText#</td>
		<td class="cs_dlgLabelSmall">
			<div>
			
				<div id="#fqFieldName#_currentSelection">#currentValueRenderData.name#</div>
				<div id="#fqFieldName#_thumbnail">
					<cfif len(currentValueRenderData.image)>
						#currentValueRenderData.image#
					</cfif>
				</div>
				<div id="uploadHolder_#fqFieldName#" style="min-width:475px">
					<iframe height="70px" width="375px" scrolling="no" frameBorder="0" src="/ADF/extensions/customfields/file_uploader/v2/fileUploadForm.cfm?subsiteURL=#request.subsite.url#&fieldName=#fqFieldName#&uploadUUID=#uploadUUID#&inputID=#fieldQuery.inputID#"></iframe>
				</div>
				<div id="errorMsg_#fqFieldName#"></div>
				<input type="button" value="Clear" name="clear_btn_#fqFieldName#" id="clear_btn_#fqFieldName#" onclick="#fqFieldName#clearButtonClick()">
			</div>
		</td>
	</tr>
	<!--- hidden field to store the value --->
	<input type='hidden' name='#fqFieldName#' id='#fqFieldName#' value='#currentValue#'>
	<!--- // include hidden field for simple form processing --->
	<cfif renderSimpleFormField>
		<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(xParams.fieldName, 'fic_','')#">
	</cfif>
</cfoutput>