<!--- //
post-approve.cfm

	This hook module is called after an Element is published during the approval process. 
	
	Note: Copy this file to the root of current site or to a specific subsite.

History:
	2014-08-04 - GAC - Created
// --->

<cfscript>
	enableLogging = false; 	// set to true for debug logging
	dumpLogFileName = "post-approve.html";
	
	if ( enableLogging )
		application.ADF.utils.logAppend(msg=attributes, label='attributes', logfile=dumpLogFileName);
</cfscript>