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
		Uploading... <img src="/ADF/extensions/customfields/file_uploader/v2/ajax-loader-arrows.gif">
	</div>
	<div class="uploadFailure" style="display:none">
		
	</div>
	<div class="form">
		<form id="file_upload_form" target="upload_target" method="post" enctype="multipart/form-data" action="/ADF/extensions/customfields/file_uploader/v2/handleFileUpload.cfm">
			<input type="hidden" name="subsiteURL" value="#request.subsite.url#">
			<input type="hidden" name="fieldID" value="#request.params.inputID#">
			<input type="hidden" name="uploadUUID" value="#request.params.uploadUUID#">
			<input type="hidden" name="filename" value="">
			<input type="file" name="filedata" onchange="uploadFile()">
		</form>
		<iframe id="upload_target" name="upload_target" src="" style="display:none"></iframe>
	</div>
</cfoutput>