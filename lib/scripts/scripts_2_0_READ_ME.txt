************************************
  ADF Scripts 2.0 Developer README
************************************

CommonSpot 10 includes an optimized approach to loading Javascript and CSS files ("resources").
Code that does these things needs to be updated to take advantage of these new capabilities, and to integrate well with CommonSpot.
The ADF 2.0 scripts component uses this new infrastructure.
This document describes some of the changes, and how to make use of these new capabilities, in both the ADF and CommonSpot.

The Scripts component loadSomeLibrary() methods now load registered CommonSpot resources.
  You must ensure that the resources you need have been registered in CommonSpot Site Admin.
  NOTE: Resources must be registered separately in each site where they'll be used.

To register all resources included in the ADF at once, install and reset the ADF, then do this (once):
     		http://{your-commonspot-site}/?configADF=1
     	Or from a custom script file run:
     		<cfmodule template="/ADF/lib/scripts/registerAllScripts.cfm">
  By default it will skip resources that already exist.
  To update them instead, use:
  			http://{commonspot-site}/?reconfigADF=1
  		Or from a custom script file run:
  			<cfmodule template="/ADF/lib/scripts/registerAllScripts.cfm" updateExisting="1">
  Updating will fail for each script if the existing name is an alias, not an actual resource.

  To register (or re-register) only a minimum set of ADF resources use the 'scriptsPackage' parameter:
  			http://{commonspot-site}/?configADF=1&scriptsPackage=min OR http://{commonspot-site}/?reconfigADF=1&scriptsPackage=min
  		Or in a custom script file run:
  			<cfmodule template="/ADF/lib/scripts/registerAllScripts.cfm" scriptsPackage="min">
  			Or:
  			<cfmodule template="/ADF/lib/scripts/registerAllScripts.cfm" updateExisting="1" scriptsPackage="min">
  		Note: Registering the minimum set of ADF resources may prevent some ADF and ADF App lib methods, custom scripts, custom field types
  				and datasheet modules from working correctly. Missing resources dependencies will need to be registered in
  				CommonSpot manually. Although, at runtime missing resource dependencies to show up as entries in the site's CommonSpot error logs.

	Important: You must be logged in to the CommonSpot site to use the 'configADF' URL parameters.

By default, the script registers jQuery (and jQueryMigrate) to load in the head, so existing jQuery calls in the page body won't break.
  All other javascript libraries load in the foot.
  However, that's not optimal for page load time, because page rendering blocks until jQuery loads, and it's a sizable library.
  A better strategy would be to render all your javascript in the foot, then you can change the registration for jQuery  to load it in the foot.
  To do that:
    - Register any custom js files load in the foot
    - Use Application.ADF.scripts.addFooterJS(required string js, required string resourceGroup) to queue ad hoc js for output there

In general, you should register specific versions of a library with a name that includes the version, and create an alias without it.
  For example, register 'JQuery 1.11', and create an alis named 'JQuery' pointing to it.
  That lets you re-point jQuery to a different version in one place.
  It also allows callers to request either a specific version, or the generic one.
  The ADF script mentioned above does that.

In custom field types, custom scripts or render handlers, use the ADF scripts methods to load each resource:
	Examples:
		- Application.ADF.scripts.LoadJQuery()
		- Application.ADF.scripts.LoadJQueryUI();

	Or you can load a list of registered resources directly using:
	- Application.ADF.scripts.loadResources(resourcesList="jQuery,jQueryUI");
		Note: This example assumes that 'jQuery' and 'jQueryUI' are registered resource names or aliases

	Important: Using the ADF (or the CommonSpot) loadResources() methods bypass any additional features and/or dependencies
				  built into the ADF scripts 'load' methods.

If your custom field type renderer load resources itself, or uses the Scripts version to do so, you should also implement getResourceDependencies(), and return the list of resource names you're loading.
  You must include any results from classes further up the inheritance hierarchy, like this:
    return listAppend(super.getResourceDependencies(), "Resources,This,Component,Loads");

    Note: Examples of loadResourceDependencies() and getResourceDependencies() can be seen in the ADF Custom Field Types
    		 found in the /ADF/extensions/customfields/{filetypename}/{filetypename}_render.cfc files.

Use these methods to load ad hoc css in the header, or js in the footer:
  - Application.ADF.scripts.addHeaderCSS(required string css, required string resourceGroup);
  - Application.ADF.scripts.addFooterJS(required string js, required string resourceGroup);
 		 Note: These ADF wrapper calls can include the script or style tags. But the direct CommonSpot UDF calls should not.

To add generic HTML, meta tags for example, use these methods:
  - Application.ADF.scripts.addHeaderHTML(required string html, required string resourceGroup);
  - Application.ADF.scripts.addFooterHTML(required string html, required string resourceGroup);

Note that resources themselves load their own js and css files, but DO NOT load any outside dependencies they may have.
  For example, if you want jQueryUI, you also need to load jQuery itself, and a theme.
  The ADF Scripts component methods in general do this for you.
  For example, application.ADF.scripts.LoadJQueryUI() loads jQuery, JQueryUI, and either the default UI theme or a requested one.

The version and force arguments to all Scripts component loadSomeLibrary() methods are ignored
  The version used is determined by registration of the resource.

See the CommonSpot 10 Developers Guide for the information regarding using these CommonSpot UDFs directly:
 - Server.CommonSpot.udf.resources.loadResources(required string resourcesList);
 - Custom field type base class method:
 		- loadResources(required string resourcesList);
 - Server.CommonSpot.udf.resources.addHeaderCSS(required string css, required string resourceGroup);
 		Note: this call accepts css directly, so you don't need and shouldn't include the style tags.
 - Server.CommonSpot.udf.resources.addFooterJS(required string js, required string resourceGroup);
 		Note: this call accepts js directly, so you don't need and shouldn't include the script tags.
 - Server.CommonSpot.udf.resources.addHeaderHTML(required string html, required string resourceGroup);
 - Server.CommonSpot.udf.resources.addFooterHTML(required string html, required string resourceGroup);
