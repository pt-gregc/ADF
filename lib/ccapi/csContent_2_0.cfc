<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
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
	csContent_2_0.cfc
Summary:
	CCAPI Content functions for the ADF Library
Version:
	2.0
History:
	2012-12-27 - MFC - Created.  Direct functions to the API Element Library.
	2014-09-23 - GAC - Updated the apiElement injectedBean dependency to version apiElement_1_1
--->
<cfcomponent displayname="csContent_2_0" extends="ADF.lib.ccapi.csContent_1_0" hint="Constructs a CCAPI instance and then allows you to populate Custom Elements and Textblocks">

<cfproperty name="version" value="2_0_7">
<cfproperty name="type" value="transient">
<cfproperty name="apiElement" type="dependency" injectedBean="apiElement_1_1">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">
<cfproperty name="wikiTitle" value="CSContent_2_0">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$populateContent
Summary:
	Handles population of the textblock content
	Will send to pre process before entering content
	Return structure will have a status code and message
Returns:
	Struct status - returns the status of the update with the following keys
		contentUpdated - did the content get updated
		msg - error message if available
Arguments:
	String elementName - the named element which content will be added for
	Struct data - the data for the element
	Numeric - forceSubsiteID - If set this will override the subsiteID in the data.
	Numeric - forcePageID - If set this will override the pageID in the data.
	Boolean - forceLogout
	String - forceControlName
	Numeric - forceControlID
	String - forceElementType
History:
	2012-12-27 - MFC - Created.  Direct functions to the API Element Library.
	2013-02-21 - GAC - Fixed typo in log text message
	2013-06-24 - MTT - Added the forceControlName and forceControlID arguments.
	2014-05-01 - GAC - Fixed typo in the try/catch, switched ( e ANY ) to ( ANY e )
	2014-09-23 - GAC - Updated to call the apiElement_1_1 via the server bean rather than the injectedBean dependency
	2015-08-22 - GAC - Updated to allow textblock updates to be passed to the csContent_1_0.populateContent
	2015-09-11 - GAC - Var'd the return result variable
--->
<cffunction name="populateContent" access="public" returntype="struct" hint="Use this method to populate content for either a Textblock or Custom Element">
	<cfargument name="elementName" type="string" required="true" hint="The name of the element from the CCAPI configuration">
	<cfargument name="data" type="struct" required="true" hint="Data for either the Texblock element or the Custom Element">
	<cfargument name="forceSubsiteID" type="numeric" required="false" default="-1" hint="If set this will override the subsiteID in the data.">
	<cfargument name="forcePageID" type="numeric" required="false" default="-1" hint="If set this will override the pageID in the data.">
	<cfargument name="forceLogout" type="boolean" required="false" default="true" hint="Flag to keep the API session logged in for a continuous process.">	
	<cfargument name="forceControlName" type="string" required="false" default="" hint="Field to override the element control name from the config.">
	<cfargument name="forceControlID" type="numeric" required="false" default="-1" hint="Field to override the element control name with the control ID.">
	<cfargument name="forceElementType" type="string" required="false" default="custom" hint="Field to override the element type name. Element type of 'textblock' pass request to csContent_1_0.populateContent">
	
	<cfscript>
		var contentResult = StructNew();
		var result = StructNew();
		
		//var apiElement = server.ADF.objectFactory.getBean("apiElement_1_1");
		
		// For textblock updating allow populateContent calls to use csContent_1_0.populateContent
		if ( arguments.forceElementType EQ "textblock" )
		{
			variables.ccapi = server.ADF.objectFactory.getBean("ccapi_1_0");
			
			contentResult = super.populateContent(argumentCollection=arguments);
		}
		else
		{
			// Call the API apiElement Lib Component
			contentResult = variables.apiElement.populateCustom(elementName=arguments.elementName,
																    data=arguments.data,
																    forceSubsiteID=arguments.forceSubsiteID,
																    forcePageID=arguments.forcePageID,
																    forceLogout=arguments.forceLogout,
																    forceControlName=arguments.forceControlName,
																    forceControlID=arguments.forceControlID);
		}
		
		// Format the result in the way that was previously constructed
		result = contentResult;
		
		if ( StructKeyExists(contentResult,"status") )
			result.contentUpdated = contentResult.status;

		//result.msg = contentResult.msg;
		
		return result; 
	</cfscript>
</cffunction>

</cfcomponent>