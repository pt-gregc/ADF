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

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	M. Carroll
Name:
	delete_element_handler.cfm
Summary:
	Invokes the CommonSpot datasheet delete form data modules.
History:
	2010-03-12 - MFC - Created
	2010-12-14 - MFC - Added Callback functionality for the Lightbox and
						Dialog header and footers.
--->
<!--- // Include the CommonSpot process for a datasheet --->

<!--- Render the dlg header --->
<cfscript>
	CD_DialogName = request.params.title;
	CD_Title=CD_DialogName;
	CD_IncludeTableTop=1;
	CD_CheckLock=0;
	CD_CheckLogin=1;
	CD_CheckPageAlive=0;
</cfscript>
<CFINCLUDE TEMPLATE="/commonspot/dlgcontrols/dlgcommon-head.cfm">
<cfoutput><tr><td></cfoutput>

<!--- // if we are returning then handle the delete --->
<cfif (StructKeyExists(Request.Params,"doDelete")) AND (Request.Params.doDelete neq 0)>

	<!--- Delete the CE record --->
	<cfif (Request.Params.FormID NEQ 0) AND (Request.Params.PageID NEQ 0)>
		<cfscript>
			application.ADF.cedata.deleteCE(datapageidList=Request.Params.PageID);
		</cfscript>
	</cfif>

	<cfoutput><div style="width:100%;text-align:center;" class="cs_dlgNormal">Record deleted successfully</div></cfoutput>
	<!--- Call the Callback function if defined --->
	<!--- <cfif LEN(arguments.callback)>
		<cfoutput>
		<script type="text/javascript">
			// Set back the lightbox callback
			getCallback('#arguments.callback#');
		</script>
		</cfoutput>
	<cfelse>	
		<cfset forms = server.ADF.objectFactory.getBean("forms_1_0")>
		<!--- <cfoutput>#forms.closeLBAndRefresh()#</cfoutput> --->
	</cfif> --->
	
<cfelse>
	<cfinclude template="/commonspot/controls/datasheet/cs-delete-form-data.cfm">	
</cfif>

<!--- Render the dlg footer --->
<cfoutput></tr></td></cfoutput>
<CFINCLUDE template="/commonspot/dlgcontrols/dlgcommon-foot.cfm">
