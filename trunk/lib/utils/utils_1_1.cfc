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
	utils_1_1.cfc
Summary:
	Util functions for the ADF Library
Version:
	1.1.2
History:
	2011-01-25 - MFC - Created
	2011-02-01 - GAC - Added dependency to csData_1_1
	2011-03-31 - GAC - Added dependency to data_1_1
--->
<cfcomponent displayname="utils_1_1" extends="ADF.lib.utils.utils_1_0" hint="Util functions for the ADF Library">

<cfproperty name="version" value="1_1_2">
<cfproperty name="type" value="singleton">
<cfproperty name="ceData" type="dependency" injectedBean="ceData_1_1">
<cfproperty name="csData" type="dependency" injectedBean="csData_1_1">
<cfproperty name="data" type="dependency" injectedBean="data_1_1">
<cfproperty name="wikiTitle" value="Utils_1_1">

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$runCommand
Summary:
	Runs the given command
Returns:
	Any
Arguments:
	string - beanName
	string - methodName
	struct - args
	string - appName
History:
 	Dec 3, 2010 - RAK - Created
	2010-12-21 - GAC - Modified - Fixed the default variable for the args parameter
	2010-12-21 - GAC - Modified - var scoped the bean local variable
	2011-01-19 - GAC - Modified - Updated the returnVariable to allow calls to methods that return void
	2011-01-30 - RLW - Modified - Added an optional appName param that can be used to execute a method from an app bean
	2011-02-01 - GAC - Comments - Updated the comments with the arguments list
	2011-02-09 - GAC - Modified - renamed the 'local' variable to 'result' since local is a reserved word in CF9
	2011-04-19 - RAK - Modified loading beans by bean name to not use evaluate and added fallback for application.ADF.beanName
	2011-05-17 - RAK - Verified we were able to find the bean before we invoked commands upon it
	2011-09-07 - GAC - Modified - added a TRY/CATCH around the CFINVOKE and an ELSE to the IsObject() check to help with error handling
--->
<cffunction name="runCommand" access="public" returntype="Any" hint="Runs the given command">
	<cfargument name="beanName" type="string" required="true" default="" hint="Name of the bean you would like to call">
	<cfargument name="methodName" type="string" required="true" default="" hint="Name of the method you would like to call">
	<cfargument name="args" type="Struct" required="false" default="#StructNew()#" hint="Structure of arguments for the speicified call">
	<cfargument name="appName" type="string" required="false" default="" hint="Pass in an App Name to allow the method to be exectuted from an app bean">
	<cfscript>
		var result = StructNew();
		var bean = "";
		// if there has been an app name passed through go directly to that
		if( Len(arguments.appName)
				and StructKeyExists(application, arguments.appName)
				and StructKeyExists(StructFind(application,arguments.appName), arguments.beanName) )
		{
			bean = StructFind( StructFind(application,arguments.appName),arguments.beanName);
		// check in application scope
		}
		else if ( application.ADF.objectFactory.containsBean(arguments.beanName) )
		{
			bean = application.ADF.objectFactory.getBean(arguments.beanName);
		}
		else if ( server.ADF.objectFactory.containsBean(arguments.beanName) )
		{
			bean = server.ADF.objectFactory.getBean(arguments.beanName);
		}
		else if(StructKeyExists(application.ADF,arguments.beanName))
		{
			bean = StructFind(application.ADF,arguments.beanName);
		}
	</cfscript>
	<cfif isObject(bean)>
		<cftry>
			<cfinvoke component = "#bean#"
				  method = "#arguments.methodName#"
				  returnVariable = "result.reData"
				  argumentCollection = "#arguments.args#">
			<cfcatch>
				<cfset result.reData = cfcatch>
			</cfcatch>
		</cftry>
	<cfelse>
		<cfset result.reData = "Error: The Bean is not an Object and could not be used as a component!">
	</cfif>
	<cfscript>
		// Check to make sure the result.returnData was not destroyed by a method that returns void
		if ( StructKeyExists(result,"reData") )
			return result.reData;
		else
			return;
	</cfscript>		 
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Greg Cronkright
Name:
	$buildRunCommandArgs
Summary:
	Builds the args struct for the runCommand method
Returns:
	struct
Arguments:
	struct params - a Structure of parameters for the specified call
	string excludeList - a list of arguments to exclude from the return args struct
History:
 	2011-02-01 - GAC - Created
	2011-02-01 - RAK - Added the json decode to process data passed in a json objects
	2011-02-01 - GAC - Modified - converted csData lib calls to global  
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="buildRunCommandArgs" access="public" returntype="struct" hint="Builds the args struct for the runCommand method">
	<cfargument name="params" type="struct" required="false" default="#StructNew()#" hint="Structure of parameters to be passed to the runCommand method">
	<cfargument name="excludeList" type="string" required="false" default="bean,method,appName" hint="a list of arguments to exclude from the return args struct">
	<cfscript>
		var args = StructNew();
		var itm = 1;
		var thisParam = "";
		var serialFormStruct = StructNew();
		var json = "";
		// loop through arguments.params parameters to get the args
		for( itm=1; itm lte listLen(structKeyList(arguments.params)); itm=itm+1 )
		{
			thisParam = listGetAt(structKeyList(arguments.params), itm);
			// Do no add the param to the args struct if it is in the excludeList
			if( not listFindNoCase(arguments.excludeList, thisParam) )
			{
				// Check if the argument name is 'serializedForm'
				if(thisParam EQ 'serializedForm'){
					// get the serialized form string into a structure
					serialFormStruct = variables.csData.serializedFormStringToStruct(arguments.params[thisParam]);
					StructInsert(args,"serializedForm",serialFormStruct);
				}else{
					// is thisParam is a JSON object process it throught the json lib decode method
					if(isJSON(arguments.params[thisParam])){
						json = server.ADF.objectFactory.getBean("json");
						arguments.params[thisParam] = json.decode(arguments.params[thisParam]);
					}
					StructInsert(args,thisParam,arguments.params[thisParam]);
				}
			}
		}
		return args;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$getThumbnailOfResource
Summary:
	Returns the url to the thumbnail of a resource
Returns:
	string
Arguments:
	filePath - string - Fully qualified path to resource.
	destinationURL - string - Optional - URL to destination folder. EX: /mySite/images/ (If not specified it puts the image next to the file)
History:
 	2011-03-01 - RAK - Created
 	2011-05-10 - RAK - fixed bug related to unix systems
--->
<cffunction name="getThumbnailOfResource" access="public" returntype="string" hint="Returns the url to the thumbnail of a resource">
	<cfargument name="filePath" type="string" required="true" default="" hint="Fully qualified path to resource.">
	<cfargument name="destinationURL" type="string" required="false" default="" hint="URL to destination folder. EX: /mySite/images/ (If not specified it puts the image next to the file)">
	<cfscript>
		var documentName = "";
		var destination = "";
		filePath = Replace(filePath,'\','/',"ALL");
		documentName = listLast(filePath,"/");
		if(Len(destinationURL)){
			destination = expandPath(destinationURL);
		}else{
			destination = Replace(filePath,documentName,'');
		}
	</cfscript>
	<cfpdf
		source="#filePath#"
		action = "thumbnail"
		destination = "#destination#"
		overwrite="yes"
		pages="1"
		format="png"
	>
	<cfreturn "#destinationURL##Left(documentName,Len(documentName)-4)#_page_1.png">
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ron West
Name:
	$IPInRange
Summary:
	Returns a boolean active flag if the current users IP is within the given range
Returns:
	boolean
Arguments:
	String startIP
	String endIP
	String ip
History:
 	2011-04-26 - RLW - Created
--->
<cffunction name="IPInRange" access="public" returnType="boolean" hint="Returns true if the current users IP is within the valid range ">
	<cfargument name="startIP" type="string" required="true" hint="Starting IP Range - can be as low as 1.0">
	<cfargument name="endIP" type="string" required="true" hint="Ending IP Range - can be as low as 1.1">
	<cfargument name="ip" type="string" required="false" default="#cgi.remote_addr#" hint="IP to check - defaults to current users IP">
	<cfscript>
		/**
		Based off of the following function
		
		* determine if IP is with in a range.
		* 04-mar-2010 renamed to IPinRange so as not to conflict w/existing UDF
		* 
		* @param start      start IP range (Required)
		* @param end      end IP range (Required)
		* @param ip      IP to test if in range (Required)
		* @return Returns a boolean. 
		* @author A. Cole (acole76@NOSPAMgmail.com) 
		* @version 0, March 4, 2010 
		*/
	    var startArray = listtoarray(arguments.startIP, ".");
	    var endArray = listtoarray(arguments.endIP, ".");
	    var ipArray = listtoarray(arguments.ip, ".");
	    var s = 0;
	    var e = 0;
	    var c = 0;
	    // check the length of the array and insert blank entries if the ip range was short an octet
	   	while(arrayLen(startArray) lt 4){
	   		arrayAppend(startArray, 1);
	   	}
	   	while(arrayLen(endArray) lt 4){
	   		arrayAppend(endArray, 256);
	   	}
	    // build string for comparison
	    s = ((16777216 * startArray[1]) + (65536 * startArray[2]) + (256 * startArray[3]) + startArray[4]);
	    e = ((16777216 * endArray[1]) + (65536 * endArray[2]) + (256 * endArray[3]) + endArray[4]);
	    c = ((16777216 * ipArray[1]) + (65536 * ipArray[2]) + (256 * ipArray[3]) + ipArray[4]);
	</cfscript>
	<cfreturn isvalid("range", c, s, e)>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$urlEncodeStruct
Summary:
	Converts a structure into a URL encoded key value pair string
Returns:
	string
Arguments:
	urlstruct - Struct - Structure of key value pairs for the url encoding
History:
 	2011-05-12 - RAK - Created
--->
<cffunction name="urlEncodeStruct" access="public" returntype="string" hint="Converts a structure into a URL encoded key value pair string">
	<cfargument name="urlStruct" type="struct" required="true" default="" hint="Structure of key value pairs for the url encoding">
	<cfset var rtnString = "">
	<!---Loop over each key in the structure, lowercase and encode it .
				and assign it to its value and add it to the list with a delim of &
	--->
	<cfloop collection="#arguments.urlStruct#" item="key">
		<cfscript>
			rtnString = listAppend(rtnString,URLEncodedFormat(LCase(key))&"="&URLEncodedFormat(arguments.urlStruct[key]),"&");
		</cfscript>
	</cfloop>
	<cfreturn rtnString>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$xslTransform
Summary:
	Transforms the xml file while still processing xsl:import tags.
Returns:
	string
Arguments:

History:
 	2011-05-13 - RAK - Created
	2011-09-07 - MFC - Updated the line breaks for the var scoping.
--->
<cffunction name="xslTransform" access="public" returntype="string" output="No" hint="Transforms the xml file while still processing xsl:import tags.">
	<cfargument name="xmlSource" type="string" required="yes" hint="Source of the XML file, this can be either a file path or text">
	<cfargument name="xslSource" type="string" required="yes" hint="Transformation source, this can be either a file path or text">
	<cfargument name="stParameters" type="struct" default="#StructNew()#" required="No" hint="Optional parameters to pass into the XSL transform">

	<cfscript>
		var source = ""; 
		var transformer = ""; 
		var aParamKeys = ""; 
		var pKey = "";
		var xmlReader = ""; 
		var xslReader = ""; 
		var pLen = 0;
		var xmlWriter = ""; 
		var xmlResult = ""; 
		var pCounter = 0;
		var tFactory = createObject("java", "javax.xml.transform.TransformerFactory").newInstance();

		//if xml use the StringReader - otherwise, just assume it is a file source.
		if(Find("<", arguments.xslSource) neq 0){
			xslReader = createObject("java", "java.io.StringReader").init(arguments.xslSource);
			source = createObject("java", "javax.xml.transform.stream.StreamSource").init(xslReader);
		}else{
			source = createObject("java", "javax.xml.transform.stream.StreamSource").init("file:///#arguments.xslSource#");
		}

		transformer = tFactory.newTransformer(source);

		//if xml use the StringReader - otherwise, just assume it is a file source.
		if(Find("<", arguments.xmlSource) neq 0){
			xmlReader = createObject("java", "java.io.StringReader").init(arguments.xmlSource);
			source = createObject("java", "javax.xml.transform.stream.StreamSource").init(xmlReader);
		}else{
			source = createObject("java", "javax.xml.transform.stream.StreamSource").init("file:///#arguments.xmlSource#");
		}

		//use a StringWriter to allow us to grab the String out after.
		xmlWriter = createObject("java", "java.io.StringWriter").init();

		xmlResult = createObject("java", "javax.xml.transform.stream.StreamResult").init(xmlWriter);

		if(StructCount(arguments.stParameters) gt 0){
			aParamKeys = structKeyArray(arguments.stParameters);
			pLen = ArrayLen(aParamKeys);
			for(pCounter = 1; pCounter LTE pLen; pCounter = pCounter + 1){
				//set params
				pKey = aParamKeys[pCounter];
				transformer.setParameter(pKey, arguments.stParameters[pKey]);
			}
		}

		transformer.transform(source, xmlResult);

		return xmlWriter.toString();
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
	2011-09-09 - GAC - Moved to DATA_1_1
	2012-03-31 - GAC - Converted to a forwarding function 
--->
<!--- // This function was moved to Data_1_1 LIB and will most likely be removed from Utils_1_1 in a future version --->
<cffunction name="numberAsString" access="public" returntype="string" hint="Returns a number convertedin to a string (i.e. 1 becomes 'one')">
	<cfargument name="number" type="numeric" required="true" default="" hint="Number to convert into string">
	<cfscript>
		return variables.data.numberAsString(number=arguments.number);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$createUUID
Summary:
	Creates a UUID to return back via ajaxPRoxy
Returns:
	uuid
Arguments:

History:
 	2011-08-02 - RAK - Created
	2011-09-07 - MFC - Commented out function because: 
						'The names of user-defined functions cannot be the same as built-in ColdFusion functions.'
--->
<!--- <cffunction name="createUUID" access="public" returntype="uuid" hint="Creates a UUID to return back via ajaxPRoxy">
	<cfreturn createUUID()>
</cffunction> --->

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	$versionCompare
Summary:
	Compares two version strings and returns a comparison value (1,0, or -1)
	Currently ONLY handles versions that contain Numbers and Dots (.) 
	Will need some modifications to handle text (ie. beta) or dashes (-)
	
	Based on a code example from:
	http://stackoverflow.com/questions/2365893/parsing-version-numbers-to-real-numbers
Returns:
	numeric
Arguments:
	String - versionA
	String - versionB
History:
 	2011-08-02 - GAC - Created
--->
 <cffunction name="versionCompare" access="public" returntype="numeric" hint="Compares two version strings and returns a comparison value (1,0, or -1)">
	<cfargument name="versionA" type="string" required="true" default="" hint="First version string to compare">
	<cfargument name="versionB" type="string" required="true" default="" hint="Second version string to compare">
	<cfscript>
		var arrayA = ListToArray(arguments.versionA,'.');
	    var arrayB = ListToArray(arguments.versionB,'.');
	    var lenA = ArrayLen(arrayA);
	    var lenB = ArrayLen(arrayB);
	    var a = 0;
	    var i = 0;
	    var itmA = '';
	    var itmB = '';
		// We need to make both Arrays equal length
	    if ( lenA GT lenB )
	    {
	        // if A is greater add to B
	        for ( a=lenB; a LT lenA; a=a+1 ) {
	        	ArrayAppend(arrayB,0);
	        }
	    }
	    else if ( lenB GT lenA )
	    {
	       	// if B is greater add to A
	        for ( a=lenA; a LT lenB; a=a+1 ) {
	        	ArrayAppend(arrayA,0);
	        }
	    }
		// Loop over the versionA Array and compare each pair of A and B  
	    for ( i=1; i LTE ArrayLen(arrayA); i=i+1 ) {
	    	itmA = Val(arrayA[i]);
	    	itmB = Val(arrayB[i]);
	    	// if equal Move on the next item pair
	        if (itmA NEQ itmB)
	        {
	            // Compare the item pair
	            if (itmA GT itmB)
	            {
	                return 1;
	            }
	            else
	            {
	                return -1;
	            }
	        } 
	    }
    	return 0;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Sam Smith
Name:
	$buildPaginationStruct
Summary:
	Returns pagination widget
Returns:
	Struct rtn (itemStart & itemEnd for output loop)
Arguments:
	Numeric - page
	Numeric - itemCount
	Numeric - pageSize
	Boolean - showCount (results count)
	String - URLparams (addl URL params for page links)
	Numeric - listLimit
	String - linkSeparator
	String - gapSeparator
History:
	2008-12-05 - SFS - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
	2012-03-08 - GAC - added a parameter for the listLimit to allow defined quantity of links to be built 
					 - added a parameter for the linkSeparator to allow the character(s) between consecutive links to be defined
					 - added a parameter for the gapSeparator to allow the character(s) for the gap of skipped links to be defined
					 - removed the CFOUTPUTS and move all generated string values into the returned structure
					 - added the hints to the parameters
					 - moved to utils_1_1 since removing the CFOUTPUTS may change backwards compatiblity
--->
<cffunction name="buildPaginationStruct" access="public" returntype="struct">
	<cfargument name="page" type="numeric" required="true" default="1" hint="the value of the current page">
	<cfargument name="itemCount" type="numeric" required="true" default="0" hint="the total number of items">
	<cfargument name="pageSize" type="numeric" required="true" default="1" hint="the number of items per page">
	<cfargument name="showCount" type="boolean" required="false" default="true" hint="build the record results count string">
	<cfargument name="URLparams" type="string" required="false" default="additional URL params for page links">
	<cfargument name="listLimit" type="numeric" required="false" default="6" hint="the number of link structs that get built">
	<cfargument name="linkSeparator" type="string" required="false" default="|" hint="a character(s) separator for between consecutive links">
	<cfargument name="gapSeparator" type="string" required="false" default="..." hint="a character(s) separator for the gab between skipped links">
	
	<cfscript>
		var rtn = StructNew();
		var listStart = '';
		var listEnd = '';
		var pg = '';
		var maxPage = Ceiling(arguments.itemCount / arguments.pageSize);
		var itemStart = 0;
		var itemEnd = 0;

		// Make sure the value passed in for listLimit is at least 4
		if (arguments.listLimit LT 4 )
			arguments.listLimit = 4;

		if ( arguments.page LT 1 )
			arguments.page = 1;
		else if ( arguments.page GT maxPage )
			arguments.page = maxPage;

		if ( arguments.page EQ 1 )
		{
			itemStart = 1;
			itemEnd = arguments.pageSize;
		}
		else
		{
			itemStart = ((arguments.page - 1) * arguments.pageSize) + 1;
			itemEnd = arguments.page * arguments.pageSize;
		}

		if ( itemEnd GT arguments.itemCount )
			itemEnd = arguments.itemCount;

		rtn.itemStart = itemStart;
		rtn.itemEnd = itemEnd;
	</cfscript>

	<!--- // Moved the Record Count string into the rtn Struct --->
	<cfif arguments.showCount>
		<cfset rtn.resultsCount = "Results #itemStart# - #itemEnd# of #arguments.itemCount#">
	</cfif>
	
	<cfif arguments.page GT 1>
		<cfset rtn.prevlink = "?page=#arguments.page-1##arguments.URLparams#">
		<!---&laquo; <a href="?page=#arguments.page-1##arguments.URLparams#">Prev</a>--->
	<cfelse>
		<cfset rtn.prevlink = "">
	</cfif>

	<!--- // Complicated code to help determine which page numbers to show in pagination --->
	<cfif arguments.page LTE arguments.listLimit>
		<cfset listStart = 2>
	<cfelseif arguments.page GTE maxPage - (arguments.listLimit - 1)>
		<cfset listStart = maxPage - arguments.listLimit>
	<cfelse>
		<cfset listStart = arguments.page - 2>
	</cfif>

	<cfif arguments.page LTE arguments.listLimit>
		<cfset listEnd = arguments.listLimit + 1>
	<cfelseif arguments.page GTE maxPage - (arguments.listLimit - 1)>
		<cfset listEnd = maxPage - 1>
	<cfelse>
		<cfset listEnd = arguments.page + 2>
	</cfif>

	<cfset rtn.pagelinks = ArrayNew(1)>
	<cfloop from="1" to="#maxPage#" index="pg">
		<cfset rtn.pageLinks[pg] = StructNew()>
		<cfif (pg EQ 1 OR pg EQ maxPage) OR (pg GTE listStart AND pg LTE listEnd)>
			<cfif (pg EQ listStart AND listStart GT 2) OR (pg EQ maxPage AND listEnd LT maxPage - 1)>
				<!--- // Add the Separator to the struct for the 'gab' between skipped links --->
				<cfset rtn.pageLinks[pg].Separator = arguments.gapSeparator>
				<!---...--->
			<cfelse>
				<!--- // Add the Separator to the struct for between consecutive links --->
				<cfset rtn.pageLinks[pg].Separator = arguments.linkSeparator>
				<!---|--->
			</cfif>
			<cfif arguments.page NEQ pg>
				<cfset rtn.pageLinks[pg].link = "?page=#pg##arguments.URLparams#">
				<!---<a href="?page=#pg##arguments.URLparams#">#pg#</a>--->
			<cfelse>
				<cfset rtn.pageLinks[pg].link = "">
				<!---#pg#--->
			</cfif>
		<cfelse>
			<!--- // Builds an empty struct for pagelinks outside of the LIST limit --->
		</cfif>
	</cfloop>
	<cfif arguments.page LT maxPage>
		<cfset rtn.nextLink = "?page=#arguments.page+1##arguments.URLparams#">
		<!---| <a href="?page=#arguments.page+1##arguments.URLparams#">Next</a> &raquo;--->
	<cfelse>
		<cfset rtn.nextLink = "">
	</cfif>

	<cfreturn rtn>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	T. Parker 
Name:
	$fileLastModifiedDateTime
Summary:
	Returns the last modified datetime stamp for a file
	
	To get the file last modified date of the calling script use:
	thisModulePath = GetCurrentTemplatePath();
	modDateTime = application.ADF.utils.fileLastModifiedDateTime(thisModulePath);
Returns:
	String
Arguments:
	String - filePath
History:
 	2012-05-04 - GAC - Added
--->
 <cffunction name="fileLastModifiedDateTime" access="public" returntype="string" hint="Returns the last modified datetime stamp for a file">
	<cfargument name="filePath" type="string" required="true" default="" hint="Full path to a file">
	<cfscript>
		var fileInfo = CreateObject("java","java.io.File").init(arguments.filePath);
 		var thisModuleLastModified = fileInfo.lastModified();
 		var thisModuleDateTime = createObject("java","java.util.Date").init(thisModuleLastModified);
    	return thisModuleDateTime;
	</cfscript>
</cffunction>

</cfcomponent>