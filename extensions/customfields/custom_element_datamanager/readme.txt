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
	Custom Element DataManager 
Name:
	readme.txt
Summary:
	This the readme file for the Custom Element Data Manager field
History:
	2013-11-14 - GAC - Created
--->

1) Install the Custom Element DataManager Field 
	- Import the Custom-Element-Data-Manager-Custom-Field-Type.zip file via the CommonSpot Site Admin 'Elements & Forms > Field Types and Masks'

2) Copy the 'post-save-form-hook.cfm' file from the '/ADF/extensions/customfields/custom_element_datamanager/site-files/' directory to the root of your site.
	- If you already have a 'post-save-form-hook.cfm' file in the root of your site DO NOT overwrite it. 
		There may be override fuctions and/or custom code in that site level version of this file.
		Copy the <cfinclude> code from the Custom Element DataManager's 
		/custom_element_datamanager/site-files/post-save-form-hook.cfm file
		into your sites existing post-save-form-hook.cfm file.
			
3) Restart CF or Reset ADF 
	-  If you already had a post-save-form-hook.cfm file in place in your site root then 
	   only an ADF reset '?resetADF=1' is required and a CF restart would NOT be needed.
	   
