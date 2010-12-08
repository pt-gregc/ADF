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

<cfscript>
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	scripts = server.ADF.objectFactory.getBean("scripts_1_0");
	scripts.loadJQuery();
	scripts.loadJQueryUI();
</cfscript>
<cfparam name="currentValues.scriptURL" default="">
<cfparam name="currentValues.pagePart" default="pageURL">
<cfparam name="currentValues.scriptType" default="Custom Script">
<cfoutput>
	<style type="text/css">
		###prefix#checkbox{
			margin: 0px;
			padding: 0px;
			float: left;
			width: 140px;
		}
		###prefix#caution {
			margin: 0px;
			padding: 0px;
			float:left;
			width: 140px;
		}
		###prefix#control {
			float: left;
			width: 80px;
		}
		###prefix#caution img, ###prefix#checkbox img {
			vertical-align: middle;
			margin-right: 10px;
		}
	</style>
	<script language="JavaScript" type="text/javascript">
		jQuery( function(){
			jQuery("###prefix#checkBtn").bind("click", #prefix#checkFileExists);		
		});
		// register the fields with global props object
		fieldProperties['#typeid#'].paramFields = '#prefix#scriptURL,#prefix#pagePart,#prefix#scriptType';
		// allows this field to support the orange icon (copy down to label from field name)
		fieldProperties['#typeid#'].jsLabelUpdater = '#prefix#doLabel';
		// allows this field to have a common onSubmit Validator
		fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
		// handling the copy label function
		function #prefix#doLabel(str)
		{
			document.#formname#.#prefix#label.value = str;
		}
		function #prefix#doValidate()
		{
			if( jQuery("###prefix#scriptURL").attr("value").length == 0 )
			{
				alert('Please enter a valid value for the Script URL');
				jQuery("###prefix#scriptURL").focus();
				return false;
			}
			return true;
		}
		function #prefix#checkFileExists(){
			var templatePath = jQuery("###prefix#scriptURL").attr("value");
			// clear the check
			jQuery("###prefix#checkbox").hide();
			jQuery("###prefix#caution").hide();
			// make call to check path
			jQuery.post("#application.ADF.ajaxProxy#",
				{
					bean: "utils_1_0",
					method: "scriptExists",
					templatePath: templatePath
				}, function(results){
					// show the results
					if( results == "YES" )
						jQuery("###prefix#checkbox").show();
					else
						jQuery("###prefix#caution").show();
				});
			return true;			
		}
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelSmall" colspan="2">NOTE: This field type is used to make it easier
			to register pages for the configuration of your application. If you need users to build a page
			that contains a specific Custom Script or a Render Handler - this field type will confirm that this is configured correctly
			and record the URL to the page containing the script/RH.
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Script URL:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#scriptURL" id="#prefix#scriptURL" value="#currentValues.scriptURL#" size="55" />
				<br />e.g. /ADF/apps/my_app/customcf/my_file.cfm <em>or</em> /ADF/apps/my_app/renderhandlers/my_file.cfm
			</td>
		</tr>
		<tr>
			<td></td>
			<td class="cs_dlgLabelSmall">
				<div id="#prefix#results">
					<div id="#prefix#control">
						<input type="button" name="#prefix#checkBtn" id="#prefix#checkBtn" value="Check" class="#scripts.jQueryUIButtonClass()#" />
					</div>
					<div id="#prefix#checkbox" style="display:none">
						<img src="/ADF/extensions/customfields/app_config_page/icon_checkbox.png" width="18" height="18" />File exists
					</div>
					<div id="#prefix#caution" style="display:none">
						<img src="/ADF/extensions/customfields/app_config_page/icon_caution.png" width="18" height="18" />File does not exist
					</div>
				</div>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Type:</td>
			<td class="cs_dlgLabelSmall">
				<select name="#prefix#scriptType" id="#prefix#scriptType" size="1">
					<option value="Custom Script"<cfif currentValues.scriptType eq "Custom Script"> selected="selected"</cfif>>Custom Script</option>
					<option value="Render Handler"<cfif currentValues.scriptType eq "Render Handler"> selected="selected"</cfif>>Render Handler</option>
				</select>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Page Data to record:</td>
			<td class="cs_dlgLabelSmall">
				<select name="#prefix#pagePart" id="#prefix#pagePart" size="1">
					<option value="pageURL"<cfif currentValues.pagePart eq "pageURL"> selected="selected"</cfif>>Page URL</option>
					<option value="pageID"<cfif currentValues.pagePart eq "pageID"> selected="selected"</cfif>>Page ID</option>
				</select>
			</td>
		</tr>
	</table>
</cfoutput>