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
	scheduler_2_0.cfc
Summary:
	Scheduler component for the ADF
Version:
	2.0
History:
	2015-08-31 - GAC - Created
--->
<cfcomponent displayname="scheduler_2_0" extends="scheduler_1_0" hint="Scheduler component for the ADF">
	
<cfproperty name="version" value="2_0_0">
<cfproperty name="type" value="singleton">
<cfproperty name="scripts" type="dependency" injectedBean="scripts_2_0">
<cfproperty name="data" type="dependency" injectedBean="data_2_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_2_0">
<cfproperty name="wikiTitle" value="Scheduler_2_0">


</cfcomponent>