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
	csData_2_0.cfc
Summary:
	CommonSpot Data Utils functions for the ADF Library
Version:
	2.0
History:
	2015-01-08 - GAC - Created - New v2.0	
--->
<cfcomponent displayname="csData_2_0" extends="csData_1_3" hint="CommonSpot Data Utils functions for the ADF Library">

<cfproperty name="version" value="2_0_0">
<cfproperty name="type" value="singleton">
<cfproperty name="data" type="dependency" injectedBean="data_2_0">
<cfproperty name="taxonomy" type="dependency" injectedBean="taxonomy_2_0">
<cfproperty name="wikiTitle" value="CSData_2_0">

</cfcomponent>