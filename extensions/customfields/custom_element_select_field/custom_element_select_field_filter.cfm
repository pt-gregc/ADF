<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc.  Copyright (c) 2009-2016.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!-------------
Author: 	
	PaperThin, Inc. 
Name:
	$custom_element_select_field_filter.cfm
Summary:
	This module should be used for the ADF Custom Element Select field type.
	
	(See Summary comments in the specific version of the field_filter.cfm file for input/output parameters)						
History:
	2014-01-14 - TP - Created						
	2014-01-30 - GAC - Added redirect CFINCLUDE to point to custom_element_select_field/v1_1/custom_element_select_field_filter.cfm
--->
<cfset useCFTversion = "v1_1">
<cfinclude template="/ADF/extensions/customfields/custom_element_select_field/#useCFTversion#/custom_element_select_field_filter.cfm">