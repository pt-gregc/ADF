<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
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
--->

<cfscript>
	inputParameters = attributes.inputStruct;
	args = StructNew();
	formFieldsToProcess = StructNew();
	fieldComp = '';
</cfscript>

<!---
<cfdump var="#inputParameters#" label="inputParameters" expand=false>
<cfdump var="#args#" label="args" expand=false>
--->

<cfif StructKeyExists(inputParameters, 'csAssoc_assocCE') AND IsNumeric(inputParameters.csAssoc_assocCE)>
 	<cfscript>
  		formID = inputParameters.csAssoc_assocCE;
  
  		formFieldsToProcess['fic_#formID#_#inputParameters.csAssoc_parentInstanceIDField#'] = '';
		formFieldsToProcess['fic_#formID#_#inputParameters.csAssoc_childInstanceIDField#'] = '';
  
  		Request.Params['fic_#formID#_#inputParameters.csAssoc_parentInstanceIDField#'] = inputParameters.csAssoc_parentInstanceID;
  		Request.Params['fic_#formID#_#inputParameters.csAssoc_childInstanceIDField#'] = inputParameters.csAssoc_childInstanceID;
  
  		args.dfvFormID = formID;
  		args.dfvPageID = Request.Site.IDMaster.getID();
  		args.dfvControlID = 0;
  		args.formFields = formFieldsToProcess;

  		fieldComp = createObject('component', 'commonspot.components.form.gce-field').init(argumentCollection=args); 
 	</cfscript>
 
	<CFLOCK type="readOnly" name="CS_Site#Request.SiteID#_SyncTime" timeout="10">
	  	<cfset fieldComp.populateData('', 0, 1)>
	</CFLOCK>
</cfif>
