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
	2013-12-09 - DJM - Added changes to handle hidden fields and added code to set the size of actions column for datatable
					 - Fixed issue for the range being considered as string
	2014-03-05 - JTP - Var declarations
	2014-03-12 - DJM - Updated code displaying the flyover text for edit and delete icons
	2014-04-08 - JTP - Added multi-record delete
	2014-07-01 - DJM - Added code to support metadata forms
	2014-07-08 - DJM - For associated element, code was check for wrong linked field
	2014-08-04 - DJM - Added code to check pagetype for forming CS Extended URL field value
	2014-09-08 - DJM - Updated code to process data columns only when we have some data
	2014-09-10 - DJM - Passed extra parameter to getRecordsFromSavedFilter to fetch unpublished records when the element is a LCE
	2014-10-30 - DJM - Handling of commas within values
	2015-01-05 - DJM - Added code to append '...' against 'add' buttons if not already present
	2015-02-10 - DJM - Added code fix the issue when parent linked value has '&' in it
	2015-04-02 - DJM - Modified getDisplayData() code to always return the Actions column
	2015-04-02 - DJM - Modified code for CS Extended URL to compare with just the pageID value instead of the whole value stored in DB
	2015-04-10 - DJM - Added code to check for field permission for setting up Action controls in getDisplayData()
	2015-07-03 - DJM - Added code for handling disableDatamanager interface option
	2015-07-10 - DRM - Fix getAllForms() allForms QoQ, change required at least for ACF9/MySQL
--->
<cfcomponent output="false" displayname="custom element datamanager_base" extends="ADF.core.Base" hint="This the base component for the Custom Element Data Manager field">
	
<cfscript>
	// Path to this CFT
	variables.cftPath = "/ADF/extensions/customfields/custom_element_datamanager";
</cfscript>

<!------------------------------------------------------>	
<!---// PUBLIC FUNCTIONS //----------------------------->	
<!------------------------------------------------------>		


<!---------------------------------------
	renderStyles()
---------------------------------------->		
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


<!-------------------------------------------
	renderButtons()
------------------------------------------->	
<cffunction name="renderButtons" access="public" returntype="void" hint="Method to render the add new and add existing buttons">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="currentValues" type="struct" required="true" hint="Current values structure for the field">
	<cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
	<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
	<cfargument name="parentFormType" type="string" required="false" default="CustomElement" hint="Type of the form">
	<cfargument name="pageID" type="numeric" required="false" default="0" hint="Page id of the current page; used only when datamanager is used in a metadata form">

	<cfscript>
		var renderData = '';
		var inputPropStruct = arguments.propertiesStruct;
	</cfscript>
	<cfif ListFindNoCase(inputPropStruct.interfaceOptions,'new') OR ListFindNoCase(inputPropStruct.interfaceOptions,'existing')>
		<cfsavecontent variable="renderData">
			
			<cfif ListFindNoCase(inputPropStruct.interfaceOptions,'new')>
				<cfoutput>#renderAddNewButton(argumentCollection=arguments)#</cfoutput>
			</cfif>
			
			<cfif ListFindNoCase(inputPropStruct.interfaceOptions,'existing')>
				<cfoutput>#renderAddExistingButton(argumentCollection=arguments)#</cfoutput>
			</cfif>

			<cfif ListFindNoCase(inputPropStruct.interfaceOptions,'delete')>
				<cfoutput>#renderDeleteSelectedButton(argumentCollection=arguments)#</cfoutput>
			</cfif>
			
			<!--- <cfoutput><br/></cfoutput> --->
		</cfsavecontent>
	</cfif>
	
	<cfif renderData neq ''>
		<cfset renderData = '<div style="min-width:580px;">#renderData#</div>'>
	</cfif>
	
	<cfoutput>#renderData#</cfoutput>
</cffunction>
	
	
<!-------------------------------------------
	renderAddNewButton()
------------------------------------------->	
<cffunction name="renderAddNewButton" access="public" returntype="void" hint="Method to render the add new button">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="currentValues" type="struct" required="true" hint="Current values structure for the field">
	<cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
	<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
	<cfargument name="parentFormType" type="string" required="false" default="CustomElement" hint="Type of the form">
	<cfargument name="pageID" type="numeric" required="false" default="0" hint="Page id of the current page; used only when datamanager is used in a metadata form">

	<cfscript>
		var renderData = '';
		var inputPropStruct = arguments.propertiesStruct;
		var curValuesStruct = arguments.currentValues;
		var assocParameters  = 'csAssoc_assocCE=#propertiesStruct.assocCustomElement#&csAssoc_ParentInstanceIDField=#propertiesStruct.parentInstanceIDField#&csAssoc_ChildInstanceIDField=#propertiesStruct.childInstanceIDField#&csAssoc_ChildUniqueField=#propertiesStruct.childUniqueField#';
		var parentInstanceIDVal = 0;
		var linkedFieldName = '';
		var extraParams = '';
		
		if (arguments.parentFormType EQ 'MetadataForm' AND inputPropStruct.parentUniqueField EQ '{{pageid}}')	
			parentInstanceIDVal = arguments.pageID;
		else
			linkedFieldName = 'fic_#arguments.formID#_#inputPropStruct.parentUniqueField#';
		
		if (linkedFieldName EQ '')
		{
			assocParameters = ListAppend(assocParameters, 'csAssoc_ParentInstanceID=#parentInstanceIDVal#', '&');
			extraParams = '&linkedFieldValue=#parentInstanceIDVal#';
		}
		
		assocParameters = ListAppend(assocParameters, 'csAssoc_ChildInstanceID=', '&');
	</cfscript>
		
	<cfsavecontent variable="renderData">
		<cfoutput>#Server.CommonSpot.UDF.tag.input(type="button", class="clsPushButton", name="addNew", id="addNew", value=getAddNewButtonName(propertiesStruct=arguments.propertiesStruct), onclick="javascript:setCurrentValueAndOpenURL_#arguments.fieldID#('#Request.SubSite.DlgLoader#?csModule=controls/custom/submit-data&controlTypeID=#propertiesStruct.childCustomElement#&formID=#propertiesStruct.childCustomElement#&newData=1&dataPageID=0&dataControlID=0&linkageFieldID=#propertiesStruct.childLinkedField#&openFrom=datamanager&callbackFunction=loadData_#arguments.fieldID#&#assocParameters##extraParams#', '#linkedFieldName#', 'addnew')")#</cfoutput>
	</cfsavecontent>
	<cfoutput>#renderData#</cfoutput>
</cffunction>
	
<!-------------------------------------------
	getAddNewButtonName()
------------------------------------------->	
<cffunction name="getAddNewButtonName" access="public" returntype="string" hint="Method to get the label displayed for add new button">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">

	<cfscript>
		var buttonLabel = 'Add New...';
		var ceName = "";
		var elementType = 'CustomElement';
			
		if (StructKeyExists(arguments.propertiesStruct,"newOptionText") AND Len(arguments.propertiesStruct['newOptionText']))
		{
			buttonLabel = arguments.propertiesStruct['newOptionText'];
		}
		else
		{
			if ( StructKeyExists(arguments.propertiesStruct,"childCustomElement") AND IsNumeric(arguments.propertiesStruct.childCustomElement) ) {
				if ( StructKeyExists(arguments.propertiesStruct,"assocCustomElement") AND IsNumeric(arguments.propertiesStruct.assocCustomElement) ) 
					elementType = arguments.propertiesStruct.secondaryElementType;
				ceName = getCEName(elementID=arguments.propertiesStruct.childCustomElement,elementType=elementType);
				if ( LEN(TRIM(ceName)) )
					buttonLabel = "Add New #ceName#...";
			}
		}
		
		if (Right(buttonLabel,3) NEQ '...')
			buttonLabel = buttonLabel & '...';
			
		return buttonLabel;
	</cfscript>
</cffunction>
	
	
<!-------------------------------------------
	renderAddExistingButton()
------------------------------------------->	
<cffunction name="renderAddExistingButton" access="public" returntype="void" hint="Method to render the add existing button">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="currentValues" type="struct" required="true" hint="Current values structure for the field">
	<cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
	<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
	<cfargument name="parentFormType" type="string" required="false" default="CustomElement" hint="Type of the form">
	<cfargument name="pageID" type="numeric" required="false" default="0" hint="Page id of the current page; used only when datamanager is used in a metadata form">

	<cfscript>
		var renderData = '';
		var inputPropStruct = arguments.propertiesStruct;
		var curValuesStruct = arguments.currentValues;
		var parentInstanceIDVal = 0;
		var linkedFieldName = '';
		var extraParams = '';
		
		if (arguments.parentFormType EQ 'MetadataForm' AND inputPropStruct.parentUniqueField EQ '{{pageid}}')	
			parentInstanceIDVal = arguments.pageID;
		else
			linkedFieldName = 'fic_#arguments.formID#_#inputPropStruct.parentUniqueField#';
		
		if (linkedFieldName EQ '')
		{
			extraParams = '&linkedFieldValue=#parentInstanceIDVal#';
		}
	</cfscript>
		
	<cfsavecontent variable="renderData">
		<cfoutput>#Server.CommonSpot.UDF.tag.input(type="button", class="clsPushButton", name="addExisting", id="addExisting", value=getAddExistingButtonName(propertiesStruct=arguments.propertiesStruct), onclick="javascript:setCurrentValueAndOpenURL_#arguments.fieldID#('#Request.SubSite.DlgLoader#?csModule=controls/custom/submit-data&controlTypeID=#inputPropStruct.assocCustomElement#&formID=#inputPropStruct.assocCustomElement#&newData=1&dataPageID=0&dataControlID=0&linkageFieldID=#inputPropStruct.parentInstanceIDField#&openFrom=datamanager&callbackFunction=loadData_#arguments.fieldID##extraParams#', '#linkedFieldName#', 'addexisting')")#</cfoutput>
	</cfsavecontent>
	<cfoutput>#renderData#</cfoutput>
</cffunction>


<!-------------------------------------------
	renderDeleteSelectedButton()
------------------------------------------->	
<cffunction name="renderDeleteSelectedButton" access="public" returntype="void" hint="Method to render the Delete Selected button">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="currentValues" type="struct" required="true" hint="Current values structure for the field">
	<cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
	<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
	<cfargument name="parentFormType" type="string" required="false" default="CustomElement" hint="Type of the form">
	<cfargument name="pageID" type="numeric" required="false" default="0" hint="Page id of the current page; used only when datamanager is used in a metadata form">

	<cfscript>
		var renderData = '';
	</cfscript>
		
	<cfsavecontent variable="renderData">
		<cfoutput>
			<div style="display:inline-block; text-alignment:right; float:right;">
			<a href="javascript:doSelectAll_#arguments.fieldID#(true);">Select All</a> |
			<a href="javascript:doSelectAll_#arguments.fieldID#(false);">Deselect All</a> &nbsp; 	
			#Server.CommonSpot.UDF.tag.input( type="button", 
															class="clsPushButton", 
															name="deleteSelected", 
															id="deleteSelected", 
															value=getDeleteSelectedButtonName(propertiesStruct=arguments.propertiesStruct), 
															onclick="doDeleteSelected_#arguments.fieldID#('Are you sure you want to delete the selected records?  Note this action will permanently delete the records.', 'Please select one or more records to delete.');")#
			</div>	
			<script>
				function doSelectAll_#arguments.fieldID#(opt)
				{
					jQuery( '##customElementData_#arguments.fieldID# input' ).each( function() {
						jQuery(this).prop('checked', opt);
					} );
				}				
			</script>														
		</cfoutput>
	</cfsavecontent>
	<cfoutput>#renderData#</cfoutput>
</cffunction>



<!-------------------------------------------
	getAddExistingButtonName()
------------------------------------------->	
<cffunction name="getAddExistingButtonName" access="public" returntype="string" hint="Method to get the label displayed for add existing button">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">

	<cfscript>
		var buttonLabel = 'Add Existing...';
		var ceName = "";
		
		if (StructKeyExists(arguments.propertiesStruct,"existingOptionText") AND Len(arguments.propertiesStruct['existingOptionText']))
		{
			buttonLabel = arguments.propertiesStruct['existingOptionText'];
		}
		else
		{	
			if ( StructKeyExists(arguments.propertiesStruct,"assocCustomElement") AND IsNumeric(arguments.propertiesStruct.assocCustomElement) ) {
				ceName = getCEName(elementID=arguments.propertiesStruct.assocCustomElement,elementType='CustomElement');
				if ( LEN(TRIM(ceName)) )
					buttonLabel = "Add New #ceName#...";
			}
		}
		
		if (Right(buttonLabel,3) NEQ '...')
			buttonLabel = buttonLabel & '...';
				
		return buttonLabel;
	</cfscript>
</cffunction>


<!-------------------------------------------
	getDeleteSelectedButtonName()
------------------------------------------->	
<cffunction name="getDeleteSelectedButtonName" access="public" returntype="string" hint="Method to get the label displayed for the Delete Selected">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">

	<cfscript>
		var buttonLabel = 'Delete Selected';
				
		return buttonLabel;
	</cfscript>
</cffunction>

	
<!-------------------------------------------
	queryData()
------------------------------------------->	
<cffunction name="queryData" returntype="struct" access="public" hint="Get the data for the fields" output="yes">
	<cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="currentValues" type="struct" required="true" hint="Current values structure for the field">
	<cfargument name="parentFormType" type="string" required="false" default="CustomElement" hint="Type of the form">
	<cfargument name="pageID" type="string" required="false" default="0" hint="Page id of the current page; used only when datamanager is used in a metadata form">
	
	<cfscript>
		var inputPropStruct = arguments.propertiesStruct;
		var curValuesStruct = arguments.currentValues;
		var defaultSortColumn = '';
		var defaultSortOrder = '';
		var resultData = QueryNew('');	
		var parentObj = Server.CommonSpot.ObjectFactory.getObject(arguments.parentFormType);	
		var childObj = Server.CommonSpot.ObjectFactory.getObject(inputPropStruct.secondaryElementType);
		var colList = inputPropStruct.displayFields;
		var colArray = ArrayNew(1);
		var childFormFields = QueryNew('');
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
		var parentData = StructNew();
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
		var data = '';
		var childColPos = 0;
		var assocColPos = 0;
		var displayColsArray = ArrayNew(1);
		var uniqueList = '';
		var simpleValuesArray = ArrayNew(1);
		var j = 0;
		var parentInstanceIDVal = 0;
		var compareValueWithChild = '';
		var ceObj = '';
		var eData = StructNew();
		var sessionUUID = '';
		var sessionStruct = StructNew();
		var cmdArgs = StructNew();
		var nextIndex = 0;
		var csVersion = ListFirst(ListLast(request.cp.productversion," "),".");
		var k = 0;
		var valuesWithCommaArray = ArrayNew(1);
		var stmtNewPos = 0;
		var operatorToUseStr = 'Equals';
		var operatorToUseSymbol = '=';
		
		if (arguments.parentFormType EQ 'CustomElement')
			ceObj = parentObj;
		else if (inputPropStruct.secondaryElementType EQ 'CustomElement')
			ceObj = childObj;
		else
			ceObj = Server.CommonSpot.ObjectFactory.getObject("CustomElement");
		
		if (arguments.parentFormType EQ 'MetadataForm' AND inputPropStruct.parentUniqueField EQ '{{pageid}}')	
		{
			parentInstanceIDVal = arguments.pageID;
		}
		else
		{
			parentInstanceIDVal = curValuesStruct['fic_#arguments.formID#_#inputPropStruct.parentUniqueField#'];
		}
		
		if(IsNumeric(inputPropStruct.assocCustomElement))
			linkedFldDetails = ceObj.getFields(elementID=inputPropStruct.assocCustomElement,fieldID=inputPropStruct.parentInstanceIDField);
		else 
		{
			if (inputPropStruct.secondaryElementType EQ 'CustomElement')
				linkedFldDetails = childObj.getFields(elementID=inputPropStruct.childCustomElement,fieldID=inputPropStruct.childLinkedField);
			else
				linkedFldDetails = childObj.getFields(formID=inputPropStruct.childCustomElement,fieldID=inputPropStruct.childLinkedField);
		}
			
		if (linkedFldDetails.type NEQ 'img')
		{
			compareValueWithChild = getLinkedFieldValue(fieldType=linkedFldDetails.type,fieldValue=parentInstanceIDVal);
			if (linkedFldDetails.type EQ 'csextendedurl')
			{
				operatorToUseStr = 'Contains';
				operatorToUseSymbol = 'like';
			}
		}
		else
			compareValueWithChild = parentInstanceIDVal;
			
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
		<cfscript>
			if (inputPropStruct.secondaryElementType EQ 'CustomElement')
				childFormFields = childObj.getFields(elementid=inputPropStruct.childCustomElement);
			else
				childFormFields = childObj.getFields(formID=inputPropStruct.childCustomElement);
		</cfscript>
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
							if (ListFindNoCase(assocDisplayColNames, childFormFieldsStruct[colArray[i]]))
							{
								displayColNames = ListAppend(displayColNames, '#childFormFieldsStruct[colArray[i]]#_child');
								childDisplayColNames = ListAppend(childDisplayColNames, '#childFormFieldsStruct[colArray[i]]#_child');
								formFieldsStruct['#childFormFieldsStruct[colArray[i]]#_child'] = childFormFieldsDetailedStruct[childFormFieldsStruct[colArray[i]]];
								
								childColPos = ListFindNoCase(displayColNames, childFormFieldsStruct[colArray[i]]);
								displayColNames = ListSetAt(displayColNames, childColPos, '#childFormFieldsStruct[colArray[i]]#_assoc');
								
								assocColPos = ListFindNoCase(assocDisplayColNames, childFormFieldsStruct[colArray[i]]);
								assocDisplayColNames = ListSetAt(assocDisplayColNames, assocColPos, '#childFormFieldsStruct[colArray[i]]#_assoc');
								
								formFieldsStruct['#childFormFieldsStruct[colArray[i]]#_assoc'] = formFieldsStruct['#childFormFieldsStruct[colArray[i]]#'];
								StructDelete(formFieldsStruct, childFormFieldsStruct[colArray[i]]);
							}
							else
							{
								displayColNames = ListAppend(displayColNames, childFormFieldsStruct[colArray[i]]);
								childDisplayColNames = ListAppend(childDisplayColNames, childFormFieldsStruct[colArray[i]]);
								formFieldsStruct[childFormFieldsStruct[colArray[i]]] = childFormFieldsDetailedStruct[childFormFieldsStruct[colArray[i]]];
							}
						}
						
					}
					
					if (ListFindNoCase(allAssocColList, colArray[i]))
					{
						assocColNameList = ListAppend(assocColNameList, assocFormFieldsStruct[colArray[i]]);
						if (ListFindNoCase(inputPropStruct.displayFields, colArray[i]))
						{
							if (ListFindNoCase(childDisplayColNames, assocFormFieldsStruct[colArray[i]]))
							{
								displayColNames = ListAppend(displayColNames, '#assocFormFieldsStruct[colArray[i]]#_assoc');
								assocDisplayColNames = ListAppend(assocDisplayColNames, '#assocFormFieldsStruct[colArray[i]]#_assoc');
								formFieldsStruct['#assocFormFieldsStruct[colArray[i]]#_assoc'] = assocFormFieldsDetailedStruct[assocFormFieldsStruct[colArray[i]]];
								
								assocColPos = ListFindNoCase(displayColNames, assocFormFieldsStruct[colArray[i]]);
								displayColNames = ListSetAt(displayColNames, assocColPos, '#assocFormFieldsStruct[colArray[i]]#_child');
								
								childColPos = ListFindNoCase(childDisplayColNames, assocFormFieldsStruct[colArray[i]]);
								childDisplayColNames = ListSetAt(childDisplayColNames, childColPos, '#assocFormFieldsStruct[colArray[i]]#_child');
								
								formFieldsStruct['#assocFormFieldsStruct[colArray[i]]#_child'] = formFieldsStruct['#assocFormFieldsStruct[colArray[i]]#'];
								StructDelete(formFieldsStruct, assocFormFieldsStruct[colArray[i]]);
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
				
			returnData = QueryNew('AssocDataPageID,ChildDataPageID,#displayColNames#');
			
			if (arguments.parentFormType EQ 'CustomElement')	
			{
				getParentLinkedField = parentObj.getFields(elementID=arguments.formID,fieldID=inputPropStruct.parentUniqueField);
			
				if (getParentLinkedField.RecordCount)
				{
					parentStatementsArray[1] = ceObj.createStandardFilterStatement(customElementID=arguments.formID,fieldIDorName=getParentLinkedField.ID,operator='Equals',value=parentInstanceIDVal);
					
					parentFilterArray = ceObj.createQueryEngineFilter(filterStatementArray=parentStatementsArray,filterExpression='1');
					
					parentData = ceObj.getRecordsFromSavedFilter(elementID=arguments.formID,queryEngineFilter=parentFilterArray,columnList=getParentLinkedField.Name,orderBy=ReplaceNoCase(getParentLinkedField.Name,'FIC_',''),orderByDirection="ASC", Limit=0, currentOnly=0);
				}
			}
		</cfscript>
		
		<cfif (NOT StructIsEmpty(parentData) AND StructKeyExists(parentData, 'resultQuery') AND parentData.resultQuery.RecordCount) OR arguments.parentFormType EQ 'MetadataForm'>
			<cfscript>
				if(NOT IsNumeric(inputPropStruct.assocCustomElement))
				{
					if (StructKeyExists(inputPropStruct, 'secondaryElementType') AND inputPropStruct.secondaryElementType EQ 'MetadataForm')
					{
						if (ListLen(compareValueWithChild,'||') GT 1)
						{
							if (csVersion GT 9)
							{
								statementsArray[1] = childObj.createStandardFilterStatement(customElementID=inputPropStruct.childCustomElement,fieldIDorName=inputPropStruct.childLinkedField,operator=operatorToUseStr,value=ListFirst(compareValueWithChild,'||'));
								statementsArray[2] = childObj.createStandardFilterStatement(customElementID=inputPropStruct.childCustomElement,fieldIDorName=inputPropStruct.childLinkedField,operator=operatorToUseStr,value=ListLast(compareValueWithChild,'||'));
							}
							else
							{
								statementsArray[1] = "metadata|#inputPropStruct.childCustomElement#_#inputPropStruct.childLinkedField#|#operatorToUseSymbol#|#ListFirst(compareValueWithChild,'||')#"; // Have to construct directly as metadataform has no command to create standard statement
								statementsArray[2] = "metadata|#inputPropStruct.childCustomElement#_#inputPropStruct.childLinkedField#|#operatorToUseSymbol#|#ListLast(compareValueWithChild,'||')#";
							}
							childFilterExpression = '(1 OR 2)';
						}
						else
						{
							if (csVersion GT 9)
							{
								statementsArray[1] = childObj.createStandardFilterStatement(customElementID=inputPropStruct.childCustomElement,fieldIDorName=inputPropStruct.childLinkedField,operator=operatorToUseStr,value=compareValueWithChild);
							}
							else
							{
								statementsArray[1] = "metadata|#inputPropStruct.childCustomElement#_#inputPropStruct.childLinkedField#|#operatorToUseSymbol#|#compareValueWithChild#"; // Have to construct directly as metadataform has no command to create standard statement
							}
							childFilterExpression = '1';
						}
					}
					else
					{
						if (ListLen(compareValueWithChild,'||') GT 1)
						{
							statementsArray[1] = ceObj.createStandardFilterStatement(customElementID=inputPropStruct.childCustomElement,fieldIDorName=inputPropStruct.childLinkedField,operator=operatorToUseStr,value=ListFirst(compareValueWithChild,'||'));
							statementsArray[2] = ceObj.createStandardFilterStatement(customElementID=inputPropStruct.childCustomElement,fieldIDorName=inputPropStruct.childLinkedField,operator=operatorToUseStr,value=ListLast(compareValueWithChild,'||'));
							childFilterExpression = '(1 OR 2)';
						}
						else
						{
							statementsArray[1] = ceObj.createStandardFilterStatement(customElementID=inputPropStruct.childCustomElement,fieldIDorName=inputPropStruct.childLinkedField,operator=operatorToUseStr,value=compareValueWithChild);
							childFilterExpression = '1';
						}
					}
					if(Len(inputPropStruct.inactiveField) AND Len(inputPropStruct.inactiveFieldValue))
					{
						nextIndex = ArrayLen(statementsArray)+1;
						if (StructKeyExists(inputPropStruct, 'secondaryElementType') AND inputPropStruct.secondaryElementType EQ 'MetadataForm')
						{	
							if (csVersion GT 9)
							{
								statementsArray[nextIndex] = childObj.createStandardFilterStatement(customElementID=inputPropStruct.childCustomElement,fieldIDorName=inputPropStruct.inactiveField,operator='Not Equal',value=inputPropStruct.inactiveFieldValue);
							}
							else
							{
								statementsArray[nextIndex] = "metadata|#inputPropStruct.childCustomElement#_#inputPropStruct.inactiveField#|<>|#inputPropStruct.inactiveFieldValue#"; // Have to construct directly as metadataform has no command to create standard statement
							}
						}
						else
							statementsArray[nextIndex] = ceObj.createStandardFilterStatement(customElementID=inputPropStruct.childCustomElement,fieldIDorName=inputPropStruct.inactiveField,operator='Not Equal',value=inputPropStruct.inactiveFieldValue);
						childFilterExpression = '#childFilterExpression# AND #nextIndex#';
					}
					else
						childFilterExpression = '#childFilterExpression#';
				}
				else
				{						
					assocFieldDetail = ceObj.getFields(elementID=inputPropStruct.assocCustomElement,fieldID=inputPropStruct.childInstanceIDField);
					assocReqFieldName = assocFieldDetail.Name;
					if (FindNoCase("FIC_", assocReqFieldName) eq 1)
						assocReqFieldName = Mid(assocReqFieldName, 5, 999);
					assocStatementsArray[1] = ceObj.createStandardFilterStatement(customElementID=inputPropStruct.assocCustomElement,fieldIDorName=inputPropStruct.parentInstanceIDField,operator='Equals',value=compareValueWithChild);
					if(Len(inputPropStruct.inactiveField) AND Len(inputPropStruct.inactiveFieldValue))
					{
						assocStatementsArray[2] = ceObj.createStandardFilterStatement(customElementID=inputPropStruct.assocCustomElement,fieldIDorName=inputPropStruct.inactiveField,operator='Not Equal',value=inputPropStruct.inactiveFieldValue);
						assocFilterExpression = '1 AND 2';
					}
					else
						assocFilterExpression = '1';
					assocFilterArray = ceObj.createQueryEngineFilter(filterStatementArray=assocStatementsArray,filterExpression=assocFilterExpression);
					
					if(linkedFldDetails.type EQ 'img')
					{
						compareValueWithChild = getLinkedFieldValue(fieldType=linkedFldDetails.type,fieldValue=parentInstanceIDVal);
						assocFilterArray[1] = ReplaceNoCase(assocFilterArray[1], '| | #parentInstanceIDVal#|', '| | #compareValueWithChild#|');
					}	
					if (Len(assocColNameList))
						assocColumnList = '#assocReqFieldName#,#assocColNameList#';
					else
						assocColumnList = assocReqFieldName;
						
					data = ceObj.getRecordsFromSavedFilter(elementID=inputPropStruct.assocCustomElement,queryEngineFilter=assocFilterArray,columnList=assocColumnList,orderBy=assocReqFieldName, orderByDirection="ASC", limit=0);
					assocData = data.resultQuery;
						
					if (assocData.RecordCount)
					{
						assocColumnList = assocData.columnList;
						ids = assocData[assocReqFieldName];
						
						// build list of values
						simpleValuesArray = ArrayNew(1);
						valuesWithCommaArray = ArrayNew(1);
						for( j=1; j lte assocData.recordCount; j = j+1 )
						{
							if ( ArrayFindNoCase(simpleValuesArray, assocData[assocReqFieldName][j]) EQ 0 AND ArrayFindNoCase(valuesWithCommaArray, assocData[assocReqFieldName][j]) EQ 0 )
							{
								if (ListLen(assocData[assocReqFieldName][j]) GT 1)
									ArrayAppend( valuesWithCommaArray, assocData[assocReqFieldName][j] );
								else
									ArrayAppend( simpleValuesArray, assocData[assocReqFieldName][j] );
							}
						}	
						uniqueList = ArrayToList( simpleValuesArray );
						
						if ( ListLen(uniqueList) )
						{
							if (StructKeyExists(inputPropStruct, 'secondaryElementType') AND inputPropStruct.secondaryElementType EQ 'MetadataForm')
							{
								if (csVersion GT 9)
								{
									statementsArray[1] = childObj.createStandardFilterStatement(customElementID=inputPropStruct.childCustomElement,fieldIDorName=inputPropStruct.childUniqueField,operator='Value Contained In List',value=uniqueList);
								}
								else
								{
									statementsArray[1] = "metadata|#inputPropStruct.childCustomElement#_#inputPropStruct.childUniqueField#|inlist|#uniqueList#";
								}
							}
							else
								statementsArray[1] = ceObj.createStandardFilterStatement(customElementID=inputPropStruct.childCustomElement,fieldIDorName=inputPropStruct.childUniqueField,operator='Value Contained In List',value=uniqueList);
							childFilterExpression = '1';
						}
						if ( ArrayLen(valuesWithCommaArray) )
						{
							for ( k=1; k LTE ArrayLen(valuesWithCommaArray);k=k+1 )
							{
								stmtNewPos = ArrayLen(statementsArray) + 1;
								if (StructKeyExists(inputPropStruct, 'secondaryElementType') AND inputPropStruct.secondaryElementType EQ 'MetadataForm')
								{
									if (csVersion GT 9)
									{
										statementsArray[stmtNewPos] = childObj.createStandardFilterStatement(customElementID=inputPropStruct.childCustomElement,fieldIDorName=inputPropStruct.childUniqueField,operator='Equals',value=valuesWithCommaArray[k]);
									}
									else
									{
										statementsArray[stmtNewPos] = "metadata|#inputPropStruct.childCustomElement#_#inputPropStruct.childUniqueField#|=|#valuesWithCommaArray[k]#";
									}
								}
								else
									statementsArray[stmtNewPos] = ceObj.createStandardFilterStatement(customElementID=inputPropStruct.childCustomElement,fieldIDorName=inputPropStruct.childUniqueField,operator='Equals',value=valuesWithCommaArray[k]);
								if ( Len(childFilterExpression) )
								{
									childFilterExpression = '#childFilterExpression# OR ';
								}
								childFilterExpression = '#childFilterExpression##Int(stmtNewPos)#';
							}
						}
					}
				}
				
				childFilterArray = ceObj.createQueryEngineFilter(filterStatementArray=statementsArray,filterExpression=childFilterExpression);
				if(NOT IsNumeric(inputPropStruct.assocCustomElement) AND linkedFldDetails.type EQ 'img')
				{
					compareValueWithChild = getLinkedFieldValue(fieldType=linkedFldDetails.type,fieldValue=parentInstanceIDVal);
					childFilterArray[1] = ReplaceNoCase(childFilterArray[1], '| | #parentInstanceIDVal#|', '| | #compareValueWithChild#|');
				}				
				
				childColumnList = '#childColNameList#,#valueFieldName#';
			</cfscript>
			
			<cfif inputPropStruct.secondaryElementType EQ 'CustomElement'>
				<cfscript>
					data = ceObj.getRecordsFromSavedFilter(elementID=inputPropStruct.childCustomElement,queryEngineFilter=childFilterArray,columnList=childColumnList, limit=0, currentOnly=0);					
				</cfscript>
			<cfelse>
				<cfscript>
					eData.filtertype = 1;
					eData.serSrchArray = childFilterArray;
			
					sessionUUID = "op|#inputPropStruct.childCustomElement#|#inputPropStruct.childUniqueField#" &  "_" & inputPropStruct.childUniqueField & "_" & inputPropStruct.childCustomElement & "_" &  Request.User.ID;
					sessionStruct.filter = eData;
					sessionStruct.controlTypeID = inputPropStruct.childCustomElement;
					sessionStruct.defaultSortColumn = "#valueFieldName#|ASC";
				</cfscript>	
				
				<cflock name="#Request.sessionLockName#" type="exclusive" timeout="10">
					<cfset session[sessionUUID] = sessionStruct>
				</cflock>
				
				<cfscript>
					cmdArgs.columnList = "#childColumnList#";			
					cmdArgs.filterID = sessionUUID;
					cmdArgs.id = inputPropStruct.childCustomElement;
					
					data = childObj.getRecordsFromFilter(argumentCollection=cmdArgs);
				</cfscript>
			</cfif>
			
			<cfscript>
				filteredData = data.resultQuery;
				displayColsArray = ListToArray(displayColNames);
			</cfscript>
			
			<cfquery name="returnData" dbtype="query">
				SELECT 
				<cfif IsNumeric(inputPropStruct.assocCustomElement)>
					assocData.PageID AS AssocDataPageID, assocData.ControlID AS AssocDataControlID,
				<cfelse>
					0 AS AssocDataPageID, 0 AS AssocDataControlID,
				</cfif>
					filteredData.PageID AS ChildDataPageID, filteredData.ControlID AS ChildDataControlID
				<cfif ArrayLen(displayColsArray)>
					,
				</cfif>
				<cfloop from="1" to="#ArrayLen(displayColsArray)#" index="i">
						<cfif ListFindNoCase(childDisplayColNames, displayColsArray[i])>
							<cfif ListFindNoCase(childColumnList, displayColsArray[i])>
								filteredData.[#displayColsArray[i]#]
							<cfelseif ListLast(displayColsArray[i], '_') EQ 'child' AND ListFindNoCase(childColumnList, Mid(displayColsArray[i],1,Len(displayColsArray[i])-6))>
								filteredData.[#Mid(displayColsArray[i],1,Len(displayColsArray[i])-6)#] AS #displayColsArray[i]#
							</cfif>
						<cfelseif ListFindNoCase(assocDisplayColNames, displayColsArray[i])>
							<cfif ListFindNoCase(assocColumnList, displayColsArray[i])>
								assocData.[#displayColsArray[i]#]
							<cfelseif ListLast(displayColsArray[i], '_') EQ 'assoc' AND ListFindNoCase(assocColumnList, Mid(displayColsArray[i],1,Len(displayColsArray[i])-6))>
								assocData.[#Mid(displayColsArray[i],1,Len(displayColsArray[i])-6)#] AS #displayColsArray[i]#
							</cfif>
						</cfif>
					<cfif ArrayLen(displayColsArray) GT 1 AND i NEQ ArrayLen(displayColsArray)>
					,
					</cfif>
				</cfloop>
				  FROM filteredData
			<cfif IsNumeric(inputPropStruct.assocCustomElement)>
				  ,assocData WHERE filteredData.[#valueFieldName#] = assocData.[#assocReqFieldName#]
			</cfif>
			<cfif Len(childOrderColumnName)>
			 ORDER BY filteredData.[#childOrderColumnName#] #defaultSortOrder#
			<cfelseif Len(assocOrderColumnName)>
			 ORDER BY assocData.[#assocOrderColumnName#] #defaultSortOrder#
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


<!-------------------------------------------
	getDisplayData()
------------------------------------------->	
<cffunction name="getDisplayData" returntype="struct" access="public" hint="Get the data for the fields">
	<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="dataRecords" type="query" required="true" hint="Query containing the data records">
	<cfargument name="fieldMapStruct" type="struct" required="true" hint="Structure containing the field types mapping details for the fields">
	<cfargument name="fieldOrderList" type="string" required="true" hint="Order in which the fields need to be returned">
	<cfargument name="fieldPermission" type="numeric" required="true" hint="Number indicating user permission on the field; 0 = hidden, 1=readonly, 2=edit">
		
	<cfscript>
		var inputPropStruct = arguments.propertiesStruct;
		var returnData = QueryNew('');
		var childData = arguments.dataRecords;
		var dataColumnList = ListPrepend(arguments.fieldOrderList,'AssocDataPageID,ChildDataPageID');
		var actionColumnArray = ArrayNew(1);
		var renderData = '';
		var mappingStruct = arguments.fieldMapStruct;
		var dataColumnArray = ArrayNew(1);
		var i = 0;
		var formFieldType = '';
		var formFieldID = 0;
		var formFieldValue = '';
		var returnStruct = StructNew();
		var convertedCols = StructNew();
		var converted = 0;
		var convertedColumnList = '';
		var pos = 0;
		var str = '';
		var col = '';
		var fieldUpdValue = '';
		var dataColumnList_new = '';
		var theListLen = 0;
		var actionColumnWidth = 0;
		
		dataColumnArray = ListToArray(dataColumnList);
	</cfscript>
		
	<cftry>			
		<cfloop query="childData">
			<cfset renderData = ''>
			<cfif (ListFindNoCase(inputPropStruct.interfaceOptions,'editAssoc') OR ListFindNoCase(inputPropStruct.interfaceOptions,'editChild') OR ListFindNoCase(inputPropStruct.interfaceOptions,'delete'))
				AND arguments.fieldPermission EQ 2>	
				<cfsavecontent variable="renderData">
					<cfscript>
						// this will output the content
						actionColumnWidth = renderActionColumns( fieldID=arguments.fieldID, 
																				propertiesStruct=inputPropStruct,
																				assocDataPageID=childData.AssocDataPageID,
																				assocDataControlID=ChildData.AssocDataControlID,
																				childDataPageID=childData.ChildDataPageID,
																				childDataControlID=ChildData.ChildDataControlID);
					</cfscript>
				</cfsavecontent>
			</cfif>	
				
			<cfscript>
				actionColumnArray[childData.currentRow] = renderData;
				
				for(i=1;i LTE ArrayLen(dataColumnArray);i=i+1)
				{
					col = dataColumnArray[i];
					if (StructKeyExists(mappingStruct, dataColumnArray[i]))
					{
						formFieldType = mappingStruct[dataColumnArray[i]].fieldType;
						formFieldID = mappingStruct[dataColumnArray[i]].fieldID;
						formFieldValue = childData[dataColumnArray[i]];

						switch (formFieldType)
						{
							case 'Custom Element Select':
							case 'Custom Element Select Field':
							case 'CustomElementSelect':
							case 'CustomElement Select':
							case 'CE Select':
								if( len(formFieldValue) )
									fieldUpdValue = getContent_ceSelect(fieldID=formFieldID,fieldValue='#formFieldValue#');
								else
									fieldUpdValue = '';
										
								if( NOT StructKeyExists(convertedCols, col) )
								{
									QueryAddColumn(childData, '#col#_converted', 'varchar', ArrayNew(1) );				
									convertedCols[col] = StructNew();
								}	
								QuerySetCell(childData, '#col#_converted', fieldUpdValue, childData.CurrentRow);
								break;
								
							case 'select':
								if( len(formFieldValue) )
									fieldUpdValue = getContent_select(fieldID=formFieldID,fieldValue='#formFieldValue#');
								else
									fieldUpdValue = '';
									
								if( NOT StructKeyExists(convertedCols, col) )
								{
									QueryAddColumn(childData, '#col#_converted', 'varchar', ArrayNew(1) );				
									convertedCols[col] = StructNew();
								}	
								QuerySetCell(childData, '#col#_converted', fieldUpdValue, childData.CurrentRow);
								break;

							case 'csextendedurl':
							case 'cs_url':
								fieldUpdValue = getContent_csurl(fieldID=formFieldID,fieldValue='#formFieldValue#');
								QuerySetCell(childData, col, fieldUpdValue, childData.CurrentRow);
								break;

							default:
								fieldUpdValue = formFieldValue;
								QuerySetCell(childData, col, fieldUpdValue, childData.CurrentRow);
								break;
						}
							
						/*
						try 
						{
						QuerySetCell(childData, dataColumnArray[i], fieldUpdValue, childData.CurrentRow);
						}  
						catch (any e) 
						{ 
							// QuerySetCell(childData, dataColumnArray[i], '', childData.CurrentRow);									
							logit('Error updating column:[#dataColumnArray[i]#] Row:[#childData.CurrentRow#] formFieldType:[#formFieldType#] fieldUpdValue:[#fieldUpdValue#] Message:[#e.message#] detail:[#e.detail#]'); 
						}
						*/

					}
				}
			</cfscript>					
		</cfloop>
		
		<cfscript>
			dataColumnList_new = dataColumnList;
			if (childData.RecordCount)
			{
				convertedColumnList = StructKeyList( convertedCols ); 
				theListLen = ListLen(convertedColumnList);
				for( i=1; i lte theListLen; i=i+1 )
				{
					str = ListGetAt( convertedColumnList, i );
					pos = ListFindNoCase( dataColumnList, str );
					if( pos )
						dataColumnList_new = ListSetAt( dataColumnList_new, pos, str & '_converted' );
				}
				QueryAddColumn(childData, 'Actions', 'varchar', actionColumnArray);
			}
			else
			{
				QueryAddColumn(childData, 'Actions', actionColumnArray);
			}
			
			dataColumnList_new = ListPrepend(dataColumnList_new, 'Actions');
			// Logit('datacolumnlist:[#dataColumnList_new#]');	// Actions,AssocDataPageID,ChildDataPageID,ID,Name,ParentID 				
		</cfscript>

		<cfquery name="returnData" dbtype="query">
			SELECT #dataColumnList_new#
			  FROM childData
		</cfquery>
		
		<cfscript>
			returnStruct['actionColumnWidth'] = '#actionColumnWidth#';
			returnStruct['aoColumns'] = '#dataColumnList_new#';
			returnStruct['aoColumns'] = '#ReplaceNoCase(dataColumnList_new,'_converted','','ALL')#';
			returnStruct['aaData'] = QueryToArray(queryData=returnData, fieldOrderList=dataColumnList_new);
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


<!-------------------------------------------
	renderActionColumns()
------------------------------------------->		
<cffunction name="renderActionColumns" returntype="numeric" access="public" hint="Get the data for the fields" output="Yes">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="assocDataPageID" type="numeric" required="true" hint="Data page id for the association element record">
	<cfargument name="assocDataControlID" type="numeric" required="true" hint="Data control id for the association element record">
	<cfargument name="childDataPageID" type="numeric" required="true" hint="Data page id for the child element record">
	<cfargument name="childDataControlID" type="numeric" required="true" hint="Data control id for the child element record">
	<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">

	<cfscript>
		var inputPropStruct = arguments.propertiesStruct;
		var renderData = '';
		var actionColumnWidth = '';
	</cfscript>

	<cfsavecontent variable="renderData">
	
		<cfif ListFindNoCase(inputPropStruct.interfaceOptions,'editAssoc') 
					OR ListFindNoCase(inputPropStruct.interfaceOptions,'editChild') 
					OR ListFindNoCase(inputPropStruct.interfaceOptions,'delete')>

			<cfif ListFindNoCase(inputPropStruct.interfaceOptions,'editAssoc') AND ListFindNoCase(inputPropStruct.interfaceOptions,'editChild') AND ListFindNoCase(inputPropStruct.interfaceOptions,'delete')>
				<cfset actionColumnWidth="87"> <!--- 65 --->
			<cfelse>
				<cfset actionColumnWidth="62">  <!--- 42 --->
			</cfif>
			
			<cfoutput><div style="width:#actionColumnWidth#px;white-space:no-wrap;"></cfoutput>

			<cfif ListFindNoCase(inputPropStruct.interfaceOptions,'editAssoc')>
				<cfoutput>#renderEditAssocIcon(propertiesStruct=arguments.propertiesStruct,dataPageID=arguments.assocDataPageID,dataControlID=arguments.assocDataControlID,fieldID=arguments.fieldID)#</cfoutput>
			</cfif>

			<cfif ListFindNoCase(inputPropStruct.interfaceOptions,'editChild')>
				<cfoutput>#renderEditChildIcon(propertiesStruct=arguments.propertiesStruct,dataPageID=arguments.childDataPageID,dataControlID=arguments.childDataControlID,fieldID=arguments.fieldID)#</cfoutput>
			</cfif>

			<cfif ListFindNoCase(inputPropStruct.interfaceOptions,'delete')>
				<cfoutput>#renderDeleteIcon(propertiesStruct=arguments.propertiesStruct,assocDataPageID=arguments.assocDataPageID,childDataPageID=arguments.childDataPageID,fieldID=arguments.fieldID)#</cfoutput>
			</cfif>

			<cfoutput></div></cfoutput>
		</cfif>
	</cfsavecontent>
	
	<cfoutput>#renderData#</cfoutput>
	
	<cfreturn actionColumnWidth>
</cffunction>


<!-------------------------------------------
	renderEditAssocIcon()
------------------------------------------->	
<cffunction name="renderEditAssocIcon" returntype="void" access="public" hint="Render the edit assoc action">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="dataPageID" type="numeric" required="true" hint="Data page id for the record">
	<cfargument name="dataControlID" type="numeric" required="true" hint="Data control id for the record">
	<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
	
	<cfscript>
		var inputPropStruct = arguments.propertiesStruct;
		var renderData = '';
		var qryString = '';
		var altText = "Edit Association Element '#Request.Site.availcontrols[inputPropStruct.assocCustomElement].shortdesc#'";
		
		if (StructKeyExists(arguments.propertiesStruct,"editAssocOptionText") AND Len(arguments.propertiesStruct['editAssocOptionText']))
			altText = arguments.propertiesStruct['editAssocOptionText'];
	</cfscript>
		
	<cfif IsNumeric(inputPropStruct.assocCustomElement)>
		<cfscript>
			qryString = 'formID=#inputPropStruct.assocCustomElement#&linkageFieldID=#inputPropStruct.parentInstanceIDField#';
		</cfscript>
		<cfsavecontent variable="renderData">
			<cfoutput><img onclick="javascript:top.commonspot.lightbox.openDialog(&##39;#Request.SubSite.DlgLoader#?csModule=controls/custom/submit-data&newData=0&dataPageID=#arguments.dataPageID#&dataControlID=#arguments.dataControlID#&openFrom=datamanager&callbackFunction=loadData_#arguments.fieldID#&#qryString#&##39;);" class="actionIcon" title="#altText#" alt="#altText#" src="/commonspot/dashboard/icons/application_form_edit.png"></cfoutput>
		</cfsavecontent>
	</cfif>
	<cfoutput>#renderData#</cfoutput>
</cffunction>


<!-------------------------------------------
	renderEditChildIcon()
------------------------------------------->	
<cffunction name="renderEditChildIcon" returntype="void" access="public" hint="Render the edit child action">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="dataPageID" type="numeric" required="true" hint="Data page id for the record">
	<cfargument name="dataControlID" type="numeric" required="true" hint="Data control id for the record">
	<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
	
	<cfscript>
		var inputPropStruct = arguments.propertiesStruct;
		var renderData = '';
		var qryString = '';
		var needMFFormName = 0;
		var altText = "";
		var formDetails = QueryNew('');
		var mfObj = Server.CommonSpot.ObjectFactory.getObject('MetadataForm');
		
		if (StructKeyExists(arguments.propertiesStruct,"editChildOptionText") AND Len(arguments.propertiesStruct['editChildOptionText']))
			altText = arguments.propertiesStruct['editChildOptionText'];
		else
		{
			if (IsNumeric(inputPropStruct.assocCustomElement))
			{
				if (StructKeyExists(inputPropStruct, 'secondaryElementType') AND inputPropStruct.secondaryElementType EQ 'MetadataForm')
					needMFFormName = 1;
				else
					altText = "Edit Child Element '#Request.Site.availcontrols[inputPropStruct.childCustomElement].shortdesc#'";
			}
			else
				altText = "Edit Child Element '#Request.Site.availcontrols[inputPropStruct.childCustomElement].shortdesc#'";
		}
		
		if (needMFFormName EQ 1)
		{
			formDetails = mfObj.getForms(id=inputPropStruct.childCustomElement);
			altText = formDetails.FormName;
		}
	</cfscript>
		
	<cfif IsNumeric(inputPropStruct.childCustomElement)>
		<cfscript>
			qryString = 'formID=#inputPropStruct.childCustomElement#&linkageFieldID=#inputPropStruct.childLinkedField#';
		</cfscript>
		<cfsavecontent variable="renderData">
			<cfoutput><img onclick="javascript:top.commonspot.lightbox.openDialog(&##39;#Request.SubSite.DlgLoader#?csModule=controls/custom/submit-data&newData=0&dataPageID=#arguments.dataPageID#&dataControlID=#arguments.dataControlID#&openFrom=datamanager&callbackFunction=loadData_#arguments.fieldID#&#qryString#&##39;);" class="actionIcon" title="#altText#" alt="#altText#" src="/commonspot/dashboard/icons/edit.png"></cfoutput>
		</cfsavecontent>
	</cfif>
	<cfoutput>#renderData#</cfoutput>
</cffunction>
	
	
<!-------------------------------------------
	renderDeleteIcon()
------------------------------------------->		
<cffunction name="renderDeleteIcon" returntype="void" access="public" hint="Render the delete action">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="assocDataPageID" type="numeric" required="true" hint="Data page id for the association element record">
	<cfargument name="childDataPageID" type="numeric" required="true" hint="Data page id for the child element record">
	<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
	
	<cfscript>
		var inputPropStruct = arguments.propertiesStruct;
		var renderData = '';
		var deleteFormID = 0;
		var dataPageID = 0;
		var altText = "";
			
		if(NOT IsNumeric(inputPropStruct.assocCustomElement))
		{
			deleteFormID = inputPropStruct.childCustomElement;
			dataPageID = arguments.childDataPageID;
		}
		else
		{
			deleteFormID = inputPropStruct.assocCustomElement;
			dataPageID = arguments.assocDataPageID;
		}
		
		altText = "Delete #Request.Site.availcontrols[deleteFormID].shortdesc#";
		
		if (StructKeyExists(arguments.propertiesStruct,"deleteOptionText") AND Len(arguments.propertiesStruct['deleteOptionText']))
			altText = arguments.propertiesStruct['deleteOptionText'];
	</cfscript>
	
	<cfif isNumeric(dataPageID) AND dataPageID gt 0 AND isNumeric(deleteFormID) AND deleteFormID gt 0>
		<cfsavecontent variable="renderData">
			<cfoutput>
				<img onclick="javascript:top.commonspot.lightbox.openDialog(&##39;#Request.SubSite.DlgLoader#?csModule=controls/datasheet/cs-delete-form-data&mode=results&callbackFunction=loadData_#arguments.fieldID#&realTargetModule=controls/datasheet/cs-delete-form-data&formID=#deleteFormID#&pageID=#dataPageID#&##39;);" class="actionIcon" title="#altText#" alt="#altText#" src="/commonspot/dashboard/icons/bin.png">
				<input type="checkbox" name="deleteCheckbox" value="#dataPageID#">
			</cfoutput>
		</cfsavecontent>
		<cfoutput>#renderData#</cfoutput>
	</cfif>
</cffunction>
	
	
<!-------------------------------------------
	getReorderRange()
------------------------------------------->		
<cffunction name="getReorderRange" returntype="struct" access="public" hint="Method to get the reorder range for the values fo a custom element">
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
		var endPos = 0;
		var getNextRecord = QueryNew('');
		var endDataPageID = 0;
			
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
				AND PageID > 0
		</cfquery>
			
		<cfif arguments.dropAfterDataPageID NEQ 0>
			<cfquery name="getOrderForEndRec" datasource="#Request.Site.Datasource#">
				SELECT FieldValue AS OrderPosition, PageID
				  FROM Data_FieldValue
				 WHERE PageID = <cfqueryparam value="#arguments.dropAfterDataPageID#" cfsqltype="cf_sql_integer">
				 	AND FormID = <cfqueryparam value="#dataFormID#" cfsqltype="cf_sql_integer">
					AND FieldID = <cfqueryparam value="#inputPropStruct.positionField#" cfsqltype="cf_sql_integer">
					AND VersionState = <cfqueryparam value="#request.constants.stateCURRENT#" cfsqltype="cf_sql_integer">
					AND PageID > 0
			</cfquery>
			
			<cfif getOrderForEndRec.OrderPosition LT getOrderForMovedRec.OrderPosition>
<!---			
				<cfquery name="getNextRecord" datasource="#Request.Site.Datasource#">
					SELECT FieldValue AS OrderPosition, PageID
					  FROM Data_FieldValue
					 WHERE FieldValue > <cfqueryparam value="#getOrderForEndRec.OrderPosition#" cfsqltype="cf_sql_integer">
					 	AND FormID = <cfqueryparam value="#dataFormID#" cfsqltype="cf_sql_integer">
						AND FieldID = <cfqueryparam value="#inputPropStruct.positionField#" cfsqltype="cf_sql_integer">
						AND VersionState = <cfqueryparam value="#request.constants.stateCURRENT#" cfsqltype="cf_sql_integer">
						AND PageID > 0
				 ORDER BY OrderPosition 
				</cfquery>
--->	
				<cfquery name="getNextRecord" datasource="#Request.Site.Datasource#">
					SELECT FieldValue AS OrderPosition, PageID
					  FROM Data_FieldValue
					 WHERE FieldValue > <cfqueryparam value="#getOrderForEndRec.OrderPosition#" cfsqltype="CF_SQL_VARCHAR">
					 	AND FormID = <cfqueryparam value="#dataFormID#" cfsqltype="cf_sql_integer">
						AND FieldID = <cfqueryparam value="#inputPropStruct.positionField#" cfsqltype="cf_sql_integer">
						AND VersionState = <cfqueryparam value="#request.constants.stateCURRENT#" cfsqltype="cf_sql_integer">
						AND PageID > 0
				 ORDER BY OrderPosition 
				</cfquery>
			
				<cfscript>
					endPos = getNextRecord.OrderPosition[1];
				</cfscript>
			<cfelseif getOrderForEndRec.OrderPosition GT getOrderForMovedRec.OrderPosition>
				<cfscript>
					endPos = getOrderForEndRec.OrderPosition;
				</cfscript>
			</cfif>
		<cfelse>
			<cfscript>
				endPos = 1;
			</cfscript>
		</cfif>

		<cfscript>
			if( getOrderForMovedRec.OrderPosition GT endPos )
			{
				minPosValue = endPos;
				maxPosValue = getOrderForMovedRec.OrderPosition;
			}
			else
			{
				minPosValue = getOrderForMovedRec.OrderPosition;
				maxPosValue = endPos;
			}
		</cfscript>
		
		<cfcatch>
			<cfmodule template="/commonspot/utilities/log-append.cfm" comment="Error in Data Manager getReorderRange(): #catch.message# - #cfcatch.detail#">
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


<!-------------------------------------------
	getRangeRecords()
	
	History:
		03-16-2014 - JTP - Changed to use padded string for sort instead of integer
--------------------------------------------->	
<cffunction name="getRangeRecords" returntype="query" access="public" hint="Method to get the reorder range for the values for a custom element">
	<cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="currentValues" type="any" required="true" hint="Current values structure for the field">
	<!---	
	<cfargument name="minPos" type="numeric" required="true" hint="The minimum position value to change">
	<cfargument name="maxPos" type="numeric" required="true" hint="The maximum position value to change">
	--->
	<cfargument name="minPos" type="string" required="true" hint="The minimum position value to change">
	<cfargument name="maxPos" type="string" required="true" hint="The maximum position value to change">
	<cfargument name="parentFormType" type="string" required="false" default="CustomElement" hint="Type of the form">
	<cfargument name="pageID" type="numeric" required="false" default="0" hint="Page id of the current page; used only when datamanager is used in a metadata form">

	<cfscript>
		var reqFormFields = "";
		var ceObj = Server.CommonSpot.ObjectFactory.getObject("CustomElement");
		var inputPropStruct = arguments.propertiesStruct;
		var childObj = Server.CommonSpot.ObjectFactory.getObject(inputPropStruct.secondaryElementType);
		var curValuesStruct = arguments.currentValues;
		var dataFormID = 0;
		var dataFieldID = 0;
		var getPageIDs = '';
		var getRecsToChg = QueryNew('DataPageID,Pos');
		var linkedFldDetails = QueryNew('');
		var compareValueWithChild = '';
		var dbType = Request.Site.SiteDBType;
		var intType = '';
		var parentInstanceIDVal = 0;
		var compareValueWithChildArr = ArrayNew(1);
		var i = 0;
		
		if (arguments.parentFormType EQ 'MetadataForm' AND inputPropStruct.parentUniqueField EQ '{{pageid}}')	
			parentInstanceIDVal = arguments.pageID;
		else
			parentInstanceIDVal = curValuesStruct['fic_#arguments.formID#_#inputPropStruct.parentUniqueField#'];
		
		if(IsNumeric(inputPropStruct.assocCustomElement))
			linkedFldDetails = ceObj.getFields(elementID=inputPropStruct.assocCustomElement,fieldID=inputPropStruct.parentInstanceIDField);
		else 
		{
			if (inputPropStruct.secondaryElementType EQ 'CustomElement')
				linkedFldDetails = childObj.getFields(elementID=inputPropStruct.childCustomElement,fieldID=inputPropStruct.childLinkedField);
			else
				linkedFldDetails = childObj.getFields(formID=inputPropStruct.childCustomElement,fieldID=inputPropStruct.childLinkedField);
		}
			
		compareValueWithChild = getLinkedFieldValue(fieldType=linkedFldDetails.type,fieldValue=parentInstanceIDVal);
		compareValueWithChildArr = ListToArray(compareValueWithChild, '||');
		
		switch (dbtype)
		{
			case 'Oracle':
				intType = 'number(12)';
				break;
			case 'MySQL':
				intType = 'UNSIGNED';
				break;
			case 'SQLServer':
				intType = 'int';
				break;
		}

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
				AND <cfif ArrayLen(compareValueWithChildArr) GT 1>
				(
				</cfif>
				<cfloop from="1" to="#ArrayLen(compareValueWithChildArr)#" index="i">
					FieldValue = <cfqueryparam value="#compareValueWithChildArr[i]#" cfsqltype="cf_sql_varchar">
					<cfif i NEQ ArrayLen(compareValueWithChildArr)>
					OR
					</cfif>
				</cfloop>
				<cfif ArrayLen(compareValueWithChildArr) GT 1>
				)
				</cfif>
				AND VersionState = <cfqueryparam value="#request.constants.stateCURRENT#" cfsqltype="cf_sql_integer">
				AND PageID > 0
		</cfquery>
		
		<cfif getPageIDs.RecordCount>
<!---		
			<cfquery name="getRecsToChg" datasource="#Request.Site.Datasource#">
				SELECT CAST(FieldValue AS #intType#) AS Pos, PageID AS DataPageID
				  FROM Data_FieldValue
				 WHERE FormID = <cfqueryparam value="#dataFormID#" cfsqltype="cf_sql_integer">
					AND FieldID = <cfqueryparam value="#inputPropStruct.positionField#" cfsqltype="cf_sql_integer">
					AND <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="PageID" LIST="#ValueList(getPageIDs.PageID)#">
					AND VersionState = <cfqueryparam value="#request.constants.stateCURRENT#" cfsqltype="cf_sql_integer">
					AND FieldValue >= <cfqueryparam value="#arguments.minPos#" cfsqltype="cf_sql_integer">
					AND FieldValue <= <cfqueryparam value="#arguments.maxPos#" cfsqltype="cf_sql_integer">
					AND PageID > 0
			 ORDER BY Pos
			</cfquery>
--->
			<cfquery name="getRecsToChg" datasource="#Request.Site.Datasource#">
				SELECT FieldValue AS Pos, PageID AS DataPageID
				  FROM Data_FieldValue
				 WHERE FormID = <cfqueryparam value="#dataFormID#" cfsqltype="cf_sql_integer">
					AND FieldID = <cfqueryparam value="#inputPropStruct.positionField#" cfsqltype="cf_sql_integer">
					AND <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="PageID" LIST="#ValueList(getPageIDs.PageID)#">
					AND VersionState = <cfqueryparam value="#request.constants.stateCURRENT#" cfsqltype="cf_sql_integer">
					AND CAST(FieldValue AS #intType#) >= <cfqueryparam value="#arguments.minPos#" cfsqltype="CF_SQL_INTEGER">
					AND CAST(FieldValue AS #intType#) <= <cfqueryparam value="#arguments.maxPos#" cfsqltype="CF_SQL_INTEGER">
					AND PageID > 0
			 ORDER BY Pos
			</cfquery>

		</cfif>
	<cfcatch>
		<CFMODULE TEMPLATE="/commonspot/utilities/log-append.cfm" comment="getRangeRecords: Error while trying to retrieve the fields: #cfcatch.message# :: #cfcatch.detail#">
		<cfscript>
			getRecsToChg = QueryNew('ErrorMsg');
			QueryAddRow(getRecsToChg, 1);
			QuerySetCell(getRecsToChg, 'ErrorMsg', "Error occurred while trying to retrieve range records. #cfcatch.message# #cfcatch.detail#");
		</cfscript>
	</cfcatch>
	</cftry>
	
	<cfscript>
		return getRecsToChg;
	</cfscript>
</cffunction>


<!---------------------------------------------------
	changePostion()
	
	History:
		03-16-2014 - JTP - Changed to use padded string for sort instead of integer  
---------------------------------------------------->	
<cffunction name="changePosition" returntype="void" access="public" hint="Method to get the change the position of the record with the new position provided">
	<cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="dataPageID" type="numeric" required="true" hint="The unique data pageid for the records">
	<cfargument name="newPos" type="numeric" required="true" hint="The position value to update">

   <cfscript>
		var inputPropStruct = arguments.propertiesStruct;
		var updateRec = '';
		var qry = '';
		var elementFormID = 0;
		var name = '';
	</cfscript>
	
	<!--- update the sort order field --->	
<!---	
	<cfquery name="updateRec" datasource="#request.site.datasource#">
		UPDATE Data_FieldValue
			SET FieldValue = <CFQUERYPARAM VALUE="#arguments.newPos#" CFSQLTYPE="CF_SQL_INTEGER">
		 WHERE PageID = <CFQUERYPARAM VALUE="#arguments.dataPageID#" CFSQLTYPE="CF_SQL_INTEGER">
			AND FieldID = <CFQUERYPARAM VALUE="#inputPropStruct.PositionField#" CFSQLTYPE="CF_SQL_INTEGER">
			AND VersionState = <CFQUERYPARAM VALUE="#request.constants.stateCURRENT#" CFSQLTYPE="CF_SQL_INTEGER">
			AND PageID > 0
	</cfquery>
--->
	<cfquery name="updateRec" datasource="#request.site.datasource#">
		UPDATE Data_FieldValue
			SET FieldValue = <CFQUERYPARAM VALUE="#arguments.newPos#" cfsqltype="CF_SQL_VARCHAR">
		 WHERE PageID = <CFQUERYPARAM VALUE="#arguments.dataPageID#" CFSQLTYPE="CF_SQL_INTEGER">
			AND FieldID = <CFQUERYPARAM VALUE="#inputPropStruct.PositionField#" CFSQLTYPE="CF_SQL_INTEGER">
			AND VersionState = <CFQUERYPARAM VALUE="#request.constants.stateCURRENT#" CFSQLTYPE="CF_SQL_INTEGER">
			AND PageID > 0
	</cfquery>
	
	<!--- update the last modified timestamp for all version state 2 records --->
	<cfquery name="updateRec" datasource="#request.site.datasource#">
		UPDATE Data_FieldValue
			SET DateApproved = <CFQUERYPARAM VALUE="#request.formattedTimestamp#" cfsqltype="CF_SQL_VARCHAR">
		 WHERE PageID = <CFQUERYPARAM VALUE="#arguments.dataPageID#" CFSQLTYPE="CF_SQL_INTEGER">
			AND VersionState = <CFQUERYPARAM VALUE="#request.constants.stateCURRENT#" CFSQLTYPE="CF_SQL_INTEGER">
			AND PageID > 0
	</cfquery>

	<!--- Get the form ID --->		
<!---	
	<cfquery name="qry" datasource="#request.site.datasource#">
		Select FormID from Data_FieldValue
		 WHERE PageID = <CFQUERYPARAM VALUE="#arguments.dataPageID#" CFSQLTYPE="CF_SQL_INTEGER">
			AND FieldID = <CFQUERYPARAM VALUE="#inputPropStruct.PositionField#" CFSQLTYPE="CF_SQL_INTEGER">
			AND VersionState = <CFQUERYPARAM VALUE="#request.constants.stateCURRENT#" CFSQLTYPE="CF_SQL_INTEGER">
	</cfquery>
--->
	
	<cfscript>
//		if( qry.recordCount eq 1 )
//		{
			// invalidate the element cache
			Application.CacheInfoCache.InvalidateByTypeList(arguments.FormID, Request.Constants.rphaseAllCache, 0, 0); // all levels, indirect change, don't limit to WIP
			
			if (StructKeyExists(request.site.availControls, arguments.FormID))
			{
				request.site.availControls[arguments.FormID].lastUpdateSinceRestart = request.formattedTimestamp;
				name = request.site.availControls[arguments.FormID].shortDesc;
				request.site.availControlsByName['custom:#name#'].lastUpdateSinceRestart = request.formattedTimestamp;
			}
//		}	
	</cfscript>	
</cffunction>


<!------------------------------------------------
	QueryToArray()
------------------------------------------------->
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
		var theArrayLen = 0;
		
	    for ( i=1; i LTE arguments.queryData.RecordCount; i=i + 1 )
	    {
			rowStruct = StructNew();
			theArrayLen = ArrayLen(columnArray);
		   for(j=1; j LTE theArrayLen; j=j + 1)
		   {
				columnName = columnArray[j];
				rowStruct[j] = arguments.queryData[columnName][i];
	   	}
	  	  	ArrayAppend(queryArray, rowStruct);
	    }
	    return queryArray;	
	</cfscript>
</cffunction>



<!-------------------------------------------
	LogIt()
------------------------------------------->
<cffunction name="logit" access="public" output="No" returntype="void">
	<cfargument name="comment" required="Yes" type="string">
	
	<cffile action="APPEND" 
				file="#Request.CP.LogDir#datamanager-#DateFormat(now(),'yyyy-mm-dd')#" 
				output="#arguments.comment#" 
				addnewline="Yes">
</cffunction>


<!------------------------------------------------------>	
<!---// REMOTE FUNCTIONS //----------------------------->	
<!------------------------------------------------------>		


<!-------------------------------------------
	getAllForms()
------------------------------------------->
<cffunction name="getAllForms" returnformat="json" access="remote" output="No" hint="Method to get the global custom elements">		
	<cfscript>
		var result = QueryNew('');
		var customElementObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
		var metadataFormObj = Server.CommonSpot.ObjectFactory.getObject('MetadataForm');
	</cfscript>
	
	<cftry>
		<cfscript>
			allMetadataForms = metadataFormObj.getForms();
			allCustomElements = customElementObj.getList(type="All", state="Active");
		</cfscript>
		
		<cfquery name="result" dbtype="query">
			SELECT ID, Name, LOWER(Type) AS Type
			  FROM allCustomElements
						UNION ALL
			SELECT ID, CAST(FormName AS VARCHAR) AS Name, 'metadataform' AS Type
			  FROM allMetadataForms
		</cfquery>
		
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
	
	
<!-------------------------------------------
	getFields()
------------------------------------------->
<cffunction name="getFields" returnformat="json" access="remote" hint="Get the fields for a custom elemnt">
    <cfargument name="elementID" type="numeric" required="true" hint="Custom element ID">
	<cfargument name="elementType" type="string" required="false" default="CustomElement" hint="Type of the element - CustomElement/MetadataForm">
		
    <cfscript>
		var result = QueryNew('');
		var formObj = Server.CommonSpot.ObjectFactory.getObject(arguments.elementType);
		var resultData = '';
		var elementDetails = QueryNew('');
		var nameField = '';
	</cfscript>
	
	<cftry>
		<cfscript>
			if (arguments.elementType EQ 'MetadataForm')
			{
				elementDetails = formObj.getForms(ID=arguments.elementID);
				resultData = formObj.getFields(formID=arguments.elementID);
				nameField = elementDetails.FormName;
			}
			else
			{
				elementDetails = formObj.getInfo(elementID=arguments.elementID);
				resultData = formObj.getFields(elementID=arguments.elementID);
				nameField = elementDetails.Name;
			}
		</cfscript>
		<cfquery name="result" dbtype="query">
			SELECT ID, Label AS Name, Name AS FieldName, Type, '#nameField#' AS CustomElementName
			  FROM resultData
		</cfquery>
		<cfloop query="result">
			<cfscript>
				if (Len(result.Name) EQ 0)
					result.Name = ReplaceNoCase(result.FieldName,'FIC_','');
			</cfscript>
		</cfloop>
		
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

<!-------------------------------------------
	getFieldIDList()
------------------------------------------->
<cffunction name="getFieldIDList" returnformat="json" access="remote" hint="Get the fields for a custom elemnt">
    <cfargument name="elementID" type="numeric" required="true" hint="Custom element ID">
	<cfargument name="elementType" type="string" required="false" default="CustomElement" hint="Type of the element - CustomElement/MetadataForm">
		
    <cfscript>
		var result = QueryNew('');
		var formObj = Server.CommonSpot.ObjectFactory.getObject(arguments.elementType);
		var resultData = '';
	</cfscript>
	
	<cftry>
		<cfscript>
			if (arguments.elementType EQ 'MetadataForm')
				resultData = formObj.getFields(formID=arguments.elementID);
			else
				resultData = formObj.getFields(elementID=arguments.elementID);
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


<!-------------------------------------------
	RenderGrid()
------------------------------------------->		
<cffunction name="renderGrid" access="remote" output="Yes" returntype="any" hint="Method to render the datamanger grid">	<!--- // TODO: Update to type="string" --->	
	<cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
	<cfargument name="propertiesStruct" type="any" required="true" hint="Properties structure for the field in json format"> <!--- // TODO: Update to type="struct" --->
	<cfargument name="currentValues" type="any" required="true" hint="Current values structure for the field in json format"> <!--- // TODO: Update to type="struct" --->
	<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
	<cfargument name="fieldPermission" type="numeric" required="true" hint="Number indicating user permission on the field; 0 = hidden, 1=readonly, 2=edit">
	<cfargument name="parentFormType" type="string" required="false" default="CustomElement" hint="Type of the form">
	<cfargument name="pageID" type="string" required="false" default="0" hint="Page id of the current page; used only when datamanager is used in a metadata form">

	<cfscript>
		var inputPropStruct = StructNew();
		var curValuesStruct = StructNew();
		var dataRecords = QueryNew('');
		var displayData = QueryNew('');
		var logError = false;
	
		try {
			if (IsJSON(arguments.propertiesStruct))
			{
				inputPropStruct = DeserializeJSON(arguments.propertiesStruct);
			}
			else
			{
				inputPropStruct = arguments.propertiesStruct;
			}
			
			if (IsJSON(arguments.currentValues))
			{
				curValuesStruct = DeserializeJSON(arguments.currentValues);
			}
			else
			{
				curValuesStruct = arguments.currentValues;
			}
		
			
			dataRecords = queryData(formID=arguments.formID,propertiesStruct=inputPropStruct,currentValues=curValuesStruct,
										parentFormType=arguments.parentFormType,pageID=arguments.pageID);
			
			if (NOT StructKeyExists(dataRecords, 'errorMsg'))
				displayData = getDisplayData(fieldID=arguments.fieldID, 
														propertiesStruct=inputPropStruct,
														dataRecords=dataRecords.qry,
														fieldMapStruct=dataRecords.fieldMapStruct,
														fieldOrderList=dataRecords.fieldOrderList,
														fieldPermission=arguments.fieldPermission);
														
														
			//application.ADF.utils.doDUMP(displayData,"displayData",1);
			
			return SerializeJSON(displayData);
		} 
		catch (any e) 
		{
			logError = true;	
		}										
	</cfscript>		
	
	<!-- // If error is generated log it --->
	<cfif logError>
		<cfmodule template="/commonspot/utilities/log-append.cfm" comment="Error in custom_element_datamanager_base.cfc RenderGrid() #e.message# #e.detail#">
		<cfreturn "">
	</cfif>	
</cffunction>


<!-------------------------------------------------------------------
	onDrop()
	
	History:	
		03-16-2014 - JTP - Changed to use padded string for sort instead of integer
--------------------------------------------------------------------->		
<cffunction name="onDrop" returnformat="json" access="remote" hint="Method to reorder the values fo a custom element">
	<cfargument name="formID" type="numeric" required="true" hint="ID of the form or control type">
	<cfargument name="propertiesStruct" type="any" required="true" hint="Properties structure for the field in json format"><!--- // Set to type="any" to handle either a json string or struture object --->
	<cfargument name="currentValues" type="any" required="true" hint="Current values structure for the field in json format"><!--- // Set to type="any" to handle either a json string or struture object --->
	<cfargument name="movedDataPageID" type="numeric" required="true" hint="The unique data pageid for the record from start pos">
	<cfargument name="dropAfterDataPageID" type="numeric" required="true" hint="The unique data pageid for the record from end pos">
	<cfargument name="parentFormType" type="string" required="false" default="CustomElement" hint="Type of the form">
	<cfargument name="pageID" type="numeric" required="false" default="0" hint="Page id of the current page; used only when datamanager is used in a metadata form">

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
		var i = 0;

		if ( IsJSON(arguments.propertiesStruct) )
			inputPropStruct = DeserializeJSON(arguments.propertiesStruct);
		else if ( IsStruct(arguments.propertiesStruct) )
			inputPropStruct = arguments.propertiesStruct;
		else
		{
			sResult = 'Failed to read the propertiesStruct value that was passed in to the Custom Element Datamanager onDrop method.';	
			application.ADF.utils.logAppend(msg=sResult,logFile="adf-custom-element-data-manager-cft.log");			
			return sResult;
		}
			
		if ( IsJSON(arguments.currentValues) )
			curValuesStruct = DeserializeJSON(arguments.currentValues);
		else if ( IsStruct(arguments.currentValues) )
			curValuesStruct = arguments.currentValues;
		else
		{
			sResult = 'Failed to read the currentValues value that was passed in to the Custom Element Datamanager onDrop method.';
			application.ADF.utils.logAppend(msg=sResult,logFile="adf-custom-element-data-manager-cft.log");			
			return sResult;
		}
				
		posStruct = getReorderRange( propertiesStruct=inputPropStruct, 
												movedDataPageID=arguments.movedDataPageID,
												dropAfterDataPageID=arguments.dropAfterDataPageID );
	</cfscript>
	
	<cfif posStruct.minPos GT 0 AND posStruct.maxPos GT 0>	
		<cfscript>
			rangeRecords = getRangeRecords( formID=arguments.formID, 
														currentValues=curValuesStruct, 
														propertiesStruct=inputPropStruct, 
														minPos=posStruct.minPos, 
														maxPos=posStruct.maxPos,
														parentFormType=arguments.parentFormType,
														pageID=arguments.pageID );
		</cfscript>
		
		<cfif rangeRecords.RecordCount AND NOT ListFindNoCase(rangeRecords.ColumnList, "ErrorMsg" )>
			<cfscript>
				if (rangeRecords.DataPageID[1] EQ arguments.movedDataPageID)
				{
					loopStart = 2;
					loopEnd = rangeRecords.RecordCount;
					newOrderValueForSelected = rangeRecords.Pos[rangeRecords.RecordCount];
					newOrderValueForSelected = NumberFormat( newOrderValueForSelected, '000000009' );
					orderOp = '-';
				}
				else if (rangeRecords.DataPageID[rangeRecords.RecordCount] EQ arguments.movedDataPageID)
				{
					loopStart = 1;
					loopEnd = rangeRecords.RecordCount - 1;
					newOrderValueForSelected = rangeRecords.Pos[1];
					newOrderValueForSelected = NumberFormat( newOrderValueForSelected, '000000009' );
					orderOp = '+';
				}
			</cfscript>	
				
			<cfif loopStart GT 0 AND loopEnd GT 0>
				<cfloop from="#loopStart#" to="#loopEnd#" index="i">
					<cfscript>
						// newOrderValue = Evaluate('#rangeRecords['Pos'][i]# #orderOp# 1');
						if( orderOp eq '+' )
							newOrderValue = val(rangeRecords['Pos'][i]) + 1;
						else	
							newOrderValue = val(rangeRecords['Pos'][i]) - 1;
						newOrderValue = NumberFormat( newOrderValue, '000000009' );	
						changePosition( formID=arguments.formID, propertiesStruct=inputPropStruct, dataPageID=rangeRecords['DataPageID'][i], newPos=newOrderValue);
					</cfscript>
				</cfloop>
				<cfscript>
					changePosition( formID=arguments.formID, propertiesStruct=inputPropStruct, dataPageID=arguments.movedDataPageID, newPos=newOrderValueForSelected);
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
 
 
<!------------------------------------------------------->
<!---// PRIVATE FUNCTIONS //----------------------------->
<!------------------------------------------------------->	
	
<!------------------------------------------------------
	getCEName()
-------------------------------------------------------->		
<cffunction name="getCEName" access="private" returntype="string" hint="Get the Custom Element Name">
	<cfargument name="elementID" type="numeric" required="true" hint="Custom element ID">
	<cfargument name="elementType" type="string" required="false" default="CustomElement" hint="Type of the element - CustomElement/MetadataForm">
		
    <cfscript>
		var result = QueryNew('');
		var formObj = Server.CommonSpot.ObjectFactory.getObject(arguments.elementType);
		var elementDetails = QueryNew('');
	</cfscript>
	
	<cftry>
		<cfscript>
			if (arguments.elementType EQ 'MetadataForm')
			{
				elementDetails = formObj.getForms(ID=arguments.elementID);
				result = elementDetails.FormName;
			}
			else
			{
				elementDetails = formObj.getInfo(elementID=arguments.elementID);
				result = elementDetails.Name;
			}
		</cfscript>
		<cfcatch>
			<CFMODULE TEMPLATE="/commonspot/utilities/log-append.cfm" comment="Error while trying to retrieve the global custom element name: #cfcatch.message# :: #cfcatch.detail#">
			<cfscript>
				result = 'Error';
			</cfscript>
		</cfcatch>
	</cftry>
	
	<cfreturn result>
</cffunction>
	
<!------------------------------------------------------
	getContent_ceSelect()
-------------------------------------------------------->		 
<cffunction name="getContent_ceSelect" returntype="string" access="private" hint="Function to get the content of the custom element select element">
	<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
	<cfargument name="fieldValue" type="string" required="true" hint="Value of the field">

	<cfscript>
		var paramsData = '';
		var paramsStruct = StructNew();
		var returnString = arguments.fieldValue;
		var ceDataArray = ArrayNew(1);
		var ceDataArrayLen = 0;
		var valueIndex = 0;
		var i = 0;
		var displayString = '';
		var key = '#fieldID#';
		var build = 1;
		var theArrayLen = 0;
		var valueFld = 0;
		var displayFld = 0;
		var ceObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
		var cfmlFilterCriteria = StructNew();	
		var ceFormID = 0;
		var fieldList = '';
		var sortColumn = '';
		var sortDir = '';
		var filterArray = ArrayNew(1);
		var statementsArray = ArrayNew(1);
		var fldsQry = QueryNew('');
		var index = 1;
		var valueWithoutParens = '';
		var hasParens = 0;	
		var ceData = QueryNew('');
		var formIDColArray = '';
		var formNameColArray = '';
		var start = 0;
		var end = 0;
		
		if( NOT StructKeyExists(request,'getContent_ceSelect') )
			request['getContent_ceSelect'] = structNew();
		if( NOT StructKeyExists(request['getContent_ceSelect'],fieldID ) )
		{
			request['getContent_ceSelect'][fieldID] = structNew();
			build = 1;
		}	
		else
			build = 0;
	</cfscript>

	<!--- 
		if first time through do the following:
			- get parameters of custom element select field
			- determine if filter is being used
			- get all records
			- store in results and other parameters in request	( request['getContent_ceSelect'][fieldID] )
	--->
	<cfif build eq 1>
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
					// build structures to cache the ceDataArray results
					request['getContent_ceSelect'][fieldID] = StructNew();
					request['getContent_ceSelect'][fieldID].valueField = paramsStruct.valueField;
					request['getContent_ceSelect'][fieldID].displayField = paramsStruct.displayField;
					request['getContent_ceSelect'][fieldID].displayFieldBuilder = paramsStruct.displayFieldBuilder;

					
					// If Multi-select - no display value look up
					if( StructKeyExists(paramsStruct,"MultipleSelect") AND paramsStruct.MultipleSelect eq 1 )
					{
						request['getContent_ceSelect'][fieldID].assocArray = '';
					}
					// single select. Display Value can be returned
					else	
					{
						//
						// Get Results of ALL applicable records.
						//						
						/*if( StructKeyExists(paramsStruct,"activeFlagField") 
								AND Len(paramsStruct.activeFlagField)
								AND StructKeyExists(paramsStruct,"activeFlagValue") 
								AND Len(paramsStruct.activeFlagValue)
						  )
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
							// No filter, get all records
							ceDataArray = application.ADF.ceData.getCEData(paramsStruct.customElement);
						}*/
						
						if (StructKeyExists(paramsStruct,"customElement") and Len(paramsStruct.customElement))
							ceFormID = application.ADF.cedata.getFormIDByCEName(paramsStruct.customElement);
						
						if ( StructKeyExists(paramsStruct,"activeFlagField") 
								AND Len(paramsStruct.activeFlagField) 
								AND StructKeyExists(paramsStruct,"activeFlagValue") 
								AND Len(paramsStruct.activeFlagValue) 
							) 
						{
							if ( (TRIM(LEFT(paramsStruct.activeFlagValue,1)) EQ "[") AND (TRIM(RIGHT(paramsStruct.activeFlagValue,1)) EQ "]"))
							{
								valueWithoutParens = MID(paramsStruct.activeFlagValue, 2, LEN(paramsStruct.activeFlagValue)-2);
								hasParens = 1;
							}
							else
							{
								valueWithoutParens = paramsStruct.activeFlagValue;
							}
							
							statementsArray[1] = ceObj.createStandardFilterStatement(customElementID=ceFormID,fieldIDorName=paramsStruct.activeFlagField,operator='Equals',value=valueWithoutParens);
									
							filterArray = ceObj.createQueryEngineFilter(filterStatementArray=statementsArray,filterExpression='1');
							
							if (hasParens)
							{
								filterArray[1] = ReplaceNoCase(filterArray[1], '| #valueWithoutParens#| |', '#valueWithoutParens#| ###valueWithoutParens###| |');
							}
							
							cfmlFilterCriteria.filter = StructNew();
							cfmlFilterCriteria.filter.serSrchArray = filterArray;
							cfmlFilterCriteria.defaultSortColumn = paramsStruct.activeFlagField & '|asc';
						}
						
						if ( StructKeyExists(paramsStruct,"sortByField") and paramsStruct.sortByField NEQ '--')
						{
							cfmlFilterCriteria.defaultSortColumn = paramsStruct.sortByField & '|asc';
						}
						
						if (NOT StructIsEmpty(cfmlFilterCriteria))
							paramsStruct.filterCriteria = Server.CommonSpot.UDF.util.WDDXEncode(cfmlFilterCriteria);
				
						if (StructKeyExists(paramsStruct, 'filterCriteria') AND IsWDDX(paramsStruct.filterCriteria))
						{
							cfmlFilterCriteria = Server.CommonSpot.UDF.util.WDDXDecode(paramsStruct.filterCriteria);	
							if ( StructKeyExists(cfmlFilterCriteria,"filter") )		
								filterArray = cfmlFilterCriteria.filter.serSrchArray;
							sortColumn = ListFirst(cfmlFilterCriteria.defaultSortColumn,'|');
							sortDir = ListLast(cfmlFilterCriteria.defaultSortColumn,'|');
						}
						
						if (StructKeyExists(paramsStruct,"customElement") and Len(paramsStruct.customElement))
						{
							fldsQry = ceObj.GetFields(ceFormID);
							fieldList = ValueList(fldsQry.Name);
							
							if( StructKeyExists(paramsStruct, "displayField") AND LEN(paramsStruct.displayField) AND paramsStruct.displayField neq "--Other--" ) 
								fieldList = '#paramsStruct.displayField#,#paramsStruct.valueField#';
							else if( paramsStruct.displayField eq "--Other--" AND paramsStruct.DisplayFieldBuilder neq '' )
							{
								start = 1;
								fieldList = '';
								while( true )
								{
									start = FindNoCase( Chr(171), paramsStruct.DisplayFieldBuilder, start );
									if( start )
									{
										end = FindNoCase( Chr(187), paramsStruct.DisplayFieldBuilder, start );
										if( end )
										{
											fld = Mid( paramsStruct.DisplayFieldBuilder, start + 1, (end - (start+1)) );
											if( NOT FindNoCase( fld, fieldList ) )
												fieldList = ListAppend( fieldList, fld ); 
											start = end;	
										}
										else
											break;
									}
									else
										break;
								}
								// if value field not already in list, add it to the list			
								if( NOT FindNoCase( paramsStruct.valueField, fieldList ) )
									fieldList = ListAppend( fieldList, paramsStruct.valueField ); 
							}
							else
							{
								fieldList = paramsStruct.valueField;
							}
							
							if (NOT Len(sortColumn) AND NOT Len(sortDir))
							{
								sortColumn = ListFirst(fieldList);
								sortDir = 'asc';
							}
							
							if( NOT ListFindNoCase(fieldList, sortColumn) )
								fieldList = ListAppend(fieldList, sortColumn);
							
							if (NOT ArrayLen(filterArray))
								filterArray[1] = '| element_datemodified| element_datemodified| <= | | c,c,c| | ';
								
							ceData = ceObj.getRecordsFromSavedFilter(elementID=ceFormID,queryEngineFilter=filterArray,columnList=fieldList,orderBy=sortColumn,orderByDirection=sortDir, limit=0);

							formIDColArray = ArrayNew(1);
							formNameColArray = ArrayNew(1);
							if (ceData.ResultQuery.RecordCount)
							{
								ArraySet(formIDColArray, 1, ceData.ResultQuery.RecordCount, ceFormID);
								ArraySet(formNameColArray, 1, ceData.ResultQuery.RecordCount, paramsStruct.customElement);
							}
							
							QueryAddColumn(ceData.ResultQuery, 'formID', formIDColArray);
							QueryAddColumn(ceData.ResultQuery, 'formName', formIDColArray);
						}
						ceDataArray = application.ADF.cedata.buildCEDataArrayFromQuery(ceData.ResultQuery);
	
						// cache the results					
						ceDataArrayLen = ArrayLen(ceDataArray);
						request['getContent_ceSelect'][fieldID].ceDataArray = ceDataArray;					
					
					
						// Custom element selects can 'Build' the display value.  Handle that case
						if( paramsStruct.displayField eq "--Other--" and Len(paramsStruct.displayFieldBuilder) )
						{
							// store the offset into the ceDataArray
							request['getContent_ceSelect'][fieldID].assocArray = StructNew();
							for(i=1; i LTE ceDataArrayLen; i=i+1 )
							{
								valueFld = ceDataArray[i].Values['#paramsStruct.valueField#'];
								request['getContent_ceSelect'][fieldID].assocArray[valueFld] = i;
							}	
						}	
						// Normal case - display value is just another field, no building display value from multiple fields. 
						// 	So store name value pairs.
						else if( paramsStruct.displayField neq ""	)
						{
							// store value and display field
							request['getContent_ceSelect'][fieldID].assocArray = StructNew();
							for(i=1; i LTE ceDataArrayLen; i=i+1 )
							{
								valueFld = ceDataArray[i].Values['#paramsStruct.valueField#'];
								displayFld = ceDataArray[i].Values['#paramsStruct.displayField#'];
								request['getContent_ceSelect'][fieldID].assocArray[valueFld] = displayFld;
							}	
						}
						// No display value, just return the value
						else
						{
							request['getContent_ceSelect'][fieldID].assocArray = '';						
						}
					}	
				</cfscript>
			</cfif>
		</cfif>
	</cfif>		
	
	<cfscript>
		// the Structure request['getContent_ceSelect'][fieldID] is built at this point.
	
		// Display Value is built from one or more fields
		if( arguments.fieldValue neq '' )
		{
			if( request['getContent_ceSelect'][fieldID].displayField eq "--Other--" 
					AND Len(request['getContent_ceSelect'][fieldID].displayFieldBuilder)
					AND StructKeyExists(request['getContent_ceSelect'][fieldID], 'assocArray')
					AND isStruct( request['getContent_ceSelect'][fieldID].assocArray )
					AND StructKeyExists( request['getContent_ceSelect'][fieldID].assocArray, arguments.fieldValue) )
			{
				i = request['getContent_ceSelect'][fieldID].assocArray[arguments.fieldValue];
				returnString = application.ADF.forms.renderDataValueStringfromFieldMask( request['getContent_ceSelect'][fieldID].ceDataArray[i].Values, request['getContent_ceSelect'][fieldID].displayFieldBuilder );
			}
			// Display Value is another field, simple lookup
			else if( isStruct( request['getContent_ceSelect'][fieldID].assocArray ) 
					AND StructKeyExists( request['getContent_ceSelect'][fieldID].assocArray, arguments.fieldValue) )
			{
				returnString = request['getContent_ceSelect'][fieldID].assocArray[arguments.fieldValue];
			}
			// Fall back, just pass back the value.
			else
			{
				returnString = arguments.fieldValue;
			}
		}
	</cfscript>
	
	<cfreturn returnString>
</cffunction>
	
<!------------------------------------------------------
	getContent_select()
-------------------------------------------------------->		
<cffunction name="getContent_select" returntype="string" access="private" hint="Get the content of the selection element">
	<cfargument name="fieldID" type="numeric" required="true" hint="ID of the field">
	<cfargument name="fieldValue" type="string" required="true" hint="Value of the field">
	
	<cfscript>
		var paramsData = '';
		var paramsStruct = StructNew();
		var selectOptions = StructNew();
		var returnString = arguments.fieldValue;
		var i = 0;
		var theArrayLen = 0;
		var build = 1;
		var valueText = '';
		var displayText = '';

		if( NOT StructKeyExists(request,'getContent_select') )
			request['getContent_select'] = structNew();
		if( NOT StructKeyExists(request['getContent_select'],fieldID ) )
		{
			request['getContent_select'][fieldID] = structNew();
			build = 1;
		}	
		else
			build = 0;
	</cfscript>
		
	<!--- 
		if first time through do the following:
			- get parameters of custom element select field
			- determine if filter is being used
			- get all records
			- store in results and other parameters in request	( request['getContent_select'][fieldID] )
	--->
	<cfif build eq 1>
		<cfquery name="paramsData" datasource="#Request.Site.Datasource#">
			SELECT Params
			  FROM FormInputControl
			 WHERE ID = <cfqueryparam value="#arguments.fieldID#" cfsqltype="cf_sql_integer">
		</cfquery>
			
		<cfif paramsData.RecordCount>
			<cfscript>
				paramsStruct = Server.CommonSpot.UDF.util.WDDXDecode(paramsData.Params);
			</cfscript>
	
			<cfif StructKeyExists(paramsStruct, 'ElementID') AND paramsStruct.ElementID gt 0>
				<!--- selection list is configured to point to a CE --->

				<cfif StructKeyExists(paramsStruct,"Mult") 
						AND paramsStruct.Mult eq 'no' 
						AND StructKeyExists(paramsStruct,"displayFieldID")
						AND paramsStruct.displayFieldID neq "">
						
					<!--- Normal case. Display value is just another field. So store name value pairs. --->
						
					<cfmodule template="/commonspot/metadata/form_control/input_control/resolve_optionlist.cfm"
							valsource="#paramsStruct.valSource#"
							valuelist="#paramsStruct.valList#"
							querystring="#paramsStruct.query#"
							queryDSN="#paramsStruct.queryDSN#"
							displaycolumn="#paramsStruct.dispCol#"
							valuecolumn="#paramsStruct.valCol#"
							usedefinedexpression="#paramsStruct.udef#"
							elementid="#paramsStruct.elementid#"
							fieldid="#paramsStruct.fieldid#"
							displayfieldid="#paramsStruct.displayFieldID#"
							valuefieldid="#paramsStruct.valueFieldID#"	
							filter="#paramsStruct.filter#"
							sortcolumn="#paramsStruct.sortcol#"
							return="selectOptions">
					
					<cfscript>
						request['getContent_select'][fieldID].assocArray = StructNew();

						theArrayLen = ArrayLen(selectOptions.optionValues);
						for( i=1; i lte theArrayLen; i=i+1 )
						{
							valueText = selectOptions.optionValues[i];
							displayText = selectOptions.optionText[i];
							request['getContent_select'][fieldID].assocArray[valueText] = displayText;
						}	
					</cfscript>
				</cfif>
			</cfif>	
		</cfif>
	</cfif>
	
	<cfscript>
		// the Structure request['getContent_select'][fieldID] is built at this point.
	
		// Display Value is another field, simple lookup
		if( StructKeyExists(request['getContent_select'][fieldID],'assocArray') 
				AND isStruct( request['getContent_select'][fieldID].assocArray )
				AND StructKeyExists( request['getContent_select'][fieldID].assocArray, arguments.fieldValue )
		   )
		{
			returnString = request['getContent_select'][fieldID].assocArray[arguments.fieldValue];
		}
		// Fall back, just pass back the value.
		else
		{
			returnString = arguments.fieldValue;
		}
	</cfscript>		
	
	<cfreturn returnString>
</cffunction>


<!------------------------------------------------------
	getContent_csurl()
-------------------------------------------------------->	
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


<!------------------------------------------------------
	DeleteSelectedRecords()
		- deletes one or more records that were selected.
-------------------------------------------------------->	
<cffunction name="DeleteSelectedRecords" access="public" returntype="void" hint="Given a list of dataPageIDs, delete the selected records." output="No">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="dataPageIDList" required="Yes" type="string">
	
	<cfscript>
		var ceObj = '';
		var dataPageID = '';
		var FormID = 0;
		
		if(NOT IsNumeric(arguments.propertiesStruct.assocCustomElement))
			FormID = arguments.propertiesStruct.childCustomElement;
		else
			FormID = arguments.propertiesStruct.assocCustomElement;
		
		
		if( val(arguments.dataPageIDList) eq 0 OR val(formID) eq 0 )
			return;
		
		ceObj = Server.CommonSpot.ObjectFactory.getObject("CustomElement");	
		
		for( i=1; i lte ListLen(arguments.dataPageIDList); i=i+1 ) 
		{
			// current method only deletes one at a time?? 
			try
			{
				dataPageID = ListGetAt( arguments.dataPageIDList, i );
				
				if( val(dataPageID) gt 0 )
				{
					ceObj.DeleteRecords( formID, dataPageID );
				}
			}
			catch (any e)	
			{
				application.adf.utils.logAppend( 'Could not delete custom element record from data manager. #e.message# #e.detail#', 'datamanager-delete.log' );
			}
		}				
	</cfscript>
</cffunction>


<!------------------------------------------------------
	getLinkedFieldValue()
-------------------------------------------------------->
<cffunction name="getLinkedFieldValue" returntype="string" access="private" hint="Get the linked field value depending on the field type">
	<cfargument name="fieldType" type="string" required="true" hint="Type of the field">
	<cfargument name="fieldValue" type="string" required="true" hint="Value of the field to compare">

	<cfscript>
		var dsn = Request.Site.Datasource;
		var returnString = arguments.fieldValue;
	</cfscript>
	
	<cfif arguments.fieldType EQ 'csextendedurl'>
		<cfquery name="getPageInfo" DATASOURCE="#dsn#">
			SELECT FileName, SubsiteID, PageType, Uploaded
			  FROM SitePages
			 WHERE ID = <cfqueryparam value="#arguments.fieldValue#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
		<cfscript>
			// Since extended url stored data differently for different page types, need to set up proper value to be checked
			if (getPageInfo.RecordCount)
			{
				// Just set to compare with pageID instead of the whole string as certain actions like move in CS do not update the value in DB
				/*if (getPageInfo.PageType EQ Request.Constants.pgTypeNormal AND getPageInfo.Uploaded EQ 0)
					returnString = 'CP___PAGEID=#arguments.fieldValue#,#getPageInfo.FileName#,#getPageInfo.SubsiteID#||CP___PAGEID=#arguments.fieldValue#,#getPageInfo.FileName#';
				else if ((getPageInfo.PageType EQ Request.Constants.pgTypeNormal AND getPageInfo.Uploaded EQ 1) OR getPageInfo.PageType EQ Request.Constants.pgTypeMultimedia OR getPageInfo.PageType EQ Request.Constants.pgTypeMultimediaPlaylist)
					returnString = 'CP___PAGEID=#arguments.fieldValue#';
				else if (getPageInfo.PageType EQ Request.Constants.pgTypeImage)
					returnString = 'CP___PAGEID=#arguments.fieldValue#,#getPageInfo.FileName#';
				else // PageType as user template,pageset,registered url
					returnString = 'CP___PAGEID=#arguments.fieldValue#,#getPageInfo.FileName#,#getPageInfo.SubsiteID#';*/
				returnString = 'CP___PAGEID=#arguments.fieldValue#';
			}
		</cfscript>
	<cfelseif arguments.fieldType EQ 'img'>
		<cfquery name="getPageInfo" DATASOURCE="#dsn#">
			SELECT Description
			  FROM SitePages
			 WHERE ID = <cfqueryparam value="#arguments.fieldValue#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
		<cfscript>
			if (getPageInfo.RecordCount)
				returnString = 'CPIMAGE:#arguments.fieldValue#|#getPageInfo.Description#';
		</cfscript>
	</cfif>
	
	<cfreturn returnString>
</cffunction>

</cfcomponent>