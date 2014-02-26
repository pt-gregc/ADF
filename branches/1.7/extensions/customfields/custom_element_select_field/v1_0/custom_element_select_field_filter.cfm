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

<!-------------
Author: 	
	PaperThin, Inc. 
Name:
	$custom_element_select_field_filter.cfm
Summary:
	Sample Filter Module
	
		This is a sample filter module for a custom field type.  It is called when rendering the advanced filter criteria UI
		for a metadata/custom element form.
		
		This module should be used for the ADF Custom Element Select field type.
	
	Input:
		The following 'attribute' scope variables are passed to this module.
		
			attributes.customFieldTypeID
				The ID of this custom field type.
							
			attributes.sourceFormID
				The ID of the custom element/metadata form.  
				
			attributes.sourceFieldID
				The ID of the custom element/metadata field.  Use this in combination with the attributes.sourceFormID value to 
				lookup any properties specific to this field instance.
				
			attributes.fieldNameAttributeValue
				The value to be set in the HTML output for the 'Name' attribute
		
		
	Output: 
		You must set the following 'caller' scope variables;

		
			caller.operators (Optional)
		
					This is a list of one or more operators to display for this field type.  
					Possible values are:
	
						in
						notin
						equals
						notequal
						greaterthan
						greaterthanorequals
						lessthan
						lessthanorequals
						contains
						notcontains
						within
						and
						andnot
						like
						likelist
						notlikelist
						alllist
						anylist
						alllistNOT
						anylistNOT
						inlist
						notinlist
						taxonomycontains
						taxonomynotcontains
						multitaxonomycontains
						multitaxonomynotcontains
						multitaxonomyalllist
						multitaxonomyalllistNOT
	
				If no caller.operators string is defined, or it is an empty string, the following operators will be used:
			
						equals,notequal,contains,notcontains,lessthan,lessthanorequals,greaterthan,greaterthanorequals,inlist,notinlist
				
				If your field is a text field list we recommend the default.
				If your field is a date field list we recommend the following operators:
						equals,within,lessthan,lessthanorequals,greaterthan,greaterthanorequals
				If your field is a multi-select list we recommend the following operators:
						equals,notequal,likelist,notlikelist,anylist,anylistNOT,alllist,alllistNOT
						
			caller.fieldHTML
				
					This is the HTML that will be displayed after the operator.  You must render an HTML form field with the both the 
					name and id attributes having a value of #attributes.fieldNameAttributeValue#.  
					
					For example:
						<input type="hidden" id="#attributes.fieldNameAttributeValue#" name="#attributes.fieldNameAttributeValue#" value="">
					or
						<select id="#attributes.fieldNameAttributeValue#" name="#attributes.fieldNameAttributeValue#">...</select>
			
			caller.jsSetValueFunction
				
					This is the javascript code that defines a function to be called to set the value of the field when the dialog initially loads.  
					The function needs to be named setvalue_{CustomFieldTypeID}, where CustomFieldTypeID is the ID of the custom field type. 
					The code for this function will be included once, no matter how many fields of that type are in the operators list.						
					
					For example: if your HTML outputs a simple text <input> control, the function might look like this
							function setValue_#attributes.CustomFieldTypeID#(fieldid,value)
							{
								document.getElementById(fieldid).value = value;
							}						
History:
	2014-01-14 - TP - Created
	2014-01-30 - GAC - Moved into a v1_0 version subfolder						
	2014-02-26 - DJM - Updated version with an external options file
-------------->
<cfset caller.operators = "">
<cfset optionsStruct = StructNew()>
<cfset cfmlInputParams = ''>

<cfset optionsModule = '/ADF/extensions/customfields/custom_element_select_field/v1_0/custom_element_select_field_options.cfm'>

<cfif StructKeyExists(attributes, 'currentValues') AND StructKeyExists(attributes, 'returnCurrentOnly') AND attributes.returnCurrentOnly EQ 1>
	<cfmodule template = "#optionsModule#" attributeCollection="#attributes#">
	<cfset caller.optionsStruct = ArrayToList(optionsStruct.optionText, "<br/>")>
<cfelse>
	<cfsavecontent variable="fieldHTML">
		<cfoutput>
			<span nowrap="nowrap">
			<div id="selected_values_display_XRE" style="width:120px;height:70px;overflow:auto;border:1px inset ##999999;padding:1px;display:none;"></div>
			#Server.CommonSpot.UDF.tag.input(type="button", onclick="javascript:top.commonspot.dialog.server.show('csModule=metadata/form_control/input_control/option-value-select&optionsModule=#optionsModule#&sourceformid=#attributes.sourceformid#&sourcefieldid=#attributes.sourcefieldid#&customFieldTypeID=#attributes.customFieldTypeID#&callBackFunction=updateSelectFieldValues&hiddenFldName=#attributes.fieldNameAttributeValue#&displayFldName=selected_values_display_XRE&btnName=selectBtn_XRE&&selectedValues=');", value="Select...", id="selectBtn_XRE", name="selectBtn_XRE", class="clsPushButton", style="vertical-align:top;")#
			</span>
			#Server.CommonSpot.UDF.tag.input(type="hidden", name="#attributes.fieldNameAttributeValue#", id="#attributes.fieldNameAttributeValue#", value="")#
		</cfoutput>
	</cfsavecontent>
	
	<cfset caller.fieldHTML = fieldHTML>
	
	<cfsavecontent variable="jsSetValue">
		<cfoutput>
			function setValue_#attributes.customFieldTypeID#(objID,values,displayText)
			{
				var fieldName = '#attributes.fieldNameAttributeValue#';
				fieldName = fieldName.replace("_XRE", "_" + objID);
				if (displayText.length > 0)
				{
					document.getElementById('selected_values_display_' + objID).style.display = "block";
					document.getElementById('selected_values_display_' + objID).innerHTML = displayText;
				}
				document.getElementById(fieldName).value = values;
				var urlVal = document.getElementById('selectBtn_' + objID).getAttribute("onclick");
				var startIndex = urlVal.indexOf("selectedValues=");
				var endIndex = urlVal.indexOf("')");
				var selectedValStr = urlVal.substr(startIndex + 15, endIndex - startIndex - 15);
				urlVal = urlVal.replace("selectedValues=" + selectedValStr, "selectedValues=" + values);
				document.getElementById('selectBtn_' + objID).setAttribute("onclick", urlVal);
			}
		</cfoutput>
	</cfsavecontent>
	<cfset caller.jsSetValueFunction = jsSetValue>
</cfif>

<!---
<cfsavecontent variable="fieldHTML">
	<cfif StructCount(optionsStruct)>
		<cfoutput><select name="#attributes.fieldNameAttributeValue#" id="#attributes.fieldNameAttributeValue#" style="font-family:#Request.CP.Font#;font-size:10" multiple="#cfmlInputParams.MultipleSelect#"></cfoutput>
		<cfloop collection="#optionsStruct#" item="i">
			<cfoutput><option value="#optionsStruct[i]#">#i#</option></cfoutput>
		</cfloop>
		<cfoutput></select></cfoutput>
	<cfelse>
		<cfoutput>No values found</cfoutput>
	</cfif>
</cfsavecontent>
<cfset caller.fieldHTML = fieldHTML>


<cfsavecontent variable="jsSetValue">
	<cfif StructCount(optionsStruct)>
		<cfoutput>
		function setValue_#attributes.CustomFieldTypeID#(fieldid,values)
		{
			var selectObj = document.getElementById(fieldid);
			var valuesArr = values.split(',');

			for (var j=0; j<valuesArr.length; j++)
			{
				 for (var i = 0; i < selectObj.options.length; i++)
			    {
			        if (selectObj.options[i].value == valuesArr[j])
			        {
			            selectObj.options[i].selected = true;
			            break;
			        }
			    }
			}
		}
		</cfoutput>
	<cfelse>
	<cfoutput>
		function setValue_#attributes.CustomFieldTypeID#(fieldid,value)
		{
			return;
		}
	</cfoutput>
	</cfif>
</cfsavecontent>
<cfset caller.jsSetValueFunction = jsSetValue>
--->

