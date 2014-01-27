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
	custom_element_hierarchy_selector_render.cfc
Summary:
	This the render file for the Custom Element Hierarchy Selector field
ADF Requirements:
	
History:
	2014-01-16 - DJM - Created
--->

<cfscript>
	requiredVersion = 9;
	productVersion = ListFirst(ListLast(request.cp.productversion," "),".");
	
	// Path to this CFT
	cftPath = "/ADF/extensions/customfields/custom_element_hierarchy_selector";
	// Path to proxy component in the context of the site
	componentPath = "#request.site.csAppsURL#components";
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
		<CFOUTPUT><CFIF fieldpermission gt 0>#row_and_labelcell#<CFELSE><tr><td></td><td></CFIF></CFOUTPUT>
	</cfif>
	
	<CFIF fieldpermission eq 2>
		<CFOUTPUT>
		<script type="text/javascript">
		<!--
		</CFOUTPUT>
			<CFIF req eq 'yes'>
				<cfoutput>
				#fqFieldName# = new Object();
				#fqFieldName#.id = '#fqFieldName#';
				#fqFieldName#.tid = #rendertabindex#;
				#fqFieldName#.validator = "hasValue(document.#attributes.formname#.#fqFieldName#, 'TEXT')";
				#fqFieldName#.msg = "Please select a value for the #xparams.label# field.";
				// push on to validation array
				vobjects_#attributes.formname#[vobjects_#attributes.formname#.length] = #fqFieldName#;
				</CFOUTPUT>
			</CFIF>
			<CFOUTPUT>
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
			selectorObj = CreateObject("component", "#componentPath#/custom_element_hierarchy_selector_base");
			bMemory = selectorObj.isMemoryStructureGood(propertiesStruct=inputParameters,elementID=ceFormID,fieldID=fieldQuery.inputID);
			
			if (bMemory EQ 0)
				selectorObj.buildMemoryStructure(propertiesStruct=inputParameters,elementID=ceFormID,fieldID=fieldQuery.inputID);
			
			resultCEData = selectorObj.getFilteredData(propertiesStruct=inputParameters,currentValues=attributes.currentvalues[fqFieldName],elementID=ceFormID,fieldID=fieldQuery.inputID);
			
			errorMsgCustom = 'An error occurred while trying to perform the operation.';
			if (IsArray(resultCEData) AND ArrayLen(resultCEData) AND NOT IsSimpleValue(resultCEData[1]))
				errorMsgCustom = '';
			else if (ArrayLen(resultCEData) EQ 0)
				errorMsgCustom = 'No records found to be displayed for the field.';
			
			application.ADF.scripts.loadJQuery(noConflict=true);
			// Here we need to have a function call to load jsTree
			application.ADF.scripts.loadJSTree(loadStyles=false);
			
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
							"keep_selected_style" : false, 
							"three_state" : #triState#
						},
						<cfif bMult>												
						"plugins" : [ "checkbox" ]
						</cfif>
					});
				
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
				jQuery('##jstree_#fqFieldName#').jstree( "open_node", '#inputParameters.rootValue#' );
			}
			
			jQuery('##jstree_#fqFieldName#').on("changed.jstree", function (e, data) 
			{
				// Loop over values and remove the prefix from each value
				var selectedNodesList = data.selected;
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
				document.getElementById('#fqFieldName#').value = selectedNodesIDList;
			});

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
			// -->
		</script>
		</cfoutput>
	</cfif>
</cfif>
