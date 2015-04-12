## INSTRUCTIONS TO USE OBJECT LIST BUILDER

1. Create a Global Custom Element that has data. In this case, we used CourseBuilder custom element with the following fields:
		CourseID (Text),
		CourseInstructor (Text),
		CourseTitle (Small Text Area),
		CourseCredits (Number (integer)),
		CourseDuration (Text),
		CourseDescription (Formatted Text Block)
		
2. Add records to CourseBuilder custom element.

3. Import the Custom Element ObjectListBuilder. 
	It has the following:		
			Custom Field Type: ObjectListBuilder
	Files:
			object_list_builder_render.cfm (render module)
			object_list_builder_props.cfm (properties module)
			object_list_builder_base.cfc (base componenet)
			call_renderitem.cfm (render module for the records on the page)
			object_list_builder_pre_save_hook.cfm (pre processor for ObjectListBuilder data)
			listFormats.xml (XML file with render formats for the ObjectListBuilder)
			object_list_builder_editor_styles.css (styles to be used in the ckEditor)
			object_list_builder_styles.css (styles to be used in the ObjectListBuilder dialog)
			
4. Open or Create pre-save-form-hook.cfm in the site's root directory. Add the following line:
	<cfinclude template="/ADF/extensions/customfields/object_list_builder/object_list_builder_pre_save_hook.cfm">
	
5. Open listFormats.xml file. It contains listFormats array. Each array is a structure with the following required keys:

	<format>
		<formatName>h4Listing</formatName> 
		<displayName>Listing with H4</displayName> 
		<structure><![CDATA[<h4>{CourseID} - {CourseTitle}</h4> <u>Course Instructor</u>: <b>{CourseInstructor}</b>]]></structure> 
		<isDefault>0</isDefault> 
		<wrapperTag>section</wrapperTag> 
	</format>
			
	Legend:
		formatName - unique name for the format			
		displayName - display name for the format shown in ckEditor and ObjectListBuilder dialog		
		structure - structure of format
		isDefault - boolean flag indicating if this format should be the default format
		wrapperTag - used by ckEditor. ckEditor generates valid HTML and if you put tags like H1-H6 or any block level tags, make sure the wrapperTag is also a block level tag. Default wrapperTag is Div.

6. Open object_list_builder_base.cfc and supply values for the following:

		variables.cftPath  // path to the ObjectListBuilder custom element Eg: "/ADF/extensions/customfields/object_list_builder";
		variables.ceID // ID of source customElement Eg: 4032;
		variables.customElement // Name of the source customElement Eg: "courseRecords";
		variables.searchFields // Searchable fields in source customElement, used by bloodhound and typeahead in the ObjectListBuilder dialog Eg: "CourseID,CourseInstructor,CourseTitle";
		variables.IDField // UniqueID in the source customElement Eg: "CourseID";
		variables.orderByClause // source customElement column. This should be present in variables.columnList and variables.searchFields Eg: "CourseTitle ASC";
		variables.ResultsJSONFile // prefix for the JSON file used by bloodhound and typeahead. Eg: "objectListBuilderResults";
		variables.columnList // columns from the source customElement. Eg: "CourseID,CourseInstructor,CourseTitle,CourseCredits,CourseDuration,CourseDescription";

7. Other libraries included in this custom element:
	ckeditor - if you download ckeditor locally, update the "renderJS" command in object_list_builder_base.cfc (line:315) with the path. Otherwise, it defaults to the following:
			//cdn.ckeditor.com/4.4.6/full/ckeditor.js
			
		ckeditor plugins:
			listformat - plugin used for ObjectListBuilder's formats display
			cslink - plugin used to invoke CommonSpot's insert-link dialog.
			csimage - plugin used to invoke CommonSpot's insert-image dialog and access to CommonSpot's Image Gallery.
			
	jquery - typeahead bundle. Download to jquery/typeahead folder and update the path in object_list_builder_base.cfc (line:314). Defaults to (assuming the typeahead.bundle.js is present in the above said folder)
		#variables.cftPath#/jquery/typeahead/typeahead.bundle.js	
		
	
			