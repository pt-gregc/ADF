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
/* *********************************************************************** */
Author:
	PaperThin, Inc.
Name:
	pre-save-form-hook.cfm
Summary:
	Runs code before a custom element record is saved
History:
	2015-04-17 - SU/SFS - Created
	2015-04-22 - GAC - Added cfinclude for the ADF Object List Builder custom field type
--->

<!--- // Object List Builder PRE SAVE FORM HOOK --->
<cfinclude template="/ADF/extensions/customfields/object_list_builder/object_list_builder_pre_save_hook.cfm">
