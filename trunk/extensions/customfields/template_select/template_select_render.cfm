<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2010.
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
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	// Updated scripts to load with the site ADF
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQuerySelectboxes();
</cfscript>
<cfoutput>
	<script type="text/javascript">
		// get the list of subsites and load them into the select list
		function #fqFieldName#_loadTemplates()
		{
			jQuery.get("#application.ADF.ajaxProxy#",
				{ 	bean: "csData_1_0",
					method: "getSiteTemplates",
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
		
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
		//#fqFieldName#.validator="validateBlogName()";
		#fqFieldName#.msg="Please upload a document.";
		// push on to validation array
		//vobjects_#attributes.formname#.push(#fqFieldName#);
		
	</script>
	<!--- // determine if this is rendererd in a simple form or the standard custom element interface --->
	<cfscript>
		if ( structKeyExists(request, "element") )
		{
			labelText = '<span class="CS_Form_Label_Baseline"><label for="#fqFieldName#">#xParams.label#:</label></span>';
			tdClass = 'CS_Form_Label_Baseline';
		}
		else
		{
			labelText = '<label for="#fqFieldName#">#xParams.label#:</label>';
			tdClass = 'cs_dlgLabel';
		}
	</cfscript>
	<tr>
		<td class="#tdClass#" valign="top">#labelText#</td>
		<td class="cs_dlgLabelSmall">
			<select name="#fqFieldName#_select" id="#fqFieldName#_select" size="1"></select>
		</td>
	</tr>
	<!--- hidden field to store the value --->
	<input type='hidden' name='#fqFieldName#' id='#fqFieldName#' value='#currentValue#'>
	<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#listLast(xParams.fieldName, "_")#">
</cfoutput>