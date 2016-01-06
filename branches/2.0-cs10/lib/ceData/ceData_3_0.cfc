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
	ceData_3_0.cfc
Summary:
	Custom Element Data functions for the ADF Library
Version
	2.1
History:
	2015-08-31 - GAC - Created
--->
<cfcomponent displayname="ceData_3_0" extends="ceData_2_0" hint="Custom Element Data functions for the ADF Library">

<cfproperty name="version" value="3_0_0">
<cfproperty name="type" value="singleton">
<cfproperty name="data" type="dependency" injectedBean="data_2_0">
<cfproperty name="wikiTitle" value="CEData_3_0">

<cfscript>
	variables.SQLViewNameADFVersion = "2.0"; 
</cfscript>

</cfcomponent>