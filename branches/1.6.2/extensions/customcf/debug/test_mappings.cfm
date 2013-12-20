<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2013.
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
	mappings.cfm
Summary:
	A simple output page to test if the server and cf mappings for the '/ADF' are setup correctly
History:
	2009-06-11 - GAC - Created
	2011-02-09 - GAC - Removed self-closing CF tag slashes
Directions: 
	Call this file directly from a browser using the following URL replacing {domainname} with your site's domain or IP:
	http://{domainname}/ADF/extensions/customcf/debug/test_mappings.cfm 
--->

<cfoutput><br /><strong>Success:</strong> The Web server mapping (or virutal directory) for '/ADF' is working correctly!<br /></cfoutput>
<cfflush>

<cfset testVar = StructNew()>

<cftry>
	<cfset testVar.cfmapping = CreateObject("component","ADF.extensions.customcf.debug.test_mappings").verifyMapping()>
	<cfcatch>
		<cfset testVar.cfmapping = false>
	</cfcatch>
</cftry>

<cfif StructKeyExists(testVar,"cfmapping") AND testVar.cfmapping IS true>
	<cfoutput><br /><strong>Success:</strong> The CF Mapping for '/ADF' is working correctly!<br /></cfoutput>
<cfelse>
	<cfoutput><br /><strong>FAIL:</strong> The CF Mapping for '/ADF' <strong>NOT</strong> configured correctly!<br /></cfoutput>
</cfif>
<cfflush>