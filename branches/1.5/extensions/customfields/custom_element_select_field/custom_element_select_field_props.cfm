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
	csData_1_0
	scripts_1_0
History:
	2009-07-06 - MFC - Created
	2010-09-17 - MFC - Updated the Default Value field to add [] to the value 
						to make it evaluate a CF expression.
	2010-12-06 - RAK - Added the ability to define an active flag
						Added ability to dynamically build the display field - <firstName> <lastName>:At <email>
--->
<cfscript>
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	
	if( not structKeyExists(currentValues, "customElement") )
		currentValues.customElement = "";
	if( not structKeyExists(currentValues, "valueField") )
		currentValues.valueField = "";
	if( not structKeyExists(currentValues, "displayField") )
		currentValues.displayField = "";
	if( not structKeyExists(currentValues, "renderField") )
		currentValues.renderField = "yes";
	if( not structKeyExists(currentValues, "defaultVal") )
		currentValues.defaultVal = "";
	if( not structKeyExists(currentValues, "fldName") )
		currentValues.fldName = "";
	if( not structKeyExists(currentValues, "forceScripts") )
		currentValues.forceScripts = "0";
	if( not structKeyExists(currentValues, "displayFieldBuilder") )
		currentValues.displayFieldBuilder = "";
	if( not structKeyExists(currentValues, "activeFlagField") )
		currentValues.activeFlagField = "";
	if( not structKeyExists(currentValues, "activeFlagValue") )
		currentValues.activeFlagValue = "";
	if( not structKeyExists(currentValues, "addButton") )
		currentValues.addButton = "";

</cfscript>
<cfoutput>
	<cfscript>
		application.ADF.scripts.loadJQuery();
		application.ADF.scripts.loadJQuerySelectboxes();
	</cfscript>
<script type="text/javascript">
	fieldProperties['#typeid#'].paramFields = "#prefix#customElement,#prefix#valueField,#prefix#displayField,#prefix#renderField,#prefix#defaultVal,#prefix#fldName,#prefix#forceScripts,#prefix#displayFieldBuilder,#prefix#activeFlagField,#prefix#activeFlagValue,#prefix#addButton";
	// allows this field to support the orange icon (copy down to label from field name)
	fieldProperties['#typeid#'].jsLabelUpdater = '#prefix#doLabel';
	// allows this field to have a common onSubmit Validator
	//fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
	// handling the copy label function
	function #prefix#doLabel(str)
	{
		document.#formname#.#prefix#label.value = str;
	}
	jQuery(document).ready(function(){
		var customElement = "###prefix#customElement";
		var customElementValue = "###prefix#valueField";
		<cfif len(currentValues.customElement) gt 0>
			setElementFields("#currentValues.customElement#");
			jQuery("###prefix#valueField").selectOptions("#currentValues.valueField#");
			jQuery("###prefix#displayField").selectOptions("#currentValues.displayField#");
			jQuery("###prefix#activeFlagField").selectOptions("#currentValues.activeFlagField#");

			handleDisplayFieldChange();
		</cfif>
		
		jQuery(customElement).change(function(){
			setElementFields(jQuery(customElement).val());
			handleDisplayFieldChange();
		});
		jQuery('###prefix#displayField').change(handleDisplayFieldChange);
		jQuery("###prefix#fieldBuilder").change(function(){
			var fieldBuilderVal = jQuery("###prefix#fieldBuilder").val();
			//If the selected value is not -- and its the "build your own" add to the end of the string
			if(fieldBuilderVal != "--" && jQuery('###prefix#displayField').val() == "Other"){
				var tempVal = jQuery("###prefix#displayFieldBuilder").val();
				tempVal = tempVal + String.fromCharCode(171) + fieldBuilderVal + String.fromCharCode(187);
				jQuery("###prefix#displayFieldBuilder").val(tempVal);
				jQuery("###prefix#fieldBuilder").selectOptions('--');
				jQuery("###prefix#displayFieldBuilder").focus();
			}
		});
	});

	function handleDisplayFieldChange(){
		if(jQuery('###prefix#displayField').val() == "Other"){
			jQuery(".other").show();
		}else{
			jQuery(".other").hide();
			jQuery("###prefix#displayFieldBuilder").val("");
		}
	}
	
	function setElementFields(elementName){
		if(elementName.length <= 0){
			return;
		}
		jQuery.ajax({
					type: 'POST',
					url: "#application.ADF.ajaxProxy#",
					data: { 	  bean: "ceData_1_0",
								method: "getFormIDByCEName",
								CENAME: elementName},
					success: handleFormIDPost,
		  		 	async: false
				});
				
	}
	
	function handleFormIDPost(results){
		jQuery.ajax({
			  type: 'POST',
			  url: "#application.ADF.ajaxProxy#",
			  data: { 			  bean: "ceData_1_0",
									method: "getTabsFromFormID",
							returnformat: "json",
									formID: results,
								  recurse: true},
			  success: handleTabsFromFormIDPost,
			  async: false
			},"json");
	}
	
	function handleTabsFromFormIDPost(results){
		fields = new Object();
		if(typeof results === "string"){
			results = jQuery.parseJSON(results);
		}
		fieldInfo = results;
		if(!jQuery.isArray(fieldInfo)){
			fieldInfoTemp = Array();
			fieldInfoTemp[1] = fieldInfo;
			fieldInfo = fieldInfoTemp;
		}
		fieldInfo.each(function(tab){
			jQuery(tab['FIELDS']).each(function(index,field){
				fields[field.DEFAULTVALUES.FIELDNAME] = field.DEFAULTVALUES.LABEL;
			});
		});
		//Remove options
		jQuery("###prefix#valueField").removeOption(/./);
		jQuery("###prefix#displayField").removeOption(/./);
		jQuery("###prefix#fieldBuilder").removeOption(/./);
		jQuery("###prefix#activeFlagField").removeOption(/./);
		
		//Add new options
		jQuery("###prefix#valueField").addOption(fields);

		jQuery("###prefix#activeFlagField").addOption({"--":'--'});
		jQuery("###prefix#activeFlagField").addOption(fields);
		jQuery("###prefix#activeFlagField").selectOptions('--');


		jQuery("###prefix#fieldBuilder").addOption({"--":'--'});
		jQuery("###prefix#fieldBuilder").addOption(fields);
		jQuery("###prefix#fieldBuilder").selectOptions('--');
		
		fields["Other"] = "Other";
		jQuery("###prefix#displayField").addOption(fields);
		
		//Deselect everything
		jQuery("###prefix#valueField").selectOptions(jQuery("###prefix#valueField").selectedOptions(),true);
		jQuery("###prefix#displayField").selectOptions(jQuery("###prefix#displayField").selectedOptions(),true);
	}
</script>
<!--- query to get the Custom Element List --->
<cfset customElements = server.ADF.objectFactory.getBean("ceData_1_0").getAllCustomElements()>
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
		</td>
	</tr>
	<tr class="other" style="display:none">
		<td></td>
		<td class="cs_dlgLabelSmall">
			<span>Build your own display. Select a field from the drop down to have it added to the field.</span>
			<br/>
			<select id="#prefix#fieldBuilder"></select>
			<br/>
			<input type="text" name="#prefix#displayFieldBuilder" value="#currentValues.displayFieldBuilder#" id="#prefix#displayFieldBuilder" size="40">
		</td>
	</tr>
	<tr>
		<td><br /></td>
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
		<td class="cs_dlgLabelSmall">Default Field Value:</td>
		<td class="cs_dlgLabelSmall">
			<input type="text" name="#prefix#defaultVal" id="#prefix#defaultVal" value="#currentValues.defaultVal#" size="40">
			<br />To denote a ColdFusion Expression, add brackets around the expression (i.e. "[request.user.userid]")
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
	<tr>
		<td class="cs_dlgLabelSmall">Add Button:</td>
			<td class="cs_dlgLabelSmall">
				Yes <input type="radio" id="#prefix#addButton" name="#prefix#addButton" value="1" <cfif currentValues.addButton EQ "1">checked</cfif>>&nbsp;&nbsp;&nbsp;
				No <input type="radio" id="#prefix#addButton" name="#prefix#addButton" value="0" <cfif currentValues.addButton EQ "0">checked</cfif>><br />
		</td>
	</tr>

</table>
</cfoutput>