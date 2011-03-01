<cfif StructKeyExists(request.params,"fieldID") and StructKeyExists(request.params,"fileName")>
	<cfscript>
		fieldDefaultValues = application.ADF.ceData.getFieldValuesByFieldID(request.params.fieldID);
		fileName = request.params.fileName;
		displayName = listFirst(fileName,"--")&"."&listLast(fileName,".");
		displayName = Replace(displayName," ", "_", "all");
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


