<!--- //
pre-delete-formrecord-hook.cfm
	
	This hook module is called before a form record is deleted.
	
	- Attributes.PageID – The “data” pageID of the record being deleted
	- Attributes.FormID – The formID, custom Element ID, or metadata formID of the record being deleted
	
	Both of these can be lists, and Attributes.PageID can be -999.
	
	To abort delete actions, set the variable caller.continue = 0
// --->

<!--- // Attempt to process the element that is being saved --->
<cfscript>
	enableLogging = false; 	// set to true for debug logging
	dumpLogFileName = "_post-delete-formrecord-hook.html";
	
	if ( enableLogging ) 
		application.ADF.utils.logAppend(msg=attributes, label='attributes', logfile=dumpLogFileName);
</cfscript>