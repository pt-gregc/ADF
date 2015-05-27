<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
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
	$handleFileUpload.cfm
Summary:
	File to help with the file upload process
History:
 	2011-09-01 - RAK - Created
	2014-04-04 - GAC - Changed the cfscript thow to the utils.doThow for cf8 compatiblity
	2015-05-26 - DJM - Added the 3.0 version
--->
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
				application.ADF.utils.doThrow(message="Invalid fieldID parameter entered",type="custom");
			}
			fieldDefaultValues = application.ADF.ceData.getFieldParamsByID(fieldID);

			if(!structKeyExists(fieldDefaultValues,"beanName") or !Len(fieldDefaultValues.beanName)){
				application.ADF.utils.doThrow(message="Bean name not specified in custom element definition",type="custom",detail="Bean name invalid");
			}

			fileDetails = StructNew();
			fileDetails.filePath = form.filedata;
			fileDetails.fileName = form.filename;

			validationResults = application.ADF.utils.runCommand(fieldDefaultValues.beanName,"_validateFile",fileDetails);
			
			if(!validationResults.success){
				//Failure! Throw out the error so we can get logging and such
				application.ADF.utils.doThrow(message=validationResults.msg,type="custom",detail="Validation failure");
			}

			fileMoveResults = application.ADF.utils.runCommand(fieldDefaultValues.beanName,"_preformFileMove",fileDetails);

			if(!fileMoveResults.success){
				application.ADF.utils.doThrow(message=fileMoveResults.msg,type="custom",detail="File move failure.");
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