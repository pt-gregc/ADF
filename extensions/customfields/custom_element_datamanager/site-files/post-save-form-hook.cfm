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
/* *********************************************************************** */
Author:
	PaperThin, Inc.
Name:
	post-save-form-hook.cfm
Summary:
	Runs code after a custom element from is saved
History:
	2013-11-14 - DJM - Created
	2013-11-15 - GAC - Added cfinclude for the ADF Custom Element DataManager custom field type
--->

<!--- // Custom Element DataManager POST SAVE HOOK --->
<cfinclude template="/ADF/extensions/customfields/custom_element_datamanager/custom_element_datamanager_post-save-hook.cfm">
