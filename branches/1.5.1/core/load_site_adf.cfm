<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2011.
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
		2010-10-29 - RAK - Refactored whole file to use /ADF/core/Core.cfc's Reset function
		2010-12-20 - MFC - Added check at top to verify if ADF space exists in the SERVER and APPLICATION.
							Removed IF to only run all the reset code when a user is logged in.
		2011-31-01 - RAK - Updating so force reset doesnt notify the user.
		2011-06-02 - RAK - Added * to end of regular expression so it would validate input on the entire string not just the first character
		2012-01-10 - MFC - Added span tag with ID around the reset message.
 --->
<cfscript>
	// Initialize the RESET TYPE variable
	// Determine what kind of reset is needed (if any)
	adfResetType = "";
	force = false;
	// Check if the ADF space exists in the SERVER and APPLICATION
	if ( NOT StructKeyExists(server, "ADF") ){
		adfResetType = "ALL";
		force = true;
	}else if ( NOT StructKeyExists(application, "ADF") ){
		force = true;
		adfResetType = "SITE";
	}
</cfscript>

<!--- Check if the user is logged in run the reset commands --->
<cfif request.user.id gt 0>
	<cfscript>
		// Command to reset the entire ADF
		if( StructKeyExists(url,"resetADF") ){
			adfResetType = "ALL";
		}else{
			// Check the SERVER or SITE reset commands
			if(StructKeyExists(url,"resetServerADF") and StructKeyExists(url,"resetSiteADF")){
				adfResetType = "ALL";
			}else if(StructKeyExists(url,"resetServerADF")){
				adfResetType = "SERVER";
			}else if(StructKeyExists(url,"resetSiteADF")){
				adfResetType = "SITE";
			}
		}
	</cfscript>
</cfif>

<!--- Run the RESET command --->
<cfif Len(adfResetType) gt 0>
	<cfscript>
		adfCore = createObject("component", "ADF.core.Core");
		resetResults = adfCore.reset(adfResetType);
	</cfscript>
	<cfoutput>
		<cfif !force>
			<!--- 2012-01-10 - MFC - Added span tag with ID around the reset message. --->
			<span id='ADF-Reset-Message'><b>#resetResults.message#</b></span>
		</cfif>
	</cfoutput>
</cfif>

<!--- Check if the user is logged in run the ADF DUMP VAR command --->
<cfif request.user.id gt 0>
	<!--- The following is unchanged during the 2010-10-29 refractor --->
	<cfscript>
		if ( StructKeyExists(url,"ADFDumpVar")) {
			// Verify if the ADF dump var exists
			// [MFC] - Changed "isDefined" to "LEN"
			// [RAK] - 2010-11-01 - Fixing security issue with cfscript code being passed into the evaluate from any logged in user
			// [RAK] - 2011-06-02 - Added * to end of regular expression because it was only validating the first character instead of every character in the string
			//Anything that is not a-z or 0-9 or '.' or '[' or ']'
			regularExpression = '[^a-z0-9\.\[\]]]*';
			if ( LEN(url.ADFDumpVar) GT 0 and !ReFindNoCase(regularExpression,url.ADFDumpVar)){
				CreateObject("component","ADF.lib.utils.Utils_1_0").dodump(evaluate(url.ADFDumpVar), #url.ADFDumpVar#, false);
			}else{
				// 2012-01-10 - MFC - Added span tag with ID around the reset message.
				WriteOutput("<span id='ADF-Reset-Message'><strong>ADFDumpVar Failed</strong> : Variable '#url.ADFDumpVar#' does not exist.</span>");
			}
		}
	</cfscript>
</cfif>