<cfsetting requestTimeout = 240>
<cftry>
	<cfoutput>
		<cfif !StructKeyExists(form,"filename") 
				or !StructKeyExists(form,"folder")
				or !StructKeyExists(form,"filedata")>
			<cfthrow type="custom" detail="Missing form parameters." message="Invalid Arguments">
		</cfif>
		<cfscript>
			fileUUID = ListGetAt(form.folder,1,"/");
			fieldID = ListGetAt(form.folder,2,"/");
		</cfscript>
		<cfif fieldID gt 0>
			<cfscript>
				fieldDefaultValues = application.ADF.ceData.getFieldParamsByID(fieldID);
				form.folder = fieldDefaultValues.filepath;
				fileExtension = ListGetat(form.filename,ListLen(form.filename,"."),".");
				//If its a valid extension, move it to the uploaded directory!
			</cfscript>
			<cfif ListFindNoCase(fieldDefaultValues.filetypes,fileExtension,",")>
				<cfscript>
					tempFileName = Replace(form.filename,"."&fileExtension,"");
					filePath = form.folder&"\"&tempFileName&"--"&fileUUID&"."&fileExtension;
					FileMove(form.filedata,filePath);
					application.ADF.utils.logAppend("File upload success: "&filepath,"fileUpload.txt");
				</cfscript>
			<cfelse>
				<cfthrow type="custom" detail="Invalid filetype selected for upload." message="Invalid Filetype">
			</cfif>
		</cfif>
		<script>
			parent.uploadSuccess();
		</script>
	</cfoutput>
<cfcatch type="any">
	<cfscript>
		application.ADF.utils.logAppend(cfcatch.message,"fileUploadErrors.txt");
	</cfscript>
	<cfoutput>
		<script>
			<cfif cfcatch.type eq "custom">
				parent.uploadFailure("#cfcatch.message#");
			<cfelse>
				parent.uploadFailure("");
			</cfif>
		</script>
	</cfoutput>
</cfcatch>
</cftry>