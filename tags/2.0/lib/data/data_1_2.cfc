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
Name:
	data_1_2.cfc
Summary:
	Data Utils component functions for the ADF Library
Version:
	1.2
History:
	2012-12-31 - MFC/GAC - Created - New v1.2
	2013-02-28 - GAC - Added new string to number and number to string functions
	2013-09-06 - GAC - Added the listDiff and IsListDifferent functions
	2014-12-03 - GAC - Added the isNumericList function
	2015-02-13 - GAC - Added the tagValueCleanup function
	2015-06-10 - ACW - Updated the component extends to no longer be dependant on the 'ADF' in the extends path
	2015-07-16 - GAC - Added the highlightKeywords function
	2015-08-13 - GAC - Added arrayOfArraysToQuery function
--->
<cfcomponent displayname="data_1_2" extends="data_1_1" hint="Data Utils component functions for the ADF Library">

<cfproperty name="version" value="1_2_20">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Data_1_2">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$IsElementDataDifferent
Summary:
	Compares two data structures and then returns a true if they are different
Returns:
	Boolean
Arguments:
	Struct - structDataA
	Struct - elementDataB
	String - excludeFieldList
	Any - objectFieldKeyList
History:
	2012-10-19 - GAC - Created - MOVE INTO THE ADF V1.6
	2012-12-31 - Added 'objectFieldKeyList' argument for complex fields.
				 Added temp variables to copy the structure for comparison.
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean()
	2016-02-09 - GAC - Updated duplicateBean() to use data_2_0.duplicateStruct()
--->
<cffunction name="IsStructDataDifferent" access="public" returntype="boolean" hint="Compares two data structures and then returns a false if they are different">
	<cfargument name="structDataA" type="struct" required="true" hint="">
	<cfargument name="structDataB" type="struct" required="true" hint="">
	<cfargument name="excludeKeyList" type="string" required="false" default="" hint="">
	<cfargument name="objectFieldKeyList" type="any" required="false" default="" hint="">
	
	<cfscript>
		var isDifferent = false;
		var tempStructDataA = duplicateStruct(arguments.structDataA);
		var tempStructDataB = duplicateStruct(arguments.structDataB);
		var isEqual = compareStructData(structDataA=tempStructDataA,structDataB=tempStructDataB,excludeKeyList=arguments.excludeKeyList,objectFieldKeyList=arguments.objectFieldKeyList);
		if ( NOT isEqual )
			isDifferent = true;
		return isDifferent; 
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$compareStructData
Summary:
	Compares two data structures and then returns a true if they are the same
Returns:
	Boolean
Arguments:
	Struct - structDataA
	Struct - structDataB
	String - excludeKeyList
	Any - objectFieldKeyList
History:
	2012-10-19 - GAC - Created - MOVE INTO THE ADF V1.6
	2012-12-31 - Added 'objectFieldKeyList' argument for complex fields.
--->
<cffunction name="compareStructData" access="public" returntype="boolean" hint="Compares two data structures and then returns a false if they are different">
	<cfargument name="structDataA" type="struct" required="true" hint="">
	<cfargument name="structDataB" type="struct" required="true" hint="">
	<cfargument name="excludeKeyList" type="string" required="false" default="" hint="">
	<cfargument name="objectFieldKeyList" type="any" required="false" default="" hint="">
	
	<cfscript>
		var isEqual = false;
		var i=1;
		var currentKey = "";
		var dataAObjectValue = "";
		var dataBObjectValue = "";
		
		// Remove the Primary Keys before doing compare
		for ( i=1;i LTE ListLen(arguments.excludeKeyList);i=i+1 ) {
			currentKey = ListGetAt(arguments.excludeKeyList,i);
			if ( LEN(TRIM(currentKey)) )
			{
				if ( StructKeyExists(arguments.structDataA,currentKey) )
					StructDelete(arguments.structDataA,currentKey);
				if ( StructKeyExists(arguments.structDataB,currentKey) )
					StructDelete(arguments.structDataB,currentKey);		
			}
		}
		// Loop over the object fields to compare them individually
		for ( i=1;i LTE ListLen(arguments.objectFieldKeyList);i=i+1 ) {
			currentKey = ListGetAt(arguments.objectFieldKeyList,i);
			if ( LEN(TRIM(currentKey)) )
			{
				// Compare the object fields
				if ( isJSON(arguments.structDataA[currentKey])
						AND isJSON(arguments.structDataB[currentKey]) ) 
				{
					// Set into variables to run the comparison
					dataAObjectValue = deserializeJSON(arguments.structDataA[currentKey]);
					dataBObjectValue = deserializeJSON(arguments.structDataB[currentKey]);
					// If not equal, then end all the remaining comparisons
					if ( NOT dataAObjectValue.EQUALS(dataBObjectValue) )
						return false;		
				}
				
				// If not equal, then remove from the structs for the final compare
				if ( StructKeyExists(arguments.structDataA,currentKey) )
					StructDelete(arguments.structDataA,currentKey);
				if ( StructKeyExists(arguments.structDataB,currentKey) )
					StructDelete(arguments.structDataB,currentKey);		
			}
		}
		
		// Check the entire object because it is faster.
		if ( arguments.structDataA.EQUALS(arguments.structDataB) )
			isEqual = true;
		return isEqual;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$listAppendNoDuplicates
Summary:
	Adds an item to a list only if the item is not already in the list
Returns:
	Boolean
Arguments:
	String - list
	String - value
	String - delimiters
History:
	2012-10-19 - GAC - Created - MOVE INTO THE ADF V1.6
--->
<cffunction name="listAppendNoDuplicates" access="public" returntype="string" hint="">
	<cfargument name="list" type="string" required="true" hint="">
	<cfargument name="value" type="string" required="false" default="" hint="">
	<cfargument name="delimiters" type="string" required="false" default="," hint="Delimiter for the list.  Defualt is comma. (Optional)">
	
	<cfscript>
		var retStr = arguments.list;
		if ( NOT listFindNoCase(arguments.list,arguments.value,arguments.delimiters) )
			retStr = listAppend(arguments.list,arguments.value,arguments.delimiters);
		return retStr;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$stripHTMLtags
Summary:
	Removes HTML tags from a text string
Returns:
	String 
Arguments:
	String - str
	String - replaceStr
History:
	2012-10-19 - GAC - Created
--->
<cffunction name="stripHTMLtags" access="public" returntype="string" hint="Removes HTML tags from a text string">
	<cfargument name="str" type="string" required="true">
	<cfargument name="replaceStr" type="string" default="" required="false">
	
	<cfscript>
		var findStr = "<[^>]*>";
		return REREPLACE(arguments.str,findStr,arguments.replaceStr,'all');
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$unescapeHTMLentities
Summary:
	Converts HTML entities back to their text values
Returns:
	String 
Arguments:
	String - str
History:
	2012-10-19 - GAC - Created
--->
<cffunction name="unescapeHTMLentities" access="public" returntype="string" hint="Converts HTML entities back to their text values">
	<cfargument name="str" type="string" required="true">
	
	<cfscript>
		return server.commonspot.udf.html.unescape(arguments.str);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	Mike Gillespie (mike@striking.com)
Name:
	$filterInternationlChars
Summary:
	Converts HTML entities back to their text values

	* Will replace chars in a string to be used to create a folder with valid equivalent replacements
	* @param fileName      Name of file. (Required)
	* @return Returns a string.
	* @author Mike Gillespie (mike@striking.com)
	* @version 1, May 9, 2003
	* FIXED BY 2010-01-20 - GAC
Returns:
	String 
Arguments:
	String - str
History:
	2010-01-20 - GAC - Added
	2013-12-30 - DMB - modified to use CHR in the strings to provide compatibility with Railo
						For documentation purposes, these are the original strings:	
						var bad_chars="/,\,*,&,%,$,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�";
						var good_chars="-,-,-,-,-,-,-,AE,C,D,N,Y,I,B,ae,c,o,n,-,o,y,1,y";
--->
<cffunction name="filterInternationlChars" access="public" returntype="string" output="false" hint="Will replace chars in a string to be used to create a folder with valid equivalent replacements">
	<cfargument name="fileName" type="string" required="true" hint="">
	
	<cfscript>
		var bad_chars="#chr(47)#,#chr(92)#,#chr(42)#,#chr(38)#,#chr(37)#,#chr(36)#,#chr(191)#,#chr(198)#,#chr(199)#,#chr(208)#,#chr(209)#,#chr(221)#,#chr(222)#,#chr(223)#,#chr(230)#,#chr(231)#,#chr(240)#,#chr(241)#,#chr(247)#,#chr(248)#,#chr(253)#,#chr(254)#,#chr(255)#";
		var good_chars="#chr(45)#,#chr(45)#,#chr(45)#,#chr(45)#,#chr(45)#,#chr(45)#,#chr(45)#,#chr(65)#,#chr(67)#,#chr(68)#,#chr(78)#,#chr(89)#,#chr(73)#,#chr(66)#,#chr(97)#,#chr(99)#,#chr(111)#,#chr(110)#,#chr(45)#,#chr(111)#,#chr(121)#,#chr(49)#,#chr(121)#";
		var scrubbed="";
		var b = "0";
		
		// A's
		for (b = 192; b LTE 197; b++) {
			bad_chars=listAppend(bad_chars,CHR(b));
			good_chars=listAppend(good_chars,"A");
		}
		// a's
		for (b = 224; b LTE 229; b++) {
			bad_chars=listAppend(bad_chars,CHR(b));
			good_chars=listAppend(good_chars,"a");
		}
		// E's
		for (b = 200; b LTE 203; b++) {
			bad_chars=listAppend(bad_chars,CHR(b));
			good_chars=listAppend(good_chars,"E");
		}
		// e's
		for (b = 232; b LTE 235; b++) {
			bad_chars=listAppend(bad_chars,CHR(b));
			good_chars=listAppend(good_chars,"e");
		}
		// I's
		for (b = 204; b LTE 207; b++) {
			bad_chars=listAppend(bad_chars,CHR(b));
			good_chars=listAppend(good_chars,"I");
		}
		// i's
		for (b = 236; b LTE 239; b++) {
			bad_chars=listAppend(bad_chars,CHR(b));
			good_chars=listAppend(good_chars,"i");
		}
		// 0's
		for (b = 210; b LTE 216; b++) {
			bad_chars=listAppend(bad_chars,CHR(b));
			good_chars=listAppend(good_chars,"O");
		}
		// o's
		for (b = 242; b LTE 246; b++) {
			bad_chars=listAppend(bad_chars,CHR(b));
			good_chars=listAppend(good_chars,"o");
		}
		// U's
		for (b = 217; b LTE 220; b++) {
			bad_chars=listAppend(bad_chars,CHR(b));
			good_chars=listAppend(good_chars,"U");
		}
		// u's
		for (b = 249; b LTE 252; b++) {
			bad_chars=listAppend(bad_chars,CHR(b));
			good_chars=listAppend(good_chars,"u");
		}
		
		if ( arguments.fileName eq "" ) 
			return "";
		else
			return replace(replace(ReplaceList(trim(arguments.fileName), bad_chars, good_chars)," ","_","all"),"'","","all");
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$QuerySort
Summary:
	Sort a query based on a specific column in the query
Returns:
	query 
Arguments:
	Query - query
	String - orderColumn
	String - orderType
	String - orderColumnAlias
History:
	2013-10-23 - GAC - Created
	2014-02-05 - GAC - Removed the requirement for an orderType in the order by statement.
	2015-02-06 - GAC - Added code to protect against reserved word usage as well as columns with spaces query column names	 
					 - Added fix for query of query case sensitivity issue
					 - Updated error handling to write a log file and return no records (will help not mask the error as much)
	2015-02-13 - GAC - Reorganized the code and update the comments
Usage:
	Application.ADF.data.QuerySort(query,columnName,orderType)
--->
<cffunction name="QuerySort" displayname="QuerySort" access="public" hint="Sort a query based on a custom list" returntype="query" output="true">
    <cfargument name="query" type="query" required="yes" hint="The query to be sorted">
    <cfargument name="columnName" type="string" required="no" default="" hint="The name of the column to be sorted">
    <cfargument name="orderType" type="string" required="no" default="asc" hint="The sort type. Options: asc, desc">
	<cfargument name="orderColumnAlias" type="string" required="no" default="xRecSortCol" hint="The alias for the column name used for sorting. Must be unique and not a column the original query">
	
    <cfscript>
		var qResult = queryNew("null");
		var qColumnsList = arguments.query.columnList;
		var newColList = "";
		var orderCol = "";
		var orderTypeDefaults = "asc,desc";
		var orderTypeOption = "";
		var logSQL = (structKeyExists(Request.Params,"adfLogQuerySQL") and Request.Params.adfLogQuerySQL eq 1);
		var logMsg = "[data_1_2.QuerySort]";
		var createQueryResult = "";
		
		// Protect against reserved words or columns with spaces query column names	
		// - Wrap the query column names in brackets ([])
		// - ONLY brackets are needed since this is a CF query of queries
		newColList = "[" & Replace(qColumnsList,",","],[","all") & "]";
		
		// Make sure the Column that is used to ORDER BY is one of available columns
		if ( LEN(TRIM(arguments.columnName)) AND ListFindNoCase(qColumnsList,arguments.columnName) )
			orderCol = arguments.columnName;

		if ( ListFindNoCase(orderTypeDefaults,arguments.orderType) )
			orderTypeOption = arguments.orderType;

		// A saftey catch so there is always a custom sort orderColumnAlias defined
		if ( LEN(TRIM(arguments.orderColumnAlias)) EQ 0 )
			arguments.orderColumnAlias = "recSortCol";
			
		// Also make sure the orderColumnAlias is unique and not one of the query columns
		if ( ListFindNoCase(qColumnsList,arguments.orderColumnAlias) )
			arguments.orderColumnAlias = "xNew" & arguments.orderColumnAlias;
	</cfscript>
    
    <cftry>
		<cfquery name="qResult" dbtype="query">
			SELECT #newColList#<cfif LEN(TRIM(orderCol))>,LOWER([#orderCol#]) AS [#arguments.orderColumnAlias#]</cfif>
			FROM arguments.query
			<cfif LEN(TRIM(orderCol))>
			ORDER BY [#arguments.orderColumnAlias#] #orderTypeOption#
			</cfif>
		</cfquery>
		
		<!--- // If requested... log the generated SQL --->
		<cfif logSQL>
			<cfset logMsg = logMsg & " Generated Query SQL:">
			<cfif StructKeyExists(createQueryResult,"sql")>
				<cfset logMsg = logMsg & "#chr(10)#SQL:#chr(10)##createQueryResult.sql#">
			</cfif>
			<cfif StructKeyExists(createQueryResult,"sqlparameters")>
				<cfset logMsg = logMsg & "#chr(10)#PARAMS:#chr(10)##ArrayToList(createQueryResult.sqlparameters)#">
			</cfif>
			<cfset logMsg = logMsg & "#repeatString("-", 50)#">
			<cfset application.ADF.utils.logAppend(logMsg,"ADFlogQuerySQL.log")>
		</cfif>
		
    	<cfreturn qResult>
		
		<cfcatch>
			<!--- // Build an Error Log entry --->
			<cfset logMsg = logMsg & " Error building query: #cfcatch.message#">
			<cfif StructKeyExists(cfcatch,"detail")>
				<cfset logMsg = logMsg & "#chr(10)#Detail: #cfcatch.detail#">
			</cfif>
			<cfif StructKeyExists(cfcatch,"sql")>
				<!--- // Include the generated sql in the error log --->
				<cfset logMsg = logMsg & "#chr(10)#SQL:#chr(10)##cfcatch.sql#">
			</cfif>
			<cfif StructKeyExists(cfcatch,"where")>
				<cfset logMsg = logMsg & "#chr(10)#PARAMS:#chr(10)##cfcatch.where#">
			</cfif>
			<cfset logMsg = logMsg & "#repeatString("-", 50)#">
			<cfset application.ADF.utils.logAppend(logMsg)> 

			<!--- <cfdump var="#cfcatch#" label="cfcatch" expand="false"> --->
			<!--- <cfreturn arguments.query> --->
			
			<!--- // If there was a problem don't return any results... returning incorrect or unsorted results just masks the issue --->
			<cfreturn QueryNew("#qColumnsList#")>
		</cfcatch>
	</cftry>    
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$QuerySortByOrderedList
Summary:
	Sort a query based on a custom ordered list.
	http://cookbooks.adobe.com/post_Sort_query_in_custom_order-17997.html 
Returns:
	query 
Arguments:
	query - query
	String - columnName
	String - columnType
	String - orderList
	String - orderColumnAlias
	String - orderListDelimiter
Deprecated Arguments:	
	String - orderColumnName ( replaced by orderColumnAlias)
Usage:
	application.ADF.data.QuerySortByOrderedList(query,columnNam,columnTypee,orderList);
History:
	2013-01-10 - MFC - Created
	2013-10-23 - GAC - Renamed and cleaned up debug code in the method  
					   Added null value protection logic around the ORDER BY statement
	2014-02-05 - GAC - Updated to handle reserved words
					 - Updated to auto-detect numeric and date comparisons. So now passing a column type is not needed unless forcing a specific type.
	2013-02-06 - GAC - Updated the FORCE and AUTO-DETECT columnType logic. 
					 - Updated the generated SQL output and error logging.
					 - Added safety checks for the custom sort column name
	2014-03-05 - JTP - Var declarations
	2015-02-06 - GAC - Updated the orderColumnName parameter to be orderColumnAlias. The parameter name orderColumnName was misleading.
					 - Added backward compatibity for the deprecated Parameter "orderColumnName"
					 - Changed the qColumnsList LOOP to a use REPLACE instead to add the brackets around reserved words 
--->
<cffunction name="QuerySortByOrderedList" displayname="QuerySortByOrderedList" access="public" hint="Sort a query based on a custom ordered list" returntype="query" output="false">
    <cfargument name="query" type="query" required="yes" hint="The query to be sorted">
    <cfargument name="columnName" type="string" required="yes" hint="The name of the column to be sorted">
    <cfargument name="columnType" type="string" required="no" default="" hint="The column type. Not required, will auto-detect. But possible override values: numeric, varchar, date">
    <cfargument name="orderList" type="string" required="yes" hint="The list used to sort the query">
	<cfargument name="orderColumnAlias" type="string" required="no" default="xRecSortCol" hint="The alias for the column containing the order number. Must be unique and not a column the original query."> 
	<cfargument name="orderListDelimiter" type="string" required="no" default=",">
				
    <cfscript>
		var qResult = queryNew("null");
		var qColumnsList = arguments.query.columnList;
		var orderItem = "";
		var columnTypesAllowed = "varchar,numeric,date";
		var columnTypeOverride = "";
		var newColList = "";
		var criteriaValue = "";
		var logSQL = (structKeyExists(Request.Params,"adfLogQuerySQL") and Request.Params.adfLogQuerySQL eq 1);
		var logMsg = "[data_1_2.QuerySortByOrderedList]";
		var createQueryResult = '';
		
		// If a columnType is passed in set it as the override Column Type
		if ( ListFindNoCase(columnTypesAllowed,arguments.columnType) )
			columnTypeOverride = arguments.columnType;
		
		// Protect against reserved words or columns with spaces query column names	
		// - Wrap the query column names in brackets ([])
		// - ONLY brackets are needed since this is a CF query of queries
		newColList = "[" & Replace(qColumnsList,",","],[","all") & "]";
		
		// Backwards compatiblity code to handle PARAMETER change
		if ( StructKeyExists(arguments,"orderColumnName") AND LEN(TRIM(arguments.orderColumnName)) )
			arguments.orderColumnAlias = arguments.orderColumnName;
		
		// A saftey catch so there is always a custom sort orderColumnAlias defined
		if ( LEN(TRIM(arguments.orderColumnAlias)) EQ 0 )
			arguments.orderColumnAlias = "recSortCol";
			
		// Also make sure the orderColumnAlias is unique and not one of the query columns
		if ( ListFindNoCase(qColumnsList,arguments.orderColumnAlias) )
			arguments.orderColumnAlias = "xNew" & arguments.orderColumnAlias;
	</cfscript>
		
    <!--- // Make the order list unique to avoid duplicating query records --->
    <cftry>
		<cfquery name="qResult" dbtype="query" result="createQueryResult">
			<cfloop from="1" to="#listLen(arguments.orderList, arguments.orderListDelimiter)#" index="orderItem">
				SELECT #newColList#, #orderItem# AS [#arguments.orderColumnAlias#]
				FROM arguments.query
				<!--- // Set the Criteria Value for the WHERE clause --->
				<cfset criteriaValue = listGetAt(arguments.orderList, orderItem, arguments.orderListDelimiter)>
				<!--- // Build the WHERE clause --->
				<cfif columnTypeOverride EQ "numeric" OR (IsNumeric(criteriaValue) AND LEN(TRIM(columnTypeOverride)) EQ 0)>
					<!--- // If the columnType is FORCED then obey the passed in Type even if it is WRONG --->
					WHERE [#arguments.columnName#] = <cfqueryparam value="#criteriaValue#" cfsqltype="cf_sql_numeric">
				<cfelseif columnTypeOverride EQ "date" OR (IsDate(criteriaValue) AND LEN(TRIM(columnTypeOverride)) EQ 0)>
					<!--- // If the columnType is FORCED then obey the passed in Type even if it is WRONG --->
					WHERE CAST([#arguments.columnName#] AS DATE) = CAST(<cfqueryparam value="#criteriaValue#" cfsqltype="cf_sql_date"> AS DATE)
				<cfelse>
					WHERE LOWER([#arguments.columnName#]) = <cfqueryparam value="#lcase(criteriaValue)#" cfsqltype="cf_sql_varchar">
				</cfif>
				
				<cfif orderItem LT listLen(arguments.orderList, arguments.orderListDelimiter)>
					UNION
				</cfif>
			</cfloop>
			
			ORDER BY [#arguments.orderColumnAlias#]
		</cfquery>
		
		<!--- // If requested... log the generated SQL --->
		<cfif logSQL>
			<cfset logMsg = logMsg & " Generated Query SQL:">
			<cfif StructKeyExists(createQueryResult,"sql")>
				<cfset logMsg = logMsg & "#chr(10)#SQL:#chr(10)##createQueryResult.sql#">
			</cfif>
			<cfif StructKeyExists(createQueryResult,"sqlparameters")>
				<cfset logMsg = logMsg & "#chr(10)#PARAMS:#chr(10)##ArrayToList(createQueryResult.sqlparameters)#">
			</cfif>
			<cfset logMsg = logMsg & "#repeatString("-", 50)#">
			<cfset application.ADF.utils.logAppend(logMsg,"ADFlogQuerySQL.log")>
		</cfif>
		
		<!--- // Everything seems good... so return the results --->
    	<cfreturn qResult>
		
		<cfcatch>
			<!--- // Build an Error Log entry --->
			<cfset logMsg = logMsg & " Error building query: #cfcatch.message#">
			<cfif StructKeyExists(cfcatch,"detail")>
				<cfset logMsg = logMsg & "#chr(10)#Detail: #cfcatch.detail#">
			</cfif>
			<cfif StructKeyExists(cfcatch,"sql")>
				<!--- // Include the generated sql in the error log --->
				<cfset logMsg = logMsg & "#chr(10)#SQL:#chr(10)##cfcatch.sql#">
			</cfif>
			<cfif StructKeyExists(cfcatch,"where")>
				<cfset logMsg = logMsg & "#chr(10)#PARAMS:#chr(10)##cfcatch.where#">
			</cfif>
			<cfset logMsg = logMsg & "#repeatString("-", 50)#">
			<cfset application.ADF.utils.logAppend(logMsg)> 
			
			<!--- <cfdump var="#cfcatch#" label="cfcatch" expand="false"> --->
			
			<!--- // If there was a problem don't return any results... returning incorrect results just masks the issue --->
			<cfreturn QueryNew("#qColumnsList#")>
		</cfcatch>
	</cftry>    
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	Mark Andrachek
Name:
	$getOrdinalSuffixforNumber
Summary:
	This function returns the 2 character english text ordinal for numbers.
	
	aka. GetOrdinal(num)
	http://cflib.org/index.cfm?event=page.udfbyid&udfid=349
	
 	@author Mark Andrachek (&#104;&#97;&#108;&#108;&#111;&#119;&#64;&#119;&#101;&#98;&#109;&#97;&#103;&#101;&#115;&#46;&#99;&#111;&#109;) 
	@version 1, November 5, 2003 
Returns:
	String
Arguments:
	String - number
History:
	2013-02-28 - GAC - Added from CFLib.org
--->
<cffunction name="getOrdinalSuffixforNumber" access="public" output="false" returntype="string" hint="This function returns the 2 character english text ordinal for numbers.">
	<cfargument name="number" type="numeric" required="true" hint="">
	
	<cfscript>
		// if the right 2 digits are 11, 12, or 13, set number to them.
  		// Otherwise we just want the digit in the one's place.
  		var two=Right(arguments.number,2);
  		var ordinal="";
  		
  		switch(two) 
		{
       		case "11": 
       		case "12": 
       		case "13": { arguments.number = two; break; }
       		default: { arguments.number = Right(arguments.number,1); break; }
  		}

		// 1st, 2nd, 3rd, everything else is "th"
		switch(arguments.number) 
		{
			case "1": { ordinal = "st"; break; }
			case "2": { ordinal = "nd"; break; }
			case "3": { ordinal = "rd"; break; }
			default: { ordinal = "th"; break; }
		}
  		// return the text.
 		return ordinal;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$NumberToOrdinal
Summary:
	Returns an Ordinal string version of a number from a numeric value (1 = first, 2 = second, 3 = thrid)
	
	Uses the NumberAsString method convert the numeric value to a string and then uses the CardinalToOrdinal method
	to convert the number string to an ordinal for the number
Returns:
	String
Arguments:
	numeric - number
History:
	2013-02-28 - GAC - Created
--->
<cffunction name="numberToOrdinal" access="public" output="false" returntype="string" hint="Returns an Ordinal string version of a number from a numeric value.">
	<cfargument name="number" type="numeric" required="true" hint="">
	
	<cfscript>
		return cardinalToOrdinal(NumberAsString(number));
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	Howard Fore
Name:
	$cardinalToOrdinal
Summary:
	This function converts cardinal number strings (one, two, three) to ordinal number strings (first, second, thrid).
	
	http://cflib.org/index.cfm?event=page.udfbyid&udfid=918
	
 	@author Howard Fore (&#109;&#101;&#64;&#104;&#111;&#102;&#111;&#46;&#99;&#111;&#109;) 
 	@version 1, May 26, 2003
Returns:
	String
Arguments:
	String - cardinalString
History:
	2013-02-28 - GAC - Added from CFLib.org
	2014-03-05 - JTP - Var declarations
--->
<cffunction name="cardinalToOrdinal" access="public" output="false" returntype="string" hint="This function converts cardinal number strings to ordinal number strings..">
	<cfargument name="cardinalString" type="string" required="true" hint="">
	
	<cfscript>  
		var resultString = "";        // Generated result to return
	 	var lastCardinal = "";        // Last word in cardinal number string
	  	var TempNum = 0;              // temp integer
  		var cardinalSpecialStrings = "One,one,Two,two,Three,three,Four,four,Five,five,Six,six,Eight,eight,Nine,nine,Twelve,twelve";
  		var ordinalSpecialStrings = "First,first,Second,second,Third,third,Fourth,fourth,Fifth,fifth,Sixth,sixth,Eighth,eighth,Ninth,ninth,Twelfth,twelfth";
  
  		arguments.cardinalString = trim(arguments.cardinalString);
 		lastCardinal = listLast(arguments.cardinalString," ");
  		resultString = ListDeleteAt(arguments.cardinalString,ListLen(arguments.cardinalString," ")," ");
  
		// Is lastCardinal a special case?
		TempNum = listFindNoCase(cardinalSpecialStrings,lastCardinal);
		if (TempNum GT 0) 
		{
		  	resultString = ListAppend(resultString,ListGetAt(ordinalSpecialStrings,TempNum)," ");
		} 
		else 
		{
		    if (ListFindNoCase(Right(lastCardinal,2),"en")) 
			{
		      // Last word ends with "en", add "th"
		      resultString = ListAppend(resultString,lastCardinal & "th"," ");
		    } 
		    if (ListFindNoCase(Right(lastCardinal,1),"d")) 
			{
		      // Last word ends with "d", add "th"
		      resultString = ListAppend(resultString,lastCardinal & "th"," ");
		    } 
		    if (ListFindNoCase(Right(lastCardinal,1),"y")) 
			{
		      // Last word ends with "y", delete "y", add "ieth"
		      resultString = ListAppend(resultString, Left(lastCardinal,Len(lastCardinal) - 1) & "ieth"," ");
		    } 
		    if (ListFindNoCase(Right(lastCardinal,3),"ion")) 
			{
		      // Last word ends with "ion", add "th"
		      resultString = ListAppend(resultString,lastCardinal & "th"," ");
		    } 
		}
		return resultString;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$IsListDifferent
Summary:
	Compares two lists and then returns a true if they are different
Returns:
	Boolean
Arguments:
	String - list1
	String - list2
	String - delimiters
History:
	2013-04-11 - GAC - Created
--->
<cffunction name="IsListDifferent" access="public" returntype="string" hint="Compares two lists and then returns a true if they are different">
	<cfargument name="list1" type="string" required="false" default="" hint="First list to compare">
	<cfargument name="list2" type="string" required="false" default="" hint="Second list to compare">
	<cfargument name="delimiters" type="string" required="false" default="," hint="Delimiter for all lists.  Defualt is comma. (Optional)">
	
	<cfscript>
		 var isDifferent = true;
		 var listDifferences = listDiff(list1=arguments.list1,list2=arguments.list2,delimiters=arguments.delimiters);
		 if ( ListLen(listDifferences, arguments.delimiters) EQ 0 )
		 	isDifferent = false;
		 return isDifferent;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
From CFLib on 04/05/2012 [GAC]
	
Name:
	$listDiff
	
	This function compares two lists and returns the elements that do not appear in both lists.
	
	@param list1 	 First list to compare (Required)
	@param list2 	 Second list to compare (Required)
	@param delimiters 	 Delimiter for all lists.  Defualt is comma. (Optional)
	@return Returns a string. 
	
	@author Ivan Rodriguez (&#119;&#97;&#110;&#116;&#101;&#122;&#48;&#49;&#53;&#64;&#104;&#111;&#116;&#109;&#97;&#105;&#108;&#46;&#99;&#111;&#109;) 
	@version 1, June 26, 2002 
	
	http://cflib.org/udf/ListDiff

History:
	2013-04-11 - GAC - Added
--->
<cffunction name="listDiff" access="public" returntype="string" hint="Compares two lists and returns the elements that do not appear in both lists.">
	<cfargument name="list1" type="string" required="false" default="" hint="First list to compare">
	<cfargument name="list2" type="string" required="false" default="" hint="Second list to compare">
	<cfargument name="delimiters" type="string" required="false" default="," hint="Delimiter for all lists.  Defualt is comma. (Optional)">
	
	<cfscript>
		var listReturn = "";
		var position = 1;	
		var value = "";	
		//checking list1
	  	for ( position = 1; position LTE ListLen(arguments.list1,arguments.delimiters); position = position + 1 ) {
		    value = ListGetAt(arguments.list1, position , arguments.delimiters);
		    if ( ListFindNoCase(arguments.list2, value , arguments.delimiters) EQ 0 )
		      listReturn = ListAppend(listReturn, value , arguments.delimiters );
	    }	
	    //checking list2
	    for ( position = 1; position LTE ListLen(arguments.list2,arguments.delimiters); position = position + 1 ) {
	      value = ListGetAt(arguments.list2, position , arguments.delimiters);
	      if ( ListFindNoCase(arguments.list1, value , arguments.delimiters) EQ 0 )
	        listReturn = ListAppend(listReturn, value , arguments.delimiters );
	  	}
		return listReturn;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$verifyTableExists
Summary:
	Verifies that a DB Table or View exists
	
	--Tested with MySQL and MSSQL
Returns:
	boolean
Arguments:
	String - tableName
	String - datasourseName
	String - databaseType
History:
	2013-11-18 - GAC - Created
					 - Moved to data_1_2 from ceData_2_0.verifyViewTableExists and genernalized to check existance of any table or view not just custom element specific views
					 - Added a dbType logic to add additional 'table_schema' criteria for MySQL
					 - Added different table schema name for Oracle (thanks DM)
					 - Added logging to the CFCatch rather than just returning false
	2013-11-18 - GAC - Fixed issue with logAppend() method call		
	2013-11-19 - DM  - Adding compatiblity of ORACLE	
	2013-12-05 - GAC - Removed the table name check logic around the verifyDB query
	2014-03-05 - JTP - Var declarations
--->
<cffunction name="verifyTableExists" access="public" returntype="boolean" output="false" hint="Verifies that a Tables and View Table exist for various db types.">
	<cfargument name="tableName" type="string" required="true">
	<cfargument name="datasourseName" type="string" required="false" default="#Request.Site.DataSource#">
	<cfargument name="databaseType" type="string" required="false" default="#Request.Site.SiteDBType#">
	
	<cfscript>
		var verifyDB = '';
		var verifySourceDB = QueryNew("temp");
		var datasourse = arguments.datasourseName;
		var dbType = arguments.databaseType;
		var selectFromTable = "INFORMATION_SCHEMA.TABLES"; // SQLServer and MySQL schema table
		// CFM 9+ syntax
		//var selectFromTable = (dbType == "Oracle") ? "USER_TAB_COLUMNS" : "INFORMATION_SCHEMA.TABLES"; 
		var utilsLib = server.ADF.objectFactory.getBean("utils_1_2");

		
		// Schema Table for ORACLE
		if ( dbType EQ "Oracle" )
		 	selectFromTable = "USER_TAB_COLUMNS"; 
		 	
		 // ORACLE requires uppercase DB objects
		arguments.tableName = uCase(Trim(arguments.tableName));
	</cfscript>
	<cftry>
		<!--- // Check if the table exists in the Source DB --->
		<cfquery name="verifyDB" datasource="#datasourse#">
			SELECT 	TABLE_NAME 
			  FROM 	#selectFromTable#
    		 WHERE 	TABLE_NAME = <cfqueryparam value="#arguments.tableName#" cfsqltype="cf_sql_varchar">
    		 <cfif  dbType EQ "MySQL">
    		  AND   TABLE_SCHEMA = DATABASE()
    		 </cfif>
		</cfquery>
		<!--- // Check to see if we have the table --->
		<cfif verifyDB.RecordCount> 
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
		<cfcatch>
			<cfset utilsLib.logAppend(msg="#TRIM(arguments.tableName)#: #cfcatch.message#",logFile="utils-verifyTableExists.log")>
			<cfreturn false>
		</cfcatch>
	</cftry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$isNumericList
Summary:
	Checks to make sure all values is a list are numeric. 
	Returns true/false.
Returns:
	boolean
Arguments:
	String - list
	String - delimiter
History:
	2014-12-03 - GAC - Created
--->
<cffunction name="isNumericList" returntype="boolean" access="public" output="false" hint="Checks to make sure all values is a list are numeric.">
	<cfargument name="list" type="string" required="false" default="" hist="A delimited list of values.">
	<cfargument name="delimiter" type="string" required="false" default="," hint="Delimiter for the list.  Defualt is comma. (Optional)">
	
	<cfscript>
        var listItem = '';
        var i = 0;
        
        for ( i=1; i LTE ListLen(arguments.list,arguments.delimiter); i=i+1 ) 
        {
            listItem = ListGetAt(arguments.list,i,arguments.delimiter);
            if ( !isNumeric(listItem) )
                return false;
        }   
        return true;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Name:
	$tagValueCleanup
Summary:
	Removes the tag and string between <script> <object><iframe><style><meta> and <link> tags
	                         
	@author         Saman W Jayasekara (sam @ cflove . org)                   
	@version 1.1    May 22, 2010              
Returns:
	string
Arguments:
	String - str
	String - action -  cleanup or find 
History:
	2015-02-13 - GAC - Added
--->
<cffunction name="tagValueCleanup" access="public" returntype="string" hint="Removes the tag and string between <script> <object><iframe><style><meta> and <link> tags."> 
	<cfargument name="str"    type="string" required="yes" hint="String"> 
	<cfargument name="action" type="string" required="no" default="cleanup" hint="If [cleanup], this will clean up the string and output new string, if [find], this will output a value or zero"> 
	
	<cfset var retStr = "">
	 
	<cfswitch expression="#arguments.action#"> 
		<cfcase value="cleanup"> 
			<cfset retStr = ReReplaceNoCase(arguments.str,"<script.*?</*.script*.>|<applet.*?</*.applet*.>|<embed.*?</*.embed*.>|<ilayer.*?</*.ilayer*.>|<frame.*?</*.frame*.>|<object.*?</*.object*.>|<iframe.*?</*.iframe*.>|<style.*?</*.style*.>|<meta([^>]*[^/])>|<link([^>]*[^/])>|<script([^>]*[^/])>", "", "ALL")> 
			<cfset retStr = retStr.ReplaceAll("<\w+[^>]*\son\w+=.*[ /]*>|<script.*/*>|</*.script>|<[^>]*(javascript:)[^>]*>|<[^>]*(onClick:)[^>]*>|<[^>]*(onDblClick:)[^>]*>|<[^>]*(onMouseDown:)[^>]*>|<[^>]*(onMouseOut:)[^>]*>|<[^>]*(onMouseUp:)[^>]*>|<[^>]*(onMouseOver:)[^>]*>|<[^>]*(onBlur:)[^>]*>|<[^>]*(onFocus:)[^>]*>|<[^>]*(onSelect:)[^>]*>","") > 
			<cfset retStr = reReplaceNoCase(retStr, "</?(script|applet|embed|ilayer|frame|iframe|frameset|style|link)[^>]*>","","all")> 
		</cfcase> 
		<cfdefaultcase> 
			<cfset retStr = REFindNoCase("<script.*?</script*.>|<applet.*?</applet*.>|<embed.*?</embed*.>|<ilayer.*?</ilayer*.>|<frame.*?</frame*.>|<object.*?</object*.>|<iframe.*?</iframe*.>|<style.*?</style*.>|<meta([^>]*[^/])>|<link([^>]*[^/])>|<\w+[^>]*\son\w+=.*[ /]*>|<[^>]*(javascript:)[^>]*>|<[^>]*(onClick:)[^>]*>|<[^>]*(onDblClick:)[^>]*>|<[^>]*(onMouseDown:)[^>]*>|<[^>]*(onMouseOut:)[^>]*>|<[^>]*(onMouseUp:)[^>]*>|<[^>]*(onMouseOver:)[^>]*>|<[^>]*(onBlur:)[^>]*>|<[^>]*(onFocus:)[^>]*>|<[^>]*(onSelect:)[^>]*>",arguments.str)> 
		</cfdefaultcase> 
	</cfswitch> 
 	
	<cfreturn retStr> 
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$parseRequestParamsToFilteredParams
Summary:
	Converts a CommonSpot Request Params structure to a structure that only includes allowed params
	and removes any excluded params.
Returns:
	Struct
Arguments:
	Struct - paramsStruct
	String - allowedParams
	String - excludedParams
	Boolean - preventDups
Usage:
	convertRequestParamsToFilteredParams(paramsStruct,allowedParams,excludedParams,preventDups)
History:
	2015-02-24 - Created
 --->
<cffunction name="convertRequestParamsToFilteredParams" access="public" returntype="struct" hint="Converts a CommonSpot Request Params structure to a structure that only includes allowed params and removes any excluded params.">
	<cfargument name="paramsStruct" type="struct" required="false" default="#request.params#" hint="request.params data structure to parse">
	<cfargument name="allowedParamList" type="string" required="false" default="" hint="comma-delimited list of allowed query or form params">
	<cfargument name="excludedParamList" type="string" required="false" default="" hint="comma-delimited list of excluded query or form params">
	<cfargument name="preventDups" type="boolean" required="false" default="true" hint="Set to true to prevent duplicate hidden input controls.">
	
	<cfscript>
		var retData = StructNew();
	   	var paramsData = StructNew();
		var aKey = "";
		var pKey = "";
		var paramDupList = "";
		
		// Rebuild the paramData struct will only the allowed params
		// !!! if no allowed params are passed, then allow the whole request.params struct to pass through !!!
		if ( ListLen(arguments.allowedParamList) EQ 0 )
			paramsData = arguments.paramsStruct;
		else
	   	{
		   	for ( aKey IN arguments.paramsStruct )
			{
				if ( ListFindNoCase(arguments.allowedParamList,aKey,",") )	
					paramsData[aKey] = arguments.paramsStruct[aKey]; 
			}
	   	}
		
		// Loop over the paramData from request.Params to build the retData without the excluded params
		for ( pKey IN paramsData ) 
		{
			if ( ListFindNoCase(arguments.excludedParamList,pKey,",") EQ 0 
				AND ListFindNoCase(paramDupList,pKey,",") EQ 0 )
			{
				retData[pKey] = paramsData[pKey];
				
				// Build a key list so we can check for and prevent dups
				if ( arguments.preventDups )
					paramDupList = ListAppend(paramDupList,pKey,",");
			}
		}
	   	
	   	return retData;		
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$DollarFormat2
Summary:
	Works like the built-in function DollarFormat, but does no rounding so that you can
	round as you see fit.
Returns:
	Struct
Arguments:
	String - inNum
Usage:
	DollarFormat2(inNum)
History:
	2015-04-17 - SFS - Added
 --->
<cffunction name="DollarFormat2" returntype="string" access="public" output="false" hint="Works like the built-in function DollarFormat, but does no rounding so that you can round as you see fit.">
	<cfargument name="inNum" type="string" required="false" default="" hist="Dollar value to format.">

	<cfscript>
		/**
		 * Works like the built-in function DollarFormat, but does no rounding.
		 *
		 * @param inNum 	 Number to format. (Required)
		 * @param default_var 	 Value to use if number isn't a proper number. (Optional)
		 * @return Returns a string.
		 * @author Shawn Seley (shawnse@aol.com)
		 * @version 1, September 16, 2002
		 */
		var out_str             = "";
		var decimal_str         = "";

		var default_value = arguments.inNum;
		if(ArrayLen(Arguments) GTE 2) default_value = Arguments[2];

		if (not IsNumeric(arguments.inNum)) 
		{
			return (default_value);
		} 
		else 
		{
			arguments.inNum = Trim(arguments.inNum);
			if(ListLen(arguments.inNum, ".") GT 1) {
				out_str = Abs(ListFirst(arguments.inNum, "."));
				decimal_str = "." & ListLast(arguments.inNum, ".");
			} 
			else if (Find(".", arguments.inNum) EQ 1) 
			{
				decimal_str = arguments.inNum;
			} 
			else 
			{
				out_str = Abs(arguments.inNum);
			}
			if (out_str NEQ "") 
			{
				// add commas
				out_str = Reverse(out_str);
				out_str = REReplace(out_str, "([0-9][0-9][0-9])", "\1,", "ALL");
				out_str = REReplace(out_str, ",$", "");   // delete potential leading comma
				out_str = Reverse(out_str);
			}

			// add dollar sign (and parenthesis if negative)
			if(arguments.inNum LT 0) 
			{
				return ("($" & out_str & decimal_str & ")");
			} 
			else 
			{
				return ("$" & out_str & decimal_str);
			}
		}
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	Gyrus (eli.dickinson@gmail.com gyrus@norlonto.net)
Name:
	$HTMLSafeFormattedTextBox
Summary:
	Converts special characters to character entities, making a string safe for display in HTML.
	Version 2 update by Eli Dickinson (eli.dickinson@gmail.com)
 	Fixes issue of lists not being equal and adding bull
 	v3, extra semicolons
 
 	@param string 	 String to format. (Required)
	@return Returns a string.
 	@author Gyrus (eli.dickinson@gmail.com gyrus@norlonto.net)
 	@version 3, August 30, 2006
Returns:
	String
Arguments:
	String - inString
Usage:
	application.ADF.data.HTMLSafeFormattedTextBox(inString)
History:
	2015-05-21 - GAC - Moved from utils_1_0
 --->
<cffunction name="HTMLSafeFormattedTextBox" access="public" returntype="string" hint="Converts special characters to character entities, making a string safe for display in HTML.">
	<cfargument name="inString" type="string" required="true">

	<cfscript>
		var badChars = "&amp;nbsp;,&amp;amp;,&quot;,&amp;ndash;,&amp;rsquo;,&amp;ldquo;,&amp;rdquo;,#chr(12)#";
		var goodChars = "&nbsp;,&amp;,"",&ndash;,&rsquo;,&ldquo;,&rdquo;,&nbsp;";

		// Return immediately if blank string
		if (NOT Len(Trim(arguments.inString))) return arguments.inString;

		// Do replacing
		return ReplaceList(arguments.inString, badChars, goodChars);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	simonbingham
	https://gist.github.com/simonbingham/3238060
Name:
	$highlightKeywords
Summary:
	I highlight words in a string that are found in a keyword list. Useful for search result pages.
    
	@param str           String to be searched
    @param searchterm    Comma delimited list of keywords
 
Returns:
	String
Arguments:
	String - str
	String - searchterm
	String - preTermStr
	String - postTermStr
Usage:
	application.ADF.data.highlightKeywords(str,searchterm,preTermStr,postTermStr)
History:
	2015-07-08 - GAC - Added to the data_1_2 lib component
	2015-07-09 - GAC - Added additional arguments to allow custom pre and post HTML strings to be added
	2015-07-16 - GAC - Updated the var'd variable for the loop
	2015-09-09 - KE - Updated the ReReplace to escape ALL matched special regular expression characters 
--->
<cffunction name="highlightKeywords" access="public" returntype="string" hint="Converts special characters to character entities, making a string safe for display in HTML.">
	<cfargument name="str" type="string" required="true">
	<cfargument name="searchTerm" type="string" required="true">
	<cfargument name="preTermStr" type="string" required="false" default='<span style="background:yellow;">'>
	<cfargument name="postTermStr" type="string" required="false" default='</span>' >
	
	<cfscript>
	    var j = 1;
	    var i = 1;
	    var matches = "";
	    var word = "";
	    
	    // loop through keywords
	    for ( i=1; i lte ListLen( arguments.searchTerm, " " ); i=i+1 )
	    {
	      // get current keyword and escape any special regular expression characters
	      word = ReReplace( ListGetAt( arguments.searchTerm, i, " " ), "\.|\^|\$|\*|\+|\?|\(|\)|\[|\]|\{|\}|\\", "", "ALL" );
	      
	      // return matches for current keyword from string
	      matches = ReMatchNoCase( word, arguments.str );
	      
	      // remove duplicate matches (case sensitive)
	      matches = CreateObject( "java", "java.util.HashSet" ).init( matches ).toArray();
	      
	      // loop through matches
	      for( j=1; j <= ArrayLen( matches ); j=j+1 )
	      {
	        // where match exists in string highlight it
	        arguments.str = Replace( arguments.str, matches[ j ], arguments.preTermStr & matches[ j ] & arguments.postTermStr, "all" );
	      }  
	    }
	    return arguments.str;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$arrayOfArraysToQuery
Summary:
	Converts an array of structures to a CF Query Object.

	Based on the arrayOfStructuresToQuery() by David Crawford (dcrawford@acteksoft.com) and Rob Brooks-Bilson (rbils@amkor.com)
Returns:
	Query
Arguments:
	Array - theArray
	Boolean - useFirstArrayAsColNames
	Boolean - forceSimpleColNames
	Boolean - forceColsToVarchar
Usage:
	arrayOfArraysToQuery(theArray,useFirstArrayAsColNames,forceSimpleColNames,forceColsToVarchar)
History:
	2015-08-13 - GAC - Added
 --->
<cffunction name="arrayOfArraysToQuery" access="public" returntype="query">
	<cfargument name="theArray" type="array" required="true">
	<cfargument name="useFirstArrayAsColNames" type="boolean" default="false" required="false">
	<cfargument name="forceSimpleColNames" type="boolean" default="false" required="false">
	<cfargument name="forceColsToVarchar" type="boolean" default="false" required="false">
		
	<cfscript>
		var colNames = ArrayNew(1);
		var theQuery = QueryNew("tmp");
		var i = 0;
		var j = 0;
		var c = 0;
		var foo = "";
		var count = arrayLen(arguments.theArray);
		var col_num = 0;
		var item = "";
		var firstArray = ArrayNew(1);
		var columnCount = 0;
		var newColName = "";
		var newColNames = ArrayNew(1);
		
		//if there's nothing in the array, return the empty query
		if ( count eq 0 )
			return theQuery;
		
		if ( ArrayLen( arguments.theArray ) )
			firstArray = arguments.theArray[1];
		
		columnCount = ArrayLen(firstArray);
			
		//get the column names into an array =
		if ( arguments.useFirstArrayAsColNames )
		{
			colNames = firstArray;
			ArrayDeleteAt(arguments.theArray,1);
			count = ArrayLen(arguments.theArray);
			
			if ( arguments.forceSimpleColNames )
			{
				newColName = "";
				newColNames = ArrayNew(1);
				for ( c=1; c LTE columnCount; c=c+1 )
				{
					//newColName = REREPLACE(colNames[c],"[\s]","","all");
					//newColName = REREPLACE(colNames[c],"[^0-9A-Za-z ]","","all"); 
					newColName = REREPLACE(colNames[c],"[^\w]","","all"); 
					
					ArrayAppend(newColNames,newColName);	
				}
				colNames = newColNames;		
			}
		}
		else
		{
			for ( c=1; c LTE columnCount; c=c+1 )
			{
				ArrayAppend(colNames,"column" & c);	
			}
		}	
		
		//colNames = structKeyArray(arguments.theArray[1]);
		col_num = ArrayLen(colNames);
		
		//build the query based on the colNames
		if ( arguments.forceColsToVarchar )
			theQuery = queryNew(arrayToList(colNames), RepeatString("varchar,", col_num));    
		else
			theQuery = queryNew(arrayToList(colNames));
			
		//add the right number of rows to the query
		queryAddRow(theQuery, count);
		
		//for each element in the array, loop through the columns, populating the query
		for ( i=1; i LTE count; i=i+1 )
		{
			item = arguments.theArray[i];
			for( j=1; j LTE col_num; j=j+1 )
			{	
				itemColumn = colNames[j];
				itemValue = TRIM(item[j]);

				querySetCell(theQuery, itemColumn, itemValue, i);
			}
		}
		return theQuery;
	</cfscript>
</cffunction>

</cfcomponent>