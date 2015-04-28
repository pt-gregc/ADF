<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the Starter App directory

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
	cfformprotect
Name:
	cfformprotect_render.cfm
Summary:
	Gives a text field allowing user to enter file locations. Then verifies them.
ADF Requirements:
History:
	2014-01-02 - GAC - Added comment header block
--->

<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	incScript = xparams.cfformprotect;
	
	// Load CFFORMPROTECT
	cffp = application.ADF.forms.loadCFFormProtect();
</cfscript>


<!-- include is here -->
 <!--- <cfinclude template = "#incScript#"> --->
<!-- include ends -->

<cfoutput>
<!--- load the file that grabs all values from the ini file --->
<cfinclude template="/ADF/thirdParty/cfformprotect/cffpConfig.cfm">

<!--- check the config (from the ini file)to see if each test is turned on --->
<cfif application.cfformprotect.config.mouseMovement>
	<!--- If the user moves their mouse, put the distance in this field (JavaScript function handles this).
				cffpVerify.cfm will make sure the user at least used their keyboard. A spam
				bot won't trigger this --->
				
	<input type="hidden" name="formfield1234567891" value="" id="formfield1234567891">
	<!--- <input type="hidden" name="formfield1234567891_FIELDNAME" id="formfield1234567891_FIELDNAME" value="formfield1234567891">  --->
				
	<!---<cfhtmlhead text="<script type='text/javascript' src='#request.site.url##cffpPath#/js/mouseMovement.js'></script>">--->
	<cfset application.ADF.scripts.loadmouseMovement()>
</cfif>

<cfif application.cfformprotect.config.usedKeyboard>
	<!--- If the types on their keyboard, put the amount of keys pressed in this field.
				cffpVerify.cfm will make sure the user at least used their keyboard. A spam
				bot won't trigger this --->
	<input type="hidden" name="formfield1234567892" id="formfield1234567892" value="">
	<!--- <input type="hidden" name="formfield1234567892_FIELDNAME" id="formfield1234567892_FIELDNAME" value="formfield1234567892">  --->
	<!---<cfhtmlhead text="<script type='text/javascript' src='#request.site.url##cffpPath#/js/usedKeyboard.js'></script>">--->
	<cfset application.ADF.scripts.loadUsedKeyboard()>
</cfif>


<cfif application.cfformprotect.config.timedFormSubmission>
	<!--- in cffpVerify.cfm I will verify that the amount of time it took to
				fill out this form is 'normal' (the time limits are set in the ini file)--->
	<!--- get the current time, obfuscate it and load it to this hidden field --->
	<cfset currentDate = dateFormat(now(),'yyyymmdd')>
	<cfset currentTime = timeFormat(now(),'HHmmss')>
	<!--- Add an arbitrary number to the date/time values to mask them from prying eyes --->
	<cfset blurredDate = currentDate+19740206>
	<cfset blurredTime = currentTime+19740206>
	<input type="hidden" name="formfield1234567893" value="#blurredDate#,#blurredTime#">
	<input type="hidden" name="formfield1234567893_FIELDNAME" id="formfield1234567893_FIELDNAME" value="formfield1234567893"> 
</cfif>

<cfif application.cfformprotect.config.hiddenFormField>
	<!--- A lot of spam bots automatically fill in all form fields.  cffpVerify.cfm will
				test to see if this field is blank. The "leave this empty" text is there for blind people,
				who might see this hidden field --->
	<span style="display:none">Leave this field empty <input type="text" name="formfield1234567894" value=""></span>
	<input type="hidden" name="formfield1234567894_FIELDNAME" id="formfield1234567894_FIELDNAME" value="formfield1234567894"> 
</cfif>
</cfoutput>

