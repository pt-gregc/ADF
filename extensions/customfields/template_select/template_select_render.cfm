<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc.  Copyright (c) 2009-2016.
All Rights Reserved.
 
By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->
<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
Custom Field Type:
	Template Select
Name:
	template_select_render.cfm
Summary:
	Custom field type to select from the CS templates
ADF Requirements:
	scripts_1_0
	csData_1_0
History:
	2007-01-24 - RLW - Created
	2011-10-22 - MFC - Set the default selected value to be stored when loading the CFT.
	2012-02-06 - MFC - Updated scripts to load with the site ADF
	2013-02-20 - MFC - Replaced Jquery "$" references.
	2013-03-08 - GAC - Updated to use the wrapFieldHTML function
	2014-10-31 - GAC - Added the editOnce option
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	if ( NOT StructKeyExists(xparams, "filterList") OR LEN(xparams.filterList) LTE 0 )
		xparams.filterList = "";
	if ( NOT StructKeyExists(xparams, "editOnce") )
		xparams.editOnce = 0;	
		
	//-- App Override Variables --//
	if ( NOT StructKeyExists(xparams, "appBeanName") OR LEN(xparams.appBeanName) LTE 0 )
		xparams.appBeanName = "";
	if ( NOT StructKeyExists(xparams, "appPropsVarName") OR LEN(xparams.appPropsVarName) LTE 0 )
		xparams.appPropsVarName = "";
		
	xparamsExceptionsList = "appBeanName,appPropsVarName";

	// Optional ADF App Override for the Custom Field Type XPARAMS
	If ( LEN(TRIM(xparams.appBeanName)) AND LEN(TRIM(xparams.appPropsVarName)) ) {
		xparams = application.ADF.utils.appOverrideCSParams(
													csParams=xparams,
													appName=xparams.appBeanName,
													appParamsVarName=xparams.appPropsVarName,
													paramsExceptionList=xparamsExceptionsList
												);
	}
	
	// Updated scripts to load with the site ADF
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQuerySelectboxes();
	
	// Added for future use
	// TODO: Add options in Props for a Bean and a Method that return a custom Subsite Struct
	templateStructBeanName = "csData_1_2";
	templateStructMethodName = "getSiteTemplates";
	
	selectField = "select_#fqFieldName#";
	
	// Set defaults for the label and description 
	includeLabel = true;
	includeDescription = true; 

	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";

	//-- Read Only Check w/ cs6 fieldPermission parameter --
	readOnly = application.ADF.forms.isFieldReadOnly(xparams,variables.fieldPermission);
	
	if ( LEN(currentValue) AND xparams.editOnce )
		readOnly = true;
</cfscript>
<cfoutput>
	<script type="text/javascript">
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
		#fqFieldName#.msg="Please select a value for the #xparams.label# field.";
		#fqFieldName#.validator = "validate_#fqFieldName#()";

		//If the field is required
		if ( '#xparams.req#' == 'Yes' ){
			// push on to validation array
			vobjects_#attributes.formname#.push(#fqFieldName#);
		}

		// Validation function
		function validate_#fqFieldName#(){
			if ( jQuery("select[name=#fqFieldName#_select]").val() != ''){
				return true;
			}
			return false;
		}
		
		// get the list of subsites and load them into the select list
		function #fqFieldName#_loadTemplates()
		{
			//Show the ajax working image
			jQuery("###selectField#_loading").show();
			
			jQuery.get("#application.ADF.ajaxProxy#",
				{ 	bean: "#templateStructBeanName#",
					method: "#templateStructMethodName#",
					filterValueList: "#xparams.filterList#",
					oderby: "title",
					returnFormat: "json" },
				function( subsiteStruct )
				{
					// Load the options to the select field
					jQuery.each(subsiteStruct, function(i, val) {
						jQuery("###fqFieldName#_select").addOption(i, val);
					});
					// Sort the options
					jQuery("###fqFieldName#_select").sortOptions();
					
					// Set the selected field for the current value
					jQuery("###fqFieldName#_select option[value='#currentValue#']").attr("selected", true);
					
					// Load the on change binding for the select field
					#fqFieldName#_loadBinding();
					
					//Hide the ajax working image
					jQuery("###selectField#_loading").hide();
					
					ResizeWindow();
				},
				"json"
			);
		}
		
		function #fqFieldName#_loadBinding() {
			// Use 'click' event b/c 'change' not supported with LIVE in 1.3.2
			jQuery("###fqFieldName#_select").change( function(){
				// put the selected value into the fqFieldName
				jQuery("input[name=#fqFieldName#]").val(jQuery(this).val());
			});
			
			// 2011-10-22 - MFC - Load the current selection into the saved field
			jQuery("input[name=#fqFieldName#]").val(jQuery("###fqFieldName#_select option:selected").val());
		}
		
		jQuery(document).ready(function() {
			#fqFieldName#_loadTemplates();
		});
	</script>
	
	<cfsavecontent variable="inputHTML">
		<cfoutput>
		<select name="#fqFieldName#_select" id="#fqFieldName#_select" size="1"<cfif readOnly> disabled='disabled'</cfif>>
			<option value="">--Select--</option>
		</select>
		<span id="#selectField#_loading" style="display:none;font-size:10px;">
			<img src="/ADF/extensions/customfields/template_select/ajax-loader-arrows.gif" width="16" height="16" /> Loading Templates...
		</span>
		<!--- hidden field to store the value --->
		<input type='hidden' name='#fqFieldName#' id='#fqFieldName#' value='#currentValue#'>
		</cfoutput>
	</cfsavecontent>	
	
	<!---
		This CFT is using the forms lib wrapFieldHTML functionality. The wrapFieldHTML takes
		the Form Field HTML that you want to put into the TD of the right section of the CFT 
		table row and helps with display formatting, adds the hidden simple form fields (if needed) 
		and handles field permissions (other than read-only).
		Optionally you can disable the field label and the field discription by setting 
		the includeLabel and/or the includeDescription variables (found above) to false.  
	--->
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission,includeLabel,includeDescription)#
</cfoutput>