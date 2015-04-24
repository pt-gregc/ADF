<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!---
/* ***************************************************************
/*
Author:
	PaperThin Inc.
	M. Carroll
Name:
	Import Custom Element
Summary:
	Script to process the importing of a Custom Element from an datasource outside
		of CommmonSpot
Version:
	1.0
History:
	2009-10-21 - MFC - Created
--->
<cfsetting requesttimeout="10000">

<cfscript>
	if ( NOT StructKeyExists(request.params, "action") )
		request.params.action = "form";
</cfscript>

<cfif request.params.action EQ "form">
	<cfoutput>
		<form action="#cgi.script_name#" method="post" name="profileProcess" id="profileProcess">
			<input type="hidden" name="action" id="action" value="process">
			
			<p>
				Select the Custom Element to Import:
				<select name="importCE" id="importCE">
					<option value=""> - Select Custom Element - 
					<option value="MY_CUSTOM_ELEMENT">MY_CUSTOM_ELEMENT
				</select>
			</p>
			<p>
				Number of Records to Import:
				<input type="text" name="count" id="count" size="5" value="10">
			</p>
			<p>
				Continuous Processing:
				<input type="checkbox" name="cont" id="cont" value="1" checked="true">
			</p>
			<p>
				Minutes to Pause:
				<input type="text" name="pause" id="pause" size="5" value="5">
			</p>
			<p>
				Restart Processing:
				<input type="checkbox" name="restart" id="restart" value="1">
			</p>
			<p>
				Restart at Postion:
				<input type="text" name="start" id="start" size="5" value="1">
			</p>
			<p>
				<input type="submit" value="Start Process">
			</p>
		</form>
	</cfoutput>

<cfelseif request.params.action EQ "process">
	<cfscript>
		// Check the count
		if ( NOT StructKeyExists(request.params, "count") )
			request.params.count = 1;
		// Check the pause count
		if ( NOT StructKeyExists(request.params, "pause") )
			request.params.pause = 5;
		// Check if continuous scheduled process
		if ( NOT StructKeyExists(request.params, "cont") )
			request.params.cont = false;
		// Check if continuous scheduled process
		if ( NOT StructKeyExists(request.params, "restart") )
			request.params.restart = false;
		// Check if restart position
		if ( NOT StructKeyExists(request.params, "start") OR ( request.params.start LTE 0 ) )
			request.params.start = 0;
		// Check if restart is checked
		if ( NOT request.params.restart )
			request.params.start = 0;
			
		// Start the processing
		application.ADF.importCE.controller(ceName=request.params.importCE, 
												restart=request.params.restart,
						    					passCount=request.params.count,
						    					scheduleProcess=request.params.cont,
						    					delayMinutes=request.params.pause,
						    					startAt=request.params.start);
	</cfscript>
	<cfoutput>
		Process Completed<br /><br />
		<a href="#cgi.script_name#?action=form">Return to the Form</a>
		<br /><br />
	</cfoutput>
<cfelse>
	<cfoutput>
		An error with your request.<br /><br />
		<a href="#cgi.script_name#?action=form">Please try again</a>
		<br /><br />
	</cfoutput>
</cfif>


