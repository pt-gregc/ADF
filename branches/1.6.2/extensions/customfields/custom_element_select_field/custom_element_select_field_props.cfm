<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2013.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Michael Carroll
Custom Field Type:
	Custom Element Select Field
Name:
	custom_element_select_field_props.cfm
Summary:
	Custom Element select field to select the custom element fields for the
		option id and name values.
	Added Properties to set the field name value, default field value, and field visibility.
ADF Requirements:
	csData_2_0
	scripts_1_2
History:
	2009-07-06 - MFC - Created
	2010-09-17 - MFC - Updated the Default Value field to add [] to the value
						to make it evaluate a CF expression.
	2010-12-06 - RAK - Added the ability to define an active flag
						Added ability to dynamically build the display field - <firstName> <lastName>:At <email>
	2011-03-08 - MFC - Updated AJAX calls for bean "ceData_1_1".
	2011-04-20 - RAK - Added the ability to have a multiple select field and size it
	2011-05-04 - MFC - Updated JQuery functions to work with older JQuery versions.
	2011-06-23 - RAK - Added sortField option
	2011-06-23 - GAC - Added the addtional field descriptions to the display field and sort field options
					- Modified the "Other" option  from the displayFieldBuilder to be "--Other--" to make more visible and to avoid CE field name conflicts 
	2011-12-28 - MFC - Force JQuery to "noconflict" mode to resolve issues with CS 6.2.
	2013-09-27 - GAC - Added a renderSelectOption to allow the 'SELECT' text to be added or removed from the selection list
	2013-11-14 - GAC - Reorganized the props fields
	2013-11-15 - GAC - Converted the CFT to the ADF standard CFT format using the defaultValues struct to build the current values
					 - Updated AJAX calls to use the "ceData_2_0" lib using a ajaxCEDataBean variable
--->
<cfscript>
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	
	// Setup the default values
	defaultValues = StructNew();
	defaultValues.customElement = "";
	defaultValues.valueField = "";
	defaultValues.displayField = "";
	defaultValues.renderField = "yes";
	defaultValues.defaultVal = "";
	defaultValues.fldName = "";
	defaultValues.forceScripts = "0";
	defaultValues.displayFieldBuilder = "";
	defaultValues.activeFlagField = "";
	defaultValues.activeFlagValue = "";
	defaultValues.addButton = "";
	defaultValues.multipleSelect = "";
	defaultValues.multipleSelectSize = "";
	defaultValues.sortByField = "";
	
	// This will override the current values with the default values.
	// In normal use this should not need to be modified.
	defaultValueArray = StructKeyArray(defaultValues);
	for(i=1;i<=ArrayLen(defaultValueArray);i++){
		// If there is a default value to exists in the current values
		//	AND the current value is an empty string
		//	OR the default value does not exist in the current values
		if( ( StructKeyExists(currentValues, defaultValueArray[i]) 
				AND (NOT LEN(currentValues[defaultValueArray[i]])) )
				OR (NOT StructKeyExists(currentValues, defaultValueArray[i])) ){
			currentValues[defaultValueArray[i]] = defaultValues[defaultValueArray[i]];
		}
	}

	// For backwards compatiblity: 
	// - when using a Single Select the render Select Option must be explicity TURNED OFF to be disabled
	// - but for a Multi Select the render Select Option must be explicity TURNED ON to be enabled 
	// - and we must leave this as an available option Multi Select dropdowns
	if ( !StructKeyExists(currentValues,"renderSelectOption") OR !IsBoolean(currentValues.renderSelectOption) ) {
		currentValues.renderSelectOption = true;
		if ( currentValues.multipleSelect )
			currentValues.renderSelectOption = false;
	}
	
	// Query to get the Custom Element List
	customElements = application.ADF.ceData.getAllCustomElements();
	// 2013-11-15 - GAC - Set to use 'ceData_2_0'
	ajaxCEDataBean = "ceData_2_0";
	
	application.ADF.scripts.loadJQuery(noConflict=true);
	application.ADF.scripts.loadJQuerySelectboxes();
</cfscript>

<cfoutput>
<script type="text/javascript">
	fieldProperties['#typeid#'].paramFields = "#prefix#customElement,#prefix#valueField,#prefix#displayField,#prefix#renderField,#prefix#defaultVal,#prefix#fldName,#prefix#forceScripts,#prefix#displayFieldBuilder,#prefix#activeFlagField,#prefix#activeFlagValue,#prefix#addButton,#prefix#multipleSelect,#prefix#multipleSelectSize,#prefix#sortByField,#prefix#renderSelectOption";
	// allows this field to support the orange icon (copy down to label from field name)
	fieldProperties['#typeid#'].jsLabelUpdater = '#prefix#doLabel';
	// allows this field to have a common onSubmit Validator
	//fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
	// handling the copy label function
	function #prefix#doLabel(str) {
		document.#formname#.#prefix#label.value = str;
	}
	
	jQuery(document).ready(function(){
		var customElement = "###prefix#customElement";
		var customElementValue = "###prefix#valueField";
		<cfif len(currentValues.customElement) gt 0>
			#prefix#setElementFields("#currentValues.customElement#");
			jQuery("###prefix#valueField").selectOptions("#currentValues.valueField#");
			jQuery("###prefix#displayField").selectOptions("#currentValues.displayField#");
			jQuery("###prefix#activeFlagField").selectOptions("#currentValues.activeFlagField#");
			jQuery("###prefix#sortByField").selectOptions("#currentValues.sortByField#");

			#prefix#handleDisplayFieldChange();
		</cfif>

		jQuery(customElement).change(function(){
			#prefix#setElementFields(jQuery(customElement).val());
			#prefix#handleDisplayFieldChange();
		});
		jQuery('###prefix#displayField').change(#prefix#handleDisplayFieldChange);
		jQuery("###prefix#fieldBuilder").change(function(){
			var fieldBuilderVal = jQuery("###prefix#fieldBuilder").val();
			//If the selected value is not -- and its the "build your own" add to the end of the string
			if(fieldBuilderVal != "--" && jQuery('###prefix#displayField').val() == "--Other--"){
				var tempVal = jQuery("###prefix#displayFieldBuilder").val();
				tempVal = tempVal + String.fromCharCode(171) + fieldBuilderVal + String.fromCharCode(187);
				jQuery("###prefix#displayFieldBuilder").val(tempVal);
				jQuery("###prefix#fieldBuilder").selectOptions('--');
				jQuery("###prefix#displayFieldBuilder").focus();
			}
		});
	});

	function #prefix#handleDisplayFieldChange(){
		if (jQuery('###prefix#displayField').val() == "--Other--"){
			jQuery(".other").show();
			jQuery(".otherMsg").hide();
		}
		else {
			jQuery(".other").hide();
			jQuery(".otherMsg").show();
			jQuery("###prefix#displayFieldBuilder").val("");
		}
	}

	//When the element name gets updated begin the process for updating the select fields
	function #prefix#setElementFields(elementName){
		if (elementName.length <= 0){
			return;
		}
		// 2011-03-18 - MFC - Updated to the 'ceData_1_1'
		// 2013-11-15 - GAC - Updated to use ajaxCEDataBean variable
		jQuery.ajax({
					type: 'POST',
					url: "#application.ADF.ajaxProxy#",
					data: { 	  bean: "#ajaxCEDataBean#",
								method: "getFormIDByCEName",
								CENAME: elementName},
					success: #prefix#handleFormIDPost,
		  		 	async: false
				});

	}

	//Given a formID get the tabs and pass it off to the next step
	function #prefix#handleFormIDPost(results){
		if (results != 0){
			// 2011-03-18 - MFC - Updated to the 'ceData_1_1'
			// 2013-11-15 - GAC - Updated to use ajaxCEDataBean variable
			jQuery.ajax({
				  type: 'POST',
				  url: "#application.ADF.ajaxProxy#",
				  data: { bean: "#ajaxCEDataBean#",
						  method: "getTabsFromFormID",
						  returnformat: "json",
						  formID: results,
						  recurse: true},
				  success: #prefix#handleTabsFromFormIDPost,
				  async: false
				},"json");
		}
	}

	//Handle getting the tab data and populate the select boxes.
	function  #prefix#handleTabsFromFormIDPost(results){
		var fields = new Object();
		if (typeof results === "string"){
			results = jQuery.parseJSON(results);
		}
		var fieldInfo = results;
		if (!jQuery.isArray(fieldInfo)){
			var fieldInfoTemp = Array();
			fieldInfoTemp[1] = fieldInfo;
			fieldInfo = fieldInfoTemp;
		}

		//Loop over each tab to create an object keyed on the field name with a value of label.
		jQuery(fieldInfo).each(function(fieldIndex,tab){
			jQuery(tab['FIELDS']).each(function(index,field){
				fields[field.DEFAULTVALUES.FIELDNAME] = field.DEFAULTVALUES.LABEL;
			});
		});

				//Remove options
		jQuery("###prefix#valueField").removeOption(/./);
		jQuery("###prefix#displayField").removeOption(/./);
		jQuery("###prefix#fieldBuilder").removeOption(/./);
		jQuery("###prefix#activeFlagField").removeOption(/./);
		jQuery("###prefix#sortByField").removeOption(/./);


		//Add new options
		jQuery("###prefix#valueField").addOption(fields);

		jQuery("###prefix#activeFlagField").addOption({"--":'--'});
		jQuery("###prefix#activeFlagField").addOption(fields);
		jQuery("###prefix#activeFlagField").selectOptions('--');

		jQuery("###prefix#sortByField").addOption({"--":'--'});
		jQuery("###prefix#sortByField").addOption(fields);
		jQuery("###prefix#sortByField").selectOptions('--');

		jQuery("###prefix#fieldBuilder").addOption({"--":'--'});
		jQuery("###prefix#fieldBuilder").addOption(fields);
		jQuery("###prefix#fieldBuilder").selectOptions('--');

		fields["--Other--"] = "--Other--";
		jQuery("###prefix#displayField").addOption(fields);

		//Deselect everything
		jQuery("###prefix#valueField").selectOptions(jQuery("###prefix#valueField").selectedOptions(),true);
		jQuery("###prefix#displayField").selectOptions(jQuery("###prefix#displayField").selectedOptions(),true);
	}
</script>

<table>
	<tr>
		<td class="cs_dlgLabelSmall">Custom Element:</td>
		<td class="cs_dlgLabelSmall">
			<select id="#prefix#customElement" name="#prefix#customElement" size="1">
				<option value="" selected> - Select - </option>
				<cfloop query="customElements">
					<option value="#FormName#" <cfif currentValues.customElement EQ FormName>selected</cfif>>#FormName#</option>
				</cfloop>
			</select>
			<!--- <input type="text" name="#prefix#customElement" id="#prefix#customElement" value="#currentValues.customElement#" size="40"> --->
		</td>
	</tr>
	<tr>
		<td class="cs_dlgLabelSmall">Select Value Field:</td>
		<td class="cs_dlgLabelSmall">
			<select name="#prefix#valueField" id="#prefix#valueField">
			</select>
		</td>
	</tr>
	<tr>
		<td class="cs_dlgLabelSmall">Select Display Field:</td>
		<td class="cs_dlgLabelSmall">
			<select  name="#prefix#displayField" id="#prefix#displayField">
			</select>
			<br /><span class="otherMsg">Select '--Other--' to build Custom Display Text from the available fields.</span>
		</td>
	</tr>
	<tr class="other" style="display:none">
		<td class="cs_dlgLabelSmall">Custom Display Text:</td>
		<td class="cs_dlgLabelSmall">
			<span>Build your own display. Select a field from the drop down to have it added to the Custom Display Text field.</span>
			<br/>
			<select id="#prefix#fieldBuilder"></select>
			<br/>
			<input type="text" name="#prefix#displayFieldBuilder" value="#currentValues.displayFieldBuilder#" id="#prefix#displayFieldBuilder" size="40">
		</td>
	</tr>
	<tr>
		<td class="cs_dlgLabelSmall">Sort By Field:</td>
		<td class="cs_dlgLabelSmall">
			<select name="#prefix#sortByField" id="#prefix#sortByField">
			</select>
			<br /><span>Leave blank to sort by the Select Display Field or Custom Display Text.</span>
		</td>
	</tr>
	<tr>
		<td class="cs_dlgLabelSmall">Active Flag</td>
		<td class="cs_dlgLabelSmall">
			Field: <select name="#prefix#activeFlagField" id="#prefix#activeFlagField"></select>
		</td>
	</tr>
	<tr>
		<td></td>
		<td class="cs_dlgLabelSmall">
			Value: <input type="text" name="#prefix#activeFlagValue" id="#prefix#activeFlagValue" value="#currentValues.activeFlagValue#" size="20">
			<br />To denote a ColdFusion Expression, add brackets around the expression (i.e. "[request.user.userid]")
		</td>
	</tr>
	<tr>
		<td class="cs_dlgLabelSmall">Default Field Value:</td>
		<td class="cs_dlgLabelSmall">
			<input type="text" name="#prefix#defaultVal" id="#prefix#defaultVal" value="#currentValues.defaultVal#" size="40">
			<br />To denote a ColdFusion Expression, add brackets around the expression (i.e. "[request.user.userid]")
		</td>
	</tr>
	
	<tr>
		<td colspan="2"><hr /></td>
	</tr>
	<tr>
		<td class="cs_dlgLabelSmall">Select Option:</td>
		<td class="cs_dlgLabelSmall">
				Yes <input type="radio" id="#prefix#renderSelectOption" name="#prefix#renderSelectOption" value="1" <cfif currentValues.renderSelectOption EQ "1">checked</cfif>>&nbsp;&nbsp;&nbsp;
				No <input type="radio" id="#prefix#renderSelectOption" name="#prefix#renderSelectOption" value="0" <cfif currentValues.renderSelectOption EQ "0">checked</cfif>><br />
				Places a '--Select--' option in the list. <!--- Cannot be used with a multiple selection list. ---> 
				<!--- // Must leave this option available for multiple selections lists for backwards compatiblity --->
		</td>
	</tr>
	<tr>
		<td class="cs_dlgLabelSmall">Multiple Select:</td>
		<td class="cs_dlgLabelSmall">
				Yes <input type="radio" id="#prefix#multipleSelect" name="#prefix#multipleSelect" value="1" <cfif currentValues.multipleSelect EQ "1">checked</cfif>>&nbsp;&nbsp;&nbsp;
				No <input type="radio" id="#prefix#multipleSelect" name="#prefix#multipleSelect" value="0" <cfif currentValues.multipleSelect EQ "0">checked</cfif>><br />
		</td>
	</tr>
	<tr>
		<td class="cs_dlgLabelSmall">Multiple Select Size:</td>
		<td class="cs_dlgLabelSmall">
				<input id="#prefix#multipleSelectSize" name="#prefix#multipleSelectSize" value="#currentValues.multipleSelectSize#" size="3">
		</td>
	</tr>	
	
	<tr>
		<td colspan="2"><hr /></td>
	</tr>
	<tr>
		<td class="cs_dlgLabelSmall">Field Name:</td>
		<td class="cs_dlgLabelSmall">
			<input type="text" name="#prefix#fldName" id="#prefix#fldName" value="#currentValues.fldName#" size="40">
			<br/><span>Please enter the field name to be used via JavaScript (case sensitive).  If blank, will use default name.</span>
		</td>
	</tr>
	<tr>
		<td class="cs_dlgLabelSmall">Field Display Type:</td>
		<td class="cs_dlgLabelSmall">
			<input type="radio" name="#prefix#renderField" id="#prefix#renderField" value="yes" <cfif currentValues.renderField eq 'yes'>checked</cfif>>Visible
			<input type="radio" name="#prefix#renderField" id="#prefix#renderField" value="no" <cfif currentValues.renderField eq 'no'>checked</cfif>>Hidden
		</td>
	</tr>
	<tr>
		<td class="cs_dlgLabelSmall">Add Button:</td>
			<td class="cs_dlgLabelSmall">
				Yes <input type="radio" id="#prefix#addButton" name="#prefix#addButton" value="1" <cfif currentValues.addButton EQ "1">checked</cfif>>&nbsp;&nbsp;&nbsp;
				No <input type="radio" id="#prefix#addButton" name="#prefix#addButton" value="0" <cfif currentValues.addButton EQ "0">checked</cfif>><br />
		</td>
	</tr>
	<tr>
		<td class="cs_dlgLabelSmall">Force Loading Scripts:</td>
			<td class="cs_dlgLabelSmall">
				Yes <input type="radio" id="#prefix#forceScripts" name="#prefix#forceScripts" value="1" <cfif currentValues.forceScripts EQ "1">checked</cfif>>&nbsp;&nbsp;&nbsp;
				No <input type="radio" id="#prefix#forceScripts" name="#prefix#forceScripts" value="0" <cfif currentValues.forceScripts EQ "0">checked</cfif>><br />
				Force the JQuery script to load.
		</td>
	</tr>
</table>
</cfoutput>