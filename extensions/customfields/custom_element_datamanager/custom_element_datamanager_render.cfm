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
	custom_element_datamanager_render.cfc
Summary:
	This the render file for the Custom Element Data Manager field
ADF Requirements:
	scripts_1_2
History:
	2013-11-14 - DJM - Created
	2013-11-15 - GAC - Converted to an ADF custom field type
	2013-11-25 - DJM - Added a simple form and logged in user check
	2013-11-27 - DJM - Updated code to allow multiple dataManager fields on the same form
	2013-11-28 - DJM - Updated to correct issue with 3 element configuration
	2013-12-04 - GAC - Added CommonSpot Version check since this field only runs on CommonSpot v9+
	2013-12-09 - DJM - Added code to change the cursor for datatable, actions column width and modified path to CFC to allow drag drop
	2014-02-20 - JTP - Added the AjaxBeanName variable for the override function 
	2014-03-05 - JTP - Update to better handle the newData variable
	2014-03-12 - DJM - Added code for overlay while loading datamanager, updated flyover text for edit and delete icons, 
						modified code for allowing resize of datamanager after load
	2014-04-08 - JTP - Added logic for multi-record delete
	2014-05-29 - DJM - Moved hideOverlay() call out of the if else condition.
	2014-07-01 - DJM - Added code to support metadata forms
	2014-12-15 - DJM - Modified setting up of newData variable to fix issue with editing record for GCE
	2015-03-19 - DJM - Added code to check for elementtype for honoring newData variable to fix metadata form issue
	2015-04-02 - DJM - Modified code to handle show/hide of Actions column returned
	2015-04-10 - DJM - Added code to check for field permission for rendering controls
	2015-05-01 - GAC - Updated to add a forceScript parameter to bypass the ADF renderOnce script loader
	2015-07-03 - DJM - Added code for disableDatamanager interface option
	2015-07-14 - DJM - Added code to get elements by name if not found by ID
	2015-07-21 - DJM - Modified code to have the hidden field render always
	2015-07-23 - DJM - Modified call to RenderGrid() to take parent field's value using javascript from the form field
	2015-08-06 - DJM - Modified code to check for AuthorID instead of DateAdded for setting newData variable
	2015-12-07 - DJM - Modified JS code to use encodeURIComponent instead of encodeURI since it was not encoding all chars
--->
<cfscript>
	requiredCSversion = 9;
	csVersion = ListFirst(ListLast(request.cp.productversion," "),".");
	
	// Path to component in the ADF
	componentOverridePath = "#request.site.csAppsURL#components";
	componentName = "customElementDataManager_1_0";
	
	// Ajax URL to the proxy component in the context of the site
	ajaxComURL = application.ADF.ajaxProxy;
	ajaxBeanName = 'customElementDataManager';
</cfscript>

<cfquery name="getFieldDetails" dbtype="query">
	SELECT [Action]
	  FROM FieldQuery
	 WHERE InputID = <cfqueryparam value="#fieldQuery.inputID#" cfsqltype="cf_sql_integer">
</cfquery>
		
<!--- can not trust 'newdata' form variable being passed in for local custom elements --->
<cfif getFieldDetails.Action EQ ''>
	<cfquery name="getClass" dbtype="query">
		SELECT ClassID
		  FROM FieldQuery
		 WHERE InputID = <cfqueryparam value="#fieldQuery.inputID#" cfsqltype="cf_sql_integer">
	</cfquery>
	<cfif getClass.ClassID NEQ 1>
		<cfif StructKeyExists(request.params,'pageid') 
					AND StructKeyExists(request.params,'controlid') 
					AND StructKeyExists(request.params,'controlTypeID')
					AND request.params.controlID gt 0>
			<cfquery name="qry" datasource="#request.site.datasource#">
				select count(*) as CNT 
					from data_fieldValue
				where FormID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.params.controlTypeID#">
					AND PageID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.params.PageID#">
					AND ControlID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.params.controlID#">
			</cfquery>
			<cfscript>
				if( qry.cnt eq 0 )
					newData = 1;
				else
					newData = 0;	
			</cfscript>
		</cfif>
	</cfif>
</cfif>

<cfscript>
	if ( NOT IsDefined('newData') )
	{			
		if (StructKeyExists(attributes.currentValues, 'AuthorID') AND attributes.currentValues.AuthorID GT 0)
			newData = 0;
		else
			newData = 1;
	}	
	
	if (getFieldDetails.Action NEQ 'special' AND NOT ListFindNoCase(attributes.parameters[fieldQuery.inputID].interfaceOptions, 'disableDatamanager'))
		request.showSaveAndContinue = 0;
	else
		request.showSaveAndContinue = newData;	// forces showing or hiding of 'Save & Continue' button
</cfscript>

<cfparam name="attributes.callingElement" default="">

<!--- // Make sure we are on CommonSpot 9 or greater --->
<cfif csVersion LT requiredCSversion>
	<cfscript>
		inputHTML = '<div class="cs_dlgLabelError">This Custom Field Type requires CommonSpot #requiredCSversion# or above.</div>';
		includeLabel = true;
		includeDescription = false;
		if ( NOT StructKeyExists(variables,"fieldPermission") )
			variables.fieldPermission = "";
	</cfscript>
	<cfoutput>
	#application.ADF.fields.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission,includeLabel,includeDescription)#
	</cfoutput>
<cfelse>
<cfif attributes.callingElement NEQ 'simpleform' AND (attributes.callingElement NEQ 'datasheet' OR (attributes.callingElement EQ 'datasheet' AND Request.User.ID NEQ 0))>
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
	
	<CFIF fieldpermission gt 0>		
		<CFSCRIPT>
			inputParameters = attributes.parameters[fieldQuery.inputID];
			
			if (NOT StructKeyExists(inputParameters, "secondaryElementType"))
				inputParameters.secondaryElementType = "CustomElement";
			uniqueTableAppend = fieldQuery.inputID;
		
			ceFormID = 0;
			if (StructKeyExists(Request.Params, 'controlTypeID'))
				ceFormID = Request.Params.controlTypeID;
			else if (StructKeyExists(Request.Params, 'formID'))
				ceFormID = Request.Params.formID;
			else if (StructKeyExists(attributes, 'fields'))
				ceFormID = attributes.fields.formID[1];
			
			elementType = '';
			parentFormLabel = '';
			infoArgs = StructNew();
			infoMethod = "getInfo";
			
			switch (getFieldDetails.Action)
			{
				case 'special':
					elementType = 'MetadataForm';
					infoMethod = "getForms";
					infoArgs.id = formID;
					break;
				default:
					elementType = 'CustomElement';
					infoArgs.elementID = formID;
					break;
							
			}
			
			curPageID = 0;
			if (StructKeyExists(request.params,'pageID') AND elementType EQ 'MetadataForm')
				curPageID = request.params.pageID;
			
			parentElementObj = Server.CommonSpot.ObjectFactory.getObject(elementType);
		</CFSCRIPT>
		
		<cfinvoke component="#parentElementObj#" method="#infoMethod#" argumentCollection="#infoArgs#" returnvariable="parentFormDetails">
		
		<CFSCRIPT>
			childElementObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
			
			if (IsNumeric(inputParameters.assocCustomElement))
				childElementDetails = childElementObj.getList(ID=inputParameters.assocCustomElement);
			else
				childElementDetails = childElementObj.getList(ID=inputParameters.childCustomElement);
			
			childFormName = childElementDetails.Name;
			
			if (elementType EQ 'MetadataForm')
				parentFormLabel = parentFormDetails.formName;
			else
				parentFormLabel = parentFormDetails.Name;
			
			if (Len(inputParameters.compOverride))
			{
				ext = ListLast(inputParameters.compOverride,'.');
				if (ext EQ 'cfc')
				{
					fileName = Mid(inputParameters.compOverride, 1, Len(inputParameters.compOverride)-Len(ext)-1);
					fileNamewithExt = inputParameters.compOverride;
				}
				else
				{
					fileName = inputParameters.compOverride;
					fileNamewithExt = inputParameters.compOverride & '.cfc';
				}
			
				try
				{
					if ( StructKeyExists(application.ADF,fileName) )
					{
						datamanagerObj = application.ADF[fileName];
						componentName = fileName;
						ajaxBeanName = fileName;
					}
					else if ( FileExists(ExpandPath('#componentOverridePath#/#fileNamewithExt#')) )
					{
						datamanagerObj = CreateObject("component", "#componentOverridePath#/#fileName#");
						componentName = fileName;
						ajaxBeanName = fileName;
					}
					else
					{
						datamanagerObj = application.ADF[ajaxBeanName];
					}
				}
				catch(Any e)
				{
					Server.CommonSpot.UDF.mx.doLog("DataManager: Could not load override component '#inputParameters.compOverride#'");
					//datamanagerObj = CreateObject("component", "#componentPath#/#componentName#");
					//componentName = 'custom_element_datamanager_base';
					datamanagerObj = application.ADF[ajaxBeanName];
				}
			}
			else
			{
				//datamanagerObj = CreateObject("component", "#componentPath#/#componentName#");
				//componentName = 'custom_element_datamanager_base';
				datamanagerObj = application.ADF[ajaxBeanName];
			}	
	
			widthVal = "600px";
			if (IsNumeric(inputParameters.widthValue))
			{
				widthVal = "#inputParameters.widthValue#";
				if (inputParameters.widthUnit EQ 'percent')
					widthVal = widthVal & '%';
				else
					widthVal = widthVal & 'px';
			}
		
			heightVal = "150px";
			if (IsNumeric(inputParameters.heightValue))
				heightVal = "#inputParameters.heightValue#px";
				
			// Set the forceScripts parameter if it does not exist
			if ( !StructKeyExists(inputParameters,"forceScripts") )
				inputParameters.forceScripts = false;
		
			application.ADF.scripts.loadJQuery(force=inputParameters.forceScripts,noConflict=true);
			application.ADF.scripts.loadJQueryUI(force=inputParameters.forceScripts);
			// Always force the loading of JQuery DataTables
			application.ADF.scripts.loadJQueryDataTables(force=true,loadStyles="false");
		</CFSCRIPT>
		
		<CFIF inputParameters.sortByType EQ 'manual'>
			<CFOUTPUT>
				<style>
					##customElementData_#uniqueTableAppend# tbody td {cursor: ns-resize;}
				</style>
			</CFOUTPUT>
		</CFIF>
		
		<cfif fieldpermission eq 2>
			<CFOUTPUT>#Server.CommonSpot.UDF.tag.input(type="hidden", name="#fqFieldName#", value="")#</CFOUTPUT>
		</cfif>
		
		<CFIF inputParameters.childCustomElement neq ''>
			<CFIF ((elementType NEQ 'metadataForm' AND (newData EQ 0 OR NOT ListFindNoCase(inputParameters.interfaceOptions, 'disableDatamanager'))) OR (elementType EQ 'metadataForm' AND curPageID GT 0))>
				<CFOUTPUT>
					#datamanagerObj.renderStyles(propertiesStruct=inputParameters)#
					<table class="cs_data_manager" border="0" cellpadding="2" cellspacing="2" summary="" id="parentTable_#uniqueTableAppend#"></CFOUTPUT>
					<cfif fieldpermission eq 2>
					<CFOUTPUT><tr><td>
						#datamanagerObj.renderButtons(propertiesStruct=inputParameters,currentValues=attributes.currentvalues,formID=ceFormID,fieldID=fieldQuery.inputID,parentFormType=elementType,pageID=curPageID)#
					</td></tr></CFOUTPUT>
					</cfif>
					<CFOUTPUT><tr><td>
						<span id="errorMsgSpan"></span>
					</td></tr>
					<tr><td>
					<div id="datamanager_#uniqueTableAppend#">
						<table id="customElementData_#uniqueTableAppend#" class="display" style="min-width:#widthVal#;">
						<thead><tr></tr></thead>
						<tbody>
							<tr>
								<td class="dataTables_empty"><img src="/commonspot/dashboard/images/dialog/loading.gif" />&nbsp;Loading data from server</td>
							</tr>
						</tbody>
						</table>
					</div>
					</td></tr>
					</table>
				</CFOUTPUT>
			<CFELSE>
			<CFOUTPUT><table class="cs_data_manager" border="0" cellpadding="0" cellspacing="0" summary="">
				<tr><td class="cs_dlgLabel">#childFormName# records can only be added once the #parentFormLabel# record is saved.</td></tr>
				</table></CFOUTPUT>
			</CFIF>
		</CFIF>
	</CFIF>
	
	<cfif fieldpermission lt 2>
		<CFOUTPUT>#Server.CommonSpot.UDF.tag.input(type="hidden", name="#fqFieldName#")#</CFOUTPUT>
	</cfif>
	
	<cfif attributes.rendermode eq 'standard'>
		<cfoutput></td></tr></cfoutput>
		<CFIF fieldpermission gt 0>
			<cfoutput>#description_row#</cfoutput>
		</CFIF>
	</cfif>
	
	<cfif fieldPermission gt 0>
		<cfoutput>
		<script type="text/javascript" src="/commonspot/dashboard/js/nondashboard-util.js"></script>
		<script type="text/javascript">
			<!--	
			var oTable#uniqueTableAppend# = '';
			
			jQuery( function () {
				if ( typeof commonspot == 'undefined' )
				{
					var commonspot = {};
				 	commonspot = top.commonspot.util.merge(commonspot, top.commonspot, 1, 0);
				} 
			
			
				jQuery.ajaxSetup({ cache: false, async: true });
			
		
				top.commonspot.util.event.addEvent(window, "load", function(){
																		loadData_#uniqueTableAppend#(0)
																	});
				top.commonspot.util.event.addEvent(window, "resize", resize_#uniqueTableAppend#);
			});
			
			function resize_#uniqueTableAppend#()
			{
					if ( oTable#uniqueTableAppend#.length > 0 ) 
					{
						oTable#uniqueTableAppend#.fnAdjustColumnSizing();
					}
			}
			
			function onSuccess_#uniqueTableAppend#(data)
			{
				onSuccess(data, '#uniqueTableAppend#' );
			}

			if( typeof onSuccess != 'function' )
			{
				function onSuccess(data, uniqueTable )
				{
					if(data == 'Success')
					{
						// call the loadData function for the table that the drop occurred in.
						window['loadData_' + uniqueTable]();	
						// console.log('loadData_' + uniqueTable);			
					}
					else
					{
						document.getElementById('errorMsgSpan').innerHTML = data;
						document.getElementById('customElementData_#uniqueTableAppend#').style.display = "none";
						ResizeWindow();
					}
				}
			}

			function loadData_#uniqueTableAppend#(displayOverlay)
			{
				if (typeof displayOverlay == 'undefined')
					var displayOverlay = 1;
				
				setTimeout( function(){
								loadDataCore_#uniqueTableAppend#(displayOverlay)
							}, 500 );
			}
			
			function loadDataCore_#uniqueTableAppend#(displayOverlay)
			{
				if (displayOverlay == 1)
					commonspotNonDashboard.util.displayMessageOverlay('datamanager_#uniqueTableAppend#', 'overlayDivStyle', 'Please Wait...');	
				var res#uniqueTableAppend# = '';
				var retData#uniqueTableAppend# = '';
				var parentInstanceIDVal = '';
				var parentInstanceFld = '';					
		
				<CFIF elementType EQ 'MetadataForm' AND inputParameters.parentUniqueField EQ '{{pageid}}'>
					parentInstanceIDVal = '#curPageID#';
				<CFELSE>
					parentInstanceFld = 'fic_#ceFormID#_#inputParameters.parentUniqueField#';
				</CFIF>
				
				if (parentInstanceFld != '' && (document.getElementById(parentInstanceFld) != null || document.getElementsByName(parentInstanceFld)[0] != null))
				{
					if (document.getElementById(parentInstanceFld) != null)
						parentInstanceIDVal = document.getElementById(parentInstanceFld).value;
					else
						parentInstanceIDVal = document.getElementsByName(parentInstanceFld)[0].value;
				}
				
				dataToBeSent#uniqueTableAppend# = { 
						bean: '#ajaxBeanName#',
						method: 'renderGrid',
						query2array: 0,
						returnformat: 'json',
						formID : #ceFormID#,
						fieldID : #fieldQuery.inputID#, 
						parentFormType : '#elementType#',
						pageID : #curPageID#,
						propertiesStruct : JSON.stringify(<cfoutput>#SerializeJSON(inputParameters)#</cfoutput>),
						parentInstanceValue : parentInstanceIDVal,
						fieldPermission : #fieldpermission#						
				 };
				 
				jQuery.when(

							jQuery.post( '#ajaxComURL#', 
													dataToBeSent#uniqueTableAppend#, 
													null, 
													"json" )

				).done(function(retData#uniqueTableAppend#) {
				
					// Convert the JSON String from the AjaxProxy to JSON Object
					var res#uniqueTableAppend# = jQuery.parseJSON( retData#uniqueTableAppend# );	

					var columns = [];
					var actionColumnWidth = res#uniqueTableAppend#.actionColumnWidth;
					var columnsList = res#uniqueTableAppend#.aoColumns;
					
					if( typeof columnsList == 'undefined' || ! columnsList.length  )
					{
						// no columns
						<cfif inputParameters.assocCustomElement neq ''>
							<cfset ceName = request.site.availControls[inputParameters.assocCustomElement].ShortDesc>
						<cfelse>
							<cfset ceName = request.site.availControls[inputParameters.childCustomElement].ShortDesc>
						</cfif>	
						document.getElementById('errorMsgSpan').innerHTML = "No columns returned.  Check the definition of the '#ceName#' associated custom element";
						
						document.getElementById('customElementData_#uniqueTableAppend#').style.display = "none";
						ResizeWindow();
					}
					else
					{
						var columnsArray = columnsList.split(',');
						var hasActionColumn = 0;
						var displayActionColumn = 0;
						<cfif (ListFindNoCase(inputParameters.interfaceOptions,'editAssoc') OR ListFindNoCase(inputParameters.interfaceOptions,'editChild') OR ListFindNoCase(inputParameters.interfaceOptions,'delete')) AND fieldpermission eq 2>
							displayActionColumn = 1;
						</cfif>
					
						if (columnsList != 'ERRORMSG')
						{
							for(var i=0; i < columnsArray.length; i=i+1)
							{
								if(columnsArray[i] == "AssocDataPageID" || columnsArray[i] == "ChildDataPageID")
								{
									var obj = {"bVisible": false, "mDataProp": i+1};
								}
								else if (columnsArray[i] == "Actions")
								{
									if (res#uniqueTableAppend#.aaData.length > 0 && displayActionColumn == 1)
									{
										var obj = { "sTitle": columnsArray[i], "mDataProp": i+1, "sWidth": actionColumnWidth + "px" };
										hasActionColumn = 1;
									}
									else
									{
										var obj = {"bVisible": false, "mDataProp": i+1};
									}
								}
								else
								{
									var obj = { "sTitle": columnsArray[i], "mDataProp": i+1, "sWidth": null };
								}
								columns.push(obj);
							};
							oTable#uniqueTableAppend# = jQuery("##customElementData_#uniqueTableAppend#").dataTable({
								"bFilter": false,
								"bPaginate": false,
								"bLengthChange": false,
								"bScrollInfinite": false,
								"sScrollX": "#widthVal#",
								"sScrollY": "#heightVal#",
								"bSort": false,
								"bProcessing": true,
								"bDestroy": true,
								"bAutoWidth": false,
								"bScrollCollapse": false,
								"bRetrieve": false,
								"oLanguage": {
									"sProcessing": "Please wait...fetching records....",
									"sZeroRecords": "No records found.",
									"sInfo": "Showing _TOTAL_ records",
									"sInfoEmpty": "Showing 0 records"
									},
								"aaData": res#uniqueTableAppend#.aaData,
								"aoColumns": columns,
								"fnRowCallback": function( nRow, aData, iDisplayIndex, iDisplayIndexFull) {
										if( hasActionColumn == 1 )
										{
											if (aData[2] == 0)
												jQuery(nRow).attr("id", aData[3]);
											else
												jQuery(nRow).attr("id", aData[2]);
										}
										else
										{
											if (aData[1] == 0)
												jQuery(nRow).attr("id", aData[2]);
											else
												jQuery(nRow).attr("id", aData[1]);
										}
										return nRow;
								}
							});						
							
							if (res#uniqueTableAppend#.aaData.length > 0)
							{
								jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollHead').css('width', "#widthVal#");								
								jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollHead.dataTables_scrollHeadInner.dataTable').css('width', "#widthVal#");
								jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollHeadInner').css('width', "#widthVal#");
								jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollBody').css('height', "#heightVal#");
								jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollBody').css('width', "#widthVal#");
								jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollBody.dataTable').css('width', "#widthVal#");
								jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollBody').css('width', ResizeWindow());
							}
							else
							{
								jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollBody').css('height', "30px");
							}
							
							if (displayOverlay == 1)
									commonspotNonDashboard.util.hideMessageOverlay('datamanager_#uniqueTableAppend#');
						
							if (res#uniqueTableAppend#.aaData.length > 1)
							{
								<CFIF inputParameters.sortByType EQ 'manual'>
									var startPosition;
									var endPosition;
									var startVal;
									var endVal;
									var rowData;
									var movedDataPageID = 0;
									var prevItemsLenBeforeDrop = 0;
									var prevItemsLenAfterDrop = 0;
									var dropAfterDataPageID = 0;
									
									jQuery("##customElementData_#uniqueTableAppend# tbody").sortable(
										{
										cursor: "move",
										start:function(event, ui)
											{
												prevItemsLenBeforeDrop = ui.item.prevAll().length;										
											},
										stop:function(event, ui)
											{
												prevItemsLenAfterDrop = ui.item.prevAll().length;
												movedDataPageID = ui.item.attr("id");
												prevItemsLenAfterDrop = ui.item.prevAll().length;
												if (prevItemsLenAfterDrop == 0)
												{
													dropAfterDataPageID = 0;
												}
												else 
												{
													if (prevItemsLenBeforeDrop < prevItemsLenAfterDrop)
													{
														rowData = oTable#uniqueTableAppend#.fnGetNodes()[ui.item.prevAll().length];
													}
													else if (prevItemsLenBeforeDrop > prevItemsLenAfterDrop)
													{
														rowData = oTable#uniqueTableAppend#.fnGetNodes()[ui.item.prevAll().length-1];
													}
													dropAfterDataPageID = jQuery(rowData).attr("id");
												}
												
												if (movedDataPageID != null && dropAfterDataPageID != null)
												{
													dataToBeSent#uniqueTableAppend# = 
														{ 
															bean: '#ajaxBeanName#',
															method: 'onDrop',
															query2array: 0,
															returnformat: 'json',
															formID: #ceFormID#,
															movedDataPageID: movedDataPageID, 
															dropAfterDataPageID: dropAfterDataPageID,
															parentFormType : '#elementType#',
															pageID : #curPageID#,
															propertiesStruct : JSON.stringify(<cfoutput>#SerializeJSON(inputParameters)#</cfoutput>),
															currentValues : JSON.stringify(<cfoutput>#SerializeJSON(attributes.currentvalues)#</cfoutput>)
													 	};
											
													jQuery.post( '#ajaxComURL#', 
																		dataToBeSent#uniqueTableAppend#, 
																		onSuccess_#uniqueTableAppend#, 
																		"json"); 
													
												}
											}
										});
								</CFIF>
							}
						}
						else
						{
							document.getElementById('errorMsgSpan').innerHTML = res#uniqueTableAppend#.aaData[1];
							document.getElementById('customElementData_#uniqueTableAppend#').style.display = "none";
							ResizeWindow();
						}
					}
				})
				.fail(function(jqXHR, textStatus, errorThrown)
				{
					var msg = (typeof jqXHR.responseText === 'string') ? jqXHR.responseText : 'An error occurred while trying to perform the operation.';
					document.getElementById('errorMsgSpan').innerHTML = msg;
					document.getElementById('customElementData_#uniqueTableAppend#').style.display = "none";
					ResizeWindow();
				});
				// ResizeWindow();					
			}
			
			
			function doDeleteSelected_#uniqueTableAppend#(msg,errormsg)
			{
				var dataPageIDsToDelete = '';
				
				// get checked checkboxes, ensure at least 1 checked
				var theLen = jQuery( '##customElementData_#uniqueTableAppend# input:checked' ).length;
				if( theLen == 0 )
				{
					alert(errormsg);
					return false;
				}

				// confirm with user that they really want to delete
				if( ! confirm( msg ) )
					return;
				
				
				// get data pageIDs				
				jQuery( '##customElementData_#uniqueTableAppend# input:checked' ).each( function() {
						if( dataPageIDsToDelete == '' )
							dataPageIDsToDelete = jQuery(this).val();
						else
							dataPageIDsToDelete = dataPageIDsToDelete + "," + jQuery(this).val();
					} );
				
				var data = { 
						bean: '#ajaxBeanName#',
						method: 'deleteSelectedRecords',
						returnformat: 'json',
						propertiesStruct : JSON.stringify(<cfoutput>#SerializeJSON(inputParameters)#</cfoutput>),
						dataPageIDList : dataPageIDsToDelete
				 };
				 
				jQuery.when(
					jQuery.post( '#ajaxComURL#',
												data,
												null,
												"json" )
					)
					.done(function()
					{
						onSuccess_#uniqueTableAppend#('Success');
					})
					.fail(function(jqXHR, textStatus, errorThrown)
					{
						var msg = (typeof jqXHR.responseText === 'string') ? jqXHR.responseText : 'An error occurred while trying to perform the operation.';
						alert(msg);
					});
			}
			
			function setCurrentValueAndOpenURL_#uniqueTableAppend#(urlToOpen, linkedFldName, buttonName)
			{
				var linkedFldVal = '';
				if (linkedFldName != '')
				{
					if (document.getElementById(linkedFldName) != null || document.getElementsByName(linkedFldName)[0] != null)
					{
						if (document.getElementById(linkedFldName) != null)
							linkedFldVal = document.getElementById(linkedFldName).value;
						else
							linkedFldVal = document.getElementsByName(linkedFldName)[0].value;
						if (buttonName == 'addnew')
							urlToOpen = urlToOpen + "&csAssoc_ParentInstanceID=" + encodeURIComponent(linkedFldVal) + "&linkedFieldValue=" + encodeURIComponent(linkedFldVal);
						else
							urlToOpen = urlToOpen + "&linkedFieldValue=" + encodeURIComponent(linkedFldVal);
					}
					else
					{
						if (buttonName == 'addnew')
							urlToOpen = urlToOpen + "&csAssoc_ParentInstanceID=&linkedFieldValue=";
						else
							urlToOpen = urlToOpen + "&linkedFieldValue=";
					}
				}
				top.commonspot.lightbox.openDialog(urlToOpen);
			}
			// -->
		</script>
		</cfoutput>
	</cfif>
<cfelse>
	<CFOUTPUT>#Server.CommonSpot.UDF.tag.input(type="hidden", name=fqFieldName)#</CFOUTPUT>
</cfif>
</cfif>
