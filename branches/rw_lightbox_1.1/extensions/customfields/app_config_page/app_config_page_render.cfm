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
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	scripts = server.ADF.objectFactory.getBean("scripts_1_0");
	scripts.loadJQuery();
	csData = server.ADF.objectFactory.getBean("csData_1_0");
	// check the pages that have the attached script or RH in use
	if( xParams.scriptType eq "Custom Script" )
		pageDataAry = csData.pagesContainingScript(xParams.scriptURL);
	else
		pageDataAry = csData.pagesContainingRH(xParams.scriptURL);
</cfscript>
<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
		//#fqFieldName#.validator="validateBlogName()";
		#fqFieldName#.msg="Please upload a document.";
		// push on to validation array
		//vobjects_#attributes.formname#.push(#fqFieldName#);
	</script>
	<!--- // determine if this is rendererd in a simple form or the standard custom element interface --->
	<cfscript>
		if ( structKeyExists(request, "element") )
		{
			labelText = '<span class="CS_Form_Label_Baseline"><label for="#fqFieldName#">#xParams.label#:</label></span>';
			tdClass = 'CS_Form_Label_Baseline';
		}
		else
		{
			labelText = '<label for="#fqFieldName#">#xParams.label#:</label>';
			tdClass = 'cs_dlgLabel';
		}
	</cfscript>
	<tr>
		<td class="#tdClass#" valign="top">#labelText#</td>
		<td class="cs_dlgLabelSmall">
			<select name="#fqFieldName#" id="#fqFieldName#" size="1">
				<option value="">--Select--</option>
				<cfloop from="1" to="#arrayLen(pageDataAry)#" index="itm">
					<cfif xParams.pagePart eq "pageURL">
						<cfset pageData = "#request.subsiteCache[pageDataAry[itm].subsiteID].url##pageDataAry[itm].fileName#">
					<cfelse>
						<cfset pageData = pageDataAry[itm].pageID>
					</cfif>
					<option value="#pageData#"<cfif currentValue eq pageData> selected="selected"</cfif>>#request.subsiteCache[pageDataAry[itm].subsiteID].url##pageDataAry[itm].fileName#</option>
				</cfloop>
			</select>
			<br />
			<a href="##" id="#fqFieldName#helpLink">
				<span id="#fqFieldName#showHelp">Show</span>
				<span id="#fqFieldName#hideHelp" style="display:none;">Hide</span> help
			</a>
			<div id="#fqFieldName#helpText" style="display:none;">
			Select the Page URL from the list of pages provided.  Note: if your page does not exist in the list
			then please check the Application installation instructions. It is more than likely you forgot to create the page containing the script: #xParams.scriptURL#
			</div>
		</td>
	</tr>
</cfoutput>