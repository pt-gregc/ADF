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