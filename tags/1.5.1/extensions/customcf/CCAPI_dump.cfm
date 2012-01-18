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
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
Name:
	ccapi_dump.cfm
Summary:
	A page that test access to the CCAPI by attempting to login to CommonSpot using the CCAPI webservice call
History:
	2009-06-9 - MFC - Created
--->

<!--- // Use this file to test to see if the CS is allowing a user to login to the CCAPI web service --->

<!--- // Set your access variables  --->
<cfset variables.userid = "admin-commonspot">
<cfset variables.password = "adminpassword">
<cfset variables.webserviceURL = "http://#Request.CGIVars.HTTP_HOST#/commonspot/webservice/cs_service.cfc?wsdl">
<cfset variables.site = "#request.site.url#">

<!--- // create Web service object --->
<cfobject webservice="#webserviceURL#" name="ws">

<!--- // invoke the login API call --->
<cfinvoke webservice ="#ws#"
	method ="cslogin"
	site = "#site#"
	csuserid="#userid#"
	cspassword="#password#"
	subsiteid="1"
	subsiteurl=""
	returnVariable="foo">

<!--- //Output the results --->
<cfdump var="#foo#">