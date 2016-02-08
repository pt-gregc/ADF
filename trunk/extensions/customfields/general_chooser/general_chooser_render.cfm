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
	general chooser
Name:
	general_chooser_render.cfm
Summary:
	General Chooser field type.
	Allows for selection of the custom element records.
Version:
	1.2
History:
	2009-10-16 - MFC - Created
	2009-11-13 - MFC - Updated the Ajax calls to the CFC to call the controller 
						function.  This allows only the "controller" function to 
						listed in the proxy white list XML file.
	2010-11-09 - MFC - Updated the Scripts loading methods to dynamically load the latest 
						script versions from the Scripts Object.
	2011-03-20 - MFC - Updated component to simplify the customizations process and performance.
						Removed Ajax loading process.
	2011-03-27 - MFC - Updated for Add/Edit/Delete callback.
	2011-09-21 - RAK - Added max/min selections
	2011-10-20 - GAC - Added defualt value check for the minSelections and maxSelections xParams varaibles
	2012-01-04 - SS - The field now honors the "required" setting in Standard Options.
	2012-03-19 - MFC - Added "loadAvailable" option to set if the available selections load
						when the form loads.
					   Added the new records will load into the "selected" area when saved.
	2012-07-31 - MFC - Replaced the CFJS function for "ListLen" and "ListFindNoCase".
	2013-01-10 - MFC - Fixed issue with the to add the new records into the "selected" area when saved.
	2013-12-02 - GAC - Added a new callback function for the the edit/delete to reload the selected items after an edit or a delete
					 - Updated to allow 'ADD NEW' to be used multiple times before submit
	2013-12-10 - GAC - Added redirect CFINCLUDE to point to general_chooser/v1_2/general_chooser_1_2_render.cfm
--->
<cfinclude template="/ADF/extensions/customfields/general_chooser/v1_2/general_chooser_1_2_render.cfm">