<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2010.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!--- ADF INITIALIZATION CODE BLOCK : 2010-08-26 --->
<!--- 
	History:
		2010-03-03 - MFC - Created
		2010-08-26 - MFC - Changed "isDefined" to "LEN"
 --->
<!--- CFLOCK to prevent multiple ADF resets --->
<CFTRY>
  <CFLOCK timeout="30" type="exclusive" name="ADF-RESET">
  	<cfscript>
  		// Validation for the user is logged in
  		if ( request.user.id GT 0 ) { userValidated = true; } else { userValidated = false; }
  		// Check if the ADF exists in Server space OR manual reset AND the user is logged in.
  		if ( (NOT StructKeyExists(server, "ADF")) OR ((StructKeyExists(url,"resetServerADF") OR StructKeyExists(url,"resetADF")) AND (userValidated)) )
  			CreateObject("component","ADF.core.Core").init();
  		// Initialize the ADF for the site AND the user is logged in.
  		if ( (NOT StructKeyExists(application, "ADF")) OR ((StructKeyExists(url,"resetSiteADF") OR StructKeyExists(url,"resetADF")) AND (userValidated)) )
  			CreateObject("component","#request.site.name#._cs_apps.ADF").init();
  		// Check if a variable has been defined to dump
  		if ( StructKeyExists(url,"ADFDumpVar") AND (userValidated) ) {
  			// Verify if the ADF dump var exists
  			// [MFC] - Changed "isDefined" to "LEN"
  			if ( LEN(url.ADFDumpVar) GT 0 )
  				CreateObject("component","ADF.lib.utils.Utils_1_0").dodump(evaluate(url.ADFDumpVar), #url.ADFDumpVar#, false);
  			else
  				WriteOutput("<strong>ADFDumpVar Failed</strong> : Variable '#url.ADFDumpVar#' does not exist.");
  		}
  		// ADF Reset Notifications
  		if ( ((structKeyExists(url,"resetServerADF")) OR ((structKeyExists(url,"resetSiteADF")))) AND (NOT userValidated) ) {
  			WriteOutput("<p><strong>ADF was NOT Reset! You are NOT logged in.</strong></p>");
  		} else if ( ((structKeyExists(url,"resetServerADF")) OR ((structKeyExists(url,"resetSiteADF"))) OR StructKeyExists(url,"resetADF")) AND (userValidated) ) {
  			WriteOutput("<p><strong>ADF has been Reset!</strong> - " & LSDateFormat(Now(),'short') & " @ " & LSTimeFormat(Now(),'short') & "</p>" );
  		}
  	</cfscript>
  </CFLOCK>
<CFCATCH>
	<!--- Check that the user is validated --->
	<cfif userValidated>
		<cfoutput><p>Error building the ADF.</p></cfoutput>
	</cfif>
	
	<cfsavecontent variable="dump">
		<!--- Dump the cfcatch --->
		<cfdump var="#cfcatch#" label="cfcatch" expand="false">
		
		<!--- Dump the server.ADF --->
		<cfif NOT StructKeyExists(server, "ADF")>
			<cfoutput><p>server.ADF Does not exist.</p></cfoutput>
		<cfelse>
			<cfdump var="#server.ADF#" label="server.ADF" expand="false">
		</cfif>
		
		<!--- Dump the application.ADF --->
		<cfif NOT StructKeyExists(application, "ADF")>
			<cfoutput><p>application.ADF Does not exist.</p></cfoutput>
		<cfelse>
			<cfdump var="#application.ADF#" label="application.ADF" expand="false">
		</cfif>
	</cfsavecontent>
	
	<!--- Log the error content --->
	<cfset logFileName = dateFormat(now(), "yyyymmdd") & "." & request.site.name & ".ADF_Load_Errors.htm">
	<cffile action="append" file="#request.cp.commonSpotDir#logs/#logFileName#" output="#request.formattedtimestamp# - #dump#" addnewline="true">
	
</CFCATCH>
</CFTRY>