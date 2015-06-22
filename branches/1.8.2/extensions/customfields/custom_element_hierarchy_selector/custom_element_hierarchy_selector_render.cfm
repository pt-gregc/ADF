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
	custom_element_hierarchy_selector_render.cfm
Summary:
	This the render file for the Custom Element Hierarchy Selector field.
	
	The Custom Element Hierarchy Selector field provides an interface to display hierarchical data 
	that is stored in a single Global Custom Element. This Custom Element can be its own containing 
	Element or another Custom Element.
	
Documentation:
	http://community.paperthin.com/projects/ADF/docs/extensions/customfields/Custom-Element-Hierarchy-Selector.cfm
	
ADF Requirements:
	
History:
	2014-01-16 - DJM - Created
	2014-01-29 - GAC - Converted to use AjaxProxy and the ADF Lib
	2014-02-27 - JTP - Updated the variable that is used in the validation message
	2014-04-03 - JTP - Made root node expand when initially opening
	2014-01-09 - GAC - Updated to load initially selected nodes until after the tree has completely loaded
	2015-05-01 - GAC - Updated to add a forceScript parameter to bypass the ADF renderOnce script loader
	2015-06-19 - GAC - Update to add logic to set forceScript to true when in a CS page move 
--->

<cfscript>
	requiredVersion = 9;
	productVersion = ListFirst(ListLast(request.cp.productversion," "),".");
	
	// ADF Bean Name
	ajaxBeanName = 'customElementHierarchySelector';
</cfscript>

<cfparam name="attributes.callingElement" default="">

<!--- // Make sure we are on CommonSpot 9 or greater --->
<cfif productVersion LT requiredVersion>
	<cfscript>
		inputHTML = '<div class="cs_dlgLabelError">This Custom Field Type requires CommonSpot #requiredVersion# or above.</div>';
		includeLabel = true;
		includeDescription = false;
		if ( NOT StructKeyExists(variables,"fieldPermission") )
			variables.fieldPermission = "";
	</cfscript>
	<cfoutput>
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission,includeLabel,includeDescription)#
	</cfoutput>
<cfelse>
	<cfif attributes.rendermode eq 'label'>
		<cfoutput>#fieldlabel#</cfoutput>
		<cfexit>
	<cfelseif attributes.rendermode eq 'value'>
		<cfif fieldpermission gt 0>
			<cfoutput>#attributes.currentvalues[fqFieldName]#</cfoutput>
		</cfif>
		<cfexit>
	<cfelseif attributes.rendermode eq 'description'>
		<cfoutput>#fieldQuery.description#</cfoutput>
		<cfexit>
	</cfif>

	<cfif attributes.rendermode eq 'standard'>
		<!-------// output row_and_labelcell //------>
		<CFIF fieldpermission gt 0>
			<CFOUTPUT>#row_and_labelcell#</CFOUTPUT>
		<CFELSE>
			<CFOUTPUT><tr><td></td><td></CFOUTPUT>
		</CFIF>	
	</cfif>

	<CFIF fieldpermission eq 2 AND req eq 'yes'>
		<CFOUTPUT>
		<script type="text/javascript">
		<!--
				#fqFieldName# = new Object();
				#fqFieldName#.id = '#fqFieldName#';
				#fqFieldName#.tid = #rendertabindex#;
				#fqFieldName#.validator = "hasValue(document.#attributes.formname#.#fqFieldName#, 'TEXT')";
				#fqFieldName#.msg = "Please select a value for the #fieldlabel# field.";
				// push on to validation array
				vobjects_#attributes.formname#[vobjects_#attributes.formname#.length] = #fqFieldName#;
			// -->
		</script>
		</CFOUTPUT>
	</CFIF>
	
	<CFIF fieldpermission gt 0>	
		<CFSCRIPT>
			inputParameters = attributes.parameters[fieldQuery.inputID];
			uniqueTableAppend = fieldQuery.inputID;
		
			ceFormID = 0;
			if (StructKeyExists(Request.Params, 'controlTypeID'))
				ceFormID = Request.Params.controlTypeID;
			else if (StructKeyExists(Request.Params, 'formID'))
				ceFormID = Request.Params.formID;
			else if (StructKeyExists(attributes, 'fields'))
				ceFormID = attributes.fields.formID[1];
		
			customElementObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
			//selectorObj = CreateObject("component", "#componentPath#/custom_element_hierarchy_selector_base");
			selectorObj = application.ADF[ajaxBeanName];
			bMemory = selectorObj.isMemoryStructureGood(propertiesStruct=inputParameters,elementID=ceFormID,fieldID=fieldQuery.inputID);
			
			if (bMemory EQ 0)
				selectorObj.buildMemoryStructure(propertiesStruct=inputParameters,elementID=ceFormID,fieldID=fieldQuery.inputID);
			
			resultCEData = selectorObj.getFilteredData(propertiesStruct=inputParameters,currentValues=attributes.currentvalues[fqFieldName],elementID=ceFormID,fieldID=fieldQuery.inputID);
			
			errorMsgCustom = 'An error occurred while trying to perform the operation.';
			if (IsArray(resultCEData) AND ArrayLen(resultCEData) AND NOT IsSimpleValue(resultCEData[1]))
				errorMsgCustom = '';
			else if (ArrayLen(resultCEData) EQ 0)
				errorMsgCustom = 'No records found to be displayed for the field.';
			
			// Set the forceScripts parameter if it does not exist
			if ( !StructKeyExists(inputParameters,"forceScripts") )
				inputParameters.forceScripts = false;
			
			/* CS Page Move metadata form fix */
			// If we are in a metadata form and doing a Page Move then force the scripts to render
			if ( StructKeyExists(request.params,"actionType") AND request.params.actionType EQ 2 )
				inputParameters.forceScripts = true;
			
			application.ADF.scripts.loadJQuery(force=inputParameters.forceScripts,noConflict=true);	
			// Here we need to have a function call to load jsTree
			application.ADF.scripts.loadJSTree(force=inputParameters.forceScripts,loadStyles=false);
			
			// Set the width and height value
			widthVal = "400px";
			if (IsNumeric(inputParameters.widthValue))
				widthVal = "#inputParameters.widthValue#px";
			
			heightVal = "200px";
			if (IsNumeric(inputParameters.heightValue))
				heightVal = "#inputParameters.heightValue#px";
			
			// Set the 'multiple' property
			if (inputParameters.selectionType EQ 'single')
				bMult = false;
			else
				bMult = true;
			
			// Set the 'triState' property
			if (inputParameters.selectionType EQ 'multiAuto')
				triState = true;
			else
				triState = false;
			
			// Set the 'auto select parent' property (bMult: true, triState:false)	
			autoSelectParents = false;
			if ( inputParameters.selectionType EQ "multiAutoParents" )
			{
				bMult = true;
				triState = false;
				autoSelectParents = true;
			}
			
			
			// Prepend the current values with fieldID
			fldCurValArray = ListToArray(attributes.currentvalues[fqFieldName]);
			fldCurValWithFldID = '';
			if (ArrayLen(fldCurValArray))
			{
				for (i=1; i LTE ArrayLen(fldCurValArray);i=i+1)
				{
					fldCurValWithFldID = ListAppend(fldCurValWithFldID, '#fieldQuery.inputID#_#fldCurValArray[i]#');
				}
			}
		</CFSCRIPT>
		<CFIF inputParameters.customElement neq ''>
			<CFOUTPUT>
				<!--- #application.ADF.scripts.loadJSTree()# --->
				#selectorObj.renderStyles(propertiesStruct=inputParameters)#
				<span id="errorMsgSpan" class="cs_dlgError">#errorMsgCustom#</span>
				<cfif NOT Len(errorMsgCustom)>
					<div class="jstree-default-small" style="width:#widthVal#; height:#heightVal#; border:1px solid ##999999; overflow-y:scroll; background-color:white;" id="jstree_#fqFieldName#"></div>
				</cfif>
				<!-- hidden -->
				#Server.CommonSpot.UDF.tag.input(type="hidden", id="#fqFieldName#", name="#fqFieldName#", value="#attributes.currentvalues[fqFieldName]#")#
			</CFOUTPUT>
		</CFIF>
	</CFIF>

	<CFIF fieldpermission lt 2>
		<CFOUTPUT>#Server.CommonSpot.UDF.tag.input(type="hidden", name=fqFieldName)#</CFOUTPUT>
	</CFIF>

	<cfif attributes.rendermode eq 'standard'>
		<cfoutput></td></tr></cfoutput>
		<CFIF fieldpermission gt 0>
			<cfoutput>#description_row#</cfoutput>
		</CFIF>
	</cfif>
	
	<cfif fieldPermission gt 0 AND NOT Len(errorMsgCustom)>
		<cfoutput>
		<script type="text/javascript">
			<!--	
			var #toScript(resultCEData, "#fqFieldName#_jsResultCEData")#		

			jQuery( function () {
				loadJSTreeData_#fqFieldName#();
			});
			
			function loadJSTreeData_#fqFieldName#()
			{					
				    jQuery('##jstree_#fqFieldName#').jstree({
						"core" : {
							"multiple" : #bMult#, 
							"themes" : { icons: false, variant: "small", responsive: false },
							"data" : #fqFieldName#_jsResultCEData
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
					loadInitialSelectedNodes_#fqFieldName#();
				
				/* MOVED TO TO ITS OWN FUNCTION - also updated to load after tree has complete loaded
					// set current selection
					var tmp = '#fldCurValWithFldID#';
					if ( tmp != '' ) 
					{
						var arr = tmp.split(",");
				
						jQuery('##jstree_#fqFieldName#').jstree( "select_node", arr );
					
						for( var i=0; i < arr.length; i++ )
						{
							var node = arr[i];
							MakeOpen_#fqFieldName#(node);
						}			
					}
				
					jQuery('##jstree_#fqFieldName#').jstree( "open_node", '#fieldQuery.InputID#_#inputParameters.rootValue#' );
				*/ 
			}
			
			function loadInitialSelectedNodes_#fqFieldName#()
			{
				// Wait until tree is loaded before loading the initial selection			
				jQuery('##jstree_#fqFieldName#').bind("loaded.jstree", function (e, data) {
					
					// set current selection
					var tmp = '#fldCurValWithFldID#';
									
					if ( tmp != '' ) 
					{
						// convert string to array
						var arr = tmp.split(",");
						
						jQuery('##jstree_#fqFieldName#').jstree("select_node", arr , true); 
					}
					
					<cfif LEN(TRIM(inputParameters.rootValue))>
					jQuery('##jstree_#fqFieldName#').jstree( "open_node", '#fieldQuery.InputID#_#inputParameters.rootValue#' );		
        			</cfif>
				});
			}
			
			jQuery('##jstree_#fqFieldName#').on("changed.jstree", function (e, data) 
			{
				<cfif autoSelectParents> 
				// Selection Actions for Auto Select Parents
		    	if ( data.action == "select_node" ) 
		    	{
		        	CascadeUp_#fqFieldName#(jQuery(this),data.node, 'select_node');
			    }
				else if ( data.action == "deselect_node" ) 
				{
		        	CascadeDown_#fqFieldName#(jQuery(this),data.node, 'deselect_node');
		    	}	
				</cfif>
				
				// Pass the selected Nodes to the CFT Hidden field
				setSelectedNodes_#fqFieldName#(data.selected);
			});
			
			// Add selected Items to the hidden field
			function setSelectedNodes_#fqFieldName#(selectedNodesList)
			{
				// Loop over values and remove the prefix from each value
				var selectedNodesArray = selectedNodesList.toString().split(",");
				var selectedNodesIDList = '';
				var fieldID = '#fieldQuery.inputID#';
				for (var valIndex=0; valIndex < selectedNodesArray.length; valIndex++)
				{
					var fieldIDIndex = selectedNodesArray[valIndex].indexOf('#fieldQuery.inputID#_');
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
				selectedNodesIDList = sortNodeIDs_#fqFieldName#(selectedNodesIDList);
				
				jQuery('###fqFieldName#').val(selectedNodesIDList);
			}

			function MakeOpen_#fqFieldName#(node)
			{
				var parent = 0;
			
				parent  = jQuery('##jstree_#fqFieldName#').jstree( "get_parent", node );
				
				if ( parent == false ) 
					return;
					
				if( parent != '##' )
				{
					jQuery('##jstree_#fqFieldName#').jstree( "open_node", parent );
					MakeOpen_#fqFieldName#(parent);
				}	
			}
			
			// Sort the IDs of the Nodes
			function sortNodeIDs_#fqFieldName#(idList)
			{
		        var listIsNumeric = _isNumericList_#fqFieldName#(idList);
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
		    function _isNumericList_#fqFieldName#(valuesList)
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
			
			function GetParentNode_#fqFieldName#(inNode)
			{
				var ParentNode = jQuery('##jstree_#fqFieldName#').jstree('get_parent', inNode);
				return ParentNode;
			}
		    
			<cfif autoSelectParents> 
			function CascadeUp_#fqFieldName#(treeObject,inNode,inCommand) {
				ParentNode = treeObject.jstree('get_parent', inNode);
				treeObject.jstree(inCommand, ParentNode);
			    
			}

			function CascadeDown_#fqFieldName#(treeObject,inNode,inCommand) {
			   ChildrenNodes = jQuery.makeArray(treeObject.jstree('get_children_dom', inNode));
		       treeObject.jstree(inCommand, ChildrenNodes);
			}
			</cfif>
						
			// -->
		</script>
		</cfoutput>
	</cfif>
</cfif>
