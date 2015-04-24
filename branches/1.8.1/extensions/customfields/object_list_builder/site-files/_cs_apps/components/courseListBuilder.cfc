<cfcomponent output="false" name="courseListBuilder" extends="ADF.lib.fields.objectListBuilder_1_0" hint="This is a configuration component for the ObjectListBuilder custom field type">

	<cfscript>
		// path to the ObjectListBuilder custom field type - typical value is "/ADF/extensions/customfields/object_list_builder"
		variables.cftPath = "/ADF/extensions/customfields/object_list_builder";
		variables.ceID = 14624; // ID of source custom element
		variables.customElement = "CourseBuilder"; // Name of the source custom element
		variables.searchFields = "CourseTitle,CourseCode,CourseID"; // Searchable fields in source custom element, used by bloodhound and typeahead in the ObjectListBuilder dialog
		variables.IDField = "CourseID"; // Unique identifier in the source custom element
		variables.orderByClause = "CourseTitle ASC"; // source custom element column. This should be present in variables.columnList and variables.searchFields
		variables.ResultsJSONFilePath = "#request.site.csAppsWebURL#customfields/temp/"; // temp/working directory - will auto-create the needed directories if they don't exist
		variables.ResultsJSONFile = "courseListBuilderResults"; // prefix for the JSON file used by bloodhound and typeahead. An auto-generated JSON file.
		variables.listFormatsXMLFilePath = "#request.site.csAppsWebURL#config/";
		variables.listFormatsXMLFile = "courseListFormats"; // file where all of the formats are defined in editor
		variables.columnList = "CourseID,CourseTitle,CourseCode,CourseCredits,CourseInstructor,CourseDuration,CourseDescription"; // columns used from the source custom element, should contain at minimum the id field, search fields, and order by field
	</cfscript>

</cfcomponent>