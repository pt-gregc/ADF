<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc.  Copyright (c) 2009-2016.
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
	DB Hierarchy Selector
Name:
	db_hierarchy_selector_props.cfc
Summary:
	This the props file for the Custom Element Hierarchy Selector field
	
	The Custom Element Hierarchy Selector field provides an interface to display hierarchical data 
	that is stored in a single Global Custom Element. This Custom Element can be its own containing 
	Element or another Custom Element.
	

ADF Requirements:
	
History:
	2016-08-05 - GAC - Created

--->

<!--- // if this module loads resources, do it here.. --->
<cfscript>
	application.ADF.scripts.loadJQuery(noConflict=true);
</cfscript>

<!--- ... then exit if all we're doing is detecting required resources --->
<cfif Request.RenderState.RenderMode EQ "getResources">
  <cfexit>
</cfif>

<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "1.0.0";
	
	requiredVersion = 10;
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
	ajaxBeanName = 'dbHierarchySelector';

	if( not structKeyExists(currentValues, "datasource") )
		currentValues.datasource = "";
	if ( not structKeyExists(currentValues, "tablename") )
		currentValues.tablename = "";
	if( not structKeyExists(currentValues, "parentField") )
		currentValues.parentField = "";
	if( not structKeyExists(currentValues, "displayField") )
		currentValues.displayField = "";
	if( not structKeyExists(currentValues, "valueField") )
		currentValues.valueField = "";	
	if( not structKeyExists(currentValues, "activeField") )
		currentValues.activeField = "";	
	if( not structKeyExists(currentValues, "activeOperator") )
		currentValues.activeOperator = "=";	
	if( not structKeyExists(currentValues, "activeValue") )
		currentValues.activeValue = "";
	if( not structKeyExists(currentValues, "sortField") )
		currentValues.sortField = "";
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

	// Get Available CF DSNs
	allDSNdata = createobject("java","coldfusion.server.ServiceFactory").getDatasourceService().getNames();

	allTableData = QueryNew("Table_Name");
	allColumnsData = QueryNew("temp");
	activeColumnData = QueryNew("temp"); 
	
	showTableSectionControl = false;
	showChildControls = false;
	
	sqlOperatorList = "=,!=,<>,>,<,>=,<=,!<,!>";
	
	if ( LEN(TRIM(currentValues.datasource)) )
	{
		allTableData = application.ADF.dbHierarchySelector.getDBtables(dataSource=currentValues.datasource);
		showTableSectionControl = true;
//WriteDump(var=allTableData, expand=false);
	
		if ( LEN(TRIM(currentValues.tablename)) )
		{
			allColumnsData = application.ADF.dbHierarchySelector.getTableColumns(dataSource=currentValues.datasource,tableName=currentValues.tableName);
			showChildControls = true;
			
			/* if ( LEN(TRIM(currentValues.activeField)) )
			{
				activeColumnData = application.ADF.dbHierarchySelector.getActiveValues(dataSource=currentValues.datasource,tableName=currentValues.tableName,activeField=currentValues.activeField);
				writeDump(var=activeColumnData, expand=false);
			}*/
		}
//writeDump(var=allColumnsData, expand=false);
	}
	
	errorMsgCustom = 'An error occurred while trying to perform the operation.';
	
	/* 
		writeOutput("showTableSectionControl: ");
		writeDump(var=showTableSectionControl, expand=false);
		writeOutput("<br>");
		writeOutput("showChildControls: ");
		writeDump(var=showChildControls, expand=false);
		writeOutput("<br>");
	*/
	
	//writeDump(var=currentValues, expand=false);
	
	/* 
		if ( LEN(TRIM(currentValues.datasource)) AND
				LEN(TRIM(currentValues.tablename)) AND
				LEN(TRIM(currentValues.parentField)) AND
				LEN(TRIM(currentValues.activeField)) AND
				LEN(TRIM(currentValues.activeOperator)) AND
				LEN(TRIM(currentValues.activeValue)) )
		{
		
			treeData = application.ADF.dbHierarchySelector.getTreeData(
				dataSource=currentValues.datasource
				,tableName=currentValues.tablename 
				,parentField=currentValues.parentField
				,valueField=currentValues.valueField
				,displayField=currentValues.displayField
				,activeField=currentValues.activeField
				,activeOperator=currentValues.activeOperator
				,activeValue=currentValues.activeValue
				,sortField=currentValues.sortField 
			);
			writeDump(var=treeData, expand=false);
		}
	*/
</cfscript>

<cfsavecontent variable="cftDBhierarchyCSS">
<cfoutput>
<style>
	##tableInput {
		<cfif !showTableSectionControl>
		display: none;
		</cfif>
	}
	##childElementInputs {
		<cfif !showChildControls>
		display: none;
		</cfif>
	}
</style>
</cfoutput>
</cfsavecontent>

<cfsavecontent variable="cftDBhierarchyJS">
<cfoutput>
<script type="text/javascript">
<!--
	jQuery.noConflict();
	
	fieldProperties['#typeid#'].paramFields = "#prefix#datasource,#prefix#tablename,#prefix#parentField,#prefix#displayField,#prefix#valueField,#prefix#activeField,#prefix#activeOperator,#prefix#activeValue,#prefix#sortField,#prefix#selectionType,#prefix#widthValue,#prefix#rootValue,#prefix#rootNodeText,#prefix#heightValue,#prefix#cookieField,#prefix#filterCriteria,#prefix#useUdef";
	fieldProperties['#typeid#'].defaultValueField = '#prefix#defaultValue';
	fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';

	function #prefix#doValidate()
	{
		var isSelected = 0;
		if ( document.#formname#.#prefix#datasource.selectedIndex == 0 )
		{
			showMsg('Please select a datasource.');
			document.#formname#.#prefix#datasource.focus();
			return false;
		}
		if ( document.#formname#.#prefix#datasource.selectedIndex == 0 )
		{
			showMsg('Please select a table.');
			document.#formname#.#prefix#tablename.focus();
			return false;
		}
		if ( document.#formname#.#prefix#parentField.selectedIndex <= 0 )
		{
			showMsg('Please select a parent field from the table.');
			document.#formname#.#prefix#parentField.focus();
			return false;
		}
		if ( document.#formname#.#prefix#displayField.selectedIndex <= 0 )
		{
			showMsg('Please select a display field from the table.');
			document.#formname#.#prefix#displayField.focus();
			return false;
		}
		if ( document.#formname#.#prefix#valueField.selectedIndex <= 0 )
		{
			showMsg('Please select a value field from the table.');
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
		
		jQuery("###prefix#datasource").change(childOptionFunction);
		jQuery("###prefix#tablename").change(childOptionFunction);
		
	});
	
	childOptionFunction = function(){
		
		var selectedDSN = jQuery("option:selected",jQuery("###prefix#datasource")).val();
		var selectedChild = jQuery("option:selected",jQuery("###prefix#tablename")).val();
		
		jQuery("###prefix#parentField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#displayField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#valueField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#activeField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#activeOperator").val('');
		//jQuery("###prefix#activeValue").children().remove().end().append("<option value=\"\"> - Select -</option>");
		jQuery("###prefix#activeValue").val('');
		jQuery("###prefix#sortField").children().remove().end().append("<option value=\"\"> - Select -</option>");
		
		if (selectedDSN == "")
		{
			jQuery("##tableInput").hide();
			return;
		}
		else
		{
			jQuery("##tableInput").show();
			
			/* -- Updated to use AjaxProxy -- */
			jQuery.getJSON("#ajaxComURL#?bean=#ajaxBeanName#&method=getDBtables&query2array=0&returnformat=json",{"dataSource":selectedDSN})
			.done(function(retData) {
			
				// Convert the Data from the AjaxProxy to CF Object
				var res = #prefix#convertAjaxProxyObj2CFqueryObj(retData);
//console.log(res);

				if (res.COLUMNS[0] != 'ERRORMSG')
				{
					var allOptions = "";
					var columnMap = {};
					for (var i = 0; i < res.COLUMNS.length; i++) {
						columnMap[res.COLUMNS[i]] = i;
					}
//console.log(columnMap);
					
					for (var i=0; i<res.DATA.length; i++) {
						//In our result, ID is what we will use for the value, and NAME for the label
						allOptions += "<option value=\"" + res.DATA[i][columnMap.TABLE_NAME] + "\">" + res.DATA[i][columnMap.TABLE_NAME] + "</option>";
//console.log(allOptions);	
					}
					jQuery("###prefix#tablename").children().end().append(allOptions);
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
		
		if (selectedChild == "")
		{
			jQuery("##childElementInputs").hide();
			//document.getElementById('childElementInputs').style.display = "none";
			return;
		}
		else
		{
			jQuery("##childElementInputs").show();
			//document.getElementById('childElementInputs').style.display = "";

			/* -- Updated to use AjaxProxy -- */
			jQuery.getJSON("#ajaxComURL#?bean=#ajaxBeanName#&method=getTableColumns&query2array=0&returnformat=json",{"dataSource":selectedDSN,"tableName":selectedChild})
			.done(function(retData) {
			
				// Convert the Data from the AjaxProxy to CF Object
				var res = #prefix#convertAjaxProxyObj2CFqueryObj(retData);
			
				if (res.COLUMNS[0] != 'ERRORMSG')
				{
					var allOptions = "";
					var columnMap = {};
					
					for (var i = 0; i < res.COLUMNS.length; i++) {
						columnMap[res.COLUMNS[i]] = i;
					}
					
					for (var i=0; i<res.DATA.length; i++) {
						//In our result, ID is what we will use for the value, and NAME for the label
						allOptions += "<option value=\"" + res.DATA[i][columnMap.COLUMN_NAME] + "\">" + res.DATA[i][columnMap.COLUMN_NAME] + "</option>";
					}
					
					jQuery("###prefix#parentField").children().end().append(allOptions);
					jQuery("###prefix#displayField").children().end().append(allOptions);
					jQuery("###prefix#valueField").children().end().append(allOptions);
					jQuery("###prefix#activeField").children().end().append(allOptions);
					jQuery("###prefix#sortField").children().end().append(allOptions);					
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
// -->
</script>
</cfoutput>
</cfsavecontent>

<cfscript>
	application.ADF.scripts.addHeaderCSS(cftDBhierarchyCSS,"SECONDARY");
	application.ADF.scripts.addFooterJS(cftDBhierarchyJS,"SECONDARY");
</cfscript>

<cfoutput>
<table border="0" cellpadding="3" cellspacing="0" width="100%" summary="">
	<tr>
		<td colspan="2"><span id="errorMsgSpan" class="cs_dlgError"></span></td>
	</tr>
	
	<tr id="datasourceInput">
		<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Datasource:</th>
		<td valign="baseline">
			<select id="#prefix#datasource" name="#prefix#datasource" size="1">
				<option value=""> - Select - </option>
				<cfloop array="#allDSNdata#" index="Name">
					<option value="#Name#" <cfif currentValues.datasource EQ Name>selected</cfif>>#Name#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	
	<tr id="tableInput">
		<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Table:</th>
		<td valign="baseline">
			<select id="#prefix#tablename" name="#prefix#tablename" size="1">
				<option value=""> - Select - </option>
				<cfloop query="#allTableData#">
					<option value="#allTableData.Table_Name#" <cfif currentValues.tablename EQ allTableData.Table_Name>selected</cfif>>#allTableData.Table_Name#</option>
				</cfloop>
			</select>
		</td>
	</tr>
		
	<tbody id="childElementInputs">
			
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Parent Column:</th>
			<td valign="baseline">
				<select name="#prefix#parentField" id="#prefix#parentField">
					<option value=""> - Select - </option>
						<cfloop query="allColumnsData">
						<option value="#allColumnsData.COLUMN_NAME#" <cfif currentValues.parentField EQ allColumnsData.COLUMN_NAME>selected</cfif>>#allColumnsData.COLUMN_NAME#</option>
					</cfloop>
				</select>
				<br />
				<div class="cs_dlgLabelSmall">Select the column used to indicate the parent node.</div>
			</td>
		</tr>
		
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Value Column:</th>
			<td valign="baseline">
				<select name="#prefix#valueField" id="#prefix#valueField">
					<option value=""> - Select - </option>
					<cfloop query="allColumnsData">
						<option value="#allColumnsData.COLUMN_NAME#" <cfif currentValues.valueField EQ allColumnsData.COLUMN_NAME>selected</cfif>>#allColumnsData.COLUMN_NAME#</option>
					</cfloop>
				</select>
				<br />
				<div class="cs_dlgLabelSmall">Select the column whose value will be stored when the node is selected.</div>
			</td>
		</tr>
		
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Display Column:</th>
			<td valign="baseline">
				<select name="#prefix#displayField" id="#prefix#displayField">
					<option value=""> - Select - </option>
					<option value=""> - Select - </option>
						<cfloop query="allColumnsData">
						<option value="#allColumnsData.COLUMN_NAME#" <cfif currentValues.displayField EQ allColumnsData.COLUMN_NAME>selected</cfif>>#allColumnsData.COLUMN_NAME#</option>
					</cfloop>
				</select>
				<br />
				<div class="cs_dlgLabelSmall">Select the column to display in the selection tree.</div>
			</td>
		</tr>
			
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Active Criteria:</th>
			<td valign="baseline">
				<select name="#prefix#activeField" id="#prefix#activeField">
					<option value=""> - Select - </option>
					<cfloop query="allColumnsData">
						<option value="#allColumnsData.COLUMN_NAME#" <cfif currentValues.activeField EQ allColumnsData.COLUMN_NAME>selected</cfif>>#allColumnsData.COLUMN_NAME#</option>
					</cfloop>
				</select>
				&nbsp;
				<select name="#prefix#activeOperator" id="#prefix#activeOperator">
					<option value=""> - Select - </option>
					<cfloop list="#sqlOperatorList#" index="op">
						<option value="#op#"<cfif currentValues.activeOperator EQ op>selected</cfif>>#op#</option>
					</cfloop>
				</select>
				&nbsp;
				#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#activeValue", name="#prefix#activeValue", value="#currentValues.activeValue#", size="5", class="InputControl", style="text-align: right;")#
				<br />
				<div class="cs_dlgLabelSmall">Select the column, operator and value that will be used to filter active records.</div>
			</td>
		</tr>
	
		<!--- // activeOperator --->
		<!--- <tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Active Operator:</th>
			<td valign="baseline" class="cs_dlgLabelSmall">
				<select name="#prefix#activeOperator" id="#prefix#activeOperator">
					<cfloop list="=,!=,>,<,>=,<=" index="i">
						<option value="#i#"<cfif currentValues.activeOperator EQ i>selected</cfif>>#i#</option>
					</cfloop>
				</select>
			</td>
		</tr>	--->
		
		<!--- // activeValue --->
		<!--- <tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Active Value:</th>
			<td valign="baseline" class="cs_dlgLabelSmall">
				<!--- <cfif LEN(TRIM(currentValues.activeField))>
					<select name="#prefix#activeValue" id="#prefix#activeValue">
						<option value=""> - Select - </option>
						<cfloop query="activeColumnData">
							<option value="#activeColumnData[currentValues.activeField]#"<cfif currentValues.activeValue EQ activeColumnData[currentValues.activeField]>selected</cfif>>#activeColumnData[currentValues.activeField]#</option>
						</cfloop>
					</select>
				<cfelse>
				</cfif> --->
				#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#activeValue", name="#prefix#activeValue", value="#currentValues.activeValue#", size="5", class="InputControl", style="text-align: right;")#
			</td>
		</tr>	--->
		
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Sort Column:</th>
			<td valign="baseline">
				<select name="#prefix#sortField" id="#prefix#sortField">
					<option value=""> - Select - </option>
					<cfloop query="allColumnsData">
						<option value="#allColumnsData.COLUMN_NAME#" <cfif currentValues.sortField EQ allColumnsData.COLUMN_NAME>selected</cfif>>#allColumnsData.COLUMN_NAME#</option>
					</cfloop>
				</select>
				<br />
				<div class="cs_dlgLabelSmall">Select the sort column.</div>
			</td>
		</tr>
		
		<tr>
			<td valign="baseline" colspan=2><hr /></td>
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
			<td valign="baseline" class="cs_dlgLabelSmall">
				#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#widthValue", name="#prefix#widthValue", value="#currentValues.widthValue#", size="5", class="InputControl", style="text-align: right;")#px
			</td>
		</tr>	
		
		<tr>
			<th valign="baseline" class="cs_dlgLabelBold" nowrap="nowrap">Height:</th>
			<td valign="baseline" class="cs_dlgLabelSmall">
				#Server.CommonSpot.udf.tag.input(type="text", id="#prefix#heightValue", name="#prefix#heightValue", value="#currentValues.heightValue#", size="5", class="InputControl", style="text-align: right;")#px
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