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
	DB Hierarchy Selector
Name:
	db_hierarchy_selector_base.cfc
Summary:
	This the base component for the DB Hierarchy Selector field
ADF Requirements:
	
History:
	2016-08-05 - GAC - Created

--->
<cfcomponent output="true" displayname="db_hierarchy_selector_base" extends="ADF.extensions.customfields.customfieldsBase" hint="Contains base functions to handle hierarchy selector">
	
	<cfscript>
		// ADF Path to this CFT
		variables.cftPath = "/ADF/extensions/customfields/db_hierarchy_selector";
		
		// Local Site Override
		//variables.cftPath = "/customfields/db_hierarchy_selector";
	</cfscript>

	<cffunction name="getDBtables" access="public" returntype="query">
		<cfargument name="dataSource" type="string" required="true" hint="String DSN Name">

		<cfscript>
			var tableQry = QueryNew("Table_Name");
			var tableData = QueryNew("temp");
			var dbType = request.Site.SiteDBType;
			var sqlFromTable = "INFORMATION_SCHEMA.TABLES"; 	// SQLServer and MySQL schema table name
			var oracleFromTable = "USER_TAB_COLUMNS";  			// Oracle schema table name
			var excludeTableList = "sysdiagrams,USER_PASSWORDS,USER_TOKEN";
		</cfscript>
	
		<cfif dbType NEQ "Oracle">
			<cfquery name="tableQry" datasource="#arguments.dataSource#">
				select * 
				from #sqlFromTable# 
				where TABLE_TYPE != <cfqueryparam value="SYSTEM TABLE" cfsqltype="cf_sql_varchar">
				and TABLE_NAME NOT IN (#ListQualify(excludeTableList,"'",",","all")#) 
				order by TABLE_NAME
			</cfquery>
		<cfelse>
			<cfdbinfo
				type="tables"
		    	datasource="#arguments.dataSource#"
		    	name="tableData">
			<!--- <cfdump var="#tableData#" expand=false> --->
			<cfquery name="tableQry" dbtype="query">
				SELECT Table_Name
				  FROM tableData
				 WHERE TABLE_TYPE != <cfqueryparam value="SYSTEM TABLE" cfsqltype="cf_sql_varchar">
			
				<!--- 
					AND 	TABLE_TYPE != <cfqueryparam value="VIEW" cfsqltype="cf_sql_varchar">
					AND 	TABLE_TYPE = <cfqueryparam value="TABLE" cfsqltype="cf_sql_varchar">
					AND  	TABLE_TYPE != <cfqueryparam value="SYSTEM TABLE" cfsqltype="cf_sql_varchar">
					AND 	TABLE_TYPE = <cfqueryparam value="table" cfsqltype="cf_sql_varchar">
				--->
			</cfquery>
		</cfif>
		<!--- <cfdump var="#tableQry#" expand=false> --->

		<cfreturn tableQry>
	</cffunction>
	
	<cffunction name="getTableColumns" access="public" returntype="query">
		<cfargument name="dataSource" type="string" required="true" hint="String DSN Name">
		<cfargument name="tableName" type="string" required="true" hint="String Table Name">

		<cfscript>
			var columnQry = QueryNew("COLUMN_NAME");
			//var columnData = QueryNew("temp");
		</cfscript>

		<cfdbinfo
				type="columns"
				datasource="#arguments.dataSource#"
				table="#arguments.tableName#"
				name="columnQry">
		<!--- <cfdump var="#columnQry#" expand=false>--->

		<cfreturn columnQry>
	</cffunction>
	
	<cffunction name="getActiveValues" access="public" returntype="query">
		<cfargument name="dataSource" type="string" required="true" hint="String DSN Name">
		<cfargument name="tableName" type="string" required="true" hint="String Table Name">
		<cfargument name="activeField" type="string" required="true" hint="String Active Field Name">
		
		<cfscript>
			var dataQry = QueryNew("Table_Name");
		</cfscript>
	
		<cfquery name="dataQry" datasource="#arguments.dataSource#">
			select DISTINCT #arguments.activeField# 
			from #arguments.tableName# 
			order by #arguments.activeField# 
		</cfquery>
		<!--- <cfdump var="#dataQry#" expand=false> --->

		<cfreturn dataQry>
	</cffunction>
	
	<cffunction name="getTreeData" access="public" returntype="query">
		<cfargument name="dataSource" type="string" required="true" hint="String DSN Name">
		<cfargument name="tableName" type="string" required="true" hint="String Table Name">
		<cfargument name="parentField" type="string" required="true" hint="String parentField Field Name">
		<cfargument name="valueField" type="string" required="true" hint="String Active Field Name">
		<cfargument name="displayField" type="string" required="true" hint="String Active Field Name">
		<cfargument name="activeField" type="string" required="false" default="" hint="String Active Field Name">
		<cfargument name="activeOperator" type="string" required="false" default="=" hint="String Active Value">
		<cfargument name="activeValue" type="string" required="false" default="" hint="String Active Value">
		<cfargument name="sortField" type="string" required="false" default="" hint="String Sort Field Name">
		
		<cfscript>
			var dataQry = QueryNew('');
		</cfscript>

		<cfquery name="dataQry" datasource="#arguments.dataSource#">
			select #arguments.parentField# AS ParentField, #arguments.valueField# AS ValueField, #arguments.displayField# AS DisplayField
			from #arguments.tableName# 
			where #arguments.activeField# #arguments.activeOperator# <cfqueryparam value="#arguments.activeValue#">
			order by #arguments.parentField#<cfif LEN(TRIM(arguments.sortField))>, #arguments.sortField#</cfif> 
		</cfquery>
		<!--- <cfdump var="#dataQry#" expand=false> --->

		<cfreturn dataQry>
	</cffunction>
	
	<cffunction name="renderStyles" access="public" returntype="void" hint="Method to render the styles for datamanager">		
   	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
		<cfscript>
			if ( !StructKeyExists(Request, 'objectHierarchyCSS') )
			{
				application.ADF.scripts.loadUnregisteredResource('#variables.cftPath#/db_hierarchy_selector_styles.css', "Stylesheet", "head", "secondary", 0, 0);
				request.objectHierarchyCSS = 1;
			}
		</cfscript>
    </cffunction>
	
	<cffunction name="getFilteredData" returntype="array" access="public" hint="Get the data filtered for the field of the custom elemnt" output="true">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties for the field">
		<cfargument name="currentValues" type="string" required="true" hint="Input the current values for the field">
		<cfargument name="elementID" type="numeric" required="true" hint="Custom element ID">
		<cfargument name="fieldID" type="numeric" required="true" hint="Custom element field ID">
		
		<cfscript>
			var dataMemArray = ArrayNew(1);
			var inputProps = arguments.propertiesStruct;
		</cfscript>
		
		<cflock name="objHierarchy" timeout="5" type="readOnly">
			<cfscript>
				if ( StructKeyExists(application, 'dbHierarchyCustomField') 
						AND StructKeyExists(Application.dbHierarchyCustomField, arguments.elementID)
						AND StructKeyExists(Application.dbHierarchyCustomField[arguments.elementID], arguments.fieldID)
						AND StructKeyExists(Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID], 'cache')
						AND ArrayLen( Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].cache ) gt 0 
					)
				{	
					dataMemArray = Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].cache;
				}	
			</cfscript>
		</cflock>
		
		<cfscript>
//writeDump(var=dataMemArray, expand=false);
		
			return dataMemArray;
		</cfscript>
    </cffunction>
	 
	<cffunction name="isMemoryStructureGood" returntype="boolean" access="public" hint="Check if the memory is good or not and rebuild the memory cache data">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties for the field">
		<cfargument name="elementID" type="numeric" required="true" hint="Custom element ID">
		<cfargument name="fieldID" type="numeric" required="true" hint="Custom element field ID">
		
        <cfscript>
			var getRecords = '';
			var isMemGood = 1;
			var cacheLastUpdate = '';
			var fieldProperties = arguments.propertiesStruct;
			// var objLastUpdate = request.site.availControls[arguments.elementID].lastUpdateSinceRestart;
			var eID = fieldProperties.customElement;	//TODO: Update to DB info - table		
			var objLastUpdate = request.site.availControls[eID].lastUpdateSinceRestart;
			var cacheData = ArrayNew(1);
			//var cfmlFilterCriteria = StructNew();
			var filterArray = ArrayNew(1);
			var defaultSortColumn = '';
			var i = 0;
			var memoryCache = StructNew();
			var cachedFilterArray = ArrayNew(1);
			var currentFilterArray = ArrayNew(1);
			var z = 0;
		</cfscript>
		
		<cflock name="objHierarchy" timeout="5" type="readOnly">
			<cfscript>	
				if (StructKeyExists(application,'dbHierarchyCustomField')
					AND StructKeyExists(application.dbHierarchyCustomField, eID)
					AND StructKeyExists(application.dbHierarchyCustomField[eID], arguments.fieldID))
				{
					memoryCache = application.dbHierarchyCustomField[eID][arguments.fieldID];
				}
			</cfscript>
		</cflock>
		
		<cfscript>
			if (NOT StructIsEmpty(memoryCache))
			{
				cacheLastUpdate = memoryCache.lastUpdate;
				cacheData = memoryCache.cache;
					 
				if ( ArrayLen(cacheData) AND (NOT IsDate(objLastUpdate) OR DateCompare(cacheLastUpdate, objLastUpdate) eq 1) )
					isMemGood = 1;  
				else
					isMemGood = 0;
				
				if (isMemGood)
				{
					if ( memoryCache.datasource NEQ fieldProperties.datasource
						OR memoryCache.tablename NEQ fieldProperties.tablename
						OR memoryCache.parentField NEQ fieldProperties.parentField
						OR memoryCache.valueField NEQ fieldProperties.valueField
						OR memoryCache.activeField NEQ fieldProperties.activeField
						OR memoryCache.activeOperator NEQ fieldProperties.activeOperator
						OR memoryCache.activeValue NEQ fieldProperties.activeValue
						OR memoryCache.sortField NEQ fieldProperties.sortField
						OR memoryCache.rootValue NEQ fieldProperties.rootValue
						OR memoryCache.rootNodeText NEQ fieldProperties.rootNodeText )
							isMemGood = 0;
				}
				
				if (isMemGood)
				{
					/* 
						if (StructKeyExists(fieldProperties, 'filterCriteria') AND IsWDDX(fieldProperties.filterCriteria))
						{
							cfmlFilterCriteria = Server.CommonSpot.UDF.util.WDDXDecode(fieldProperties.filterCriteria);			
							filterArray = cfmlFilterCriteria.filter.serSrchArray;
							defaultSortColumn = cfmlFilterCriteria.defaultSortColumn;
						}
						if (NOT ArrayLen(filterArray))
							filterArray[1] = '| element_datemodified| element_datemodified| <= | | c,c,c| | ';
						
						// check if filter contains #. If so assume filter has expression and make dynamic
						for( z=1; z lte ArrayLen(filterArray); z=z+1 )
						{
							if( Find( '##', filterArray[z] ) )
							{
								isMemGood = 0;
								break;
							}
						}
					*/
				
					if ( memoryCache.defaultSortColumn NEQ defaultSortColumn )
						isMemGood = 0;
					else
					{
						cachedFilterArray = memoryCache.filterArray;
						currentFilterArray = filterArray;
						if ( (ArrayLen(cachedFilterArray) AND NOT ArrayLen(currentFilterArray)) 
							OR (ArrayLen(currentFilterArray) AND NOT ArrayLen(cachedFilterArray))
							OR ArrayLen(currentFilterArray) NEQ ArrayLen(cachedFilterArray) )
								isMemGood = 0;
						else
						{
							for (i=1;i LTE ArrayLen(currentFilterArray);i=i+1)
							{
								if (currentFilterArray[i] NEQ cachedFilterArray[i])
								{
									isMemGood = 0;
									break;
								}
							}
						}
					}
				}
			}
			else
			{
				isMemGood = 0;
			}
			
			return isMemGood;
		</cfscript>
    </cffunction>
	
	<!---
		buildMemoryStructure()

		History:
			Fixed issue where if child node was ordered before parent, we would drop nodes.
	--->
	<cffunction name="buildMemoryStructure" returntype="void" access="public" hint="Build the memory structure" output="yes">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Memory cache name">
      <cfargument name="elementID" type="numeric" required="true" hint="Custom element ID">
		<cfargument name="fieldID" type="numeric" required="true" hint="Custom element field ID">
		
      <cfscript>
			var ceData = QueryNew('');
			var inputPropStruct = arguments.propertiesStruct;
			var parentFieldName = '';
			var displayFieldName = '';
			var valueFieldName = '';
			var fieldList = '';
			var errorMsg = '';
			var getFormattedData = QueryNew('');
			var dataArray = ArrayNew(1);
			var arrayIndex = 1;
			var filterArray = ArrayNew(1);
			var sortColumn = '';
			var sortDir = 'asc';
			var addedParents = StructNew();
			var defaultSortColumn = '';
			var dataSource = '';
			var tablename = '';
			var activeField = '';
			var activeOperator = '=';
			var activeValue = '';
			
			// Set the defaults
			if ( StructKeyExists(inputPropStruct,"datasource") AND LEN(TRIM(inputPropStruct.datasource)) )
				dataSource = inputPropStruct.datasource;
			if ( StructKeyExists(inputPropStruct,"tablename") AND LEN(TRIM(inputPropStruct.tablename)) )
				tablename = inputPropStruct.tablename;
			if ( StructKeyExists(inputPropStruct,"parentField") AND LEN(TRIM(inputPropStruct.parentField)) )
				parentFieldName = inputPropStruct.parentField;
			if ( StructKeyExists(inputPropStruct,"valueField") AND LEN(TRIM(inputPropStruct.valueField)) )
				valueFieldName = inputPropStruct.valueField;
			if ( StructKeyExists(inputPropStruct,"displayField") AND LEN(TRIM(inputPropStruct.displayField)) )
				displayFieldName = inputPropStruct.displayField;
			if ( StructKeyExists(inputPropStruct,"activeField") AND LEN(TRIM(inputPropStruct.activeField)) )
				activeField = inputPropStruct.activeField;
			if ( StructKeyExists(inputPropStruct,"activeOperator") AND LEN(TRIM(inputPropStruct.activeOperator)) )
				activeOperator = inputPropStruct.activeOperator;	
			if ( StructKeyExists(inputPropStruct,"activeValue") AND LEN(TRIM(inputPropStruct.activeValue)) )
				activeValue = inputPropStruct.activeValue;
			if ( StructKeyExists(inputPropStruct,"sortField") AND LEN(TRIM(inputPropStruct.sortField)) )
				defaultSortColumn = inputPropStruct.sortField;
		</cfscript>

		<cftry>

			<!--- <cfscript>
				if (ListFirst(parentFieldName,':') NEQ 'Error')
				{
					fieldList = parentFieldName;
					sortColumn = parentFieldName;
					displayFieldName = getFieldName(allFieldsQuery=ceFields, fieldID=inputPropStruct.displayField);
				}
				else
					errorMsg = ListRest(parentFieldName,':');

				if( NOT Len(ErrorMsg) AND ListFirst(displayFieldName,':') NEQ 'Error' )
				{
					if( NOT ListFindNoCase(fieldList, displayFieldName) AND displayFieldName neq '' )
						fieldList = ListAppend(fieldList, displayFieldName);
					valueFieldName = getFieldName(allFieldsQuery=ceFields, fieldID=inputPropStruct.valueField);
				}
				else
					errorMsg = ListRest(displayFieldName,':');
			</cfscript> --->

			<cfif NOT Len(ErrorMsg) AND ListFirst(valueFieldName,':') NEQ 'Error'>
				<!--- <cfscript>
					if (NOT ListFindNoCase(fieldList, valueFieldName))
						fieldList = ListAppend(fieldList, valueFieldName);
						
					if (StructKeyExists(inputPropStruct, 'filterCriteria') AND IsWDDX(inputPropStruct.filterCriteria))
					{
						cfmlFilterCriteria = Server.CommonSpot.UDF.util.WDDXDecode(inputPropStruct.filterCriteria);			
						filterArray = cfmlFilterCriteria.filter.serSrchArray;
						sortColumn = ListFirst(cfmlFilterCriteria.defaultSortColumn,'|');
						sortDir = ListLast(cfmlFilterCriteria.defaultSortColumn,'|');
						defaultSortColumn = cfmlFilterCriteria.defaultSortColumn;
					}
					
					if (NOT ArrayLen(filterArray))
						filterArray[1] = '| element_datemodified| element_datemodified| <= | | c,c,c| | ';

					if (NOT ListFindNoCase(fieldList, sortColumn))
						fieldList = ListAppend(fieldList, sortColumn);
						
					ceData = customElementObj.getRecordsFromSavedFilter( elementID=inputPropStruct.customElement, 
																				queryEngineFilter=filterArray, 
																				columnList=fieldList, 
																				orderBy=sortColumn, 
																				orderByDirection=sortDir, 
																				limit=0);
				</cfscript> --->
				
			<cfscript> 	
				getFormattedData = application.ADF.dbHierarchySelector.getTreeData(
													dataSource=datasource
													,tableName=tablename 
													,parentField=parentFieldName
													,valueField=valueFieldName
													,displayField=displayFieldName
													,activeField=activeField
													,activeOperator=activeOperator
													,activeValue=activeValue
													,sortField=defaultSortColumn 
												);
//writeDump(var=getFormattedData, expand=false);
			</cfscript> 
				
			<!---	<cfquery name="getFormattedData" dbtype="query">
					SELECT #parentFieldName# AS ParentField, #displayFieldName# AS DisplayField, #valueFieldName# AS ValueField
					  FROM ceData.ResultQuery
				 	ORDER BY #parentFieldName#
				<cfif sortColumn NEQ parentFieldName>
				 , #sortColumn# #sortDir#
				</cfif>
				</cfquery>--->

			<cfscript>
					if( inputPropStruct.RootNodeText neq '' )
					{
						arrayIndex = 1;
						dataArray[arrayIndex] = StructNew();
						dataArray[arrayIndex]['id'] = '#arguments.fieldID#_#inputPropStruct.rootValue#';
						dataArray[arrayIndex]['text'] = inputPropStruct.rootNodeText;
						dataArray[arrayIndex]['parent'] = '##';
						
						// "state": {"opened" : '' / true, "selected" : '' / true } - ''=false
						dataArray[arrayIndex]["state"] = StructNew();
						dataArray[arrayIndex]["state"]["opened"] = '';
						dataArray[arrayIndex]["state"]["selected"] = '';
					}						
					addedParents[inputPropStruct.rootValue] = StructNew();
			</cfscript>
				
			<cfif getFormattedData.RecordCount>
					<cfloop query="getFormattedData">
						<cfscript>
							// if the parent node has not already been added, add it and store off its offset into the array. 
							// 	They must exist before child nodes.
							if( NOT StructKeyExists( addedParents, getFormattedData.ParentField ) )
							{	
								arrayIndex = ArrayLen(dataArray) + 1;
								dataArray[arrayIndex] = StructNew();
								addedParents[getFormattedData.ParentField] = arrayIndex;
							}
							
							// If this node was already added into the array (processed a child already), get offset and 
							//		add info to that structure
							if( StructKeyExists( addedParents, getFormattedData.ValueField ) )
							{
								arrayIndex = addedParents[getFormattedData.ValueField];
							}	
							else	// otherwise append to the array
							{	
								arrayIndex = ArrayLen(dataArray) + 1;
								addedParents[getFormattedData.ValueField] = arrayIndex;
							}	
								
							dataArray[arrayIndex] = StructNew();
							dataArray[arrayIndex]['id'] = '#arguments.fieldID#_#getFormattedData.ValueField#';
							dataArray[arrayIndex]['text'] = "#getFormattedData.DisplayField#";
							
							if( getFormattedData.ParentField EQ inputPropStruct.rootValue )
							{
								if( inputPropStruct.RootNodeText neq '' )
									dataArray[arrayIndex]['parent'] = '#arguments.fieldID#_#inputPropStruct.rootValue#';
								else
									dataArray[arrayIndex]['parent'] = '##';
							}	
							else
								dataArray[arrayIndex]['parent'] = '#arguments.fieldID#_#getFormattedData.ParentField#';
							
							// "state": {"opened" : '' / true, "selected" : '' / true } ''=false
							dataArray[arrayIndex]["state"] = StructNew();
							dataArray[arrayIndex]["state"]["opened"] = '';
							dataArray[arrayIndex]["state"]["selected"] = '';
							
						</cfscript>
					</cfloop>
				</cfif>
			<cfelse>
				<cfscript>
					errorMsg = ListRest(valueFieldName,':');
				</cfscript>
			</cfif>
		<cfcatch>
			<CFMODULE TEMPLATE="/commonspot/utilities/log-append.cfm" comment="Error while trying to retrieve the fields: #cfcatch.message# :: #cfcatch.detail#">
			<cfscript>
				errorMsg = "Error occurred while trying to retrieve data the fields for the element.";
			</cfscript>
		</cfcatch>
		</cftry>

		<cfif Len(errorMsg)>
			<cfset dataArray[1] = errorMsg>
		<cfelse>
			<cflock name="objHierarchy" timeout="5" type="Exclusive"> 
			    <cfscript>
					if (NOT StructKeyExists(Application, 'dbHierarchyCustomField'))
						Application.dbHierarchyCustomField = StructNew();
					if (NOT StructKeyExists(Application.dbHierarchyCustomField, arguments.elementID))
						Application.dbHierarchyCustomField[arguments.elementID] = StructNew();
					if (NOT StructKeyExists(Application.dbHierarchyCustomField[arguments.elementID], arguments.fieldID))
						Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID] = StructNew(); 
					
					Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].lastUpdate = Request.FormattedTimestamp;
					Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].cache = dataArray;
					Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].datasource = datasource;
					Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].tablename = tablename;
					Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].parentField = parentFieldName;
					Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].displayField = displayFieldName;
					Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].valueField = valueFieldName;
					
					Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].activeField = activeField;
					Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].activeOperator = activeOperator;
					Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].activeValue = activeValue;
					Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].sortField = defaultSortColumn;

					
					Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].rootValue = propertiesStruct.rootValue;
					Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].rootNodeText = propertiesStruct.rootNodeText;
					//Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].filterArray = filterArray;
					Application.dbHierarchyCustomField[arguments.elementID][arguments.fieldID].defaultSortColumn = defaultSortColumn;
				</cfscript>
			</cflock>
		</cfif>
    </cffunction>

</cfcomponent>