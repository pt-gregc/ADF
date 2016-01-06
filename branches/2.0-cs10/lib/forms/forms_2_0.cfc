<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2016.
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

<cfproperty name="version" value="2_0_2">
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
		var formResultHTML = "";
		var defaultResultCallback = "application.ADF.forms.renderAddEditFormResult";	
		var formResultCallbackArgs = arguments;	
		
		/*
			// IMPORTANT: The use of "customizedFinalHtml" has been DEPRECATED.
			//            CommonSpot 10 JS and CSS resources will NOT be available or run using the customizedFinalHtml approach 
			// 			  Only HTML and inline JS an CSS with render
			//            Please use the formResultCallback and build a callback with a path to a method in memory or 
			// 			  path to .cfm module file to handle processing after the form has been submitted!!
		*/
		
		// If we do NOT have a resultCallback path
		// Use the default resultCallback method path
		if ( LEN(TRIM(arguments.formResultCallback)) EQ 0 )
			arguments.formResultCallback = defaultResultCallback;
		
		// DEV NOTE: An example of an Alternate option for a Form Result Module
		// resultCallback = "/customcf/adfFormResultModule.cfm"; 	// file on QAbase10
	
		// If customizedFinalHtml has a value pass it through and clear the resultCallback and resultCallbackArgs
		if ( LEN(TRIM(arguments.customizedFinalHtml)) )
		{
			// Pass the customizedFinalHtml to the Form ( to a pre-submit hidden field )
			formResultHTML = arguments.customizedFinalHtml;
			
			// And make sure to clear the resultCallback and the resultCallbackArgs
			arguments.formResultCallback = "";
			formResultCallbackArgs = StructNew();
		}				
			
		variables.scripts.loadJQuery();
		variables.scripts.loadADFLightbox();
		
		// DEV NOTES: use this dump to see what we are passing as arguments to the RenderSimpleForm resultCallbackArgs(arguments)
		//application.ADF.utils.doDUMP(formResultCallbackArgs,"formResultCallbackArgs",0);
	
		// Return the HTML for the form
		rtnHTML = server.CommonSpot.UDF.UI.RenderSimpleForm(dataPageID=arguments.dataPageID, 
																formID=arguments.formID, 
																postToNewWindow=APIPostToNewWindow, 
																customizedFinalHtml=formResultHTML, 
																behaveAsSimpleForm=arguments.behaveAsSimpleForm,
																resultCallback=arguments.formResultCallback,		
																resultCallbackArgs=formResultCallbackArgs);
																			
		return rtnHTML;	
	</cfscript>																	
	<!--- // IMPORTANT: For ADF 2.0 and CommonSpot 10 we are NOT passing customizedFinalHtml to the RenderSimpleForm UDF directly
						 We are now passing that HTML string to the resultCallbackArgs as part of the arguments as arguments.customizedFinalHtml ---> 
	<!--- // DEV: customizedFinalHtml=formResultHTML ---> 
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$renderAddEditFormResult
Summary:
	Renders the HTML for result that displays after the renderAddEditForm has been submitted.
Returns:
	Void 
Arguments:
	Numeric - formID - the Custom Element Form ID
	Numeric - dataPageID - the dataPageID for the record that you would like to edit
	String - lbAction - Lightbox action on close, norefresh or refreshparent
	String - customizedFinalHtml - HTML to display when form is submitted
	String - callback
	Struct - FormValues
History:
	2015-10-13 - GAC - Created
--->
<cffunction name="renderAddEditFormResult" access="public" returntype="void" hint="Renders the HTML for result that displays after the renderAddEditForm has been submitted.">
	<cfargument name="formID" type="numeric" required="true" hint="">
	<cfargument name="dataPageId" type="numeric" required="true" hint="">
	<cfargument name="lbAction" type="string" required="false" default="norefresh" hint="The action, either norefresh or refreshparent">
	<cfargument name="customizedFinalHtml" type="string" required="false" default="" hint="Allows you to pass in custom HTML that will display after submit">
	<cfargument name="callback" type="string" required="false" default="" hint="Optional callback javascript function that will get called on submit">
	<cfargument name="FormValues" type="struct" required="false" default="#StructNew()#" hint="The data passed from the submitted form.">
	
	<cfscript>
		var formResultFooterJS = "";
		
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
	<!--- <cfif LEN(arguments.customizedFinalHtml)>
		<cfoutput>#arguments.customizedFinalHtml#</cfoutput>
	</cfif> --->
	
	<cfsavecontent variable="formResultFooterJS">
		<cfoutput>
		<!--- <script type='text/javascript'> --->
		lbResizeWindow();
			
		<cfif LEN(TRIM(arguments.callback))>
		jQuery(function(){
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
		<!--- </script> --->
		
		<!--- // If no callback OR customizedFinalHtml then check the LBACTION param. --->
		<cfif LEN(arguments.customizedFinalHtml) EQ 0 AND LEN(arguments.callback) EQ 0>
			<!--- <script type='text/javascript'> --->
			<cfif arguments.lbAction EQ "refreshparent">
			<!--- // If the LB Action is to refresh parent --->
			closeLBReloadParent();
			<cfelse>
			<!--- //Else if we don't have a callback, then close the LB --->
			closeLB();
			</cfif>
			<!--- </script> --->
		</cfif>	
		</cfoutput>
	</cfsavecontent>
	
	<cfoutput>
		<div style="text-align: center">
			<div style="padding-top:20px;padding-bottom:30px;">
				<img id="loading_img" title="Saving, please wait..." src="/commonspot/dashboard/images/dialog/loading.gif">
				<span id="loading_text">Saving, please wait...</span>
			</div>
		</div>
	</cfoutput>

	<cfscript>
		// Load the inline JavaScript after the libraries have loaded
		variables.scripts.addFooterJS(formResultFooterJS, "SECONDARY"); //  PRIMARY, SECONDARY, TERTIARY
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$closeLBandRefresh
Summary:	
	Closes the current lightbox and refreshes the parent window
Returns:
	Void
Arguments:
	Void
History:
	2009-10-25 - RLW - Created
	2010-12-21 - MFC - Updated to use the ADF Lightbox Framework functions
	2015-11-18 - GAC - Updated to work with scripts_2_0
--->
<cffunction name="closeLBAndRefresh" access="public" returntype="void" hint="">
	
	<cfscript>
		var dialogFooterJS = "";
	
		variables.scripts.loadJquery(force=1);
		variables.scripts.loadADFLightbox(force=1);
	</cfscript>
	
	<cfsavecontent variable="dialogFooterJS">
	<cfoutput>
		<!--- <script type='text/javascript'>--->
			jQuery(function(){
				closeLBReloadParent();
			});
		<!---</script>--->
	</cfoutput>
	</cfsavecontent>
	
	<cfscript>
		// Load the inline JavaScript after the libraries have loaded
		variables.scripts.addFooterJS(dialogFooterJS, "TERTIARY"); //  PRIMARY, SECONDARY, TERTIARY
	</cfscript>
</cffunction>

</cfcomponent>
