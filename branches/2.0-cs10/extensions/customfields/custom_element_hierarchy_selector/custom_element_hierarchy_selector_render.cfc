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
	Custom Element Hierarchy Selector
Name:
	custom_element_hierarchy_selector_render.cfm
Summary:
	This the render file for the Custom Element Hierarchy Selector field
ADF Requirements:
	
History:
	2014-01-16 - DJM - Created
	2014-01-29 - GAC - Converted to use AjaxProxy and the ADF Lib
	2014-02-27 - JTP - Updated the variable that is used in the validation message
	2014-04-03 - JTP - Made root node expand when initially opening
	2014-01-09 - GAC - Updated to load initially selected nodes until after the tree has completely loaded
	2015-04-10 - DJM - Converted to CFC
	2015-04-15 - DJM - Moved ADF renderer base and updated the extends parameter
--->
<cfcomponent displayName="CustomElementHierarchySelector Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="callingElement" type="string" required="yes">
	
	<cfscript>
		var allAtrs = getAllAttributes();
		var inputParameters = Duplicate(arguments.parameters);
		var uniqueTableAppend = arguments.fieldID;
		var ceFormID = arguments.formID;
		var customElementObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
		var ajaxBeanName = 'customElementHierarchySelector';
		var selectorObj = application.ADF[ajaxBeanName];
		var bMemory = 0;
		var errorMsgCustom = 'An error occurred while trying to perform the operation.';
		var resultCEData = ArrayNew(1);
		var widthVal = "400px";
		var heightVal = "200px";
		var fldCurValArray = ListToArray(arguments.value);
		var fldCurValWithFldID = '';
		var i = 0;
	</cfscript>
	
	<cfif arguments.displayMode neq "hidden">
		<cfscript>
			/*if (StructKeyExists(Request.Params, 'controlTypeID'))
					ceFormID = Request.Params.controlTypeID;
				else if (StructKeyExists(Request.Params, 'formID'))
					ceFormID = Request.Params.formID;
				else if (StructKeyExists(allAtrs, 'fields'))
					ceFormID = allAtrs.fields.formID[1];*/
			
			bMemory = selectorObj.isMemoryStructureGood(propertiesStruct=inputParameters,elementID=ceFormID,fieldID=arguments.fieldID);
			
			if (bMemory EQ 0)
				selectorObj.buildMemoryStructure(propertiesStruct=inputParameters,elementID=ceFormID,fieldID=arguments.fieldID);
			
			resultCEData = selectorObj.getFilteredData(propertiesStruct=inputParameters,currentValues=arguments.value,elementID=ceFormID,fieldID=arguments.fieldID);
			
			if (IsArray(resultCEData) AND ArrayLen(resultCEData) AND NOT IsSimpleValue(resultCEData[1]))
				errorMsgCustom = '';
			else if (ArrayLen(resultCEData) EQ 0)
				errorMsgCustom = 'No records found to be displayed for the field.';
			
			application.ADF.scripts.loadJQuery(noConflict=true);
			// Here we need to have a function call to load jsTree
			application.ADF.scripts.loadJSTree(loadStyles=false);
			
			// Set the width and height value
			if (IsNumeric(inputParameters.widthValue))
				widthVal = "#inputParameters.widthValue#px";
			
			if (IsNumeric(inputParameters.heightValue))
				heightVal = "#inputParameters.heightValue#px";
			
			// Prepend the current values with fieldID
			if (ArrayLen(fldCurValArray))
			{
				for (i=1; i LTE ArrayLen(fldCurValArray);i=i+1)
				{
					fldCurValWithFldID = ListAppend(fldCurValWithFldID, '#arguments.fieldID#_#fldCurValArray[i]#');
				}
			}
		</cfscript>
		<cfif inputParameters.customElement neq ''>
			<cfoutput>
				#selectorObj.renderStyles(propertiesStruct=inputParameters)#
				<span id="errorMsgSpan" class="cs_dlgError">#errorMsgCustom#</span>
				<cfif NOT Len(errorMsgCustom)>
					<div class="jstree-default-small" style="width:#widthVal#; height:#heightVal#; border:1px solid ##999999; overflow-y:scroll; background-color:white;" id="jstree_#arguments.fieldName#"></div>
				</cfif>
				<!-- hidden -->
				#Server.CommonSpot.UDF.tag.input(type="hidden", id="#arguments.fieldName#", name="#arguments.fieldName#", value="#arguments.value#")#
			</cfoutput>
		</cfif>
		
		<cfscript>
			if (NOT Len(errorMsgCustom))
				renderJSFunctions(argumentCollection=arguments, curFieldValueWithID=fldCurValWithFldID, dataResults=resultCEData);
		</cfscript>
	</cfif>

	<cfif arguments.displayMode neq "editable">
		<cfoutput>#Server.CommonSpot.UDF.tag.input(type="hidden", name=arguments.fieldName)#</cfoutput>
	</cfif>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="curFieldValueWithID" type="string" required="yes">
	<cfargument name="dataResults" type="array" required="yes">
	
	<cfscript>
		var inputParameters = Duplicate(arguments.parameters);
		var allAtrs = getAllAttributes();
		
		// Set the 'multiple' property
		var bMult = (inputParameters.selectionType EQ 'single') ? false : true;
		
		// Set the 'triState' property
		var triState = (inputParameters.selectionType EQ 'multiAuto') ? true : false;
		
		// Set the 'auto select parent' property
		var autoSelectParents = (inputParameters.selectionType EQ 'multiAutoParents') ? true : false;
	</cfscript>
	
<cfoutput><script type="text/javascript">
<!--
var #toScript(arguments.dataResults, "#arguments.fieldName#_jsResultCEData")#		

jQuery( function () {
	loadJSTreeData_#arguments.fieldName#();
});

function loadJSTreeData_#arguments.fieldName#()
{					
		jQuery('##jstree_#arguments.fieldName#').jstree({
			"core" : {
				"multiple" : #bMult#, 
				"themes" : { icons: false, variant: "small", responsive: false },
				"data" : #arguments.fieldName#_jsResultCEData,
			},

			"checkbox" : {
				"keep_selected_style" : false 
				,"three_state" : #triState#
				<cfif autoSelectParents> 
				,"cascade" : ""
				</cfif>
			},
			
			<cfif bMult>												
			"plugins" : [ "checkbox" ]
			</cfif>
		});
							
		// Load initially selected nodes for this tree
		loadInitialSelectedNodes_#arguments.fieldName#();
	
	/* MOVED TO TO ITS OWN FUNCTION - also updated to load after tree has complete loaded
		// set current selection
		var tmp = '#arguments.curFieldValueWithID#';
		if ( tmp != '' ) 
		{
			var arr = tmp.split(",");
	
			jQuery('##jstree_#arguments.fieldName#').jstree( "select_node", arr );
		
			for( var i=0; i < arr.length; i++ )
			{
				var node = arr[i];
				MakeOpen_#arguments.fieldName#(node);
			}			
		}
	
		jQuery('##jstree_#arguments.fieldName#').jstree( "open_node", '#fieldQuery.InputID#_#inputParameters.rootValue#' );
	*/ 
}

function loadInitialSelectedNodes_#arguments.fieldName#()
{
	// Wait until tree is loaded before loading the initial selection			
	jQuery('##jstree_#arguments.fieldName#').bind("loaded.jstree", function (e, data) {
		
		// set current selection
		var tmp = '#arguments.curFieldValueWithID#';
						
		if ( tmp != '' ) 
		{
			// convert string to array
			var arr = tmp.split(",");
			
			jQuery('##jstree_#arguments.fieldName#').jstree("select_node", arr , true); 
		}
		
		<cfif LEN(TRIM(inputParameters.rootValue))>
		jQuery('##jstree_#arguments.fieldName#').jstree( "open_node", '#fieldQuery.InputID#_#inputParameters.rootValue#' );		
		</cfif>
	});
}

jQuery('##jstree_#arguments.fieldName#').on("changed.jstree", function (e, data) 
{
	<cfif autoSelectParents> 
	// Selection Actions for Auto Select Parents
	if ( data.action == "select_node" ) 
	{
		CascadeUp_#arguments.fieldName#(jQuery(this),data.node, 'select_node');
	}
	else if ( data.action == "deselect_node" ) 
	{
		CascadeDown_#arguments.fieldName#(jQuery(this),data.node, 'deselect_node');
	}	
	</cfif>
	
	// Pass the selected Nodes to the CFT Hidden field
	setSelectedNodes_#arguments.fieldName#(data.selected);
});

// Add selected Items to the hidden field
function setSelectedNodes_#arguments.fieldName#(selectedNodesList)
{
	// Loop over values and remove the prefix from each value
	var selectedNodesArray = selectedNodesList.toString().split(",");
	var selectedNodesIDList = '';
	var fieldID = '#arguments.fieldID#';
	for (var valIndex=0; valIndex < selectedNodesArray.length; valIndex++)
	{
		var fieldIDIndex = selectedNodesArray[valIndex].indexOf('#arguments.fieldID#_');
		if (fieldIDIndex != -1)
			selectedNode = selectedNodesArray[valIndex].substr(fieldID.length + 1, selectedNodesArray[valIndex].length);
		else
			selectedNode = selectedNodesArray[valIndex];
			
		if (selectedNodesIDList.length)
			selectedNodesIDList += ',' + selectedNode;
		else
			selectedNodesIDList = selectedNode;
	}
	
	// Sort the NodeID list before adding them to the hidden field
	// - Sorting the node list allows items with the same selection to be grouped together
	selectedNodesIDList = sortNodeIDs_#arguments.fieldName#(selectedNodesIDList);
	
	jQuery('###arguments.fieldName#').val(selectedNodesIDList);
}

function MakeOpen_#arguments.fieldName#(node)
{
	var parent = 0;

	parent  = jQuery('##jstree_#arguments.fieldName#').jstree( "get_parent", node );
	
	if ( parent == false ) 
		return;
		
	if( parent != '##' )
	{
		jQuery('##jstree_#arguments.fieldName#').jstree( "open_node", parent );
		MakeOpen_#arguments.fieldName#(parent);
	}	
}

// Sort the IDs of the Nodes
function sortNodeIDs_#arguments.fieldName#(idList)
{
	var listIsNumeric = _isNumericList_#arguments.fieldName#(idList);
	var valuesArray = idList.split(",");
	
	if ( listIsNumeric )
	{
		// If the list has all numeric values sort the list as numbers
		valuesArray = valuesArray.sort(function(a,b){
			return a-b;
		});
	}
	else
	{
		// Use non-numeric / case-insenstive sort if the list has Alpha chars 
		valuesArray = valuesArray.sort(function (a, b) {
			return a.toLowerCase().localeCompare(b.toLowerCase());
		});          
	}
	return valuesArray.join(",");
}

// Determine if the list do not contain any Alpha values
function _isNumericList_#arguments.fieldName#(valuesList)
{
	var valuesArray = valuesList.split(",");
	var listItem = '';
	
	for ( var i=0; i < valuesArray.length; i++) 
	{
		listItem = valuesArray[i];
		if ( !jQuery.isNumeric(listItem) )
			return false;

	}   
	return true;
}

function GetParentNode_#arguments.fieldName#(inNode)
{
	var ParentNode = jQuery('##jstree_#arguments.fieldName#').jstree('get_parent', inNode);
	return ParentNode;
}

<cfif autoSelectParents> 
function CascadeUp_#arguments.fieldName#(treeObject,inNode,inCommand) {
	ParentNode = treeObject.jstree('get_parent', inNode);
	treeObject.jstree(inCommand, ParentNode);
	
}

function CascadeDown_#arguments.fieldName#(treeObject,inNode,inCommand) {
   ChildrenNodes = jQuery.makeArray(treeObject.jstree('get_children_dom', inNode));
   treeObject.jstree(inCommand, ChildrenNodes);
}
</cfif>
//-->
</script></cfoutput>
</cffunction>

<cfscript>
	private any function getValidationJS(required string formName, required string fieldName, required boolean isRequired)
	{
		if (arguments.isRequired)
			return 'hasValue(document.#arguments.formName#.#arguments.fieldName#, "TEXT")';
		return "";
	}
	
	private string function getValidationMsg()
	{
		return "Please select a value for the #arguments.label# field.";
	}
</cfscript>
</cfcomponent>