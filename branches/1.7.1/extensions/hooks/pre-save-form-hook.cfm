<!--- //
	pre-save-form-hook.cfm
	
	This hook module is called prior to saving any metadata form, custom element or simple form.
	
	Note: Copy to the root of your site.

History:
	2014-08-04 - GAC - Created
// --->

<cfscript>
	enableLogging = false; 	// set to true for debug logging
	dumpLogFileName = "pre-save-form-hook.html";
	
	if ( enableLogging )
		application.ADF.utils.logAppend(msg=attributes, label='attributes', logfile=dumpLogFileName);
	
</cfscript>