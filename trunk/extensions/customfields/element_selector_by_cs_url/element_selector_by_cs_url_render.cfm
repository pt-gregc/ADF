<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the Starter App directory

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
	PaperThin Inc.
Custom Field Type:
	Element Selector
Name:
	element_selector_render.cfm
Summary:
	This field type is designed to allow you to easily get the value/params from another
	field in the same custom element.  Currently only the csPageURL (CommonSpot Page URL) field type has 
	been implemented
History:
	2012-11-04 - GAC - Added the fieldPermission parameter to the wrapFieldHTML function call
					 - Added the includeLabel and includeDescription parameters to the wrapFieldHTML function call
					 - Added readOnly field security code with the cs6 fieldPermission parameter
					 - Updated the wrapFieldHTML explanation comment block
	2014-09-23 - GAC - Fixed to parse CS9 style cs_url field values
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];

	// Set defaults for the label and description 
	includeLabel = true;
	includeDescription = true; 

	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";

	//-- Read Only Check w/ cs6 fieldPermission parameter --
	readOnly = application.ADF.forms.isFieldReadOnly(xparams,variables.fieldPermission);
	
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQuerySelectboxes();
	application.ADF.scripts.loadJQueryUI();
</cfscript>
<cfparam name="xParams.formField" default="">
<cfif not len(xParams.formField)>
	<cfoutput>Error: Please return to the Site Administrator/Elements and select a field to bind to in the "Other Properties" tab of this field</cfoutput>
	<cfexit>
</cfif>
<cfscript>
	// retrieve the parameters for the field connecting to
	fieldParams = application.ADF.ceData.getFieldParamsByID(listLast(xParams.formField, "_"));
</cfscript>

<cfoutput>
	<script>
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

		//Validation function
		function validate_#fqFieldName#(){
			if (jQuery("input[name=#fqFieldName#]").val() != ''){
				return true;
			}else{
				return false;
			}
		}
		// control bindings
		jQuery(function(){
			// bind the get value button
			jQuery("###fqFieldName#getValueBtn").button();
			jQuery("###fqFieldName#getValueBtn").click(#fqFieldName#getCurrentValue);
		})
		
		// retrieve the pageID from the selected field
		function #fqFieldName#getCurrentValue(){
		
			<!--- // RLW - 2011-01-30 - this is where you would write specifc code based on the
					CS field type to retrieve its value --->
			<cfif fieldParams.type eq "cs_url">
				//fieldValue = jQuery("##pagedisp_#xParams.formField#").html();
				
				var isLinkObj = false;
				var fieldValue = '';
				var fieldObj = jQuery("##pagedisp_#xParams.formField#");
				var linkResult = [];
					
				fieldObj.find('a[href]').each(function() {
				    if(this.tagName.toUpperCase() == 'A') {
				        linkResult.push([this.tagName,this.innerHTML,this.href,this.title]);
						isLinkObj = true;
						return;
				    } 
				});

				if ( isLinkObj )
				{
					fieldValue = linkResult[0][3];
				}
				else
				{
					fieldValue = fieldObj;
				}
	
				// remove the non breaking space
				fieldValue = fieldValue.replace(/(&nbsp;)*/g,"");
	
				// if we actually have a value from this field go get the data for this page
				if( fieldValue.length != 0 ) {
				
					// get the pageID for this page (convert the query to an array of structs)
					jQuery.post("#application.ADF.ajaxProxy#",
						{ 	bean: "csData_1_1",
							method: "getCSPageDataByURL",
							csPageURL: fieldValue,
							convertQueryToArray: true,
							returnFormat: "json" },
						function(result){
							// retrieve the elements for this page
							if( result.length )
								#fqFieldName#getPageElements(result[0].id);
						}, "json"
					);
				}
			</cfif>
		}
		// retrieve the elements from the page and populate the selection list
		function #fqFieldName#getPageElements(csPageID){
			// remove the options currently in the list of elements
			jQuery("###fqFieldName#").removeOption(/./);
			// get the elements for the selected page
			jQuery.post("#application.ADF.ajaxProxy#",
				{	bean: "csData_1_1",
					method: "getElementsByPageID",
					pageIDList: csPageID,
					TBandCEOnly: true,
					returnFormat: "json" },
				function(result){
					// now that we have elements build the selection list
					if( result.length )
						#fqFieldName#buildElementList(result);
				}, "json"
			);
		}
		
		// build the list of elements
		function #fqFieldName#buildElementList(elements){
			// loop through each of the elements and build the selectOptions
			for(itm=0; itm < elements.length; itm++ ){
				jQuery("###fqFieldName#").addOption(elements[itm].CONTROLID, elements[itm].SHORTDESC + ' - [' + elements[itm].CONTROLNAME + ']');
			}
		}
	</script>

	<cfsavecontent variable="inputHTML">
		<cfoutput>
			<a href="javascript:;" id="#fqFieldName#getValueBtn">Get elements from selected page</a><br />
			<select name="#fqFieldName#" id='#fqFieldName#'<cfif readOnly> disabled="disabled"</cfif>></select>
			<br /><span class="CS_Form_Description">Select the element from the list - this will be the element that is targeted for the CCAPI call.</span>
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