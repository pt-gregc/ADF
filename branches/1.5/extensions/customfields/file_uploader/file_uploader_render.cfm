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
<cfscript>
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadADFLightbox();
	application.ADF.scripts.loadJQueryUI();
	application.ADF.scripts.loadUploadify();
	
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	// find if we need to render the simple form field
	renderSimpleFormField = false;
	if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) )
		renderSimpleFormField = true;
		
	uploadUUID = CreateUUID();

	
	acceptedFileTypes = xparams.filetypes;
	for(i=1;i<=ListLen(acceptedFileTypes);i++){
		acceptedFileTypes = ListSetAt(acceptedFileTypes,i,"*."&ListGetAt(acceptedFileTypes,i));
	}
	acceptedFileTypes = ListChangeDelims(acceptedFileTypes,";");
</cfscript>
<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
		//#fqFieldName#.msg="Please upload a document!";
		// Push on to validation array
		//vobjects_#attributes.formname#.push(#fqFieldName#);
		
		jQuery(function(){
			handleExistingData();
			//the folder is not REALLY a folder! This is for security reasons. 
			//The folder is actually the custom field's ID so we can look up the prop values
			jQuery('##upload_btn_#fqFieldName#').uploadify({
				'uploader'  : '/ADF/thirdParty/jquery/uploadify/uploadify.swf',
				'script'    : '/ADF/extensions/customfields/file_uploader/handleFileUpload.cfm?subsiteURL#request.subsite.url#',
				'cancelImg' : '/ADF/thirdParty/jquery/uploadify/cancel.png',
				'auto'      : true,
				'folder'    : '/#uploadUUID#/#fieldQuery.inputID#',
				'fileDesc'	: '#acceptedFileTypes#',
				'fileExt'	: '#acceptedFileTypes#',
				'onProgress': function(event,queue,fileObj,data){
					if(data.percentage == 100){
						tempName = fileObj.name.replace(fileObj.type,"");
						tempName = tempName+"--#uploadUUID#"+fileObj.type;
						jQuery("###fqFieldName#").val(tempName);
						jQuery("##errorMsg_#fqFieldName#").html("Upload Success!");
					}
				},
				'onCancel'	: function(event,queueID,fileObj){
					jQuery("###fqFieldName#").val("");
					jQuery("##errorMsg_#fqFieldName#").html("");
				},
				'onError'	: function(event,queueID,fileObj,errorObj){
					jQuery("##errorMsg_#fqFieldName#").html("File upload error. Possibly due to invalid filetype. Please try again with a valid file.");
					return true;
				}
			});

		});
		
		function handleExistingData(){
			currentValue = jQuery("###fqFieldName#").val();
			if(currentValue.length > 0){
				//We have existing value!
				jQuery("###fqFieldName#_currentSelection").html(currentValue);
				setView(true);
			}else{
				setView(false);
			}
		}
		
		function setView(selected){
			if(!selected){
				jQuery("###fqFieldName#_currentSelection").hide();
				jQuery("##clear_btn_#fqFieldName#").hide();
				jQuery("##uploadHolder_#fqFieldName#").show();
			}else{
				jQuery("##clear_btn_#fqFieldName#").show();
				jQuery("##uploadHolder_#fqFieldName#").hide();
			}
		}
		
		function clearButtonClick(){
			jQuery("###fqFieldName#").val("");
			setView(false);
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
			<div style="min-height:100px">
				<div id="#fqFieldName#_currentSelection">#currentValue#</div>
				<div id="uploadHolder_#fqFieldName#" style="min-width:475px">
					<div id="upload_btn_#fqFieldName#"></div>
					<div id="errorMsg_#fqFieldName#"></div>
				</div>
				<input type="button" value="Clear" name="clear_btn_#fqFieldName#" id="clear_btn_#fqFieldName#" onclick="clearButtonClick()">
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