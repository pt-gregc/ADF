<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2011.
All Rights Reserved.
 
By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Michael Carroll 
Custom Field Type:
	general_chooser_props.cfm
Name:
	general_chooser_props.cfm
Summary:
	General Chooser field type.
	Allows for selection of the custom element records.
Version:
	2.0.0
History:
	2011-03-20 - MFC - Created new version 2 chooser based on the v1 props/render files.
	2011-12-08 - SS - The field now honors the "required" setting in Standard Options and forces the user to make a choice.
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	// overwrite the field ID to be unique
	xParams.fieldID = #fqFieldName#;
	
	// Set the defaults
	if( StructKeyExists(xParams, "forceScripts") AND (xParams.forceScripts EQ "1") )
		xParams.forceScripts = true;
	else
		xParams.forceScripts = false;
	
	// find if we need to render the simple form field
	renderSimpleFormField = false;
	if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) )
		renderSimpleFormField = true;
</cfscript>
<cfoutput>
	
	<link href="/commonspot/dashboard/css/reset.css" rel="stylesheet" type="text/css" />
	<link href="/commonspot/dashboard/css/default.css" rel="stylesheet" type="text/css" />
	<link href="/commonspot/dashboard/css/dialog.css" rel="stylesheet" type="text/css" id="dialogcss" />
	<link href="/commonspot/dashboard/css/formdialog.css" rel="stylesheet" type="text/css" />
	<link href="/commonspot/dashboard/css/pagelist.css" rel="stylesheet" type="text/css" />
	<link href="/commonspot/dashboard/css/util.css" rel="stylesheet" type="text/css" />
	<link href="/commonspot/dashboard/dialogs/pageview/css/datasheet-columns.css" rel="stylesheet" type="text/css" />
	
	<cfscript>
		// Load the scripts
		application.ADF.scripts.loadJQuery(force=xParams.forceScripts);
		application.ADF.scripts.loadJQueryUI(force=xParams.forceScripts);
		application.ADF.scripts.loadADFLightbox();
		application.ADF.scripts.loadCFJS();
	</cfscript>
	
	<script type="text/javascript">
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
		#fqFieldName#.validator = "validate_#fqFieldName#()";
		#fqFieldName#.msg = "Please make a selection from the available items list.";
		// Check if the field is required
		if ( '#xparams.req#' == 'Yes' ){
			// push on to validation array
			vobjects_#attributes.formname#.push(#fqFieldName#);
		}
		function validate_#fqFieldName#()
		{
			//alert(fieldLen);
			if (jQuery("input[name=#fqFieldName#]").val() != '')
			{
				return true;
			}
			else
			{
				alert(#fqFieldName#.msg);
				return false;
			}
		}

		// Move the selected object to the selected
		function moveObjectToSelected(selObj){
			// Modify the arrow icon to the close
			makeArrowIcon(selObj);
			
			// Add the click object back into the list
			jQuery("##selSelections").append(selObj);	
		}
				
		// Move the selected object to the available
		function moveObjectToAvailable(selObj){
			
			// Modify the close icon to the arrow
			makeCloseIcon(selObj)
			
			// Add the click object back into the list
			jQuery("##availSelections").append(selObj);	
		}
		
		// Move all avialable objects to the selected
		function moveAllAvailableObjects(){
			// Loop over each LI in the UL
			jQuery('ul##availSelections li').each(function(index){
				// Move the object to selected
				moveObjectToSelected(jQuery(this));
			})
		}
		
		// Move all selected objects to the available
		function moveAllSelectedObjects(){
			// Loop over each LI in the UL
			jQuery('ul##selSelections li').each(function(index){
				// Move the object to selected
				moveObjectToAvailable(jQuery(this));
			})
		}
		
	</script>
	
	<!--- Load in the GC scripts --->
	<!--- <script type="text/javascript" src="/ADF/extensions/customfields/general_chooser/v2/general_chooser.js">
	 ---> 
	<tr>
		<td class="cs_dlgLabelSmall" colspan="2">
			<div>
				#xparams.label#:
			</div>
			<div id="pageListsContainer" style="width: 693px;">
				<div id="infoBar">
					Select the records you want to include in the selections by dragging 
					items into or out of the 'Select Columns' list. Order the columns 
					within the datasheet by dragging items within the 'Selected Columns' field.
				</div>
				<div id="filterBar">
					<div>
						<label>Find:</label>
						<input type="text" size="30" value="" title="Enter search criteria. Can be one or more keywords seperated by a comma." name="txtSearchString" id="txtSearchString">
						<input type="button" onclick="sendGetAvailableFilter();" value="Filter" class="clsPushButton">
					</div>
				</div>
				<div id="saveBar">
					<input type="button" onclick="openLBAdd();" value="Add New Record" class="clsPushButton">
				</div>
				<div style="clear:both;"></div>
				<!-- Left Page List : Available Columns List -->
				<div id="leftPageList" class="plContainer">
					<div class="header"> 
					</div>
					<div class="pagelistContainer"> 
						<table class="pagelistHeader">
							<thead>
								<tr>
									<th class="availableColumn" 
										id="pl_availableColumn" 
										onclick="currentSortColumnIDavailableColumn=commonspotLocal.pageList.sortColumn(sortCallback, currentSortColumnIDavailableColumn, 'pl_availableColumn', 'name', 'ascending')"
										tyle="background-image:url(/commonspot/dashboard/images/controls/header_light_blue.gif)"
										title="Available Columns">Available Columns <img src="/commonspot/dashboard/images/controls/white_up_bullet.gif"/>
									</th>
								</tr>
							</thead>
						</table>
						
						<!--- <div id="spryPagelistRegion" class="pagelistRegion SpryHiddenRegion" spry:region="commonspotLocalData.DatasheetElement_getAvailableColumns"> --->
						<div id="spryPagelistRegion" class="pagelistRegion">
							<!-- error message when spry data has an error  -->
							<!--- <div spry:state="error" class="errorMessage">
								Failed to load data. Please close and reopen this dialog.
							</div> --->				
							<!-- Used for sizing -->	
							<div id="pageListTableAvailableColumns">
								<!-- pagelist results set -->	
								<div>	
									<ul id="availSelections" class="connectedSortable">
										<li id="101">
											<table class="draggableRows">
												<tbody>
													<tr spry:hover="tableRowHover">
														<td class="availableColumn"><span name="availableColumns">Test101</span></td>														
														<td><span class="ico_arrow_right actionMontageIcon" title="Click to add to selected list">&nbsp;</span></td>
													</tr>
												</tbody>
											</table>
										</li> 
										<li id="102">
											<table class="draggableRows">
												<tbody>
													<tr spry:hover="tableRowHover">
														<td class="availableColumn"><span name="availableColumns">Test102</span></td>														
														<td><span class="ico_arrow_right actionMontageIcon" title="Click to add to selected list">&nbsp;</span></td>
													</tr>
												</tbody>
											</table> 
										</li>
										<li id="103">
											<table class="draggableRows">
												<tbody>
													<tr spry:hover="tableRowHover">
														<td class="availableColumn"><span name="availableColumns">Test103</span></td>														
														<td><span class="ico_arrow_right actionMontageIcon" title="Click to add to selected list">&nbsp;</span></td>
													</tr>
												</tbody>
											</table> 
										</li>
										<li id="104">
											<table class="draggableRows">
												<tbody>
													<tr spry:hover="tableRowHover">
														<td class="availableColumn"><span name="availableColumns">Test104</span></td>														
														<td><span class="ico_arrow_right actionMontageIcon" title="Click to add to selected list">&nbsp;</span></td>
													</tr>
												</tbody>
											</table>
										</li>
									</ul>
								</div> <!--pagelistReady--> 
							</div> <!-- pagelist table --> 
						</div> <!-- pagelistRegion -->	
					</div> <!-- pagelistContainer --> 
					
					<div id="dialogFooter">
						<div class="actionImgDiv" id="addIconDiv">
							<span class="ico_add">&nbsp;</span>
							<a class="primaryLink" href="javascript:;" onclick="moveAllAvailableObjects();">Add All</a>
						</div>
						<div>
							<span class="ico_message">&nbsp;</span>
							<span id="numItems"></span>
						</div> 
					</div> 
				</div>
				
				<div id="separator" class="plContainer"></div>
				
				<!-- Right Page List : Selected Columns List -->
				<div id="rightPageList" class="plContainer">
					<div class="header"></div>		 
					<div class="pagelistContainer">
						<table class="pagelistHeader">
							<thead>
								<tr id="pl_row_keywords">
									<th id="selectedColumnsLabel" class="viewSelectedNameColumn" title="Selected Columns">Selected Columns</th>
								</tr>										 
							</thead>
						</table>
						
						 <!--// SPRY Region for the pagelist //-->						
						<!--- <div id="spryPagelistSelectedRegion" class="pagelistRegion SpryHiddenRegion scrollableRegion" spry:region="commonspotLocalData.DatasheetElement_getSelectedColumns"> --->
						<div id="spryPagelistSelectedRegion" class="pagelistRegion scrollableRegion">
							<!-- error message when spry data has an error  -->
							<!--- <div spry:state="error" class="errorMessage">
								Failed to load data. Please close and reopen this dialog.
							</div>	 --->			
							<!-- Used for sizing -->	
							<div id="PageListSelectedTable">
								<!-- pagelist results set -->	
								<!--- <div spry:state="ready" class="pagelistReady" id="datasheetView"> --->
								<div class="pagelistReady" id="datasheetView">
									<div class="pagelistBodyDiv" id="pageListTableSelectedColumns">
										<div id="droppable_Test201" rowindex="1" >
											<ul id="selSelections" class="connectedSortable">
												<li id="201">
													<table class="draggableRowsSelections">
														<tbody>
															<tr name="dragRow">
																<td class="viewSelectedNameColumn">
																	<span name="txtSelectedColumn">Test201</span>
																</td>
																<td>
																	<span class="ico_cancel actionMontageIcon" title="Click to remove the selected column">&nbsp;</span>
																</td>	 
															</tr>
														</tbody>
													</table>
												</li>
												<li id="202">
													<table class="draggableRowsSelections">
														<tbody>
															<tr name="dragRow">
																<td class="viewSelectedNameColumn">
																	<span name="txtSelectedColumn">Test202</span>
																</td>
																<td>
																	<span class="ico_cancel actionMontageIcon" title="Click to remove the selected column">&nbsp;</span>
																</td>	 
															</tr>
														</tbody>
													</table>
												</li>
											</ul>
										</div>
									</div> 
								</div> <!--pagelistReady-->
							</div> <!--pagelist table-->
						</div> <!--pagelistRegion-->
						<div id="dialogSelectedFooter">
							<!--- <div class="actionImgDiv" id="removeIconDiv"> --->
							<div class="actionImgDiv">
								<img class="" src="/commonspot/dashboard/icons/delete.png">
								<a class="primaryLink" href="javascript:;" onclick="moveAllSelectedObjects();">Remove All</a>
							</div> 
						</div>  
					</div>						
				</div> 
			</div>
			
			<input type="hidden" id="#fqFieldName#" name="#fqFieldName#" value="#currentValue#">
		</td>
	</tr>
	
	<!--- // include hidden field for simple form processing --->
	<cfif renderSimpleFormField>
		<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(xParams.fieldName, 'fic_','')#">
	</cfif>
</cfoutput>