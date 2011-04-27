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


