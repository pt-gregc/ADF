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
	handleFileDownload.cfm
Summary:
	File to help with the file download process
History:
 	2011-09-01 - RAK - Created
	2015-05-26 - DJM - Added the 3.0 version
--->
<cfif StructKeyExists(request.params,"fieldID") and StructKeyExists(request.params,"fileName")>
	<cfscript>
		fieldDefaultValues = application.ADF.ceData.getFieldParamsByID(request.params.fieldID);
		fileName = request.params.fileName;

		//Get the display name, remove the --UUID from the text. Maintain the extension
		totalLength = Len(fileName);
		extension = listLast(fileName,".");
		removeLength = Len(extension)+38;
		displayName = Left(fileName,totalLength-removeLength)&"."&extension;


		filePath = "";
		if(StructKeyExists(fieldDefaultValues,"filePath")){
			concatenator = '';
			if(Find('/',fieldDefaultValues.filePath)){
				concatenator = '/';
			}else{
				concatenator = '\';
			}
			if(right(fieldDefaultValues.filePath, 1) is concatenator){
				concatenator = "";
			}
			filePath = fieldDefaultValues.filePath&concatenator&fileName;
		}
	</cfscript>
   <cfheader name="content-disposition" value="attachment; filename=#displayName#;">
 	<cfcontent file="#filePath#" type="unknown" deletefile="no">
<cfelse>
	<cfoutput>
		Invalid parameters. <br/>
		Expecting:<br/>
		fieldID - the field ID from the custom element record<br/>
		fileName - the filename that is stored in the record
	</cfoutput>
</cfif>


