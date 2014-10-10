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
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West 
Custom Field Type:
	App Config Page
Name:
	app_config_page_render.cfm
ADF Requirements:
	scripts_1_0
	ceData_1_0
	forms_1_1
History:
	RLW - Created
	2010-11-29 - GAC - Added conditional logic inside the select box cfloop to check 
					   the length of filename in the records generated by the pagesContainingRH 
					   or the pagesContainingScript.
	2011-08-11 - GAC - Updated the jQuery so the show help link would toggle the Help text 
					 - Converted the CFT to use the wrapFieldHTML() method
					 - Set to use the application.ADF.scripts instead of the objectFactory.getBean
	2012-04-11 - GAC - Removed renderSimpleFormField check
					 - Added the fieldPermission parameter to the wrapFieldHTML function call
					 - Added the includeLabel and includeDescription parameters to the wrapFieldHTML function call
					 - Added readOnly field security code with the cs6 fieldPermission parameter
					 - Updated the wrapFieldHTML explanation comment block
--->
<cfscript>
	// Load JQuery to the script
	application.ADF.scripts.loadJQuery();
	
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	// check the pages that have the attached script or RH in use
	if( xParams.scriptType eq "Custom Script" )
		pageDataAry = application.ADF.csData.pagesContainingScript(xParams.scriptURL);
	else
		pageDataAry = application.ADF.csData.pagesContainingRH(xParams.scriptURL);
		
	// Set defaults for the label and description 
	includeLabel = true;
	includeDescription = true; 

	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";

	//-- Read Only Check w/ cs6 fieldPermission parameter --
	readOnly = application.ADF.forms.isFieldReadOnly(xparams,variables.fieldPermission);
</cfscript>

<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
		//#fqFieldName#.validator="validateBlogName()";
		#fqFieldName#.msg="Please select a page.";
		// push on to validation array
		//vobjects_#attributes.formname#.push(#fqFieldName#);
		
		jQuery(function(){
			jQuery('###fqFieldName#helpLink').click( function() {
				jQuery('###fqFieldName#helpText').toggle();
				if ( jQuery('###fqFieldName#helpText').is(':hidden') ) {
					
					jQuery('###fqFieldName#showHelpLabel').show();
					jQuery('###fqFieldName#hideHelpLabel').hide();			
				}
				else
				{
					jQuery('###fqFieldName#showHelpLabel').hide();
					jQuery('###fqFieldName#hideHelpLabel').show();								
				}
			});		
		});
	</script>
	
	<style type="text/css">
		.#fqFieldName#LabelSmall{
			font-family: Verdana,Arial;
			font-size: 0.6em;
			color: ##000000;
		}
	</style>

	<cfsavecontent variable="inputHTML">
		<cfoutput>
			<select name="#fqFieldName#" id="#fqFieldName#" size="1">
				<option value="">--Select--</option>
				<cfloop from="1" to="#arrayLen(pageDataAry)#" index="itm">
					<!--- // Make sure each of the records have a fileName --->
					<cfif LEN(TRIM(pageDataAry[itm].fileName))>
						<cfif xParams.pagePart eq "pageURL">
							<cfset pageData = "#request.subsiteCache[pageDataAry[itm].subsiteID].url##pageDataAry[itm].fileName#">
						<cfelse>
							<cfset pageData = pageDataAry[itm].pageID>
						</cfif>
						<option value="#pageData#"<cfif currentValue eq pageData> selected="selected"</cfif>>#request.subsiteCache[pageDataAry[itm].subsiteID].url##pageDataAry[itm].fileName#</option>
					</cfif>
				</cfloop>
			</select>
			<br />
			<a href="javascript:;" id="#fqFieldName#helpLink" class="#fqFieldName#LabelSmall">
				<span id="#fqFieldName#showHelpLabel">Show Help</span>
				<span id="#fqFieldName#hideHelpLabel" style="display:none;">Hide Help</span>
			</a>
			<div id="#fqFieldName#helpText" style="display:none;" class="#fqFieldName#LabelSmall">
			Select the Page URL from the list of pages provided.  Note: if your page does not exist in the list
			then please check the Application installation instructions. It is more than likely you forgot to create the page containing the script: #xParams.scriptURL#
			</div>
		</cfoutput>
	</cfsavecontent>
	
	<!---
		This CFT is using the forms lib wrapFieldHTML functionality. The wrapFieldHTML takes
		the Form Field HTML that you want to put into the TD of the right section of the CFT 
		table row and helps with display formatting, adds the hidden simple form fields (if needed) 
		and handles field permissions (other than read-only).
		Optionally you can disable the field label and the field discription by setting 
		the includeLabel and/or the includeDescription variables (found above) to false.  
	--->
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission,includeLabel,includeDescription)#
</cfoutput>