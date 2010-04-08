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
	adf_dump.cfm
Summary:
	A page that outputs ADF object to verify the ADF is configured correctly

History:
	2009-06-4 - GAC - Created
--->

<cfoutput>
<br />
<div id="manageConfigResetLink"><a href="#CGI.SCRIPT_NAME#?resetServerADF=1&resetSiteADF=1" title="Reset ADF / App Configuration" class="CS_DataSheet_Data_Cell_Action">Reset ADF</a></div>
<br />
</cfoutput>

<!--- // Output Core ADF objects in the Server scope   --->
<cfif IsDefined("Server.ADF")>
	<cfdump var="#Server.ADF#" label="Server.ADF" expand="no">
<cfelse>
	<cfoutput>Server.ADF is NOT Defined!<br /></cfoutput>
</cfif>

<!--- // Output Core ADF objects in the Application scope  --->
<cfif IsDefined("Application.ADF")>
	<cfdump var="#Application.ADF#" label="Application.ADF" expand="no">
<cfelse>
	<cfoutput>Application.ADF is NOT Defined!<br /></cfoutput>
</cfif>

<!--- // Output ADF lib objects  --->
<!--- <cfdump var="#Application.ADF.utils#" label="Application.ADF.utils" expand="no"> --->

<!--- // Output App specific objects  --->
<!--- <cfdump var="#Application.ptProfile#" label="Application.ptProfile" expand="no">  --->

<!--- // Direct ADF lib method calls  --->
<!--- <cfscript>
	Application.ADF.scripts.loadJQuery('1.3.2');
	Application.ADF.scripts.loadJQueryUI('1.7.1');
</cfscript> --->