<cfoutput>
	#application.ADF.scripts.loadJQuery()#
	<script>
		function uploadFile(){
			var tempFileName = jQuery('[name="filedata"]').val();
			tempFileName = tempFileName.replace(/\\/g, "/");
			tempFileName = tempFileName.replace(/[ ]/g, "-");
			tempFileName = tempFileName.split('/').pop();
			jQuery('[name="filename"]').val(tempFileName);
			jQuery("form").submit();
			jQuery(".uploading").show();
			jQuery(".form").hide();
			jQuery(".uploadFailure").hide();
		}
		function uploadSuccess(){
			<!--- This trickery takes the file: test.pdf and converts it to test--#request.params.uploadUUID#.pdf --->
			var fileValue = jQuery('[name="filename"]').val();
			var fileExtensionRegex = /(\.[^.]+)$/;
			var extension = fileValue.match(fileExtensionRegex)[0];
			fileValue = fileValue.replace(fileExtensionRegex,'');
			fileValue = fileValue+"--#request.params.uploadUUID#"+extension;
			jQuery(".uploading").hide();
			jQuery('[name="filedata"]').val("");
			jQuery(".form").show();
			parent.#request.params.fieldName#handleFileUploadComplete(jQuery('[name="filename"]').val(),fileValue);
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
		Uploading... <img src="/ADF/extensions/customfields/file_uploader/ajax-loader-arrows.gif">
	</div>
	<div class="uploadFailure" style="display:none">
		
	</div>
	<div class="form">
		<form id="file_upload_form" target="upload_target" method="post" enctype="multipart/form-data" action="/ADF/extensions/customfields/file_uploader/v1/handleFileUpload.cfm">
			<input type="hidden" name="subsiteURL" value="#request.subsite.url#">
			<input type="hidden" name="folder" value="/#request.params.uploadUUID#/#request.params.inputID#">
			<input type="hidden" name="filename" value="">
			<input type="file" name="filedata" onchange="uploadFile()">
		</form>
		<iframe id="upload_target" name="upload_target" src="" style="display:none"></iframe>
	</div>
</cfoutput>