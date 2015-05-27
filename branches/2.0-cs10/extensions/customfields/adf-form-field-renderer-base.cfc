<cfcomponent displayname="ADF form-field-renderer-base" extends="commonspot.public.form-field-renderer-base" hint="This the base component for the CFC renderers">

<!---
	2015-05-27 - DRM - added renderCSFormScripts() call
--->
<cfscript>
	application.ADF.fields.renderCSFormScripts(); // make js form utils available to all renderers
</cfscript>

</cfcomponent>