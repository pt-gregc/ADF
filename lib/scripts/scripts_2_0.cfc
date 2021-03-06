component displayname="scripts_2_0" extends="scripts_1_2" hint="Scripts functions for the ADF Library" output="no"
{
	/*
		The contents of this file are subject to the Mozilla Public License Version 1.1
		(the "License"); you may not use this file except in compliance with the
		License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

		Software distributed under the License is distributed on an "AS IS" basis,
		WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
		the specific language governing rights and limitations under the License.

		The Original Code is comprised of the ADF directory

		The Initial Developer of the Original Code is
		PaperThin, Inc.  Copyright (c) 2009-2016.
		All Rights Reserved.

		By downloading, modifying, distributing, using and/or accessing any files
		in this directory, you agree to the terms and conditions of the applicable
		end user license agreement.
	*/

	/* ***************************************************************
		Author:
			PaperThin, Inc.
		Name:
			scripts_2_0.cfc
		Summary:
			Scripts functions for the ADF Library
		Version:
			2.0
		History:
			2012-12-07 - RAK - Created - New v1.2
			2013-03-01 - GAC - Updated jQuery iCalendar comment headers
			2013-09-05 - GAC - Updated with functions for and jQuery qTip2 jQuery ImagesLoaded
			2013-09-27 - DMB - Added a function to load jQuery Cycle2 lib
			2014-05-19 - GAC - Added functions for jQuery plug-ins: jEditable, Calx, Calculation
			2014-09-16 - GAC - Updated references to thirdparty to thirdParty for case sensitivity
			2015-02-17 - GAC - Added a loadjQueryTimeAgo function to load version 1.4 by default
			2015-04-22 - GAC - Added the loadCKEditor and the loadTypeAheadBundle functions
			2015-06-10 - ACW - Updated the component extends to no longer be dependant on the 'ADF' in the extends path
			2015-07-21 - GAC - Added and updated the loadCFJS function for CFJS v1.3
			2015-08-20 - DRM - Created 2.0 version for ADF 2.0 and CommonSpot 10
			2015-11-18 - DRM - Added loadUnregisteredResource method
									 Modified loadTheme to use an unregistered resource if possible
			2016-02-26 - GAC - Updated default params loadUnregisteredResource()
			2016-03-14 - GAC - Added the renderQueued() method
								  - Updated loadTheme to limit error log entries to only one per request
	*/


	/* PROPERTIES */
	property name="version" type="string" default="2_0_2";
	property name="type" value="singleton";
	property name="wikiTitle" value="Scripts_2_0";


	/* EXTERNAL COMPONENTS */
	variables.resourceAPI = Server.CommonSpot.ObjectFactory.getObject("Resource");


	/* UTILITIES */

	public void function loadResources(required string resourcesList)
	{
		Server.CommonSpot.udf.resources.loadResources(arguments.resourcesList);
	}

	/*
		URL: URL of the resource to load
		resourceType: 'JavaScript', 'StyleSheet', or the name of a custom resource type
		location: 'head' or 'foot'
		resourceGroup: one of 'primary', 'secondary' or 'tertiary'
		canCombine default=0: boolean, except empty str means auto: combine if we can read the file from expandPath(URL), checked when rendering resource request URLs
		canMinify default=0; boolean
	*/
	public void function loadUnregisteredResource(required string URL, required string resourceType, required string location, required string resourceGroup, string canCombine=0, string canMinify=0)
	{
		Server.CommonSpot.udf.resources.loadUnregisteredResource(argumentCollection=arguments);
	}

	public void function addHeaderHTML(required string html, required string resourceGroup) // resourceGroup: PRIMARY, SECONDARY, TERTIARY
	{
		Server.CommonSpot.udf.resources.addHeaderHTML(html, resourceGroup);
	}

	public void function addFooterHTML(required string html, required string resourceGroup) // resourceGroup: PRIMARY, SECONDARY, TERTIARY
	{
		Server.CommonSpot.udf.resources.addFooterHTML(html, resourceGroup);
	}

	public void function addFooterJS(required string js, required string resourceGroup) // resourceGroup: PRIMARY, SECONDARY, TERTIARY
	{
		// Strip the script tags
		arguments.js = ReplaceNoCase(arguments.js, "</script>", "", "ALL");
		arguments.js = ReReplaceNoCase(arguments.js, "<[[:space:]]*script.*?>", "", "ALL");

		Server.CommonSpot.udf.resources.addFooterJS(arguments.js, arguments.resourceGroup);
	}

	public void function addHeaderCSS(required string css, required string resourceGroup) // resourceGroup: PRIMARY, SECONDARY, TERTIARY
	{
		// Strip the style tags
		arguments.css = ReplaceNoCase(arguments.css, "</style>", "", "ALL");
		arguments.css = ReReplaceNoCase(arguments.css, "<[[:space:]]*style.*?>", "", "ALL");

		Server.CommonSpot.udf.resources.addHeaderCSS(arguments.css, arguments.resourceGroup);
	}
	
	public void function renderQueued() 
	{
		Server.CommonSpot.UDF.resources.renderQueued();
	}

	/*
		generic theme/skin loader
		assumes there's a default version registered as a resource, and that some portion of its path is the theme/skin name

		args:
			themeName: name of theme you want to load (actually that portion of the file path, regardless of how it's referred to elsewhere)
			defaultResourceName: name of the registered default resource
			parentKey: portion of the default resource url BEFORE the one that's the theme name

		History:
			2016-01-07 - GAC - Updated the loadTheme to check if the ThemeName is a registered resource before attempting
								build the theme's CSS file path from defaultResource's information
			2016-02-08 - AW - Updated resourceAPI.getList()
			2016-03-14 - GAC - Updated to limit a loadTheme error log entry to only one per request
	*/
	public void function loadTheme(string themeName, string defaultResourceName, string parentKey)
	{
		var regResourceList = resourceAPI.getList(searchString=arguments.themeName, searchOperator='equals');
		var defaultResourceList = "";
		var res = "";
		var cssURL = "";
		var listPos = 0;
		var errMsg = "";
		var themeLoadFailed = false;

		// if the themeName is a registered resource then use it
		if ( regResourceList.RecordCount == 1 && arrayLen(regResourceList.earlyLoadSourceArray[1]) == 1 )
		{
			loadResources(arguments.themeName);
		}
		else
		{
			// if the themeName is NOT registered resource... then attempt to build a path and load it.
			defaultResourceList = resourceAPI.getList(searchString=arguments.defaultResourceName, searchOperator='equals');

			if (defaultResourceList.RecordCount == 1 && arrayLen(defaultResourceList.earlyLoadSourceArray[1]) == 1)
			{
				res = defaultResourceList.earlyLoadSourceArray[1][1];
				cssURL = res.sourceURL;
				listPos = listFindNoCase(cssURL, arguments.parentKey, "/");
				
				// If possible replace the defaultThemeName with the passed in themeName in the defaultResouce's URL
				// ... otherwise just use the registered Default Theme URL
				if (listPos > 0 && listPos < (listLen(cssURL, "/") - 1))
				{
					cssURL = listSetAt(cssURL, listPos + 1, arguments.themeName, "/");
					if ( fileExists(Request.Site.Dir & cssURL) )
						loadUnregisteredResource(cssURL, "Stylesheet", "head", "secondary", 0, 0);
				 	else
						themeLoadFailed = true;
				}
				else
				    themeLoadFailed = true;

				if ( themeLoadFailed )
				{
					 // This case handles the bad cssURL and uses the default resource
					loadResources(arguments.defaultResourceName);

					if ( !StructKeyExists(request,"ADFloadTheme#arguments.themeName#" ) )
				 	{
						errMsg = "Could not find the requested theme resource '#arguments.themeName#', using the default theme '#arguments.defaultResourceName#' instead. Please register the required theme as a CommonSpot Resource.";
						Server.CommonSpot.addLogEntry(errMsg);
						//throw(errMsg);

						request["ADFloadTheme#arguments.themeName#"] = 1;
					}
				}
			}
			else
			{
				 if ( !StructKeyExists(request,"ADFloadTheme#arguments.themeName#" ) )
				 {
				   // This case handles the missing default resource ... see log for more details
					 errMsg = "Could not find the requested theme resources '#arguments.themeName#' or the default theme '#arguments.defaultResourceName#'. Please register the required themes as CommonSpot Resources.";
					 Server.CommonSpot.addLogEntry(errMsg);
					 //throw(errMsg);

					 request["ADFloadTheme#arguments.themeName#"] = 1;
				}
			}
		}
	}


	/* PRIMARY - MAJOR LIBRARIES */


	/*
		History:
			2015-09-24 - GAC - Added jQuery Migrate to load with jQuery by default
							 - Added a useMigrate parameter to disable jQuery Migrate
			2016-01-07 - GAC - Set useMigrate to be disabled by default
								- Switched to used addFooterJS instead of addFooterHTML
	*/
	public void function loadJQuery(string version="", boolean force=0, boolean noConflict=0, boolean useMigrate=0 )
	{
		loadResources("jQuery");

		if (arguments.noConflict)
			addFooterJS("<script>jQuery.noConflict();</script>", "PRIMARY");

		// Load the Migrate plugin
		if ( arguments.useMigrate )
			loadResources("jQueryMigrate");
	}

	public void function loadJQueryMigrate()
	{
		loadResources("jQuery,jQueryMigrate");
	}

	/*
		History:
			2016-02-23 - GAC - Allow loadTheme() to handle if a themeName was not passed in
	*/
	public void function loadJQueryUI(string version="", string themeName="", boolean force=0, string defaultThemeOverride="")
	{
		arguments.themeName = trim(arguments.themeName);
		
		loadResources("jQuery,jQueryUI");
		
		if ( arguments.themeName == "" )
			arguments.themeName = "jQueryUIDefaultTheme";

		loadTheme(arguments.themeName, "jQueryUIDefaultTheme", "css");
	}

	/*
		History:
			2016-02-19 - GAC - Added as a passthrough for existing code that was looking for loadJQueryUIStyles()
			2016-02-23 - GAC - Allow loadTheme() to handle if a themeName was not passed in
	*/
	public void function loadJQueryUIStyles(string themeName="")
	{
		arguments.themeName = trim(arguments.themeName);

		if ( arguments.themeName == "" )
			arguments.themeName = "jQueryUIDefaultTheme";

		loadTheme(arguments.themeName, "jQueryUIDefaultTheme", "css");
	}

	public void function loadJQueryMobile(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryMobile");
	}

	public void function loadBootstrap(string version="", boolean force=0, boolean useDefaultTheme=0)
	{
		loadResources("jQuery,Bootstrap");
		if (arguments.useDefaultTheme)
			loadResources("BootstrapDefaultTheme");
	}

	public void function loadBootstrapDefaultTheme()
	{
		loadResources("BootstrapDefaultTheme");
	}

	/* SECONDARY - PLUGINS ETC */

    /*
        History:
            2016-02-10 - ACW - Added the "CSLightbox" as a CommonSpot registered resource
            2016-06-10 - GAC - Updated to make sure Height/Width are numeric values when passed in via URL params
									  - Updated to make sure no HTML tags are passed in via the Title/Subtitle URL params
    */
	public void function loadADFLightbox(string version="", boolean force=0)
	{
		var js = "";

		// NOTE: This loadResources MUST contain "CSLightbox" which is a CommonSpot registered resource
	 	loadResources("jQuery,ADFLightbox,CSLightbox");

		if (structKeyExists(request,"ADFLightboxLoaded"))
			return; // TODO: throw("Why are you loadinging again!");
		else
			request.ADFLightboxLoaded = 1;

		// Set a default Width
		if ( !StructKeyExists(request.params, "width") OR !isNumeric(request.params.width) )
			request.params.width = 500;

		// Set a default Height
		if ( !StructKeyExists(request.params, "height") OR !isNumeric(request.params.height) )
			request.params.height = 500;

		// Set a default Title
		if ( !StructKeyExists(request.params, "title") )
			request.params.title = "";

		// Set a default Subtitle
		if ( !StructKeyExists(request.params, "subtitle") )
			request.params.subtitle = "";

		// Make sure that no html tags are pass to the ADF lightbox JavaScript
		// NOTE: Can NOT use local dependency (variables.data.) here... since it is called by lightboxProxy 
		if ( LEN(TRIM(request.params.title)) )
			request.params.title = Application.ADF.data.stripHTMLTags(request.params.title);
		if ( LEN(TRIM(request.params.subtitle)) )
			request.params.subtitle = Application.ADF.data.stripHTMLTags(request.params.subtitle);

		// Build the ADFlightbox INIT JS block
		saveContent variable="js"
		{
			writeOutput
			("
				jQuery(function()
				{
					initADFLB();
					if ( (typeof commonspot != 'undefined') && (typeof commonspot.lightbox != 'undefined') )
							commonspot.lightbox.initCurrent(#request.params.width#, #request.params.height#, { title: '#request.params.title#', subtitle: '#request.params.subtitle#', close: 'true', reload: 'true' });
				});
			");
		}
		addFooterJS(js,"TERTIARY");
	}

	public void function loadADFStyles()
	{
		loadResources("ADFStyles");
	}

	public void function loadAutoGrow(string version="", boolean force=0)
	{
		loadResources("jQuery,AutoGrow");
	}

	public void function loadCFJS(string version="", boolean force=0)
	{
		loadResources("jQuery,CFJS");
	}

	public void function loadDateFormat(string version="", boolean force=0)
	{
		loadResources("DateFormat");
	}

	public void function loadDateJS(string version="", boolean force=0)
	{
		loadResources("DateJS");
	}

	public void function loadDropCurves(string version="", boolean force=0)
	{
		loadResources("jQuery,DropCurves");
	}

	public void function loadDynatree(boolean force=0)
	{
		loadResources("jQuery,jQueryUI,jQueryCookie,Dynatree");
	}

	public void function loadFileUploader(boolean force=0)
	{
		loadResources("jQuery,FileUploader");
	}

	public void function loadFontAwesome(string version="", boolean force=0, boolean dynamicHeadRender=0, string overridePath="")
	{
		var scriptPath = trim(arguments.overridePath);
		if (scriptPath != "" && listLast(scriptPath, ".") == "css" && fileExists(expandPath(scriptPath)))
			loadUnregisteredResource(scriptPath, "Stylesheet", "head", "secondary", 0, 0);
		else
			loadResources("FontAwesome"); // includes both base version and ADF css extension
	}

	public void function loadGalleryView(string version="", string themeName="", boolean force=0)
	{
		// NOTE: themeName arg was ignored in prior (1.2) version
		loadResources("jQuery,GalleryView,jQueryTimers,jQueryEasing");
	}

	public void function loadJQueryTimers()
	{
		loadResources("jQuery,jQueryTimers");
	}

	public void function loadJQueryEasing(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryEasing");
	}

	/*
		History:
			2016-02-23 - GAC - Allow loadTheme() to handle if a skinName was not passed in
	*/
	public void function loadJCarousel(string skinName="", boolean force=0, string version="")
	{
		arguments.skinName = trim(arguments.skinName);
		
		loadResources("jQuery,jCarousel");
		
		if ( arguments.skinName == "" )
			arguments.skinName = "jCarouselDefaultSkin";

		loadTheme(arguments.skinName, "jCarouselDefaultSkin", "skins");
	}

	public void function loadJCarouselDefaultSkin()
	{
		loadResources("jCarouselDefaultSkin");
	}

	public void function loadJCrop(boolean force=0)
	{
		loadResources("jQuery,jQueryMigrate,jCrop");
	}

	public void function loadJCycle(string version="", boolean force=0)
	{
		loadResources("jQuery,jCycle");
	}

	public void function loadJCycle2(string version="", boolean force=0, boolean enablelog=0)
	{
		loadResources("jQuery,jCycle2");
		if (!arguments.enableLog)
			addFooterHTML('<script>jQuery.fn.cycle.log = jQuery.noop</script>', "TERTIARY");
	}

	public void function loadJQueryAutocomplete(boolean force=0)
	{
		loadResources("jQuery,jQueryAutocomplete,jQueryMetadata");
	}

	public void function loadJQueryMetadata()
	{
		loadResources("jQuery,jQueryMetadata");
	}

	public void function loadJQueryBBQ(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryBBQ");  // jQueryMigrate not needed for bbq-1.3.adf.js
		
		// jQuery BBQ 1.3 and below require Migrate!!
		//loadResources("jQuery,jQueryMigrate,jQueryBBQ");
	}

	public void function loadJQueryBlockUI(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryBlockUI");
	}

	public void function loadJQueryCalculation(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryCalculation");
	}

	public void function loadJQueryCalcX(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryCalcX");
	}

	public void function loadJQueryCapty(boolean force=0)
	{
		loadResources("jQuery,jQueryCapty");
	}

	public void function loadJQueryCheckboxes(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryCheckboxes");
	}

	public void function loadJQueryCookie(boolean force=0)
	{
		loadResources("jQuery,jQueryCookie");
	}

	public void function loadJQueryDataTables(string version="", boolean force=0, boolean loadStyles=1)
	{
		loadResources("jQuery,jQueryDataTables");
		if (arguments.loadStyles)
			loadResources("jQueryDataTablesStyles");
	}

	public void function loadJQueryDatePick(boolean force=0)
	{
		// jQuery jDatePick requires Migrate!!
		loadResources("jQuery,jQueryMigrate,jQueryDatePick");
	}

	public void function loadJQueryDoTimeout(boolean force=0)
	{
		loadResources("jQuery,jQueryDoTimeout");
	}

	public void function loadJQueryDump(boolean force=0)
	{
		loadResources("jQuery,jQueryDump");
	}

	public void function loadJQueryFancyBox(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryFancyBox,jQueryEasing,jQueryMouseWheel");
	}

	public void function loadJQueryField(string version="")
	{
		loadResources("jQuery,jQueryField");
	}

	public void function loadJQueryFileUpload(boolean force=0)
	{
		loadResources("jQuery,jQueryFileUpload");
	}

	public void function loadJQueryHighlight(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryHighlight");
	}

	public void function loadJQueryHighlightTextArea(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryHighlightTextArea");
	}

	public void function loadJQueryHotkeys(boolean force=0)
	{
		loadResources("jQuery,jQueryHotkeys");
	}

	public void function loadJQueryiCalendar(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryMigrate,jQueryiCalendar");
	}

	public void function loadJQueryImagesLoaded(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryImagesLoaded");
	}

	public void function loadJQueryJeditable(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryJeditable");
	}

	public void function loadJQueryJSON(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryJSON");
	}

	public void function loadJQueryMouseWheel(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryMouseWheel");
	}

	public void function loadJQueryMultiselect(boolean force=0)
	{
		loadResources("jQuery,jQueryMultiselect");
	}

	public void function loadJQueryNMCFormHelper(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryNMCFormHelper");
	}

	public void function loadJQueryPlupload(boolean force=0)
	{
		loadResources("jQuery,jQueryPlupload");
	}

	public void function loadJQuerySelectboxes(string version="", boolean force=0)
	{
		loadResources("jQuery,jQuerySelectboxes");
	}

	public void function loadJQuerySuperfish(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryHoverIntent,jQuerySuperfish");
	}

	public void function loadJQueryHoverIntent()
	{
		loadResources("jQuery,jQueryHoverIntent");
	}

	public void function loadjQuerySWFObject(string version="", boolean force=0)
	{
		loadResources("jQuery,jQuerySWFObject");
	}

	public void function loadSWFObject(string version="", boolean force=0)
	{
		loadResources("SWFObject");
	}

	public void function loadJQuerySWFUpload(string version="", boolean useQueue=0, boolean force=0)
	{
		loadResources("jQuery,jQuerySWFUpload");
		if (arguments.useQueue)
			loadResources("jQuerySWFUploadQueue");
	}

	public void function loadJQueryTemplates(boolean force=0)
	{
		loadResources("jQuery,jQueryTemplates");
	}

	public void function loadJQueryTextLimit(boolean force=0)
	{
		loadResources("jQuery,jQueryTextLimit");
	}

	public void function loadJQueryTimeAgo(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryTimeAgo");
	}

	public void function loadJQueryTools(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryTools");
	}

	public void function loadJQueryUIForm()
	{
		loadResources("jQuery,jQueryUI,jQueryUIForm");
	}

	public void function loadJQueryUIStars(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryUI,jQueryUIStars");
	}

	public void function loadJQueryUITimepickerAddon(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryUI,jQueryUITimepickerAddon");
	}

	public void function loadJQueryUITimepickerFG(string version="", boolean force=0)
	{
		loadResources("jQuery,jQueryUI,jQueryUITimepickerFG");
	}

	public void function loadJSONJS(boolean force=0)
	{
		loadResources("JSONJS");
	}

	/*
		History:
			2016-02-23 - GAC - Allow loadTheme() to handle if a theme was not passed in
	*/
	public void function loadJSTree(string version="", boolean force=0, boolean loadStyles=0, string theme="")
	{
		loadResources("jQuery,JSTree");
		if (arguments.loadStyles)
		{
			arguments.theme = trim(arguments.theme);

			if ( arguments.theme == "" )
				arguments.theme="JSTreeDefaultStyles";

			loadTheme(arguments.theme, "JSTreeDefaultStyles", "themes");
		}
	}

	public void function loadMathUUID(boolean force=0)
	{
		loadResources("MathUUID");
	}

	public void function loadMouseMovement(string version="", boolean force=0)
	{
		loadResources("MouseMovement");
	}

	/* HIGH: there's nothing like NiceForms or PrettyForms in the ADF that I can find
		HIGH: ...which is kind of good, since there's also inline js it would be better not to need.
	public void function loadNiceForms(boolean force=0)
	{
		loadResources("NiceForms,CommonSpotStyles");
	}*/

    // NOT ALLOWED ANYMORE
	/*public void function loadCommonSpotStyles()
	{
		loadResources("CommonSpotStyles");
	}*/

	public void function loadQTip(string version="", boolean force=0)
	{
		loadResources("jQuery,QTip");
	}

	/* HIGH: there's nothing like this in the ADF thirdParty folder
	public void function loadSimplePassMeter(boolean force=0)
	{
		loadResources("jQuery,SimplePassMeter");
	}*/

	public void function loadTableSorter(string version="", boolean force=0)
	{
		loadResources("jQuery,TableSorter");
	}

	public void function loadTableSorterPager()
	{
		loadTableSorter();
		loadResources("TableSorterPager");
	}

	public void function loadTableSorterThemes()
	{
		loadTableSorter();
		loadResources("TableSorterThemes");
	}

	/*
	The ThickBox JQuery Lightbox Plugin Library is no longer included as part of the ADF's ThirdParty library.
		ThickBox 3.1 (last updated on 08/08/2007)
		http://codylindley.com/thickbox/
	public void function loadThickbox()
	{
		loadResources("jQuery,Thickbox");
	} */

	public void function loadTipsy()
	{
		loadResources("jQuery,Tipsy");
	}

	public void function loadTypeAheadBundle()
	{
		loadResources("jQuery,TypeAheadBundle");
	}

	public void function loadUploadify()
	{
		loadResources("jQuery,Uploadify,jQuerySWFObject");
	}

	public void function loadUsedKeyboard()
	{
		loadResources("UsedKeyboard");
	}

	// last because an arg named 'package' messes up IDEA's syntax highlighting from here on out, as of IDEA 141.2311.1
	public void function loadCKEditor(string version="4.5.3", string package="full", boolean useCDN=0, boolean force=0)
	{
		loadResources("CKEditor");
	}
}