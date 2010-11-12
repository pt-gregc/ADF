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
		2010-10-29 - RAK - Refactored whole file to use /ADF/core/Core.cfc's Reset function
 --->
<cfif request.user.id gt 0>
	<cfscript>
		//Determine what kind of reset is needed (if any)
		adfResetType = "";
		if(NOT StructKeyExists(server, "ADF") or StructKeyExists(url,"resetADF")){
			adfResetType = "ALL";
		}else{
			if(StructKeyExists(url,"resetServerADF") and StructKeyExists(url,"resetSiteADF")){
				adfResetType = "ALL";
			}else if(StructKeyExists(url,"resetServerADF")){
				adfResetType = "SERVER";
			}else if(StructKeyExists(url,"resetSiteADF")){
				adfResetType = "SITE";
			}
		}
	</cfscript>
	<cfif Len(adfResetType) gt 0>
		<cfscript>
			adfCore = createObject("component", "ADF.core.Core");
			resetResults = adfCore.reset(adfResetType);
		</cfscript>
		<cfoutput>
			#resetResults.message#
		</cfoutput>
	</cfif>
	
	<!--- The following is unchanged during the 2010-10-29 refractor --->
	<cfscript>
		if ( StructKeyExists(url,"ADFDumpVar")) {
			// Verify if the ADF dump var exists
			// [MFC] - Changed "isDefined" to "LEN"
			if ( LEN(url.ADFDumpVar) GT 0 )
				CreateObject("component","ADF.lib.utils.Utils_1_0").dodump(evaluate(url.ADFDumpVar), #url.ADFDumpVar#, false);
			else
				WriteOutput("<strong>ADFDumpVar Failed</strong> : Variable '#url.ADFDumpVar#' does not exist.");
		}
	</cfscript>
</cfif>