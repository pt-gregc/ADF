<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2010.
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
	ajaxService_1_0.cfc
Summary:
	Ajax Service functions for the ADF Library
History:
	2009-06-17 - MFC - Created
--->
<cfcomponent displayname="ajaxService_1_0" hint="Ajax Service functions for the ADF Library" extends="ADF.core.Base">


<cfproperty name="version" value="1_0_0">
<cfproperty name="type" value="singleton">
<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$getSubsiteStruct
Summary:	
	Acts as a loader (broker) for the csData_1_0.getSubsiteStruct
Returns:
	Struct subsiteStruct
Arguments:
	Void
History:
	2009-05-15 - RLW - Created
--->
<cffunction name="getSubsiteStruct" access="remote" returntype="struct" returnformat="json" hint="Acts as a loader (broker) for the csData_1_0.getSubsiteStruct">
	<cfset var csData = server.ADF.getBean("csData_1_0")>
	<cfreturn csData.getSubsiteStruct()>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$addSubsite
Summary:	
	Acts as an Ajax broker for the CCAPI "createSubsite" call
Returns:
	Boolean success
Arguments:
	Numeric subsiteID [The subsite where the new subsite should be created in]
	String name [Name for the new subsite]
	String description [Description of the new subsite]
	String displayName [The Display Name for the new subsite]
History:
	2009-05-18 - RLW - Created
--->
<cffunction name="addSubsite" access="remote" returntype="Boolean" returnformat="json" hint="Acts as an Ajax broker for the CCAPI createSubsite call">
	<cfargument name="subsiteID" type="numeric" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="description" type="string" required="true">
	<cfargument name="displayName" type="string" required="true">
	<cfscript>
		// get and configure the csSubsite bean
		csSubsiteObj = server.ADF.getBean("csSubsite_1_0").createSubsite(arguments, arguments.subsiteID, false);	
	</cfscript>
	<cfreturn true>
</cffunction>

</cfcomponent>