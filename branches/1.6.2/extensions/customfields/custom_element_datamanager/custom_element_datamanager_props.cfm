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
	Custom Element DataManager 
Name:
	custom_element_datamanager_props.cfm
Summary:
	This the props file for the Custom Element Data Manager field
ADF Requirements:
	scripts_1_2
History:
	2013-11-14 - DJM - Created
	2013-11-15 - GAC - Converted to an ADF custom field type
	2013-11-27 - DJM - Updated code to allow multiple dataManager fields on the same form
	2013-12-04 - GAC - Added CommonSpot Version check since this feild only runs on CommonSpot v9+
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2014-01-28 - GAC - Converted to use AjaxProxy.cfm instead of calling the base.cfc directly
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "1.0.2"; 
	
	// CS version and required Version variables
	requiredCSversion = 9;
	csVersion = ListFirst(ListLast(request.cp.productversion," "),".");
</cfscript>	

<!--- // Make sure we are on CommonSpot 9 or greater --->
<cfif csVersion LT requiredCSversion>
	<CFOUTPUT>
		<table border="0" cellpadding="3" cellspacing="0" width="100%" summary="">
			<tr><td class="cs_dlgLabelError">This Custom Field Type requires CommonSpot #requiredCSversion# or above.</td></tr>
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

	if( not structKeyExists(currentValues, "childCustomElement") )
		currentValues.childCustomElement = "";
	if( not structKeyExists(currentValues, "parentUniqueField") )
		currentValues.parentUniqueField = "";
	if( not structKeyExists(currentValues, "childUniqueField") )
		currentValues.childUniqueField = "";
	if( not structKeyExists(currentValues, "childLinkedField") )
		currentValues.childLinkedField = "";
	if( not structKeyExists(currentValues, "inactiveField") )
		currentValues.inactiveField = "";
	if( not structKeyExists(currentValues, "inactiveFieldValue") )
		currentValues.inactiveFieldValue = "";
	if( not structKeyExists(currentValues, "displayFields") )
		currentValues.displayFields = "";	
	if( not structKeyExists(currentValues, "widthValue") )
		currentValues.widthValue = "";
	if( not structKeyExists(currentValues, "widthUnit") )
		currentValues.widthUnit = "";
	if( not structKeyExists(currentValues, "heightValue") )
		currentValues.heightValue = "";
	if( not structKeyExists(currentValues, "heightUnit") )
		currentValues.heightUnit = "";
	if( not structKeyExists(currentValues, "sortByType") )
		currentValues.sortByType = "";
	if( not structKeyExists(currentValues, "sortByField") )
		currentValues.sortByField = "";
	if( not structKeyExists(currentValues, "sortByDir") )
		currentValues.sortByDir = "";
	if( not structKeyExists(currentValues, "positionField") )
		currentValues.positionField = "";
	if( not structKeyExists(currentValues, "refersParent") )
		currentValues.refersParent = 1;
	if( not structKeyExists(currentValues, "assocCustomElement") )
		currentValues.assocCustomElement = "";
	if( not structKeyExists(currentValues, "interfaceOptions") )
		currentValues.interfaceOptions = "new,editChild,delete";
	if( not structKeyExists(currentValues, "compOverride") )
		currentValues.compOverride = "";
	if( not structKeyExists(currentValues, "parentInstanceIDField") )
		currentValues.parentInstanceIDField = "";
	if( not structKeyExists(currentValues, "childInstanceIDField") )
		currentValues.childInstanceIDField = "";
		
	customElementObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
	allCustomElements = customElementObj.getList(type="All", state="Active");
	parentCustomElementDetails = customElementObj.getInfo(elementID=formID);
	selectedTypeFields = customElementObj.getFields(elementID=formID);
	errorMsgCustom = 'Some error occurred while trying to perform the operation.';	
</cfscript>

<cfquery name="globalCustomElements" dbtype="query">
	SELECT *
	  FROM allCustomElements
	 WHERE lower(Type) = <cfqueryparam value="global" cfsqltype="cf_sql_varchar">
</cfquery>

<cfquery name="selectedTypeFields" dbtype="query">
	SELECT ID, Label AS Name
	  FROM selectedTypeFields
	 WHERE <cfmodule template="/commonspot/utilities/handle-in-list.cfm" field="Type" list="formatted_text_block,taxonomy,date,calendar" cfsqltype="cf_sql_varchar" isNot=1>	
</cfquery>

<cfscript>
	application.ADF.scripts.loadJQuery(noConflict=true);
	application.ADF.scripts.loadJQueryUI();
</cfscript>

<cfoutput>
<style>
	###prefix#allFields, ###prefix#displayFieldsSelected { list-style-type: none; margin: 0; padding: 0; float: left; border:1px solid black; height:140px; width:100%; overflow: auto;}
	###prefix#allFields li, ###prefix#displayFieldsSelected li { margin: 5px; padding: 5px; font-size: 10px;}
	.ui-state-default
	{
		background: ##E6E6E6;
		border: 1px solid ##D3D3D3;
		color: ##555555;
		font-weight: normal;
	}
</style>
<script type="text/javascript">
<!--
	jQuery.noConflict();
	
	fieldProperties['#typeid#'].paramFields = "#prefix#childCustomElement,#prefix#parentUniqueField,#prefix#childUniqueField,#prefix#childLinkedField,#prefix#inactiveField,#prefix#inactiveFieldValue,#prefix#displayFields,#prefix#sortByType,#prefix#sortByField,#prefix#sortByDir,#prefix#positionField,#prefix#refersParent,#prefix#assocCustomElement,#prefix#interfaceOptions,#prefix#compOverride,#prefix#parentInstanceIDField,#prefix#childInstanceIDField,#prefix#widthValue,#prefix#widthUnit,#prefix#heightValue,#prefix#heightUnit";
	fieldProperties['#typeid#'].jsLabelUpdater = '#prefix#doLabel';
	fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
	
	function #prefix#doLabel(str)
	{
		document.#formname#.#prefix#label.value = str;
	}
	
	function #prefix#doValidate()
	{
		var selectedWidthUnitVal = '';
		if ( document.#formname#.#prefix#childCustomElementSelect.selectedIndex == 0 )
		{
			showMsg('Please select a custom element.');
			return false;
		}
		if ( document.#formname#.#prefix#parentUniqueField.selectedIndex <= 0 )
		{
			showMsg('Please select a unique field for the parent custom element.');
			return false;
		}
		if ( document.#formname#.#prefix#childUniqueField.selectedIndex <= 0 )
		{
			showMsg('Please select a unique field for the child custom element.');
			return false;
		}
		if ( document.#formname#.#prefix#displayFields.value.length == 0 )
		{
			showMsg('Please select a display field.');
			return false;
		}
		if ( document.#formname#.#prefix#widthValue.value.length > 0 && !checkinteger(document.#formname#.#prefix#widthValue.value) ) {
			showMsg('Please enter a valid integer width value for the data table.');
			setFocus(document.#formname#.#prefix#widthValue);
			return false;
		}
		if ( checkinteger(document.#formname#.#prefix#widthValue.value) && document.#formname#.#prefix#widthValue.value > 100) {
			selectedWidthUnitVal = document.#formname#.#prefix#widthUnit.options[document.#formname#.#prefix#widthUnit.selectedIndex].value;
			if (selectedWidthUnitVal == 'percent')
			{
				showMsg('Please enter a valid integer as width percent value.');
				setFocus(document.#formname#.#prefix#widthValue);
				return false;
			}
		}
		if ( document.#formname#.#prefix#heightValue.value.length > 0 && !checkinteger(document.#formname#.#prefix#heightValue.value) ) {
			showMsg('Please enter a valid integer height value for the data table.');
			setFocus(document.#formname#.#prefix#heightValue);
			return false;
		}
		if ( document.#formname#.#prefix#sortByType[0].checked == true && document.#formname#.#prefix#sortByField.selectedIndex <= 0)
		{
			showMsg('Please select a field to sort on.');
			return false;
		}
		if ( document.#formname#.#prefix#sortByType[1].checked == true && document.#formname#.#prefix#positionField.selectedIndex <= 0)
		{
			showMsg('Please select a position field.');
			return false;
		}
		if ( document.#formname#.#prefix#sortByType[1].checked == true && document.#formname#.#prefix#childUniqueField.options[document.#formname#.#prefix#childUniqueField.selectedIndex].value == document.#formname#.#prefix#positionField.options[document.#formname#.#prefix#positionField.selectedIndex].value)
		{
			showMsg('Position field cannot be same as child custom element unique field.');
			return false;
		}
		if ( document.#formname#.#prefix#refersParentCheckbox.checked == true )
		{
			if ( document.#formname#.#prefix#childLinkedField.selectedIndex <= 0 )
			{
				showMsg('Please select a unique field for the child custom element linked field.');
				return false;
			}
			
			if ( document.#formname#.#prefix#sortByType[1].checked == true && document.#formname#.#prefix#childLinkedField.options[document.#formname#.#prefix#childLinkedField.selectedIndex].value == document.#formname#.#prefix#positionField.options[document.#formname#.#prefix#positionField.selectedIndex].value)
			{
				showMsg('Position field cannot be same as child custom element linked field.');
				return false;
			}
		}
		else
		{		
			if ( document.#formname#.#prefix#assocCustomElement.selectedIndex <= 0 )
			{
				showMsg('Please select an association custom element.');
				return false;
			}
			if ( document.#formname#.#prefix#parentInstanceIDField.selectedIndex <= 0 )
			{
				showMsg('Please select a parent instanceID field.');
				return false;
			}
			if ( document.#formname#.#prefix#childInstanceIDField.selectedIndex <= 0 )
			{
				showMsg('Please select a child instanceID field.');
				return false;
			}
		}
		var interfaceOptionsList = '';
		for(var i=0; i<document.#formname#.#prefix#interfaceOptionsCbox.length; i++) {
			if(document.#formname#.#prefix#interfaceOptionsCbox[i].checked == true)
			{
				if(interfaceOptionsList.length > 0)
					interfaceOptionsList = interfaceOptionsList + ',' + document.#formname#.#prefix#interfaceOptionsCbox[i].value;
				else
					interfaceOptionsList = document.#formname#.#prefix#interfaceOptionsCbox[i].value;
			}
		}
		document.#formname#.#prefix#interfaceOptions.value = interfaceOptionsList;
		
		var compOverrideValue = trim(document.#formname#.#prefix#compOverride.value);
		document.#formname#.#prefix#compOverride.value = compOverrideValue;
		
		return true;
	}
	
	function #prefix#selectRadio(optionSel)
	{
		if(optionSel == 0)
		{
			document.#formname#.#prefix#sortByType[0].checked = true;
			document.getElementById('positionFieldSpan').style.display = "none";
			document.#formname#.#prefix#positionField.selectedIndex = 0;
		}
		else
		{
			document.#formname#.#prefix#sortByType[1].checked = true;
			document.getElementById('positionFieldSpan').style.display = "";
			document.#formname#.#prefix#sortByField.selectedIndex = 0;
			document.#formname#.#prefix#sortByDir.selectedIndex = 0;
		}
	}
	
	function #prefix#showInactiveValueFld()
	{
		var selectedIndex = document.#formname#.#prefix#inactiveField.selectedIndex;
		
		if (selectedIndex > 0)
		{
			document.getElementById('inactiveValueSpan').style.display = "";
		}
		else
		{
			document.getElementById('inactiveValueSpan').style.display = "none";
			document.#formname#.#prefix#inactiveFieldValue.value = "";
		}
	}
	
	function #prefix#toggleAssocFld()
	{
		if (document.#formname#.#prefix#refersParentCheckbox.checked == true)
		{
			document.#formname#.#prefix#refersParent.value = 1;
			
			document.getElementById('assocCETr').style.display = "none";
			document.getElementById('assocElementInputs').style.display = "none";						
			document.#formname#.#prefix#assocCustomElement.selectedIndex = 0;
			
			document.getElementById('childLinkedFldSpan').style.display = "";
			document.getElementById('inactiveFieldTr').style.display = "";
			document.#formname#.#prefix#interfaceOptionsCbox[1].checked = false;
			document.getElementById('existingOption').style.display = "none";
			document.#formname#.#prefix#interfaceOptionsCbox[2].checked = false;
			document.getElementById('editAssocOption').style.display = "none";
			assocOptionFunction();
		}
		else
		{
			document.#formname#.#prefix#refersParent.value = 0;
			
			document.getElementById('assocCETr').style.display = "";
			
			document.getElementById('childLinkedFldSpan').style.display = "none";
			document.#formname#.#prefix#childLinkedField.selectedIndex = 0;
			document.getElementById('inactiveFieldTr').style.display = "none";
			document.getElementById('existingOption').style.display = "";
			document.getElementById('editAssocOption').style.display = "";
			
			assocOptionFunction();
		}
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
		onLoadFunction();
		jQuery("###prefix#childCustomElementSelect").change(childOptionFunction);		
		jQuery("###prefix#assocCustomElement").change(assocOptionFunction);
		
		jQuery( "###prefix#allFields, ###prefix#displayFieldsSelected" ).sortable({
			connectWith: ".connectedSortable",
		}).disableSelection();
		
		jQuery( "###prefix#displayFieldsSelected" ).on( "sortover", function(e, ui) {				
			var currentVal = "";
			
			jQuery("###prefix#displayFieldsSelected > li").each(function(i, item){
				var listItemValue = item.value;
				if(i > 0)
					currentVal = currentVal + ',' + listItemValue;
				else
					currentVal = listItemValue;
			});
			document.#formname#.#prefix#displayFields.value = currentVal;
		});
			
		jQuery( "###prefix#allFields, ###prefix#displayFieldsSelected" ).on( "sortstop", function( e, ui ) {
			var currentVal = "";
			jQuery("###prefix#displayFieldsSelected > li").each(function(i, item){
				var listItemValue = item.value;
				if(i > 0)
					currentVal = currentVal + ',' + listItemValue;
				else
					currentVal = listItemValue;
			});
			document.#formname#.#prefix#displayFields.value = currentVal;
		});
	});
	
	onLoadFunction = function(){
		var selectedChildWithType = jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).val();
		var selectedChildWithTypeArray = selectedChildWithType.split('||');
		var selectedChild = selectedChildWithTypeArray[0];
		if (selectedChildWithTypeArray.length == 2)
			selectedChild = selectedChildWithTypeArray[1];
		var selectedAssoc = jQuery("option:selected",jQuery("###prefix#assocCustomElement")).val();
		document.#formname#.#prefix#childCustomElement.value = selectedChild;
		
		displayDeleteBtnText();

		// Processing of fields related to association elements
		jQuery("###prefix#parentInstanceIDField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#childInstanceIDField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		
		// If child is not selected then just return
		if (selectedChild == "")
		{
			document.getElementById("addNewOpt").innerHTML = "Allow 'Add New'";
			return;
		}
		else
		{
			document.getElementById("addNewOpt").innerHTML = "Allow 'Add New " + jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).text() + "'";
			document.getElementById("editChildOpt").innerHTML = "Allow 'Edit' of " + jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).text();
			var selectedDisplayFieldIDs = "#currentValues.displayFields#";
			var selectedDisplayFieldIDArray = selectedDisplayFieldIDs.split(',');
			var replaceArrayForSelected = selectedDisplayFieldIDs.split(',');
			
			jQuery("###prefix#allFields").children().remove().end();
			jQuery("###prefix#displayFieldsSelected").children().remove().end();
			jQuery("###prefix#sortByField").children().remove().end().append("<option value=\"\"> - Select -</option>");
			
			jQuery("###prefix#positionField").children().remove().end().append("<option value=\"\"> - Select -</option>");
			
			jQuery("###prefix#childUniqueField").children().remove().end().append("<option value=\"\"> - Select -</option>");
			jQuery("###prefix#childLinkedField").children().remove().end().append("<option value=\"\"> - Select -</option>");
			jQuery("###prefix#inactiveField").children().remove().end().append("<option value=\"\"> - Select -</option>");
			
			jQuery.getJSON("#ajaxComURL#?bean=#ajaxBeanName#&method=getFields&query2array=0&returnformat=json",{"elementid":selectedChild})
			.done(function(retData) {
				
				// Convert the Data from the AjaxProxy to CF Object
				var res = #prefix#convertAjaxProxyObj2CFqueryObj(retData);
			
				if (res.COLUMNS[0] != 'ERRORMSG')
				{
					var newOptions = "";
					var selectedTypeExcludedOptions = "";
					var selectedTypeIncludedOptions = "";
					var avaiableDisplayFields = "";
					var selectedDisplayFieldsFromChild = "";
					var columnMap = {};
					for (var i = 0; i < res.COLUMNS.length; i++) {
						columnMap[res.COLUMNS[i]] = i;
					}
					
					for(var i=0; i<res.DATA.length; i++) {
						//In our result, ID is what we will use for the value, and NAME for the label
						newOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</option>";
						
						if (res.DATA[i][columnMap.TYPE] != 'formatted_text_block' && res.DATA[i][columnMap.TYPE] != 'taxonomy' && res.DATA[i][columnMap.TYPE] != 'date' && res.DATA[i][columnMap.TYPE] != 'calendar')
							selectedTypeExcludedOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
						
						if (res.DATA[i][columnMap.TYPE] == 'hidden' || res.DATA[i][columnMap.TYPE] == 'integer' || res.DATA[i][columnMap.TYPE] == 'custom')
							selectedTypeIncludedOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
						
						if (selectedDisplayFieldIDArray.indexOf(res.DATA[i][columnMap.ID].toString()) == -1)
							avaiableDisplayFields += "<li value=\"" + res.DATA[i][columnMap.ID] + "\" class=\"ui-state-default\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</li>";
						else
						{
							selectedDisplayFieldsFromChild += "<li value=\"" + res.DATA[i][columnMap.ID] + "\" class=\"ui-state-default\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</li>";
							replaceArrayForSelected[selectedDisplayFieldIDArray.indexOf(res.DATA[i][columnMap.ID].toString())] = "<li value=\"" + res.DATA[i][columnMap.ID] + "\" class=\"ui-state-default\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</li>";
						}
					}					
					jQuery("###prefix#allFields").children().end().append(avaiableDisplayFields);
					if (selectedAssoc == "")
						jQuery("###prefix#displayFieldsSelected").children().end().append(selectedDisplayFieldsFromChild);
					
					jQuery("###prefix#sortByField").children().end().append(newOptions);
					if ('#currentValues.sortByType#' == 'auto')
						jQuery("###prefix#sortByField").val(#currentValues.sortByField#);
						
					jQuery("###prefix#childUniqueField").children().end().append(selectedTypeExcludedOptions);
					jQuery("###prefix#childUniqueField").val(#currentValues.childUniqueField#);
					
					if (document.#formname#.#prefix#refersParentCheckbox.checked == true)
					{
						jQuery("###prefix#childLinkedField").children().end().append(selectedTypeExcludedOptions);
						jQuery("###prefix#childLinkedField").val(#currentValues.childLinkedField#);
						
						jQuery("###prefix#inactiveField").children().end().append(selectedTypeExcludedOptions);
						jQuery("###prefix#inactiveField").val(#currentValues.inactiveField#);
						
						jQuery("###prefix#positionField").children().end().append(selectedTypeIncludedOptions);
						if ('#currentValues.sortByType#' == 'manual')
							jQuery("###prefix#positionField").val(#currentValues.positionField#);
					}
					
					if (selectedAssoc == "")
					{
						document.getElementById('assocElementInputs').style.display = "none";
						document.getElementById('existingOption').style.display = "none";
						document.getElementById('editAssocOption').style.display = "none";
						return;
					}
					else
					{
						document.getElementById('existingOption').style.display = "";
						document.getElementById('editAssocOption').style.display = "";
						document.getElementById("addExistingOpt").innerHTML = "Allow 'Add New " + jQuery("option:selected",jQuery("###prefix#assocCustomElement")).text() + "'";
						document.getElementById("editAssocOpt").innerHTML = "Allow 'Edit' of " + jQuery("option:selected",jQuery("###prefix#assocCustomElement")).text();
						document.getElementById('assocElementInputs').style.display = "";
						document.getElementById('assocCENameSpan').innerHTML = jQuery("option:selected",jQuery("###prefix#assocCustomElement")).text();
						
						// jQuery call to populate the Parent FormID, Parent Instance ID, Child Form ID, Child Instance ID and Sort By Fields
						jQuery.getJSON("#ajaxComURL#?bean=#ajaxBeanName#&method=getFields&query2array=0&returnformat=json",{"elementid":selectedAssoc}) 
						.done(function(retData) {
						
						    // Convert the Data from the AjaxProxy to CF Object
							var res = #prefix#convertAjaxProxyObj2CFqueryObj(retData);
						
							if (res.COLUMNS[0] != 'ERRORMSG')
							{
								var newOptions = "";
								var newSortByOptions = "";
								var selectedTypeExcludedOptions = "";
								var selectedTypeIncludedOptions = "";
								var avaiableDisplayFields = "";
								var columnMap = {};
								for (var i = 0; i < res.COLUMNS.length; i++) {
									columnMap[res.COLUMNS[i]] = i;
								}
								
								for(var i=0; i<res.DATA.length; i++) {
									//In our result, ID is what we will use for the value, and NAME for the label
									newOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
									newSortByOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</option>";
									
									if (res.DATA[i][columnMap.TYPE] != 'formatted_text_block' && res.DATA[i][columnMap.TYPE] != 'taxonomy' && res.DATA[i][columnMap.TYPE] != 'date' && res.DATA[i][columnMap.TYPE] != 'calendar')
										selectedTypeExcludedOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
									
									if (res.DATA[i][columnMap.TYPE] == 'hidden' || res.DATA[i][columnMap.TYPE] == 'integer' || res.DATA[i][columnMap.TYPE] == 'custom')
										selectedTypeIncludedOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
									
									if (selectedDisplayFieldIDArray.indexOf(res.DATA[i][columnMap.ID].toString()) == -1)
										avaiableDisplayFields += "<li value=\"" + res.DATA[i][columnMap.ID] + "\" class=\"ui-state-default\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</li>";
									else
									{
										replaceArrayForSelected[selectedDisplayFieldIDArray.indexOf(res.DATA[i][columnMap.ID].toString())] = "<li value=\"" + res.DATA[i][columnMap.ID] + "\" class=\"ui-state-default\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</li>";
									}
								}
								jQuery("###prefix#parentInstanceIDField").children().end().append(newOptions);
								jQuery("###prefix#childInstanceIDField").children().end().append(newOptions);
								jQuery("###prefix#parentInstanceIDField").val(#currentValues.parentInstanceIDField#);
								jQuery("###prefix#childInstanceIDField").val(#currentValues.childInstanceIDField#);
								
								// association element is selected then append the assoc element fields to the end of the sort by field
								jQuery("###prefix#sortByField").children().end().append(newSortByOptions);
								if ('#currentValues.sortByType#' == 'auto')
									jQuery("###prefix#sortByField").val(#currentValues.sortByField#);
								
								jQuery("###prefix#allFields").children().end().append(avaiableDisplayFields);
								
								jQuery("###prefix#inactiveField").children().end().append(selectedTypeExcludedOptions);
								jQuery("###prefix#inactiveField").val(#currentValues.inactiveField#);
								
								jQuery("###prefix#positionField").children().end().append(selectedTypeIncludedOptions);
								if ('#currentValues.sortByType#' == 'manual')
									jQuery("###prefix#positionField").val(#currentValues.positionField#);
							}
							else
							{
								document.getElementById('errorMsgSpan').innerHTML = res.DATA[0];
							}
							jQuery("###prefix#displayFieldsSelected").children().end().append(replaceArrayForSelected.join(''));
						})
						.fail(function() {
							document.getElementById('errorMsgSpan').innerHTML = '#errorMsgCustom#';
						});
					}
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
	}
	
	assocOptionFunction = function(){
		
		var selectedAssoc = jQuery("option:selected",jQuery("###prefix#assocCustomElement")).val();
		var selectedChildWithType = jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).val();
		var selectedChildWithTypeArray = selectedChildWithType.split('||');
		var selectedChild = selectedChildWithTypeArray[0];
		if (selectedChildWithTypeArray.length == 2)
			selectedChild = selectedChildWithTypeArray[1];
			
		displayDeleteBtnText();
		
		document.#formname#.#prefix#childCustomElement.value = selectedChild;
		
		var sortByFieldSelectedValue = '';
		if(document.#formname#.#prefix#sortByField.selectedIndex > 0)
			sortByFieldSelectedValue = document.#formname#.#prefix#sortByField.options[document.#formname#.#prefix#sortByField.selectedIndex].value;
		
		document.getElementById('assocCENameSpan').innerHTML = "";
		document.#formname#.#prefix#childLinkedField.selectedIndex = 0;		
		document.#formname#.#prefix#parentInstanceIDField.selectedIndex = 0;
		document.#formname#.#prefix#childInstanceIDField.selectedIndex = 0;
		document.#formname#.#prefix#inactiveField.selectedIndex = 0;
		document.#formname#.#prefix#positionField.selectedIndex = 0;
		#prefix#showInactiveValueFld();
		
		jQuery("###prefix#parentInstanceIDField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#childInstanceIDField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#inactiveField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#positionField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#childLinkedField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		
		if (selectedChild != "")
		{
			jQuery.getJSON("#ajaxComURL#?bean=#ajaxBeanName#&method=getFieldIDList&returnformat=json",{"elementid":selectedChild})
			.done(function(retData) {
			
				// trim the retData
				var res = jQuery.trim(retData);
			
				if (res != 'ERROR')
				{
					var IDListArray = res.split(',');
			
					jQuery("###prefix#allFields > li").each(function(i, item){
						var listItemValue = item.value;
						if (IDListArray.indexOf(listItemValue.toString()) == -1)
							jQuery(item).remove();
					});
					
					jQuery("###prefix#displayFieldsSelected > li").each(function(i, item){
						var listItemValue = item.value;
						if (IDListArray.indexOf(listItemValue.toString()) == -1)
						{
							jQuery(item).remove();
							
							var currentValArray = document.#formname#.#prefix#displayFields.value.split(',');
							var currentVal = '';
							
							if(currentValArray.indexOf(listItemValue.toString()) != -1)
							{
								currentValArray.splice(currentValArray.indexOf(listItemValue.toString()),1);
							}
							currentVal = currentValArray.join();
							document.#formname#.#prefix#displayFields.value = currentVal;
						}
					});
					
					jQuery("###prefix#sortByField > option").each(function(i, item){
						var listItemValue = item.value;
						if (IDListArray.indexOf(listItemValue.toString()) == -1 && i != 0)
						{
							jQuery(item).remove();
							if (sortByFieldSelectedValue != "" && listItemValue == sortByFieldSelectedValue)
								document.#formname#.#prefix#sortByField.selectedIndex = 0;
						}
					});
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
		else
		{
			jQuery("###prefix#allFields").children().remove().end();
			
			jQuery("###prefix#displayFieldsSelected").children().remove().end();
				
			jQuery("###prefix#sortByField").children().remove().end().append("<option value=\"\"> - Select -</option>");;
			
			document.#formname#.#prefix#displayFields.value = "";
		}
		
		if (selectedAssoc == "")
		{
			document.getElementById('existingOption').style.display = "none";
			document.getElementById('editAssocOption').style.display = "none";
			document.getElementById('assocElementInputs').style.display = "none";
			
			if (selectedChild != "")
			{
				if(document.#formname#.#prefix#refersParentCheckbox.checked == true)
				{
					jQuery.getJSON("#ajaxComURL#?bean=#ajaxBeanName#&method=getFields&query2array=0&returnformat=json",{"elementid":selectedChild})
					.done(function(retData) {
					
					 // Convert the Data from the AjaxProxy to CF Object
					 var res = #prefix#convertAjaxProxyObj2CFqueryObj(retData);
					
						if (res.COLUMNS[0] != 'ERRORMSG')
						{
							var newOptions = "";
							var selectedTypeIncludedOptions = "";
							var selectedTypeExcludedOptions = "";
							var columnMap = {};
							for (var i = 0; i < res.COLUMNS.length; i++) {
								columnMap[res.COLUMNS[i]] = i;
							}
							
							for(var i=0; i<res.DATA.length; i++) {
								//In our result, ID is what we will use for the value, and NAME for the label
								newOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
								
								if (res.DATA[i][columnMap.TYPE] != 'formatted_text_block' && res.DATA[i][columnMap.TYPE] != 'taxonomy' && res.DATA[i][columnMap.TYPE] != 'date' && res.DATA[i][columnMap.TYPE] != 'calendar')
									selectedTypeExcludedOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
								
								if (res.DATA[i][columnMap.TYPE] == 'hidden' || res.DATA[i][columnMap.TYPE] == 'integer' || res.DATA[i][columnMap.TYPE] == 'custom')
									selectedTypeIncludedOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
							}
							
							jQuery("###prefix#positionField").children().end().append(selectedTypeIncludedOptions);
							jQuery("###prefix#inactiveField").children().end().append(newOptions);
							jQuery("###prefix#childLinkedField").children().end().append(selectedTypeExcludedOptions);
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
				else
					document.getElementById('inactiveFieldTr').style.display = "none";
			}
			
			return;
		}
		else
		{
			document.getElementById('existingOption').style.display = "";
			document.getElementById('editAssocOption').style.display = "";
			document.getElementById("addExistingOpt").innerHTML = "Allow 'Add New " + jQuery("option:selected",jQuery("###prefix#assocCustomElement")).text() + "'";
			document.getElementById("editAssocOpt").innerHTML = "Allow 'Edit' of " + jQuery("option:selected",jQuery("###prefix#assocCustomElement")).text();
			document.getElementById('assocElementInputs').style.display = "";
			document.getElementById('inactiveFieldTr').style.display = "";
			document.getElementById('assocCENameSpan').innerHTML = jQuery("option:selected",jQuery("###prefix#assocCustomElement")).text();

			jQuery.getJSON("#ajaxComURL#?bean=#ajaxBeanName#&method=getFields&query2array=0&returnformat=json",{"elementid":selectedAssoc}) 
			.done(function(retData) {
			
			     // Convert the Data from the AjaxProxy to CF Object
				 var res = #prefix#convertAjaxProxyObj2CFqueryObj(retData);
			
				if (res.COLUMNS[0] != 'ERRORMSG')
				{
					var newOptions = "";
					var newListOptions = "";
					var newSortByOptions = "";
					var selectedTypeIncludedOptions = "";
					var columnMap = {};
					for (var i = 0; i < res.COLUMNS.length; i++) {
						columnMap[res.COLUMNS[i]] = i;
					}
					
					for(var i=0; i<res.DATA.length; i++) {
						//In our result, ID is what we will use for the value, and NAME for the label
						newOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
						newSortByOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</option>";
						newListOptions += "<li value=\"" + res.DATA[i][columnMap.ID] + "\" class=\"ui-state-default\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</li>";
						if (res.DATA[i][columnMap.TYPE] == 'hidden' || res.DATA[i][columnMap.TYPE] == 'integer' || res.DATA[i][columnMap.TYPE] == 'custom')
							selectedTypeIncludedOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
					}
					jQuery("###prefix#parentInstanceIDField").children().end().append(newOptions);
					jQuery("###prefix#childInstanceIDField").children().end().append(newOptions);
					jQuery("###prefix#allFields").children().end().append(newListOptions);
					jQuery("###prefix#sortByField").children().end().append(newSortByOptions);
					jQuery("###prefix#positionField").children().end().append(selectedTypeIncludedOptions);
					jQuery("###prefix#inactiveField").children().end().append(newOptions);
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
		checkFrameSize();
	}
	
	childOptionFunction = function(){
		
		var selectedChildWithType = jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).val();
		var selectedChildWithTypeArray = selectedChildWithType.split('||');
		var selectedChild = selectedChildWithTypeArray[0];
		var selectedType = '';
		if (selectedChildWithTypeArray.length == 2)
		{
			selectedChild = selectedChildWithTypeArray[1];
			selectedType = selectedChildWithTypeArray[0];
		}
		
		displayDeleteBtnText();
		
		document.#formname#.#prefix#childCustomElement.value = selectedChild;
		
		var selectedAssoc = jQuery("option:selected",jQuery("###prefix#assocCustomElement")).val();
		var sortByFieldSelectedValue = '';
		if(document.#formname#.#prefix#sortByField.selectedIndex > 0)
			sortByFieldSelectedValue = document.#formname#.#prefix#sortByField.options[document.#formname#.#prefix#sortByField.selectedIndex].value;
		document.getElementById('childCENameSpan').innerHTML = "";
		document.getElementById('assocChildCENameSpan').innerHTML = "";
		document.#formname#.#prefix#childUniqueField.selectedIndex = 0;
		document.#formname#.#prefix#childLinkedField.selectedIndex = 0;
		
		if (document.#formname#.#prefix#refersParentCheckbox.checked == true)
		{
			document.#formname#.#prefix#positionField.selectedIndex = 0;
			document.#formname#.#prefix#inactiveField.selectedIndex = 0;
			document.#formname#.#prefix#displayFields.value = "";
			document.#formname#.#prefix#sortByField.selectedIndex = 0;
			jQuery("###prefix#positionField").children().remove().end().append("<option value=\"\"> - Select -</option>");
			jQuery("###prefix#inactiveField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		}
		
		jQuery("###prefix#childUniqueField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#childLinkedField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		
		if (selectedAssoc != "")
		{
			jQuery.getJSON("#ajaxComURL#?bean=#ajaxBeanName#&method=getFieldIDList&returnformat=json",{"elementid":selectedAssoc})
			.done(function(retData) {
				
				// trim the retData
				var res = jQuery.trim(retData);
			
				if (res != 'ERROR')
				{
					var IDListArray = res.split(',');
			
					jQuery("###prefix#allFields > li").each(function(i, item){
						var listItemValue = item.value;
						if (IDListArray.indexOf(listItemValue.toString()) == -1)
							jQuery(item).remove();
					});
					
					jQuery("###prefix#displayFieldsSelected > li").each(function(i, item){
						var listItemValue = item.value;
						if (IDListArray.indexOf(listItemValue.toString()) == -1)
						{
							jQuery(item).remove();
							
							var currentValArray = document.#formname#.#prefix#displayFields.value.split(',');
							var currentVal = '';
							
							if(currentValArray.indexOf(listItemValue.toString()) != -1)
							{
								currentValArray.splice(currentValArray.indexOf(listItemValue.toString()),1);
							}
							currentVal = currentValArray.join();
							document.#formname#.#prefix#displayFields.value = currentVal;
						}
					});					
					
					jQuery("###prefix#sortByField > option").each(function(i, item){
						var listItemValue = item.value;
						if (IDListArray.indexOf(listItemValue.toString()) == -1 && i != 0)
						{
							jQuery(item).remove();
							if (sortByFieldSelectedValue != "" && listItemValue == sortByFieldSelectedValue)
								document.#formname#.#prefix#sortByField.selectedIndex = 0;
						}
					});
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
		else
		{
			jQuery("###prefix#allFields").children().remove().end();
			
			jQuery("###prefix#displayFieldsSelected").children().remove().end();
			
			jQuery("###prefix#sortByField").children().remove().end().append("<option value=\"\"> - Select -</option>");
			
			document.#formname#.#prefix#displayFields.value = "";
		}
		
		if (selectedChild == "")
		{
			document.getElementById("addNewOpt").innerHTML = "Allow 'Add New'";
			document.getElementById('childElementInputs').style.display = "none";
			document.getElementById('inactiveFieldTr').style.display = "none";
			document.getElementById('assocElementInputs').style.display = "none";
			document.#formname#.#prefix#assocCustomElement.selectedIndex = 0;
			assocOptionFunction();
			return;
		}
		else
		{
			document.getElementById("addNewOpt").innerHTML = "Allow 'Add New " + jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).text() + "'";
			document.getElementById("editChildOpt").innerHTML = "Allow 'Edit' of " + jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).text();
			document.getElementById('childElementInputs').style.display = "";
			if (selectedType == 'local')
			{
				document.#formname#.#prefix#refersParentCheckbox.checked = false;
				document.#formname#.#prefix#refersParent.value = 0;

				// special cases if selected Child is same as current element
				if( selectedChild == #attributes.formID# )
					document.getElementById('refersParentTr').style.display = "";
				else	
					document.getElementById('refersParentTr').style.display = "none";
					
				document.getElementById('assocCETr').style.display = "";
	
				document.getElementById('childLinkedFldSpan').style.display = "none";
				document.#formname#.#prefix#childLinkedField.selectedIndex = 0;
				document.getElementById('inactiveFieldTr').style.display = "none";
				document.#formname#.#prefix#refersParent.value = 0;
				document.#formname#.#prefix#interfaceOptionsCbox[0].checked = false;
				document.getElementById('newOption').style.display = "none";
				document.#formname#.#prefix#interfaceOptionsCbox[3].checked = false;
				document.getElementById('editChildOption').style.display = "none";
				
				if (selectedAssoc != "")
				{
					document.getElementById('existingOption').style.display = "";
					document.getElementById('editAssocOption').style.display = "";
				}
				else
				{
					document.getElementById('existingOption').style.display = "none";
					document.getElementById('editAssocOption').style.display = "none";
				}
			}
			else
			{
				document.getElementById('refersParentTr').style.display = "";
				document.getElementById('newOption').style.display = "";
				document.getElementById('editChildOption').style.display = "";
			}
			
			if (selectedAssoc != "")
				document.getElementById('assocElementInputs').style.display = "";
				
			if (document.#formname#.#prefix#refersParentCheckbox.checked == true || selectedAssoc != "")
				document.getElementById('inactiveFieldTr').style.display = "";
			
			var childCustomElementName = jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).text();
			document.getElementById('childCENameSpan').innerHTML = childCustomElementName;
			document.getElementById('assocChildCENameSpan').innerHTML = childCustomElementName;
			
			jQuery("###prefix#assocCustomElement").children().remove().end().append("<option value=\"\"> - Select -</option>");

/* -- Updated to use AjaxProxy -- */			
/* 	jQuery.getJSON("#ajaxComURL#/custom_element_datamanager_base.cfc?method=getGlobalCE&returnformat=json") */
			
			jQuery.getJSON("#ajaxComURL#?bean=#ajaxBeanName#&method=getGlobalCE&query2array=0&returnformat=json")
			.done(function(retData) {
			
				// Convert the Data from the AjaxProxy to CF Object
				var res = #prefix#convertAjaxProxyObj2CFqueryObj(retData);
			
				if (res.COLUMNS[0] != 'ERRORMSG')
				{
					var newOptions = "";
					var columnMap = {};
					for (var i = 0; i < res.COLUMNS.length; i++) {
						columnMap[res.COLUMNS[i]] = i;
					}
					
					for(var i=0; i<res.DATA.length; i++) {
						if (selectedChild != res.DATA[i][columnMap.ID])
							newOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
					}
					
					jQuery("###prefix#assocCustomElement").children().end().append(newOptions);
					jQuery("###prefix#assocCustomElement").val(selectedAssoc);
				}
				else
				{
					document.getElementById('errorMsgSpan').innerHTML = res.DATA[0];
				}
			})
			.fail(function() {
				document.getElementById('errorMsgSpan').innerHTML = '#errorMsgCustom#';
			});

/* -- Updated to use AjaxProxy -- */			
/* jQuery.getJSON("#ajaxComURL#/custom_element_datamanager_base.cfc?method=getFields&returnformat=json",{"elementid":selectedChild}) */
			
			jQuery.getJSON("#ajaxComURL#?bean=#ajaxBeanName#&method=getFields&query2array=0&returnformat=json",{"elementid":selectedChild})
			.done(function(retData) {
			
				// Convert the Data from the AjaxProxy to CF Object
				var res = #prefix#convertAjaxProxyObj2CFqueryObj(retData);
			
				if (res.COLUMNS[0] != 'ERRORMSG')
				{
					var newOptions = "";
					var newListOptions = "";
					var selectedTypeExcludedOptions = "";
					var selectedTypeIncludedOptions = "";
					var columnMap = {};
					for (var i = 0; i < res.COLUMNS.length; i++) {
						columnMap[res.COLUMNS[i]] = i;
					}
					
					for(var i=0; i<res.DATA.length; i++) {
						//In our result, ID is what we will use for the value, and NAME for the label
						newOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</option>";
						newListOptions += "<li value=\"" + res.DATA[i][columnMap.ID] + "\" class=\"ui-state-default\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</li>";
						
						if (res.DATA[i][columnMap.TYPE] != 'formatted_text_block' && res.DATA[i][columnMap.TYPE] != 'taxonomy' && res.DATA[i][columnMap.TYPE] != 'date' && res.DATA[i][columnMap.TYPE] != 'calendar')
							selectedTypeExcludedOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
						
						if (document.#formname#.#prefix#refersParentCheckbox.checked == true)
						{
							if (res.DATA[i][columnMap.TYPE] == 'hidden' || res.DATA[i][columnMap.TYPE] == 'integer' || res.DATA[i][columnMap.TYPE] == 'custom')
								selectedTypeIncludedOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
						}
					}
					
					jQuery("###prefix#sortByField").children().end().append(newOptions);
					
					jQuery("###prefix#allFields").children().end().append(newListOptions);
					jQuery("###prefix#childUniqueField").children().end().append(selectedTypeExcludedOptions);
					jQuery("###prefix#childLinkedField").children().end().append(selectedTypeExcludedOptions);
					
					if (document.#formname#.#prefix#refersParentCheckbox.checked == true)
					{
						jQuery("###prefix#positionField").children().end().append(selectedTypeIncludedOptions);
						jQuery("###prefix#inactiveField").children().end().append(selectedTypeExcludedOptions);
					}
				}
				else
				{
					document.getElementById('errorMsgSpan').innerHTML = res.DATA[0];
				}
			})
			.fail(function() {
				document.getElementById('errorMsgSpan').innerHTML = '#errorMsgCustom#';
			});
		
			#prefix#showInactiveValueFld();
		}
		
		checkFrameSize();
	}
	
	displayDeleteBtnText = function(){
		var selectedChildWithType = jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).val();
		var selectedChildWithTypeArray = selectedChildWithType.split('||');
		var selectedChild = selectedChildWithTypeArray[0];
		if (selectedChildWithTypeArray.length == 2)
			selectedChild = selectedChildWithTypeArray[1];
		var selectedAssoc = jQuery("option:selected",jQuery("###prefix#assocCustomElement")).val();
		
		if (selectedChild == "" && selectedAssoc == "")
		{
			document.getElementById("deleteOpt").innerHTML = "Allow 'Delete'";
		}
		else if (selectedAssoc == "")
		{
			document.getElementById("deleteOpt").innerHTML = "Allow 'Delete' of " + jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).text();
		}
		else
		{
			document.getElementById("deleteOpt").innerHTML = "Allow 'Delete' of " + jQuery("option:selected",jQuery("###prefix#assocCustomElement")).text();
		}
	}
// -->
</script>
</cfoutput>

<cfset selectedCEName = ''>
<cfset selectedCEType = ''>
<cfset selectedAssocCEName = ''>

<cfoutput>
<table border="0" cellpadding="3" cellspacing="0" width="100%" summary="">
	<tr><td colspan="2"><span id="errorMsgSpan" class="cs_dlgError"></span></td></tr>
	<tr>
		<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Child Custom Element:</th>
		<td valign="baseline">
			<select id="#prefix#childCustomElementSelect" name="#prefix#childCustomElementSelect" size="1">
				<option value=""> - Select - </option>
				<cfloop query="allCustomElements">
					<!---<cfif allCustomElements.ID NEQ attributes.FormID>--->
						<option value="#LCase(allCustomElements.Type)#||#allCustomElements.ID#" <cfif currentValues.childCustomElement EQ allCustomElements.ID>selected</cfif>>#allCustomElements.Name#</option>
					<!---</cfif>--->
					<cfif currentValues.childCustomElement EQ allCustomElements.ID>
						<cfset selectedCEName = allCustomElements.Name>
						<cfset selectedCEType = allCustomElements.Type>
					</cfif>
				</cfloop>
			</select>
		</td>
	</tr>
	<tbody id="childElementInputs" <cfif NOT IsNumeric(currentValues.childCustomElement)>style="display:none;"</cfif>>
		<tr id="refersParentTr" <cfif selectedCEType EQ 'local' AND currentValues.childCustomElement NEQ attributes.formID>style="display:none;"</cfif>>
			<td valign="baseline" align="right">&nbsp;</td>
			<td valign="baseline" align="left">
				#Server.CommonSpot.udf.tag.checkboxRadio(type="checkbox", name="#prefix#refersParentCheckbox", value="1", label="The child element contains the reference to the parent instance", checked=(currentValues.refersParent EQ 1), labelClass="cs_dlgLabelSmall", onchange="#prefix#toggleAssocFld()")#
				#Server.CommonSpot.udf.tag.input(type="hidden", id="#prefix#refersParent", name="#prefix#refersParent", value="#currentValues.refersParent#")#
			</td>
		</tr>
		<tr id="assocCETr" <cfif currentValues.refersParent EQ 1>style="display:none;"</cfif>>
			<td valign="baseline" align="right">&nbsp;</td>
			<td valign="baseline" align="left">
			<table><tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Association Custom Element:</th>
			<td valign="baseline">
				<select id="#prefix#assocCustomElement" name="#prefix#assocCustomElement" size="1">
					<option value=""> - Select - </option>
					<cfloop query="globalCustomElements">
						<cfif selectedCEName NEQ globalCustomElements.Name AND globalCustomElements.ID NEQ attributes.FormID>
							<option value="#globalCustomElements.ID#" <cfif currentValues.assocCustomElement EQ globalCustomElements.ID>selected</cfif>>#globalCustomElements.Name#</option>
						</cfif>
						<cfif currentValues.assocCustomElement EQ globalCustomElements.ID>
							<cfset selectedAssocCEName = globalCustomElements.Name>
						</cfif>
					</cfloop>
				</select>
			</td>
			</tr></table>
			</td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Interface Options:</th>
			<td valign="baseline">
				<span id="newOption" <cfif selectedCEType EQ 'local'>style="display:none;"</cfif>>#Server.CommonSpot.udf.tag.checkboxRadio(type="checkbox", id="#prefix#interfaceOptionsCbox", name="#prefix#interfaceOptionsCbox", value="new", label="<span id='addNewOpt'>Allow 'Add New'</span>", labelIsHTML=1, checked=(ListFindNoCase(currentValues.interfaceOptions,'new')), labelClass="cs_dlgLabelSmall")#<br/></span>
				<span id="existingOption" <cfif currentValues.refersParent EQ 1>style="display:none;"</cfif>>#Server.CommonSpot.udf.tag.checkboxRadio(type="checkbox", id="#prefix#interfaceOptionsCbox", name="#prefix#interfaceOptionsCbox", value="existing", label="<span id='addExistingOpt'>Allow 'Add Existing'</span>", labelIsHTML=1, checked=(ListFindNoCase(currentValues.interfaceOptions,'existing')), labelClass="cs_dlgLabelSmall")#<br/></span>
				<span id="editAssocOption" <cfif currentValues.refersParent EQ 1>style="display:none;"</cfif>>#Server.CommonSpot.udf.tag.checkboxRadio(type="checkbox", id="#prefix#interfaceOptionsCbox", name="#prefix#interfaceOptionsCbox", value="editAssoc", label="<span id='editAssocOpt'>Allow 'Edit'</span>", labelIsHTML=1, checked=(ListFindNoCase(currentValues.interfaceOptions,'editAssoc')), labelClass="cs_dlgLabelSmall")#<br/></span>
				<span id="editChildOption" <cfif selectedCEType EQ 'local'>style="display:none;"</cfif>>#Server.CommonSpot.udf.tag.checkboxRadio(type="checkbox", id="#prefix#interfaceOptionsCbox", name="#prefix#interfaceOptionsCbox", value="editChild", label="<span id='editChildOpt'>Allow 'Edit'</span>", labelIsHTML=1, checked=(ListFindNoCase(currentValues.interfaceOptions,'editChild')), labelClass="cs_dlgLabelSmall")#<br/></span>
				#Server.CommonSpot.udf.tag.checkboxRadio(type="checkbox", id="#prefix#interfaceOptionsCbox", name="#prefix#interfaceOptionsCbox", value="delete", label="<span id='deleteOpt'>Allow 'Delete'</span>", labelIsHTML=1, checked=(ListFindNoCase(currentValues.interfaceOptions,'delete')), labelClass="cs_dlgLabelSmall")#
			</td>
		</tr>
		<tr>
			<th class="cs_dlgLabelBold" nowrap="nowrap" valign="top">Display Fields:</th>
			<td valign="baseline" nowrap="nowrap">
				<table><tr><td class="cs_dlgLabelSmall">Available Fields:<br/>
				<ul name="#prefix#allFields" id="#prefix#allFields" class="connectedSortable">
				</ul></td>
				<td class="cs_dlgLabelSmall">Fields to Display:<br/>
				<ul name="#prefix#displayFieldsSelected" id="#prefix#displayFieldsSelected" class="connectedSortable">
				</ul></td></tr></table>
			</td>
		</tr>
		<tr>
			<th class="cs_dlgLabelBold" nowrap="nowrap">Grid Dimensions:</th>
			<td valign="baseline" nowrap="nowrap">
				<table><tr><td class="cs_dlgLabelSmall">Width:
				#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#widthValue", name="#prefix#widthValue", value="#currentValues.widthValue#", size="5", class="InputControl")#
				<select name="#prefix#widthUnit" id="#prefix#widthUnit">
					<option value="percent" <cfif currentValues.widthUnit EQ 'percent'>selected</cfif>>%</option>
					<option value="pixel" <cfif currentValues.widthUnit EQ 'pixel'>selected</cfif>>px</option>
				</select></td>
				<td class="cs_dlgLabelSmall">Height:
				#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#heightValue", name="#prefix#heightValue", value="#currentValues.heightValue#", size="5", class="InputControl")#
				<select name="#prefix#heightUnit" id="#prefix#heightUnit">
					<option value="pixel" <cfif currentValues.heightUnit EQ 'pixel'>selected</cfif>>px</option>
				</select></td></td></tr></table>
			</td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Display Order:</th>
			<td valign="baseline" nowrap="nowrap">
				<table border="0" cellpadding="3" cellspacing="0" width="100%" summary="">
				<tr><td nowrap="nowrap">
					#Server.CommonSpot.udf.tag.checkboxRadio(type="radio", name="#prefix#sortByType", value="auto", label="Sort By", checked=(currentValues.sortByType EQ '' OR currentValues.sortByType EQ 'auto'), labelClass="cs_dlgLabelSmall", onchange="#prefix#selectRadio(0)")#&nbsp;
					<select name="#prefix#sortByField" id="#prefix#sortByField" onchange="#prefix#selectRadio(0)">
					</select>&nbsp;
					<select name="#prefix#sortByDir" id="#prefix#sortByDir" onchange="#prefix#selectRadio(0)">
						<option value="asc" <cfif currentValues.sortByDir EQ 'asc'>selected</cfif>>ASC</option>
						<option value="desc" <cfif currentValues.sortByDir EQ 'desc'>selected</cfif>>DESC</option>
					</select>
				</td></tr>
				<tr><td>
					#Server.CommonSpot.udf.tag.checkboxRadio(type="radio", name="#prefix#sortByType", value="manual", label="Order Manually", checked=(currentValues.sortByType EQ 'manual'), labelClass="cs_dlgLabelSmall", onchange="#prefix#selectRadio(1)")#&nbsp;
				</td></tr>
				<tr><td>
					<span id="positionFieldSpan" <cfif currentValues.sortByType EQ 'auto' OR currentValues.sortByType EQ ''>style="display:none;margin-left:40px;"<cfelse>style="margin-left:40px;"</cfif> class="cs_dlgLabelSmall">Position Field:&nbsp;<select name="#prefix#positionField" id="#prefix#positionField" onchange="#prefix#selectRadio(1)">
					</select>
					<div class="cs_dlgLabelSmall" style="margin-left:40px;margin-top:3px;">Only 'Number (integer)' or 'Hidden' fields can be used to Order Manually.</div>
					</span>
				</td></tr>
				</table>
			</td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Component Override:</th>
			<td valign="baseline">
				#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#compOverride", name="#prefix#compOverride", value="#currentValues.compOverride#", size="30", class="InputControl")#
			</td>
		</tr>
		<tr>
			<td colspan="2" valign="baseline" class="cs_dlgLabel" nowrap="nowrap"><strong>#parentCustomElementDetails.Name#<br/><hr/></strong></td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Unique Field:</th>
			<td valign="baseline">
				<select name="#prefix#parentUniqueField" id="#prefix#parentUniqueField">
					<option value=""> - Select - </option>
					<cfloop query="selectedTypeFields">
						<option value="#selectedTypeFields.ID#" <cfif currentValues.parentUniqueField EQ selectedTypeFields.ID>selected</cfif>>#selectedTypeFields.Name#</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="2" valign="baseline" class="cs_dlgLabel" nowrap="nowrap"><strong><span id="childCENameSpan">#selectedCEName#</span><br/><hr/></strong></td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Unique Field:</th>
			<td valign="baseline">
				<select name="#prefix#childUniqueField" id="#prefix#childUniqueField">
				</select>
			</td>
		</tr>
		<tr id="childLinkedFldSpan" <cfif currentValues.refersParent EQ 0>style="display:none;"</cfif>>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Linkage Field:</th>
			<td valign="baseline">
				<select name="#prefix#childLinkedField" id="#prefix#childLinkedField">
				</select>
			</td>
		</tr>
	</tbody>
	<tbody id="assocElementInputs" <cfif currentValues.refersParent EQ 1>style="display:none;"</cfif>>
		<tr>
			<td colspan="2" valign="baseline" class="cs_dlgLabel" nowrap="nowrap"><strong><span id="assocCENameSpan">#selectedAssocCEName#</span><br/><hr/></strong></td>
		</tr>
		<tr>
			<td colspan="2" valign="baseline" class="cs_dlgLabelSmall" nowrap="nowrap">Please choose what fields store the following data in the association custom element</td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">#parentCustomElementDetails.Name# InstanceID Field:</th>
			<td valign="baseline">
				<select name="#prefix#parentInstanceIDField" id="#prefix#parentInstanceIDField">
				</select>
			</td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap"><span id="assocChildCENameSpan">#selectedCEName#</span> InstanceID Field:</th>
			<td valign="baseline">
				<select name="#prefix#childInstanceIDField" id="#prefix#childInstanceIDField">
				</select>
			</td>
		</tr>
	</tbody>
	<tr id="inactiveFieldTr" <cfif NOT IsNumeric(currentValues.childCustomElement)>style="display:none;"</cfif>>
		<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Inactive Field:</th>
		<td valign="baseline" nowrap="nowrap">
			<select name="#prefix#inactiveField" id="#prefix#inactiveField" onChange="#prefix#showInactiveValueFld()">
			</select>&nbsp;
			<span id="inactiveValueSpan" class="cs_dlgLabelBold"<cfif currentValues.inactiveField EQ ''>style="display:none;"</cfif>>Inactive Value:&nbsp;#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#inactiveFieldValue", name="#prefix#inactiveFieldValue", value="#currentValues.inactiveFieldValue#", size="10", class="InputControl")#</span>
		</td>
	</tr>
	<tr>
		<td class="cs_dlgLabelSmall" colspan="2" style="font-size:7pt;">
			<hr />
			ADF Custom Field v#fieldVersion#
		</td>
	</tr>
</table>
#Server.CommonSpot.UDF.tag.input(type="hidden", name="#prefix#displayFields", value=currentValues.displayFields)#
#Server.CommonSpot.UDF.tag.input(type="hidden", name="#prefix#childCustomElement", value=currentValues.childCustomElement)#
#Server.CommonSpot.UDF.tag.input(type="hidden", name="#prefix#interfaceOptions", value=currentValues.interfaceOptions)#
</cfoutput>
</cfif>