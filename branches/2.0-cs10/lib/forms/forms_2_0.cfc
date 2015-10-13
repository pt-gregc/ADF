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
 *************************************************************** 
Author: 	
	PaperThin, Inc. 
Name:
	forms_2_0.cfc
Summary:
	Date Utils functions for the ADF Library
Version:
	2.0
History:
	2015-09-10 - GAC - Created
--->
<cfcomponent displayname="forms_2_0" extends="forms_1_1" hint="Forms Utils functions for the ADF Library">

<cfproperty name="version" value="2_0">
<cfproperty name="type" value="transient">
<cfproperty name="ceData" injectedBean="ceData_3_0" type="dependency">
<cfproperty name="scripts" injectedBean="scripts_2_0" type="dependency">
<cfproperty name="ui" injectedBean="ui_2_0" type="dependency">
<cfproperty name="fields" injectedBean="fields_2_0" type="dependency">
<cfproperty name="wikiTitle" value="Forms_2_0">

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$renderAddEditForm
Summary:
	Returns the HTML for an Add/Edit Custom element record
Returns:
	String formHTML
Arguments:
	Numeric - formID - the Custom Element Form ID
	Numeric - dataPageID - the dataPageID for the record that you would like to edit
	String - lbAction - Lightbox action on close, norefresh or refreshparent
	String - customizedFinalHtml - HTML to display when form is submitted
	String - callback
	String - behaveAsSimpleForm
	String - formResultCallback
History:
	2015-10-12 - GAC - Updated for ADF 2.0 and CommonSpot 10 loadResources()
--->
<cffunction name="renderAddEditForm" access="public" returntype="String" hint="Returns the HTML for an Add/Edit Custom element record">
	<cfargument name="formID" type="numeric" required="true" hint="Form ID to render">
	<cfargument name="dataPageId" type="numeric" required="true" hint="DatapageID to render the edit for">
	<cfargument name="lbAction" type="string" required="false" default="norefresh" hint="The action, either norefresh or refreshparent">
	<cfargument name="customizedFinalHtml" type="string" required="false" default="" hint="DEPRECATED (Use resultCallback instead): Allows you to pass in custom HTML that will display after submit">
	<cfargument name="callback" type="string" required="false" default="" hint="Optional callback code that will get called on submit">
	<cfargument name="behaveAsSimpleForm" type="Boolean" required="no" default="0" hint="Optional parameter to treat the form as simple form or not">
	<cfargument name="formResultCallback" type="string" required="no" default="" hint="An path to and in memory method or a path to a module file.">
	
	<cfscript>
		var udfResults = '';
		var APIPostToNewWindow = false;
		var rtnHTML = "";
		var formResultHTML = "";
		
		if ( LEN(TRIM(arguments.formResultCallback)) EQ 0 )
			arguments.formResultCallback = "application.ADF.forms.renderAddEditFormResult";
			
		// Testing Form Result Module
		//arguments.formResultCallback = "/customcf/adfFormResultModule.cfm"; // file on QAbase10
			
		//variables.scripts.loadJQuery();
		variables.scripts.loadADFLightbox();
	</cfscript>
	
	<!--- // Result from the Form Submit --->
	<!--- <cfsavecontent variable="formResultHTML">
		<!--- Set the form result html to the argument if defined --->
		<cfoutput>
			<cfscript>
				// Load the scripts, check if we need to load
				//	the JSON scripts for the callback.
				// 2011-03-26 - MFC - Commented out force JQuery, the loadADFLightbox with force will
				//						load JQuery.
				//variables.scripts.loadJQuery(force=1);
				//variables.scripts.loadADFLightbox(force=1);
				
				// TEMP FIX - Until loadResource() works with the CS RenderSimpleForm UDF
				rtnScripts.loadADFLightbox(force=1);
			</cfscript>
			<script type='text/javascript'>
				jQuery(document).ready(function(){
					lbResizeWindow();
					<cfif Len(arguments.callback)>
						// Get the PageWindow and the form value
						var pageWindow = top.commonspot.lightbox.getPageWindow();
						var value = pageWindow.ADFFormData.formValueStore;
						//console.log(value);
						//Call the callback with the form value
						getCallback('#arguments.callback#', value);
					</cfif>
				});
			</script>
			<!--- Set the form result HTML
					If none defined, then check the LBACTION param.
			 --->
			<cfif LEN(arguments.customizedFinalHtml)>
				<cfoutput>#arguments.customizedFinalHtml#</cfoutput>
			<cfelse>
				<!--- If the LB Action is to refresh parent --->
				<cfif arguments.lbAction EQ "refreshparent" and LEN(arguments.callback) eq 0>
					<script type='text/javascript'>
						closeLBReloadParent();
					</script>
				<cfelseif LEN(arguments.callback) eq 0>
					<!--- Else if we don't have a callback, then close the LB --->
					<script type='text/javascript'>
						closeLB();
					</script>
				</cfif>
			</cfif>
		</cfoutput>
	</cfsavecontent> --->

	<!--- HTML for the form --->
	<cfsavecontent variable="rtnHTML">
		<cfset udfResults = server.CommonSpot.UDF.UI.RenderSimpleForm(dataPageID=arguments.dataPageID, 
																		formID=arguments.formID, 
																		postToNewWindow=APIPostToNewWindow, 
																		customizedFinalHtml="", 
																		behaveAsSimpleForm=arguments.behaveAsSimpleForm,
																		resultCallback=arguments.formResultCallback,
																		resultCallbackArgs=arguments)>
		
		<!--- IMPORTANT: As for ADF 2.0 and CommonSpot 10 we are NOT passing customizedFinalHtml to the RenderSimpleForm UDF directly
						 We are no passing that HTML string to the resultCallbackArgs as part of the arguments as arguments.customizedFinalHtml ---> 
					
		<!--- customizedFinalHtml=formResultHTML ---> 
		
		<cfoutput>
			<!--- // Render the result from the call to the UDF function --->
			#udfResults#
			<cfif Len(arguments.callback)>
				<script type="text/javascript">
					//Setting this up so that on page load the cookie gets filled with existing values, if there are any
					jQuery(document).ready(function (){
						handleFormChange();
						
						jQuery(document).on("click","##proxyButton1",handleFormChange);
					});
					
					function handleFormChange(){
						// Get the PageWindow and store the form value
						var pageWindow = top.commonspot.lightbox.getPageWindow();
						pageWindow.ADFFormData = {
							formValueStore: getForm()
						};
					}

					//returns the form values as an object
					// Obj[fieldName] = fieldValue;
					function getForm(){
						var rtnStruct = new Object();
						var formFields = jQuery("input");
						
						formFields = formFields.filter(
							function(){
								// Need to check that the field has a name attribute
								if ( jQuery(this).attr("name") )
									return jQuery(this).attr("name").toLowerCase().indexOf("fieldname") != -1;
							}
						);
						
						formFields.each(function (){
							var name = jQuery(this).attr("name");
							//Case insensitive replace
							name = name.replace(/_fieldName/i,"");
							if( jQuery("[name='"+name+"']").attr("type") === "checkbox" && !jQuery("[name='"+name+"']:checked").length)
							{
								rtnStruct[jQuery(this).attr("value")] = "";
							}
							else
							{
								rtnStruct[jQuery(this).attr("value")] = jQuery("[name='"+name+"']").attr("value");
							}
						});
					
						return rtnStruct;
					}
				</script>
			</cfif>
		</cfoutput>
	</cfsavecontent>
	
	<cfreturn rtnHTML>
</cffunction>

<cffunction name="renderAddEditFormResult" access="public" returntype="void" output="true" hint="Renders the HTML for an Add/Edit form submit result.">
	<cfargument name="formID" type="numeric" required="true" hint="">
	<cfargument name="dataPageId" type="numeric" required="true" hint="">
	<cfargument name="lbAction" type="string" required="false" default="norefresh" hint="The action, either norefresh or refreshparent">
	<cfargument name="customizedFinalHtml" type="string" required="false" default="" hint="Allows you to pass in custom HTML that will display after submit">
	<cfargument name="callback" type="string" required="false" default="" hint="Optional callback javascript function that will get called on submit">
	
	<cfscript>
		var formResultFooterHTML = "";
		var resultFormID = arguments.formID;
		var resultFormData = StructNew();
		
		// Clean Up passed in string values
		arguments.customizedFinalHtml = TRIM(arguments.customizedFinalHtml);
		arguments.callback = TRIM(arguments.callback);
		
		// Pull out the submitted Form key/value pairs
		/* if ( StructKeyExists(request,"params") )
		{	
			resultFormData.values = extractFromSimpleForm(request.params);
			
			resultFormData.formID = arguments.formID;
			
			if ( arguments.dataPageID GT 0 AND StructKeyExists(request.params,"PageID") AND IsNumeric(request.params.PageID) )
				resultFormData.dataPageID = request.params.PageID;
		}*/
		
		//variables.scripts.loadJQuery();
		variables.scripts.loadADFLightbox();
	</cfscript>
	
	<!--- // NOTE: Request.Params and ALL of its 'after submit' goodies are available here --->
	<!--- <cfdump var="#request.params#" expand=false> --->
	
	<!--- // Output the submitted Form key/value pairs --->
	<!--- <cfdump var="#resultFormData#" expand=false> --->
	
	<cfdump var="#arguments#" label="arguments" expand=false>
	
	<!--- /// Render Customized Fianal HTML inline --->
	<cfif LEN(arguments.customizedFinalHtml)>
		<cfoutput>#arguments.customizedFinalHtml#</cfoutput>
	</cfif>
	
	<cfsavecontent variable="formResultFooterHTML">
		<cfoutput>
		<script type='text/javascript'>
			jQuery(document).ready(function(){
				lbResizeWindow();
				<cfif Len(arguments.callback)>
					// Get the PageWindow and the form value
					var pageWindow = top.commonspot.lightbox.getPageWindow();
					var value = pageWindow.ADFFormData.formValueStore;
					//console.log(value);
					
					//Call the callback with the form value
					getCallback('#arguments.callback#', value);
				</cfif>
			});
		</script>
		<!--- // Set the form result HTML
				If none defined, then check the LBACTION param.
		 --->
		<cfif LEN(arguments.customizedFinalHtml) EQ 0 AND LEN(arguments.callback) EQ 0>
			<!--- If the LB Action is to refresh parent --->
			<cfif arguments.lbAction EQ "refreshparent">
				<script type='text/javascript'>
					closeLBReloadParent();
				</script>
			<cfelse>
				<!--- Else if we don't have a callback, then close the LB --->
				<script type='text/javascript'>
					closeLB();
				</script>
			</cfif>
		</cfif>	
		</cfoutput>
	</cfsavecontent>

	<cfscript>
		// Load the inline JavaScript after the libraries have loaded
		variables.scripts.addFooterHTML(formResultFooterHTML, "SECONDARY"); //  PRIMARY, SECONDARY, TERTIARY
		
		// Server.CommonSpot.udf.resources.addFooterHTML(formResultScripts, "SECONDARY"); //  PRIMARY, SECONDARY, TERTIARY
        // Server.CommonSpot.udf.resources.addFooterJS(formResultScripts, "SECONDARY"); //  PRIMARY, SECONDARY, TERTIARY
	</cfscript>
</cffunction>

</cfcomponent>

<!--- component displayname="forms_2_0" extends="forms_1_1" hint="Forms Utils functions for the ADF Library"
{
	property name="version" value="2_0_0";
	property name="type" value="transient";
	property name="ceData" injectedBean="ceData_3_0" type="dependency";
	property name="scripts" injectedBean="scripts_2_0" type="dependency";
	property name="ui" injectedBean="ui_2_0" type="dependency";
	property name="fields" injectedBean="fields_2_0" type="dependency";
	property name="wikiTitle" value="Forms_2_0";	
} --->