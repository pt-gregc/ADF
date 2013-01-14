<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2012.
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
	data_1_0.cfc
Summary:
	Data Utils component functions for the ADF Library
Version:
	1.0
History:
	2009-06-22 - PaperThin, Inc. - Created
--->
<cfcomponent displayname="data_1_0" extends="ADF.core.Base" hint="Data Utils component functions for the ADF Library">

<cfproperty name="version" value="1_0_3">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Data_1_0">

<!--- * Remove elements from one array which exist in another array.
*
* @param baseArray      Main array of values. (Required)
* @param deleteArray      Array of values to delete. (Required)
* @return Returns an array.
* @author Jason Rushton (jason@iworks.com)
* @version 1, April 11, 2008
 --->
<cffunction name="arraydeletearray" access="public" returntype="array">
	<cfargument name="baseArray" type="array" required="yes">
	<cfargument name="deleteArray" type="array" required="yes">
	<cfset arguments.baseArray.removeAll(arguments.deleteArray)>
	
	<cfreturn arguments.baseArray>
</cffunction>

<!---
/**
* Sorts an array of structures based on a key in the structures.
*
* @param aofS      Array of structures.
* @param key      Key to sort by.
* @param sortOrder      Order to sort by, asc or desc.
* @param sortType      Text, textnocase, or numeric.
* @param delim      Delimiter used for temporary data storage. Must not exist in data. Defaults to a period.
* @return Returns a sorted array.
* @author Nathan Dintenfass (nathan@changemedia.com)
* @version 1, December 10, 2001
*/
--->
<cffunction name="arrayOfStructsSort" access="public" returntype="array">
	<cfargument name="aOfS" type="array" required="true">
	<cfargument name="key" type="string" required="true">
	<cfargument name="sortOrder" type="string" required="false" default="asc">
	<cfargument name="sortType" type="string" required="false" default="textnocase">
	<cfargument name="delim" type="string" required="false">

	<cfscript>
		//by default we'll use an ascending sort
        var sortOrder2 = "asc";
        //by default, we'll use a textnocase sort
        var sortType2 = "textnocase";
        //by default, use ascii character 30 as the delim
        var delim2 = ".";
        //make an array to hold the sort stuff
        var sortArray = arraynew(1);
        //make an array to return
        var returnArray = arraynew(1);
        //grab the number of elements in the array (used in the loops)
        var count = arrayLen(arguments.aOfS);
        //make a variable to use in the loop
        var ii = 1;
        //if there is a 3rd argument, set the sortOrder
        if(structKeyExists(arguments, 'sortOrder'))
            sortOrder2 = arguments.sortOrder;
        //if there is a 4th argument, set the sortType
        if(structKeyExists(arguments, 'sortType'))
            sortType2 = arguments.sortType;
        //if there is a 5th argument, set the delim
        if(structKeyExists(arguments, 'delim'))
            delim2 = arguments.delim;
        //loop over the array of structs, building the sortArray
        for(ii = 1; ii lte count; ii = ii + 1)
            sortArray[ii] = arguments.aOfS[ii][arguments.key] & delim2 & ii;
        //now sort the array
        arraySort(sortArray,sortType2,sortOrder2);
        //now build the return array
        for(ii = 1; ii lte count; ii = ii + 1)
            returnArray[ii] = arguments.aOfS[listLast(sortArray[ii],delim2)];
        //return the array
        return returnArray;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$arrayOfStructuresToQuery
Summary:
	Returns Query from Array of Structures
Returns:
	Query
Arguments:
	Array
	Boolean - forceColsToVarchar
History:
	2009-01-20 - MFC - Created
	2011-09-01 - GAC - Modified - Added a flag to force all query columns to be varchar datatype
	2012-09-21 - AW  - Updated - Updates to support Railo
--->
<cffunction name="arrayOfStructuresToQuery" access="public" returntype="query">
	<cfargument name="theArray" type="array" required="true">
	<cfargument name="forceColsToVarchar" type="boolean" default="false" required="false">	
	<cfscript>
		/**
		* Converts an array of structures to a CF Query Object.
		* 6-19-02: Minor revision by Rob Brooks-Bilson (rbils@amkor.com)
		*
		* Update to handle empty array passed in. Mod by Nathan Dintenfass. Also no longer using list func.
		*
		* @param Array      The array of structures to be converted to a query object. Assumes each array element contains structure with same (Required)
		* @return Returns a query object.
		* @author David Crawford (rbils@amkor.comdcrawford@acteksoft.com)
		* @version 2, March 19, 2003
		*/
		var colNames = "";
		var theQuery = QueryNew("tmp");
		var i = 0;
		var j = 0;
		var c = 0;
		var foo = "";
		var count = arrayLen(arguments.theArray);
		var col_num = 0;
		var item = "";

		//if there's nothing in the array, return the empty query
		if (count eq 0)
			return theQuery;
		//get the column names into an array =
		colNames = structKeyArray(arguments.theArray[1]);
		col_num = ArrayLen(colNames);
		//build the query based on the colNames
		if (arguments.forceColsToVarchar)
			theQuery = queryNew(arrayToList(colNames), RepeatString("varchar,", col_num));    
		else
			theQuery = queryNew(arrayToList(colNames));
		//add the right number of rows to the query
		queryAddRow(theQuery, count);
		//for each element in the array, loop through the columns, populating the query
		for(i=1; i LTE count; i=i+1)
		{
			item = arguments.theArray[i];
			for(j=1; j LTE col_num; j=j+1)
			{
				foo = '';
				if (StructKeyExists(item, colNames[j]))
					foo = item[colNames[j]];

				if (NOT IsSimpleValue(foo))
					foo = '';

				querySetCell(theQuery, colNames[j], foo, i);
			}
		}
		return theQuery;
	</cfscript>

</cffunction>

<!--- ///**
	* Sorts a two dimensional array by the specified column in the second dimension.
	*
	* @param arrayToSort	A two-dimensional array to sort.
	* @param sortColumn		Which index of the array is to be used to do the sorting, a number (1-n)
	* @param type			What kind of sort to do, (numeric, text, textnocase)
	* @param delim      Delimiter used for temporary data storage. Must not exist in data. Defaults to a period.
	* @return Returns an array.
	* @author Robert West (robert.west@digiphilic.com)
	* @version 1, October 8, 2002
	* @history Updated list conversion code so that if the data contained commas the function would still work. Now uses a period as the delimiter.
	*/
--->
<cffunction name="ArraySort2D" access="public" returntype="array">
	<cfargument name="arrayToSort" type="array" required="yes">
	<cfargument name="sortColumn" type="numeric" required="yes">
	<cfargument name="type" type="string">
	<cfargument name="delim" type="string" required="false" default="|">
	<cfargument name="sortOrder" type="string" required="false" default="asc">
	
	<cfscript>
		var order = "asc";
		var i = 1;
		var j = 1;
		var thePosition = "";
		var theList = "";
		//by default, use ascii character 30 as the delim
        var delim2 = "|";
		var sortOrder2 = "asc";
		var arrayToReturn = ArrayNew(2);
		var sortArray = ArrayNew(1);
		var counter = 1;
        if(structKeyExists(arguments, 'sortOrder'))
            sortOrder2 = arguments.sortOrder;
        if(structKeyExists(arguments, 'delim'))
            delim2 = arguments.delim;
		for (i=1; i LTE ArrayLen(arguments.arrayToSort); i=i+1) {
			ArrayAppend(sortArray, arguments.arrayToSort[i][arguments.sortColumn]);
		}
		theList = ArrayToList(sortArray,delim2);
		ArraySort(sortArray, arguments.type, sortOrder2);
		for (i=1; i LTE ArrayLen(sortArray); i=i+1) {
			thePosition = ListFind(theList, sortArray[i],delim2);
			theList = ListDeleteAt(theList, thePosition,delim2);
			for (j=1; j LTE ArrayLen(arguments.arrayToSort[thePosition]); j=j+1) {
				arrayToReturn[counter][j] = arguments.arrayToSort[thePosition][j];
			}
			ArrayDeleteAt(arguments.arrayToSort, thePosition);
			counter = counter + 1;
		}
		return arrayToReturn;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	M. Carroll
Name:
	$CSVToArray
Summary:
	CSV format to Array
	http://www.bennadel.com/blog/991-CSVToArray-ColdFusion-UDF-For-Parsing-CSV-Data-Files.htm
Returns:
	Array
Arguments:
	String - File
	String - CSV
	String - Delimiter
	Boolean - Trim
History:
	2008-10-30 - MFC - Created
	2011-02-09 - MFC - Renamed the "LOCAL" variable name.
						Updated the comment header for the credits.
--->
<cffunction name="CSVToArray" access="public" returntype="array" output="false" hint="Takes a CSV file or CSV data value and converts it to an array of arrays based on the given field delimiter. Line delimiter is assumed to be new line / carriage return related.">
	<!--- Define arguments. --->
	<cfargument name="File" type="string" required="false" default="" hint="The optional file containing the CSV data."/>
	<cfargument name="CSV" type="string" required="false" default="" hint="The CSV text data (if the file was not used)." />
	<cfargument name="Delimiter" type="string" required="false" default="," hint="The data field delimiter."/>
	<cfargument name="Trim" type="boolean" required="false" default="true" hint="Flags whether or not to trim the END of the file for line breaks and carriage returns."/>

	<!--- Define the local scope. --->
	<cfset var _LOCAL = StructNew() />

	<!---
	Check to see if we are using a CSV File. If so,
	then all we want to do is move the file data into
	the CSV variable. That way, the rest of the algorithm
	can be uniform.
	--->
	<cfif Len( ARGUMENTS.File )>
		<!--- Read the file into Data. --->
		<cffile action="read" file="#ARGUMENTS.File#" variable="ARGUMENTS.CSV"/>
	</cfif>

	<!---
	ASSERT: At this point, no matter how the data was
	passed in, we now have it in the CSV variable.
	--->

	<!---
	Check to see if we need to trim the data. Be default,
	we are going to pull off any new line and carriage
	returns that are at the end of the file (we do NOT want
	to strip spaces or tabs).
	--->
	<cfif ARGUMENTS.Trim>
		<!--- Remove trailing returns. --->
		<cfset ARGUMENTS.CSV = REReplace(ARGUMENTS.CSV,"[\r\n]+$","","ALL")/>
	</cfif>

	<!--- Make sure the delimiter is just one character. --->
	<cfif (Len( ARGUMENTS.Delimiter ) NEQ 1)>
		<!--- Set the default delimiter value. --->
		<cfset ARGUMENTS.Delimiter = "," />
	</cfif>

	<!---
	Create a compiled Java regular expression pattern object
	for the expression that will be needed to parse the
	CSV tokens including the field values as well as any
	delimiters along the way.
	--->
	<cfset _LOCAL.Pattern = CreateObject(
	"java",
	"java.util.regex.Pattern"
	).Compile(
	JavaCast(
	"string",

	<!--- Delimiter. --->
	"\G(\#ARGUMENTS.Delimiter#|\r?\n|\r|^)" &

	<!--- Quoted field value. --->
	"(?:""([^""]*+(?>""""[^""]*+)*)""|" &

	<!--- Standard field value --->
	"([^""\#ARGUMENTS.Delimiter#\r\n]*+))"
	)
	)
	/>

	<!---
	Get the pattern matcher for our target text (the
	CSV data). This will allows us to iterate over all the
	tokens in the CSV data for individual evaluation.
	--->
	<cfset _LOCAL.Matcher = _LOCAL.Pattern.Matcher( JavaCast( "string", ARGUMENTS.CSV ) ) />

	<!---
	Create an array to hold the CSV data. We are going
	to create an array of arrays in which each nested
	array represents a row in the CSV data file.
	--->
	<cfset _LOCAL.Data = ArrayNew( 1 ) />

	<!--- Start off with a new array for the new data. --->
	<cfset ArrayAppend( _LOCAL.Data, ArrayNew( 1 ) ) />


	<!---
	Here's where the magic is taking place; we are going
	to use the Java pattern matcher to iterate over each
	of the CSV data fields using the regular expression
	we defined above.

	Each match will have at least the field value and
	possibly an optional trailing delimiter.
	--->
	<cfloop condition="_LOCAL.Matcher.Find()">
		<!---
		Get the delimiter. We know that the delimiter will
		always be matched, but in the case that it matched
		the START expression, it will not have a length.
		--->
		<cfset _LOCAL.Delimiter = _LOCAL.Matcher.Group(	JavaCast( "int", 1 ) ) />

		<!---
		Check for delimiter length and is not the field
		delimiter. This is the only time we ever need to
		perform an action (adding a new line array). We
		need to check the length because it might be the
		START STRING match which is empty.
		--->
		<cfif (	Len( _LOCAL.Delimiter ) AND (_LOCAL.Delimiter NEQ ARGUMENTS.Delimiter) )>
			<!--- Start new row data array. --->
			<cfset ArrayAppend(	_LOCAL.Data,	ArrayNew( 1 )	) />
		</cfif>

		<!---
		Get the field token value in group 2 (which may
		not exist if the field value was not qualified.
		--->
		<cfset _LOCAL.Value = _LOCAL.Matcher.Group( JavaCast( "int", 2 ) ) />

		<!---
		Check to see if the value exists. If it doesn't
		exist, then we want the non-qualified field. If
		it does exist, then we want to replace any escaped
		embedded quotes.
		--->
		<cfif StructKeyExists( _LOCAL, "Value" )>
		<!---
		Replace escpaed quotes with an unescaped double
		quote. No need to perform regex for this.
		--->
			<cfset _LOCAL.Value = Replace(	_LOCAL.Value,"""""","""","all"	) />
		<cfelse>

		<!---
		No qualified field value was found, so use group
		3 - the non-qualified alternative.
		--->
			<cfset _LOCAL.Value = _LOCAL.Matcher.Group(	JavaCast( "int", 3 ) ) />
		</cfif>

		<!--- Add the field value to the row array. --->
		<cfset ArrayAppend(	_LOCAL.Data[ ArrayLen( _LOCAL.Data ) ],	_LOCAL.Value	) />
	</cfloop>

	<!---
	At this point, our array should contain the parsed
	contents of the CSV value. Return the array.
	--->
	<cfreturn _LOCAL.Data />
</cffunction>

<!---
/**
* Returns TRUE if the string is a valid CF UUID.
*
* @param str     String to be checked. (Required)
* @return Returns a boolean.
* @author Jason Ellison (jgedev@hotmail.com)
* @version 1, November 24, 2003
*/
--->
<cffunction name="isCFUUID" access="public" returntype="boolean">
	<cfargument name="inStr" type="string" required="true">

	<cfscript>
		return REFindNoCase("^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$", arguments.inStr);
	</cfscript>
</cffunction>

<!---
/**
 * From CFLib on 12/08/2008
 *
 * Returns elements in list1 that are found in list2.
 * Based on ListCompare by Rob Brooks-Bilson (rbils@amkor.com)
 *
 * @param List1 	 Full list of delimited values.
 * @param List2 	 Delimited list of values you want to compare to List1.
 * @param Delim1 	 Delimiter used for List1.  Default is the comma.
 * @param Delim2 	 Delimiter used for List2.  Default is the comma.
 * @param Delim3 	 Delimiter to use for the list returned by the function.  Default is the comma.
 * @return Returns a delimited list of values.
 * @author Michael Slatoff (michael@slatoff.com)
 * @version 1, August 20, 2001
 */
 --->
<cffunction name="ListInCommon" access="public" returntype="String">
	<cfargument name="list1" type="String" required="true">
	<cfargument name="list2" type="String" required="true">

	<cfscript>
		var TempList = "";
		var i = 0;

		/* Loop through the second list, checking for the values from the first list.
		 * Add any elements from the second list that are found in the first list to the
		 * temporary list
	     */
		for (i=1; i LTE ListLen(arguments.list2); i=i+1) {
			if (ListFindNoCase(arguments.list1, ListGetAt(arguments.list2, i))){
				TempList = ListAppend(TempList, ListGetAt(arguments.list2, i));
			}
		}
		Return TempList;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$QueryToXML
Summary:
	Returns XML for a Query
Returns:
	Array
Arguments:
	String Items list of uuid's
History:
	2009-01-20 - MFC - Created
--->
<cffunction name="QueryToXML" access="public" returntype="xml">
	<cfargument name="query" type="query" required="true">
	<cfargument name="rootElementName" type="string" required="false" default="query">
	<cfargument name="rowName" type="string" required="false" default="row">

	<cfscript>
		/**
		* Generates an XMLDoc object from a basic CF Query.
		*
		* @param query      The query to transform. (Required)
		* @param rootElement      Name of the root node. (Default is "query.") (Optional)
		* @param row      Name of each row. Default is "row." (Optional)
		* @param nodeMode      Defines the structure of the resulting XML. Options are 1) "values" (default), which makes each value of each column mlText of individual nodes; 2) "columns", which makes each value of each column an attribute of a node for that column; 3) "rows", which makes each row a node, with the column names as attributes. (Optional)
		* @return Returns a string.
		* @author Nathan Dintenfass (nathan@changemedia.com)
		* @version 2, November 15, 2002
		*/

	    //the default name of the root element
	    var root = "query";
	    //the default name of each row
	    var row = "row";
	    //make an array of the columns for looping
	    var cols = listToArray(arguments.query.columnList);
	    //which mode will we use?
	    var nodeMode = "values";
	    //vars for iterating
	    var ii = 1;
	    var rr = 1;
	    //vars for holding the values of the current column and value
	    var thisColumn = "";
	    var thisValue = "";
	    //a new xmlDoc
	    var xml = xmlNew();
	    //if there are 2 arguments, the second one is name of the root element
	    if(structCount(arguments) GTE 2)
	        root = arguments[2];
	    //if there are 3 arguments, the third one is the name each element
	    if(structCount(arguments) GTE 3)
	        row = arguments[3];
	    //if there is a 4th argument, it's the nodeMode
	    if(structCount(arguments) GTE 4)
	        nodeMode = arguments[4];
	    //create the root node
	    xml.xmlRoot = xmlElemNew(xml,root);
	    //capture basic info in attributes of the root node
	    xml[root].xmlAttributes["columns"] = arrayLen(cols);
	    xml[root].xmlAttributes["rows"] = arguments.query.recordCount;
	    //loop over the recordcount of the query and add a row for each one
	    for(rr = 1; rr LTE arguments.query.recordCount; rr = rr + 1){
	        arrayAppend(xml[root].xmlChildren,xmlElemNew(xml,row));
	        //loop over the columns, populating the values of this row
	        for(ii = 1; ii LTE arrayLen(cols); ii = ii + 1){
	            thisColumn = lcase(cols[ii]);
	            thisValue = query[cols[ii]][rr];
	            switch(nodeMode){
	                case "rows":
	                    xml[root][row][rr].xmlAttributes[thisColumn] = thisValue;
	                    break;
	                case "columns":
	                    arrayAppend(xml[root][row][rr].xmlChildren,xmlElemNew(xml,thisColumn));
	                    xml[root][row][rr][thisColumn].xmlAttributes["value"] = thisValue;
	                    break;
	                default:
	                    arrayAppend(xml[root][row][rr].xmlChildren,xmlElemNew(xml,thisColumn));
	                    xml[root][row][rr][thisColumn].xmlText = thisValue;
	            }
			}
	    }
	    //return the xmlDoc
	    return xml;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$sortArrayByIDList
Summary:
	Returns a sorted Array of Structures by the field and id list arguments
Returns:
	Array
Arguments:
	Array - Array of Structs
	String - Element Field Name
	String - List of Field Values
History:
	2009-06-17 - MFC - Created
--->
<cffunction name="sortArrayByIDList" access="public" returntype="array">
	<cfargument name="arrayOfStructs" type="array" required="true">
	<cfargument name="idFieldName" type="string" required="true">
	<cfargument name="idList" type="string" required="true">

	<cfscript>
		var retArray = ArrayNew(1);
		var i = 1;
		var j = 1;
		var arrayCount = 1;
		var fldVal = "";
		
		// loop over the idList
		for (i = 1; i lte #ListLen(arguments.idList)#; i = i + 1)
		{
			// loop over the arrayOfStructs to find the matching item with the ID
			for (j = 1; j lte #ArrayLen(arguments.arrayOfStructs)#; j=j+1)
			{
				// [MFC 2/20/09] Check if the values struct exists.  Set fldVal variable.
				if ( structKeyExists(arguments.arrayOfStructs[j], "values") )
					fldVal = arguments.arrayOfStructs[j].Values["#arguments.idFieldName#"];
				else
					fldVal = arguments.arrayOfStructs[j][arguments.idFieldName];

				if ( ListGetAt(arguments.idList,i) eq fldVal )
				{
					retArray[arrayCount] = arguments.arrayOfStructs[j];
					arrayCount = arrayCount + 1;
				}
			}
		}
		return retArray;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Sam Smith
Name:
	$trimStringByWordCount
Summary:
	Shortens a string without cutting words in half.
Returns:
	String
Arguments:
	String - The string to modify
	Words - The number of words to display
	useEllipsis - boolean - Option to turn off the Ellipsis [...] at the end of the trimed string
History:
	2009-05-31 - SFS - Copied from CFlib.org.
	Originally written by David Grant (david@insite.net)
	Modified by Ray Camden on July 30, 2001
	2010-01-17 - GAC - Modified - Added Ellipsis option
--->
<cffunction name="trimStringByWordCount" access="public" returntype="String" hint="Shortens a string without cutting words in half and appends '...' to the end.">
	<cfargument name="str" required="yes" type="string" hint="The string to modify">
	<cfargument name="words" required="yes" type="numeric" hint="The number of words to display">
	<cfargument name="useEllipsis" default="true" required="false" type="boolean" hint="Option to turn off the Ellipsis [...] at the end of the trimed string">

	<cfscript>
		var numWords = 0;
		var oldPos = 1;
		var i = 1;
		var strPos = 0;
	
		str = trim(str);
		str = REReplace(str,"[[:space:]]{2,}"," ","ALL");
		numWords = listLen(str," ");
		if (words gte numWords) return str;
		for (i = 1; i lte words; i=i+1) {
			strPos = find(" ",str,oldPos);
			oldPos = strPos + 1;
		}
		if ( (len(str) lte strPos) OR (useEllipsis IS false) ) {
			return left(str,strPos-1);
		} else { 
			return left(str,strPos-1) & "...";
		}
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$getBinaryDocFile
Summary:
	Given a path and file name return the binary data for the document
	NOTE: already convereted to base64 for submission to content creation API
Returns:
	String filePath
Arguments:
	Binary document
History:
	2008-06-22 - RLW - Created
--->
<cffunction name="getBinaryDocFile" access="public" returntype="void">
	<cfargument name="filePath" type="string" required="true">
	<cfscript>
		// reset the binary doc value to null to start over
		request.binaryDoc = "";
	</cfscript>
	<!--- // make sure the file exists --->
	<cfif fileExists(arguments.filePath)>
		<cffile action="readbinary" file="#arguments.filePath#" variable="binaryDoc">
		<cfset request.binaryDoc = binaryDoc>
	</cfif>
</cffunction>
<!---
	/* ***************************************************************
	/*
	Author: 	Ron West
	Name:
		$queryToArrayOfStructures
	Summary:	
		Converts a query to an array of structures
	Returns:
		Array rtnArray
	Arguments:
		Query queryData
	History:
		2009-07-05 - RLW - Created
		2011-02-07 - GAC - Added parameter to force all StructKeys to lowercase 
	--->
<cffunction name="queryToArrayOfStructures" access="public" returntype="Array" hint="Converts a query to an array of structures">
	<cfargument name="queryData" type="query" required="true" hint="The query that will be converted into an array of structures">
	<cfargument name="keysToLowercase" type="boolean" required="false" default="false" hint="Use to convert struct key to lowercase">
	<!---
	This library is part of the Common Function Library Project. An open source
		collection of UDF libraries designed for ColdFusion 5.0 and higher. For more information,
		please see the web site at:
			
			http://www.cflib.org
			
		Warning:
		You may not need all the functions in this library. If speed
		is _extremely_ important, you may want to consider deleting
		functions you do not plan on using. Normally you should not
		have to worry about the size of the library.
			
		License:
		This code may be used freely. 
		You may modify this code as you see fit, however, this header, and the header
		for the functions must remain intact.
		
		This code is provided as is.  We make no warranty or guarantee.  Use of this code is at your own risk.
	--->		
	<cfscript>
		/**
		 * Converts a query object into an array of structures.
		 * 
		 * @param query 	 The query to be transformed 
		 * @return This function returns a structure. 
		 * @author Nathan Dintenfass (nathan@changemedia.com) 
		 * @version 1, September 27, 2001 
		 */
		var theArray = arraynew(1);
		var cols = ListtoArray(arguments.queryData.columnlist);
		var row = 1;
		var thisRow = "";
		var col = 1;
		for(row = 1; row LTE arguments.queryData.recordcount; row = row + 1){
			thisRow = structnew();
			for(col = 1; col LTE arraylen(cols); col = col + 1){
				if ( arguments.keysToLowercase ) 
					thisRow[lcase(cols[col])] = arguments.queryData[cols[col]][row];
				else
					thisRow[cols[col]] = arguments.queryData[cols[col]][row];	
			}
			arrayAppend(theArray,duplicate(thisRow));
		}
	</cfscript>
	<cfreturn theArray>
</cffunction>
<!---
/**
 * From CFLib on 07/02/2009
 *
 * Converts a URL query string to a structure.
 *
 * @param qs      Query string to parse. Defaults to cgi.query_string. (Optional)
 * @return Returns a struct.
 * @author Malessa Brisbane (cflib@brisnicki.com)
 * @version 1, April 11, 2006
 */
 --->
<cffunction name="queryStringToStruct" access="public" returntype="struct">
	<cfargument name="inString" type="String" required="true">
	
	<cfscript>
		/**
		* Converts a URL query string to a structure.
		*
		* @param qs      Query string to parse. Defaults to cgi.query_string. (Optional)
		* @return Returns a struct.
		* @author Malessa Brisbane (cflib@brisnicki.com)
		* @version 1, April 11, 2006
		*/
		 //var to hold the final structure
	    var struct = StructNew();
	    //vars for use in the loop, so we don't have to evaluate lists and arrays more than once
	    var i = 1;
	    var pairi = "";
	    var keyi = "";
	    var valuei = "";
	    var qsarray = "";
	    var qs = arguments.inString; // default querystring value
	    
	    //if there is a second argument, use that as the query string
	    if (arrayLen(arguments) GT 0) qs = arguments[1];
	
	    //put the query string into an array for easier looping
	    qsarray = listToArray(qs, "&");
	    //now, loop over the array and build the struct
	    for (i = 1; i lte arrayLen(qsarray); i = i + 1){
	        pairi = qsarray[i]; // current pair
	        keyi = listFirst(pairi,"="); // current key
	        valuei = urlDecode(listLast(pairi,"="));// current value
	        // check if key already added to struct
	        if (structKeyExists(struct,keyi)) struct[keyi] = listAppend(struct[keyi],valuei); // add value to list
	        else structInsert(struct,keyi,valuei); // add new key/value pair
	    }
	    // return the struct
	    return struct;
	</cfscript>
</cffunction>
<!---

From cflib.org

/**
* Makes a struct for all values in a given column(s) of a query.
*
* @param query      The query to operate on (Required)
* @param keyColumn      The name of the column to use for the key in the struct (Required)
* @param valueColumn      The name of the column in the query to use for the values in the struct (defaults to whatever the keyColumn is) (Optional)
* @param reverse      Boolean value for whether to go through the query in reverse (default is false) (Optional)
* @return struct
* @author Nathan Dintenfass (nathan@changemedia.com)
* @version 1, July 9, 2003
*/

History:
	2009-07-30 - RLW - Created

--->
<cffunction name="queryColumnsToStruct" access="public" returntype="Struct" hint="">
	<cfargument name="query" type="query" required="true" hint="The query to convert">
	<cfargument name="keyColumn" type="string" required="true" hint="The name of the column in the query to use as the key for the structure">
	<cfargument name="valueColumn" type="string" required="false" default="#arguments.keyValue#" hint="The name of the column in the query to use as the value for the structure"> 
	<cfargument name="reverse" type="boolean" required="false" default="false" hint="Load the structure by reversing through the query">
	<cfscript>
	    var struct = structNew();
	    var increment = 1;
	    var ii = 1;
	    var rowsGotten = 0;
	    //if reversing, we go backwards through the query
	    if(arguments.reverse){
	        ii = arguments.query.recordCount;
	        increment = -1;
	    }    
	    //loop through the query, populating the struct
	    //we do the while loop rather than a for loop because we don't know what direction we're going in
	    while(rowsGotten LT arguments.query.recordCount){
	        struct[arguments.query[arguments.keyColumn][ii]] = arguments.query[arguments.valueColumn][ii];
	        ii = ii + increment;
	        rowsGotten = rowsGotten + 1;        
	    }
	</cfscript>
	<cfreturn struct>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$structFindRecurse
Summary:
	Returns the struct key value for the struct key that matches the keylist param.
	Recurses through the struct to find the exact path in the keylist.  
Returns:
	String - The value for the matching keyList path.   
Arguments:
	Struct - dataStruct - Struct to recurse
	String - keyList - Structure key list to recurse
History:
	2009-08-12 - MFC - Created
--->
<cffunction name="structFindRecurse" access="public" returntype="string" hint="Returns the struct key value for the struct key that matches the keylist param.">
	<cfargument name="dataStruct" type="struct" required="true" hint="Struct to recurse">
	<cfargument name="keyList" type="string" required="true" hint="Structure key list to recurse">
	
	<cfscript>
		var currKey = ListFirst(arguments.keyList);  // Current Key Variable

		// Check if current key exists in the struct
		if ( StructKeyExists(arguments.dataStruct, currKey) ){
			// Check if we still have a sub struct
			if ( isStruct(arguments.dataStruct[currKey]) ) {
				// Recurse the remaining struct
				return structFindRecurse(arguments.dataStruct[currKey], ListDeleteAt(arguments.keyList,1));				
			} else {
				// Found what we needed, so return the struct key value
				return arguments.dataStruct[currKey];
			}
		} else {
			// No match found, return empty string
			return "";
		}
	</cfscript>
</cffunction>
<!---
	/* ***************************************************************
	/*
	Author: 	Ron West
	Name:
		$csvToQuery
	Summary:	
		Converts a CSV file into a Query
	Returns:
		Query csvQuery
	Arguments:
		String csvString
		String rowDelim
		String colDelim
	History:
		2009-08-25 - RLW - Created
	--->
<cffunction name="csvToQuery" access="public" returntype="query" hint="Converts a CSV file into a Query">
	<cfargument name="csvString" type="string" required="true" hint="The actual CSV content">
	<cfargument name="rowDelim" type="string" required="false" default="#chr(10)#" hint="The delimiter between each row. Defaults to carriage return">
	<cfargument name="colDelim" type="string" required="false" default="," hint="The delimeter between each column. Defaults to comma">
	<!---
	This library is part of the Common Function Library Project. An open source
		collection of UDF libraries designed for ColdFusion 5.0 and higher. For more information,
		please see the web site at:
			
			http://www.cflib.org
			
		Warning:
		You may not need all the functions in this library. If speed
		is _extremely_ important, you may want to consider deleting
		functions you do not plan on using. Normally you should not
		have to worry about the size of the library.
			
		License:
		This code may be used freely. 
		You may modify this code as you see fit, however, this header, and the header
		for the functions must remain intact.
		
		This code is provided as is.  We make no warranty or guarantee.  Use of this code is at your own risk.
	--->
	<cfscript>
	/**
	 * Transform a CSV formatted string with header column into a query object.
	 * 
	 * @param cvsString 	 CVS Data. (Required)
	 * @param rowDelim 	 Row delimiter. Defaults to CHR(10). (Optional)
	 * @param colDelim 	 Column delimiter. Defaults to a comma. (Optional)
	 * @return Returns a query. 
	 * @author Tony Brandner (tony@brandners.com) 
	 * @version 1, September 30, 2005 
	 */
	//function csvToQuery(csvString){
		//var rowDelim = chr(10);
		//var colDelim = ",";
		//var numCols = 1;
		var newQuery = QueryNew("");
		var arrayCol = ArrayNew(1);
		var i = 1;
		var j = 1;
		
		arguments.csvString = trim(arguments.csvString);
		
		//if(arrayLen(arguments) GE 2) arguments.rowDelim = arguments[2];
		//if(arrayLen(arguments) GE 3) arguments.colDelim = arguments[3];
	
		arrayCol = listToArray(listFirst(arguments.csvString,arguments.rowDelim),arguments.colDelim);
		
		for(i=1; i le arrayLen(arrayCol); i=i+1) queryAddColumn(newQuery, arrayCol[i], ArrayNew(1));
		
		for(i=2; i le listLen(arguments.csvString,arguments.rowDelim); i=i+1) {
			queryAddRow(newQuery);
			for(j=1; j le arrayLen(arrayCol); j=j+1) {
				if(listLen(listGetAt(arguments.csvString,i,arguments.rowDelim),arguments.colDelim) ge j) {
					querySetCell(newQuery, arrayCol[j],listGetAt(listGetAt(arguments.csvString,i,arguments.rowDelim),j,arguments.colDelim), i-1);
				}
			}
		}
		
	//}
	</cfscript>
	<cfreturn newQuery>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$structMerge
Summary:
	Merge two simple or complex structures in one.
	
	Struct2 will taks precendence if any conflicts.
	
	Only the greatest function in the world...
	
	Note: When developing a recursive function, follow the DFTVYVS programming standard. 
			(DFTVYVS = Don't Forget To VAR Your Variables Stupid)
Returns:
	Structure
Arguments:
	Structure struct1      The first struct.
	Structure struct2      The second struct.
History:
	2009-08-26 - MFC - Created
	2011-02-02 - RAK - Added the ability to merge lists together
--->
<cffunction name="structMerge" returntype="struct" access="public" hint="Merge two simple or complex structures in one.">
    <cfargument name="struct1" type="struct" required="true">
    <cfargument name="struct2" type="struct" required="true">
    <cfargument name="mergeValues" type="boolean" required="false" default="false" hint="Merges values if they can be merged">
   
	<cfscript>
		var retStruct = Duplicate(arguments.struct1);  // Set struct1 as the base structure
		var retStructKeyList = structKeyList(retStruct);
		var struct2KeyList = structKeyList(arguments.struct2);
		var currKey = "";
		var i = 1;
		//DFTVYVS = Don't Forget To VAR Your Variables...Stupid	

		// loop over the struct 2 key list
		for ( i = 1; i LTE ListLen(struct2KeyList); i = i + 1)
		{
			// current key
			currKey = ListGetAt(struct2KeyList, i);
			// reset the structKeyList
			retStructKeyList = structKeyList(retStruct);
			
			// Check if the current key is in the struct1 key list
			if ( ListFindNoCase(retStructKeyList, currKey) )
			{
				// Check if have a sub-structure remaining
				if ( isStruct(retStruct[currKey]) AND isStruct(arguments.struct2[currKey]) )
					StructInsert(retStruct, currKey, structMerge(retStruct[currKey], arguments.struct2[currKey]), true);
				else if ( isStruct(arguments.struct2[currKey]) ){
					// Check if we still have a struct in arguments.struct2[currKey]
					StructInsert(retStruct, currKey, arguments.struct2[currKey], true);
				}else if(arguments.mergeValues and isSimpleValue(retStruct[currKey]) and isSimpleValue(struct2[currKey])){
					//Check to see if we have simple values that can have a list merge
					StructInsert(retStruct, currKey, listAppend(retStruct[currKey],struct2[currKey]), true);
				}
			}
			else
			{
				StructInsert(retStruct, currKey, arguments.struct2[currKey], true);
			}
		}
		return retStruct;
	</cfscript>
</cffunction>
<!---
	/* ***************************************************************
	/*
	Author: 	Ron West
	Name:
		$queryToCSV
	Summary:	
		Converts a CF Query into a CSV string
	Returns:
		String csv
	Arguments:
		Query data
		String headers
		String cols
	History:
		2009-08-27 - RLW - Created
	--->
<cffunction name="queryToCSV" access="public" returntype="string" hint="Converts a CF Query into a CSV string">

	<cfargument name="data" type="query" required="true" hint="The Query to be converted">
	<cfargument name="headers" type="string" required="false" default="" hint="A comma separated list of strings to be used as column headers">
	<cfargument name="cols" type="string" required="false" default="" hint="A comma separated list of column names from query to be converted">
	<cfscript>
		/**
		* Transform a query result into a csv formatted variable.
		*
		* @param query      The query to transform. (Required)
		* @param headers      A list of headers to use for the first row of the CSV string. Defaults to cols. (Optional)
		* @param cols      The columns from the query to transform. Defaults to all the columns. (Optional)
		* @return Returns a string.
		* @author adgnot sebastien (sadgnot@ogilvy.net)
		* @version 1, June 26, 2002
		*/
		//function QueryToCsv(arguments.data){
		    var csv = "";
		    //var cols = "";
		    //var headers = "";
		    var i = 1;
		    var j = 1;
		    
		    //if(arrayLen(arguments) gte 2) headers = arguments[2];
		    //if(arrayLen(arguments) gte 3) cols = arguments[3];
		    
		    if(arguments.cols is "") arguments.cols = arguments.data.columnList;
		    if(arguments.headers IS "") arguments.headers = arguments.cols;
		    
		    arguments.headers = listToArray(arguments.headers);
		    
		    for(i=1; i lte arrayLen(arguments.headers); i=i+1){
		        csv = csv & """" & arguments.headers[i] & """,";
		    }
		
		    csv = csv & chr(13) & chr(10);
		    
		    arguments.cols = listToArray(arguments.cols);
		    
		    for(i=1; i lte arguments.data.recordCount; i=i+1){
		        for(j=1; j lte arrayLen(arguments.cols); j=j+1){
		            csv = csv & """" & arguments.data[arguments.cols[j]][i] & """,";
		        }        
		        csv = csv & chr(13) & chr(10);
		    }
		    //return csv;
		//}
	</cfscript>
	<cfreturn csv>
</cffunction>
<!---
	/* ***************************************************************
	/*
	Author: 	Ron West
	Name:
		$queryConcat
	Summary:	
		Concatenate two queries together
	Returns:
		Query rtnQuery
	Arguments:
		Query query1
		Query query2
	History:
		2009-09-07 - RLW - Created

This library is part of the Common Function Library Project. An open source
	collection of UDF libraries designed for ColdFusion 5.0 and higher. For more information,
	please see the web site at:
		
		http://www.cflib.org
		
	Warning:
	You may not need all the functions in this library. If speed
	is _extremely_ important, you may want to consider deleting
	functions you do not plan on using. Normally you should not
	have to worry about the size of the library.
		
	License:
	This code may be used freely. 
	You may modify this code as you see fit, however, this header, and the header
	for the functions must remain intact.
	
	This code is provided as is.  We make no warranty or guarantee.  Use of this code is at your own risk.
--->
<cffunction name="queryConcat" access="public" returntype="Query" hint="Concatenate two queries together">
	<cfargument name="q1" type="query" required="true" hint="The first query to start with">
	<cfargument name="q2" type="query" required="true" hint="The second query - note must have the same columns as the first query">
	<cfscript>
		/**
		 * Concatenate two queries together.
		 * 
		 * @param q1 	 First query. (Optional)
		 * @param q2 	 Second query. (Optional)
		 * @return Returns a query. 
		 * @author Chris Dary (umbrae@gmail.com) 
		 * @version 1, February 23, 2006 
		 */
		var row = "";
		var col = "";
		
		if(arguments.q1.columnList NEQ arguments.q2.columnList) {
			return arguments.q1;
		}
		
		for(row=1; row LTE arguments.q2.recordCount; row=row+1) {
		 queryAddRow(arguments.q1);
		 for(col=1; col LTE listLen(arguments.q1.columnList); col=col+1)
			querySetCell(arguments.q1,ListGetAt(arguments.q1.columnList,col), arguments.q2[ListGetAt(arguments.q1.columnList,col)][row]);
		}
	</cfscript>
	<cfreturn q1>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$getTagAttribute
Summary:
	Returns the value for the html tag attribute.
Returns:
	String - Tag attribute data.
Arguments:
	String - tag - HTML tag.
	String - attribute - Attribute value to return from the tag.
History:
	2009-09-22 - MFC - Created
--->
<cffunction name="getTagAttribute" access="public" output="true" returntype="string" hint="Returns the value for the html tag attribute">
	<cfargument name="tag" type="string" required="true" hint="HTML tag">
	<cfargument name="attribute" type="string" required="true" hint="Attribute value to return from the tag">
	
	<cfscript>
		// Find the attribute in the tag
		var beginAttr = findNoCase(arguments.attribute, arguments.tag);
		var firstEqual = find("=", arguments.tag, beginAttr);
		// Handle quoted data
		var possibleQuote = mid(arguments.tag, firstEqual + 1, 1);
		var endAttr = "";
		var retAttrVal = "";		
			
		if ( beginAttr GT 0 ) {
			// Check if we have a quote around the value
			if ( (possibleQuote EQ """") OR (possibleQuote EQ "'") ) {
				// Find the closing quote 
				endAttr = findNoCase(possibleQuote, arguments.tag, firstEqual + 2);
			}
			else {
				// No quote, then find the next space
				endAttr = findNoCase(" ", arguments.tag, firstEqual);
			}
			// Get the value for the attr tag
			retAttrVal = mid(arguments.tag, firstEqual + 2, endAttr - firstEqual - 2 );
		}
	</cfscript>
	<cfreturn retAttrVal>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$deleteFromList
Summary:	
	Removes an item from a list
Returns:
	String list
Arguments:
	String list
	String listValue
History:
 2009-11-06 - RLW - Created
--->
<cffunction name="deleteFromList" access="public" returntype="String" hint="Removes a value from a list">
	<cfargument name="list" type="string" required="true" hint="The list with the value that is to be removed">
	<cfargument name="listValue" type="string" required="true" hint="The value to remove from the list">
	<cfscript>
		/**
		* Delete items from a list.
		*
		* @param variable      An item, or a list of items, to remove from the list. (Required)
		* @param qs      The actual list to parse. Can be blank. (Optional)
		* @return Returns a string.
		* @author Alessandro Chisari (ruchizzy@hotmail.com)
		* @version 1, May 17, 2006
		*/
		//var to hold the final string
		var string = "";
		//vars for use in the loop, so we don't have to evaluate lists and arrays more than once
		var ii = 1;
		var thisVar = "";
		var thisIndex = "";
		var array = "";
		//put the query string into an array for easier looping
		array = listToArray(arguments.list,",");
		//now, loop over the array and rebuild the string
		for(ii = 1; ii lte arrayLen(array); ii = ii + 1){
			thisIndex = array[ii];
			thisVar = thisIndex;
			//if this is the var, edit it to the value, otherwise, just append
			if(not listFindnocase(arguments.listValue,thisVar))
			string = listAppend(string,thisIndex,",");
		}
	</cfscript>
	<cfreturn string>
</cffunction>
<!---
 	From CFLib on 11/02/2009 [MFC]

	Capitalizes the first letter in each word.
	Made udf use strlen, rkc 3/12/02
	v2 by Sean Corfield.
	
	@param string      String to be modified. (Required)
	@return Returns a string.
	@author Raymond Camden (ray@camdenfamily.com)
	@version 2, March 9, 2007
--->
<cffunction name="capFirst" returntype="string" output="false">
    <cfargument name="str" type="string" required="true" />
    
    <cfset var newstr = "" />
    <cfset var word = "" />
    <cfset var separator = "" />
    
    <cfloop index="word" list="#arguments.str#" delimiters=" ">
        <cfset newstr = newstr & separator & UCase(left(word,1)) />
        <cfif len(word) gt 1>
            <cfset newstr = newstr & right(word,len(word)-1) />
        </cfif>
        <cfset separator = " " />
    </cfloop>

    <cfreturn newstr />
</cffunction>
<!---
/* *************************************************************** */
	From CFLib on 11/13/2009 [MFC]
/**
	* Concatenates two arrays.
	*
	* @param a1      The first array.
	* @param a2      The second array.
	* @return Returns an array.
	* @author Craig Fisher (craig@altainetractive.com)
	* @version 1, September 13, 2001
	*/
--->
<cffunction name="ArrayConcat" access="public" returntype="array" hint="">
	<cfargument name="a1" type="array" required="true" hint="">
	<cfargument name="a2" type="array" required="true" hint="">
	
	<cfscript>
	    var i=1;
	    if ((NOT IsArray(a1)) OR (NOT IsArray(a2))) {
	        writeoutput("Error in <Code>ArrayConcat()</code>! Correct usage: ArrayConcat(<I>Array1</I>, <I>Array2</I>) -- Concatenates Array2 to the end of Array1");
	        return 0;
	    }
	    for (i=1;i LTE ArrayLen(a2);i=i+1) {
	        ArrayAppend(a1, Duplicate(a2[i]));
	    }
	    return a1;
	</cfscript>
</cffunction>
<!---
/* *************************************************************** */
	From CFLib on 11/16/2009 [MFC]
	
/**
* Rounds a number to a specific number of decimal places by using Java's math library.
*
* @param numberToRound      The number to round. (Required)
* @param numberOfPlaces      The number of decimal places. (Required)
* @param mode      The rounding mode. Defaults to even. (Optional)
* @return Returns a number.
* @author Peter J. Farrell (pjf@maestropublishing.com)
* @version 1, March 3, 2006
*/
--->
<cffunction name="decimalRound" access="public" returntype="numeric" hint="">
	<cfargument name="numberToRound" type="numeric" required="true" hint="">
	<cfargument name="numberOfPlaces" type="numeric" required="true" hint="">
	
	<cfscript>
		// Thanks to the blog of Christian Cantrell for this one
		var bd = CreateObject("java", "java.math.BigDecimal");
		var mode = "even";
		var result = "";
		
		if (ArrayLen(arguments) GTE 3) {
		    mode = arguments[3];
		}
		
		bd.init(arguments.numberToRound);
		if (mode IS "up") {
		    bd = bd.setScale(arguments.numberOfPlaces, bd.ROUND_HALF_UP);
		} else if (mode IS "down") {
		    bd = bd.setScale(arguments.numberOfPlaces, bd.ROUND_HALF_DOWN);
		} else {
		    bd = bd.setScale(arguments.numberOfPlaces, bd.ROUND_HALF_EVEN);
		}
		result = bd.toString();
		
		if(result EQ 0) result = 0;
		
		return result;
	</cfscript>
</cffunction>
<!---
/* *************************************************************** */
	From CFLib on 11/17/2009 [MFC]
	
/**
* Remove duplicates from a list.
*
* @param lst      List to parse. (Required)
* @param delim      List delimiter. Defaults to a comma. (Optional)
* @return Returns a string.
* @author Keith Gaughan (keith@digital-crew.com)
* @version 1, August 22, 2005
*/
--->
<cffunction name="listRemoveDuplicates" access="public" returntype="string" hint="">
	<cfargument name="lst" type="string" required="true">
	<cfscript>
		var i = 0;
		var delim = ",";
		var asArray = "";
		var set = StructNew();
		
		if (ArrayLen(arguments) gt 1) delim = arguments[2];
		
		asArray = ListToArray(lst, delim);
		for (i = 1; i LTE ArrayLen(asArray); i = i + 1) set[asArray[i]] = "";
		
		return structKeyList(set, delim);
	</cfscript>
</cffunction>
<!---
/* *************************************************************** */
	From CFLib on 12/10/2009 [MFC]
/**
* Converts a structure to a URL query string.
*
* @param struct      Structure of key/value pairs you want converted to URL parameters
* @param keyValueDelim      Delimiter for the keys/values. Default is the equal sign (=).
* @param queryStrDelim      Delimiter separating url parameters. Default is the ampersand (&).
* @return Returns a string.
* @author Erki Esken (erki@dreamdrummer.com)
* @version 1, December 17, 2001
*/
--->
<cffunction name="StructToQueryString" access="public" returntype="string" hint="">
	<cfargument name="struct" type="struct" required="true" hint="">
	<cfscript>
		var qstr = "";
		var delim1 = "=";
		var delim2 = "&";
		
		switch (ArrayLen(Arguments)) {
		case "3":
		delim2 = Arguments[3];
		case "2":
		delim1 = Arguments[2];
		}
		    
		for (key in struct) {
		qstr = ListAppend(qstr, URLEncodedFormat(LCase(key)) & delim1 & URLEncodedFormat(struct[key]), delim2);
		}
		return qstr;
	</cfscript>
	
</cffunction>
<!---
/* *************************************************************** */
	From CFLib on 12/17/2009 [MFC]
	
Display rss feed.
Changes by Raymond Camden and Steven (v2 support amount)

@param feedURL      RSS URL. (Required)
@param amount      Restricts the amount of items returned. Defaults to number of items in the feed. (Optional)
@return Returns a query.
@author Jose Diaz-Salcedo (bleachedbug@gmail.com)
@version 2, November 20, 2008
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="cfRssFeed" access="public" returntype="query" output=false>
    <cfargument name="feedUrl" type="string" required="true"/>
    <cfset var news_file = arguments.feedurl>
    <cfset var rss = "">
    <cfset var items = "">
    <cfset var rssItems = "">
    <cfset var i = "">
    <cfset var row = "">
    <cfset var title = "">
    <cfset var link = "">
    <cfscript>
		var description = '';
	</cfscript>
    
    <cfhttp url="#news_file#" method="get" />
    
    <cfset rss = xmlParse(cfhttp.filecontent)>

    <cfset items = xmlSearch(rss, "/rss/channel/item")>
    <cfset rssItems = queryNew("title,description,link")>

    <cfloop from="1" to="#ArrayLen(items)#" index="i">
        <cfset row = queryAddRow(rssItems)>
        <cfset title = xmlSearch(rss, "/rss/channel/item[#i#]/title")>

        <cfif arrayLen(title)>
            <cfset title = title[1].xmlText>
        <cfelse>
            <cfset title="">
        </cfif>

        <cfset description = XMLSearch(items[i], "/rss/channel/item[#i#]/description")>

        <cfif ArrayLen(description)>
            <cfset description = description[1].xmlText>
        <cfelse>
            <cfset description="">
        </cfif>

        <cfset link = xmlSearch(items[i], "/rss/channel/item[#i#]/link")>

        <cfif arrayLen(link)>
            <cfset link = link[1].xmlText>
        <cfelse>
            <cfset link="">
        </cfif>

        <cfset querySetCell(rssItems, "title", title, row)>
        <cfset querySetCell(rssItems, "description", description, row)>
        <cfset querySetCell(rssItems, "link", link, row)>

    </cfloop>

    <cfreturn rssItems />

</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$formatUUID
Summary:
	Formats a string into an UUID number format.
	This happens b/c leading and ending zero's are ommitted.
Returns:
	UUID
Arguments:
	String - uuid - UUID string to fix.
History:
	2010-03-04 - MFC - Created
--->
<cffunction name="formatUUID" access="public" returntype="UUID" hint="">
	<cfargument name="uuid" type="string" required="true">
	<cfscript>
		var retUUID = arguments.uuid;
		var firstSet = ListFirst(arguments.uuid, "-");
		var lastSet = ListLast(arguments.uuid, "-");
		// Keep adding leading zero's until length is 8
		WHILE ( LEN(firstSet) LT 8 ){
			firstSet = "0" & firstSet;
		}
		// Keep adding ending zero's until length is 16
		WHILE ( LEN(lastSet) LT 16 ){
			lastSet = lastSet & "0";
		}
		// Merge the firstSet and lastSet back to the UUID
		retUUID = firstSet & "-" & ListGetAt(arguments.uuid, 2, "-") & "-" & ListGetAt(arguments.uuid, 3, "-") & "-" & lastSet;
		return retUUID;
	</cfscript>
</cffunction>

</cfcomponent>