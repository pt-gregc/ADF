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

<!--- can not trust 'newdata' form variable being passed in for local custom elements --->
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

<cfscript>
	if ( NOT IsDefined('newData') )
	{			
		if (StructKeyExists(attributes.currentValues, 'DateAdded'))
			newData = 0;
		else
			newData = 1;
	}
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
			uniqueTableAppend = fieldQuery.inputID;
		
			ceFormID = 0;
			if (StructKeyExists(Request.Params, 'controlTypeID'))
				ceFormID = Request.Params.controlTypeID;
			else if (StructKeyExists(Request.Params, 'formID'))
				ceFormID = Request.Params.formID;
			else if (StructKeyExists(attributes, 'fields'))
				ceFormID = attributes.fields.formID[1];
		
			customElementObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
			childCustomElementDetails = customElementObj.getList(ID=inputParameters.childCustomElement);
			parentCustomElementDetails = customElementObj.getInfo(elementID=ceFormID);
			
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
		
			application.ADF.scripts.loadJQuery(noConflict=true);
			application.ADF.scripts.loadJQueryUI();
			application.ADF.scripts.loadJQueryDataTables(force=true,loadStyles="false");
		</CFSCRIPT>
		
		<CFIF inputParameters.sortByType EQ 'manual'>
			<CFOUTPUT>
				<style>
					##customElementData_#uniqueTableAppend# tbody td {cursor: ns-resize;}
				</style>
			</CFOUTPUT>
		</CFIF>
	
		<CFIF inputParameters.childCustomElement neq ''>
			<CFIF newData EQ 0>
				<CFOUTPUT>
					#datamanagerObj.renderStyles(propertiesStruct=inputParameters)#
					<table class="cs_data_manager" border="0" cellpadding="2" cellspacing="2" summary="" id="parentTable_#uniqueTableAppend#">
					#datamanagerObj.renderButtons(propertiesStruct=inputParameters,currentValues=attributes.currentvalues,formID=ceFormID,fieldID=fieldQuery.inputID)#
					<tr><td>
						<span id="errorMsgSpan"></span>
					</td></tr>
					<tr><td>
					<table id="customElementData_#uniqueTableAppend#" class="display" style="min-width:#widthVal#;">
					<thead><tr></tr></thead>
					<tbody>
						<tr>
							<td class="dataTables_empty"><img src="/commonspot/dashboard/images/dialog/loading.gif" />&nbsp;Loading data from server</td>
						</tr>
					</tbody>
					</table>
					</td></tr>
					</table>
				</CFOUTPUT>
			<CFELSE>
			<CFOUTPUT><table class="cs_data_manager" border="0" cellpadding="0" cellspacing="0" summary="">
				<tr><td class="cs_dlgLabelError">#childCustomElementDetails.Name# records can only be added once the #parentCustomElementDetails.Name# record is saved.</td></tr>
				</table>
				#Server.CommonSpot.UDF.tag.input(type="hidden", name="#fqFieldName#", value="")#</CFOUTPUT>
			</CFIF>
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

	<cfif fieldPermission gt 0>
		<cfoutput>
		<script type="text/javascript">
			<!--	
			var oTable#uniqueTableAppend# = '';
			
			jQuery.ajaxSetup({ cache: false, async: true });	
		
			top.commonspot.util.event.addEvent(window, "load", loadData_#uniqueTableAppend#);
			top.commonspot.util.event.addEvent(window, "resize", resize_#uniqueTableAppend#);
			
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

			function loadData_#uniqueTableAppend#()
			{
				setTimeout( loadDataCore_#uniqueTableAppend#, 500 );
			}
			
			function loadDataCore_#uniqueTableAppend#()
			{
				var res#uniqueTableAppend# = '';
				var retData#uniqueTableAppend# = '';
				
				dataToBeSent#uniqueTableAppend# = { 
						bean: '#ajaxBeanName#',
						method: 'renderGrid',
						query2array: 0,
						returnformat: 'json',
						formID : #ceFormID#,
						fieldID : #fieldQuery.inputID#, 
						propertiesStruct : JSON.stringify(<cfoutput>#SerializeJSON(inputParameters)#</cfoutput>),
						currentValues : JSON.stringify(<cfoutput>#SerializeJSON(attributes.currentvalues)#</cfoutput>)						
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
					var columnsList = res#uniqueTableAppend#.aoColumns;
					var columnsArray = columnsList.split(',');
					var hasActionColumn = 0;
				
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
								<CFIF ListFindNoCase(inputParameters.interfaceOptions, 'editAssoc') AND ListFindNoCase(inputParameters.interfaceOptions, 'editChild') AND ListFindNoCase(inputParameters.interfaceOptions, 'delete')>
									var obj = { "sTitle": columnsArray[i], "mDataProp": i+1, "sWidth": "65px" };
								<CFELSE>
									var obj = { "sTitle": columnsArray[i], "mDataProp": i+1, "sWidth": "42px" };
								</CFIF>
								hasActionColumn = 1;
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
							// jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollBody').css('width', ResizeWindow());
						}
						else
						{
							jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollBody').css('height', "30px");
						}
					
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
				})
				.fail(function() 
				{
					document.getElementById('errorMsgSpan').innerHTML = 'An error occurred while trying to perform the operation.';
					document.getElementById('customElementData_#uniqueTableAppend#').style.display = "none";
					ResizeWindow();
				});
				// ResizeWindow();
			}
			// -->
		</script>
		</cfoutput>
	</cfif>
<cfelse>
	<CFOUTPUT>#Server.CommonSpot.UDF.tag.input(type="hidden", name=fqFieldName)#</CFOUTPUT>
</cfif>
</cfif>
