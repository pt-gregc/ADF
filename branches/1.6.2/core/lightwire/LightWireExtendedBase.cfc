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
	LightWireExtendedBase.cfc
History:
	2009-08-14 - MFC - Created
	2013-10-21 - GAC - Added 'file-version' property for ADF core files 
--->

<cfcomponent name="LightWireExtendedBase" extends="ADF.thirdParty.lightwire.LightWire" output="false">

<cfproperty name="version" value="1_6_2">
<cfproperty name="file-version" value="1">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	G. Cronkright
Name:
	$getBean
Summary:
	Override method for the Lightwire getBean method with added error handling.
	Used return a bean with all of its dependencies loaded..
Returns:
	void
Arguments:
	String - ObjectName 
History:
	2011-01-20 - GAC - Copied from Lightwire Lightwire.cfc
					   Modified to add error logging
--->
<cffunction name="getBean" returntype="any" access="public" output="false" hint="I return a bean with all of its dependencies loaded.">
	<cfargument name="ObjectName" type="string" required="yes" hint="I am the name of the object to generate.">
	<cfscript>
		var ReturnObject = '';
		var buildError = StructNew();
		
		try {
			// Call the getBean method from the extended Lightwire.cfc in Lightwire
			ReturnObject = Super.getBean(argumentCollection=arguments);
		}
		catch( Any e ) {
			// Build the Error Struct
			buildError.args = arguments;
			buildError.details = e;
			// Log the Error struct and add it to the ADF buildErrors Array 
			doBuildErrorLogging("getBean",buildError);
		}
		return ReturnObject;
	</cfscript>	
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	G. Cronkright
Name:
	doBuildErrorLogging
Summary:
	Create a Log file for the given error and add the error struct to the application.ADF.buildErrors Array
Returns:
	Boolean
Arguments:
	String - meathodName
History:
	2011-01-21 - GAC - Created
--->
<cffunction name="doBuildErrorLogging" access="public" returntype="void" hint="Create a Log file for the given error and add the error struct to the application.ADF.buildErrors Array">
	<cfargument name="methodName" type="string" required="false" default="GenericBuild" hint="method that was called that we should log">
	<cfargument name="errorDetailsStruct" type="struct" required="false" default="#StructNew()#" hint="Error details structure to log">
	<cfscript>
		var dump = "";
		var logFileName = dateFormat(now(), "yyyymmdd") & "." & request.site.name & ".ADF_" & arguments.methodName & "_Errors.htm";
		var errorStruct = arguments.errorDetailsStruct;	
		// Add the methodName to the errorStruct
		errorStruct.ADFmethodName = arguments.methodName;
	</cfscript>
	<!--- // Package the error dump and write it to a html file in the logs directory --->
	<cfsavecontent variable="dump">
		<cfdump var="#errorStruct#" label="#arguments.methodName# Error" expand="false">
	</cfsavecontent>
	<cffile action="append" file="#request.cp.commonSpotDir#logs/#logFileName#" output="#request.formattedtimestamp# - #dump#" addnewline="true">
	<cfscript>
		// Add the errorStruct to the server.ADF.buildErrors Array 
		ArrayAppend(server.ADF.buildErrors,errorStruct);
	</cfscript>
</cffunction>

</cfcomponent>