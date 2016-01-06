<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2016.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	handleFileDownload.cfm
Summary:
	This is a redirect file used with the the file_Uploader CFT					
History:
	2015-06-11 - GAC - Added redirect CFINCLUDE to point to /file_uploader/v3_0/handleFileUpload.cfm
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfset useCFTversion = "v3_0">
<cfinclude template="#useCFTversion#/handleFileDownload.cfm">

