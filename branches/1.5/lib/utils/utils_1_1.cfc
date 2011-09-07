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
	1.1.0
History:
	2011-01-25 - MFC - Created
	2011-02-01 - GAC - Added dependency to csData_1_1
--->
<cfcomponent displayname="utils_1_1" extends="ADF.lib.utils.utils_1_0" hint="Util functions for the ADF Library">

<cfproperty name="version" value="1_1_0">
<cfproperty name="type" value="singleton">
<cfproperty name="ceData" type="dependency" injectedBean="ceData_1_1">
<cfproperty name="csData" type="dependency" injectedBean="csData_1_1">
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
	<cfargument name="xmlSource" type="string" required="yes">
	<cfargument name="xslSource" type="string" required="yes">
	<cfargument name="stParameters" type="struct" default="#StructNew()#" required="No">

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
	Ben Forta (ben@forta.com
Name:
	$numberAsString
Summary:
	Returns a number converte dinto a string (i.e. 1 becomes 'one')
Returns:
	string
Arguments:

History:
 	2011-07-25 - RAK - copied from http://www.cflib.org/index.cfm?event=page.udfbyid&udfid=40
	2011-09-07 - GAC - Removed all of IsDefined() functions and replaced them with StructKeyExists()... sorry Ben F! ... no IsDefined's allowed!
--->
<cffunction name="numberAsString" access="public" returntype="string" hint="Returns a number converte dinto a string (i.e. 1 becomes 'one')">
	<cfargument name="number" type="numeric" required="true" default="" hint="Number to convert into string">
	<cfscript>
		VAR Result="";          // Generated result
		VAR Str1="";            // Temp string
		VAR Str2="";            // Temp string
		VAR n=number;           // Working copy
		VAR Billions=0;
		VAR Millions=0;
		VAR Thousands=0;
		VAR Hundreds=0;
		VAR Tens=0;
		VAR Ones=0;
		VAR Point=0;
		VAR HaveValue=0;        // Flag needed to know if to process "0"
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

</cfcomponent>