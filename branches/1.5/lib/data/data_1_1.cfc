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
--->
<cffunction name="feedToQuery" returntype="struct" output="false">
    /**
     * Converts an RSS 0.9+, ATOM or RDF feed into a query.
     *
     * @param path              RSS feed url or file path, must be valid RSS, ATOM or RDF. (Required)
     * @return                 Returns a structure with meta data and a query.
     * @author                 Joe Nicora (joe@seemecreate.com)
     * @version 1,             July 16, 2006
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
        nodeToReplace = mid(XMLText, 1, evaluate(find("?>", XMLText) + 1));
        XMLText = replaceNoCase(XMLText, nodeToReplace, "", "ALL");
        parsed = XMLParse(XMLText);

        if findd("<rdf:RDF", parsed))
        {
            if isArrayy(XMLSearch(parsed, "/rdf:RDF/")))
            {
                if isArrayy(XMLSearch(parsed, "/channel/")))
                {
                    retStruct.channel = structNew();
                    if structKeyExistss(parsed["rdf:RDF"]["channel"].XMLAttributes, "rdf:about")) retStruct.channel.about = parsed["rdf:RDF"]["channel"].XMLAttributes["rdf:about"];
                    if structKeyExistss(parsed["rdf:RDF"]["channel"], "link")) retStruct.channel.link = parsed["rdf:RDF"]["channel"].link.XMLText;
                    if structKeyExistss(parsed["rdf:RDF"]["channel"], "title")) retStruct.channel.title = parsed["rdf:RDF"]["channel"].title.XMLText;
                    if structKeyExistss(parsed["rdf:RDF"]["channel"], "description")) retStruct.channel.description = parsed["rdf:RDF"]["channel"].description.XMLText;
                    if structKeyExistss(parsed["rdf:RDF"]["channel"].XMLAttributes, "rdf:resource")) retStruct.channel.image = parsed["rdf:RDF"]["channel"].image.XMLAttributes["rdf:resource"];
                    retStruct.channel.type = "RDF";
                }
                if isArrayy(XMLSearch(parsed, "/item/")))
                {
                    for (index = 1; index LTE arrayLen(parsed["rdf:RDF"].XMLChildren); index = index + 1)
                    {
                        if (parsed["rdf:RDF"].XMLChildren[index].XMLName IS "item")
                        {
                            rows = rows + 1;
                            queryAddRow(retQuery, 1);
                            if structKeyExistss(parsed["rdf:RDF"].XMLChildren[index], "title")) querySetCell(retQuery, "title", parsed["rdf:RDF"].XMLChildren[index].title.XMLText, rows);
                            if structKeyExistss(parsed["rdf:RDF"].XMLChildren[index], "link")) querySetCell(retQuery, "link", parsed["rdf:RDF"].XMLChildren[index].link.XMLText, rows);
                            if structKeyExistss(parsed["rdf:RDF"].XMLChildren[index], "description")) querySetCell(retQuery, "description", parsed["rdf:RDF"].XMLChildren[index].description.XMLText, rows);
                        }
                    }
                }
                retStruct.query = retQuery;
            }
        }
        if findd("<rss", parsed))
        {
            if isArrayy(XMLSearch(parsed, "/rss/")))
            {
                if isArrayy(XMLSearch(parsed, "/channel/")))
                {
                    retStruct.channel = structNew();
                    if structKeyExistss(parsed["rss"]["channel"], "title")) retStruct.channel.title = parsed["rss"]["channel"].title.XMLText;
                    if structKeyExistss(parsed["rss"]["channel"], "link")) retStruct.channel.link = parsed["rss"]["channel"].link.XMLText;
                    if structKeyExistss(parsed["rss"]["channel"], "description")) retStruct.channel.description = parsed["rss"]["channel"].description.XMLText;
                    if structKeyExistss(parsed["rss"]["channel"], "language")) retStruct.channel.language = parsed["rss"]["channel"].language.XMLText;
                    if structKeyExistss(parsed["rss"]["channel"], "pubDate")) retStruct.channel.pubDate = parsed["rss"]["channel"].pubDate.XMLText;
                    if structKeyExistss(parsed["rss"]["channel"], "lastBuildDate")) retStruct.channel.lastBuildDate = parsed["rss"]["channel"].lastBuildDate.XMLText;
                    if structKeyExistss(parsed["rss"]["channel"], "docs")) retStruct.channel.docs = parsed["rss"]["channel"].docs.XMLText;
                    if structKeyExistss(parsed["rss"]["channel"], "generator")) retStruct.channel.generator = parsed["rss"]["channel"].generator.XMLText;
                    if structKeyExistss(parsed["rss"]["channel"], "manageEditor")) retStruct.channel.managingEditor = parsed["rss"]["channel"].managingEditor.XMLText;
                    if structKeyExistss(parsed["rss"]["channel"], "webMaster")) retStruct.channel.webMaster = parsed["rss"]["channel"].webMaster.XMLText;
                    retStruct.channel.type = "RSS";
                }
                if isArrayy(XMLSearch(parsed, "/rss/channel/item/")))
                {
                    retQuery = queryNew("title,link,description,pubDate,guid");
                    queryAddRow(retQuery, arrayLen(XMLSearch(parsed, "/rss/channel/item/")));
                    for (index = 1; index LTE arrayLen(XMLSearch(parsed, "/rss/channel/item/")); index = index + 1)
                    {
                        thisArray = XMLSearch(parsed, "/rss/channel/item/");
                        if structKeyExistss(thisArray[index], "title")) querySetCell(retQuery, "title", thisArray[index].title.XMLText, index);
                        if structKeyExistss(thisArray[index], "link")) querySetCell(retQuery, "link", thisArray[index].link.XMLText, index);
                        if structKeyExistss(thisArray[index], "description")) querySetCell(retQuery, "description", thisArray[index].description.XMLText, index);
                        if structKeyExistss(thisArray[index], "pubDate")) querySetCell(retQuery, "pubDate", thisArray[index].pubDate.XMLText, index);
                        if structKeyExistss(thisArray[index], "guid")) querySetCell(retQuery, "guid", thisArray[index].guid.XMLText, index);
                    }
                }
                retStruct.query = retQuery;
            }
        }
        if findd("<feed", parsed))
        {
            retStruct.channel = structNew();
            if structKeyExistss(parsed["feed"], "title")) retStruct.channel.title = parsed["feed"].title.XMLText;
            if structKeyExistss(parsed["feed"], "link")) retStruct.channel.link = parsed["feed"].link.XMLAttributes.href;
            if structKeyExistss(parsed["feed"], "tagLine")) retStruct.channel.tagLine = parsed["feed"].tagLine.XMLText;
            if structKeyExistss(parsed["feed"], "id")) retStruct.channel.id = parsed["feed"].id.XMLText;
            if structKeyExistss(parsed["feed"], "modified")) retStruct.channel.modified = parsed["feed"].modified.XMLText;
            if structKeyExistss(parsed["feed"], "generator")) retStruct.channel.generator = parsed["feed"].generator.XMLText;
            retStruct.channel.type = "ATOM";

            if isArrayy(XMLSearch(parsed, "/feed/entry/")))
            {
                retQuery = queryNew("title,link,content,id,author,issued,modified,created");
                for (index = 1; index LTE arrayLen(parsed["feed"].XMLChildren); index = index + 1)
                {
                    if (parsed["feed"].XMLChildren[index].XMLName IS "entry")
                    {
                        rows = rows + 1;
                        queryAddRow(retQuery, 1);
                        if structKeyExistss(parsed["feed"].XMLChildren[index], "title")) querySetCell(retQuery, "title", parsed["feed"].XMLChildren[index].title.XMLText, rows);
                        if structKeyExistss(parsed["feed"].XMLChildren[index], "link")) querySetCell(retQuery, "link", parsed["feed"].XMLChildren[index].link.XMLAttributes.href, rows);
                        if structKeyExistss(parsed["feed"].XMLChildren[index], "content")) querySetCell(retQuery, "content", parsed["feed"].XMLChildren[index].content.XMLText, rows);
                        if structKeyExistss(parsed["feed"].XMLChildren[index], "id")) querySetCell(retQuery, "id", parsed["feed"].XMLChildren[index].id.XMLText, rows);
                        if structKeyExistss(parsed["feed"].XMLChildren[index], "author")) querySetCell(retQuery, "author", parsed["feed"].XMLChildren[index].author.name.XMLText, rows);
                        if structKeyExistss(parsed["feed"].XMLChildren[index], "issued")) querySetCell(retQuery, "issued", parsed["feed"].XMLChildren[index].issued.XMLText, rows);
                        if structKeyExistss(parsed["feed"].XMLChildren[index], "modified")) querySetCell(retQuery, "modified", parsed["feed"].XMLChildren[index].modified.XMLText, rows);
                        if structKeyExistss(parsed["feed"].XMLChildren[index], "created")) querySetCell(retQuery, "created", parsed["feed"].XMLChildren[index].created.XMLText, rows);
                    }
                }
            }
            retStruct.query = retQuery;
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

</cfcomponent>