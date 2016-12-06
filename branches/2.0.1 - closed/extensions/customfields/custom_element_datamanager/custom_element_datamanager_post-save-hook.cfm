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
/* *********************************************************************** */
Author:
	PaperThin, Inc.
Custom Field Type:
	Custom Element DataManager 
Name:
	custom_element_datamanager_post-save-hook.cfm
Summary:
	This file in cfincluded in to the post-save-form-hook.cfm. When the post-save-form-hook.cfm is
	added to the root of your site it runs this code after a commonspot object is saved.
History:
	2013-11-14 - DJM - Created
	2013-11-15 - GAC - Converted to an ADF custom field type
	2016-10-17 - GAC - Update to have DM specific variable names
--->

<cfscript>
	dmInputParameters = attributes.inputStruct;
	dmArgs = StructNew();
	dmFormFieldsToProcess = StructNew();
	dmFieldComp = '';
</cfscript>

<!---
<cfdump var="#dmInputParameters#" label="inputParameters" expand=false>
--->

<cfif StructKeyExists(dmInputParameters, 'csAssoc_assocCE') AND IsNumeric(dmInputParameters.csAssoc_assocCE)>
 	<cfscript>
  		dmFormID = dmInputParameters.csAssoc_assocCE;

  		dmFormFieldsToProcess['fic_#dmFormID#_#dmInputParameters.csAssoc_parentInstanceIDField#'] = '';
		dmFormFieldsToProcess['fic_#dmFormID#_#dmInputParameters.csAssoc_childInstanceIDField#'] = '';

  		Request.Params['fic_#dmFormID#_#dmInputParameters.csAssoc_parentInstanceIDField#'] = dmInputParameters.csAssoc_parentInstanceID;
  		Request.Params['fic_#dmFormID#_#dmInputParameters.csAssoc_childInstanceIDField#'] = dmInputParameters.csAssoc_childInstanceID;

  		dmArgs.dfvFormID = dmFormID;
  		dmArgs.dfvPageID = Request.Site.IDMaster.getID();
  		dmArgs.dfvControlID = 0;
  		dmArgs.formFields = dmFormFieldsToProcess;

  		dmFieldComp = createObject('component', 'commonspot.components.form.gce-field').init(argumentCollection=dmArgs);
 	</cfscript>

	<!--- // populateData - only takes 2 parameters --->
	<CFLOCK type="readOnly" name="CS_Site#Request.SiteID#_SyncTime" timeout="10">
	  	<cfset dmFieldComp.populateData(0, 1)>
	</CFLOCK>
</cfif>

<!---
<cfdump var="#dmArgs#" label="args" expand=false>
--->

