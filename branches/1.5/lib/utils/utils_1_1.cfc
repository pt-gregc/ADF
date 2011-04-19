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
				and StructKeyExists(StructFind(application,arguments.appName), arguments.beanName)){
			bean = StructFind( StructFind(application,arguments.appName),arguments.beanName);
		// check in application scope
		}else if( application.ADF.objectFactory.containsBean(arguments.beanName) ){
			bean = application.ADF.objectFactory.getBean(arguments.beanName);
		}else if( server.ADF.objectFactory.containsBean(arguments.beanName) ){
			bean = server.ADF.objectFactory.getBean(arguments.beanName);
		}else if(StructKeyExists(application.ADF,arguments.beanName)){
			bean = StructFind(application.ADF,arguments.beanName);
		}
	</cfscript>
	<cfinvoke component = "#bean#"
		  method = "#arguments.methodName#"
		  returnVariable = "result.reData"
		  argumentCollection = "#arguments.args#">
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
 	3/1/11 - RAK - Created
--->
<cffunction name="getThumbnailOfResource" access="public" returntype="string" hint="Returns the url to the thumbnail of a resource">
	<cfargument name="filePath" type="string" required="true" default="" hint="Fully qualified path to resource.">
	<cfargument name="destinationURL" type="string" required="false" default="" hint="URL to destination folder. EX: /mySite/images/ (If not specified it puts the image next to the file)">
	<cfscript>
		var documentName = "";
		var destination = "";
		filePath = Replace(filePath,'\\','/');
		documentName = ListGetAt(filePath,ListLen(filePath,'/'),'/');

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

</cfcomponent>