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
	2014-02-24 - DJM - Fix for the problem of fields not loading up in available fields grid occasionally on change of association CE.
	2014-03-17 - GAC - Added dbType="QofQ" to the handle-in-list call inside the selectedTypeFields query or queries
	2014-07-01 - DJM - Added code to support metadata forms
	2014-09-08 - DJM - Updated styles for Interface Options and Display Fields
	2014-09-19 - GAC - Removed deprecated doLabel and jsLabelUpdater js calls
	2015-01-28 - DJM - Added timeout to resize frame function call to avoid multiple scrollbars
	2015-02-10 - DJM - Added code to hide text inputs related to secondary element when it is set as none
	2015-05-12 - DJM - Updated the field version to 2.0
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "2.0"; 
	
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
	if( not structKeyExists(currentValues, "assocCustomElement") )
		currentValues.assocCustomElement = "";
	if( not structKeyExists(currentValues, "secondaryElementType") )
		currentValues.secondaryElementType = "CustomElement";
	if( not structKeyExists(currentValues, "interfaceOptions") )
		currentValues.interfaceOptions = "existing,EditAssoc,delete";
	if( not structKeyExists(currentValues, "compOverride") )
		currentValues.compOverride = "";
	if( not structKeyExists(currentValues, "parentInstanceIDField") )
		currentValues.parentInstanceIDField = "";
	if( not structKeyExists(currentValues, "childInstanceIDField") )
		currentValues.childInstanceIDField = "";
	if( not structKeyExists(currentValues, "newOptionText") )
		currentValues.newOptionText = "";
	if( not structKeyExists(currentValues, "existingOptionText") )
		currentValues.existingOptionText = "";
	if( not structKeyExists(currentValues, "editAssocOptionText") )
		currentValues.editAssocOptionText = "";
	if( not structKeyExists(currentValues, "editChildOptionText") )
		currentValues.editChildOptionText = "";
	if( not structKeyExists(currentValues, "deleteOptionText") )
		currentValues.deleteOptionText = "";
	
	// UI changed to provide the JOIN as a single field instead of child and assoc. So added logic to properly select the join and secondary elements according to the data stored for DB
	joinObj = '';
	secondaryObj = '';
	if (IsNumeric(currentValues.assocCustomElement))
	{
		joinObj = currentValues.assocCustomElement;
		secondaryObj = currentValues.childCustomElement;
	}
	else
		joinObj = currentValues.childCustomElement;
		
	if (NOT IsNumeric(currentValues.assocCustomElement))
	{
		if (ListFindNoCase(currentValues.interfaceOptions, 'new'))
		{
			currentValues.interfaceOptions = ListSetAt(currentValues.interfaceOptions, ListFindNoCase(currentValues.interfaceOptions,'new'), 'existing');
			currentValues.existingOptionText = currentValues.newOptionText;
			currentValues.newOptionText = "";
		}
		if (ListFindNoCase(currentValues.interfaceOptions, 'editChild'))
		{
			currentValues.interfaceOptions = ListSetAt(currentValues.interfaceOptions, ListFindNoCase(currentValues.interfaceOptions,'editChild'), 'editAssoc');
			currentValues.editAssocOptionText = currentValues.editChildOptionText;
			currentValues.editChildOptionText = "";
			
		}
	}
	
	parentElementType = '';
	parentFormLabel = '';
	fieldsMethod = "getFields";
	fieldsArgs = StructNew();
	infoMethod = "getInfo";
	infoArgs = StructNew();
	isDataManagerEnabled = 1;

	switch (dlgtype)
	{
		case 'customelement':
			parentElementType = 'CustomElement';
			infoArgs.elementID = formID;
			fieldsArgs.elementID = formID;
			break;
		case 'metadata':
			parentElementType = 'MetadataForm';
			infoMethod = "getForms";
			infoArgs.id = formID;
			fieldsArgs.formID = formID;
			break;
		case 'simpleform':
			isDataManagerEnabled = 0;
	}
</cfscript>

<cfif isDataManagerEnabled>
<cfscript>
	customElementObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
	metadataFormObj = Server.CommonSpot.ObjectFactory.getObject('MetadataForm');
	if (parentElementType EQ 'MetadataForm')
		parentFormObj = metadataFormObj;
	else
		parentFormObj = customElementObj;
</cfscript>
<cfinvoke component="#parentFormObj#" method="#infoMethod#" argumentCollection="#infoArgs#" returnvariable="parentFormDetails">

<cfinvoke component="#parentFormObj#" method="#fieldsMethod#" argumentCollection="#fieldsArgs#" returnvariable="selectedTypeFields">

<cfscript>
	allMetadataForms = metadataFormObj.getForms();
	allCustomElements = customElementObj.getList(type="All", state="Active");
	errorMsgCustom = 'Some error occurred while trying to perform the operation.';	
	
	if (parentElementType EQ 'MetadataForm')
		parentFormLabel = parentFormDetails.formName;
	else
		parentFormLabel = parentFormDetails.Name;
</cfscript>

<cfquery name="allForms" dbtype="query">
	SELECT ID, Name, LOWER(Type) 
	  FROM allCustomElements 
	UNION ALL
	SELECT ID, FormName AS Name, 'metadataform' AS Type
	  FROM allMetadataForms
</cfquery>

<cfquery name="globalCustomElements" dbtype="query">
	SELECT *
	  FROM allCustomElements
	 WHERE lower(Type) = <cfqueryparam value="global" cfsqltype="cf_sql_varchar">
</cfquery>

<cfquery name="selectedTypeFields" dbtype="query">
	SELECT ID, Label AS Name
	  FROM selectedTypeFields
	 WHERE <cfmodule template="/commonspot/utilities/handle-in-list.cfm" field="Type" list="formatted_text_block,taxonomy,date,calendar" cfsqltype="cf_sql_varchar" isNot=1 dbType="QofQ">	
</cfquery>

<cfscript>
	application.ADF.scripts.loadJQuery(noConflict=true);
	application.ADF.scripts.loadJQueryUI();
</cfscript>

<cfoutput>
<style>
	###prefix#allFields, ###prefix#displayFieldsSelected { list-style-type: none; margin: 0; padding: 0; float: left; border:1px solid black; height:140px; width:200px; overflow: auto;}
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
	
	fieldProperties['#typeid#'].paramFields = "#prefix#childCustomElement,#prefix#parentUniqueField,#prefix#childUniqueField,#prefix#childLinkedField,#prefix#inactiveField,#prefix#inactiveFieldValue,#prefix#displayFields,#prefix#sortByType,#prefix#sortByField,#prefix#sortByDir,#prefix#positionField,#prefix#assocCustomElement,#prefix#secondaryElementType,#prefix#interfaceOptions,#prefix#compOverride,#prefix#parentInstanceIDField,#prefix#childInstanceIDField,#prefix#widthValue,#prefix#widthUnit,#prefix#heightValue,#prefix#heightUnit,#prefix#newOptionText,#prefix#existingOptionText,#prefix#editAssocOptionText,#prefix#editChildOptionText,#prefix#deleteOptionText";
	fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
	
	function #prefix#toggleInputField(chkBoxObj,optionValue)
	{
		var fldObj = '';
		var spanObj = '';
		var inputText = '';
		switch (optionValue)
		{
			case 'new':
				fldObj = document.#formname#.#prefix#newOptionText;
				spanObj = document.getElementById('newOptionTextSpan');
				inputText = 'Add New ' + document.#formname#.#prefix#assocCustomElementSelect.options[document.#formname#.#prefix#assocCustomElementSelect.selectedIndex].text;
				break;
			case 'existing':
				fldObj = document.#formname#.#prefix#existingOptionText;
				spanObj = document.getElementById('existingOptionTextSpan');
				inputText = 'Add New ' + document.#formname#.#prefix#childCustomElementSelect.options[document.#formname#.#prefix#childCustomElementSelect.selectedIndex].text;
				break;
			case 'editAssoc':
				fldObj = document.#formname#.#prefix#editAssocOptionText;
				spanObj = document.getElementById('editAssocOptionTextSpan');
				inputText = 'Edit ' + document.#formname#.#prefix#childCustomElementSelect.options[document.#formname#.#prefix#childCustomElementSelect.selectedIndex].text;
				break;
			case 'editChild':
				fldObj = document.#formname#.#prefix#editChildOptionText;
				spanObj = document.getElementById('editChildOptionTextSpan');
				inputText = 'Edit ' + document.#formname#.#prefix#assocCustomElementSelect.options[document.#formname#.#prefix#assocCustomElementSelect.selectedIndex].text;
				break;
			case 'delete':
				fldObj = document.#formname#.#prefix#deleteOptionText;
				spanObj = document.getElementById('deleteOptionTextSpan');
				inputText = 'Delete ' + document.#formname#.#prefix#childCustomElementSelect.options[document.#formname#.#prefix#childCustomElementSelect.selectedIndex].text;
				break;		
		}
		if (chkBoxObj.checked == true)
		{
			fldObj.value = inputText;
			spanObj.style.display = "";
		}
		else
		{
			fldObj.value = "";
			spanObj.style.display = "none";
		}
	}
	
	function #prefix#doValidate()
	{
		var selectedWidthUnitVal = '';
		var selectedJoin = '';
		var selectedSecondary = '';
		var selectedType = '';
		if ( document.#formname#.#prefix#childCustomElementSelect.selectedIndex == 0 )
		{
			showMsg('Please select a custom element.');
			return false;
		}
		else
		{
			selectedJoin = document.#formname#.#prefix#childCustomElementSelect.options[document.#formname#.#prefix#childCustomElementSelect.selectedIndex].value;
		}
	<cfif dlgtype NEQ 'metadata'>
		if ( document.#formname#.#prefix#parentUniqueField.selectedIndex <= 0 )
		{
			showMsg('Please select a unique field for the parent custom element.');
			return false;
		}
	</cfif>
		if (document.#formname#.#prefix#assocCustomElementSelect.selectedIndex > 0)
		{
			if (document.#formname#.#prefix#secondaryUniqueField.selectedIndex <= 0)
			{
				showMsg('Please select a unique field for the secondary object.');
				return false;
			}
			else
			{
				document.#formname#.#prefix#childUniqueField.value = document.#formname#.#prefix#secondaryUniqueField.options[document.#formname#.#prefix#secondaryUniqueField.selectedIndex].value;
			}
			selectedSecondary = document.#formname#.#prefix#assocCustomElementSelect.options[document.#formname#.#prefix#assocCustomElementSelect.selectedIndex].value;
			var selectedSecondaryArray = selectedSecondary.split('||');
			if (selectedSecondaryArray.length == 2)
			{
				selectedSecondary = selectedSecondaryArray[1];
				selectedType = selectedSecondaryArray[0];
			}
			else
			{
				selectedSecondary = selectedSecondaryArray[0];
			}
		}
		else if (document.#formname#.#prefix#assocCustomElementSelect.selectedIndex <= 0)
		{
			if (document.#formname#.#prefix#joinUniqueField.selectedIndex <= 0)
			{
				showMsg('Please select a unique field for the join custom element.');
				return false;
			}
			else
			{
				document.#formname#.#prefix#childUniqueField.value = document.#formname#.#prefix#joinUniqueField.options[document.#formname#.#prefix#joinUniqueField.selectedIndex].value;
			}
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
		if ( document.#formname#.#prefix#sortByType[1].checked == true && document.#formname#.#prefix#childUniqueField.value == document.#formname#.#prefix#positionField.options[document.#formname#.#prefix#positionField.selectedIndex].value)
		{
			showMsg('Position field cannot be same as child custom element unique field.');
			return false;
		}
		if ( document.#formname#.#prefix#assocCustomElementSelect.selectedIndex <= 0 )
		{
			if ( document.#formname#.#prefix#childLinkedField.selectedIndex <= 0 )
			{
				showMsg('Please select a unique field for the child custom element linked field.');
				return false;
			}
			
			if ( document.#formname#.#prefix#sortByType[1].checked == true && document.#formname#.#prefix#childLinkedField.value == document.#formname#.#prefix#positionField.options[document.#formname#.#prefix#positionField.selectedIndex].value)
			{
				showMsg('Position field cannot be same as child custom element linked field.');
				return false;
			}
		}
		else
		{
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
		var addToList = 1;
		var valueToAdd = '';
		for(var i=0; i<document.#formname#.#prefix#interfaceOptionsCbox.length; i++) {
			if(document.#formname#.#prefix#interfaceOptionsCbox[i].checked == true)
			{
				addToList = 1;
					valueToAdd = '';
				if ((i == 0 || i == 3) && selectedType.toLowerCase() != 'global')
					addToList = 0;
				if (addToList == 1)
				{
					valueToAdd = document.#formname#.#prefix#interfaceOptionsCbox[i].value;
					var fldValue = '';
					switch (valueToAdd)
					{
						case 'new':
							fldValue = trim(document.#formname#.#prefix#newOptionText.value);
							break;
						case 'existing':
							fldValue = trim(document.#formname#.#prefix#existingOptionText.value);
							break;
						case 'editAssoc':
							fldValue = trim(document.#formname#.#prefix#editAssocOptionText.value);
							break;
						case 'editChild':
							fldValue = trim(document.#formname#.#prefix#editChildOptionText.value);
							break;
						case 'delete':
							fldValue = trim(document.#formname#.#prefix#deleteOptionText.value);
							break;		
					}
					if ( fldValue == '')
					{
						showMsg('Please enter a button/hover text for all the checked interface options.');
						return false;
					}
					if (document.#formname#.#prefix#assocCustomElementSelect.selectedIndex <= 0)
					{
						if (valueToAdd == 'existing')
						{
							valueToAdd = 'new';
							document.#formname#.#prefix#newOptionText.value = document.#formname#.#prefix#existingOptionText.value;
							document.#formname#.#prefix#existingOptionText.value = "";
						}
						else if (valueToAdd == 'editAssoc')
						{
							valueToAdd = 'editChild';
							document.#formname#.#prefix#editChildOptionText.value = document.#formname#.#prefix#editAssocOptionText.value;
							document.#formname#.#prefix#editAssocOptionText.value = "";
						}
					}
					if(interfaceOptionsList.length > 0)
						interfaceOptionsList = interfaceOptionsList + ',' + valueToAdd;
					else
						interfaceOptionsList = valueToAdd;
				}
			}
		}
		
		if (document.#formname#.#prefix#assocCustomElementSelect.selectedIndex <= 0)
		{
			document.#formname#.#prefix#existingOptionText.value = "";
			document.#formname#.#prefix#editAssocOptionText.value = "";
		}
		
		document.#formname#.#prefix#interfaceOptions.value = interfaceOptionsList;
		
		var compOverrideValue = trim(document.#formname#.#prefix#compOverride.value);
		document.#formname#.#prefix#compOverride.value = compOverrideValue;
		
		if (document.#formname#.#prefix#assocCustomElementSelect.selectedIndex > 0)
		{
			document.#formname#.#prefix#childCustomElement.value = selectedSecondary;
			document.#formname#.#prefix#assocCustomElement.value = selectedJoin;
		}
		else
		{
			document.#formname#.#prefix#childCustomElement.value = selectedJoin;
			document.#formname#.#prefix#assocCustomElement.value = selectedSecondary;
		}
		
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
		jQuery("###prefix#assocCustomElementSelect").change(assocOptionFunction);
		
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
		var selectedAssocWithType = jQuery("option:selected",jQuery("###prefix#assocCustomElementSelect")).val();
		var selectedAssocWithTypeArray = selectedAssocWithType.split('||');
		var selectedAssoc = selectedAssocWithTypeArray[0];
		var selectedType = '';
		if (selectedAssocWithTypeArray.length == 2)
		{
			selectedAssoc = selectedAssocWithTypeArray[1];
			selectedType = selectedAssocWithTypeArray[0];
		}
		
		if (selectedType == 'metadataform')
			selectedFormType = 'MetadataForm';
		else
			selectedFormType = 'CustomElement';
		var selectedChild = jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).val();
		document.#formname#.#prefix#assocCustomElement.value = selectedAssoc;
		document.#formname#.#prefix#childCustomElement.value = selectedChild;
		document.#formname#.#prefix#secondaryElementType.value = selectedFormType;
		
		displayDeleteBtnText();

		// Make all fields blank related to secondary object
		jQuery("###prefix#secondaryUniqueField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		
		// Make all fields blank related to join object
		jQuery("###prefix#allFields").children().remove().end();
		jQuery("###prefix#displayFieldsSelected").children().remove().end();
		jQuery("###prefix#sortByField").children().remove().end().append("<option value=\"\"> - Select -</option>");			
		jQuery("###prefix#positionField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		
		jQuery("###prefix#joinUniqueField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#childLinkedField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#inactiveField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		
		jQuery("###prefix#parentInstanceIDField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#childInstanceIDField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		
		// If child is not selected then just return
		if (selectedChild == "")
		{
			document.getElementById("addExistingOpt").innerHTML = "Allow 'Add New'";
			document.getElementById("editAssocOpt").innerHTML = "Allow 'Edit'";
			return;
		}
		else
		{
			document.getElementById("addExistingOpt").innerHTML = "Allow 'Add New " + jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).text() + "'";
			document.getElementById("editAssocOpt").innerHTML = "Allow 'Edit' of " + jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).text();
			var selectedDisplayFieldIDs = "#currentValues.displayFields#";
			var selectedDisplayFieldIDArray = selectedDisplayFieldIDs.split(',');
			var replaceArrayForSelected = selectedDisplayFieldIDs.split(',');			
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
					
					jQuery("###prefix#sortByField").children().end().append(newOptions);
					if ('#currentValues.sortByType#' == 'auto')
						jQuery("###prefix#sortByField").val(#currentValues.sortByField#);
					
					jQuery("###prefix#inactiveField").children().end().append(selectedTypeExcludedOptions);
					jQuery("###prefix#inactiveField").val(#currentValues.inactiveField#);
					
					jQuery("###prefix#positionField").children().end().append(selectedTypeIncludedOptions);
					if ('#currentValues.sortByType#' == 'manual')
						jQuery("###prefix#positionField").val(#currentValues.positionField#);
					
					jQuery("###prefix#childLinkedField").children().end().append(selectedTypeExcludedOptions);
					
					jQuery("###prefix#parentInstanceIDField").children().end().append(newOptions);
					jQuery("###prefix#childInstanceIDField").children().end().append(newOptions);
					
					jQuery("###prefix#joinUniqueField").children().end().append(selectedTypeExcludedOptions);
					
					if (selectedAssoc == "")
					{
						jQuery("###prefix#displayFieldsSelected").children().end().append(selectedDisplayFieldsFromChild);
						jQuery("###prefix#childLinkedField").val(#currentValues.childLinkedField#);
						jQuery("###prefix#joinUniqueField").val(#currentValues.childUniqueField#);
						return;
					}
					else
					{
						jQuery("###prefix#parentInstanceIDField").val(#currentValues.parentInstanceIDField#);
						jQuery("###prefix#childInstanceIDField").val(#currentValues.childInstanceIDField#);
						var selectedAssocText = jQuery("option:selected",jQuery("###prefix#assocCustomElementSelect")).text();
						document.getElementById("addNewOpt").innerHTML = "Allow 'Add New " + selectedAssocText + "'";
						document.getElementById("editChildOpt").innerHTML = "Allow 'Edit' of " + selectedAssocText;
						document.getElementById('assocCENameSpan').innerHTML = selectedAssocText;
						document.getElementById('assocChildCENameSpan').innerHTML = selectedAssocText;
						
						// jQuery call to populate the Parent FormID, Parent Instance ID, Child Form ID, Child Instance ID and Sort By Fields
						jQuery.getJSON("#ajaxComURL#?bean=#ajaxBeanName#&method=getFields&query2array=0&returnformat=json",{"elementid":selectedAssoc,"elementType":selectedFormType}) 
						.done(function(retData) {
						
						    // Convert the Data from the AjaxProxy to CF Object
							var res = #prefix#convertAjaxProxyObj2CFqueryObj(retData);
						
							if (res.COLUMNS[0] != 'ERRORMSG')
							{
								var newSortByOptions = "";
								var avaiableDisplayFields = "";
								var selectedTypeExcludedOptions = "";
								var columnMap = {};
								for (var i = 0; i < res.COLUMNS.length; i++) {
									columnMap[res.COLUMNS[i]] = i;
								}
								
								for(var i=0; i<res.DATA.length; i++) {
									//In our result, ID is what we will use for the value, and NAME for the label
									newSortByOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</option>";
									if (res.DATA[i][columnMap.TYPE] != 'formatted_text_block' && res.DATA[i][columnMap.TYPE] != 'taxonomy' && res.DATA[i][columnMap.TYPE] != 'date' && res.DATA[i][columnMap.TYPE] != 'calendar')
										selectedTypeExcludedOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
									if (selectedDisplayFieldIDArray.indexOf(res.DATA[i][columnMap.ID].toString()) == -1)
										avaiableDisplayFields += "<li value=\"" + res.DATA[i][columnMap.ID] + "\" class=\"ui-state-default\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</li>";
									else
									{
										replaceArrayForSelected[selectedDisplayFieldIDArray.indexOf(res.DATA[i][columnMap.ID].toString())] = "<li value=\"" + res.DATA[i][columnMap.ID] + "\" class=\"ui-state-default\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</li>";
									}
								}
								
								// association element is selected then append the assoc element fields to the end of the sort by field
								jQuery("###prefix#sortByField").children().end().append(newSortByOptions);
								if ('#currentValues.sortByType#' == 'auto')
									jQuery("###prefix#sortByField").val(#currentValues.sortByField#);
								
								jQuery("###prefix#allFields").children().end().append(avaiableDisplayFields);
								jQuery("###prefix#secondaryUniqueField").children().end().append(selectedTypeExcludedOptions);
								jQuery("###prefix#secondaryUniqueField").val(#currentValues.childUniqueField#);
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
// 	newOptionTextField
<CFIF currentValues.newOptionText EQ ''>
	document.getElementById('#prefix#newOptionText').value = 'Add New ' + jQuery("option:selected",jQuery("###prefix#assocCustomElementSelect")).text();
</CFIF>
// 	existingOptionTextField
<CFIF currentValues.existingOptionText EQ ''>
	document.getElementById('#prefix#existingOptionText').value = 'Add New ' + jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).text();
</CFIF>
// 	editAssocOptionTextField
<CFIF currentValues.editAssocOptionText EQ ''>
	document.getElementById('#prefix#editAssocOptionText').value = 'Edit ' + jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).text();
</CFIF>
// 	editChildOptionTextField
<CFIF currentValues.editChildOptionText EQ ''>
	document.getElementById('#prefix#editChildOptionText').value = 'Edit ' + jQuery("option:selected",jQuery("###prefix#assocCustomElementSelect")).text();
</CFIF>
// 	deleteOptionTextField
<CFIF currentValues.deleteOptionText EQ ''>
	document.getElementById('#prefix#deleteOptionText').value = 'Delete ' + jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).text();
</CFIF>
	}
	
	assocOptionFunction = function(){
		var selectedAssocWithType = jQuery("option:selected",jQuery("###prefix#assocCustomElementSelect")).val();
		var selectedAssocWithTypeArray = selectedAssocWithType.split('||');
		var selectedAssoc = selectedAssocWithTypeArray[0];
		var selectedType = '';
		if (selectedAssocWithTypeArray.length == 2)
		{
			selectedAssoc = selectedAssocWithTypeArray[1];
			selectedType = selectedAssocWithTypeArray[0];
		}
		
		if (selectedType.toLowerCase() == 'metadataform')
			selectedFormType = 'MetadataForm';
		else
			selectedFormType = 'CustomElement';
		var selectedChild = jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).val();
		
		document.#formname#.#prefix#assocCustomElement.value = selectedAssoc;
		document.#formname#.#prefix#secondaryElementType.value = selectedFormType;
		
		var sortByFieldSelectedValue = '';
		if(document.#formname#.#prefix#sortByField.selectedIndex > 0)
			sortByFieldSelectedValue = document.#formname#.#prefix#sortByField.options[document.#formname#.#prefix#sortByField.selectedIndex].value;
		
		document.getElementById('assocCENameSpan').innerHTML = "";
		document.getElementById('assocChildCENameSpan').innerHTML = "";
		document.#formname#.#prefix#secondaryUniqueField.selectedIndex = 0;
		#prefix#showInactiveValueFld();
		
		// Remove this
		jQuery("###prefix#secondaryUniqueField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		
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
			})
			.then(function() {
				updateFieldsOnAssocCEChange(selectedAssoc,selectedType,selectedChild);
			});
		}
		else
		{
			jQuery("###prefix#allFields").children().remove().end();
			
			jQuery("###prefix#displayFieldsSelected").children().remove().end();
				
			jQuery("###prefix#sortByField").children().remove().end().append("<option value=\"\"> - Select -</option>");;
			
			document.#formname#.#prefix#displayFields.value = "";
			updateFieldsOnAssocCEChange(selectedAssoc,selectedType,selectedChild);
		}
		window.setTimeout("checkFrameSize(1)",100);
	}
	
	updateFieldsOnAssocCEChange = function(selectedAssoc,selectedType,selectedChild){
		if (selectedType.toLowerCase() == 'metadataform')
			selectedFormType = 'MetadataForm';
		else
			selectedFormType = 'CustomElement';
		
		if (selectedAssoc == "")
		{
			document.getElementById('newOption').style.display = "none";
			document.getElementById('editChildOption').style.display = "none";
			document.getElementById('newOptionTextSpan').style.display = "none";
			document.getElementById('editChildOptionTextSpan').style.display = "none";			

			if (selectedChild != "")
				document.getElementById('twoJoinInputs').style.display = "";
			document.getElementById('threeJoinInputs').style.display = "none";
			document.getElementById('secondaryElementInputs').style.display = "none";
			return;
		}
		else
		{
			if (selectedType.toLowerCase() == 'global')
			{				
				document.getElementById('newOption').style.display = "";
				document.getElementById('editChildOption').style.display = "";
				document.getElementById('newOptionTextSpan').style.display = "";
				document.getElementById('editChildOptionTextSpan').style.display = "";	
			}
			else
			{
				document.getElementById('newOption').style.display = "none";
				document.getElementById('editChildOption').style.display = "none";
				document.getElementById('newOptionTextSpan').style.display = "none";
				document.getElementById('editChildOptionTextSpan').style.display = "none";	
			}
			var selecetdAssocText = jQuery("option:selected",jQuery("###prefix#assocCustomElementSelect")).text();
			document.getElementById("addNewOpt").innerHTML = "Allow 'Add New " + selecetdAssocText + "'";
			document.getElementById("editChildOpt").innerHTML = "Allow 'Edit' of " + selecetdAssocText;
			document.getElementById("#prefix#newOptionText").value = "Add New " + selecetdAssocText;
			document.getElementById("#prefix#editChildOptionText").value = "Edit " + selecetdAssocText;
			document.getElementById('threeJoinInputs').style.display = "";
			document.getElementById('twoJoinInputs').style.display = "none";
			document.getElementById('secondaryElementInputs').style.display = "";
			document.getElementById('assocCENameSpan').innerHTML = selecetdAssocText;
			document.getElementById('assocChildCENameSpan').innerHTML = selecetdAssocText;
			
			jQuery.getJSON("#ajaxComURL#?bean=#ajaxBeanName#&method=getFields&query2array=0&returnformat=json",{"elementid":selectedAssoc,"elementType":selectedFormType}) 
			.done(function(retData) {
			
			     // Convert the Data from the AjaxProxy to CF Object
				 var res = #prefix#convertAjaxProxyObj2CFqueryObj(retData);
			
				if (res.COLUMNS[0] != 'ERRORMSG')
				{
					var newListOptions = "";
					var newSortByOptions = "";
					var selectedTypeExcludedOptions = "";
					var columnMap = {};
					for (var i = 0; i < res.COLUMNS.length; i++) {
						columnMap[res.COLUMNS[i]] = i;
					}
					
					for(var i=0; i<res.DATA.length; i++) {
						//In our result, ID is what we will use for the value, and NAME for the label
						newSortByOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</option>";
						newListOptions += "<li value=\"" + res.DATA[i][columnMap.ID] + "\" class=\"ui-state-default\">" + res.DATA[i][columnMap.CUSTOMELEMENTNAME] + "." + res.DATA[i][columnMap.NAME] + "</li>";
						if (res.DATA[i][columnMap.TYPE] != 'formatted_text_block' && res.DATA[i][columnMap.TYPE] != 'taxonomy' && res.DATA[i][columnMap.TYPE] != 'date' && res.DATA[i][columnMap.TYPE] != 'calendar')
							selectedTypeExcludedOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
					}
					jQuery("###prefix#allFields").children().end().append(newListOptions);
					jQuery("###prefix#secondaryUniqueField").children().end().append(selectedTypeExcludedOptions);
					jQuery("###prefix#sortByField").children().end().append(newSortByOptions);
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
	
	childOptionFunction = function(){		
		var selectedAssocWithType = jQuery("option:selected",jQuery("###prefix#assocCustomElementSelect")).val();
		var selectedAssocWithTypeArray = selectedAssocWithType.split('||');
		var selectedAssoc = selectedAssocWithTypeArray[0];
		var selectedType = '';
		if (selectedAssocWithTypeArray.length == 2)
		{
			selectedAssoc = selectedAssocWithTypeArray[1];
			selectedType = selectedAssocWithTypeArray[0];
		}
		
		if (selectedType.toLowerCase() == 'metadataform')
			selectedFormType = 'MetadataForm';
		else
			selectedFormType = 'CustomElement';
		var selectedChild = jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).val();
			
		displayDeleteBtnText();
		
		document.#formname#.#prefix#assocCustomElement.value = selectedAssoc;
		document.#formname#.#prefix#childCustomElement.value = selectedChild;
		document.#formname#.#prefix#secondaryElementType.value = selectedFormType;
		
		var sortByFieldSelectedValue = '';
		if(document.#formname#.#prefix#sortByField.selectedIndex > 0)
			sortByFieldSelectedValue = document.#formname#.#prefix#sortByField.options[document.#formname#.#prefix#sortByField.selectedIndex].value;
		document.getElementById('childCENameSpan').innerHTML = "";
		document.getElementById('assocCENameSpan').innerHTML = "";
		document.getElementById('assocChildCENameSpan').innerHTML = "";
		document.#formname#.#prefix#joinUniqueField.selectedIndex = 0;
		document.#formname#.#prefix#positionField.selectedIndex = 0;
		document.#formname#.#prefix#inactiveField.selectedIndex = 0;
		document.#formname#.#prefix#sortByField.selectedIndex = 0;
		jQuery("###prefix#positionField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#inactiveField").children().remove().end().append("<option value=\"\"> - Select -</option>");		
		jQuery("###prefix#joinUniqueField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#childLinkedField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#parentInstanceIDField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#childInstanceIDField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		
		if (selectedAssoc != "")
		{
			
			document.#formname#.#prefix#parentInstanceIDField.selectedIndex = 0;
			document.#formname#.#prefix#childInstanceIDField.selectedIndex = 0;
			jQuery.getJSON("#ajaxComURL#?bean=#ajaxBeanName#&method=getFieldIDList&returnformat=json",{"elementid":selectedAssoc,"elementType":selectedFormType})
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
			})
			.then(function() {
				updateFieldsOnChildCEChange(selectedChild,selectedAssoc,selectedType);
			});
		}
		else
		{
			jQuery("###prefix#allFields").children().remove().end();
			
			jQuery("###prefix#displayFieldsSelected").children().remove().end();
			
			jQuery("###prefix#sortByField").children().remove().end().append("<option value=\"\"> - Select -</option>");
			document.#formname#.#prefix#childLinkedField.selectedIndex = 0;
			document.#formname#.#prefix#displayFields.value = "";
			updateFieldsOnChildCEChange(selectedChild,selectedAssoc,selectedType);
		}
		checkFrameSize(1);
	}
	
	updateFieldsOnChildCEChange = function(selectedChild,selectedAssoc,selectedType){
		if (selectedChild == "")
		{
			document.getElementById("addExistingOpt").innerHTML = "Allow 'Add New'";
			document.getElementById("editAssocOpt").innerHTML = "Allow 'Edit'";
			document.getElementById('childElementInputs').style.display = "none";
			document.getElementById('inactiveFieldTr').style.display = "none";
			document.getElementById('threeJoinInputs').style.display = "none";
			document.getElementById('twoJoinInputs').style.display = "none";
			document.#formname#.#prefix#assocCustomElementSelect.selectedIndex = 0;
			assocOptionFunction();
			return;
		}
		else
		{
			var selectedChildText = jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).text();
			selectedAssocWithType = jQuery("option:selected",jQuery("###prefix#assocCustomElementSelect")).val();
			document.getElementById("addExistingOpt").innerHTML = "Allow 'Add New " + selectedChildText + "'";
			document.getElementById("editAssocOpt").innerHTML = "Allow 'Edit' of " + selectedChildText;
			document.getElementById("#prefix#existingOptionText").value = "Add New " + selectedChildText;
			document.getElementById("#prefix#editAssocOptionText").value = "Edit " + selectedChildText;
			document.getElementById("#prefix#deleteOptionText").value = "Delete " + selectedChildText;
			document.getElementById('childElementInputs').style.display = "";
			document.getElementById('existingOption').style.display = "";
			document.getElementById('editAssocOption').style.display = "";
			document.getElementById('inactiveFieldTr').style.display = "";
			
			if (selectedAssoc != "")
				document.getElementById('threeJoinInputs').style.display = "";
			else
				document.getElementById('twoJoinInputs').style.display = "";
			
			var childCustomElementName = jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).text();
			document.getElementById('childCENameSpan').innerHTML = childCustomElementName;
			
			jQuery("###prefix#assocCustomElementSelect").children().remove().end().append("<option value=\"\">None</option>");

/* -- Updated to use AjaxProxy -- */			
/* 	jQuery.getJSON("#ajaxComURL#/custom_element_datamanager_base.cfc?method=getGlobalCE&returnformat=json") */
			
			jQuery.getJSON("#ajaxComURL#?bean=#ajaxBeanName#&method=getAllForms&query2array=0&returnformat=json")
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
							newOptions += "<option value=\"" + res.DATA[i][columnMap.TYPE] + "||" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
					}
					
					jQuery("###prefix#assocCustomElementSelect").children().end().append(newOptions);
					jQuery("###prefix#assocCustomElementSelect").val(selectedAssocWithType);
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
						
						if (res.DATA[i][columnMap.TYPE] == 'hidden' || res.DATA[i][columnMap.TYPE] == 'integer' || res.DATA[i][columnMap.TYPE] == 'custom')
							selectedTypeIncludedOptions += "<option value=\"" + res.DATA[i][columnMap.ID] + "\">" + res.DATA[i][columnMap.NAME] + "</option>";
					}
					
					jQuery("###prefix#sortByField").children().end().append(newOptions);
					
					jQuery("###prefix#allFields").children().end().append(newListOptions);
					jQuery("###prefix#joinUniqueField").children().end().append(selectedTypeExcludedOptions);
					jQuery("###prefix#childLinkedField").children().end().append(selectedTypeExcludedOptions);
					jQuery("###prefix#parentInstanceIDField").children().end().append(newOptions);
					jQuery("###prefix#childInstanceIDField").children().end().append(newOptions);
					
					jQuery("###prefix#positionField").children().end().append(selectedTypeIncludedOptions);
					jQuery("###prefix#inactiveField").children().end().append(selectedTypeExcludedOptions);
					
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
	}
	
	displayDeleteBtnText = function(){
		var selectedAssocWithType = jQuery("option:selected",jQuery("###prefix#assocCustomElementSelect")).val();
		var selectedAssocWithTypeArray = selectedAssocWithType.split('||');
		var selectedAssoc = selectedAssocWithTypeArray[0];
		var selectedType = '';
		if (selectedAssocWithTypeArray.length == 2)
		{
			selectedAssoc = selectedAssocWithTypeArray[1];
			selectedType = selectedAssocWithTypeArray[0];
		}
		
		if (selectedType.toLowerCase() == 'metadataform')
			selectedFormType = 'MetadataForm';
		else
			selectedFormType = 'CustomElement';
		var selectedChild = jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).val();
		
		if (selectedChild == "" && selectedAssoc == "")
		{
			document.getElementById("deleteOpt").innerHTML = "Allow 'Delete'";
		}
		else
		{
			document.getElementById("deleteOpt").innerHTML = "Allow 'Delete' of " + jQuery("option:selected",jQuery("###prefix#childCustomElementSelect")).text();
		}
	}
// -->
</script>
</cfoutput>

<cfset selectedJoinCEName = ''>
<cfset selectedSecondaryCEType = ''>
<cfset selectedSecondaryCEName = ''>

<cfoutput>
<table border="0" cellpadding="3" cellspacing="0" width="100%" summary="">
	<tr><td colspan="2"><span id="errorMsgSpan" class="cs_dlgError"></span></td></tr>
	<tr>
		<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Primary Object:</th>
		<td valign="baseline" class="cs_dlgLabel">#parentFormLabel#</td>
	</tr>
	<tr>
		<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Joining Custom Element:</th>
		<td valign="baseline">
			<select id="#prefix#childCustomElementSelect" name="#prefix#childCustomElementSelect" size="1">
				<option value=""> - Select - </option>
				<cfloop query="globalCustomElements">
					<!---<cfif allCustomElements.ID NEQ attributes.FormID>--->
						<option value="#globalCustomElements.ID#" <cfif joinObj EQ globalCustomElements.ID>selected</cfif>>#globalCustomElements.Name#</option>
					<!---</cfif>--->
					<cfif joinObj EQ globalCustomElements.ID>
						<cfset selectedJoinCEName = globalCustomElements.Name>
					</cfif>
				</cfloop>
			</select>
		</td>
	</tr>
	
	<tbody id="childElementInputs" <cfif NOT IsNumeric(joinObj)>style="display:none;"</cfif>>
		<tr>
			<td valign="baseline" align="right">&nbsp;</td>
			<td valign="baseline" align="left" class="cs_dlgLabelSmall">This is the custom element that contains the relationship between the object(s). It may contain other data as well.</td>
		</tr>
		<tr id="assocCETr">
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Secondary Object:</th>
			<td valign="baseline">
				<select id="#prefix#assocCustomElementSelect" name="#prefix#assocCustomElementSelect" size="1">
					<option value="">None</option>
					<cfloop query="allForms">
						<cfif selectedJoinCEName NEQ allForms.Name AND allForms.ID NEQ attributes.FormID>
							<option value="#LCase(allForms.Type)#||#allForms.ID#" <cfif secondaryObj EQ allForms.ID>selected</cfif>>#allForms.Name#</option>
						</cfif>
						<cfif secondaryObj EQ allForms.ID>
							<cfset selectedSecondaryCEName = allForms.Name>
							<cfset selectedSecondaryCEType = allForms.Type>
						</cfif>
					</cfloop>
				</select>
			</td>
		</tr>
		
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Interface Options:</th>
			<td valign="baseline" class="cs_dlgLabelSmall">
				<span id="newOption" <cfif secondaryObj EQ "" OR selectedSecondaryCEType NEQ 'global'>style="display:none;"</cfif>>#Server.CommonSpot.udf.tag.checkboxRadio(type="checkbox", id="#prefix#interfaceOptionsCbox", name="#prefix#interfaceOptionsCbox", value="new", label="<span id='addNewOpt'>Allow 'Add New'</span>", labelIsHTML=1, checked=(ListFindNoCase(currentValues.interfaceOptions,'new')), labelClass="cs_dlgLabelSmall", onclick="#prefix#toggleInputField(this,'new');")#&nbsp;<br/></span>
				<span id="newOptionTextSpan" <cfif NOT ListFindNoCase(currentValues.interfaceOptions,'new')>style="display:none;padding-left:50px;"<cfelse>style="padding-left:50px;"</cfif>>Button Text:&nbsp;#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#newOptionText", name="#prefix#newOptionText", value="#currentValues.newOptionText#", size="30", class="InputControl")#<br/></span>
				<span id="existingOption">#Server.CommonSpot.udf.tag.checkboxRadio(type="checkbox", id="#prefix#interfaceOptionsCbox", name="#prefix#interfaceOptionsCbox", value="existing", label="<span id='addExistingOpt'>Allow 'Add Existing'</span>", labelIsHTML=1, checked=(ListFindNoCase(currentValues.interfaceOptions,'existing')), labelClass="cs_dlgLabelSmall", onclick="#prefix#toggleInputField(this,'existing');")#&nbsp;<br/></span>
				<span id="existingOptionTextSpan" <cfif NOT ListFindNoCase(currentValues.interfaceOptions,'existing')>style="display:none;padding-left:50px;"<cfelse>style="padding-left:50px;"</cfif>>Button Text:&nbsp;#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#existingOptionText", name="#prefix#existingOptionText", value="#currentValues.existingOptionText#", size="30", class="InputControl")#<br/></span>
				<span id="editAssocOption">#Server.CommonSpot.udf.tag.checkboxRadio(type="checkbox", id="#prefix#interfaceOptionsCbox", name="#prefix#interfaceOptionsCbox", value="editAssoc", label="<span id='editAssocOpt'>Allow 'Edit'</span>", labelIsHTML=1, checked=(ListFindNoCase(currentValues.interfaceOptions,'editAssoc')), labelClass="cs_dlgLabelSmall", onclick="#prefix#toggleInputField(this,'editAssoc');")#&nbsp;<br/></span>
				<span id="editAssocOptionTextSpan" <cfif NOT ListFindNoCase(currentValues.interfaceOptions,'editAssoc')>style="display:none;padding-left:50px;"<cfelse>style="padding-left:50px;"</cfif>>Hover Text:&nbsp;#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#editAssocOptionText", name="#prefix#editAssocOptionText", value="#currentValues.editAssocOptionText#", size="30", class="InputControl")#<br/></span>
				<span id="editChildOption" <cfif secondaryObj EQ "" OR selectedSecondaryCEType NEQ 'global'>style="display:none;"</cfif>>#Server.CommonSpot.udf.tag.checkboxRadio(type="checkbox", id="#prefix#interfaceOptionsCbox", name="#prefix#interfaceOptionsCbox", value="editChild", label="<span id='editChildOpt'>Allow 'Edit'</span>", labelIsHTML=1, checked=(ListFindNoCase(currentValues.interfaceOptions,'editChild')), labelClass="cs_dlgLabelSmall", onclick="#prefix#toggleInputField(this,'editChild');")#&nbsp;<br/></span>
				<span id="editChildOptionTextSpan" <cfif NOT ListFindNoCase(currentValues.interfaceOptions,'editChild')>style="display:none;padding-left:50px;"<cfelse>style="padding-left:50px;"</cfif>>Hover Text:&nbsp;#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#editChildOptionText", name="#prefix#editChildOptionText", value="#currentValues.editChildOptionText#", size="30", class="InputControl")#<br/></span>
				#Server.CommonSpot.udf.tag.checkboxRadio(type="checkbox", id="#prefix#interfaceOptionsCbox", name="#prefix#interfaceOptionsCbox", value="delete", label="<span id='deleteOpt'>Allow 'Delete'</span>", labelIsHTML=1, checked=(ListFindNoCase(currentValues.interfaceOptions,'delete')), labelClass="cs_dlgLabelSmall", onclick="#prefix#toggleInputField(this,'delete');")#&nbsp;<br/></span>
				<span id="deleteOptionTextSpan" <cfif NOT ListFindNoCase(currentValues.interfaceOptions,'delete')>style="display:none;padding-left:50px;"<cfelse>style="padding-left:50px;"</cfif>>Hover Text:&nbsp;#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#deleteOptionText", name="#prefix#deleteOptionText", value="#currentValues.deleteOptionText#", size="30", class="InputControl")#<br/></span>
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
			<td colspan="2" valign="baseline" class="cs_dlgLabel" nowrap="nowrap"><strong>#parentFormLabel#<br/><hr/></strong></td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Unique Field:</th>
			<td valign="baseline">
				<cfif dlgtype NEQ 'metadata'>
				<select name="#prefix#parentUniqueField" id="#prefix#parentUniqueField">
					<option value=""> - Select - </option>
					<cfloop query="selectedTypeFields">
						<option value="#selectedTypeFields.ID#" <cfif currentValues.parentUniqueField EQ selectedTypeFields.ID>selected</cfif>>#selectedTypeFields.Name#</option>
					</cfloop>
				</select>
				<cfelse>
					<span class="cs_dlgLabel">CommonSpot ID</span>
					#Server.CommonSpot.UDF.tag.input(type="hidden", name="#prefix#parentUniqueField", value="{{pageid}}")#
				</cfif>
			</td>
		</tr>
		<tr>
			<td colspan="2" valign="baseline" class="cs_dlgLabel" nowrap="nowrap"><strong><span id="childCENameSpan">#selectedJoinCEName#</span><br/><hr/></strong></td>
		</tr>
	</tbody>
	<tbody id="twoJoinInputs" <cfif joinObj EQ "" OR secondaryObj NEQ "">style="display:none;"</cfif>>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Unique Field:</th>
			<td valign="baseline">
				<select name="#prefix#joinUniqueField" id="#prefix#joinUniqueField">
				</select>
			</td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Linkage Field:</th>
			<td valign="baseline">
				<select name="#prefix#childLinkedField" id="#prefix#childLinkedField">
				</select>
			</td>
		</tr>
	</tbody>
	<tbody id="threeJoinInputs" <cfif secondaryObj EQ "">style="display:none;"</cfif>>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">#parentFormLabel# InstanceID Field:</th>
			<td valign="baseline">
				<select name="#prefix#parentInstanceIDField" id="#prefix#parentInstanceIDField">
				</select>
			</td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap"><span id="assocChildCENameSpan">#selectedSecondaryCEName#</span> InstanceID Field:</th>
			<td valign="baseline">
				<select name="#prefix#childInstanceIDField" id="#prefix#childInstanceIDField">
				</select>
			</td>
		</tr>
	</tbody>
	<tr id="inactiveFieldTr" <cfif NOT IsNumeric(joinObj)>style="display:none;"</cfif>>
		<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Inactive Field:</th>
		<td valign="baseline" nowrap="nowrap">
			<select name="#prefix#inactiveField" id="#prefix#inactiveField" onChange="#prefix#showInactiveValueFld()">
			</select>&nbsp;
			<span id="inactiveValueSpan" class="cs_dlgLabelBold"<cfif currentValues.inactiveField EQ ''>style="display:none;"</cfif>>Inactive Value:&nbsp;#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#inactiveFieldValue", name="#prefix#inactiveFieldValue", value="#currentValues.inactiveFieldValue#", size="10", class="InputControl")#</span>
		</td>
	</tr>
	<tbody id="secondaryElementInputs" <cfif secondaryObj EQ "">style="display:none;"</cfif>>
		<tr>
			<td colspan="2" valign="baseline" class="cs_dlgLabel" nowrap="nowrap"><strong><span id="assocCENameSpan">#selectedSecondaryCEName#</span><br/><hr/></strong></td>
		</tr>
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Unique Field:</th>
			<td valign="baseline">
				<select name="#prefix#secondaryUniqueField" id="#prefix#secondaryUniqueField">
				</select>
			</td>
		</tr>
	</tbody>
	<tr>
		<td class="cs_dlgLabelSmall" colspan="2" style="font-size:7pt;">
			<hr />
			ADF Custom Field v#fieldVersion#
		</td>
	</tr>
</table>
#Server.CommonSpot.UDF.tag.input(type="hidden", name="#prefix#displayFields", value=currentValues.displayFields)#
#Server.CommonSpot.UDF.tag.input(type="hidden", name="#prefix#assocCustomElement", value=secondaryObj)#
#Server.CommonSpot.UDF.tag.input(type="hidden", name="#prefix#childCustomElement", value=joinObj)#
#Server.CommonSpot.UDF.tag.input(type="hidden", name="#prefix#secondaryElementType", value=currentValues.secondaryElementType)#
#Server.CommonSpot.UDF.tag.input(type="hidden", name="#prefix#interfaceOptions", value=currentValues.interfaceOptions)#
#Server.CommonSpot.UDF.tag.input(type="hidden", name="#prefix#childUniqueField", value=currentValues.childUniqueField)#
</cfoutput>
<cfelse>
	<cfoutput><tr><td colspan="2"><span id="errorMsgSpan" class="cs_dlgError">This field type could be configured for custom elements and metadata forms only.</span></td></tr></cfoutput>
</cfif>
</cfif>