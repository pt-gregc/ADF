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
	custom_element_select_field_render.cfm
Summary:
	Custom Element select field to select the custom element fields for the
		option id and name values.
	Added Properties to set the field name value, default field value, and field visibility.
ADF Requirements:
	csData_2_0
	scripts_1_2
	forms_1_1
History:
	2009-10-28 - MFC - Created
	2009-12-23 - MFC - Resolved error with loading the current value selected.
	2010-03-10 - MFC - Updated function call to ADF lib to reference application.ADF.
						Updated cedata statement to remove filter and get all records.
	2010-06-10 - MFC - Update to sort the CEDataArray at the start.
	2010-09-17 - MFC - Updated the Default Value field to add [] to the value 
						to make it evaluate a CF expression.
	2010-11-22 - MFC - Updated the loadJQuery call to remove the jquery version param.
						Removed commented out cfdump.
	2010-12-06 - RAK - Added the ability to define an active flag
						Added ability to dynamically build the display field - <firstName> <lastName>:At <email>
	2011-01-06 - RAK - Added error catching on evaluate failure.
	2011-02-08 - RAK - Added the class to the select from the props file for javascript interaction.
	2011-04-20 - RAK - Added the ability to have a multiple select field
	2011-06-23 - RAK - Added sortField option
	2011-06-23 - GAC - Added the the conditional logic for the sortField option 
					- Modified the "Other" option  from the displayFieldBuilder to be "--Other--" to make more visible and to avoid CE field name conflicts 
					- Added code to display the Description text 
	2013-02-20 - MFC - Replaced Jquery "$" references.
	2013-09-27 - GAC - Added a renderSelectOption to allow the 'SELECT' text to be added or removed from the selection list
	2013-11-14 - DJM - Added the fieldpermission variable for read only field 
    				 - Moved the Field to Data Mask code out to an new ADF from_1_1 function
	2013-11-14 - GAC - Updated the selected value to be an empty string if the stored value or the default value does not match available records from the bound element
	2013-11-15 - GAC - Converted the CFT to the ADF standard CFT format using the forms.wrapFieldHTML method
	2014-01-17 - TP  - Added the abiltiy to render checkboxes, radio buttons as well as a selection list
	2014-01-30 - GAC - Added redirect CFINCLUDE to point to custom_element_select_field/v1_1/custom_element_select_field_render.cfm
--->
<cfset useCFTversion = "v1_1">
<cfinclude template="/ADF/extensions/customfields/custom_element_select_field/#useCFTversion#/custom_element_select_field_render.cfm">

