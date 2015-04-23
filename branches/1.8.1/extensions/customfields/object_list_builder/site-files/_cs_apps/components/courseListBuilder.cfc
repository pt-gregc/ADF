<cfcomponent output="false" name="courseListBuilder" extends="ADF.lib.fields.objectListBuilder_1_0" hint="This is a configuration component for the ObjectListBuilder custom field type">

	<cfscript>
		// path to the ObjectListBuilder custom field type - typical value is "/ADF/extensions/customfields/object_list_builder"
		variables.cftPath = "/ADF/extensions/customfields/object_list_builder";
		variables.ceID = 8079; // ID of source custom element
		variables.customElement = "CC Course"; // Name of the source custom element
		variables.searchFields = "courseName,courseCode,courseID"; // Searchable fields in source custom element, used by bloodhound and typeahead in the ObjectListBuilder dialog
		variables.IDField = "uniqueID"; // Unique identifier in the source custom element
		variables.orderByClause = "courseName ASC"; // source custom element column. This should be present in variables.columnList and variables.searchFields
		variables.ResultsJSONFilePath = "#request.site.csAppsWebURL#config/";
		variables.ResultsJSONFile = "courseListBuilderResults"; // prefix for the JSON file used by bloodhound and typeahead.
		variables.listFormatsXMLFilePath = "#request.site.csAppsWebURL#config/";
		variables.listFormatsXMLFile = "courseListFormats"; // file where all of the formats are defined in editor
		variables.columnList = "uniqueID,courseName,catalogYear,deptID,courseCode,courseID,courseCredits,pageProperties,courseTemplateID,catalogPageID,catalogPageRebuild,dbCourseID,description"; // columns used from the source custom element, should contain at minimum the id field, search fields, and order by field
	</cfscript>

	<cffunction name="renderItem" access="public" returntype="any" hint="Method to render item in the given format">
		<cfargument name="format" type="string" required="true" hint="Format in which item should be displayed">
		<cfargument name="id" type="string" required="true" hint="Id of the record">
		<cfscript>
			var renderData = '';
			var newstr = "";
			var str = "";
			var tempStr = "";
			var curItem = StructNew();
			var i = 0;
			var cleanstr = "";
			var startCharPos = 1;
			var replaceStrings = [];
			var posStruct = StructNew();
			var curString = "";
			var curStructure = "";
			var record = application.ADF.ceData.getCachedCEData(variables.customElement, '#variables.IDField#', arguments.id);
			var resultRow = structNew();

			//application.adf.utils.logappend(msg="<hr>", logfile='debugCLB.html');

			if (isArray(record) and (arrayLen(record) GTE 1))
				resultRow = record[1]['values'];
			//application.adf.utils.logappend(msg=resultRow, logfile='debugCLB.html', label="courseListBuilder.cfc - line 41 - resultRow");

			if (arguments.format neq "")
				renderFormat = deserializeJSON(getFormats(format=arguments.format));
			else if (arguments.useDefault eq 1)
				renderFormat = deserializeJSON(getFormats(isDefaultFilter=1));
			//application.adf.utils.logappend(msg=renderFormat, logfile='debugCLB.html', label="courseListBuilder.cfc - line 47 - renderFormat");

			curStructure = renderFormat['structure'];
			newStr = curStructure;

			while (startCharPos LT Len(curStructure))
			{
				posStruct = REFindNoCase("{([a-z]+[a-z0-9]*)}", curStructure, startCharPos, true);

				if (posStruct.pos[1] NEQ 0)
				{
					startCharPos = posStruct.pos[1] + posStruct.len[1];
					tempstr = Mid(curStructure, posStruct.pos[1], posStruct.len[1]);
					cleanstr = Replace(tempstr,"{","");
					cleanstr = Replace(cleanstr,"}","");
					curString = "#tempstr#^#cleanstr#";
					arrayAppend(replaceStrings,curString);
				}
				else {
					startCharPos = Len(curStructure);
				}
			}
			//application.adf.utils.logappend(msg=replaceStrings, logfile='debugCLB.html', label="courseListBuilder.cfc - line 69 - replaceStrings", expand="Yes");
		</cfscript>

		<cfsavecontent variable="resultHTML">
			<cfscript>
				newStr = curStructure;
				//application.adf.utils.logappend(msg="courseListBuilder.cfc - line 75 - newStr before: #htmlEditFormat(newStr)#<br>", logfile='debugCLB.html');
				for (i=1; i le arrayLen(replaceStrings); i=i+1)
				{
					str = replaceStrings[i];
					//application.adf.utils.logappend(msg="courseListBuilder.cfc - line 79 - str: #str#<br>", logfile='debugCLB.html');

					tempstr = ListGetAt(str,1,"^");
					//application.adf.utils.logappend(msg="courseListBuilder.cfc - line 82 - tempstr: #tempstr#<br>", logfile='debugCLB.html');

					cleanstr = ListGetAt(str,2,"^");
					//application.adf.utils.logappend(msg="courseListBuilder.cfc - line 85 - cleanstr: #cleanstr#<br>", logfile='debugCLB.html');

					/* Retrieve custom element value from record. If the custom element record does not exist, return an error message instead. */
					if (structKeyExists(resultRow,"#cleanstr#")) {
						cleanstr = resultRow[cleanstr];
						/* I have the converted value and now I will do further processing */
						cleanstr = secondaryRender(cleanstr, ListGetAt(str, 2, "^"));
						//application.adf.utils.logappend(msg="courseListBuilder.cfc - line 93 - cleanstr after secondaryRendering: #cleanstr#<br>", logfile='debugCLB.html');
					}
					else {
						cleanstr = 'Record not found. Please re-select.';
					}
					//application.adf.utils.logappend(msg="courseListBuilder.cfc - line 89 - cleanstr: #cleanstr#<br>", logfile='debugCLB.html');

					newStr = Replace(newStr, tempstr, cleanstr);
					//application.adf.utils.logappend(msg="courseListBuilder.cfc - line 96 - newStr after iteration #i#: #htmlEditFormat(newStr)#<br>", logfile='debugCLB.html');
				}
				//application.adf.utils.logappend(msg="courseListBuilder.cfc - line 98 - newStr after loop: #htmlEditFormat(newStr)#<br>", logfile='debugCLB.html');
			</cfscript>
			<cfoutput>#newstr#</cfoutput>

		</cfsavecontent>
		<!---<cfset application.adf.utils.logappend(msg="courseListBuilder.cfc - line 103 - resultHTML: #htmlEditFormat(resultHTML)#<br>", logfile='debugCLB.html')>--->
		<cfreturn resultHTML>

	</cffunction>

	<cffunction name="secondaryRender" access="private" returntype="any" hint="Method to do any further rendering with CE value before finishing renderItem">
		<cfargument name="value" default="" type="any">
		<cfargument name="fieldname" default="" type="string">

		<cfset var renderedValue = "">

		<cfswitch expression="#arguments.fieldname#">
			<cfcase value="catalogPageID">
				<cfset renderedValue = application.ADF.csData.getCSPageURL(arguments.value)>
			</cfcase>
			<cfcase value="courseID">
				<cfset renderedValue = left(arguments.value,3) & " " & right(arguments.value,5)>
			</cfcase>
			<!--- Add any additional cases in here for any further rendering situations --->
			<cfdefaultcase>
				<cfset renderedValue = arguments.value>
			</cfdefaultcase>
		</cfswitch>

		<cfreturn renderedValue>
	</cffunction>

</cfcomponent>