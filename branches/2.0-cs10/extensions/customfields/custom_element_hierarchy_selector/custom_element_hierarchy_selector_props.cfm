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
/* *************************************************************** */
Author:
	PaperThin, Inc.
Custom Field Type:
	Custom Element Hierarchy Selector
Name:
	custom_element_hierarchy_selector_props.cfc
Summary:
	This the props file for the Custom Element Hierarchy Selector field
ADF Requirements:
	
History:
	2014-01-16 - DJM - Created
	2014-01-29 - GAC - Converted to use AjaxProxy and the ADF Lib
	2014-09-19 - GAC - Removed deprecated doLabel and jsLabelUpdater js calls
	2015-05-12 - DJM - Updated the field version to 2.0
	2015-09-02 - DRM - Add getResourceDependencies support, bump version
--->

<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "2.0.1";
	
	requiredVersion = 9;
	productVersion = ListFirst(ListLast(request.cp.productversion," "),".");
</cfscript>	

<!--- // Make sure we are on CommonSpot 9 or greater --->
<cfif productVersion LT requiredVersion>
	<CFOUTPUT>
		<table border="0" cellpadding="3" cellspacing="0" width="100%" summary="">
			<tr><td class="cs_dlgLabelError">This Custom Field Type requires CommonSpot #requiredVersion# or above.</td></tr>
		</table>
	</CFOUTPUT>
<cfelse>
<cfscript>
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	formID = attributes.formID;
	currentValues = attributes.currentValues;
	
	
	// AjaxProxy Path to make ajax call in context of the site
	ajaxComURL = application.ADF.ajaxProxy;
	ajaxBeanName = 'customElementDataManager';

	if( not structKeyExists(currentValues, "customElement") )
		currentValues.customElement = "";
	if( not structKeyExists(currentValues, "parentField") )
		currentValues.parentField = "";
	if( not structKeyExists(currentValues, "displayField") )
		currentValues.displayField = "";
	if( not structKeyExists(currentValues, "valueField") )
		currentValues.valueField = "";
	if( not structKeyExists(currentValues, "selectionType") )
		currentValues.selectionType = "single";
	if( not structKeyExists(currentValues, "cookieField") )
		currentValues.cookieField = "";
	if( not structKeyExists(currentValues, "defaultValue") )
		currentValues.defaultValue = "";	
	if ( not StructKeyExists(attributes.currentValues, 'useUdef') )
		currentValues.useUdef = 0;		
	if ( not StructKeyExists(attributes.currentValues, 'filterCriteria') )
		currentValues.filterCriteria = "";
	if( not structKeyExists(currentValues, "widthValue") )
		currentValues.widthValue = "";
	if( not structKeyExists(currentValues, "rootNodeText") )
		currentValues.rootNodeText = "";
	if( not structKeyExists(currentValues, "rootValue") )
		currentValues.rootValue = "";
	if( not structKeyExists(currentValues, "heightValue") )
		currentValues.heightValue = "";
		
	customElementObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
	allCustomElements = customElementObj.getList(type="All", state="Active");
	
	if (IsNumeric(currentValues.customElement))
		selectedCEFields = customElementObj.getFields(elementID=currentValues.customElement);
	
	errorMsgCustom = 'An error occurred while trying to perform the operation.';
	selectedCEFields = QueryNew('');
	nonHiddenFields = QueryNew('');
	
	// Create the unique id
	persistentUniqueID = '';
	if (NOT Len(persistentUniqueID))
		persistentUniqueID = CreateUUID();
	
	cfmlFilterCriteria = StructNew();
	if (IsWDDX(currentValues.filterCriteria))
	{
		cfmlFilterCriteria = Server.CommonSpot.UDF.util.WDDXDecode(currentValues.filterCriteria);
	}
</cfscript>

<cfif IsStruct(cfmlFilterCriteria)>
	<!--- Add the filter criteria to the session scope --->
	<cflock scope="session" timeout="5" type="Exclusive"> 
	    <cfscript>		   
			Session['#persistentUniqueID#'] = cfmlFilterCriteria;
		</cfscript>
	</cflock>
</cfif>

<cfif IsNumeric(currentValues.customElement)>
	<cfscript>
		selectedCEFields = customElementObj.getFields(elementID=currentValues.customElement);
	</cfscript>
	
	<cfquery name="nonHiddenFields" dbtype="query">
		SELECT ID, Label AS Name
		  FROM selectedCEFields
		 WHERE lower(Type) <> <cfqueryparam value="hidden" cfsqltype="cf_sql_varchar">
	</cfquery>
</cfif>

<cfscript>
	application.ADF.scripts.loadJQuery(noConflict=true);
</cfscript>

<cfoutput>
<script type="text/javascript">
<!--
	jQuery.noConflict();
	
	fieldProperties['#typeid#'].paramFields = "#prefix#customElement,#prefix#parentField,#prefix#displayField,#prefix#valueField,#prefix#selectionType,#prefix#widthValue,#prefix#rootValue,#prefix#rootNodeText,#prefix#heightValue,#prefix#cookieField,#prefix#filterCriteria,#prefix#useUdef";
	fieldProperties['#typeid#'].defaultValueField = '#prefix#defaultValue';
	fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';

	function #prefix#doValidate()
	{
		var isSelected = 0;
		if ( document.#formname#.#prefix#customElement.selectedIndex == 0 )
		{
			showMsg('Please select a custom element.');
			document.#formname#.#prefix#customElement.focus();
			return false;
		}
		if ( document.#formname#.#prefix#parentField.selectedIndex <= 0 )
		{
			showMsg('Please select a parent field for the custom element.');
			document.#formname#.#prefix#parentField.focus();
			return false;
		}
		if ( document.#formname#.#prefix#displayField.selectedIndex <= 0 )
		{
			showMsg('Please select a display field for the custom element.');
			document.#formname#.#prefix#displayField.focus();
			return false;
		}
		if ( document.#formname#.#prefix#valueField.selectedIndex <= 0 )
		{
			showMsg('Please select a value field for the custom element.');
			document.#formname#.#prefix#valueField.focus();
			return false;
		}
		if ( document.#formname#.#prefix#widthValue.value.length > 0 && !checkinteger(document.#formname#.#prefix#widthValue.value) ) 
		{
			showMsg('Please enter a valid integer as width value.');
			setFocus(document.#formname#.#prefix#widthValue);
			return false;
		}
		if ( document.#formname#.#prefix#heightValue.value.length > 0 && !checkinteger(document.#formname#.#prefix#heightValue.value) ) {
			showMsg('Please enter a valid integer as height value.');
			setFocus(document.#formname#.#prefix#heightValue);
			return false;
		}
		
		for (var i=0; i < document.#formname#.#prefix#selectionType.length;i=i+1)
		{
			if (document.#formname#.#prefix#selectionType[i].checked)
				isSelected = 1;
		}
		
		if( isSelected == 0 )
		{
			showMsg('Please select a selection type.');
			return false;
		}		
		return true;
	}
	
	// Function to Convert AjaxProxy data to CF Query data object
	function #prefix#convertAjaxProxyObj2CFqueryObj(objData)
	{
		var results = {};
		results.COLUMNS = [];
		results.DATA = [];
		
		// Look for the 'columnlist' key
		if ( objData.hasOwnProperty('columnlist') )
		{ 	
			// Convert the 'columnlist' key to results.COLUMNS
			var colsArray = objData.columnlist.split(',');
			jQuery.each( colsArray,function( rowNum,rowValue ){
				var temp;
				if (colsArray.hasOwnProperty(rowValue)) 
				{
					temp = colsArray[rowValue].toUpperCase();
					delete colsArray[rowValue];
					colsArray[rowValue.charAt(0).toUpperCase() + rowValue.substring(1)] = temp;
				}
			});
			// Convert the colsArray to UPPERCASE
			var upperCasedArray = jQuery.map(colsArray, function(item, index) {
			    return item.toUpperCase();
			});
			// Set the res.COLUMNS value
			results.COLUMNS = upperCasedArray;
	   }
	   
	   // Look for the 'data' key
	   if ( objData.hasOwnProperty('data') )
	   {	
		   // Convert the 'data' key to results.DATA
		   var rowData = [];
		   var cellPos = 0;
		   jQuery.each( objData.data,function( colName,colValues ){
	           // console.log('colName: ' + colName);
			   // console.log('colValues: ' + colValues);
					
	            jQuery.each( colValues,function( rowPos,cellValue ){
						
	                //console.log('rowPos: ' + rowPos);
					//console.log('cellPos: ' + cellPos);
					//console.log('cellValue: ' + cellValue);
						
					if ( !rowData.hasOwnProperty(rowPos) ) 
					{ 
						rowData[rowPos] = [];
					}
					rowData[rowPos][cellPos] = cellValue; 
				});
	            cellPos++;
	        });
			results.DATA = rowData;
		}
				
		return results;
	}
	
	jQuery(document).ready(function()
	{
		jQuery("###prefix#customElement").change(childOptionFunction);
	});
	
	childOptionFunction = function(){
		
		var selectedChild = jQuery("option:selected",jQuery("###prefix#customElement")).val();
				
		jQuery("###prefix#parentField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#displayField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#valueField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		
		var regex = new RegExp("controlTypeID=[0-9]*", "g");
		jQuery('###prefix#filterBtn[onclick]').attr('onclick', function(i, v){
			return v.replace(regex, "controlTypeID=" + selectedChild);
		});
		
		if (selectedChild == "")
		{
			document.getElementById('childElementInputs').style.display = "none";
			return;
		}
		else
		{
			document.getElementById('childElementInputs').style.display = "";

			/* -- Updated to use AjaxProxy -- */
			jQuery.getJSON("#ajaxComURL#?bean=#ajaxBeanName#&method=getFields&query2array=0&returnformat=json",{"elementid":selectedChild})
			.done(function(retData) {
			
				// Convert the Data from the AjaxProxy to CF Object
				var res = #prefix#convertAjaxProxyObj2CFqueryObj(retData);
			
				if (res.COLUMNS[0] != 'ERRORMSG')
				{
					var allOptions = "";
					var nonHiddenFieldOptions = "";
					var columnMap = {};
					for (var i = 0; i < res.COLUMNS.length; i++) {
						columnMap[res.COLUMNS[i]] = i;
					}
					
					for(var i=0; i<res.DATA.length; i++) {
						//In our result, ID is what we will use for the value, and NAME for the label
						allOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
						
						if (res.DATA[i][columnMap.TYPE] != 'hidden')
							nonHiddenFieldOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
					}
					jQuery("###prefix#parentField").children().end().append(nonHiddenFieldOptions);
					jQuery("###prefix#displayField").children().end().append(allOptions);
					jQuery("###prefix#valueField").children().end().append(allOptions);
				}
				else
				{
					document.getElementById('errorMsgSpan').innerHTML = res.DATA[0];
				}
			})
			.fail(function() {
				document.getElementById('errorMsgSpan').innerHTML = '#errorMsgCustom#';
			});
		}
		#prefix#clearFilter();
		checkFrameSize();
	}
	
	function #prefix#clearFilter()
	{
		document.#formname#.#prefix#filterCriteria.value = "";
		document.getElementById('#prefix#clearBtn').style.display = "none";
		var onClickAttrVal = document.getElementById('#prefix#filterBtn').getAttribute("onclick");
		var onClickAppend = onClickAttrVal.substr(1, onClickAttrVal.length - 16);
		var onClickFunction = onClickAppend + "&hasFilter=0');";	
		document.getElementById('#prefix#filterBtn').setAttribute("onclick", onClickFunction);
	}
	
// -->
</script>

<table border="0" cellpadding="3" cellspacing="0" width="100%" summary="">
	<tr><td colspan="2"><span id="errorMsgSpan" class="cs_dlgError"></span></td></tr>
	<tr>
		<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Custom Element:</th>
		<td valign="baseline">
			<select id="#prefix#customElement" name="#prefix#customElement" size="1">
				<option value=""> - Select - </option>
				<cfloop query="allCustomElements">
					<option value="#allCustomElements.ID#" <cfif currentValues.customElement EQ allCustomElements.ID>selected</cfif>>#allCustomElements.Name#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tbody id="childElementInputs" <cfif NOT IsNumeric(currentValues.customElement)>style="display:none;"</cfif>>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Parent Field:</th>
			<td valign="baseline">
				<select name="#prefix#parentField" id="#prefix#parentField">
					<option value=""> - Select - </option>
					<cfloop query="nonHiddenFields">
						<option value="#nonHiddenFields.ID#" <cfif currentValues.parentField EQ nonHiddenFields.ID>selected</cfif>>#nonHiddenFields.Name#</option>
					</cfloop>
				</select>
				<br />
				<div class="cs_dlgLabelSmall">Select the field used to indicate the parent node.</div>
				</td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Display Field:</th>
			<td valign="baseline">
				<select name="#prefix#displayField" id="#prefix#displayField">
					<option value=""> - Select - </option>
					<cfloop query="selectedCEFields">
						<option value="#selectedCEFields.ID#" <cfif currentValues.displayField EQ selectedCEFields.ID>selected</cfif>>#selectedCEFields.Label#</option>
					</cfloop>
				</select>
				<br />
				<div class="cs_dlgLabelSmall">Select the field to display in the selection tree.</div>
			</td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Value Field:</th>
			<td valign="baseline">
				<select name="#prefix#valueField" id="#prefix#valueField">
					<option value=""> - Select - </option>
					<cfloop query="selectedCEFields">
						<option value="#selectedCEFields.ID#" <cfif currentValues.valueField EQ selectedCEFields.ID>selected</cfif>>#selectedCEFields.Label#</option>
					</cfloop>
				</select>
				<br />
				<div class="cs_dlgLabelSmall">Select the field whose value will be stored when the node is selected.</div>
			</td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Root Node Text:</th>
			<td valign="baseline">
				#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#rootNodeText", name="#prefix#rootNodeText", value="#currentValues.rootNodeText#", size="40", class="InputControl")#
				<div class="cs_dlgLabelSmall">Enter the text to be displayed as the 'root' node. If blank no 'root' node will be displayed.</div>
			</td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Root Value:</th>
			<td valign="baseline">
				#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#rootValue", name="#prefix#rootValue", value="#currentValues.rootValue#", size="25", class="InputControl")#
				<br><div class="cs_dlgLabelSmall">The 'parent' value identifying items off the root node (first-level items).</div>
			</td>
		</tr>		
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Width:</th>
			<td valign="baseline">
				#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#widthValue", name="#prefix#widthValue", value="#currentValues.widthValue#", size="5", class="InputControl")#
			</td>
		</tr>	
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Height:</th>
			<td valign="baseline">
				#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#heightValue", name="#prefix#heightValue", value="#currentValues.heightValue#", size="5", class="InputControl")#
			</td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Selection Type:</th>
			<td valign="baseline" nowrap="nowrap">
				#Server.CommonSpot.udf.tag.checkboxRadio(type="radio", name="#prefix#selectionType", value="single", label="Single", checked=(currentValues.selectionType EQ '' OR currentValues.selectionType EQ 'single'), labelClass="cs_dlgLabelSmall")#&nbsp;
				<br/>
				#Server.CommonSpot.udf.tag.checkboxRadio(type="radio", name="#prefix#selectionType", value="multiple", label="Multiple", checked=(currentValues.selectionType EQ 'multiple'), labelClass="cs_dlgLabelSmall")#&nbsp;
				<br/><!--- 'cascade up' --->
				#Server.CommonSpot.udf.tag.checkboxRadio(type="radio", name="#prefix#selectionType", value="multiAutoParents", label="Multiple (auto select parents)", checked=(currentValues.selectionType EQ 'multiAutoParents'), labelClass="cs_dlgLabelSmall")#&nbsp;
				<br/><!--- 'cascade down' --->
				#Server.CommonSpot.udf.tag.checkboxRadio(type="radio", name="#prefix#selectionType", value="multiAuto", label="Multiple (auto select children)", checked=(currentValues.selectionType EQ 'multiAuto'), labelClass="cs_dlgLabelSmall")#&nbsp;
			</td>
		</tr>
		<tr>
			<th valign="top" class="cs_dlgLabelBold" nowrap="nowrap">Filter Criteria:</th>
			<td valign="baseline">
			#Server.CommonSpot.UDF.tag.input(type="hidden", id="#prefix#filterCriteria", name="#prefix#filterCriteria", value=currentValues.filterCriteria, style="font-family:#Request.CP.Font#;font-size:10")#
			#Server.CommonSpot.UDF.tag.input(type="button", class="clsPushButton", id="#prefix#filterBtn", name="#prefix#filterBtn", value="Filter", onclick="javascript:top.commonspot.dialog.server.show('csmodule=controls/custom/select-data-filters&isAdminUI=1&editRights=1&adminRights=1&openFrom=fieldProps&controlTypeID=#currentValues.customElement#&persistentUniqueID=#persistentUniqueID#&prefixStr=#prefix#&hasFilter=1');")#
			<cfif Len(currentValues.filterCriteria)>
				#Server.CommonSpot.UDF.tag.input(type="button", class="clsPushButton", id="#prefix#clearBtn", name="#prefix#clearBtn", value="Clear", onclick="#prefix#clearFilter()")#
			<cfelse>
				#Server.CommonSpot.UDF.tag.input(type="button", class="clsPushButton", id="#prefix#clearBtn", name="#prefix#clearBtn", value="Clear", onclick="#prefix#clearFilter()", style="display:none;")#
			</cfif>
			<br />
			<div class="cs_dlgLabelSmall">Specify the filter to be applied while retrieving data.</div>
			</td>
		</tr>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Cookie Field:</th>
			<td valign="baseline">#Server.CommonSpot.UDF.tag.input(type="text", name="#prefix#cookieField", value=currentValues.cookieField, size="30", maxlength="255", style="font-family:#Request.CP.Font#;font-size:10")#
			<br />
			<div class="cs_dlgLabelSmall">Enter the name of the cookie field to use to populate this field. Leave empty to not use a cookie to populate.</div>
			</td>
		</tr>
		</CFOUTPUT>
		<CFSET caption="Enter the valid values from selected Values Field that you want selected by default.">
		<CFINCLUDE template="/commonspot/metadata/form_control/input_control/default_value.cfm">
		<CFOUTPUT>
	</tbody>
	<tr>
		<td class="cs_dlgLabelSmall" colspan="2" style="font-size:7pt;">
			<hr />
			ADF Custom Field v#fieldVersion#
		</td>
	</tr>
</table>
</cfoutput>
</cfif>