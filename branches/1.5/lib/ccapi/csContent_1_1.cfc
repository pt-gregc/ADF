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
	csContent_1_1.cfc
Summary:
	CCAPI Content functions for the ADF Library
Version:
	1.0.1
History:
	2011-03-20 - RLW - Created
--->
<cfcomponent displayname="csContent_1_1" hint="Constructs a CCAPI instance and then allows you to populate Custom Elements and Textblocks" extends="csContent_1_0">
<cfproperty name="version" value="1_0_1">
<cfproperty name="type" value="transient">
<cfproperty name="ccapi" type="dependency" injectedBean="ccapi_1_1">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_0">
<cfproperty name="wikiTitle" value="CSContent_1_0">

</cfcomponent>