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

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Custom Field Type:
	general chooser v2.1
Name:
	sample_2_1_gc.cfc
Summary:
	Sample General Chooser Property Component
History:
	2016-12-06 - GAC - Created
--->
<cfcomponent name="sample_2_1_gc" extends="ADF.extensions.customfields.general_chooser.general_chooser">

<cfscript>
	// CUSTOM ELEMENT INFO
	variables.CUSTOM_ELEMENT = "";
	variables.CE_FIELD = "";
	variables.SEARCH_FIELDS = "";
	variables.ORDER_FIELD = "";
	// Display Text for the Chooser Items ( Defaults to the ORDER_FIELD )
	//variables.DISPLAY_FIELD = "";

	// Item Display Thumbnail Image Field (If specified will render 2 DIVs in each drag & drop Item)
	variables.SELECT_ITEM_IMAGE_FIELD = "";
	
	// STYLES
	variables.MAIN_WIDTH = 580;
	variables.SECTION1_WIDTH = 270;
	variables.SECTION2_WIDTH = 270;
	variables.SECTION3_WIDTH = variables.MAIN_WIDTH;
	variables.SELECT_BOX_HEIGHT = 350;
	variables.SELECT_BOX_WIDTH = 250;
	variables.SELECT_ITEM_HEIGHT = 15;
	variables.SELECT_ITEM_WIDTH = 210;
	variables.SELECT_ITEM_CLASS = "ui-state-default";

	// Only used if SELECT_ITEM_IMAGE_FIELD has been assigned
	variables.SELECT_ITEM_IMAGE_HEIGHT = 30;
	variables.SELECT_ITEM_IMAGE_WIDTH = variables.SELECT_ITEM_IMAGE_HEIGHT;

	// Deprecated Setting - MOVED to the CFT props
	//variables.JQUERY_UI_THEME = "ui-lightness";
	
	// NEW VARIABLES for v1.1
	variables.SHOW_SEARCH = true;  					// Boolean
	variables.SHOW_ALL_LINK = true;  				// Boolean
	variables.SHOW_ADD_LINK = true;  				// Boolean
	variables.SHOW_EDIT_DELETE_LINKS = false;  	// Boolean
	
	// NEW VARIABLES for v1.2 for ADF 1.6.2+
	variables.AVAILABLE_LABEL = "Available Items";
	variables.SELECTED_LABEL = "Selected Items";
	variables.NEW_ITEM_LABEL = "Add New Item";
	variables.SHOW_EDIT_LINKS = false;  			// Boolean - SHOW_EDIT_DELETE_LINKS must be true to enable this option 
	variables.SHOW_DELETE_LINKS = false;  			// Boolean - SHOW_EDIT_DELETE_LINKS must be true to enable this option
</cfscript>

</cfcomponent>