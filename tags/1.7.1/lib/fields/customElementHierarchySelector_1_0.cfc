<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
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
	Custom Element Hierarchy Selector
Name:
	customElementHierarchySelector_1_0.cfc
Summary:
	This is a pass-through for the base component for the Custom Element Hierarchy Selector field
ADF Requirements:
	
History:
	2014-01-27 - GAC - Created
--->
<cfcomponent displayname="customElementHierarchySelector_1_0" extends="ADF.extensions.customfields.custom_element_hierarchy_selector.custom_element_hierarchy_selector_base" output="false"  hint="This is the base component for the Custom Element Hierarchy Selector field">

<cfproperty name="version" value="1_0_0">
<cfproperty name="type" value="transient">
<cfproperty name="wikiTitle" value="CustomElementHierarchySelector_1_0">

<!--- // This component is a pass-through component that allows for the custom_element_hierarchy_selector_base.cfc to be part of the ADF as a LIB component --->
<!--- // - Global overrides can be achieved by copying this file to the  "_cs_apps/lib" folder ( "_cs_apps/lib/customElementHierarchySelector_1_0.cfc" and extending to this file )  --->

</cfcomponent>