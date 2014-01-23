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
--->
<cfscript>
	requiredCSversion = 9;
	csVersion = ListFirst(ListLast(request.cp.productversion," "),".");
	
	// Path to this CFT
	cftPath = "/ADF/extensions/customfields/custom_element_datamanager";
	// Path to proxy component in the context of the site
	componentPath = "#request.site.csAppsURL#components";
	// Ajax URL to the proxy component in the context of the site
	ajaxComURL = "#request.site.URL#_cs_apps/components";
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
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission,includeLabel,includeDescription)#
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
					if (FileExists(ExpandPath('#componentPath#/#fileNamewithExt#')))
					{
						datamanagerObj = CreateObject("component", "#componentPath#/#fileName#");
						componentName = fileName;
					}
					else
					{
						datamanagerObj = CreateObject("component", "#componentPath#/custom_element_datamanager_base");
						componentName = 'custom_element_datamanager_base';
					}
				}
				catch(Any e)
				{
					datamanagerObj = CreateObject("component", "#componentPath#/custom_element_datamanager_base");
					componentName = 'custom_element_datamanager_base';
				}
			}
			else
			{
				datamanagerObj = CreateObject("component", "#componentPath#/custom_element_datamanager_base");
				componentName = 'custom_element_datamanager_base';
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
			{
				heightVal = "#inputParameters.heightValue#px";
			}
		
			if (NOT IsDefined('newData'))
			{			
				if (StructKeyExists(attributes.currentValues, 'DateAdded'))
					newData = 0;
				else
					newData = 1;
			}
		
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
							<td class="dataTables_empty">Loading data from server</td>
						</tr>
					</tbody>
					</table>
					</td></tr>
					</table>
				</CFOUTPUT>
			<CFELSE>
			<CFOUTPUT><table class="cs_data_manager" border="0" cellpadding="2" cellspacing="2" summary="">
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
			
			jQuery.ajaxSetup({ cache: false, async: false });	
		
			
			// setTimeout( 'loadData_#uniqueTableAppend#()', 7000 );
			
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
		
			function loadData_#uniqueTableAppend#()
			{
				var res#uniqueTableAppend# = '';
				
				dataToBeSent = { 
						method: 'renderGrid',
						returnformat: 'json',
						formID : #ceFormID#,
						fieldID : #fieldQuery.inputID#, 
						propertiesStruct : JSON.stringify(<cfoutput>#SerializeJSON(inputParameters)#</cfoutput>),
						currentValues : JSON.stringify(<cfoutput>#SerializeJSON(attributes.currentvalues)#</cfoutput>)						
				 };
				jQuery.when(

							jQuery.post( '#ajaxComURL#/#componentName#.cfc', 
										dataToBeSent, 
										null, 
										"json")
				
/*				 
	jQuery.getJSON("#ajaxComURL#/#componentName#.cfc?method=renderGrid&returnformat=json&formID=#ceFormID#&fieldID=#fieldQuery.inputID#&" + "&propertiesStruct=" + JSON.stringify(<cfoutput>#SerializeJSON(inputParameters)#</cfoutput>) + "&currentValues=" + JSON.stringify(<cfoutput>#SerializeJSON(attributes.currentvalues)#</cfoutput>))
*/

				).done(function(res#uniqueTableAppend#) {
				
					var columns = [];
					var columnsList = res#uniqueTableAppend#.aoColumns;
					var columnsArray = columnsList.split(',');
				
					if (columnsList != 'ERRORMSG')
					{
						for(var i=0; i < columnsArray.length; i=i+1){
							if(columnsArray[i] == "DataPageID")
							{
								var obj = {"bVisible": false, "mDataProp": i+1};
							}
							else if (columnsArray[i] == "Actions")
							{
								var obj = { "sTitle": columnsArray[i], "mDataProp": i+1, "sWidth": "42px" };
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
									jQuery(nRow).attr("id", aData[2]);
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
								var tableData;
								jQuery("##customElementData_#uniqueTableAppend# tbody").sortable(
									{
									cursor: "move",
									start:function(event, ui)
										{
										startPosition = ui.item.prevAll().length + 1;
										},
									update: function(event, ui) 
										{
										endPosition = ui.item.prevAll().length + 1;
										startVal = ui.item.attr("id");
										tableData = oTable#uniqueTableAppend#.fnGetNodes()[endPosition-1];
										endVal = jQuery(tableData).attr("id");
										
										dataToBeSent = 
											{ 
												method: 'onDrop',
												returnformat: 'json',
												formID: #ceFormID#,
												movedDataPageID: startVal, 
												dropAfterDataPageID: endVal,
												propertiesStruct : JSON.stringify(<cfoutput>#SerializeJSON(inputParameters)#</cfoutput>),
												currentValues : JSON.stringify(<cfoutput>#SerializeJSON(attributes.currentvalues)#</cfoutput>)						
										 	};
										
										jQuery.post( '#ajaxComURL#/#componentName#.cfc', 
																dataToBeSent, 
																onSuccess_#uniqueTableAppend#, 
																"json");
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
