/*
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
*/

/*  
 *************************************************************** 
Author: 	
	PaperThin, Inc. 
Name:
	forms_2_0.cfc
Summary:
	Date Utils functions for the ADF Library
Version:
	2.0
History:
	2015-09-10 - GAC - Created
*/
component displayname="forms_2_0" extends="forms_1_1" hint="Forms Utils functions for the ADF Library"
{
	property name="version" value="2_0_0";
	property name="type" value="transient";
	property name="ceData" injectedBean="ceData_3_0" type="dependency";
	property name="scripts" injectedBean="scripts_2_0" type="dependency";
	property name="ui" injectedBean="ui_2_0" type="dependency";
	property name="fields" injectedBean="fields_2_0" type="dependency";
	property name="wikiTitle" value="Forms_2_0";	
}