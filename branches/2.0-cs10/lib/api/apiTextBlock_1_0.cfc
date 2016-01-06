<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2016.
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
	apiTextBlock_1_0.cfc
Summary:
	API Subsite functions for the ADF Library
Version:
	1.0
History:
	2013-02-12 - MFC - Created
	2015-06-11 - GAC - Updated the component extends to use the libraryBase path
--->
<cfcomponent displayname="apiTextBlock_1_0" extends="ADF.lib.libraryBase" hint="API Text Block functions for the ADF Library">

<cfproperty name="version" value="1_0_2">
<cfproperty name="api" type="dependency" injectedBean="api_1_0">
<cfproperty name="csContent" type="dependency" injectedBean="csContent_2_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_2_0">
<cfproperty name="wikiTitle" value="APITextBlock_1_0">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$populate
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
	Struct data - the data for the textblock element
	Numeric - forceSubsiteID - If set this will override the subsiteID in the data.
	Numeric - forcePageID - If set this will override the pageID in the data.
	Boolean - forceLogout
	String - forceControlName
	Numeric - forceControlID
History:
	2015-09-11 - GAC - Created
--->
<cffunction name="populate" access="public" returntype="struct" hint="Use this method to populate content for either a Textblock or Custom Element">
	<cfargument name="elementName" type="string" required="true" hint="The name of the element from the CCAPI configuration">
	<cfargument name="data" type="struct" required="true" hint="Data for either the Texblock element">
	<cfargument name="forceSubsiteID" type="numeric" required="false" default="-1" hint="If set this will override the subsiteID in the data.">
	<cfargument name="forcePageID" type="numeric" required="false" default="-1" hint="If set this will override the pageID in the data.">
	<cfargument name="forceLogout" type="boolean" required="false" default="true" hint="Flag to keep the API session logged in for a continuous process.">	
	<cfargument name="forceControlName" type="string" required="false" default="" hint="Field to override the element control name from the config.">
	<cfargument name="forceControlID" type="numeric" required="false" default="-1" hint="Field to override the element control name with the control ID.">
	
	<cfscript>
		// Hardcode the forceElementType to be a textblock
		arguments.forceElementType = "textblock";
		
		return variables.csContent.populateContent(argumentCollection=arguments);
	</cfscript>
</cffunction>

</cfcomponent>