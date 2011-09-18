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
	M Carroll 
Custom Field Type:
	sample_gc.cfc
Name:
	sample_gc.cfc
Summary:
	Sample General Chooser Property Component
History:
	2010-06-21 - MFC - Created
	2011-03-20 - MFC - Updated component to simplify the customizations process and performance.
						Removed Ajax loading process.
--->
<cfcomponent name="sample_gc" extends="ADF.extensions.customfields.general_chooser.v2.general_chooser">

<cfscript>
	// CUSTOM ELEMENT INFO
	variables.CUSTOM_ELEMENT = "";
	variables.CE_FIELD = "";
	variables.SEARCH_FIELDS = "";
	variables.ORDER_FIELD = "";
	
	// STYLES
	variables.MAIN_WIDTH = 580;
	variables.SECTION1_WIDTH = 270;
	variables.SECTION2_WIDTH = 270;
	variables.SECTION3_WIDTH = 580;
	variables.SELECT_BOX_HEIGHT = 350;
	variables.SELECT_BOX_WIDTH = 250;
	variables.SELECT_ITEM_HEIGHT = 15;
	variables.SELECT_ITEM_WIDTH = 210;
	variables.SELECT_ITEM_CLASS = "ui-state-default";
	variables.JQUERY_UI_THEME = "ui-lightness";
	
	// NEW VARIABLES v1.1
	variables.SHOW_SEARCH = true;  // Boolean
	variables.SHOW_ALL_LINK = true;  // Boolean
	variables.SHOW_ADD_LINK = true;  // Boolean
</cfscript>

</cfcomponent>