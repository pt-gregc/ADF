<!---
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
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M Carroll 
Custom Field Type:
	general chooser
Name:
	general_chooser_props.cfm
Summary:
	General Chooser field type.
	Allows for selection of the custom element records.
Version:
	1.2
History:
	2009-05-29 - MFC - Created
	2011-03-20 - MFC - Updated component to simplify the customizations process and performance.
						Removed Ajax loading process.
	2011-09-21 - RAK - Added max/min selections
	2011-09-21 - RAK - Updated default values to load in an easier to configure manner
	2011-10-20 - GAC - Updated the descriptions for the minSelections and maxSelections fields
	2012-03-19 - MFC - Added "loadAvailable" option to set if the available selections load
						when the form loads.
	2013-11-21 - TP  - Fixed typos with props option descriptions
	2013-12-05 - GAC - Added standard CS text formatting to the props options 
	2013-12-10 - GAC - Added redirect CFINCLUDE to point to general_chooser/v1_2/general_chooser_1_2_props.cfm
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfinclude template="/ADF/extensions/customfields/general_chooser/v1_2/general_chooser_1_2_props.cfm">