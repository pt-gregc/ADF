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
Custom Field Type:
	Custom Element Select Field 
Name:
	customElementSelect_1_0.cfc
Summary:
	This is a pass-through for the base component for the Custom Element Select Field 
ADF Requirements:
	csData_2_0
	fields_1_0
History:
	2014-03-07 - GAC - Created
--->
<cfcomponent displayname="customElementSelect_1_0" extends="ADF.extensions.customfields.custom_element_select_field.custom_element_select_field_base" output="false"  hint="This is the base component for the Custom Element Data Manager field">

<cfproperty name="version" value="1_0_0">
<cfproperty name="type" value="transient">
<cfproperty name="wikiTitle" value="CustomElementSelect_1_0">

<!--- // This component is a pass-through component that allows for the custom_element_select_field_base.cfc to be part of the ADF as a LIB component --->
<!--- // - Global overrides can be achieved by copying this file to the  "_cs_apps/lib" folder ( "_cs_apps/lib/customElementSelect_1_0.cfc" and extending to this file )  --->

</cfcomponent>