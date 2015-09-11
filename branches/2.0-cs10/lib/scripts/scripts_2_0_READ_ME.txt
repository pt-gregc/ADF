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

To register all resources included in the ADF at once, install the ADF, then do this (once):
     <cfmodule template="/ADF/lib/scripts/registerAllScripts.cfm">
  By default it will skip resources that already exist.
  To update them instead, pass the attribute updateExisting="1".
  Updating will fail if the existing name is an alias, not an actual resource.

By default, the script registers jQuery (and jQueryMigrate) to load in the head, so existing jQuery calls in the page body won't break.
  All other javascript libraries load in the foot.
  However, that's not optimal for page load time, because page rendering blocks until jQuery loads, and it's a sizable library.
  A better strategy would be to render all your javascript in the foot, then you can change the registration for jQuery  to load it in the foot.
  To do that:
    - Register any custom js files load in the foot
    - Use Server.CommonSpot.udf.resources.addFooterJS() to queue ad hoc js for output there

In general, you should register specific versions of a library with a name that includes the version, and create an alias without it.
  For example, register 'JQuery 1.11', and create an alis named 'JQuery' pointing to it.
  That lets you re-point jQuery to a different version in one place.
  It also allows callers to request either a specific version, or the generic one.
  The ADF script mentioned above does that.
  
In a custom field type renderer component, use this base class method to load registered resources yourself:
  loadResources(required string resourcesList);
  
In custom scripts or render handlers, use this CommonSpot UDF:
  Server.CommonSpot.udf.resources.loadResources(required string resourcesList);

If your custom field type renderer load resources itself, or uses the Scripts version to do so, you should also implement getResourceDependencies(), and return the list of resource names you're loading.
  You must include any results from classes further up the inheritance hierarchy, like this:
    return listAppend(super.getResourceDependencies(), "Resources,This,Component,Loads");

Use these methods to load ad hoc css in the header, or js in the footer:
  addHeaderCSS(required string css, required string resourceGroup);
  addFooterJS(required string js, required string resourceGroup);
  Note that those calls accept css and js directly, so you don't need and shouldn't include script or style tags.

To add generic HTML, meta tags for example, use these methods:
  addHeaderHTML(required string html, required string resourceGroup);
  addFooterHTML(required string html, required string resourceGroup);

Note that resources themselves load their own js and css files, but DO NOT load any outside dependencies they may have.
  For example, if you want jQueryUI, you also need to load jQuery itself, and a theme.
  The ADF Scripts component methods in general do this for you.
  For example, application.ADF.scripts.LoadJQueryUI() loads jQuery, JQueryUI, and either the default UI theme or a requested one.

The version and force arguments to all Scripts component loadSomeLibrary() methods are ignored
  The version used is determined by the resource registered.