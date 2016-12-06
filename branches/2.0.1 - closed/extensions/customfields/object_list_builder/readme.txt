## INSTRUCTIONS TO USE OBJECT LIST BUILDER

1. Create a Global Custom Element that has data. In this case, we used CourseBuilder custom element with the following fields:
		CourseID (Text),
		CourseInstructor (Text),
		CourseTitle (Small Text Area),
		CourseCredits (Number (integer)),
		CourseDuration (Text),
		CourseDescription (Formatted Text Block)
		
		
2. Add records to CourseBuilder custom element.


3. Import the Custom Field Type : Object-List-Builder
	Custom Field Type zip Import Archive:	
		/ADF/extensions/customfields/object_list_builder/exported-objects/Object-List-Builder-Custom-Field-Type.zip

	The Custom Field Type has the following files:
			object_list_builder_render.cfc (render module)
			object_list_builder_props.cfm (properties module)
			object_list_builder_base.cfc (base componenet)
			call_renderitem.cfm (render module for the records on the page)
			object_list_builder_pre_save_hook.cfm (pre processor for ObjectListBuilder data)
			listFormats.xml (XML file with render formats for the ObjectListBuilder)
			object_list_builder_editor_styles.css (styles to be used in the ckEditor)
			object_list_builder_styles.css (styles to be used in the ObjectListBuilder dialog)
	
			
4. Add or modify a pre-save-form-hook.cfm file in the site's root directory. 
	If you do not have an existing pre-save-form-hook.cfm file you can use the that is located here:
		/ADF/extensions/customfields/object_list_builder/site-files/pre-save-form-hook.cfm
	(If adding a new hook file to the site a CF restart will be required.)	

	If you already have a pre-save-form-hook.cfm installed in your site root, copy the following <cfinclude> line into that file:
	<cfinclude template="/ADF/extensions/customfields/object_list_builder/object_list_builder_pre_save_hook.cfm">
	
	
5. Copy the listFormats.xml file to your site and rename this file based on your Global Custom Element (Eg. courseListFormats.xml) . 
	This config XML file contains the listFormats array. Each item in the array is a structure with the following required keys:
	
	Copied {custom}ListFormats.xml File Site Level Location:
		/ADF/extensions/customfields/object_list_builder/site-files/_cs_apps/config/{custom}ListFormats.xml
	
	Example ListFormats XML Node:
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
		wrapperTag - used by ckEditor. ckEditor generates valid HTML and if you put tags like H1-H6 or any block level tags, make sure the 			    wrapperTag is also a block level tag. Default wrapperTag is Div.

	Standard Config file:
		/ADF/extensions/customfields/object_list_builder/listFormats.xml
		
	Example File:
		/ADF/extensions/customfields/object_list_builder/site-files/_cs_apps/config/courseListFormats.xml


6. Create a configuration component in your site's "/_cs_apps/components/" directory
		Name this component based on your Global Custom Element (Eg. courseListBuilder.cfc) 
		Set the the CFCs extends to: extends="ADF.lib.fields.objectListBuilder_1_0"
		Create a <cfscript> block at the top of the configuration component
		Add the follow following variables and set values for each:

			variables.cftPath  // path to the ObjectListBuilder custom element Eg: "/ADF/extensions/customfields/object_list_builder";
			variables.ceID // ID of source customElement Eg: 4032;
			variables.customElement // Name of the source customElement Eg: "courseRecords";
			variables.searchFields // Searchable fields in source customElement, used by bloodhound and typeahead in the ObjectListBuilder dialog Eg: "CourseID,CourseInstructor,CourseTitle";
			variables.IDField // UniqueID in the source customElement Eg: "CourseID";
			variables.orderByClause // source customElement column. This should be present in variables.columnList and variables.searchFields Eg: "CourseTitle ASC";
			variables.ResultsJSONFile // prefix for the JSON file used by bloodhound and typeahead. Eg: "objectListBuilderResults";
			variables.columnList // columns from the source customElement. Eg: "CourseID,CourseInstructor,CourseTitle,CourseCredits,CourseDuration,CourseDescription";

		Base Component File:
			/ADF/extensions/customfields/object_list_builder/object_list_builder_base.cfc
		Example File:
			/ADF/extensions/customfields/object_list_builder/site-files/_cs_apps/components/courseListBuilder.cfc
		

7. Create or update the site level proxyWhiteList.xml file with the configuration component and methods

		Site Level location:
			/_cs_apps/config/proxyWhiteList.xml
			
		proxyWhiteList Node:
			<courseListBuilder>getResultsList,renderItem</courseListBuilder>
			
		Example File:
			/ADF/extensions/customfields/object_list_builder/site-files/_cs_apps/config/proxyWhiteList.xml


8. Reset the ADF (?resetADF=1)


9. Add the Object-List-Builder Custom Field to existing or new Custom Element (Local or Global)
		Update the Custom Field Properties with the name of the custom Configuration component (Eg. courseListBuilder.cfc) 
		that was placed in the "/_cs_apps/components/" directory (from step 6).
		
		Example Custom Field Type "Other Properties":
			Component Name: courseListBuilder


Addtional Information:

- ADF thirdParty libraries used for this custom field type:
		jquery - loaded from the "/ADF/thirdParty/jquery/" directory
		jqueryUI - loaded from the "/ADF/thirdParty/jquery/ui/" directory
		jquery typeahead bundle - loaded from the "/ADF/thirdParty/jquery/typeahead/" directory
		ckeditor - loaded by default from the ckeditor.com CDN "//cdn.ckeditor.com/4.4.7/full/ckeditor.js" 
				   or it can be installed and the loaded from a site level directory "/cs_customization/ckeditor/ckeditor.js"

- Libraries included in this custom field type:
		ckeditor plugins - loaded from the "/extensions/customfields/object_list_builder/plugins/" directory:
			listformat - plugin used for ObjectListBuilder's formats display
			cslink - plugin used to invoke CommonSpot's insert-link dialog.
			csimage - plugin used to invoke CommonSpot's insert-image dialog and access to CommonSpot's Image Gallery.






	
			
	
		
	
			