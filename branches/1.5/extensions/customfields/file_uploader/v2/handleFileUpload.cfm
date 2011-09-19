<cfsetting requestTimeout = 240>
<cftry>
	<cfoutput>
		<cfif !StructKeyExists(form,"filename") 
				or !StructKeyExists(form,"fieldID")
				or !StructKeyExists(form,"uploadUUID")
				or !StructKeyExists(form,"filedata")>
			<cfthrow type="custom" detail="Missing form parameters." message="Invalid Arguments">
		</cfif>
		<cfscript>
			fileUUID = form.uploadUUID;
			fieldID = form.fieldID;
		</cfscript>
		<cfscript>
			if( !(fieldID gt 0)){
				throw(message="Invalid fieldID parameter entered",type="custom");
			}
			fieldDefaultValues = application.ADF.ceData.getFieldParamsByID(fieldID);

			if(!structKeyExists(fieldDefaultValues,"beanName") or !Len(fieldDefaultValues.beanName)){
				throw(message="Bean name not specified in custom element definition",type="custom",detail="Bean name invalid");
			}

			fileDetails = StructNew();
			fileDetails.filePath = form.filedata;
			fileDetails.fileName = form.filename;
			
			//Passing this so the CFC can look up any possible variables it may need from the props file if its custom.
			fileDetails.fieldID = fieldID;

			validationResults = application.ADF.utils.runCommand(fieldDefaultValues.beanName,"_validateFile",fileDetails);
			
			if(!validationResults.success){
				//Failure! Throw out the error so we can get logging and such
				throw(message=validationResults.msg,type="custom",detail="Validation failure");
			}

			fileMoveResults = application.ADF.utils.runCommand(fieldDefaultValues.beanName,"_preformFileMove",fileDetails);

			if(!fileMoveResults.success){
				throw(message=fileMoveResults.msg,type="custom",detail="File move failure.");
			}
		</cfscript>
		<script>
			parent.uploadSuccess("#fileMoveResults.fileName#");
		</script>
	</cfoutput>
<cfcatch type="any">
	<cfscript>
		application.ADF.utils.logAppend(cfcatch,"fileUploadErrors.html");
	</cfscript>
	<cfoutput>
		<script>
			<cfif cfcatch.type eq "custom">
				parent.uploadFailure("#cfcatch.message#");
			<cfelse>
				parent.uploadFailure("");
			</cfif>
		</script>
		<cfdump var="#cfcatch#" label="cfcatch">
	</cfoutput>
</cfcatch>
</cftry>