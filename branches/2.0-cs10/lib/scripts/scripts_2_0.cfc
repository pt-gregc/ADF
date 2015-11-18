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
		PaperThin, Inc. Copyright(C) 2015.
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
			2013-09-05 - GAC - Updated with functions for and jQuery qTip2 JQuery ImagesLoaded
			2013-09-27 - DMB - Added a function to load jQuery Cycle2 lib
			2014-05-19 - GAC - Added functions for jQuery plug-ins: jEditable, Calx, Calculation
			2014-09-16 - GAC - Updated references to thirdparty to thirdParty for case sensitivity
			2015-02-17 - GAC - Added a loadJQueryTimeAgo function to load version 1.4 by default
			2015-04-22 - GAC - Added the loadCKEditor and the loadTypeAheadBundle functions
			2015-06-10 - ACW - Updated the component extends to no longer be dependant on the 'ADF' in the extends path
			2015-07-21 - GAC - Added and updated the loadCFJS function for CFJS v1.3
			2015-08-20 - DRM - Created 2.0 version for ADF 2.0 and CommonSpot 10
			2015-11-18 - DRM - Added loadUnregisteredResource method
									 Modified loadTheme to use an unregistered resource if possible
	*/


	/* PROPERTIES */
	property name="version" type="string" default="2_0_0";
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
		canCombine default="": boolean, except empty str means auto: combine if we can read the file from expandPath(URL), checked when rendering resource request URLs
		canMinify default="0"; boolean
	*/
	public void function loadUnregisteredResource(required string URL, required string resourceType, required string location, required string resourceGroup, string canCombine="", string canMinify="")
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
	  Server.CommonSpot.udf.resources.addFooterJS(js, resourceGroup);
	}
	 
	public void function addHeaderCSS(required string css, required string resourceGroup) // resourceGroup: PRIMARY, SECONDARY, TERTIARY
	{
	  Server.CommonSpot.udf.resources.addHeaderCSS(css, resourceGroup);
	}

	/*
		generic theme/skin loader
		assumes there's a default version registered as a resource, and that some portion of its path is the theme/skin name

		args:
			themeName: name of theme you want to load (actually that portion of the file path, regardless of how it's referred to elsewhere)
			defaultResourceName: name of the registered default resource
			parentKey: portion of the default resource url BEFORE the one that's the theme name
	*/
	public void function loadTheme(string themeName, string defaultResourceName, string parentKey)
	{
		var resourceList = resourceAPI.getList(0, arguments.defaultResourceName, "equals");
		var res = "";
		var cssURL = "";
		var listPos = 0;

		if (resourceList.RecordCount == 1 && arrayLen(resourceList.earlyLoadSourceArray[1]) == 1)
		{
			res = resourceList.earlyLoadSourceArray[1][1];
			cssURL = res.sourceURL;
			listPos = listFindNoCase(cssURL, arguments.parentKey, "/");
			if (listPos > 0 && listPos < (listLen(cssURL, "/") - 1))
			{
				cssURL = listSetAt(cssURL, listPos + 1, arguments.themeName, "/");
				if (res.canCombine == 1) // take that as a proxy for it being local, if not, just render the raw tag
					loadUnregisteredResource(cssURL, "Stylesheet", "head", "secondary", res.canCombine, res.canMinify);
				else
					addHeaderHTML('<link href="#cssURL#" rel="stylesheet" type="text/css">', "SECONDARY");
			}
		}
	}


	/* PRIMARY - MAJOR LIBRARIES */
	
	
	/*
		History:
			2015-09-24 - GAC - Added jQuery Migrate to load with jQuery by default... since that is ADF assumes will happen
							 - Added a useMigrate parameter to disable jQuery Migrate
	*/
	public void function loadJQuery(string version="", boolean force=0, boolean noConflict=0, useMigrate=1 )
	{
		loadResources("jQuery");
	
		if (arguments.noConflict)
			addFooterHTML("<script>jQuery.noConflict();</script>", "PRIMARY");
		
		// Load the Migrate plugin
		if ( arguments.useMigrate ) 
			loadResources("JQueryMigrate");
	}

	public void function loadJQueryMigrate()
	{
		loadResources("JQuery,JQueryMigrate");
	}


	public void function loadJQueryUI(string version="", string themeName="", boolean force=0)
	{
		loadResources("jQuery,JQueryUI");
		if (arguments.themeName == "")
			loadResources("JQueryUIDefaultTheme");
		else
			loadTheme(arguments.themeName, "JQueryUIDefaultTheme", "css");
	}
	

	public void function loadJQueryMobile(string version="", boolean force=0)
	{
		loadResources("jQuery,JQueryMobile");
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

	public void function loadADFLightbox(string version="", boolean force=0)
	{
		var js = "";
	 	loadResources("jQuery,ADFLightbox");
	
		if (structKeyExists(request,"ADFLightboxLoaded"))
			return; // TODO: throw("Why are you loadinging again!");
		else
		   	request.ADFLightboxLoaded = 1;
		  	
		// Set a default Width
		if ( NOT StructKeyExists(request.params, "width") )
			request.params.width = 500;
		
		// Set a default Height
		if ( NOT StructKeyExists(request.params, "height") )
			request.params.height = 500;
		
		// Set a default Title
		if ( NOT StructKeyExists(request.params, "title") )
			request.params.title = "";
		
		// Set a default Subtitle
		if ( NOT StructKeyExists(request.params, "subtitle") )
			request.params.subtitle = "";
	
		// Build the ADFlightbox INIT JS block
		saveContent variable="js"
		{
			writeOutput
		  	("
				jQuery(document).ready(function()
				{
					initADFLB();
				  	if ( (typeof commonspot != 'undefined') && (typeof commonspot.lightbox != 'undefined') ) 
				   		commonspot.lightbox.initCurrent(#request.params.width#, #request.params.height#, { title: '#request.params.title#', subtitle: '#request.params.subtitle#', close: 'true', reload: 'true' });
				});
		  	");
		}
		addFooterJS(js,"SECONDARY");
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
		loadResources("jQuery,jQueryUI,JQueryCookie,Dynatree");
	}

	public void function loadFileUploader(boolean force=0)
	{
		loadResources("jQuery,FileUploader");
	}

	public void function loadFontAwesome(string version="", boolean force=0, boolean dynamicHeadRender=0, string overridePath="")
	{
		var scriptPath = trim(arguments.overridePath);
		if (scriptPath != "" && listLast(scriptPath, ".") == "css" && fileExists(expandPath(scriptPath)))
			addHeaderHTML('<link href="#scriptPath#" rel="stylesheet" type="text/css">', "SECONDARY");
		else
			loadResources("FontAwesome"); // includes both base version and ADF css extension
	}

	public void function loadGalleryView(string version="", string themeName="", boolean force=0)
	{
		// NOTE: themeName arg was ignored in prior (1.2) version
		loadResources("JQuery,GalleryView,JQueryTimers,JQueryEasing");
	}

	public void function loadJQueryTimers()
	{
		loadResources("JQuery,JQueryTimers");
	}

	public void function loadJQueryEasing(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryEasing");
	}

	public void function loadJCarousel(string skinName="", boolean force=0, string version="")
	{
		loadResources("JQuery,JCarousel");
		if (arguments.skinName == "")
			loadResources("JCarouselDefaultSkin");
		else
			loadTheme(arguments.themeName, "JCarouselDefaultSkin", "skins");
	}

	public void function loadJCarouselDefaultSkin()
	{
		loadResources("JCarouselDefaultSkin");
	}

	public void function loadJCrop(boolean force=0)
	{
		loadResources("JQuery,JCrop");
	}

	public void function loadJCycle(string version="", boolean force=0)
	{
		loadResources("JQuery,JCycle");
	}

	public void function loadJCycle2(string version="", boolean force=0, boolean enablelog=0)
	{
		loadResources("JQuery,JCycle2");
		if (!arguments.enableLog)
			addFooterHTML('<script>jQuery.fn.cycle.log = jQuery.noop</script>', "TERTIARY");
	}

	public void function loadJQueryAutocomplete(boolean force=0)
	{
		loadResources("JQuery,JQueryAutocomplete,JQueryMetadata");
	}

	public void function loadJQueryMetadata()
	{
		loadResources("JQuery,JQueryMetadata");
	}

	public void function loadJQueryBBQ(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryBBQ");
	}

	public void function loadJQueryBlockUI(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryBlockUI");
	}

	public void function loadJQueryCalculation(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryCalculation");
	}

	public void function loadJQueryCalcX(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryCalcX");
	}

	public void function loadJQueryCapty(boolean force=0)
	{
		loadResources("JQuery,JQueryCapty");
	}

	public void function loadJQueryCheckboxes(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryCheckboxes");
	}

	public void function loadJQueryCookie(boolean force=0)
	{
		loadResources("JQuery,JQueryCookie");
	}

	public void function loadJQueryDataTables(string version="", boolean force=0, boolean loadStyles=1)
	{
		loadResources("JQuery,JQueryDataTables");
		if (arguments.loadStyles)
			loadResources("JQueryDataTablesStyles");
	}

	public void function loadJQueryDatePick(boolean force=0)
	{
		loadResources("JQuery,JQueryDatePick");
	}

	public void function loadJQueryDoTimeout(boolean force=0)
	{
		loadResources("JQuery,JQueryDoTimeout");
	}

	public void function loadJQueryDump(boolean force=0)
	{
		loadResources("JQuery,JQueryDump");
	}

	public void function loadJQueryFancyBox(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryFancyBox,JQueryEasing,JQueryMouseWheel");
	}

	public void function loadJQueryField(string version="")
	{
		loadResources("JQuery,JQueryField");
	}

	public void function loadJQueryFileUpload(boolean force=0)
	{
		loadResources("JQuery,JQueryFileUpload");
	}

	public void function loadJQueryHighlight(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryHighlight");
	}

	public void function loadJQueryHotkeys(boolean force=0)
	{
		loadResources("JQuery,JQueryHotkeys");
	}

	public void function loadJQueryiCalendar(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryiCalendar");
	}

	public void function loadJQueryImagesLoaded(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryImagesLoaded");
	}

	public void function loadJQueryJeditable(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryJeditable");
	}

	public void function loadJQueryJSON(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryJSON");
	}

	public void function loadJQueryMouseWheel(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryMouseWheel");
	}

	public void function loadJQueryMultiselect(boolean force=0)
	{
		loadResources("JQuery,JQueryMultiselect");
	}

	public void function loadJQueryNMCFormHelper(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryNMCFormHelper");
	}

	public void function loadJQueryPlupload(boolean force=0)
	{
		loadResources("JQuery,JQueryPlupload");
	}

	public void function loadJQuerySelectboxes(string version="", boolean force=0)
	{
		loadResources("JQuery,JQuerySelectboxes");
	}

	public void function loadJQuerySuperfish(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryHoverIntent,JQuerySuperfish");
	}

	public void function loadJQueryHoverIntent()
	{
		loadResources("JQuery,JQueryHoverIntent");
	}

	public void function loadjQuerySWFObject(string version="", boolean force=0)
	{
		loadResources("JQuery,jQuerySWFObject");
	}

	public void function loadSWFObject(string version="", boolean force=0)
	{
		loadResources("SWFObject");
	}

	public void function loadJQuerySWFUpload(string version="", boolean useQueue=0, boolean force=0)
	{
		loadResources("JQuery,JQuerySWFUpload");
		if (arguments.useQueue)
			loadResources("JQuerySWFUploadQueue");
	}

	public void function loadJQueryTemplates(boolean force=0)
	{
		loadResources("JQuery,JQueryTemplates");
	}

	public void function loadJQueryTextLimit(boolean force=0)
	{
		loadResources("JQuery,JQueryTextLimit");
	}

	public void function loadJQueryTimeAgo(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryTimeAgo");
	}

	public void function loadJQueryTools(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryTools");
	}

	public void function loadJQueryUIForm()
	{
		loadResources("JQuery,JQueryUI,JQueryUIForm");
	}

	public void function loadJQueryUIStars(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryUI,JQueryUIStars");
	}

	public void function loadJQueryUITimepickerAddon(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryUI,JQueryUITimepickerAddon");
	}

	public void function loadJQueryUITimepickerFG(string version="", boolean force=0)
	{
		loadResources("JQuery,JQueryUI,JQueryUITimepickerFG");
	}

	public void function loadJSONJS(boolean force=0)
	{
		loadResources("JSONJS");
	}

	public void function loadJSTree(string version="", boolean force=0, boolean loadStyles=0, string theme="")
	{
		loadResources("JQuery,JSTree");
		if (arguments.loadStyles)
		{
			arguments.theme = trim(arguments.theme);
			if (arguments.theme == "")
				loadResources("JSTreeDefaultStyles");
			else
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

	public void function loadCommonSpotStyles()
	{
		loadResources("CommonSpotStyles");
	}

	public void function loadQTip(string version="", boolean force=0)
	{
		loadResources("JQuery,QTip");
	}

	/* HIGH: there's nothing like this in the ADF
	public void function loadSimplePassMeter(boolean force=0)
	{
		loadResources("JQuery,SimplePassMeter");
	}*/

	public void function loadTableSorter(string version="", boolean force=0)
	{
		loadResources("JQuery,TableSorter");
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

	public void function loadThickbox()
	{
		loadResources("JQuery,Thickbox");
	}

	public void function loadTipsy()
	{
		loadResources("JQuery,Tipsy");
	}

	public void function loadTypeAheadBundle()
	{
		loadResources("JQuery,TypeAheadBundle");
	}

	public void function loadUploadify()
	{
		loadResources("JQuery,Uploadify,jQuerySWFObject");
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