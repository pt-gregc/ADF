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
--->
<cfcomponent displayname="data_1_2" extends="ADF.lib.data.data_1_1" hint="Data Utils component functions for the ADF Library">

<cfproperty name="version" value="1_2_5">
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
History:
	2012-10-19 - GAC - Created - MOVE INTO THE ADF V1.6
	2012-12-31 - Added 'objectFieldKeyList' argument for complex fields.
				 Added temp variables to copy the structure for comparison.
--->
<cffunction name="IsStructDataDifferent" access="public" returntype="boolean" hint="Compares two data structures and then returns a false if they are different">
	<cfargument name="structDataA" type="struct" required="true" hint="">
	<cfargument name="structDataB" type="struct" required="true" hint="">
	<cfargument name="excludeKeyList" type="string" required="false" default="" hint="">
	<cfargument name="objectFieldKeyList" type="any" required="false" default="" hint="">
	<cfscript>
		var isDifferent = false;
		var tempStructDataA = Duplicate(arguments.structDataA);
		var tempStructDataB = Duplicate(arguments.structDataB);
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
						AND isJSON(arguments.structDataB[currentKey]) ) {
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
	Converts HTML entities back to thier text values
Returns:
	String 
Arguments:
	String - str
History:
	2012-10-19 - GAC - Created
--->
<cffunction name="unescapeHTMLentities" access="public" returntype="string" hint="Converts HTML entities back to thier text values">
	<cfargument name="str" type="string" required="true">
	<cfscript>
		return server.commonspot.udf.html.unescape(arguments.str);
	</cfscript>
</cffunction>

<!--- /**
* Will replace chars in a string to be used to create a folder with valid equivalent replacements
*
* @param fileName      Name of file. (Required)
* @return Returns a string.
* @author Mike Gillespie (mike@striking.com)
* @version 1, May 9, 2003
* FIXED BY 2010-01-20 - GAC
*/ --->
<cffunction name="filterInternationlChars" access="public" returntype="string" output="false" hint="Will replace chars in a string to be used to create a folder with valid equivalent replacements">
	<cfargument name="fileName" type="string" required="true" hint="">
	<cfscript>
		var bad_chars="/,\,*,&,%,$,¿,Æ,Ç,Ð,Ñ,Ý,Þ,ß,æ,ç,ð,ñ,÷,ø,ý,þ,ÿ";
		var good_chars="-,-,-,-,-,-,-,AE,C,D,N,Y,I,B,ae,c,o,n,-,o,y,1,y";
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
	Sort a query based on a custom list.
	http://cookbooks.adobe.com/post_Sort_query_in_custom_order-17997.html 
Returns:
	query 
Arguments:
	query
	string
	string
	string
	string
History:
	2013-01-10 - MFC - Created
--->
<cffunction name="QuerySort" displayname="QuerySort" access="public" hint="Sort a query based on a custom list" returntype="query" output="true">
    <cfargument name="query" type="query" required="yes" hint="The query to be sorted">
    <cfargument name="columnName" type="string" required="yes" hint="The name of the column to be sorted">
    <cfargument name="columnType" type="string" required="no" default="numeric" hint="The column type. Possible values: numeric, varchar">
    <cfargument name="orderList" type="string" required="yes" hint="The lsit used to sort the query">
    <cfargument name="orderColumnName" type="string" required="no" default="orderNo" hint="The name of the column containing the order number">
    <cfset var qResult = queryNew("null")>
    
    <!--- Make the order list unique to avoid duplicating query records --->
    <!--- <cfset arguments.orderList = ListUnique(arguments.orderList)> --->
    <cftry>
		<!--- <cfdump var="#arguments#" label="QuerySort - args" expand="false"> --->
		<!--- <cfdump var="#GetMetaData(arguments.query)#" label="QuerySort - GetMetaData" expand="false"> --->
		<cfquery name="qResult" dbtype="query">
			<cfloop from="1" to="#listLen(arguments.orderList)#" index="orderItem">
				SELECT *, #orderItem# AS #arguments.orderColumnName#
				FROM arguments.query
				WHERE #arguments.columnName# = '#listGetAt(arguments.orderList, orderItem)#'
				<cfif orderItem LT listLen(arguments.orderList)>
					
					UNION
					 
				</cfif>
			</cfloop>
			<!--- 
			SELECT *, #listLen(arguments.orderList) + 1# AS #arguments.orderColumnName#
			FROM arguments.query
			WHERE #arguments.columnName# NOT IN (<cfqueryparam value="#arguments.orderList#" list="yes" cfsqltype="cf_sql_#arguments.columnType#" />)
			 --->
			ORDER BY #arguments.orderColumnName#
		</cfquery>
		<!--- <cfdump var="#qResult#" label="QuerySort - qResult" expand="false"> --->
    	<cfreturn qResult>
		<cfcatch>
			<cfdump var="#cfcatch#" label="cfcatch" expand="false">
			<cfreturn arguments.query>
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
  		
  		switch(two) {
       		case "11": 
       		case "12": 
       		case "13": { arguments.number = two; break; }
       		default: { arguments.number = Right(arguments.number,1); break; }
  		}

		// 1st, 2nd, 3rd, everything else is "th"
		switch(arguments.number) {
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
--->
<cffunction name="cardinalToOrdinal" access="public" output="false" returntype="string" hint="This function converts cardinal number strings to ordinal number strings..">
	<cfargument name="cardinalString" type="string" required="true" hint="">
	<cfscript>  
		var resultString = "";        // Generated result to return
	 	var lastCardinal = "";        // Last word in cardinal number string
	  	var TempNum = 0;              // temp integer

  		cardinalSpecialStrings = "One,one,Two,two,Three,three,Four,four,Five,five,Six,six,Eight,eight,Nine,nine,Twelve,twelve";
  		ordinalSpecialStrings = "First,first,Second,second,Third,third,Fourth,fourth,Fifth,fifth,Sixth,sixth,Eighth,eighth,Ninth,ninth,Twelfth,twelfth";
  
  		cardinalString = trim(cardinalString);
 		lastCardinal = listLast(cardinalString," ");
  		resultString = ListDeleteAt(cardinalString,ListLen(cardinalString," ")," ");
  
		// Is lastCardinal a special case?
		TempNum = listFindNoCase(cardinalSpecialStrings,lastCardinal);
		if (TempNum GT 0) {
		  	resultString = ListAppend(resultString,ListGetAt(ordinalSpecialStrings,TempNum)," ");
		} 
		else {
		    if (ListFindNoCase(Right(lastCardinal,2),"en")) {
		      // Last word ends with "en", add "th"
		      resultString = ListAppend(resultString,lastCardinal & "th"," ");
		    } 
		    if (ListFindNoCase(Right(lastCardinal,1),"d")) {
		      // Last word ends with "d", add "th"
		      resultString = ListAppend(resultString,lastCardinal & "th"," ");
		    } 
		    if (ListFindNoCase(Right(lastCardinal,1),"y")) {
		      // Last word ends with "y", delete "y", add "ieth"
		      resultString = ListAppend(resultString, Left(lastCardinal,Len(lastCardinal) - 1) & "ieth"," ");
		    } 
		    if (ListFindNoCase(Right(lastCardinal,3),"ion")) {
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
	Compares two lists and then returns a true if they are different or not
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

</cfcomponent>