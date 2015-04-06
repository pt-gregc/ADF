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
Name:
	data_1_1.cfc
Summary:
	Data Utils component functions for the ADF Library
Version:
	1.1
History:
	2011-01-25 - MFC - Created - New v1.1
	2012-03-31 - GAC - Fixed function comments in the numberAsString and the makeUUID functions
--->
<cfcomponent displayname="data_1_1" extends="ADF.lib.data.data_1_0" hint="Data Utils component functions for the ADF Library">

<cfproperty name="version" value="1_1_4">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Data_1_1">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Dave Merril
Name:
	$queryRowToStruct
Summary:
	Returns a struct with requested data from a requested query row.
Returns:
	Struct
Arguments:
	query - query
	rowNum - numeric
	colsList - string
	LCaseNames - boolean
	targetStruct - struct
History:
	2010-11-17 - RAK - Brought in Dave Merril's queryRowToStruct for use in ADF
--->
<cffunction name="queryRowToStruct" hint="Returns a struct w requested data from a requested query row." output="no" returntype="struct" access="public">
	<cfargument name="query" type="query" required="yes" hint="Source Query">
	<cfargument name="rowNum" type="numeric" default="1" required="no" hint="Row to convert">
	<cfargument name="colsList" type="string" default="#arguments.query.ColumnList#" required="no" hint="List of columns">
	<cfargument name="LCaseNames" type="boolean" default="yes" required="no" hint="Lowercase all the names?">
	<cfargument name="targetStruct" type="struct" default="#StructNew()#" required="no" hint="Ability to append the results to a passed in target structure">
	<cfscript>
		var s = arguments.targetStruct;
		var aCols = '';
		var i = 0;
		var count = 0;
		
		if (arguments.LCaseNames)
			arguments.colsList = LCase(arguments.colsList);
		aCols = ListToArray(arguments.colsList);
		count = ArrayLen(aCols);
		for (i = 1; i lte count; i = i + 1)
			s[aCols[i]] = arguments.query[aCols[i]][arguments.rowNum];
		return s;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$arrayOfStructToXML
Summary:
	Given an array of structures return an xml version
Returns:
	xml
Arguments:

History:
 	2010-12-01 - RAK - Created
--->
<cffunction name="arrayOfStructToXML" access="public" returntype="xml" hint="Given an array of structures return an xml version">
	<cfargument name="arrayOfStruct" type="array" required="true" default="" hint="Array of structures to be converted to XML data">
	<cfargument name="rootName" type="string" required="false" default="root" hint="Name of the root element to wrap all the xml data">
	<cfargument name="nodeName" type="string" required="true" default="node" hint="Default name of each of the nodes within arrays">
	<cfscript>
		var rtnXML = XmlNew();
		var i = 1;
		
		rtnXML.xmlRoot = XmlElemNew(rtnXML,arguments.rootName);
		for(i=1;i<=ArrayLen(arrayOfStruct);i = i +1)
			rtnXML[arguments.rootName].XmlChildren[i] = XmlElemNew(rtnXML,arguments.nodeName);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
From CFLib on 2/18/2011 [GAC]

Name:
	$activateURL

This function takes URLs in a text string and turns them into links.
Version 2 by Lucas Sherwood, lucas@thebitbucket.net.
Version 3 Updated to allow for ;

@param strText      	Text to parse. (Required)
@param target      		Optional target for links. Defaults to "". (Optional)
@param paragraph      	Optionally add paragraphFormat to returned string. (Optional)
@param linkClass      	Optionally add a class to the generated a tag. (Optional)
@return Returns a string.
@author Joel Mueller (lucas@thebitbucket.netjmueller@swiftk.com)
@version 3, August 11, 2004

History:
	2011-02-09 - GAC - Added
	2012-01-12 - GAC - Added a linkClass parameter
--->
<cffunction name="activateURL" access="public" returntype="string" hint="Takes urls in a text string and turns them into links">
	<cfargument name="strText" type="string" required="false" default="" hint="A text string to search through for URLs">
	<cfargument name="target" type="string" required="false" default="" hint="A valid A HREF target: _blank, _self">
	<cfargument name="paragraph" type="string" required="false" default="false" hint="If true, add paragraphFormat to returned string">
	<cfargument name="linkClass" type="string" required="false" default="" hint="Link Class">
	<cfscript>
	    var nextMatch = 1;
	    var objMatch = "";
	    var outstring = "";
	    var thisURL = "";
	    var thisLink = "";
	    
	    do {
	        objMatch = REFindNoCase("(((https?:|ftp:|gopher:)\/\/)|(www\.|ftp\.))[-[:alnum:]\?%,\.\/&##!;@:=\+~_]+[A-Za-z0-9\/]", arguments.strText, nextMatch, true);
	        if (objMatch.pos[1] GT nextMatch OR objMatch.pos[1] EQ nextMatch) {
	            outString = outString & Mid(arguments.strText, nextMatch, objMatch.pos[1] - nextMatch);
	        } else {
	            outString = outString & Mid(arguments.strText, nextMatch, Len(arguments.strText));
	        }
	        nextMatch = objMatch.pos[1] + objMatch.len[1];
	        if (ArrayLen(objMatch.pos) GT 1) {
	            // If the preceding character is an @, assume this is an e-mail address
	            // (for addresses like admin@ftp.cdrom.com)
	            if (Compare(Mid(arguments.strText, Max(objMatch.pos[1] - 1, 1), 1), "@") NEQ 0) {
	                thisURL = Mid(arguments.strText, objMatch.pos[1], objMatch.len[1]);
	                thisLink = "<a href=""";
	                switch (LCase(Mid(arguments.strText, objMatch.pos[2], objMatch.len[2]))) {
	                    case "www.": {
	                        thisLink = thisLink & "http://";
	                        break;
	                    }
	                    case "ftp.": {
	                        thisLink = thisLink & "ftp://";
	                        break;
	                    }
	                }
	                thisLink = thisLink & thisURL & """";
	                if (Len(Target) GT 0) {
	                    thisLink = thisLink & " target=""" & arguments.target & """";
	                }
	                if ( LEN(TRIM(arguments.linkClass)) GT 0 ) 
	                {
	                    thisLink = thisLink & " class=""" & arguments.linkClass & """";
	                }
	                thisLink = thisLink & ">" & thisURL & "</a>";
	                outString = outString & thisLink;
	                // arguments.strText = Replace(arguments.strText, thisURL, thisLink);
	                // nextMatch = nextMatch + Len(thisURL);
	            } else {
	                outString = outString & Mid(arguments.strText, objMatch.pos[1], objMatch.len[1]);
	            }
	        }
	    } while (nextMatch GT 0);
	        
	    // Now turn e-mail addresses into mailto: links.
	    outString = REReplace(outString, "([[:alnum:]_\.\-]+@([[:alnum:]_\.\-]+\.)+[[:alpha:]]{2,4})", "<a href=""mailto:\1"">\1</a>", "ALL");
	        
	    if ( arguments.paragraph ) 
	        outString = ParagraphFormat(outString);
	        
		return outString;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
From CFLib on 2011-03-10 [RAK]

Name:
	$feedToQuery

Converts an RSS 0.9+, ATOM or RDF feed into a query.

@param path      URL of RSS feed. (Required)
@return Returns a structure.
@author Joe Nicora (joe@seemecreate.com)
@version 1, April 9, 2007

History:
	2011-03-14 - RAK - Created
	2011-03-14 - RAK - Normalized columns
	2011-03-14 - RAK - Added date time parsing
	2011-04-20 - RAK - Changed if's to else if's to prevent issue wtih overlapping tags.
	2011-05-11 - RAK - Added success/failure return value to function
	2011-05-11 - RAK - Added improved error handling and reporting.
	2011-05-17 - RAK - Removed extra evaluate
	2014-03-05 - JTP - Var declarations
--->
<cffunction name="feedToQuery" returntype="struct" output="false" access="public" hint="Converts an rss feed to a query">
	<cfargument name="path" type="string" required="yes" hint="RSS Path" />

	<cfscript>
		var parsed = "";
		var index = 0;
		var rows = 0;
		var thisArr = arrayNew(1);
		var retStruct = structNew();
		var XMLText = "";
		var retQuery = queryNew("title,link,description");
		var nodeToReplace = '';
	</cfscript>
	
	<cfif path CONTAINS "://">
		<cfhttp url="#path#" resolveurl="no" />
		<cfset XMLText = cfhttp.fileContent>
	<cfelse>
		<cffile action="read" file="#path#" variable="XMLText">
	</cfif>

	<cfscript>
		retStruct.success = false;
		if(isXML(XMLText)){
			nodeToReplace = mid(XMLText, 1, find("?>", XMLText) + 1);
			XMLText = replaceNoCase(XMLText, nodeToReplace, "", "ALL");
			parsed = XMLParse(XMLText);
		}else{
			application.ADF.utils.logAppend(
					"Could not parse XML data in feedToQuery. <br/>"
					&"Feed URL: #path#. <br/>"
					&"XML Results: <br/>"
					&application.ADF.utils.doDump(XMLText,"XMLText",0,1)
					&"<br/><br/>"
					,"feedToQueryErrors.html"
				);
		}
		//RDF
		if (find("<rdf:RDF", parsed))
		{
			if (isArray(XMLSearch(parsed, "/rdf:RDF/")))
			{
				if (isArray(XMLSearch(parsed, "/channel/")))
				{
					retStruct.channel = structNew();
					if (structKeyExists(parsed["rdf:RDF"]["channel"].XMLAttributes, "rdf:about")) retStruct.channel.about = parsed["rdf:RDF"]["channel"].XMLAttributes["rdf:about"];
					if (structKeyExists(parsed["rdf:RDF"]["channel"], "link")) retStruct.channel.link = parsed["rdf:RDF"]["channel"].link.XMLText;
					if (structKeyExists(parsed["rdf:RDF"]["channel"], "title")) retStruct.channel.title = parsed["rdf:RDF"]["channel"].title.XMLText;
					if (structKeyExists(parsed["rdf:RDF"]["channel"], "description")) retStruct.channel.description = parsed["rdf:RDF"]["channel"].description.XMLText;
					if (structKeyExists(parsed["rdf:RDF"]["channel"].XMLAttributes, "rdf:resource")) retStruct.channel.image = parsed["rdf:RDF"]["channel"].image.XMLAttributes["rdf:resource"];
					retStruct.channel.type = "RDF";
				}
				if (isArray(XMLSearch(parsed, "/item/")))
				{
					for (index = 1; index LTE arrayLen(parsed["rdf:RDF"].XMLChildren); index = index + 1)
					{
						if (parsed["rdf:RDF"].XMLChildren[index].XMLName IS "item")
						{
							rows = rows + 1;
							queryAddRow(retQuery, 1);
							if (structKeyExists(parsed["rdf:RDF"].XMLChildren[index], "title")) querySetCell(retQuery, "title", parsed["rdf:RDF"].XMLChildren[index].title.XMLText, rows);
							if (structKeyExists(parsed["rdf:RDF"].XMLChildren[index], "link")) querySetCell(retQuery, "link", parsed["rdf:RDF"].XMLChildren[index].link.XMLText, rows);
							if (structKeyExists(parsed["rdf:RDF"].XMLChildren[index], "description")) querySetCell(retQuery, "description", parsed["rdf:RDF"].XMLChildren[index].description.XMLText, rows);
						}
					}
				}
				retStruct.query = retQuery;
				retStruct.success = true;
			}
		}
		//RSS
		else if (find("<rss", parsed))
		{
			if (isArray(XMLSearch(parsed, "/rss/")))
			{
				if (isArray(XMLSearch(parsed, "/channel/")))
				{
					retStruct.channel = structNew();
					if (structKeyExists(parsed["rss"]["channel"], "title")) retStruct.channel.title = parsed["rss"]["channel"].title.XMLText;
					if (structKeyExists(parsed["rss"]["channel"], "link")) retStruct.channel.link = parsed["rss"]["channel"].link.XMLText;
					if (structKeyExists(parsed["rss"]["channel"], "description")) retStruct.channel.description = parsed["rss"]["channel"].description.XMLText;
					if (structKeyExists(parsed["rss"]["channel"], "language")) retStruct.channel.language = parsed["rss"]["channel"].language.XMLText;
					if (structKeyExists(parsed["rss"]["channel"], "pubDate")) retStruct.channel.pubDate = parsed["rss"]["channel"].pubDate.XMLText;
					if (structKeyExists(parsed["rss"]["channel"], "lastBuildDate")) retStruct.channel.lastBuildDate = parsed["rss"]["channel"].lastBuildDate.XMLText;
					if (structKeyExists(parsed["rss"]["channel"], "docs")) retStruct.channel.docs = parsed["rss"]["channel"].docs.XMLText;
					if (structKeyExists(parsed["rss"]["channel"], "generator")) retStruct.channel.generator = parsed["rss"]["channel"].generator.XMLText;
					if (structKeyExists(parsed["rss"]["channel"], "manageEditor")) retStruct.channel.managingEditor = parsed["rss"]["channel"].managingEditor.XMLText;
					if (structKeyExists(parsed["rss"]["channel"], "webMaster")) retStruct.channel.webMaster = parsed["rss"]["channel"].webMaster.XMLText;
					retStruct.channel.type = "RSS";
				}
				if (isArray(XMLSearch(parsed, "/rss/channel/item/")))
				{
					retQuery = queryNew("title,link,description,pubDate,guid");
					queryAddRow(retQuery, arrayLen(XMLSearch(parsed, "/rss/channel/item/")));
					for (index = 1; index LTE arrayLen(XMLSearch(parsed, "/rss/channel/item/")); index = index + 1)
					{
						thisArray = XMLSearch(parsed, "/rss/channel/item/");
						if (structKeyExists(thisArray[index], "title")) querySetCell(retQuery, "title", thisArray[index].title.XMLText, index);
						if (structKeyExists(thisArray[index], "link")) querySetCell(retQuery, "link", thisArray[index].link.XMLText, index);
						if (structKeyExists(thisArray[index], "description")) querySetCell(retQuery, "description", thisArray[index].description.XMLText, index);
						if (structKeyExists(thisArray[index], "pubDate")){
							//2011-03-14 - RAK - Added date time parsing
							querySetCell(retQuery, "pubDate", parseDateTime(thisArray[index].pubDate.XMLText), index);
						}
						if (structKeyExists(thisArray[index], "guid")) querySetCell(retQuery, "guid", thisArray[index].guid.XMLText, index);
					}
				}
				retStruct.query = retQuery;
				retStruct.success = true;
			}
		}
		//ATOM
		else if (find("<feed", parsed))
		{
			retStruct.channel = structNew();
			if (structKeyExists(parsed["feed"], "title")) retStruct.channel.title = parsed["feed"].title.XMLText;
			if (structKeyExists(parsed["feed"], "link")) retStruct.channel.link = parsed["feed"].link.XMLAttributes.href;
			if (structKeyExists(parsed["feed"], "tagLine")) retStruct.channel.tagLine = parsed["feed"].tagLine.XMLText;
			if (structKeyExists(parsed["feed"], "id")) retStruct.channel.id = parsed["feed"].id.XMLText;
			if (structKeyExists(parsed["feed"], "modified")) retStruct.channel.modified = parsed["feed"].modified.XMLText;
			if (structKeyExists(parsed["feed"], "generator")) retStruct.channel.generator = parsed["feed"].generator.XMLText;
			retStruct.channel.type = "ATOM";

			if (isArray(XMLSearch(parsed, "/feed/entry/")))
			{
				//2011-03-14 - RAK - Normalized columns


				retQuery = queryNew("title,link,description,pubDate,guid");
				for (index = 1; index LTE arrayLen(parsed["feed"].XMLChildren); index = index + 1)
				{
					if (parsed["feed"].XMLChildren[index].XMLName IS "entry")
					{
						rows = rows + 1;
						queryAddRow(retQuery, 1);

						//2011-03-14 - RAK - Normalized columns


						if (structKeyExists(parsed["feed"].XMLChildren[index], "title")) querySetCell(retQuery, "title", parsed["feed"].XMLChildren[index].title.XMLText, rows);
						if (structKeyExists(parsed["feed"].XMLChildren[index], "link")) querySetCell(retQuery, "link", parsed["feed"].XMLChildren[index].link.XMLAttributes.href, rows);
						if (structKeyExists(parsed["feed"].XMLChildren[index], "content")) querySetCell(retQuery, "description", parsed["feed"].XMLChildren[index].content.XMLText, rows);
						if (structKeyExists(parsed["feed"].XMLChildren[index], "id")) querySetCell(retQuery, "guid", parsed["feed"].XMLChildren[index].id.XMLText, rows);
						if (structKeyExists(parsed["feed"].XMLChildren[index], "issued")) querySetCell(retQuery, "pubDate", parsed["feed"].XMLChildren[index].issued.XMLText, rows);
						if (structKeyExists(parsed["feed"].XMLChildren[index], "modified")) querySetCell(retQuery, "pubDate", parsed["feed"].XMLChildren[index].modified.XMLText, rows);
						if (structKeyExists(parsed["feed"].XMLChildren[index], "created")) querySetCell(retQuery, "pubDate", parsed["feed"].XMLChildren[index].created.XMLText, rows);
						//2011-03-14 - RAK - added updated parsing..
						if (structKeyExists(parsed["feed"].XMLChildren[index], "updated")) querySetCell(retQuery, "pubDate", application.ADF.date.ISOToDateTime(parsed["feed"].XMLChildren[index].updated.XMLText,0), rows);




					}
				}
			}
			retStruct.query = retQuery;
			retStruct.success = true;
		}
	</cfscript>
	<cfreturn retStruct />
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	Ben Nadel
Name:
	$queryAppend
Summary:
	This takes two queries and appends the second one to the first one. Returns the resultant third query.
Returns:
	Query
Arguments:
	QueryOne - query
	QueryTwo - query
	UnionAll - boolean
Source:
	http://www.bennadel.com/blog/114-ColdFusion-QueryAppend-qOne-qTwo-.htm
History:
	2011-03-14 - RAK - Pulled in from example on website
--->
<cffunction name="queryAppend" access="public" returntype="query" output="false" hint="This takes two queries and appends the second one to the first one. Returns the resultant third query.">
     <!--- Define arguments. --->
     <cfargument name="QueryOne" type="query" required="true" hint="The first query to have query 2 appended to"/>
     <cfargument name="QueryTwo" type="query" required="true" hint="The second query to be appended to query 1" />
     <cfargument name="UnionAll" type="boolean" required="false" default="true" hint="Care about diplicates or not, if we expect duplicates we union all" />
     <cfset var NewQuery = "" />

     <!--- Append the second to the first. Do this by unioning the two queries. --->
     <cfquery name="NewQuery" dbtype="query">
		  <!--- Select all from the first query. --->
		  (SELECT * FROM ARGUMENTS.QueryOne )
		  <!--- Union the two queries together. --->
		  UNION
		  <!---
		 * Check to see if we are going to care about duplicates. If we don't
		 * expect duplicates then just union all.
		 * --->
		  <cfif ARGUMENTS.UnionAll>
			 ALL
		  </cfif>
		  <!--- Select all from the second query. --->
		  ( SELECT * FROM ARGUMENTS.QueryTwo )
     </cfquery>

 	 <!--- // Return the new query. --->
     <cfreturn NewQuery />
 </cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Greg Cronkright
Name:
	$countWordsInString
Summary:
	Counts the number of words in a string
Returns:
	String
Arguments:
	string - textStr
History:
	2011-03-11 - GAC - 	Based on the word counting from trimStringByWordCount in data_1_0 
						which was originally written by David Grant (david@insite.net)
--->
<cffunction name="countWordsInString" access="public" returntype="String" hint="Counts the number of words in string">
	<cfargument name="textStr" required="yes" type="string" hint="The string to count">
	<cfscript>
		var numWords = 0;
		var str = trim(arguments.textStr);
		str = REReplace(str,"[[:space:]]{2,}"," ","ALL");
		numWords = listLen(str," ");
		return numWords;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	Pete Freitag
Name:
	$EscapeExtendedChars
Summary:
	Escapes extended chararacters from a string
Returns:
	String
Arguments:
	String - str
Source:
	URL: http://www.petefreitag.com/item/202.cfm
History:
	2011-03-31 - GAC - Added
	2014-03-05 - JTP - Var declarations
--->
<cffunction name="EscapeExtendedChars" returntype="string" access="public" output="false" hint="Escapes extended chararacters from a string">
	<cfargument name="str" type="string" required="true" hint="String to escape extended characters on">
	
	<cfscript>
		var buf = CreateObject("java", "java.lang.StringBuffer");
		var len = Len(arguments.str);
		var char = "";
		var charcode = 0;
		var i = 0;
		
		buf.ensureCapacity(JavaCast("int", len+20));
	</cfscript>
	
	<cfif NOT len>
		<cfreturn arguments.str>
	</cfif>
	<cfloop from="1" to="#len#" index="i">
		<cfset char = arguments.str.charAt(JavaCast("int", i-1))>
		<cfset charcode = JavaCast("int", char)>
		<cfif (charcode GT 31 AND charcode LT 127) OR charcode EQ 10
			OR charcode EQ 13 OR charcode EQ 9>
				<cfset buf.append(JavaCast("string", char))>
		<cfelse>
			<cfset buf.append(JavaCast("string", "&##"))>
			<cfset buf.append(JavaCast("string", charcode))>
			<cfset buf.append(JavaCast("string", ";"))>
		</cfif>
	</cfloop>
	<cfreturn buf.toString()>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$arrayOfStructsSortMultiKeys
Summary:
	Sorts an Array Of Structures based on the multiple structure keys.
Returns:
	array
Arguments:
	array - aOfS - Array of structure data set.
	string - orderByKeyList - Structure keys to sort the Array.
	Boolean - forceColsToVarchar
	Boolean - allowComplexValues
Usage:
	application.ptCourseCatalog.data.arrayOfStructsSortMultiKeys(aOfS,orderByKeyList,forceColsToVarchar);  
History:
	2011-04-04 - MFC - Created
	2011-09-01 - GAC - Added a flag to force all query columns to be varchar datatype
	2014-11-20 - GAC - Added a parameter to allow complex value to be returned in a query column
--->
<cffunction name="arrayOfStructsSortMultiKeys" access="public" returntype="array" output="true" hint="Sorts an Array Of Structures based on the multiple structure keys.">
	<cfargument name="aOfS" type="array" required="true" hint="Array of structures">
	<cfargument name="orderByKeyList" type="string" required="true" hint="List of keys to order by">
	<cfargument name="forceColsToVarchar" type="boolean" default="false" required="false" hint="Force the columnts to evaluate via varchar">
	<cfargument name="allowComplexValues" type="boolean" default="false" required="false" hint="Will allow complex values to be returned in a query column if the forceColsToVarchar not true.">
		
	<cfscript>
		// Make the array an query
		var aOfSQry = arrayOfStructuresToQuery(theArray=arguments.aOfS,forceColsToVarchar=arguments.forceColsToVarchar,allowComplexValues=arguments.allowComplexValues);
		var sortedQry = "";
	</cfscript>
	<!--- Query the data set to ORDER BY --->
	<cfquery name="sortedQry" dbtype="query">
        SELECT *
          FROM aOfSQry
      ORDER BY #arguments.orderByKeyList#
	</cfquery>
	<cfscript>
		// Transform the query back to array of structs and Return
		return queryToArrayOfStructures(sortedQry);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	Ben Forta (ben@forta.com)
Name:
	$numberAsString
Summary:
	Returns a number converted into a string (i.e. 1 becomes 'one')
Returns:
	string
Arguments:
	Numeric - number
History:
 	2011-07-25 - RAK - copied from http://www.cflib.org/index.cfm?event=page.udfbyid&udfid=40
	2011-09-07 - GAC - Removed all of IsDefined() functions and replaced them with StructKeyExists()... sorry Ben F! ... no IsDefined's allowed!
	2011-09-09 - GAC - Moved from UTILS_1_1 
	2014-03-05 - JTP - Var declarations
--->
<cffunction name="numberAsString" access="public" returntype="string" hint="Returns a number converted into a string (i.e. 1 becomes 'one')">
	<cfargument name="number" type="numeric" required="true" default="" hint="Number to convert into string">
	<cfscript>
		var Result="";          // Generated result
		var Str1="";            // Temp string
		var Str2="";            // Temp string
		var n=number;           // Working copy
		var Billions=0;
		var Millions=0;
		var Thousands=0;
		var Hundreds=0;
		var Tens=0;
		var Ones=0;
		var Point=0;
		var HaveValue=0;        // Flag needed to know if to process "0"
		var strHolder = StructNew();

		// Initialize strings
		// Strings are "externalized" to simplify
		// changing text or translating
		if ( NOT StructKeyExists(REQUEST,"Strs") )
		{
			REQUEST.Strs=StructNew();
			REQUEST.Strs.space=" ";
			REQUEST.Strs.and="and";
			REQUEST.Strs.point="Point";
			REQUEST.Strs.n0="Zero";
			REQUEST.Strs.n1="One";
			REQUEST.Strs.n2="Two";
			REQUEST.Strs.n3="Three";
			REQUEST.Strs.n4="Four";
			REQUEST.Strs.n5="Five";
			REQUEST.Strs.n6="Six";
			REQUEST.Strs.n7="Seven";
			REQUEST.Strs.n8="Eight";
			REQUEST.Strs.n9="Nine";
			REQUEST.Strs.n10="Ten";
			REQUEST.Strs.n11="Eleven";
			REQUEST.Strs.n12="Twelve";
			REQUEST.Strs.n13="Thirteen";
			REQUEST.Strs.n14="Fourteen";
			REQUEST.Strs.n15="Fifteen";
			REQUEST.Strs.n16="Sixteen";
			REQUEST.Strs.n17="Seventeen";
			REQUEST.Strs.n18="Eighteen";
			REQUEST.Strs.n19="Nineteen";
			REQUEST.Strs.n20="Twenty";
			REQUEST.Strs.n30="Thirty";
			REQUEST.Strs.n40="Forty";
			REQUEST.Strs.n50="Fifty";
			REQUEST.Strs.n60="Sixty";
			REQUEST.Strs.n70="Seventy";
			REQUEST.Strs.n80="Eighty";
			REQUEST.Strs.n90="Ninety";
			REQUEST.Strs.n100="Hundred";
			REQUEST.Strs.nK="Thousand";
			REQUEST.Strs.nM="Million";
			REQUEST.Strs.nB="Billion";
		}

		// Save strings to an array once to improve performance
		if ( NOT StructKeyExists(REQUEST,"StrsA") )
		{
			// Arrays start at 1, to 1 contains 0
			// 2 contains 1, and so on
			REQUEST.StrsA=ArrayNew(1);
			ArrayResize(REQUEST.StrsA, 91);
			REQUEST.StrsA[1]=REQUEST.Strs.n0;
			REQUEST.StrsA[2]=REQUEST.Strs.n1;
			REQUEST.StrsA[3]=REQUEST.Strs.n2;
			REQUEST.StrsA[4]=REQUEST.Strs.n3;
			REQUEST.StrsA[5]=REQUEST.Strs.n4;
			REQUEST.StrsA[6]=REQUEST.Strs.n5;
			REQUEST.StrsA[7]=REQUEST.Strs.n6;
			REQUEST.StrsA[8]=REQUEST.Strs.n7;
			REQUEST.StrsA[9]=REQUEST.Strs.n8;
			REQUEST.StrsA[10]=REQUEST.Strs.n9;
			REQUEST.StrsA[11]=REQUEST.Strs.n10;
			REQUEST.StrsA[12]=REQUEST.Strs.n11;
			REQUEST.StrsA[13]=REQUEST.Strs.n12;
			REQUEST.StrsA[14]=REQUEST.Strs.n13;
			REQUEST.StrsA[15]=REQUEST.Strs.n14;
			REQUEST.StrsA[16]=REQUEST.Strs.n15;
			REQUEST.StrsA[17]=REQUEST.Strs.n16;
			REQUEST.StrsA[18]=REQUEST.Strs.n17;
			REQUEST.StrsA[19]=REQUEST.Strs.n18;
			REQUEST.StrsA[20]=REQUEST.Strs.n19;
			REQUEST.StrsA[21]=REQUEST.Strs.n20;
			REQUEST.StrsA[31]=REQUEST.Strs.n30;
			REQUEST.StrsA[41]=REQUEST.Strs.n40;
			REQUEST.StrsA[51]=REQUEST.Strs.n50;
			REQUEST.StrsA[61]=REQUEST.Strs.n60;
			REQUEST.StrsA[71]=REQUEST.Strs.n70;
			REQUEST.StrsA[81]=REQUEST.Strs.n80;
			REQUEST.StrsA[91]=REQUEST.Strs.n90;
		}

		//zero shortcut
		if(number is 0) return "Zero";

		// How many billions?
		// Note: This is US billion (10^9) and not
		// UK billion (10^12), the latter is greater
		// than the maximum value of a CF integer and
		// cannot be supported.
		Billions=n\1000000000;
		if (Billions)
		{
			n=n-(1000000000*Billions);
			Str1=NumberAsString(Billions)&REQUEST.Strs.space&REQUEST.Strs.nB;
			if (Len(Result))
				Result=Result&REQUEST.Strs.space;
			Result=Result&Str1;
			Str1="";
			HaveValue=1;
		}

		// How many millions?
		Millions=n\1000000;
		if (Millions)
		{
			n=n-(1000000*Millions);
			Str1=NumberAsString(Millions)&REQUEST.Strs.space&REQUEST.Strs.nM;
			if (Len(Result))
				Result=Result&REQUEST.Strs.space;
			Result=Result&Str1;
			Str1="";
			HaveValue=1;
		}

		// How many thousands?
		Thousands=n\1000;
		if (Thousands)
		{
			n=n-(1000*Thousands);
			Str1=NumberAsString(Thousands)&REQUEST.Strs.space&REQUEST.Strs.nK;
			if (Len(Result))
				Result=Result&REQUEST.Strs.space;
			Result=Result&Str1;
			Str1="";
			HaveValue=1;
		}

		// How many hundreds?
		Hundreds=n\100;
		if (Hundreds)
		{
			n=n-(100*Hundreds);
			Str1=NumberAsString(Hundreds)&REQUEST.Strs.space&REQUEST.Strs.n100;
			if (Len(Result))
				Result=Result&REQUEST.Strs.space;
			Result=Result&Str1;
			Str1="";
			HaveValue=1;
		}

		// How many tens?
		Tens=n\10;
		if (Tens)
			n=n-(10*Tens);

		// How many ones?
		Ones=n\1;
		if (Ones)
			n=n-(Ones);

		// Anything after the decimal point?
		if (Find(".", number))
			Point=Val(ListLast(number, "."));

		// If 1-9
		Str1="";
		if (Tens IS 0)
		{
			if (Ones IS 0)
			{
				if (NOT HaveValue)
					Str1=REQUEST.StrsA[0];
			}
			else
				// 1 is in 2, 2 is in 3, etc
				Str1=REQUEST.StrsA[Ones+1];
		}
		else if (Tens IS 1)
		// If 10-19
		{
			// 10 is in 11, 11 is in 12, etc
			Str1=REQUEST.StrsA[Ones+11];
		}
		else
		{
			// 20 is in 21, 30 is in 31, etc
			Str1=REQUEST.StrsA[(Tens*10)+1];

			// Get "ones" portion
			if (Ones)
				Str2=NumberAsString(Ones);
			Str1=Str1&REQUEST.Strs.space&Str2;
		}

		// Build result
		if (Len(Str1))
		{
			if (Len(Result))
				Result=Result&REQUEST.Strs.space&REQUEST.Strs.and&REQUEST.Strs.space;
			Result=Result&Str1;
		}

		// Is there a decimal point to get?
		if (Point)
		{
			Str2=NumberAsString(Point);
			Result=Result&REQUEST.Strs.space&REQUEST.Strs.point&REQUEST.Strs.space&Str2;
		}

		return Result;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$makeUUID
Summary:
	Creates a UUID to return back via ajaxProxy
Returns:
	uuid
Arguments:
	none
History:
 	2011-08-02 - RAK - Created
	2011-09-07 - MFC - Commented out function because: 
						'The names of user-defined functions cannot be the same as built-in ColdFusion functions.'
	2011-09-09 - GAC - Moved from UTILS_1_1 and renamed
--->
<cffunction name="makeUUID" access="public" returntype="uuid" hint="Creates a UUID to return back via ajaxProxy">
	<cfreturn createUUID()>
</cffunction>

<!---
/* *************************************************************** */
From CFLib on 10/04/2011 [GAC]

Name:
	$listUnion

This function combines two lists, automatically removing duplicate values. 
Allows for optional delimiters for all lists. Also allows for optional sort type and sort order

@param List1      First list of delimited values. 
	@param List2      Second list of delimited values. 
	@param Delim1      Delimiter used for List1.  Default is the comma. 
	@param Delim2      Delimiter used for List2.  Default is the comma. 
	@param Delim3      Delimiter to use for the list returned by the function.  Default is the comma. 
	@param SortType      Type of sort:  Text or Numeric.  The default is Text. 
	@param SortOrder      Asc for ascending, DESC for descending.  Default is Asc 
	@return Returns a string. 

@author Rob Brooks-Bilson (rbils@amkor.com) 
	@version 1, November 14, 2001 

History:
	2011-10-04 - GAC - Added
--->
<cffunction name="listUnion" access="public" returntype="string" hint="This function combines two lists, automatically removing duplicate values. Allows for optional delimiters for all lists. Also allows for optional sort type and sort order">
	<cfargument name="list1" type="string" required="false" default="" hint="First list of delimited values.">
	<cfargument name="list2" type="string" required="false" default="" hint="Second list of delimited values.">
	<cfargument name="delim1" type="string" required="false" default="," hint="Delimiter used for List1. Default is the comma.">
	<cfargument name="delim2" type="string" required="false" default="," hint="Delimiter used for List2. Default is the comma.">
	<cfargument name="delim3" type="string" required="false" default="," hint="Delimiter to use for the list returned by the function. Default is the comma.">
	<cfargument name="sortType" type="string" required="false" default="text" hint="Type of sort:  text or numeric. Default is text.">
	<cfargument name="sortOrder" type="string" required="false" default="ASC" hint="ASC for ascending, DESC for descending. Default is ASC.">
	<cfscript>
	 	var TempList = "";
		var CombinedList = "";  
		var i = 0;
		// Combine list 1 and list 2 with the proper delimiter
		CombinedList = ListChangeDelims(arguments.List1, arguments.Delim3, arguments.Delim1) & arguments.Delim3 &  ListChangeDelims(arguments.List2, arguments.Delim3, arguments.Delim2);
		// Strip duplicates if indicated
		for (i=1; i LTE ListLen(CombinedList, arguments.Delim3); i=i+1) {
		    if (NOT ListFindNoCase(TempList, ListGetAt(CombinedList, i, arguments.Delim3), arguments.Delim3))
		    {
		    	TempList = ListAppend(TempList, ListGetAt(CombinedList, i, arguments.Delim3), arguments.Delim3);
			}
		}
		return ListSort(TempList, arguments.SortType, arguments.SortOrder, arguments.Delim3);
	</cfscript>
</cffunction>

</cfcomponent>