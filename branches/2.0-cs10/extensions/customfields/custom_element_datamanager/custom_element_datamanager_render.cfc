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
	2014-03-12 - DJM - Added code for overlay while loading datamanager, updated flyover text for edit and delete icons, 
						modified code for allowing resize of datamanager after load
	2014-04-08 - JTP - Added logic for multi-record delete
	2014-05-29 - DJM - Moved hideOverlay() call out of the if else condition.
	2014-07-01 - DJM - Added code to support metadata forms
	2014-12-15 - DJM - Modified setting up of newData variable to fix issue with editing record for GCE
	2015-03-19 - DJM - Added code to check for elementtype for honoring newData variable to fix metadata form issue
	2015-04-02 - DJM - Modified code to handle show/hide of Actions column returned
	2015-04-10 - DJM - Added code to check for field permission for rendering controls
	2015-04-10 - DJM - Converted to CFC
	2015-04-15 - DJM - Moved ADF renderer base and updated the extends parameter
--->
<cfcomponent displayName="CustomElementDataManager Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

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
		var elementType = '';
		var	parentFormLabel = '';
		var infoArgs = StructNew();
		var infoMethod = "getInfo";
		var parentElementObj = '';
		var childElementObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
		var datamanagerObj = '';
		var parentFormDetails = QueryNew('');
		var childElementDetails = QueryNew('');
		var childFormName = '';
		var ext = '';
		var fileName = '';
		var fileNameWithExt = '';
		var widthVal = "600px";
		var heightVal = "150px";
		var curPageID = 0;
		var allFieldsQuery = arguments.fieldQuery;
		var getDataDetails = QueryNew('');
		var getClass = QueryNew('');
		var dsn = request.site.datasource;
		var newData = '';
		
		// Version related vars
		var requiredCSversion = 10;
		var csVersion = ListFirst(ListLast(request.cp.productversion," "),".");
		var inputHTML = '<span class="cs_dlgLabelError">This Custom Field Type requires CommonSpot #requiredCSversion# or above.</span>';
		
		// Path to component in the ADF
		var componentOverridePath = "#request.site.csAppsURL#components";
		var ajaxBeanName = 'customElementDataManager';
	</cfscript>
	
	<cfif csVersion LT requiredCSversion>
		<cfoutput>#inputHTML#</cfoutput>
	<cfelse>
		<!--- can not trust 'newdata' form variable being passed in for local custom elements --->
		<cfif arguments.formType EQ "Local Custom Element"
				AND StructKeyExists(Request.Params,'pageID') 
				AND StructKeyExists(Request.Params,'controlID') 
				AND StructKeyExists(Request.Params,'controlTypeID')
				AND Request.Params.controlID gt 0>
			<cfquery name="getDataDetails" datasource="#dsn#">
				select count(*) as CNT 
					from Data_fieldValue
				where FormID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Request.Params.controlTypeID#">
					AND PageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Request.Params.PageID#">
					AND ControlID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Request.Params.controlID#">
			</cfquery>
			<cfscript>
				newData = (getDataDetails.cnt == 0) ? 1 : 0;
			</cfscript>
		</cfif>
		
		<cfscript>
			if (NOT IsNumeric(newData))
			{
				if (StructKeyExists(Request.Params, 'newData') AND IsNumeric(Request.Params.newData))
					newData = Request.Params.newData;
				else
					newData = StructKeyExists(allAtrs.currentValues, 'DateAdded') ? 0 : 1;
			}
			
			request.showSaveAndContinue = newData;	// forces showing or hiding of 'Save & Continue' button
		</cfscript>
		
		<cfif arguments.callingElement NEQ 'simpleform' AND (arguments.callingElement NEQ 'datasheet' OR (arguments.callingElement EQ 'datasheet' AND Request.User.ID NEQ 0))>
			<cfif arguments.displayMode neq "hidden">
				<cfscript>
					if (NOT StructKeyExists(inputParameters, "secondaryElementType"))
						inputParameters.secondaryElementType = "CustomElement";
					
					/*if (StructKeyExists(Request.Params, 'controlTypeID'))
						ceFormID = Request.Params.controlTypeID;
					else if (StructKeyExists(Request.Params, 'formID'))
						ceFormID = Request.Params.formID;
					else if (StructKeyExists(allAtrs, 'fields'))
						ceFormID = allAtrs.fields.formID[1];*/
					
					switch (arguments.formType)
					{
						case 'Custom Metadata Form':
							elementType = 'MetadataForm';
							infoMethod = "getForms";
							infoArgs.id = formID;
							break;
						default:
							elementType = 'CustomElement';
							infoArgs.elementID = formID;
							break;		
					}
					
					if (StructKeyExists(Request.Params,'pageID') AND elementType EQ 'MetadataForm')
						curPageID = Request.Params.pageID;
					
					parentElementObj = Server.CommonSpot.ObjectFactory.getObject(elementType);
				</cfscript>
				
				<cfinvoke component="#parentElementObj#" method="#infoMethod#" argumentCollection="#infoArgs#" returnvariable="parentFormDetails">
				
				<cfscript>
					if (elementType EQ 'MetadataForm')
						parentFormLabel = parentFormDetails.formName;
					else
						parentFormLabel = parentFormDetails.Name;
					
					if (IsNumeric(inputParameters.assocCustomElement))
						childElementDetails = childElementObj.getList(ID=inputParameters.assocCustomElement);
					else
						childElementDetails = childElementObj.getList(ID=inputParameters.childCustomElement);
					
					childFormName = childElementDetails.Name;
					
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
								ajaxBeanName = fileName;
							}
							else if ( FileExists(ExpandPath('#componentOverridePath#/#fileNamewithExt#')) )
							{
								datamanagerObj = CreateObject("component", "#componentOverridePath#/#fileName#");
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
							datamanagerObj = application.ADF[ajaxBeanName];
						}
					}
					else
					{
						datamanagerObj = application.ADF[ajaxBeanName];
					}	
			
					if (IsNumeric(inputParameters.widthValue))
					{
						widthVal = "#inputParameters.widthValue#";
						if (inputParameters.widthUnit EQ 'percent')
							widthVal = widthVal & '%';
						else
							widthVal = widthVal & 'px';
					}
				
					if (IsNumeric(inputParameters.heightValue))
						heightVal = "#inputParameters.heightValue#px";
				
					application.ADF.scripts.loadJQuery(noConflict=true);
					application.ADF.scripts.loadJQueryUI();
					application.ADF.scripts.loadJQueryDataTables(force=true,loadStyles="false");
				</cfscript>
				
				<cfif inputParameters.sortByType EQ 'manual'>
					<cfoutput>
						<style>
							##customElementData_#uniqueTableAppend# tbody td {cursor: ns-resize;}
						</style>
					</cfoutput>
				</cfif>
				
				<cfif inputParameters.childCustomElement neq ''>
					<cfif (elementType NEQ 'metadataForm' AND newData EQ 0) OR (elementType EQ 'metadataForm' AND curPageID GT 0)>
						<cfoutput>
							#datamanagerObj.renderStyles(propertiesStruct=inputParameters)#
							<table class="cs_data_manager" border="0" cellpadding="2" cellspacing="2" summary="" id="parentTable_#uniqueTableAppend#"></cfoutput>
							<cfif arguments.displayMode eq "editable">
							<cfoutput><tr><td>
								#datamanagerObj.renderButtons(propertiesStruct=inputParameters,currentValues=allAtrs.currentValues,formID=ceFormID,fieldID=arguments.fieldID,parentFormType=elementType,pageID=curPageID)#
							</td></tr></cfoutput>
							</cfif>
							<cfoutput><tr><td>
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
						</cfoutput>
					<cfelse>
						<cfoutput><table class="cs_data_manager" border="0" cellpadding="0" cellspacing="0" summary="">
							<tr><td class="cs_dlgLabel">#childFormName# records can only be added once the #parentFormLabel# record is saved.</td></tr>
							</table>
							#Server.CommonSpot.UDF.tag.input(type="hidden", name=arguments.fieldName, value="")#</cfoutput>
					</cfif>
				</cfif>
				<cfscript>
					renderJSFunctions(argumentCollection=arguments, ajaxBeanName=ajaxBeanName, formID=ceFormID, elementType=elementType, pageID=curPageID, width=widthVal, height=heightVal);
				</cfscript>
				<cfif arguments.displayMode neq "editable">
					<cfoutput>#Server.CommonSpot.UDF.tag.input(type="hidden", name=arguments.fieldName)#</cfoutput>
				</cfif>
			</cfif>
		<cfelse>
			<cfoutput>#Server.CommonSpot.UDF.tag.input(type="hidden", name=arguments.fieldName)#</cfoutput>
		</cfif>
	</cfif>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="ajaxBeanName" type="string" required="yes">
	<cfargument name="formID" type="numeric" required="yes">
	<cfargument name="elementType" type="string" required="yes">
	<cfargument name="pageID" type="numeric" required="yes">
	<cfargument name="width" type="string" required="yes">
	<cfargument name="height" type="string" required="yes">
	
	<cfscript>
		var js = "";
		var inputParameters = Duplicate(arguments.parameters);
		var allAtrs = getAllAttributes();
		var uniqueTableAppend = arguments.fieldID;
		// Ajax URL to the proxy component in the context of the site
		var ajaxComURL = application.ADF.ajaxProxy;
	</cfscript>
	
<cfsavecontent variable="js">
<cfoutput><script type="text/javascript" src="/commonspot/dashboard/js/nondashboard-util.js"></script>
<script type="text/javascript">
<!--
var oTable#uniqueTableAppend# = '';		

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
	
	dataToBeSent#uniqueTableAppend# = { 
			bean: '#arguments.ajaxBeanName#',
			method: 'renderGrid',
			query2array: 0,
			returnformat: 'json',
			formID : #arguments.formID#,
			fieldID : #arguments.fieldID#, 
			parentFormType : '#arguments.elementType#',
			pageID : #arguments.pageID#,
			propertiesStruct : JSON.stringify(<cfoutput>#SerializeJSON(inputParameters)#</cfoutput>),
			currentValues : JSON.stringify(<cfoutput>#SerializeJSON(allAtrs.currentValues)#</cfoutput>),
			displayMode : '#arguments.displayMode#'			
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
			<cfif (ListFindNoCase(inputParameters.interfaceOptions,'editAssoc') OR ListFindNoCase(inputParameters.interfaceOptions,'editChild') OR ListFindNoCase(inputParameters.interfaceOptions,'delete')) AND arguments.displayMode EQ "editable">
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
					"sScrollX": "#arguments.width#",
					"sScrollY": "#arguments.height#",
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
					jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollHead').css('width', "#arguments.width#");								
					jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollHead.dataTables_scrollHeadInner.dataTable').css('width', "#arguments.width#");
					jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollHeadInner').css('width', "#arguments.width#");
					jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollBody').css('height', "#arguments.height#");
					jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollBody').css('width', "#arguments.width#");
					jQuery("##parentTable_#uniqueTableAppend#").find('.dataTables_scrollBody.dataTable').css('width', "#arguments.width#");
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
												bean: '#arguments.ajaxBeanName#',
												method: 'onDrop',
												query2array: 0,
												returnformat: 'json',
												formID: #arguments.formID#,
												movedDataPageID: movedDataPageID, 
												dropAfterDataPageID: dropAfterDataPageID,
												parentFormType : '#arguments.elementType#',
												pageID : #arguments.pageID#,
												propertiesStruct : JSON.stringify(<cfoutput>#SerializeJSON(inputParameters)#</cfoutput>),
												currentValues : JSON.stringify(<cfoutput>#SerializeJSON(allAtrs.currentValues)#</cfoutput>)
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
	.fail(function() 
	{
		document.getElementById('errorMsgSpan').innerHTML = 'An error occurred while trying to perform the operation.';
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

			).done( 
			
				function() { onSuccess_#uniqueTableAppend#('Success'); } 
			);
}
//-->
</script></cfoutput>
</cfsavecontent>
<cfoutput>#js#</cfoutput>
</cffunction>

</cfcomponent>