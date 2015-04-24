<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!---
	/* ***************************************************************
	/*
	Author: 	Ron West
	Name:
		$make_CFT_list.cfm
	Summary:	
		Form for making a custom field type be list style fields
	History:
		2009-11-17 - RLW - Created
		2010-09-03 - MFC - Updated to change the AJAX method to "getFieldTypes"
--->
<cfscript>
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQuerySelectBoxes();
</cfscript>

<cfoutput>
	<script type="text/javascript">
		var customFields = "";
		// get the fieldTypes
		jQuery( function(){
			// load the action onto the onchange
			jQuery(".fieldTypes").bind("change", loadFieldType);
			// bind the submit process
			jQuery("##save").bind("click", saveForm);
			// get the available field types
			getFieldTypes();		
		});
		function getFieldTypes(){
			// get the custom field types
			jQuery.get("#application.ADF.ajaxProxy#",
				{
					bean: "utils_1_0",
					//method: "getCFTypes",
					method: "getFieldTypes",
					returnformat: "json"
				}, function(results){
					customFields = eval('(' + results + ')');
					for( i=1; i < customFields.length; i++ ){
						jQuery(".fieldTypes").addOption(i, customFields[i]["TYPE"]);
					}
					// reselect the "select" option
					jQuery(".fieldTypes").selectOptions("");
				}
			);		
		}
		function loadFieldType(){
			var curVal = jQuery(".fieldTypes").selectedValues();
			var curFT = "";
			if( curVal.length )
			{
				jQuery("##type").attr("value", customFields[curVal]["TYPE"]);
				jQuery("##renderModule").attr("value", customFields[curVal]["RENDERMODULE"]);
				jQuery("##propertyModule").attr("value", customFields[curVal]["PROPERTYMODULE"]);
				jQuery("##JSValidator").attr("value", customFields[curVal]["JSVALIDATOR"]);
				jQuery("##active").attr("value", customFields[curVal]["ACTIVE"]);
				jQuery("##ID").attr("value", customFields[curVal]["ID"]);
			}
			return true;
		}
		function saveForm(){
			if( jQuery("##ID").attr("value").length == 0 )
				return false;
			// clear the responses
			jQuery("##save").attr("disabled", true);
			jQuery("##success").hide();
			jQuery("##failure").hide();
			// make the call
			jQuery.post("#application.ADF.ajaxProxy#",
				{
					bean: "utils_1_0",
					method: "updateCustomFieldType",
					ID: jQuery("##ID").attr("value"),
					type: jQuery("##type").attr("value"),
					propertyModule: jQuery("##propertyModule").attr("value"),
					renderModule: jQuery("##renderModule").attr("value"),
					JSValidator: jQuery("##JSValidator").attr("value"),
					active: jQuery("##active").attr("value")
				},function (results){
					
					if( results == "true" )
						jQuery("##success").show();
					else
						jQuery("##failure").show();
					// reset form
					getFieldTypes();
					resetForm();
				}
			);
			// handle results
			jQuery("##save").attr("disabled", false);
			return true;
		}
		function resetForm(){
			jQuery("##type").attr("value", "");
			jQuery("##renderModule").attr("value", "");
			jQuery("##propertyModule").attr("value", "");
			jQuery("##JSValidator").attr("value", "");
			jQuery("##active").attr("value", "");
			jQuery("##ID").attr("value", "");	
		}
	</script>
	<h2>Make Custom Field Type a "List" type</h2>
	<p>This script will update a field type to a "list" type.  This will allow you to use filters like:
		<ul>
			<li>Any list item contained in list</li>
			<li>All list items contained in list</li>
		</ul>
	when you select "Render Mode" for the Custom Element.
	</p>
	<p>
		<ul>
			<li>Step 1: Select the field type you would like to use</li>
			<li>Step 2: Enter "list" into the JSValidator Field</li>
			<li>Step 3: Save</li>
		</ul>
	</p>
	<form id="fieldType">
		Select Field Type: <select class="fieldTypes" size="1">
			<option value="">-- Select --</option>					
		</select><br />
		<fieldset>
			<label for="type">Type:</label> <input type="text" name="type" id="type" disabled="disabled" /><br />
			<label for="propertyModule">Property Module:</label> <input type="text" name="propertyModule" id="propertyModule" size="80" /><br />
			<label for="renderModule">Render Module:</label> <input type="text" name="renderModule" id="renderModule" size="80" /><br />
			<label for="JSValidator">JSValidator:</label> <input type="text" name="JSValidator" id="JSValidator" /><br />
			<label for="Active">Active:</label> <input type="text" name="active" id="active" disabled="disabled" /><br />
			<input type="hidden" name="ID" id="ID" />
		</fieldset>
		<fieldset>
			<div id="success" style="display:none;">Form saved successfully</div>
			<div id="failure" style="display:none;">Error saving form</div>
			<input type="button" id="save" value="save" />
		</fieldset>
	</form>

</cfoutput>