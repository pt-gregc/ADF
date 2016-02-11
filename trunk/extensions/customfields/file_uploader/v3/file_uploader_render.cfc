<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the Starter App directory

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
	Ryan Kahn
Name:
	file_uploader_render.cfc
Summary:
	Renders the file upload form
History:
	2011-08-05 - RAK - Created
	2011-08-05 - RAK - fixed issue where the file uploader would try to generate images for non-pdf files.
	2011-09-22 - RAK - Updated file uploader to be able to get more detailed information if they choose to override the props.
	2012-01-03 - GAC - Moved the the hidden field code inside the TD tag
	2012-02-14 - GAC - Moved the CFT hidden fields back inside of the <td> wrapper for the field
	2013-01-21 - SFS - Moved the CFT hidden fields back outside of the <td> wrapper for the field to make more valid HTML
	2015-05-08 - DJM - Converted to CFC
	2015-05-26 - DJM - Added the 3.0 version
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean()
	2016-02-09 - GAC - Updated duplicateBean() to use data_2_0.duplicateStruct()
--->
<cfcomponent displayName="FileUploader Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		var uploadUUID = CreateUUID();
		var currentFilename = "";
		var fieldDefaultValues = application.ADF.ceData.getFieldParamsByID(arguments.fieldID);
		var valueRenderParams = StructNew();
		var currentValueRenderData = '';
		var imageURL = "/ADF/extensions/customfields/file_uploader/v3/handleFileDownload.cfm?subsiteURL=#request.subsite.url#&fieldID=#arguments.fieldID#&filename=";
		var concatenator = "";

		application.ADF.scripts.loadJQuery();
		application.ADF.scripts.loadADFLightbox();
		application.ADF.scripts.loadJQueryUI();
		
		valueRenderParams.currentValue = currentValue;
		currentValueRenderData = application.ADF.utils.runCommand(fieldDefaultValues.beanName,"getCurrentValueRenderData",valueRenderParams);
		
		renderJSFunctions(argumentCollection=arguments, beanName=fieldDefaultValues.beanName);
	</cfscript>
	
	<cfoutput>
		<div>
			<div id="#arguments.fieldName#_currentSelection">#currentValueRenderData.name#</div>
			<div id="#arguments.fieldName#_thumbnail">
				<cfif len(currentValueRenderData.image)>
					#currentValueRenderData.image#
				</cfif>
			</div>
			<div id="uploadHolder_#arguments.fieldName#" style="min-width:475px">
				<iframe height="70px" width="375px" scrolling="no" frameBorder="0" src="/ADF/extensions/customfields/file_uploader/v3/fileUploadForm.cfm?subsiteURL=#request.subsite.url#&fieldName=#arguments.fieldName#&uploadUUID=#uploadUUID#&inputID=#arguments.fieldID#"></iframe>
			</div>
			<div id="errorMsg_#arguments.fieldName#"></div>
			<input type="button" value="Clear" name="clear_btn_#arguments.fieldName#" id="clear_btn_#arguments.fieldName#" onclick="#arguments.fieldName#clearButtonClick()">
		</div>
		
		<!--- hidden field to store the value --->
		<input type='hidden' name='#arguments.fieldName#' id='#arguments.fieldName#' value='#currentValue#'>
	</cfoutput>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="beanName" type="string" required="yes">
	
	<cfscript>
		var currentValue = arguments.value;
	</cfscript>
<cfoutput>
<script type="text/javascript">
<!--
jQuery(document).ready( function(){
	#arguments.fieldName#setView(false);
	<cfif Len(currentValue)>
		#arguments.fieldName#setView(true);
		jQuery("###arguments.fieldName#_currentSelection").show();
	</cfif>
});

function #arguments.fieldName#handleFileUploadComplete(fileName){
	<cfif application.ADF.utils.runCommand(arguments.beanName,"_isThumbnailGenerationOn")>
		jQuery.post("#application.ADF.ajaxProxy#",{
			bean: "#arguments.beanName#",
			method:"_getThumbnail",
			fileName:fileName,
			fieldID: "#arguments.fieldID#"
		},function(results){
			jQuery("###arguments.fieldName#_thumbnail").html(results);
		});
	</cfif>

	jQuery("###arguments.fieldName#_currentSelection").html(fileName);
	jQuery("###arguments.fieldName#").val(fileName);  //.trigger("change"); // TODO: MAY NEED TO ADD THE .TRIGGER TO NOTIFY FORM OF CHANGE 
	#arguments.fieldName#setView(true);
	jQuery("###arguments.fieldName#_currentSelection").show();
}

function #arguments.fieldName#setView(selected){
	if(!selected){
		jQuery("###arguments.fieldName#_currentSelection").hide();
		jQuery("##clear_btn_#arguments.fieldName#").hide();
		jQuery("##uploadHolder_#arguments.fieldName#").show();
	}else{
		jQuery("##clear_btn_#arguments.fieldName#").show();
		jQuery("##uploadHolder_#arguments.fieldName#").hide();
	}
}

function #arguments.fieldName#clearButtonClick(){
	jQuery("###arguments.fieldName#").val("");
	jQuery("###arguments.fieldName#_thumbnail").html("");
	jQuery("##errorMsg_#arguments.fieldName#").html("");
	jQuery("###arguments.fieldName#_currentSelection").html("");
	#arguments.fieldName#setView(false);
}
//-->
</script>
</cfoutput>
</cffunction>


<cfscript>
	public string function getResourceDependencies()
	{
		return listAppend(super.getResourceDependencies(), "jQuery,jQueryUI,ADFLightbox");
	}
</cfscript>

</cfcomponent>