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
	ccapi.cfc
Summary:
	CCAPI functions for the ADF Library
Version:
	1.0.1
History:
	2011-03-20 - RLW - Created
	2011-06-27 - RAK - Stripped out ALL changes because they were defunct
--->
<cfcomponent displayname="ccapi_1_1" extends="ADF.lib.ccapi.ccapi_1_0" hint="CCAPI functions for the ADF Library">
<cfproperty name="version" value="1_0_1">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_1">
<cfproperty name="ceData" type="dependency" injectedBean="ceData_1_1">
<cfproperty name="csData" type="dependency" injectedBean="csData_1_1">
<cfproperty name="forms" type="dependency" injectedBean="forms_1_1">
<cfproperty name="scripts" type="dependency" injectedBean="scripts_1_1">
<cfproperty name="wikiTitle" value="CCAPI">


</cfcomponent>