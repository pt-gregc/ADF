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
--->
<cfcomponent displayname="utils_1_1" extends="ADF.lib.utils.utils_1_0" hint="Util functions for the ADF Library">

<cfproperty name="version" value="1_1_0">
<cfproperty name="type" value="singleton">
<cfproperty name="ceData" type="dependency" injectedBean="ceData_1_1">
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

History:
 	Dec 3, 2010 - RAK - Created
	2010-12-21 - GAC - Modified - Fixed the default variable for the args parameter
	2010-12-21 - GAC - Modified - var scoped the bean local variable
	2011-01-19 - GAC - Modified - Updated the returnVariable to allow calls to methods that return void
	2011-01-30 - RLW - Modified - Added an optional appName param that can be used to execute a method from an app bean
--->
<cffunction name="runCommand" access="public" returntype="Any" hint="Runs the given command">
	<cfargument name="beanName" type="string" required="true" default="" hint="Name of the bean you would like to call">
	<cfargument name="methodName" type="string" required="true" default="" hint="Name of the method you would like to call">
	<cfargument name="args" type="Struct" required="false" default="#StructNew()#" hint="Structure of arguments for the speicified call">
	<cfargument name="appName" type="string" required="false" default="" hint="Pass in an App Name to allow the method to be exectuted from an app bean">
	<cfscript>
		var local = StructNew();
		var bean = "";
		// if there has been an app name passed through go directly to that
		if( len(arguments.appName) and structKeyExists(application, arguments.appName) and isObject(evaluate("application." & arguments.appName & "." & beanName)) )
			bean = evaluate("application." & arguments.appName & "." & beanName);
		// check in application scope
		else if( application.ADF.objectFactory.containsBean(arguments.beanName) )
			bean = application.ADF.objectFactory.getBean(arguments.beanName);
		else if( server.ADF.objectFactory.containsBean(arguments.beanName) )
			bean = server.ADF.objectFactory.getBean(arguments.beanName);
	</cfscript>
   	<cfinvoke component = "#bean#"
				 method = "#arguments.methodName#"
				 returnVariable = "local.returnData"
				 argumentCollection = "#arguments.args#" />
	<cfscript>
		// Check to make sure the local.returnData was not destroyed by a method that returns void
		if ( StructKeyExists(local,"returnData") )
			return local.returnData;
		else
			return;
	</cfscript>		 
</cffunction>



</cfcomponent>