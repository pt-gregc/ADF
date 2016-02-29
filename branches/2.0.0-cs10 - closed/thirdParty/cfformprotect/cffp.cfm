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
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Custom Field Type:
	cffp.cfm
Name:
	cffp

History:
	2016-02-25 - DMB - Added resource load.
--->
<!--- This path should start from the web root and work forward from
			there, if you don't have it in the web root --->
<cfset cffpPath = "/cfformprotect">

<!--- load the file that grabs all values from the ini file --->
<cfinclude template="#cffpPath#/cffpConfig.cfm">

<!--- Bas van der Graaf (bvdgraaf@e-dynamics.nl): Make sure JS is only included once when securing multiple forms with cfformprotect. --->
<cfif not structkeyExists(request,"cffpJS")>
	<!--- <cfhtmlhead text="<script type='text/javascript' src='#cffpPath#/js/cffp.js'></script>"> --->
	<cfset application.ADF.scripts.loadUnregisteredResource("#cffpPath#/js/cffp.js", "Javascript", "head", "secondary", 0, 0)>
	<cfset request.cffpJS = true>
</cfif>

<!--- check the config (from the ini file)to see if each test is turned on --->
<cfif cffpConfig.mouseMovement>
	<!--- If the user moves their mouse, put the distance in this field (JavaScript function handles this).
				cffpVerify.cfm will make sure the user at least used their keyboard. A spam
				bot won't trigger this --->
	<input id="fp<cfoutput>#createuuid()#</cfoutput>" type="hidden" name="formfield1234567891" class="cffp_mm" value="" />
</cfif>

<cfif cffpConfig.usedKeyboard>
	<!--- If the types on their keyboard, put the amount of keys pressed in this field.
				cffpVerify.cfm will make sure the user at least used their keyboard. A spam
				bot won't trigger this --->
	<input id="fp<cfoutput>#createuuid()#</cfoutput>" type="hidden" name="formfield1234567892" class="cffp_kp" value="" />
</cfif>

<cfif cffpConfig.timedFormSubmission>
	<!--- in cffpVerify.cfm I will verify that the amount of time it took to
				fill out this form is 'normal' (the time limits are set in the ini file)--->
	<!--- get the current time, obfuscate it and load it to this hidden field --->
	<cfset currentDate = dateFormat(now(),'yyyymmdd')>
	<cfset currentTime = timeFormat(now(),'HHmmss')>
	<!--- Add an arbitrary number to the date/time values to mask them from prying eyes --->
	<cfset blurredDate = currentDate+19740206>
	<cfset blurredTime = currentTime+19740206>
	<input id="fp<cfoutput>#createuuid()#</cfoutput>" type="hidden" name="formfield1234567893" value="<cfoutput>#blurredDate#,#blurredTime#</cfoutput>" />
</cfif>

<cfif cffpConfig.hiddenFormField>
	<!--- A lot of spam bots automatically fill in all form fields.  cffpVerify.cfm will
				test to see if this field is blank. The "leave this empty" text is there for blind people,
				who might see this hidden field --->
	<span style="display:none">Leave this field empty <input id="fp<cfoutput>#createuuid()#</cfoutput>" type="text" name="formfield1234567894" value="" /></span>
</cfif>