<!---
/* *********************************************************************** */
Author:
	PaperThin, Inc.
	Samuel Smith
Name:
	force-login.cfm
Summary:
	This page is called when the user goes to a page that is protected. The user is presented with a login button that produces a login lightbox.
History:
	2012-07-17 - SFS - Created
	2014-12-17 - MLS - Updated - made adjustments to the update to force HTTPS. Adjusted to accomodate relative links.
--->

<!--- // Construct a local variable (u) used to switch a user to the secure version of a page. --->
<cfscript>
	// establish default values
	doRedirect = 0;
	protocol = "";
	svr = ""; 
	
	// only define protocol, svr variables if CGI.HTTP_REFERER contains a protocol, otherwise this is relative link
	if (Len(ListFirst(CGI.HTTP_REFERER,":")) gt 0)
	{
		protocol = ListFirst(CGI.HTTP_REFERER,":") & "://";
		svr = CGI.Server_Name;
	}
	
	// detect whether user got here via secure protocol
	if (cgi.https is not "on")
	{
		protocol = "https://";
		svr = CGI.Server_Name;
		doRedirect = 1;              // set flag to redirect to secure protocol
	}
	
	// create link to go to after logging in
	u = "#protocol##svr##CGI.SCRIPT_NAME#";
	if (Len(Trim(CGI.QUERY_STRING)))
		u = "#u#?#CGI.QUERY_STRING#"; // add any URL parameters
		
	session.user.requestTarget.targetURL = u;
</cfscript>

<!--- // If we have determined that we need to redirect the user, then do so. --->
<cfif doRedirect>
	<cflocation url="#u#" addtoken="no">
</cfif>

<!--- // Display the generic screen telling the user to login to this protected page and display a form button that produces a lightbox for logging in. --->
<cfoutput>
	<table align="center">
		<tr>
			<td align="center">A Login is required to access this page.<br>Please login now.</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td align="center">
				<CFMODULE TEMPLATE="/commonspot/security/login-buttons.cfm"
					LoginButtonCaption="Login"
					hideAutoLogin="1"
					hideChangePassword="0">
			</td>
		</tr>
	</table>
</cfoutput>