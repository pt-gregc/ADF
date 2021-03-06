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
	ADF INITIALIZATION CODE BLOCK
Summary:
	Called from the site 'custom-application' to load the ADF and handle the ADF reset.
History:
	2010-03-03 - MFC - Created
	2010-08-26 - MFC - Changed "isDefined" to "LEN"
	2010-10-29 - RAK - Refactored whole file to use /ADF/core/Core.cfc's Reset function
	2010-12-20 - MFC - Added check at top to verify if ADF space exists in the SERVER and APPLICATION.
						Removed IF to only run all the reset code when a user is logged in.
	2011-31-01 - RAK - Updating so force reset doesnt notify the user.
	2011-06-02 - RAK - Added * to end of regular expression so it would validate input on the entire string not just the first character
	2012-01-10 - MFC - Added span tag with ID around the reset message.
	2012-07-02 - MFC - Added lock around the entire ADF reset processing. Prevents errors on server restarts.
	2013-01-23 - MFC - Increased the CFLOCK timeout to "300".
	2013-01-24 - MFC - Setup the "Session.ADF" space if it doesn't exist for the users session
	2013-12-05 - GAC - Removed the login check logic from around URL resetADF checks to allow the not logged in message to display (when not a forced Reset) and the user is not logged in 
	2014-05-27 - GAC - Added a ADFdumpVar processing method call to help with securing the rendered output
					 - Added the ADF and fileVersion local variables
					 - Added the label to simple value dumps
	2015-03-20 - SFS - Added inline style to resolve display issue with Railo 4.2.1 and a site that is using Bootstrap in its site design
	2015-04-22 - GAC - Updated logic for Railo/Bootstrap ADFDumpVar fix  
					 - Added a 'Railo' check before adding the ADFDumpVar fix
	2015-08-19 - GAC - Switched the 'Railo' check for the ADFDumpVar to be a NOT ACF check (thanks lucee!!)
	2015-09-24 - GAC - Added installADF and reinstallADF URL parameters to handle the new ADF install processes
	2015-11-25 - GAC - Removed the double LOCK around the ADF load/reset process
	2016-02-02 - GAC - Added configADF and reconfigADF as options to trigger the ADF install process (which right just registers scripts in CS10)
--->
<cfscript>
	adfVersion = "2.0.0";
	adfFileVersion = "19"; 
		
	// Initialize the RESET TYPE variable
	// Determine what kind of reset is needed (if any)
	adfResetType = "";
	force = false;
	
	// Check if the ADF space exists in the SERVER and APPLICATION
	if ( NOT StructKeyExists(server, "ADF") ) 
	{
		adfResetType = "ALL";
		force = true;
	} 
	else if ( NOT StructKeyExists(application, "ADF") ) 
	{
		force = true;
		adfResetType = "SITE";
	}
		
	// Setup the "Session.ADF" space if it doesn't exist for the users session
	if ( NOT StructKeyExists(session, "ADF") )
		session.ADF = StructNew();
</cfscript>
	
<!--- // Check if the user is logged in run the reset commands --->
<cfscript>
	// Command to reset the entire ADF
	if( StructKeyExists(url,"resetADF") ) 
		adfResetType = "ALL";
	else 
	{
		// Check the SERVER or SITE reset commands
		if ( StructKeyExists(url,"resetServerADF") and StructKeyExists(url,"resetSiteADF") )
			adfResetType = "ALL";
		else if ( StructKeyExists(url,"resetServerADF") )
			adfResetType = "SERVER";
		else if ( StructKeyExists(url,"resetSiteADF") )
			adfResetType = "SITE";
		// Check the ADF Installer commands
		else if ( StructKeyExists(url,"installADF") OR StructKeyExists(url,"configADF") )
			adfResetType = "CONFIGURE";
		else if ( StructKeyExists(url,"reinstallADF") OR StructKeyExists(url,"reconfigADF") )
			adfResetType = "RECONFIGURE";
	}
</cfscript>

<!--- // Run the RESET command --->
<cfif Len(adfResetType) gt 0>
	<cfscript>
		adfCore = createObject("component", "ADF.core.Core");
		resetResults = adfCore.reset(adfResetType);
	</cfscript>
	
	<cfoutput>
		<cfif !force>
			<!--- // 2012-01-10 - MFC - Added span tag with ID around the reset message. --->
			<!--- // 2014-01-08 - DRM - Moved msg to cfhtmlhead, otherwise it's before doctype tag, browser reverts to quirks mode, can look funny --->
			<cfhtmlhead text="<span id='ADF-Reset-Message'><b>#resetResults.message#</b></span>">
		</cfif>
	</cfoutput>
</cfif>
	
<!--- // Check if the user is logged in run the ADF DUMP VAR command --->
<cfif request.user.id gt 0>
	<!--- // The following is unchanged during the 2010-10-29 refractor --->
	<cfscript>
		adfDumpMsg = "";
		if ( StructKeyExists(url,"ADFDumpVar")) 
		{
			// Set the cfmlEngine type
			cfmlEngine = server.coldfusion.productname;
			/* [SFS] - 2015-03-20 - Added inline style to resolve display issue with Railo 4.2.1 and a site that is using Bootstrap in its site design */
			if ( !FindNoCase(cfmlEngine,'ColdFusion Server') )
				adfDumpMsg = "<style>.label{color:##000000;display:table-cell;font-size:11px;font-weight:normal;}</style>";
			// Verify if the ADF dump var exists
			// [MFC] - Changed "isDefined" to "LEN"
			// [RAK] - 2010-11-01 - Fixing security issue with cfscript code being passed into the evaluate from any logged in user
			// [RAK] - 2011-06-02 - Added * to end of regular expression because it was only validating the first character instead of every character in the string
			// [DRM] = 2014-01-08 - Moved msg to cfhtmlhead, same reasoning as with reset msg above
			//Anything that is not a-z or 0-9 or '.' or '[' or ']'
			regularExpression = '[^a-z0-9\.\[\]]]*';
			if ( Len(url.ADFDumpVar) GT 0 and !ReFindNoCase(regularExpression,url.ADFDumpVar) ) 
			{
                // [GAC] 2016-01-04 - Check to see if we need to render UDFs in the ADFDumpVar dump
				if ( !StructKeyExists(url,"showUDFs") )
                    url.showUDFs = 0; // Set to false by default
					
                utilsObj = CreateObject("component","ADF.lib.utils.utils_2_0");
				// [GAC] 2014-05-27 - Added a security fix for the ADF dump var command
				adfDumpVarData = utilsObj.processADFDumpVar(dumpVarStr=url.ADFDumpVar,sanitize=true);
				// [GAC] 2014-05-27 - Dump the processed ADFdumpVar data 
				if ( IsSimpleValue(adfDumpVarData) )
					adfDumpMsg = adfDumpMsg & utilsObj.dodump(adfDumpVarData, url.ADFDumpVar, true, true);
				else
					adfDumpMsg = adfDumpMsg & utilsObj.dodump(adfDumpVarData, url.ADFDumpVar, false, true, url.showUDFs);
			}
			else 
			{
				// 2012-01-10 - MFC - Added span tag with ID around the reset message.
				adfDumpMsg = "<span id='ADF-Reset-Message'><strong>ADFDumpVar Failed</strong> : Variable '#url.ADFDumpVar#' does not exist.</span>";
			}
		}
	</cfscript>
	
	<cfif adfDumpMsg neq "">
		<cfhtmlhead text="#adfDumpMsg#">
	</cfif>
</cfif>
