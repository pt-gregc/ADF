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
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
Name:
	adf_dump.cfm
Summary:
	A page that outputs ADF object to verify the ADF is configured correctly

History:
	2009-06-4 - GAC - Created
	2010-08-12 - GAC - Modified
	2014-10-08 - GAC - Removed version declarations from the loadJQuery and loadJQueryUI calls
--->

<cfoutput>
<br />
<div id="manageConfigResetLink"><a href="#CGI.SCRIPT_NAME#?resetServerADF=1&resetSiteADF=1" title="Reset ADF / App Configuration" class="CS_DataSheet_Data_Cell_Action">Reset ADF</a></div>
<br />
</cfoutput>

<!--- // Output Core ADF objects in the Server scope   --->
<cfif StructKeyExists(Server,"ADF")>
	<cfdump var="#server.ADF#" label="server.ADF" expand="no">
<cfelse>
	<cfoutput>server.ADF is NOT Defined!<br /></cfoutput>
</cfif>

<!--- // Output Core ADF objects in the Application scope  --->
<cfif StructKeyExists(application,"ADF")>
	<cfdump var="#application.ADF#" label="application.ADF" expand="no">
	
	<!--- // Output ADF lib objects  --->
	<!--- <cfdump var="#application.ADF.utils#" label="application.ADF.utils" expand="no"> --->
	
	<!--- // Direct ADF lib method calls  --->
	<!--- <cfscript>
		application.ADF.scripts.loadJQuery();
		application.ADF.scripts.loadJQueryUI();
	</cfscript> --->
	
<cfelse>
	<cfoutput>application.ADF is NOT Defined!<br /></cfoutput>
</cfif>

<!--- // Output ADF App specific objects in the Application scope  --->
<cfif StructKeyExists(application,"ptProfile")>
	<cfdump var="#application.ptProfile#" label="application.ptProfile" expand="no">
<cfelse>
	<cfoutput>application.ptProfile is NOT Defined!<br /></cfoutput>
</cfif>