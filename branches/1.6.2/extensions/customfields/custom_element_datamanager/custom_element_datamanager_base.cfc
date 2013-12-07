<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2013.
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
	custom_element_datamanager_base.cfc
Summary:
	This the base component for the Custom Element Data Manager field
ADF Requirements:
	csData_2_0
	forms_1_1
History:
	2013-11-14 - DJM - Created
	2013-11-15 - GAC - Converted to an ADF custom field type
	2013-11-25 - DJM - Removed code used for getting contents of a checkbox, multicheckbox and radiobutton
	2013-11-27 - DJM - Updated code to allow multiple dataManager fields on the same form
--->
<cfcomponent output="false" displayname="custom element datamanager_base" extends="ADF.core.Base" hint="This the base component for the Custom Element Data Manager field">
	
	<cfscript>
		// Path to this CFT
		variables.cftPath = "/ADF/extensions/customfields/custom_element_datamanager";
	</cfscript>
	
	<cffunction name="getGlobalCE" returnformat="json" access="remote" hint="Method to get teh global custom elements">		
        <cfscript>
			var result = QueryNew('');
			var customElementObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
		</cfscript>
		
		<cftry>
			<cfscript>
				result = customElementObj.getList(type="Global", state="Active");
			</cfscript>
		<cfcatch>
			<CFMODULE TEMPLATE="/commonspot/utilities/log-append.cfm" comment="Error while trying to retrieve the fields: #cfcatch.message# :: #cfcatch.detail#">
			<cfscript>
				result = QueryNew('ErrorMsg');
				QueryAddRow(result, 1);
				QuerySetCell(result, 'ErrorMsg', "Error occurred while trying to retrieve the global custom elements.");
			</cfscript>
		</cfcatch>
		</cftry>
		
        <cfreturn result>
    </cffunction>
	
	<cffunction name="getFields" returnformat="json" access="remote" hint="Get the fields for a custom elemnt">
        <cfargument name="elementID" type="numeric" required="true" hint="Custom element ID">
		
        <cfscript>
			var result = QueryNew('');
			var customElementObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
			var resultData = '';
			var elementDetails = customElementObj.getInfo(elementID=arguments.elementID);
		</cfscript>
		
		<cftry>
			<cfscript>
				resultData = customElementObj.getFields(elementID=arguments.elementID);
			</cfscript>
			<cfquery name="result" dbtype="query">
				SELECT ID, Label AS Name, Type, '#elementDetails.Name#' AS CustomElementName
				  FROM resultData
			</cfquery>
		<cfcatch>
			<CFMODULE TEMPLATE="/commonspot/utilities/log-append.cfm" comment="Error while trying to retrieve the fields: #cfcatch.message# :: #cfcatch.detail#">
			<cfscript>
				result = QueryNew('ErrorMsg');
				QueryAddRow(result, 1);
				QuerySetCell(result, 'ErrorMsg', "Error occurred while trying to retrieve data the fields for the element.");
			</cfscript>
		</cfcatch>
		</cftry>
		
        <cfreturn result>
    </cffunction>
	
	<cffunction name="getFieldIDList" returnformat="json" access="remote" hint="Get the fields for a custom elemnt">
        <cfargument name="elementID" type="numeric" required="true" hint="Custom element ID">
		
        <cfscript>
			var result = QueryNew('');
			var customElementObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
			var resultData = '';
			var elementDetails = customElementObj.getInfo(elementID=arguments.elementID);
		</cfscript>
		
		<cftry>
			<cfscript>
				resultData = customElementObj.getFields(elementID=arguments.elementID);
				result = ValueList(resultData.ID);
			</cfscript>
		<cfcatch>
			<CFMODULE TEMPLATE="/commonspot/utilities/log-append.cfm" comment="Error while trying to retrieve the fields: #cfcatch.message# :: #cfcatch.detail#">
			<cfscript>
				result = 'Error';
			</cfscript>
		</cfcatch>
		</cftry>
		
        <cfreturn result>
    </cffunction>
	
	<cffunction name="renderStyles" access="public" returntype="void" hint="Method to render the styles for datamanager">		
        <cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
		<cfscript>
			var renderData = '';
		</cfscript>
		<cfsavecontent variable="renderData">
			<cfoutput><link rel="stylesheet" type="text/css" href="#variables.cftPath#/custom_element_datamanager_styles.css" /></cfoutput>
		</cfsavecontent>
		<cfoutput>#renderData#</cfoutput>
    </cffunction>
	
	<cffunction name="renderButtons" access="public" returntype="void" hint="Method to render the add new and add existing buttons">
    	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
		<cfargument name="currentValues" type="struct" required="true" hint="Current values structure for the field">
		<cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
		<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
		<cfscript>
			var renderData = '';
			var inputPropStruct = arguments.propertiesStruct;
		</cfscript>
		<cfif ListFindNoCase(inputPropStruct.interfaceOptions,'new') OR ListFindNoCase(inputPropStruct.interfaceOptions,'existing')>
			<cfsavecontent variable="renderData">
				<cfoutput><tr><td></cfoutput>
				<cfif ListFindNoCase(inputPropStruct.interfaceOptions,'new')>
					<cfoutput>#renderAddNewButton(argumentCollection=arguments)#</cfoutput>
				</cfif>
				<cfif ListFindNoCase(inputPropStruct.interfaceOptions,'existing')>
					<cfoutput>#renderAddExistingButton(argumentCollection=arguments)#</cfoutput>
				</cfif>
				<cfoutput></td></tr></cfoutput>
			</cfsavecontent>
		</cfif>
		<cfoutput>#renderData#</cfoutput>
    </cffunction>
	
	<cffunction name="renderAddNewButton" access="private" returntype="void" hint="Method to render the add new button">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
		<cfargument name="currentValues" type="struct" required="true" hint="Current values structure for the field">
		<cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
		<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
		<cfscript>
			var renderData = '';
			var inputPropStruct = arguments.propertiesStruct;
			var curValuesStruct = arguments.currentValues;
			var linkedIDSelectedName = 'fic_#arguments.formID#_#inputPropStruct.parentUniqueField#';
			var assocParameters  = 'csAssoc_assocCE=#propertiesStruct.assocCustomElement#&csAssoc_ParentInstanceIDField=#propertiesStruct.parentInstanceIDField#&csAssoc_ChildInstanceIDField=#propertiesStruct.childInstanceIDField#&csAssoc_ChildUniqueField=#propertiesStruct.childUniqueField#';
			assocParameters = ListAppend(assocParameters, 'csAssoc_ParentInstanceID=#curValuesStruct[linkedIDSelectedName]#', '&');
			assocParameters = ListAppend(assocParameters, 'csAssoc_ChildInstanceID=', '&');
		</cfscript>
		
		<cfsavecontent variable="renderData">
			<cfoutput>#Server.CommonSpot.UDF.tag.input(type="button", class="clsPushButton", name="addNew", id="addNew", value=getAddNewButtonName(propertiesStruct=arguments.propertiesStruct), onclick="javascript:top.commonspot.lightbox.openDialog('#Request.SubSite.DlgLoader#?csModule=controls/custom/submit-data&controlTypeID=#propertiesStruct.childCustomElement#&formID=#propertiesStruct.childCustomElement#&newData=1&dataPageID=0&dataControlID=0&linkageFieldID=#propertiesStruct.childLinkedField#&linkedFieldValue=#curValuesStruct[linkedIDSelectedName]#&openFrom=datamanager&callbackFunction=loadData_#arguments.fieldID#&#assocParameters#')")#</cfoutput>
		</cfsavecontent>
		<cfoutput>#renderData#</cfoutput>
	</cffunction>
	
	<cffunction name="getAddNewButtonName" access="private" returntype="string" hint="Method to get the label displayed for add new button">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
		<cfscript>
			var buttonLabel = 'Add New...';
			return buttonLabel;
		</cfscript>
	</cffunction>
	
	<cffunction name="renderAddExistingButton" access="private" returntype="void" hint="Method to render the add existing button">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
		<cfargument name="currentValues" type="struct" required="true" hint="Current values structure for the field">
		<cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
		<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
		<cfscript>
			var renderData = '';
			var inputPropStruct = arguments.propertiesStruct;
			var curValuesStruct = arguments.currentValues;
			var linkedIDSelectedName = 'fic_#arguments.formID#_#inputPropStruct.parentUniqueField#';
		</cfscript>
		
		<cfsavecontent variable="renderData">
			<cfoutput>#Server.CommonSpot.UDF.tag.input(type="button", class="clsPushButton", name="addExisting", id="addExisting", value=getAddExistingButtonName(propertiesStruct=arguments.propertiesStruct), onclick="javascript:top.commonspot.lightbox.openDialog('#Request.SubSite.DlgLoader#?csModule=controls/custom/submit-data&controlTypeID=#inputPropStruct.assocCustomElement#&formID=#inputPropStruct.assocCustomElement#&newData=1&dataPageID=0&dataControlID=0&linkageFieldID=#inputPropStruct.parentInstanceIDField#&linkedFieldValue=#curValuesStruct[linkedIDSelectedName]#&openFrom=datamanager&callbackFunction=loadData_#arguments.fieldID#')")#</cfoutput>
		</cfsavecontent>
		<cfoutput>#renderData#</cfoutput>
	</cffunction>
	
	<cffunction name="getAddExistingButtonName" access="private" returntype="string" hint="Method to get the label displayed for add existing button">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
		<cfscript>
			var buttonLabel = 'Add Existing...';
			return buttonLabel;
		</cfscript>
	</cffunction>
	
	<cffunction name="renderGrid" access="remote" returntype="void" hint="Method to render the datamanger grid">		
        <cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
		<cfargument name="propertiesStruct" type="string" required="true" hint="Properties structure for the field in json format">
		<cfargument name="currentValues" type="string" required="true" hint="Current values structure for the field in json format">
		<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
		<cfscript>
			var inputPropStruct = StructNew();
			var curValuesStruct = StructNew();
			var dataRecords = QueryNew('');
			var displayData = QueryNew('');
			
			if (IsJSON(arguments.propertiesStruct))
			{
				inputPropStruct = DeserializeJSON(arguments.propertiesStruct);
			}
			if (IsJSON(arguments.currentValues))
			{
				curValuesStruct = DeserializeJSON(arguments.currentValues);
			}
			
			dataRecords = queryData(formID=arguments.formID,propertiesStruct=inputPropStruct,currentValues=curValuesStruct);
			
			if (NOT StructKeyExists(dataRecords, 'errorMsg'))
				displayData = getDisplayData(fieldID=arguments.fieldID,propertiesStruct=inputPropStruct,dataRecords=dataRecords.qry,fieldMapStruct=dataRecords.fieldMapStruct,fieldOrderList=dataRecords.fieldOrderList);
		</cfscript>
		<cfoutput>#SerializeJSON(displayData)#</cfoutput>
    </cffunction>
	
	<cffunction name="queryData" returntype="struct" access="private" hint="Get the data for the fields">
        <cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
		<cfargument name="currentValues" type="struct" required="true" hint="Current values structure for the field">
        <cfscript>
			var inputPropStruct = arguments.propertiesStruct;
			var curValuesStruct = arguments.currentValues;
			var linkedIDSelectedName = 'fic_#arguments.formID#_#inputPropStruct.parentUniqueField#';
			var defaultSortColumn = '';
			var defaultSortOrder = '';
			var resultData = QueryNew('');		
			var ceObj = Server.CommonSpot.ObjectFactory.getObject("CustomElement");
			var colList = inputPropStruct.displayFields;
			var colArray = ArrayNew(1);
			var childFormFields = "";
			var childFormFields = QUeryNew('');
			var fldName = "";
			var allChildColList = "";
			var allChildColNameList = '';
			var childFormFieldsStruct = StructNew();
			var childOrderColumnName = "";
			var valueFieldName = "";
			var assocFormFields = "";
			var allAssocColList = "";
			var allAssocColNameList = '';
			var i = 0;
			var childColNameList = '';
			var assocColNameList = '';
			var assocFormFieldsStruct = StructNew();			
			var assocOrderColumnName = "";
			var displayColNames = "";
			var assocDisplayColNames = '';
			var childDisplayColNames = '';
			var getParentLinkedField =  QueryNew('');
			var parentStatementsArray = ArrayNew(1);
			var parentFilterArray = ArrayNew(1);
			var parentData = QueryNew('');
			var statementsArray = ArrayNew(1);
			var childFilterExpression = '';
			var assocFieldDetail = QueryNew('');
			var assocReqFieldName = '';
			var assocFilterExpression = '';
			var assocStatementsArray = ArrayNew(1);
			var assocFilterArray = ArrayNew(1);
			var assocData = QueryNew('PageID');
			var assocColumnList = '';
			var childFilterArray = ArrayNew(1);
			var filteredData = '';
			var childColumnList = '';
			var returnStruct = StructNew();
			var assocFormFieldsDetailedStruct = StructNew();
			var childFormFieldsDetailedStruct = StructNew();
			var formFieldsStruct = StructNew();
			var returnData = QueryNew('');
			
			if (inputPropStruct.sortByType EQ 'auto')
			{
				defaultSortColumn = inputPropStruct.sortByField;
				defaultSortOrder = inputPropStruct.sortByDir;
			}
			else if (inputPropStruct.sortByType EQ 'manual')
			{
				defaultSortColumn = inputPropStruct.positionField;
				defaultSortOrder = "ASC";
			}
			
			if(Len(inputPropStruct.displayFields))
			{
				if (NOT ListFindNoCase(colList, defaultSortColumn))
					colList = ListAppend(colList, defaultSortColumn);
					
				if (NOT ListFindNoCase(colList, inputPropStruct.childUniqueField))
					colList = ListAppend(colList, inputPropStruct.childUniqueField);
			}
			
			colArray = ListToArray(colList);
		</cfscript>
		
		<cftry>
			<cfset childFormFields = ceObj.getFields(elementid=inputPropStruct.childCustomElement)>
			
			<!--- List of available columns --->
			<cfloop query="childFormFields">
				<cfscript>
					fldName = childFormFields.Name;
					if (FindNoCase("FIC_", fldName) eq 1)
						fldName = Mid(fldName, 5, 999);
					if (NOT ListFindNoCase(allChildColList, childFormFields.ID))
						allChildColList = ListAppend(allChildColList, childFormFields.ID);
					
					if (NOT ListFindNoCase(allChildColNameList, fldName))
						allChildColNameList = ListAppend(allChildColNameList, fldName);
						
					childFormFieldsStruct[childFormFields.ID] = fldName;
					childFormFieldsDetailedStruct[fldName] = StructNew();
					childFormFieldsDetailedStruct[fldName]['FormID'] = inputPropStruct.childCustomElement;
					childFormFieldsDetailedStruct[fldName]['FieldID'] = childFormFields.ID;
					childFormFieldsDetailedStruct[fldName]['FieldType'] = childFormFields.Type;
					
					if (defaultSortColumn EQ childFormFields.ID)
						childOrderColumnName = fldName;
					
					if (inputPropStruct.childUniqueField EQ childFormFields.ID)
						valueFieldName = fldName;
				</cfscript>
			</cfloop>
			<cfif IsNumeric(inputPropStruct.assocCustomElement)>
				<cfset assocFormFields = ceObj.getFields(elementid=inputPropStruct.assocCustomElement)>

				<!--- List of available columns --->
				<cfloop query="assocFormFields">	
					<cfscript>
						fldName = assocFormFields.Name;
						if (FindNoCase("FIC_", fldName) eq 1)
							fldName = Mid(fldName, 5, 999);
						if (NOT ListFindNoCase(allAssocColList, assocFormFields.ID))
							allAssocColList = ListAppend(allAssocColList, assocFormFields.ID);
						
						if (NOT ListFindNoCase(allAssocColNameList, fldName))
							allAssocColNameList = ListAppend(allAssocColNameList, fldName);
						
						assocFormFieldsStruct[assocFormFields.ID] = fldName;
						assocFormFieldsDetailedStruct[fldName] = StructNew();
						assocFormFieldsDetailedStruct[fldName]['FormID'] = inputPropStruct.assocCustomElement;
						assocFormFieldsDetailedStruct[fldName]['FieldID'] = assocFormFields.ID;
						assocFormFieldsDetailedStruct[fldName]['FieldType'] = assocFormFields.Type;
						
						if (defaultSortColumn EQ assocFormFields.ID)
							assocOrderColumnName = fldName;
					</cfscript>
				</cfloop>
			</cfif>
			<cfscript>
				if (ArrayLen(colArray))
				{
					for (i = 1; i lte ArrayLen(colArray); i = i + 1)
					{
						if (ListFindNoCase(allChildColList, colArray[i]))
						{
							childColNameList = ListAppend(childColNameList, childFormFieldsStruct[colArray[i]]);
							if (ListFindNoCase(inputPropStruct.displayFields, colArray[i]))
							{
								displayColNames = ListAppend(displayColNames, childFormFieldsStruct[colArray[i]]);
								childDisplayColNames = ListAppend(childDisplayColNames, childFormFieldsStruct[colArray[i]]);
								
								formFieldsStruct[childFormFieldsStruct[colArray[i]]] = childFormFieldsDetailedStruct[childFormFieldsStruct[colArray[i]]];
							}
						}
						if (ListFindNoCase(allAssocColList, colArray[i]))
						{
							assocColNameList = ListAppend(assocColNameList, assocFormFieldsStruct[colArray[i]]);
							if (ListFindNoCase(inputPropStruct.displayFields, colArray[i]))
							{
								if (ListFindNoCase(displayColNames, assocFormFieldsStruct[colArray[i]]))
								{
									displayColNames = ListAppend(displayColNames, '#assocFormFieldsStruct[colArray[i]]#_assoc');
									assocDisplayColNames = ListAppend(assocDisplayColNames, '#assocFormFieldsStruct[colArray[i]]#_assoc');
									formFieldsStruct['#assocFormFieldsStruct[colArray[i]]#_assoc'] = assocFormFieldsDetailedStruct[assocFormFieldsStruct[colArray[i]]];
								}
								else
								{
									displayColNames = ListAppend(displayColNames, assocFormFieldsStruct[colArray[i]]);
									assocDisplayColNames = ListAppend(assocDisplayColNames, assocFormFieldsStruct[colArray[i]]);
									formFieldsStruct[assocFormFieldsStruct[colArray[i]]] = assocFormFieldsDetailedStruct[assocFormFieldsStruct[colArray[i]]];
								}
							}
						}
					}
				}
				
				returnData = QueryNew('DataPageID,#displayColNames#');
				
				getParentLinkedField = ceObj.getFields(elementID=arguments.formID,fieldID=inputPropStruct.parentUniqueField);
				
				if (getParentLinkedField.RecordCount)
				{
					parentStatementsArray[1] = ceObj.createStandardFilterStatement(customElementID=arguments.formID,fieldIDorName=getParentLinkedField.ID,operator='Equals',value=curValuesStruct[linkedIDSelectedName]);
				
					parentFilterArray = ceObj.createQueryEngineFilter(filterStatementArray=parentStatementsArray,filterExpression='1');
				
					parentData = ceObj.getRecordsFromSavedFilter(elementID=arguments.formID,queryEngineFilter=parentFilterArray,columnList=getParentLinkedField.Name,orderBy=ReplaceNoCase(getParentLinkedField.Name,'FIC_',''),orderByDirection="ASC");
			
				}
			</cfscript>
			
			<cfif parentData.RecordCount>
				<cfscript>
					if(NOT IsNumeric(inputPropStruct.assocCustomElement))
					{
						statementsArray[1] = ceObj.createStandardFilterStatement(customElementID=inputPropStruct.childCustomElement,fieldIDorName=inputPropStruct.childLinkedField,operator='Equals',value=curValuesStruct[linkedIDSelectedName]);
						if(Len(inputPropStruct.inactiveField) AND Len(inputPropStruct.inactiveFieldValue))
						{
							statementsArray[2] = ceObj.createStandardFilterStatement(customElementID=inputPropStruct.childCustomElement,fieldIDorName=inputPropStruct.inactiveField,operator='Not Equal',value=inputPropStruct.inactiveFieldValue);
							childFilterExpression = '1 AND 2';
						}
						else
							childFilterExpression = '1';
					}
					else
					{						
						assocFieldDetail = ceObj.getFields(elementID=inputPropStruct.assocCustomElement,fieldID=inputPropStruct.childInstanceIDField);
						assocReqFieldName = assocFieldDetail.Name;
						if (FindNoCase("FIC_", assocReqFieldName) eq 1)
							assocReqFieldName = Mid(assocReqFieldName, 5, 999);
						assocStatementsArray[1] = ceObj.createStandardFilterStatement(customElementID=inputPropStruct.assocCustomElement,fieldIDorName=inputPropStruct.parentInstanceIDField,operator='Equals',value=curValuesStruct[linkedIDSelectedName]);
						if(Len(inputPropStruct.inactiveField) AND Len(inputPropStruct.inactiveFieldValue))
						{
							assocStatementsArray[2] = ceObj.createStandardFilterStatement(customElementID=inputPropStruct.assocCustomElement,fieldIDorName=inputPropStruct.inactiveField,operator='Not Equal',value=inputPropStruct.inactiveFieldValue);
							assocFilterExpression = '1 AND 2';
						}
						else
							assocFilterExpression = '1';
						assocFilterArray = ceObj.createQueryEngineFilter(filterStatementArray=assocStatementsArray,filterExpression=assocFilterExpression);
						
						if (Len(assocColNameList))
							assocColumnList = '#assocReqFieldName#,#assocColNameList#';
						else
							assocColumnList = assocReqFieldName;
						
						assocData = ceObj.getRecordsFromSavedFilter(elementID=inputPropStruct.assocCustomElement,queryEngineFilter=assocFilterArray,columnList=assocColumnList,orderBy=assocReqFieldName, orderByDirection="ASC");
						
						if (assocData.RecordCount)
						{
							assocColumnList = assocData.columnList;
							statementsArray[1] = ceObj.createStandardFilterStatement(customElementID=inputPropStruct.childCustomElement,fieldIDorName=inputPropStruct.childUniqueField,operator='Value Contained In List',value=ArrayToList(assocData[assocReqFieldName]));
							childFilterExpression = '1';
						}
					}
					childFilterArray = ceObj.createQueryEngineFilter(filterStatementArray=statementsArray,filterExpression=childFilterExpression);
					childColumnList = '#childColNameList#,#valueFieldName#';
					filteredData = ceObj.getRecordsFromSavedFilter(elementID=inputPropStruct.childCustomElement,queryEngineFilter=childFilterArray,columnList=childColumnList);					
				</cfscript>
				
				<cfquery name="returnData" dbtype="query">
					SELECT 
					<cfif IsNumeric(inputPropStruct.assocCustomElement)>
						assocData.PageID AS DataPageID, assocData.ControlID AS DataControlID
					<cfelse>
						filteredData.PageID AS DataPageID, filteredData.ControlID AS DataControlID
					</cfif>
					<cfif ListLen(displayColNames)>
						,
					</cfif>
					<cfloop from="1" to="#ListLen(displayColNames)#" index="i">
							<cfif ListFindNoCase(childDisplayColNames, ListGetAt(displayColNames,i))>
								filteredData.#ListGetAt(displayColNames,i)#
							<cfelseif ListFindNoCase(assocDisplayColNames, ListGetAt(displayColNames,i))>
								<cfif ListFindNoCase(assocColumnList, ListGetAt(displayColNames,i))>
									assocData.#ListGetAt(displayColNames,i)#
								<cfelseif ListLast(ListGetAt(displayColNames,i), '_') EQ 'assoc' AND ListFindNoCase(assocColumnList, Mid(ListGetAt(displayColNames,i),1,ListLast(ListGetAt(displayColNames,i), '_')))>
									assocData.#Mid(ListGetAt(displayColNames,i),1,ListLast(ListGetAt(displayColNames,i), '_'))# AS #ListGetAt(displayColNames,i)#
								</cfif>
							</cfif>
						<cfif ListLen(displayColNames) GT 1 AND i NEQ ListLen(displayColNames)>
						,
						</cfif>
					</cfloop>
					  FROM filteredData
				<cfif IsNumeric(inputPropStruct.assocCustomElement)>
					  ,assocData WHERE filteredData.#valueFieldName# = assocData.#assocReqFieldName#
				</cfif>
				<cfif Len(childOrderColumnName)>
				 ORDER BY filteredData.#childOrderColumnName# #defaultSortOrder#
				<cfelseif Len(assocOrderColumnName)>
				 ORDER BY assocData.#assocOrderColumnName# #defaultSortOrder#
				</cfif>
				</cfquery>
			</cfif>
			<cfscript>
				returnStruct['qry'] = returnData;
				returnStruct['fieldMapStruct'] = formFieldsStruct;
				returnStruct['fieldOrderList'] = '#displayColNames#';
			</cfscript>
		<cfcatch>
			<CFMODULE TEMPLATE="/commonspot/utilities/log-append.cfm" comment="Error while trying to retrieve data for the child element: #cfcatch.message# :: #cfcatch.detail#">
			<cfscript>
				returnStruct['errorMsg'] = "Error occurred while trying to retrieve data for the child element.";
			</cfscript>
		</cfcatch>
		</cftry>
		<cfreturn returnStruct>
	</cffunction>
	
	<cffunction name="getDisplayData" returntype="struct" access="private" hint="Get the data for the fields">
		<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
		<cfargument name="dataRecords" type="query" required="true" hint="Query containing the data records">
		<cfargument name="fieldMapStruct" type="struct" required="true" hint="Structure containing the field types mapping details for the fields">
		<cfargument name="fieldOrderList" type="string" required="true" hint="Order in which the fields need to be returned">
		
		<cfscript>
			var inputPropStruct = arguments.propertiesStruct;
			var returnData = QueryNew('');
			var childData = arguments.dataRecords;
			var dataColumnList = ListPrepend(arguments.fieldOrderList,'DataPageID');
			var actionColumnArray = ArrayNew(1);
			var renderData = '';
			var mappingStruct = arguments.fieldMapStruct;
			var dataColumnArray = ArrayNew(1);
			var i = 0;
			var formFieldType = '';
			var formFieldID = 0;
			var formFieldValue = '';
			var returnStruct = StructNew();
			dataColumnArray = ListToArray(dataColumnList);
		</cfscript>
		
		<cftry>
			<cfif ListFindNoCase(inputPropStruct.interfaceOptions,'edit') OR ListFindNoCase(inputPropStruct.interfaceOptions,'delete')>
				<cfloop query="childData">
					<cfsavecontent variable="renderData">
						<cfoutput>#renderActionColumns(fieldID=arguments.fieldID,propertiesStruct=inputPropStruct,dataPageID=childData.DataPageID,dataControlID=ChildData.DataControlID)#</cfoutput>
					</cfsavecontent>
					<cfscript>
						actionColumnArray[childData.currentRow] = renderData;
						for(i=1;i LTE ArrayLen(dataColumnArray);i=i+1)
						{
							if (StructKeyExists(mappingStruct, dataColumnArray[i]))
							{
								formFieldType = mappingStruct[dataColumnArray[i]].fieldType;
								formFieldID = mappingStruct[dataColumnArray[i]].fieldID;
								formFieldValue = childData[dataColumnArray[i]];
								if(Len(formFieldValue))
								{
									switch (formFieldType)
									{
										case 'Custom Element Select Field':
											fieldUpdValue = getContent_ceSelect(fieldID=formFieldID,fieldValue='#formFieldValue#');
											break;
										case 'select':
											fieldUpdValue = getContent_select(fieldID=formFieldID,fieldValue='#formFieldValue#');
											break;
										case 'csextendedurl':
										case 'cs_url':
											fieldUpdValue = getContent_csurl(fieldID=formFieldID,fieldValue='#formFieldValue#');
											break;
										default:
											fieldUpdValue = formFieldValue;
											break;
									}
									QuerySetCell(childData, dataColumnArray[i], fieldUpdValue, childData.CurrentRow);
								}
							}
						}
					</cfscript>
					<cfset actionColumnArray[childData.currentRow] = renderData>
				</cfloop>
				<cfscript>
					QueryAddColumn(childData, 'Actions', 'varchar', actionColumnArray);
					dataColumnList = ListPrepend(dataColumnList, 'Actions');
				</cfscript>
			</cfif>						
			<cfquery name="returnData" dbtype="query">
				SELECT #dataColumnList#
				  FROM childData
			</cfquery>
			<cfscript>
				returnStruct['aoColumns'] = '#dataColumnList#';
				returnStruct['aaData'] = QueryToArray(queryData=returnData,fieldOrderList=dataColumnList);
  			</cfscript>
		<cfcatch>
			<CFMODULE TEMPLATE="/commonspot/utilities/log-append.cfm" comment="Error while trying to set the display data for the child element: #cfcatch.message# :: #cfcatch.detail#">
			<cfscript>
				returnData = QueryNew('ErrorMsg');
				QueryAddRow(returnData, 1);
				QuerySetCell(returnData, 'ErrorMsg', "Error occurred while trying to retrieve data for the child element.");
				returnStruct['aoColumns'] = 'ErrorMsg';
				returnStruct['aaData'] = QueryToArray(queryData=returnData,fieldOrderList='ErrorMsg');
			</cfscript>
		</cfcatch>
		</cftry>
		
		<cfreturn returnStruct>
	</cffunction>
	
	<cffunction name="getContent_ceSelect" returntype="string" access="private" hint="Function to get the content of the custom element select element">
		<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
		<cfargument name="fieldValue" type="string" required="true" hint="Value of the field">
		<cfscript>
			var paramsData = '';
			var paramsStruct = StructNew();
			var returnString = arguments.fieldValue;
			var ceDataArray = ArrayNew(1);
			var valueIndex = 0;
			var i = 0;
			var displayString = '';
		</cfscript>
		
		<cfquery name="paramsData" datasource="#Request.Site.Datasource#">
			SELECT Params
			  FROM FormInputControl
			 WHERE ID = <cfqueryparam value="#arguments.fieldID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfif paramsData.RecordCount>
			<cfscript>
				paramsStruct = Server.CommonSpot.UDF.util.WDDXDecode(paramsData.Params);
			</cfscript>
			<cfif Len(paramsStruct.customElement)>
				<cfscript>
					if(StructKeyExists(paramsStruct,"activeFlagField") and Len(paramsStruct.activeFlagField)
							and StructKeyExists(paramsStruct,"activeFlagValue") and Len(paramsStruct.activeFlagValue))
					{
						if((TRIM(LEFT(paramsStruct.activeFlagValue,1)) EQ "[") AND (TRIM(RIGHT(paramsStruct.activeFlagValue,1)) EQ "]"))
						{
							paramsStruct.activeFlagValue = MID(paramsStruct.activeFlagValue, 2, LEN(paramsStruct.activeFlagValue)-2);
							paramsStruct.activeFlagValue = Evaluate(paramsStruct.activeFlagValue);
						}
						ceDataArray = application.ADF.ceData.getCEData(paramsStruct.customElement,paramsStruct.activeFlagField,paramsStruct.activeFlagValue);
					}
					else
					{
						ceDataArray = application.ADF.ceData.getCEData(paramsStruct.customElement);
					}
					
					if (ArrayLen(ceDataArray))
					{
						for (i=1; i LTE ArrayLen(ceDataArray); i=i+1)
						{
							valueIndex = ListFindNoCase(returnString,ceDataArray[i].Values['#paramsStruct.valueField#']);
							if(valueIndex)
							{
								if (paramsStruct.displayField eq "--Other--" and Len(paramsStruct.displayFieldBuilder))
								{
									displayString = application.ADF.forms.renderDataValueStringfromFieldMask(ceDataArray[i].Values, paramsStruct.displayFieldBuilder);
								}
								else
									displayString = ceDataArray[i].Values['#paramsStruct.displayField#'];
								
								returnString = ListSetAt(returnString, valueIndex, displayString);
							}
						}
					}
				</cfscript>
			</cfif>
		</cfif>
		<cfreturn returnString>
	</cffunction>
	
	<cffunction name="getContent_select" returntype="string" access="private" hint="Get the content of the selection element">
		<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
		<cfargument name="fieldValue" type="string" required="true" hint="Value of the field">
		<cfscript>
			var paramsData = '';
			var paramsStruct = StructNew();
			var selectOptions = StructNew();
			var returnString = arguments.fieldValue;
			var fieldValueArray = ListToArray(Arguments.fieldValue);
			var i = 0;
			var optionValuesString = '';
			var valueIndex = 0;
			var displayFieldID = '';
			var valueFieldID = '';
		</cfscript>
		
		<cfquery name="paramsData" datasource="#Request.Site.Datasource#">
			SELECT Params
			  FROM FormInputControl
			 WHERE ID = <cfqueryparam value="#arguments.fieldID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfif paramsData.RecordCount>
			<cfscript>
				paramsStruct = Server.CommonSpot.UDF.util.WDDXDecode(paramsData.Params);
				if (StructKeyExists(paramsStruct, 'displayfieldid'))
					displayFieldID = paramsStruct.displayfieldid;
				if (StructKeyExists(paramsStruct, 'valuefieldid'))
					valueFieldID = paramsStruct.valuefieldid;
			</cfscript>
			<cfmodule template="/commonspot/metadata/form_control/input_control/resolve_optionlist.cfm"
					valsource="#paramsStruct.valSource#"
					valuelist="#paramsStruct.valList#"
					querystring="#paramsStruct.query#"
					queryDSN="#paramsStruct.queryDSN#"
					displaycolumn="#paramsStruct.dispCol#"
					valuecolumn="#paramsStruct.valCol#"
					userdefinedexpression="#paramsStruct.udef#"
					elementid="#paramsStruct.elementid#"
					fieldid="#paramsStruct.fieldid#"
					displayfieldid="#displayFieldID#"
					valuefieldid="#valueFieldID#"	
					filter="#paramsStruct.filter#"
					sortcolumn="#paramsStruct.sortcol#"
					return="selectOptions">
			<cfscript>
				if (ArrayLen(selectOptions.optionValues) AND ArrayLen(selectOptions.optionText))
				{
					optionValuesString = ArrayToList(selectOptions.optionValues);
					returnString = '';
					for (i=1; i LTE ArrayLen(fieldValueArray); i=i+1)
					{
						valueIndex = ListFindNoCase(optionValuesString, fieldValueArray[i]);
						if (valueIndex)					
							returnString = ListAppend(returnString, selectOptions.optionText[valueIndex]);
						else
							returnString = ListAppend(returnString, fieldValueArray[i]);
					}
				}
			</cfscript>
		</cfif>
		<cfreturn returnString>
	</cffunction>
	
	<cffunction name="renderActionColumns" returntype="void" access="private" hint="Get the data for the fields">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
		<cfargument name="dataPageID" type="numeric" required="true" hint="Data page id for the record">
		<cfargument name="dataControlID" type="numeric" required="true" hint="Data control id for the record">
		<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
		<cfscript>
			var inputPropStruct = arguments.propertiesStruct;
			var renderData = '';
		</cfscript>
		<cfsavecontent variable="renderData">
		<cfif ListFindNoCase(inputPropStruct.interfaceOptions,'edit')>
			<cfoutput>#renderEditIcon(argumentCollection=arguments)#</cfoutput>
		</cfif>
		<cfif ListFindNoCase(inputPropStruct.interfaceOptions,'delete')>
			<cfoutput>#renderDeleteIcon(argumentCollection=arguments)#</cfoutput>
		</cfif>
		</cfsavecontent>
		<cfoutput>#renderData#</cfoutput>
	</cffunction>
	
	<cffunction name="renderEditIcon" returntype="void" access="private" hint="Render the edit action">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
		<cfargument name="dataPageID" type="numeric" required="true" hint="Data page id for the record">
		<cfargument name="dataControlID" type="numeric" required="true" hint="Data control id for the record">
		<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
		<cfscript>
			var inputPropStruct = arguments.propertiesStruct;
			var renderData = '';
			var qryString = '';
			
			if(NOT IsNumeric(inputPropStruct.assocCustomElement))
				qryString = 'formID=#inputPropStruct.childCustomElement#&linkageFieldID=#inputPropStruct.childLinkedField#';
			else
				qryString = 'formID=#inputPropStruct.assocCustomElement#&linkageFieldID=#inputPropStruct.parentInstanceIDField#';
		</cfscript>
		<cfsavecontent variable="renderData">
			<cfoutput><img onclick="javascript:top.commonspot.lightbox.openDialog(&##39;#Request.SubSite.DlgLoader#?csModule=controls/custom/submit-data&newData=0&dataPageID=#arguments.dataPageID#&dataControlID=#arguments.dataControlID#&openFrom=datamanager&callbackFunction=loadData_#arguments.fieldID#&#qryString#&##39;);" class="actionIcon" title="Edit" alt="Edit" src="/commonspot/dashboard/icons/edit.png"></cfoutput>
		</cfsavecontent>
		<cfoutput>#renderData#</cfoutput>
	</cffunction>
	
	<cffunction name="renderDeleteIcon" returntype="void" access="private" hint="Render the delete action">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
		<cfargument name="dataPageID" type="numeric" required="true" hint="Data page id for the record">
		<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
		<cfscript>
			var inputPropStruct = arguments.propertiesStruct;
			var renderData = '';
			var deleteFormID = 0;
			
			if(NOT IsNumeric(inputPropStruct.assocCustomElement))
				deleteFormID = inputPropStruct.childCustomElement;
			else
				deleteFormID = inputPropStruct.assocCustomElement;
		</cfscript>
		<cfsavecontent variable="renderData">
			<cfoutput><img onclick="javascript:top.commonspot.lightbox.openDialog(&##39;#Request.SubSite.DlgLoader#?csModule=controls/datasheet/cs-delete-form-data&mode=results&callbackFunction=loadData_#arguments.fieldID#&realTargetModule=controls/datasheet/cs-delete-form-data&formID=#deleteFormID#&pageID=#arguments.dataPageID#&##39;);" class="actionIcon" title="Delete" alt="Delete" src="/commonspot/dashboard/icons/bin.png"></cfoutput>
		</cfsavecontent>
		<cfoutput>#renderData#</cfoutput>
	</cffunction>
	
	<cffunction name="onDrop" returnformat="json" access="remote" hint="Method to reorder the values fo a custom element">
		<cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
		<cfargument name="propertiesStruct" type="string" required="true" hint="Properties structure for the field in json format">
		<cfargument name="currentValues" type="string" required="true" hint="Current values structure for the field in json format">
        <cfargument name="movedDataPageID" type="numeric" required="true" hint="The unique data pageid for the record from start pos">
		<cfargument name="dropAfterDataPageID" type="numeric" required="true" hint="The unique data pageid for the record from end pos">
        <cfscript>
			var orderOp = '';
			var qOrderedResults = QueryNew('');
			var loopStart = 0;
			var loopEnd = 0;
			var newOrderValue = 0;
			var newOrderValueForSelected = 0;
			var updateRec = '';
			var updateCurRec = '';
			var sResult = 'Success';
			var inputPropStruct = StructNew();
			var curValuesStruct = StructNew();
			var dataFormID = 0;
			var posStruct = StructNew();
			var rangeRecords = QueryNew('');
			
			if (IsJSON(arguments.propertiesStruct))
			{
				inputPropStruct = DeserializeJSON(arguments.propertiesStruct);
			}
			
			if (IsJSON(arguments.currentValues))
			{
				curValuesStruct = DeserializeJSON(arguments.currentValues);
			}
			
			if (IsNumeric(inputPropStruct.assocCustomElement))
				dataFormID = inputPropStruct.assocCustomElement;
			else
				dataFormID = inputPropStruct.childCustomElement;
				
			posStruct = getReorderRange(propertiesStruct=inputPropStruct,movedDataPageID=arguments.movedDataPageID,dropAfterDataPageID=arguments.dropAfterDataPageID);
		</cfscript>
		
		<cfif posStruct.minPos GT 0 AND posStruct.maxPos GT 0>	
			<cfscript>
				rangeRecords = getRangeRecords(formID=arguments.formID,currentValues=curValuesStruct,propertiesStruct=inputPropStruct,minPos=posStruct.minPos,maxPos=posStruct.maxPos);
			</cfscript>
			
			<cfif rangeRecords.RecordCount AND NOT ListFindNoCase(rangeRecords.ColumnList, "ErrorMsg" )>
				<cfscript>
					if (rangeRecords.DataPageID[1] EQ arguments.movedDataPageID)
					{
						loopStart = 2;
						loopEnd = rangeRecords.RecordCount;
						newOrderValueForSelected = rangeRecords.Pos[rangeRecords.RecordCount];
						orderOp = '-';
					}
					else if (rangeRecords.DataPageID[rangeRecords.RecordCount] EQ arguments.movedDataPageID)
					{
						loopStart = 1;
						loopEnd = rangeRecords.RecordCount - 1;
						newOrderValueForSelected = rangeRecords.Pos[1];
						orderOp = '+';
					}
				</cfscript>	
				
				<cfif loopStart GT 0 AND loopEnd GT 0>
					<cfloop from="#loopStart#" to="#loopEnd#" index="i">
						<cfscript>
							newOrderValue = Evaluate('#rangeRecords['Pos'][i]# #orderOp# 1');
							changePosition(propertiesStruct=inputPropStruct,dataPageID=rangeRecords['DataPageID'][i],newPos=newOrderValue);
						</cfscript>
					</cfloop>
					<cfscript>
						changePosition(propertiesStruct=inputPropStruct,dataPageID=arguments.movedDataPageID,newPos=newOrderValueForSelected);
					</cfscript>
				</cfif>
			<cfelse>
				<CFMODULE TEMPLATE="/commonspot/utilities/log-append.cfm" comment="Error while trying to reorder the records: Could not retrieve the range records for modifying the order">
				<cfscript>
					sResult = rangeRecords.ErrorMsg[1];
				</cfscript>				
			</cfif>
		<cfelse>
			<CFMODULE TEMPLATE="/commonspot/utilities/log-append.cfm" comment="Error while trying to reorder the records: Calculated minimum and maximum positions value are not numeric value greater than zero">
			<cfscript>
				sResult = 'Could not determine the position range for the moved element.';
			</cfscript>
		</cfif>
		<cfreturn sResult>
    </cffunction>
	
	<cffunction name="getReorderRange" returntype="struct" access="private" hint="Method to get the reorder range for the values fo a custom element">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
        <cfargument name="movedDataPageID" type="numeric" required="true" hint="The unique data pageid for the record from start pos">
		<cfargument name="dropAfterDataPageID" type="numeric" required="true" hint="The unique data pageid for the record from end pos">
        <cfscript>
			var ceObj = Server.CommonSpot.ObjectFactory.getObject("CustomElement");
			var inputPropStruct = arguments.propertiesStruct;
			var dataFormID = 0;
			var getOrderForMovedRec = '';
			var getOrderForEndRec = '';
			var minPosValue = 0;
			var maxPosValue = 0;
			var returnStruct = StructNew();
			
			if (IsNumeric(inputPropStruct.assocCustomElement))
				dataFormID = inputPropStruct.assocCustomElement;
			else
				dataFormID = inputPropStruct.childCustomElement;
		</cfscript>
		
		<cftry>
			<cfquery name="getOrderForMovedRec" datasource="#Request.Site.Datasource#">
				SELECT FieldValue AS OrderPosition, PageID
				  FROM Data_FieldValue
				 WHERE PageID = <cfqueryparam value="#arguments.movedDataPageID#" cfsqltype="cf_sql_integer">
				 	AND FormID = <cfqueryparam value="#dataFormID#" cfsqltype="cf_sql_integer">
					AND FieldID = <cfqueryparam value="#inputPropStruct.positionField#" cfsqltype="cf_sql_integer">
					AND VersionState = <cfqueryparam value="#request.constants.stateCURRENT#" cfsqltype="cf_sql_integer">
			</cfquery>
			
			<cfquery name="getOrderForEndRec" datasource="#Request.Site.Datasource#">
				SELECT FieldValue AS OrderPosition, PageID
				  FROM Data_FieldValue
				 WHERE PageID = <cfqueryparam value="#arguments.dropAfterDataPageID#" cfsqltype="cf_sql_integer">
				 	AND FormID = <cfqueryparam value="#dataFormID#" cfsqltype="cf_sql_integer">
					AND FieldID = <cfqueryparam value="#inputPropStruct.positionField#" cfsqltype="cf_sql_integer">
					AND VersionState = <cfqueryparam value="#request.constants.stateCURRENT#" cfsqltype="cf_sql_integer">
			</cfquery>
			
			<cfscript>
				if (getOrderForMovedRec.OrderPosition GT getOrderForEndRec.OrderPosition)
				{
					minPosValue = getOrderForEndRec.OrderPosition;
					maxPosValue = getOrderForMovedRec.OrderPosition;
				}
				else
				{
					minPosValue = getOrderForMovedRec.OrderPosition;
					maxPosValue = getOrderForEndRec.OrderPosition;
				}
			</cfscript>
		<cfcatch>
			<cfscript>
				minPosValue = 0;
				maxPosValue = 0;
			</cfscript>
		</cfcatch>
		</cftry>
		<cfscript>
			returnStruct['minPos'] = minPosValue;
			returnStruct['maxPos'] = maxPosValue;
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<cffunction name="getRangeRecords" returntype="query" access="private" hint="Method to get the reorder range for the values fo a custom element">
		<cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
		<cfargument name="currentValues" type="struct" required="true" hint="Current values structure for the field">
        <cfargument name="minPos" type="numeric" required="true" hint="The minimum position value to change">
		<cfargument name="maxPos" type="numeric" required="true" hint="The maximum position value to change">
        <cfscript>
			var reqFormFields = "";
			var ceObj = Server.CommonSpot.ObjectFactory.getObject("CustomElement");
			var inputPropStruct = arguments.propertiesStruct;
			var curValuesStruct = arguments.currentValues;
			var linkedIDSelectedName = 'fic_#arguments.formID#_#inputPropStruct.parentUniqueField#';
			var dataFormID = 0;
			var dataFieldID = 0;
			var getPageIDs = '';
			var getRecsToChg = QueryNew('DataPageID,Pos');
			
			if (IsNumeric(inputPropStruct.assocCustomElement))
			{
				dataFormID = inputPropStruct.assocCustomElement;
				dataFieldID = inputPropStruct.parentInstanceIDField;
			}
			else
			{
				dataFormID = inputPropStruct.childCustomElement;
				dataFieldID = inputPropStruct.childLinkedField;
			}
		</cfscript>
		
		<cftry>
			<cfquery name="getPageIDs" datasource="#Request.Site.Datasource#">
				SELECT PageID
				  FROM Data_FieldValue
				 WHERE FormID = <cfqueryparam value="#dataFormID#" cfsqltype="cf_sql_integer">
					AND FieldID = <cfqueryparam value="#dataFieldID#" cfsqltype="cf_sql_integer">
					AND FieldValue = <cfqueryparam value="#curValuesStruct[linkedIDSelectedName]#" cfsqltype="cf_sql_varchar">
					AND VersionState = <cfqueryparam value="#request.constants.stateCURRENT#" cfsqltype="cf_sql_integer">
			</cfquery>
			
			<cfif getPageIDs.RecordCount>
				<cfquery name="getRecsToChg" datasource="#Request.Site.Datasource#">
					SELECT FieldValue AS Pos, PageID AS DataPageID
					  FROM Data_FieldValue
					 WHERE FormID = <cfqueryparam value="#dataFormID#" cfsqltype="cf_sql_integer">
						AND FieldID = <cfqueryparam value="#inputPropStruct.positionField#" cfsqltype="cf_sql_integer">
						AND <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="PageID" LIST="#ValueList(getPageIDs.PageID)#">
						AND VersionState = <cfqueryparam value="2" cfsqltype="cf_sql_integer">
						AND FieldValue >= <cfqueryparam value="#arguments.minPos#" cfsqltype="cf_sql_integer">
						AND FieldValue <= <cfqueryparam value="#arguments.maxPos#" cfsqltype="cf_sql_integer">
				 ORDER BY Pos
				</cfquery>
			</cfif>
		<cfcatch>
			<CFMODULE TEMPLATE="/commonspot/utilities/log-append.cfm" comment="Error while trying to retrieve the fields: #cfcatch.message# :: #cfcatch.detail#">
			<cfscript>
				getRecsToChg = QueryNew('ErrorMsg');
				QueryAddRow(getRecsToChg, 1);
				QuerySetCell(getRecsToChg, 'ErrorMsg', "Error occurred while trying to retrieve range records.");
			</cfscript>
		</cfcatch>
		</cftry>
		
		<cfscript>
			return getRecsToChg;
		</cfscript>
	</cffunction>
	
	<cffunction name="changePosition" returntype="void" access="private" hint="Method to get the change the position of the record with the new position provided">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
        <cfargument name="dataPageID" type="numeric" required="true" hint="The unique data pageid for the records">
		<cfargument name="newPos" type="numeric" required="true" hint="The position value to update">
        <cfscript>
			var inputPropStruct = arguments.propertiesStruct;
			var updateRec = '';
		</cfscript>
		
		<cfquery name="updateRec" datasource="#request.site.datasource#">
			UPDATE Data_FieldValue
				SET FieldValue = <CFQUERYPARAM VALUE="#arguments.newPos#" CFSQLTYPE="CF_SQL_INTEGER">
			 WHERE PageID = <CFQUERYPARAM VALUE="#arguments.dataPageID#" CFSQLTYPE="CF_SQL_INTEGER">
				AND FieldID = <CFQUERYPARAM VALUE="#inputPropStruct.PositionField#" CFSQLTYPE="CF_SQL_INTEGER">
				AND VersionState = <CFQUERYPARAM VALUE="#request.constants.stateCURRENT#" CFSQLTYPE="CF_SQL_INTEGER">
		</cfquery>
	</cffunction>

	<cffunction name="QueryToArray" access="public" returntype="array" output="false" hint="This turns a query into an array of structures with each key being a number.">
    	<cfargument name="queryData" type="query" required="yes" hint="Query to be converted to array">
		<cfargument name="fieldOrderList" type="string" required="true" hint="Order in which the fields need to be returned">

	    <cfscript>
		    var columnArray = ListToArray(arguments.fieldOrderList);
			var queryArray = ArrayNew(1);
			var i = 0;
			var rowStruct = StructNew();
			var j = 0;
			var columnName = '';
			
		    for (i=1; i LTE arguments.queryData.RecordCount; i=i + 1)
		    {
				rowStruct = StructNew();
		   		for (j=1; j LTE ArrayLen(columnArray); j=j + 1)
		   		{
					columnName = columnArray[j];
					rowStruct[j] = arguments.queryData[columnName][i];
		   		}
		  	  	ArrayAppend(queryArray, rowStruct);
		    }
		    return queryArray;	
	    </cfscript>
    </cffunction>
	
	<cffunction name="getContent_csurl" returntype="string" access="private" hint="Get the content of the commonspot page url and extended url element">
		<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
		<cfargument name="fieldValue" type="string" required="true" hint="Value of the field">
		<cfscript>
			var returnString = arguments.fieldValue;
			var cgiServerProtocol = '';
			var refererURL = '';
			
			returnString = REReplaceNoCase(returnString, "<a","<a target=""_blank"" ","all");

			return returnString;
		</cfscript>
	</cffunction>
</cfcomponent>