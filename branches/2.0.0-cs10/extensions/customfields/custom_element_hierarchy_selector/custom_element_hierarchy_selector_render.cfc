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
	Custom Element Hierarchy Selector
Name:
	custom_element_hierarchy_selector_render.cfc
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
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean()
	2016-01-06 - GAC - Added a isMultiline() call so the label renders at the top
	                 - Added getMinWidth() and getMinHeight()
   2016-02-09 - JTP - Put back duplicate and added structKeyExists
   2016-02-09 - GAC - Updated duplicateBean() to use data_2_0.duplicateStruct()
	2016-02-18 - DRM - Handle readonly mode
							 Highlight root node if selected node is a direct child of it (single select mode only)
							 Add loadResourceDependencies() support
							 Break getting data and selectorObject out into their own methods
							 Don't duplicate arguments.parameters, just use it, other minor cleanup
	2016-02-19 - DRM - Move more default styling into custom_element_hierarchy_selector_styles.css
							 Add styling there for .jstree-disabled on parent div, remove ad hoc js for that
							 Rename disableJSTree to jsTreeDisable, add possible TODOs for it
							 Remove duplicate hidden field in some situations
--->
<cfcomponent displayName="CustomElementHierarchySelector Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">

	<cfscript>
		var params = arguments.parameters;
		var customElementObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
		var selectorObj = getSelectorObj();
		var errorMsgCustom = 'An error occurred while trying to perform the operation.';
		var resultCEData = ArrayNew(1);
		var widthVal = "400px";
		var heightVal = "200px";
		var fldCurValArray = ListToArray(arguments.value);
		var fldCurValWithFldID = '';
		var i = 0;

		params.rootValue = trim(params.rootValue);
	</cfscript>
	
	<cfif arguments.displayMode neq "hidden">
		<cfscript>
			resultCEData = getData(propertiesStruct=params, elementID=arguments.formID, fieldID=arguments.fieldID, value=arguments.value);
			
			if (IsArray(resultCEData) AND ArrayLen(resultCEData) AND NOT IsSimpleValue(resultCEData[1]))
				errorMsgCustom = '';
			else if (ArrayLen(resultCEData) EQ 0)
				errorMsgCustom = 'No records found to be displayed for the field.';
			
			// Set the width and height value
			if (StructKeyExists(params,'widthValue') AND IsNumeric(params.widthValue))
				widthVal = "#params.widthValue#px";
			
			if (StructKeyExists(params,'heightValue') AND IsNumeric(params.heightValue))
				heightVal = "#params.heightValue#px";
			
			// Prepend the current values with fieldID
			if (ArrayLen(fldCurValArray))
			{
				for (i=1; i LTE ArrayLen(fldCurValArray);i=i+1)
				{
					fldCurValWithFldID = ListAppend(fldCurValWithFldID, '#arguments.fieldID#_#fldCurValArray[i]#');
				}
			}
		</cfscript>

		<cfif structKeyExists(params,"customElement") and (params.customElement neq '')>
			<cfoutput>
				#selectorObj.renderStyles(propertiesStruct=params)#
				<span id="errorMsgSpan" class="cs_dlgError">#errorMsgCustom#</span>
				<cfif NOT Len(errorMsgCustom)>
					<div class="jstree-default-small" style="width:#widthVal#; height:#heightVal#;" id="jstree_#arguments.fieldName#"></div>
				</cfif>
			</cfoutput>
		</cfif>
		
		<cfscript>
			if (NOT Len(errorMsgCustom))
				renderJSFunctions(argumentCollection=arguments, curFieldValueWithID=fldCurValWithFldID, dataResults=resultCEData);
		</cfscript>
	</cfif>

	<cfoutput>#Server.CommonSpot.UDF.tag.input(type="hidden", id="#arguments.fieldName#", name="#arguments.fieldName#", value="#arguments.value#")#</cfoutput>
</cffunction>


<cfscript>
	private array function getData(required struct propertiesStruct, required numeric elementID, required numeric fieldID, required string value)
	{
		var data = [];
		var selectorObj = getSelectorObj();
		var isInMemory = selectorObj.isMemoryStructureGood(propertiesStruct=arguments.propertiesStruct, elementID=arguments.elementID, fieldID=arguments.fieldID);
		if (isInMemory == 0)
			selectorObj.buildMemoryStructure(propertiesStruct=arguments.propertiesStruct, elementID=arguments.elementID, fieldID=arguments.fieldID);
		data = selectorObj.getFilteredData(propertiesStruct=arguments.propertiesStruct, elementID=arguments.elementID, fieldID=arguments.fieldID, currentValues=arguments.value);
		return data;
	}

	private any function getSelectorObj()
	{
		var ajaxBeanName = 'customElementHierarchySelector';
		var selectorObj = application.ADF[ajaxBeanName];
		return selectorObj;
	}
</cfscript>


<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="curFieldValueWithID" type="string" required="yes">
	<cfargument name="dataResults" type="array" required="yes">
	
	<cfscript>
		var params =  arguments.parameters;
		
		// Set the 'multiple' property
		var bMult = (params.selectionType EQ 'single') ? false : true;
		
		// Set the 'triState' property
		var triState = (params.selectionType EQ 'multiAuto') ? true : false;
		
		// Set the 'auto select parent' property
		var autoSelectParents = (params.selectionType EQ 'multiAutoParents') ? true : false;
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
		}

		<cfif bMult>
		, "plugins" : [ "checkbox" ]
		</cfif>
	});

	// Load initially selected nodes for this tree
	loadInitialSelectedNodes_#arguments.fieldName#();
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
			
			jQuery('##jstree_#arguments.fieldName#').jstree("select_node", arr, true);
		}
		
		<cfif params.rootValue neq "">
		jQuery('##jstree_#arguments.fieldName#').jstree( "open_node", '#fieldQuery.InputID#_#params.rootValue#' );		
		</cfif>

		<!---
			arguments.value is the ParentID; this tests if the current node is a child of the root node, and highlighting it if so, like happens in other cases
			TODO: handle this in multi-select mode
		--->
		<cfif arguments.value eq params.rootValue>
		jQuery('.jstree-anchor').addClass('jstree-clicked'); // so root node is highlighted w/o opening
		</cfif>

		<cfif arguments.displayMode eq "readonly">
		jsTreeDisable('##jstree_#arguments.fieldName#');
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
	var parent = jQuery('##jstree_#arguments.fieldName#').jstree( "get_parent", node);
	if (!parent)
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

function jsTreeDisable(treeSelector)
{
	// disable nodes
	jQuery(treeSelector + ' .jstree-anchor').each( function() {
   	jQuery(treeSelector).jstree().disable_node(this.id);
	});

	// disable open-close btns
	jQuery(treeSelector + ' .jstree-ocl')
		.off('click.block')
		.on('click.block', function() {
		return false;
	});

	// disable dbl click open-close
	jQuery(treeSelector).jstree().settings.core.dblclick_toggle = false;

	// set jstree-disabled class on whole tree div
	jQuery(treeSelector).addClass('jstree-disabled');

	/*
		TODO: disable context menu, drag and drop
			for possible implementations, see http://stackoverflow.com/questions/34883409/disable-the-whole-jstree/35057572##answer-35410583
		TODO: ideally this would be a jsTree plugin
	*/
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


	public void function loadResourceDependencies()
	{
		application.ADF.scripts.loadJQuery(noConflict=true);
		application.ADF.scripts.loadJSTree(loadStyles=false);
	}
	public string function getResourceDependencies()
	{
		return listAppend(super.getResourceDependencies(), "jQuery,JSTree");
	}


	// Requires a Build of CommonSpot 10 higher than 10.0.0.313
	public numeric function getMinHeight()
	{
		if (structKeyExists(arguments.parameters, "heightValue") && isNumeric(arguments.parameters.heightValue) && arguments.parameters.heightValue > 0)
			return arguments.parameters.heightValue; // always px
		return 0;
	}
	
	// Requires a Build of CommonSpot 10 higher than 10.0.0.313
	public numeric function getMinWidth()
	{
		if ( structKeyExists(arguments.parameters, "widthValue") && isNumeric(arguments.parameters.widthValue) && arguments.parameters.widthValue > 0)
			return arguments.parameters.widthValue + 160; // 150 is default label width, plus some slack // always px
		return 0;
	}

	private boolean function isMultiline()
	{
		return true;
	}
</cfscript>
</cfcomponent>