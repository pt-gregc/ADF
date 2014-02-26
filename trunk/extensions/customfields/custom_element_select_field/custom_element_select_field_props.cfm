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
	M. Carroll
Custom Field Type:
	Custom Element Select Field
Name:
	custom_element_select_field_props.cfm
Summary:
	Custom Element select field to select the custom element fields for the
		option id and name values.
	Added Properties to set the field name value, default field value, and field visibility.
ADF Requirements:
	csData_2_0
	scripts_1_2
History:
	2009-07-06 - MFC - Created
	2010-09-17 - MFC - Updated the Default Value field to add [] to the value
						to make it evaluate a CF expression.
	2010-12-06 - RAK - Added the ability to define an active flag
						Added ability to dynamically build the display field - <firstName> <lastName>:At <email>
	2011-03-08 - MFC - Updated AJAX calls for bean "ceData_1_1".
	2011-04-20 - RAK - Added the ability to have a multiple select field and size it
	2011-05-04 - MFC - Updated JQuery functions to work with older JQuery versions.
	2011-06-23 - RAK - Added sortField option
	2011-06-23 - GAC - Added the addtional field descriptions to the display field and sort field options
					- Modified the "Other" option  from the displayFieldBuilder to be "--Other--" to make more visible and to avoid CE field name conflicts 
	2011-12-28 - MFC - Force JQuery to "noconflict" mode to resolve issues with CS 6.2.
	2013-09-27 - GAC - Added a renderSelectOption to allow the 'SELECT' text to be added or removed from the selection list
	2013-11-14 - GAC - Reorganized the props fields
	2013-11-15 - GAC - Converted the CFT to the ADF standard CFT format using the defaultValues struct to build the current values
					 - Updated AJAX calls to use the "ceData_2_0" lib using a ajaxCEDataBean variable
	2013-11-20 - TP  - Added a isBoolean check to the multipleSelect and the renderSelectOption logic
	2013-12-05 - GAC - Added standard CS text formatting to the props options 
	2014-01-02 - GAC - Updated the props option descriptions
					 - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2014-01-17 - TP  - Aded the abiltiy to render checkboxes, radio buttons as well as a selection list
	2014-01-30 - GAC - Added redirect CFINCLUDE to point to custom_element_select_field/v1_1/custom_element_select_field_props.cfm
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfset useCFTversion = "v1_1">
<cfinclude template="/ADF/extensions/customfields/custom_element_select_field/#useCFTversion#/custom_element_select_field_props.cfm">