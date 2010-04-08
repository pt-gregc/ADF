<!--- load the file that grabs all values from the ini file --->
<cfinclude template="/ADF/thirdParty/cfformprotect/cffpConfig.cfm">

<!--- check the config (from the ini file)to see if each test is turned on --->
<cfif application.cfformprotect.config.mouseMovement>
	<!--- If the user moves their mouse, put the distance in this field (JavaScript function handles this).
				cffpVerify.cfm will make sure the user at least used their keyboard. A spam
				bot won't trigger this --->
	<input type="hidden" name="formfield1234567891" id="formfield1234567891" value="">
	<!---<cfhtmlhead text="<script type='text/javascript' src='#request.site.url##cffpPath#/js/mouseMovement.js'></script>">--->
	<cfset application.ADF.scripts.loadmouseMovement()>
</cfif>

<cfif application.cfformprotect.config.usedKeyboard>
	<!--- If the types on their keyboard, put the amount of keys pressed in this field.
				cffpVerify.cfm will make sure the user at least used their keyboard. A spam
				bot won't trigger this --->
	<input type="hidden" name="formfield1234567892" id="formfield1234567892" value="">
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
	<input type="hidden" name="formfield1234567893" value="<cfoutput>#blurredDate#,#blurredTime#</cfoutput>">
</cfif>

<cfif application.cfformprotect.config.hiddenFormField>
	<!--- A lot of spam bots automatically fill in all form fields.  cffpVerify.cfm will
				test to see if this field is blank. The "leave this empty" text is there for blind people,
				who might see this hidden field --->
	<span style="display:none">Leave this field empty <input type="text" name="formfield1234567894" value=""></span>
</cfif>