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

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	forms_2_0.cfc
Summary:
	Form functions for the ADF Library
History:
	2009-09-28 - MFC - Created
--->
<cfcomponent displayname="forms_2_0" extends="ADF.lib.forms.forms_1_0" hint="Form functions for the ADF Library">

<cfproperty name="version" value="2_0_0">
<cfproperty name="type" value="transient">
<cfproperty name="ceData" injectedBean="ceData_1_0" type="dependency">
<cfproperty name="scripts" injectedBean="scripts_1_0" type="dependency">
<cfproperty name="wikiTitle" value="Forms_1_0">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
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
History:
	2009-08-03 - MFC - Created
	2009-11-11 - MFC - Updates to force the jquery script to load
	2010-06-04 - MFC - Added IF statement to check for lbAction to refresh parent
	2010-06-07 - MFC - Updated the render form to not call the special RTE operations when above CS 6.
	2010-09-28 - MFC - Updated the Lightbox forms to load the CS Dialog headers and footers.
	2010-11-28 - RK - NEEDS TO ADD COMMENTS!
--->
<cffunction name="renderAddEditForm" access="public" returntype="String" hint="Returns the HTML for an Add/Edit Custom element record">
	<cfargument name="formID" type="numeric" required="true">
	<cfargument name="dataPageId" type="numeric" required="true">
	<cfargument name="lbAction" type="string" required="false" default="norefresh">
	<cfargument name="customizedFinalHtml" type="string" required="false" default="">
	<cfargument name="renderResult" type="boolean" required="false" default="0">
	<cfargument name="callback" type="string" required="false" default="">
	<cfargument name="callbackReturnField" type="string" required="false" default="">
	
	<cfscript>
		var APIPostToNewWindow = false;
		var rtnHTML = "";
		var formResultHTML = "";
		// Find out if the CE contains an RTE field
		var formContainRTE = application.ADF.ceData.containsFieldType(arguments.formID, "formatted_text_block");
	</cfscript>
	
	<cfsavecontent variable="cookieLoader">
		<cfoutput>
			<script type="text/javascript">
				function cookie(key, value, options) {
				    // key and value given, set cookie...
				    if (arguments.length > 1 && (value === null || typeof value !== "object")) {
				        options = jQuery.extend({}, options);
				        if (value === null) {
				            options.expires = -1;
				        }
				        if (typeof options.expires === 'number') {
				            var days = options.expires, t = options.expires = new Date();
				            t.setDate(t.getDate() + days);
				        }
				        return (commonspot.lightbox.getPageWindow().document.cookie = [
				            encodeURIComponent(key), '=',
				            options.raw ? String(value) : encodeURIComponent(String(value)),
				            options.expires ? '; expires=' + options.expires.toUTCString() : '', // use expires attribute, max-age is not supported by IE
				            options.path ? '; path=' + options.path : '',
				            options.domain ? '; domain=' + options.domain : '',
				            options.secure ? '; secure' : ''
				        ].join(''));
				    }
				    // key and possibly options given, get cookie...
				    options = value || {};
				    var result, decode = options.raw ? function (s) { return s; } : decodeURIComponent;
				    return (result = new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)').exec(commonspot.lightbox.getPageWindow().document.cookie)) ? decode(result[1]) : null;
				};
			</script>
		</cfoutput>
	</cfsavecontent>
	<!--- Result from the Form Submit --->
	<cfsavecontent variable="formResultHTML">
		<!--- Render the dlg header --->
		<cfscript>
			CD_DialogName = request.params.title;
			CD_Title=CD_DialogName;
			CD_IncludeTableTop=1;
			CD_CheckLock=0;
			CD_CheckLogin=1;
			CD_CheckPageAlive=0;
         APIPostToNewWindow = false;
		</cfscript>
		<CFINCLUDE TEMPLATE="/commonspot/dlgcontrols/dlgcommon-head.cfm">
		<cfoutput><tr><td></cfoutput>
		<!--- Set the form result html to the argument if defined --->
		<cfif LEN(arguments.customizedFinalHtml)>
			<cfoutput>#arguments.customizedFinalHtml#</cfoutput>
		<cfelse>
			<cfoutput>
				<cfscript>
					variables.scripts.loadADFLightbox(force=1);
				</cfscript>
				<cfif Len(arguments.callback)>
					#cookieLoader#
				</cfif>
				<script type='text/javascript'>
					jQuery(document).ready(function(){
						<cfif Len(arguments.callback)>
							cookieValue = cookie("tempFormCookie");
							getCallback('#arguments.callback#', cookieValue);
							cookie("tempFormCookie",null);
						<cfelse>
							if ( "#arguments.lbAction#" == "refreshparent" )
								closeLBReloadParent();
							closeLB();
						</cfif>
					});
				</script>
				Multimedia has been created. Trying to automatically submit.
			</cfoutput>
		</cfif>
		<!--- Render the dlg footer --->
		<cfoutput></tr></td></cfoutput>
		<CFINCLUDE template="/commonspot/dlgcontrols/dlgcommon-foot.cfm">
	</cfsavecontent>
	
	<cfif NOT renderResult>
		<!--- HTML for the form --->
		<cfsavecontent variable="rtnHTML">
			<cfscript>
				CD_DialogName = request.params.title;
				CD_Title=CD_DialogName;
				CD_IncludeTableTop=1;
				CD_CheckLock=0;
				CD_CheckLogin=1;
				CD_CheckPageAlive=0;
				//CD_OnLoad="handleOnLoad();";
				//CD_OnLoad="";
          		APIPostToNewWindow = false;
			</cfscript>
			<CFINCLUDE TEMPLATE="/commonspot/dlgcontrols/dlgcommon-head.cfm">
			<cfoutput>
				<cfscript>
					variables.scripts.loadADFLightbox(force=1);
				</cfscript>
				<!--- Call the UDF function --->
				<tr><td>#Server.CommonSpot.UDF.UI.RenderSimpleForm(arguments.dataPageID, arguments.formID, APIPostToNewWindow, formResultHTML)#</td></tr>
				<cfif Len(arguments.callback)>
					#cookieLoader#
					<script type="text/javascript">
						jQuery("form").change(function(){
							cookie("tempFormCookie",getFieldValue("#callbackReturnField#"));
						});
						function getFieldValue(fieldName){
							if(fieldName.length > 0){
								var name = jQuery("[value='" + fieldName + "'][name$='fieldName']").attr("name");
								name = name.replace("_fieldName","");
								return jQuery("[name='"+name+"']").attr("value");
							}else{
								return null;
							}
						}
					</script>
				</cfif>
			</cfoutput>
			<CFINCLUDE template="/commonspot/dlgcontrols/dlgcommon-foot.cfm">
		</cfsavecontent>
	<cfelse>
		<cfset rtnHTML = formResultHTML>
	</cfif>
	<cfreturn rtnHTML>
	
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$renderDeleteForm
Summary:	
	Renders the standard datasheet delete module
Returns:
	Void
Arguments:
	Numeric formID
	Numeric dataPageID
	String title
History:
 	2009-10-25 - RLW - Created
	2010-02-18 - MFC - Returns a HTML for delete form.
	2010-04-14 - GAC - Updated to work with the ADFLightbox Framework
	2010-07-23 - SFS - Added argument to supply the lightbox dialog with a title needed for CS CE delete function.
	2010-10-29 - MFC - Updated the delete form for CS 6 Lightbox styles.
--->
<cffunction name="renderDeleteForm" access="public" returntype="String" hint="Renders the standard datasheet delete module">
	<cfargument name="formID" type="numeric" required="true" hint="The FormID for the Custom Element">
	<cfargument name="dataPageID" type="numeric" required="true" hint="the DataPageID for the record being deleted">
	<cfargument name="title" type="string" required="no" default="Delete Record" hint="The title of the dialog displayed while deleting">
	
	<cfset var deleteFormHTML = "">
	<cfsavecontent variable="deleteFormHTML">
		<!--- Render the dlg header --->
		<cfscript>
			CD_DialogName = request.params.title;
			CD_Title=CD_DialogName;
			CD_IncludeTableTop=1;
			CD_CheckLock=0;
			CD_CheckLogin=1;
			CD_CheckPageAlive=0;
		</cfscript>
		<CFINCLUDE TEMPLATE="/commonspot/dlgcontrols/dlgcommon-head.cfm">
		<cfoutput><tr><td></cfoutput>
		<cfscript>
			variables.scripts.loadJquery('1.3.2', 1);
			variables.scripts.loadADFLightbox(force=1);
			
			//targetModule = "#request.subsiteCache[1].url#datasheet-modules/delete-form-data.cfm";
			targetModule = "/ADF/extensions/datasheet-modules/delete_element_handler.cfm";
			request.params.pageID = arguments.dataPageID;
			request.params.formID = arguments.formID;
			CD_DIALOGNAME = arguments.title;
		</cfscript>
		<cfinclude template="/ADF/extensions/datasheet-modules/delete_element_handler.cfm">
		<!--- Render the dlg footer --->
		<cfoutput></tr></td></cfoutput>
		<CFINCLUDE template="/commonspot/dlgcontrols/dlgcommon-foot.cfm">
	</cfsavecontent>
	<cfreturn deleteFormHTML>
</cffunction>

</cfcomponent>