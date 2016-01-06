<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2016.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->
<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	fileUploadForm.cfm
Summary:
	File to render the file upload form
History:
 	2011-09-01 - RAK - Created
	2015-05-26 - DJM - Added the 3.0 version
--->
<cfoutput>
	#application.ADF.scripts.loadJQuery()#
	<script>
		function uploadFile(){
			var tempFileName = jQuery('[name="filedata"]').val();
			tempFileName = tempFileName.replace(/\\/g, "/");
			tempFileName = tempFileName.split('/').pop();
			jQuery('[name="filename"]').val(tempFileName);
			jQuery("form").submit();
			jQuery(".uploading").show();
			jQuery(".form").hide();
			jQuery(".uploadFailure").hide();
		}
		function uploadSuccess(filename){
			jQuery(".uploading").hide();
			jQuery('[name="filedata"]').val("");
			jQuery(".form").show();
			parent.#request.params.fieldName#handleFileUploadComplete(filename);
		}
		function uploadFailure(message){
			jQuery(".uploadFailure").html("Upload Failure. "+message);
			jQuery(".uploadFailure").show();
			jQuery(".uploading").hide();
			jQuery('[name="filedata"]').val("");
			jQuery(".form").show();
		}
	</script>
	<div class="uploading" style="display:none;">
		Uploading... <img src="/ADF/extensions/customfields/file_uploader/v3/ajax-loader-arrows.gif">
	</div>
	<div class="uploadFailure" style="display:none">
		
	</div>
	<div class="form">
		<form id="file_upload_form" target="upload_target" method="post" enctype="multipart/form-data" action="/ADF/extensions/customfields/file_uploader/v3/handleFileUpload.cfm">
			<input type="hidden" name="subsiteURL" value="#request.subsite.url#">
			<input type="hidden" name="fieldID" value="#request.params.inputID#">
			<input type="hidden" name="uploadUUID" value="#request.params.uploadUUID#">
			<input type="hidden" name="filename" value="">
			<input type="file" name="filedata" onchange="uploadFile()">
		</form>
		<iframe id="upload_target" name="upload_target" src="" style="display:none"></iframe>
	</div>
</cfoutput>