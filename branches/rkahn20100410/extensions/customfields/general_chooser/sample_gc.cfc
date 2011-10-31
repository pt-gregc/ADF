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
--->
<cfcomponent name="sample_gc" extends="ADF.extensions.customfields.general_chooser.general_chooser">

<cfscript>
	// CUSTOM ELEMENT INFO
	variables.CUSTOM_ELEMENT = "";
	variables.CE_FIELD = "";
	variables.SEARCH_FIELDS = "";
	variables.ORDER_FIELD = "";
	
	// LAYOUT FLAGS
	variables.SHOW_SECTION1 = true;  // Boolean
	variables.SHOW_SECTION2 = true;  // Boolean
	
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
	
	// ADDITIONS
	variables.SHOW_ALL_LINK = true;  // Boolean
	variables.ADD_NEW_FLAG = false;	// Boolean
	variables.ADD_NEW_URL = "";
	variables.ADD_NEW_LB_WIDTH = 600;
	variables.ADD_NEW_LB_HEIGHT = 420;
</cfscript>

</cfcomponent>