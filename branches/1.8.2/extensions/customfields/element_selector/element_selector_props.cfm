<!--
	DEPRECATED DO NOT USE
	DEPRECATED DO NOT USE
	DEPRECATED DO NOT USE
	DEPRECATED DO NOT USE
	DEPRECATED DO NOT USE
-->

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
	PaperThin Inc.
Custom Field Type:
	Element Selector
Name:
	element_selector_props.cfm
Summary:
	
	DEPRECATED DO NOT USE
	
History:
	2011-01-30 - RLW - Created	
	2011-12-28 - MFC - Force JQuery to "noconflict" mode to resolve issues with CS 6.2.
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2014-09-19 - GAC - Removed deprecated doLabel and jsLabelUpdater js calls
	2014-09-23 - GAC - Added redirect CFINCLUDE to point to /element_selector_by_cs_url/element_selector_by_cs_url_props.cfm
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<!--- !! DEPRECATED DO NOT USE !! --->
<cfinclude template="/ADF/extensions/customfields/element_selector_by_cs_url/element_selector_by_cs_url_props.cfm">