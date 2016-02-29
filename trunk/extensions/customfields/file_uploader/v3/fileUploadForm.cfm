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
	Ryan Kahn
Name:
	fileUploadForm.cfm
Summary:
	File to render the file upload form
History:
 	2011-09-01 - RAK - Created
	2015-05-26 - DJM - Added the 3.0 version
	2016-02-23 - GAC - Updated to include the CS Page header and Footer so CS Resources load
--->
<cfscript>
	errMsg = "";
	if ( !StructKeyExists(request,"params") )
		errMsg = "The required parameters were not available to process this request.";
	else if ( !StructKeyExists(request.params,"subsiteURL") )
		errMsg = "A 'subsiteURL' url parameter is required?";
	else if ( !StructKeyExists(request.params,"fieldname") )
		errMsg = "A 'fieldname' url parameter is required!";
	else if ( !StructKeyExists(request.params,"inputid") )
		errMsg = "A 'inputid' url parameter is required!";
	else if ( !StructKeyExists(request.params,"UPLOADUUID") )
		errMsg = "A 'UPLOADUUID' url parameter is required!";

	if ( LEN(TRIM(errMsg)) )
	{
		application.ADF.log.logAppend(msg=errMsg,logFile="ADF-cft-fileUploadForm-Error.log");
		if ( !application.ADF.siteDevMode )
			errMsg = "The required parameters were not passed in.";
		
		// Render the Error Message
		WriteOutput(errMsg);
		exit; // exit instead of throw so it doesn't do a big CF error in iframe in the form
		//throw(message=errMsg);
	}
</cfscript>

<cfscript>
	// Add the CS Page Footer since this script is not in the CS Site context
	application.ADF.ui.csPageResourceHeader(pageTitle="File Upload Form");
</cfscript>
	
	<!--- // loading jQuery --->
	<cfscript>
		application.ADF.scripts.loadJQuery();
	</cfscript>

	<cfsavecontent variable="uploaderJS">
	<cfoutput>
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
	</cfoutput>
	</cfsavecontent>

	<cfscript>
		application.ADF.scripts.addFooterJS(uploaderJS, "PRIMARY"); //  PRIMARY, SECONDARY, TERTIARY
	</cfscript>

<cfoutput>
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

<cfscript>
	// Add the CS Page Footer since this script is not in the CS Site context
	application.ADF.ui.csPageResourceFooter();
</cfscript>