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
	2016-08-05 - GAC - Created

--->
<cfcomponent displayName="CustomElementHierarchySelector Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">

	<cfscript>
		var params = arguments.parameters;
		var selectorObj = getSelectorObj();
		var errorMsgCustom = 'An error occurred while trying to perform the operation.';
		var resultCEData = ArrayNew(1);
		var widthVal = "400px";
		var heightVal = "200px";
		var fldCurValArray = ListToArray(arguments.value);
		var fldCurValWithFldID = '';
		var i = 0;

		params.rootValue = trim(params.rootValue);
		
		//WriteDump(var=Params,expand=false);
		//WriteDump(var=application.dbHierarchyCustomField,expand=false);
	</cfscript>
	
	<cfif arguments.displayMode neq "hidden">
		<cfscript>
			resultCEData = getData(propertiesStruct=params, elementID=arguments.formID, fieldID=arguments.fieldID, value=arguments.value);
			
			if ( IsArray(resultCEData) AND ArrayLen(resultCEData) AND NOT IsSimpleValue(resultCEData[1]) )
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

		<cfif structKeyExists(params,"datasource") AND (params.datasource neq '')
				AND structKeyExists(params,"tablename") AND (params.tablename neq '')>
			<cfoutput>
				#selectorObj.renderStyles(propertiesStruct=params)#
				<!--- NOT NEEDED AT THIS TIME
					// HACK to stop parent nodes from being selected 
					// !! NOT FINAL SOLUTION !!
					<style>
						/* Hide parent nodes' checkbox */
						/* https://groups.google.com/d/msg/jstree/TqK2OzDv0qg/iYNDjdNFqeoJ */
						##jstree_#arguments.fieldName# .jstree-open > .jstree-anchor > .jstree-checkbox, 
						##jstree_#arguments.fieldName# .jstree-closed > .jstree-anchor > .jstree-checkbox { display:none; }
					</style> --->
				<span id="errorMsgSpan" class="cs_dlgError">#errorMsgCustom#</span>
				<cfif NOT Len(errorMsgCustom)>
					<div style="float:right; display:inline-block";">
						<input type="search" value="" class="" style="box-shadow:inset 0 0 4px ##eee; width:200px; margin:0 0 4px; padding:6px 12px; border-radius:4px; border:1px solid silver; font-size:0.9em;" id="jstree_search_#arguments.fieldName#" placeholder="Search" />
						<!--- <i id="jstree_searchclear_#arguments.fieldName#" class="fa fa-times-circle"></i> --->
					</div>
					<div class="jstree-default-small" style="width:#widthVal#; height:#heightVal#;" id="jstree_#arguments.fieldName#"></div>
					<!--- <div style="float:right; margin:4px 0 0 0; font-size:0.9em;"><a></a></div> --->
					<div style="text-align: right; font-size:xx-small;">
						<cfif params.selectionType NEQ 'single'>
							<div style="display:inline-block" id="jstree_select_all_#arguments.fieldName#"><a href="javascript:;">Select All</a></div>&nbsp;
							<div style="display:inline-block" id="jstree_deselect_all_#arguments.fieldName#"><a href="javascript:;">Deselect All</a></div>
						<cfelseif !params.req>
							<div style="display:inline-block" id="jstree_deselect_#arguments.fieldName#"><a href="javascript:;">Deselect</a></div>
						</cfif>
					</div>
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
		
		//var isInMemory = selectorObj.isMemoryStructureGood(propertiesStruct=arguments.propertiesStruct, elementID=arguments.elementID, fieldID=arguments.fieldID);
		//if (isInMemory == 0)
			selectorObj.buildMemoryStructure(propertiesStruct=arguments.propertiesStruct, elementID=arguments.elementID, fieldID=arguments.fieldID);
		
		data = selectorObj.getFilteredData(propertiesStruct=arguments.propertiesStruct, elementID=arguments.elementID, fieldID=arguments.fieldID, currentValues=arguments.value);
//writeDump(var=data, expand=false);

		return data;
	}

	private any function getSelectorObj()
	{
		var ajaxBeanName = 'dbHierarchySelector';
		var selectorObj = application.ADF[ajaxBeanName];
		return selectorObj;
	}
</cfscript>

<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		
		// Set the defaults
		if ( NOT StructKeyExists(inputParameters,"datasource") OR !LEN(TRIM(inputParameters.datasource)) )
			inputParameters.datasource = "";
			
		//if( NOT StructKeyExists(inputParameters,"widthValue") OR NOT IsNumeric(inputParameters.widthValue) )
		//	inputParameters.widthValue = "200";
		
		//if( NOT StructKeyExists(inputParameters,"heightValue") OR NOT IsNumeric(inputParameters.heightValue) )
		//	inputParameters.heightValue = "150";
		
		return inputParameters;
	</cfscript>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="curFieldValueWithID" type="string" required="yes">
	<cfargument name="dataResults" type="array" required="yes">
	
	<cfscript>
		var params =  arguments.parameters;
		var cftDBhierarchyJS = '';
		
		// Set the 'multiple' property
		var bMult = (params.selectionType EQ 'single') ? false : true;
		
		// Set the 'triState' property
		var triState = (params.selectionType EQ 'multiAuto') ? true : false;
		
		// Set the 'auto select parent' property
		var autoSelectParents = (params.selectionType EQ 'multiAutoParents') ? true : false;
	</cfscript>

<cfsavecontent variable="cftDBhierarchyJS"><cfoutput>
<script type="text/javascript">
<!--
var #toScript(arguments.dataResults, "#arguments.fieldName#_jsResultCEData")#		

jQuery( function () {
	
	loadJSTreeData_#arguments.fieldName#();
	
	// Init Search Variable
	var to_#arguments.fieldName# = false;
	
	// Search
	jQuery('##jstree_search_#arguments.fieldName#').keyup(function () {
		if(to_#arguments.fieldName#) { clearTimeout(to_#arguments.fieldName#); }
		to_#arguments.fieldName# = setTimeout(function () {
				var v = jQuery('##jstree_search_#arguments.fieldName#').val();
				jQuery('##jstree_#arguments.fieldName#').jstree(true).search(v);
		}, 250);
	});
	
	/*jQuery("##jstree_searchclear_#arguments.fieldName#").click(function(){
	    jQuery('##jstree_search_#arguments.fieldName#').val('');
	});*/
	
	<cfif params.selectionType NEQ 'single'>
		//check all checkboxes button click handler
		jQuery("##jstree_select_all_#arguments.fieldName#").click( function() {	
				jQuery('##jstree_#arguments.fieldName#').jstree("check_all");
		});
	
		//uncheck all checkboxes button click handler
		jQuery("##jstree_deselect_all_#arguments.fieldName#").click( function() {
				jQuery('##jstree_#arguments.fieldName#').jstree("uncheck_all");
		});
	<cfelseif !params.req>
		// deselected the selected node button click handler
		jQuery("##jstree_deselect_#arguments.fieldName#").click( function() {
				jQuery('###arguments.fieldName#').val('');
				jQuery('##jstree_#arguments.fieldName# .jstree-anchor').removeClass('jstree-clicked');
		});
	</cfif>
	
	
	
	<!--- !!! THIS CODE IS NOT NEEDED !!! THIS HAS BEEN RESOLVED - gac 9/2/2016--->
	<!--- // HACK to stop parent nodes from being selected 
		// !! NOT FINAL SOLUTION !!
		// http://stackoverflow.com/questions/24480791/jstree-disable-selection-on-a-parent-node-but-allow-expansion-on-click
		/* jQuery('##jstree_#arguments.fieldName#').on('select_node.jstree', function (e, data) {
				if (data.node.children.length > 0) {
					 jQuery('##jstree_#arguments.fieldName#').jstree(true).deselect_node(data.node);
					 // needs IF logic so if parent node is already open... it is not closed
					 //jQuery('##jstree_#arguments.fieldName#').jstree(true).toggle_node(data.node);
				}
		  });*/
	  --->
	
});

function loadJSTreeData_#arguments.fieldName#()
{					
	jQuery('##jstree_#arguments.fieldName#').jstree({
		"core" : {
			"multiple" : #bMult#
			,"themes" : { icons: false, variant: "small", responsive: false }
			,"data" : #arguments.fieldName#_jsResultCEData
		},

		"checkbox" : {
			"keep_selected_style" : false
			,"three_state" : #triState#
			<cfif autoSelectParents>
			,"cascade" : ""
			</cfif>
		}

		<cfif bMult>
		, "plugins" : [ "checkbox", "search" ]
		<cfelse>
		, "plugins" : [ "search" ]
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
		
		<!--- // Updated to expand first node of tree is rootNodeText is defined --->		
		<cfif LEN(TRIM(params.rootNodeText))>
			<cfif LEN(TRIM(params.rootValue)) EQ 0>
				jQuery('##jstree_#arguments.fieldName#').jstree( "open_node", '#arguments.fieldID#__anchor' );
			<cfelse>
				jQuery('##jstree_#arguments.fieldName#').jstree( "open_node", '#arguments.fieldID#_#params.rootValue#' );		
			</cfif>
		</cfif>
		
		<!--- !!! THIS CODE FOR SELECTING ROOTNODES IS NOT NEEDED!!! THIS HAS BEEN RESOLVED - gac 9/2/2016 --->
		<!---
			arguments.value is the ParentID; this tests if the current node is a child of the root node, and highlighting it if so, like happens in other cases
			TODO: handle this in multi-select mode
				
		<cfif !bMult AND arguments.value eq params.rootValue >
		jQuery('.jstree-anchor').addClass('jstree-clicked'); // so root node is highlighted w/o opening
		</cfif>
		--->

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
</cfsavecontent>

<cfscript>
	application.ADF.scripts.addFooterJS(cftDBhierarchyJS,"SECONDARY");
</cfscript>

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
		//application.ADF.scripts.loadFontAwesome();
	}
	public string function getResourceDependencies()
	{
		return listAppend(super.getResourceDependencies(), "jQuery,JSTree");
		//return listAppend(super.getResourceDependencies(), "jQuery,JSTree,FontAwesome");
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