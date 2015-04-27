<!--- //
 	post-pagecreate.cfm

	This hook module is called after a page has been created. 
	
	Note: Copy this file to the root of current site or to a specific subsite.

History:
	2014-08-04 - GAC - Created
// --->

<cfscript>
	enableLogging = false; 	// set to true for debug logging
	dumpLogFileName = "_post-pagecreate.html";
	
	if ( enableLogging ) 
	{
		application.ADF.utils.logAppend(msg=attributes, label='attributes', logfile=dumpLogFileName);
		application.ADF.utils.logAppend(msg=Request.Page, label='Request.Page', logfile=dumpLogFileName);
	}
</cfscript>