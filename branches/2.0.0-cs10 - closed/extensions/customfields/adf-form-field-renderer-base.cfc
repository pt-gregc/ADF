<cfcomponent displayname="ADF form-field-renderer-base" extends="commonspot.public.form-field-renderer-base" hint="This the base component for the CFC renderers">

<!---
	2015-05-27 - DRM - added renderCSFormScripts() call
	2015-08-28 - DRM - removed that method and the call to it
							 moved those functions into cs-form-utilities.js, registered it as resource 'ADFcsFormUtilities'
							 NOT loading it automatically, code that needs those should load the resource itself
						If the ADFcsFormUtilities is a registered resource in CommonSpot use this code to call it:
							Server.CommonSpot.udf.resources.loadResources("ADFcsFormUtilities");
--->

</cfcomponent>