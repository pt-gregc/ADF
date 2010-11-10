<cftry>
	<cfoutput>
		<cfif !StructKeyExists(form,"filename") 
				or !StructKeyExists(form,"folder")
				or !StructKeyExists(form,"filedata")
				or !StructKeyExists(form,"subsiteURL")
				or !StructKeyExists(form,"uploadUUID")
				or !StructKeyExists(form,"inputID")>
			<cfthrow type="custom" detail="Missing form parameters." message="Invalid Arguments">
		</cfif>
		<cfscript>
			fileUUID = form.uploadUUID;
			fieldID = form.inputID;
		</cfscript>
		<cfif fieldID gt 0>
			<cfscript>
				fieldDefaultValues = application.ADF.ceData.getFieldValuesByFieldID(fieldID);
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
	</cfoutput>
<cfcatch type="any">	
	<cfscript>
		application.ADF.utils.logAppend(cfcatch.message,"fileUploadErrors.txt");
	</cfscript>
	<cfthrow type="custom" detail="#cfcatch.detail#" message="#cfcatch.message#">
</cfcatch>
</cftry>