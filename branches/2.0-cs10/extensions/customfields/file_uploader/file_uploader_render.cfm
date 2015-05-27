<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the Starter App directory

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
	Ryan Kahn
Name:
	file_Upload_Render.cfm
Summary:
	Renders the file upload form
History:
	2011-08-05 - RAK - Created
	2011-08-05 - RAK - Fixed issue where the file uploader would try to generate images for non-pdf files.
	2012-01-03 - GAC - Moved the the hidden field code inside the TD tag
	2015-05-26 - DJM - Added redirect CFINCLUDE to point to file_uploader/v3/file_uploader_render.cfm
--->
<cfinclude template="/ADF/extensions/customfields/file_uploader/v3/file_uploader_render.cfm">