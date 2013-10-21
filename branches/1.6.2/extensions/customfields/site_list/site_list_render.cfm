<!--
	DEPRECATED DO NOT USE
	DEPRECATED DO NOT USE
	DEPRECATED DO NOT USE
	DEPRECATED DO NOT USE
	DEPRECATED DO NOT USE
--->
<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the Starter App directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2013.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin Inc.
Name:
	site_list_render.cfm
Summary:

	DEPRECATED DO NOT USE

Version:
	1.0.0
History:
	2012-04-11 - GAC - Added the fieldPermission parameter to the wrapFieldHTML function call
					 - Added the includeLabel and includeDescription parameters to the wrapFieldHTML function call
					 - Added readOnly field security code with the cs6 fieldPermission parameter
					 - Updated the wrapFieldHTML explanation comment block
					 - Fixed an issue in the query loop by changing the output variable from ID to siteID
	2012-04-12 - GAC - Added redirect CFINCLUDE to point to /cs_site_select/cs_site_select_render.cfm
--->
<cfinclude template="/ADF/extensions/customfields/cs_site_select/cs_site_select_render.cfm">
