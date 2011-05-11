<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2011.
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
	1.1.0
History:
	2011-01-25 - MFC - Created - New v1.1
--->
<cfcomponent displayname="data_1_1" extends="ADF.lib.data.data_1_0" hint="Data Utils component functions for the ADF Library">

<cfproperty name="version" value="1_1_0">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Data_1_1">

<!---
/* ***************************************************************
/*
Author: 	Dave Merril
Name:
	$queryRowToStruct
Summary:
	Returns a struct w requested data from a requested query row.
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
	<cfargument name="query" type="query" required="yes">
	<cfargument name="rowNum" type="numeric" default="1" required="no">
	<cfargument name="colsList" type="string" default="#arguments.query.ColumnList#" required="no">
	<cfargument name="LCaseNames" type="boolean" default="yes" required="no">
	<cfargument name="targetStruct" type="struct" default="#StructNew()#" required="no">
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
/* ***************************************************************
/*
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
 	Dec 1, 2010 - RAK - Created
--->
<cffunction name="arrayOfStructToXML" access="public" returntype="xml" hint="Given an array of structures return an xml version">
	<cfargument name="arrayOfStruct" type="array" required="true" default="" hint="Array of structures to be converted to XML data">
	<cfargument name="rootName" type="string" required="false" default="root" hint="Name of the root element to wrap all the xml data">
	<cfargument name="nodeName" type="string" required="true" default="node" hint="Default name of each of the nodes within arrays">
	<cfscript>
		var rtnXML = XmlNew();
		var i = 1;
		rtnXML.xmlRoot = XmlElemNew(rtnXML,arguments.rootName);
		for(i=1;i<=ArrayLen(arrayOfStruct);i = i +1){
			rtnXML[arguments.rootName].XmlChildren[i] = XmlElemNew(rtnXML,arguments.nodeName);
			
		}
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
	From CFLib on 2/18/2011 [GAC]

	This function takes URLs in a text string and turns them into links.
	Version 2 by Lucas Sherwood, lucas@thebitbucket.net.
	Version 3 Updated to allow for ;
	
	@param strText      	Text to parse. (Required)
	@param target      		Optional target for links. Defaults to "". (Optional)
	@param paragraph      	Optionally add paragraphFormat to returned string. (Optional)
	@return Returns a string.
	@author Joel Mueller (lucas@thebitbucket.netjmueller@swiftk.com)
	@version 3, August 11, 2004
	
	History:
		2011-02-09 - GAC - Added
--->
<cffunction name="activateURL" access="public" returntype="string" hint="">
	<cfargument name="strText" type="string" required="false" default="" hint="A text string to search through for URLs">
	<cfargument name="target" type="string" required="false" default="" hint="A valid A HREF target: _blank, _self">
	<cfargument name="paragraph" type="string" required="false" default="false" hint="If true, add paragraphFormat to returned string">
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
From CFLib on 2011-03-10 [RAK]

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
--->
<cffunction name="feedToQuery" returntype="struct" output="false" access="public">
	/**
	 * Converts an RSS 0.9+, ATOM or RDF feed into a query.
	 *
	 * @param path 	 		RSS feed url or file path, must be valid RSS, ATOM or RDF. (Required)
	 * @return 				Returns a structure with meta data and a query.
	 * @author 				Joe Nicora (joe@seemecreate.com)
	 * @version 1, 			July 16, 2006
	 */
	<cfargument name="path" type="string" required="yes" />

	<cfset var parsed = "" />
	<cfset var index = 0 />
	<cfset var rows = 0 />
	<cfset var thisArr = arrayNew(1) />
	<cfset var retStruct = structNew() />
	<cfset var XMLText = "" />
	<cfset var retQuery = queryNew("title,link,description") />

	<cfif path CONTAINS "://">
		<cfhttp url="#path#" resolveurl="no" />
		<cfset XMLText = cfhttp.fileContent />
	<cfelse>
		<cffile action="read" file="#path#" variable="XMLText">
	</cfif>

	<cfscript>
		retStruct.success = false;
		if(isXML(XMLText)){
			nodeToReplace = mid(XMLText, 1, evaluate(find("?>", XMLText) + 1));
			XMLText = replaceNoCase(XMLText, nodeToReplace, "", "ALL");
			parsed = XMLParse(XMLText);
		}else{
			application.ADF.utils.logAppend(
					"Could not parse XML data in feedToQuery. <br/>"
					&"Feed URL: #path#. <br/>"
					&"XML Results: <br/>"
					&Application.ADF.utils.doDump(XMLText,"XMLText",0,1)
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
/* ***************************************************************
/*
Author: 	Ben Nadel
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
     <cfargument name="QueryOne" type="query" required="true" />
     <cfargument name="QueryTwo" type="query" required="true" />
     <cfargument name="UnionAll" type="boolean" required="false" default="true" />
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

 <!--- Return the new query. --->
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
--->
<cffunction name="EscapeExtendedChars" returntype="string" access="public" output="false" hint="Escapes extended chararacters from a string">
	<cfargument name="str" type="string" required="true">
	<cfset var buf = CreateObject("java", "java.lang.StringBuffer")>
	<cfset var len = Len(arguments.str)>
	<cfset var char = "">
	<cfset var charcode = 0>
	<cfset buf.ensureCapacity(JavaCast("int", len+20))>
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
History:
	2011-04-04 - MFC - Created
--->
<cffunction name="arrayOfStructsSortMultiKeys" access="public" returntype="array" output="true" hint="Sorts an Array Of Structures based on the multiple structure keys.">
	<cfargument name="aOfS" type="array" required="true">
	<cfargument name="orderByKeyList" type="string" required="true">

	<cfscript>
		// Make the array an query
		var aOfSQry = arrayOfStructuresToQuery(arguments.aOfS);
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

</cfcomponent>