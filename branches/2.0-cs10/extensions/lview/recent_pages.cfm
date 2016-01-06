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
Name:
	recent_pages.cfm
Summary:

Version:
	1.0
History:
	2014-01-03 - GAC - Added comment headers
--->
<cfoutput><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:spry="http://ns.adobe.com/spry">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<meta http-equiv="pragma" content="no-cache" />
		<title>Community</title>
		<link href="/commonspot/dashboard/css/reset.css" rel="stylesheet" type="text/css" />
		<link href="/commonspot/dashboard/lview/css/lview-left.css" rel="stylesheet" type="text/css" id="lview_left_css" />
		<link href="/commonspot/javascript/lightbox/lightbox.css" type="text/css" rel="stylesheet" />
		<link href="/commonspot/dashboard/css/index.css" rel="stylesheet" type="text/css" />
		<!-- frame specific js file -->
		<script type="text/javascript" src="/commonspot/dashboard/lview/js/page-details.js"></script>

		<cfset searchDate = dateAdd("h", -2, now())>
		<cfquery name="getRecentAction" datasource="#request.site.datasource#">
			select ID, fileName, subsiteID, title
			from sitePages
			where dateContentLastModified > <cfqueryparam cfsqltype="cf_sql_varchar" value="#dateFormat(searchDate, 'yyyy-mm-dd')# #timeFormat(searchDate, 'hh:mm:ss')#">
			order by dateContentLastModified desc
		</cfquery>
	</head>
	<body>
		<h2>Recent Pages</h2>
		<ul>
		<cfloop query="getRecentAction">
			<li><a target="page_frame" onclick="openTemplate('#request.subsiteCache[getRecentAction.subsiteID].url##getRecentAction.fileName#');" href="javascript:;">#getRecentAction.title#</a></li>
		</cfloop>
		</ul>
	</body>
</html></cfoutput>