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
/* *************************************************************** */
Author:
	PaperThin, Inc.
Custom Field Type:
	Object List Builder
Name:
	object_list_builder_pre_save_hook.cfm
Summary:
	This is the pre-save-form-hook module for Object List Builderr field
History:
	2015-04-17 - SU/SFS - Created
--->
<cfscript>
	doQuit = 0;
	inputParameters = attributes.inputStruct;
	ceObj = Server.CommonSpot.ObjectFactory.getObject("CustomElement");
	if (StructKeyExists(inputParameters, "controlTypeID") and (inputParameters.controlTypeID NEQ 0))
		objListElementID = inputParameters.controlTypeID;
	else if (StructKeyExists(inputParameters, "controlID") and (inputParameters.controlID NEQ 0))
		objListElementID = inputParameters.controlID;
	else if (StructKeyExists(inputParameters, "formID") and (inputParameters.formID NEQ 0))
		objListElementID = inputParameters.formID;
	else
		doQuit = 1;	
</cfscript>

<!---<cfexit>--->

<cfif doQuit neq 1>
	<cfscript>
		flds = ceObj.getFields(elementID=objListElementID);
	</cfscript>
	<cfloop query="flds">
		<cfscript>
			if (flds.Type eq "Object List Builder")
			{
				fldName = "FIC_#objListElementID#_#flds.id#";
				//application.adf.utils.logappend(msg="hook.cfm - line 26 - fldName: #fldName#<br><br>", logfile='debugPDFRH.html');
				if (StructKeyExists(inputParameters,fldName))
				{
					tagTools = Server.CommonSpot.UDF.tagTools;
					componentOverridePath = "#request.site.csAppsURL#components";
					beanName = "";
				
					//application.adf.utils.logappend(msg=flds, logfile='debugPDFRH.html', label="hook.cfm - line 33 - flds");
					//application.adf.utils.logappend(msg=flds.params, logfile='debugPDFRH.html', label="hook.cfm - line 34 - flds.params");
					fldsparams = flds.params;
					componentPath = fldsparams.componentPath;
					//application.adf.utils.logappend(msg="hook.cfm - line 37 - fldsparams.componentPath: #fldsparams.componentPath#<br><br>", logfile='debugPDFRH.html');
					ext = ListLast(componentPath,'.');
					//application.adf.utils.logappend(msg="hook.cfm - line 39 - ext: #ext#<br><br>", logfile='debugPDFRH.html');

					if (ext EQ 'cfc')
					{
						fileName = Mid(componentPath, 1, Len(componentPath)-Len(ext)-1);
						fileNameWithExt = componentPath;
					}
					else
					{
						fileName = componentPath;
						fileNameWithExt = componentPath & '.cfc';
					}

					//application.adf.utils.logappend(msg="hook.cfm - line 52 - fileName: #fileName#<br><br>", logfile='debugPDFRH.html');
					//application.adf.utils.logappend(msg="hook.cfm - line 53 - fileNameWithExt: #fileNameWithExt#<br><br>", logfile='debugPDFRH.html');

					if (FileExists(ExpandPath('#componentOverridePath#/#fileNamewithExt#')))	
						beanName = "#fileName#";
						//beanName = "#componentOverridePath#/#fileName#";
					else
						beanName = "objectListBuilder";

					//application.adf.utils.logappend(msg="hook.cfm - line 60 - beanName: #beanName#<br><br>", logfile='debugPDFRH.html');

					oldVal = inputParameters[fldName];
					newVal = oldVal;
					objectBuilderTags = tagTools.FindTags(oldVal,"customtagid,id,format");

					//application.adf.utils.logappend(msg="hook.cfm - line 66 - oldVal: #oldVal#<br><br>", logfile='debugPDFRH.html');
					//application.adf.utils.logappend(msg="hook.cfm - line 67 - newVal: #newVal#<br><br>", logfile='debugPDFRH.html');
					//application.adf.utils.logappend(msg=objectBuilderTags, logfile='debugPDFRH.html', label="hook.cfm - line 68 - objectBuilderTags");

					for (curTagPos=1; curTagPos lte arrayLen(objectBuilderTags); curTagPos=curTagPos+1)
					{
						curStruct = objectBuilderTags[curTagPos];
						//application.adf.utils.logappend(msg=curStruct, logfile='debugPDFRH.html', label="hook.cfm - line 73 - curStruct");
						if (lcase(curStruct.tagName) eq "customobjectlistbuildertag" AND 
									structKeyExists(curStruct, "TagAttrs"))
						{
							curAttribs = curStruct.TagAttrs;
							if (StructKeyExists(curAttribs, "id") AND 
											StructKeyExists(curAttribs, "format") AND
											StructKeyExists(curAttribs, "customtagid")
								)
							{
								origStr = curStruct.OriginalTag;
								///ADF/extensions/customfields/object_list_builder/call_renderitem.cfm
								newStr = '<CPMODULE ELEMENT="/ADF/extensions/customfields/object_list_builder/call_renderitem.cfm" beanName="#beanName#" id="#curAttribs.id#" format="#curAttribs.format#">';
								objectBuilderTags[curTagPos].ReplacementText = newStr;
							}
						}
					}
					newVal = Server.CommonSpot.UDF.tagTools.RebuildRTEBlock(oldVal,objectBuilderTags);
					//application.adf.utils.logappend(msg="hook.cfm - line 91 - newVal from RebuildRTEBlock: #newVal#<br><br>", logfile='debugPDFRH.html');
					newVal = ReplaceNoCase(newVal, "customObjectListBuilderTag", "CPMODULE", "ALL");
					newVal = ReplaceNoCase(newVal, "&nbsp;</CPMODULE>", "</CPMODULE>", "ALL");
					//application.adf.utils.logappend(msg="hook.cfm - line 94 - newVal sfter Replaces: #newVal#<br><br>", logfile='debugPDFRH.html');
					inputParameters[fldName] = newVal;
					setVariable('caller.retStruct.requestParams.#fldName#', newVal);
				}
			}
		</cfscript>
	</cfloop>
	<!---<cfset application.adf.utils.logappend(msg=caller.retStruct.requestParams, logfile='debugPDFRH.html', label="hook.cfm - line 101 - caller.retStruct.requestParams")>--->
</cfif>
