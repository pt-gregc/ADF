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
		var rtnHTML = "";
		var APIPostToNewWindow = false;
		
		if ( LEN(TRIM(arguments.formResultCallback)) EQ 0 )
			arguments.formResultCallback = "application.ADF.forms.renderAddEditFormResult";
			
		// DEV: An example of an Alternate option for a Form Result Module
		//arguments.formResultCallback = "/customcf/adfFormResultModule.cfm"; // file on QAbase10
			
		variables.scripts.loadJQuery();
		variables.scripts.loadADFLightbox();
	
		// Return the HTML for the form
		rtnHTML = server.CommonSpot.UDF.UI.RenderSimpleForm(dataPageID=arguments.dataPageID, 
																formID=arguments.formID, 
																postToNewWindow=APIPostToNewWindow, 
																customizedFinalHtml="", 
																behaveAsSimpleForm=arguments.behaveAsSimpleForm,
																resultCallback=arguments.formResultCallback,
																resultCallbackArgs=arguments);
																			
		return rtnHTML;	
	</cfscript>																	
	<!--- // IMPORTANT: For ADF 2.0 and CommonSpot 10 we are NOT passing customizedFinalHtml to the RenderSimpleForm UDF directly
						 We are now passing that HTML string to the resultCallbackArgs as part of the arguments as arguments.customizedFinalHtml ---> 
	<!--- // DEV: customizedFinalHtml=formResultHTML ---> 
</cffunction>

<cffunction name="renderAddEditFormResult" access="public" returntype="void" output="true" hint="Renders the HTML for an Add/Edit form submit result.">
	<cfargument name="formID" type="numeric" required="true" hint="">
	<cfargument name="dataPageId" type="numeric" required="true" hint="">
	<cfargument name="lbAction" type="string" required="false" default="norefresh" hint="The action, either norefresh or refreshparent">
	<cfargument name="customizedFinalHtml" type="string" required="false" default="" hint="Allows you to pass in custom HTML that will display after submit">
	<cfargument name="callback" type="string" required="false" default="" hint="Optional callback javascript function that will get called on submit">
	<cfargument name="FormValues" type="struct" required="false" default="#StructNew()#" hint="The data passed from the submitted form.">
	
	<cfscript>
		var formResultFooterHTML = "";
		
		// Clean Up passed in string values
		arguments.customizedFinalHtml = TRIM(arguments.customizedFinalHtml);
		arguments.callback = TRIM(arguments.callback);
		
		variables.scripts.loadJQuery();
		variables.scripts.loadADFLightbox();
	</cfscript>
	
	<!--- // START - DEV NOTES: --->
	<!--- // Request.Params and ALL of its 'after submit' goodies are available --->
	<!--- <cfdump var="#request.params#" expand=false> --->
	
	<!--- // All the data and parameters from the submitted Form --->
	<!--- <cfdump var="#arguments#" label="arguments" expand=false> --->
	
	<!--- // The fieldname/value pair struct from the submitted Form --->
	<!--- <cfdump var="#arguments.FormValues#" label="FormValues" expand=false> --->
	<!--- // END - DEV NOTES: --->
	
	<!--- // DEPRECATED: Render Customized Final HTML inline --->
	<cfif LEN(arguments.customizedFinalHtml)>
		<cfoutput>#arguments.customizedFinalHtml#</cfoutput>
	</cfif>
	
	<cfsavecontent variable="formResultFooterHTML">
		<cfoutput>
		<script type='text/javascript'>
			lbResizeWindow();
				
			<cfif Len(arguments.callback)>
			jQuery(document).ready(function(){
				// Build the FormValues JS Object
				var #ToScript(arguments.FormValues, "formvalues")#  
				// Set the the FormID as a JS variable
				var #ToScript(arguments.formid, "formid")#
				// Set the the DataPageID as a JS variable
				var #ToScript(arguments.datapageid, "datapageid")#
					
				// Call the ADF form callback with the form values data
				getCallback('#arguments.callback#', formvalues);
			});
			</cfif>
		</script>
		
		<!--- // If no callback OR customizedFinalHtml then check the LBACTION param. --->
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
	</cfscript>
</cffunction>

</cfcomponent>
