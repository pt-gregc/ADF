<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
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
	Subsite Select
Name:
	subsite_select_render.cfm
Summary:
	Custom field type, that allows a new subsite to be created
ADF Requirements:
	script_1_0
	csData_1_0
History:
	2007-01-24 - RLW - Created
	2011-02-08 - GAC - Removed old jQuery tools reference
					 - Replaced the getBean call with application.ADF
	2012-02-13 - GAC - Updated to use accept a filter porperty and a uitheme propery 
					 - Also added the appBeanName and appPropsVarName props to allow porps to be overridden by an app
	2013-03-07 - GAC - Fixed an issue with the Required field validation script.
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	if ( NOT StructKeyExists(xparams, "allowSubsiteAdd") OR LEN(xparams.allowSubsiteAdd) LTE 0 )
		xparams.allowSubsiteAdd = "no";
	if ( NOT StructKeyExists(xparams, "uiTheme") OR LEN(xparams.uiTheme) LTE 0 )
		xparams.uiTheme = "smoothness";
	if ( NOT StructKeyExists(xparams, "filterList") OR LEN(xparams.filterList) LTE 0 )
		xparams.filterList = "";	
		
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
	
	// load the jQuery library
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQueryUI(themeName=xparams.uiTheme);
	application.ADF.scripts.loadJQuerySelectboxes();
	//application.ADF.scripts.loadADFLightbox();
	
	// Added for future use
	// TODO: Add options in Props for a Bean and a Method that return a custom Subsite Struct
	subsiteStructBeanName = "csData_1_2";
	subsiteStructMethodName = "getSubsiteStruct";
	
	selectField = "select_#fqFieldName#";
	
	currentValueText = "";
	// If the currentValue has a numeric value get the subsiteURL for that subsiteID
	if ( LEN(TRIM(currentValue)) AND IsNumeric(currentValue) AND StructKeyExists(request.subsitecache,currentValue) ) 
		currentValueText = request.subsitecache[currentValue].URL;
	
	// Set defaults for the label and description 
	includeLabel = true;
	includeDescription = true; 

	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";

	//-- Read Only Check w/ cs6 fieldPermission parameter --
	readOnly = application.ADF.forms.isFieldReadOnly(xparams,variables.fieldPermission);
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
			if ( jQuery("select[name=#fqFieldName#]").val() != '') {
				return true;
			}
			return false;
		}
		
		// init allowSubsiteAdd show/hide options
		var options = {};
		
		// handle on start processing
		jQuery(function() {
			//Hide the ajax working image
			jQuery("###selectField#_loading").hide();	
			
			<!--- // TODO: future enhancement --->
			<!--- // jQuery("###fqFieldName#_new_button").button(); --->
				
			// load the list of subsites
			#fqFieldName#_loadSubsites();		
		});
		
		// get the list of subsites and load them into the select list
		function #fqFieldName#_loadSubsites()
		{
			//Show the ajax working image
			jQuery("###selectField#_loading").show();
			
			jQuery.get("#application.ADF.ajaxProxy#",
				{ 	
					bean: "#subsiteStructBeanName#",
					method: "#subsiteStructMethodName#",
					filterValueList: "#xparams.filterList#",
					orderby: "subsiteURL",
					returnFormat: "json" 
				},
				function( subsiteStruct )
				{
					var cValue = "#currentValue#";
					var cValueText = "#currentValueText#";
					
					// If currentValue has a value add it as an option
					if ( cValue.length && cValueText.length ) {
						jQuery("###fqFieldName#").addOption(cValue, cValueText);
					}
					
					jQuery.each(subsiteStruct, function(i, val) {
						jQuery("###fqFieldName#").addOption(i, val);
					});
					
					// Sort by Options by Struct Value
					jQuery("###fqFieldName#").sortOptions();
					
					if ( cValue.length && cValueText.length ) {
						// make the current subsite selected
						jQuery("###fqFieldName#").selectOptions(cValue);
					} else {
						jQuery("###fqFieldName#").selectOptions("");
					}
					
					//Hide the ajax working image
					jQuery("###selectField#_loading").hide();
					
					ResizeWindow();
				},
				"json"
			);
		}
		
		<cfif xparams.allowSubsiteAdd>
		function #fqFieldName#addSubsite(name, displayName, description)
		{
			// get values from the form fields
			var subsiteName = jQuery("###fqFieldName#_name").attr("value");
			var displayName = jQuery("###fqFieldName#_display").attr("value");
			var description = jQuery("###fqFieldName#_descr").attr("value");
			var parentSubsiteID = jQuery("###fqFieldName#").selectedValues();
			// make the call to add the subsite
			jQuery.post("#application.ADF.ajaxProxy#", 
				{ 
					bean: "csData",
					method: "addSubsite",
					name: subsiteName,
					displayName: displayName,
					description: description,
					parentSubsiteID: parentSubsiteID,
					returnFormat: "json" 
				},
				function(newSubsiteID){
				 	// reload the subsite listing
				 	#fqFieldName#_loadSubsites();
				 	// select the new subsite
				 	jQuery("###fqFieldName#").selectOptions(newSubsiteID);
				 	// close the dialog and show the "add message"
				 	jQuery("###fqFieldName#_add").dialog("close");
				 	jQuery("###fqFieldName#_add_msg").show("blind", options, 500, callback);
				 	jQuery("###fqFieldName#_add_msg").hide("blind", options, 1500, callback);
				 },
				 "json"
			);
		}
		</cfif>		
	</script>

	<cfsavecontent variable="inputHTML">
		<cfoutput>
			<!--- // TODO: future enhancement --->
			<!--- <div id="#fqFieldName#_add_msg" style="display:none;">
				Subsite Added
			</div> --->
			<select name="#fqFieldName#" id="#fqFieldName#" size="1"<cfif readOnly> disabled='disabled'</cfif>>
				<option value="">--Select--</option>
			</select>
			<span id="#selectField#_loading" style="display:none;font-size:10px;">
				<img src="/ADF/extensions/customfields/subsite_select/ajax-loader-arrows.gif" width="16" height="16" /> Loading Subsites...
			</span>
			<!--- // TODO: future enhancement --->
			<!---
				<br /><button rel="/ADF/extensions/customfields/subsite_select/add_subsite.cfm?fqfieldName=#fqFieldName#" class="ui-button ui-state-default ui-corner-all ADFLightbox" id="#fqFieldName#_new_button">New Subsite</button>
			--->
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