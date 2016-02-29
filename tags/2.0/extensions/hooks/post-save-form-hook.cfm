<!--- //
	post-save-form-hook.cfm
	
	This hook module is called after the saving any metadata form, custom element or simple form.

	Note: Copy this file to the root of current site.

History:
	2014-08-04 - GAC - Created
// --->

<!--- // Custom Element DataManager Field POST SAVE HOOK --->
<cfinclude template="/ADF/extensions/customfields/custom_element_datamanager/custom_element_datamanager_post-save-hook.cfm">

<!--- // Attempt to process the element that is being saved --->
<cfscript>
	enableLogging = false; 	// set to true for debug logging
	dumpLogFileName = "_post-save-form-hook.html";
	
	if ( enableLogging )
		application.ADF.utils.logAppend(msg=attributes, label='attributes', logfile=dumpLogFileName);
</cfscript>