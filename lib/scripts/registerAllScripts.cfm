<!---
	Script to register all resources inside the ADF as CommonSpot resources.
	You only need to run this if that's what you want to do.

	In general, actual resources created are version specific, and a generic version-less alias is created pointing to it.

	To run this, log into CommonSpot as an admin, then run this code:
	<cfmodule template="/ADF/lib/scripts/registerAllScripts.cfm"> <!--- optional attributes: updateExisting="1 or 0" scriptsPackage="full or min" --->

	History
	2015-09-08 - DRM - Initial version.
	2015-09-16 - GAC - Updated to add bootstrap-ADF-ext.css to the bootstrap resource registration
	2015-11-25 - GAC - Updated the BBQ jquery lib to 1.3
	2016-01-04 - GAC - Updated to allow a minimal set of resources to be registered
	2016-03-14 - GAC - Moved the registerResource methods to scriptsService_2_0
--->

<cfscript>
	if ( !structKeyExists(attributes, "updateExisting") )
		attributes.updateExisting = 0;

	if ( !structKeyExists(attributes, "scriptsPackage") )
		attributes.scriptsPackage = "full"; // Options: full or  min


	// COMMONSPOT RESOURCE API
	/*
		resourceAPI.save(id, name, category, earlyLoadSourceArray, lateLoadSourceArray, description, installInstructions, aliasList, redistributable);
			sourceArray: [{LoadTagType, SourceURL}]}
			LoadTagType: 1=StyleSheet 2=JavaScript
	*/
	//resourceAPI = Server.CommonSpot.ObjectFactory.getObject("Resource");

	/* MOVED TO ScriptsService_2_0 */
	// HELPER FUNCTIONS
	// we may be able to get rid of some of these when CommonSpot has corresponding APIs in some form
	/* function registerResource
	(
		required string name,
		required string category,
		required array earlyLoadSourceArray,
		required array lateLoadSourceArray,
		required string description,
		required string installInstructions,
		string aliasList="",
		boolean redistributable=0
	)
	{
		var resSpecs = "";
		var action = "registered";
		arguments.id = 0;
		if (structKeyExists(Request.Site.CS_Resources.Resources_by_name, arguments.name))
		{
			resSpecs = Request.Site.CS_Resources.Resources_by_name[arguments.name];
			if (resSpecs.name != arguments.name) // registered version is an alias, can't update it
			{
				writeOutput("Alias with this name already exists, skipped: #arguments.name#<br>");
				return;
			}
			else if (attributes.updateExisting == 0)
			{
				writeOutput("Resource already exists, skipped: #arguments.name#<br>");
				return;
			}
			else
			{
				arguments.id = resSpecs.id;
				action = "updated";
			}
		}
		arguments.earlyLoadSourceArray = getResourceArray(arguments.earlyLoadSourceArray);
		arguments.lateLoadSourceArray = getResourceArray(arguments.lateLoadSourceArray);
		writeOutput("Resource #action#: #arguments.name#<br>");
		return resourceAPI.save(argumentCollection=arguments);
	}*/
	/* MOVED TO ScriptsService_2_0 */
	/*
	function getResourceArray(resourceSpecsArray)
	{
		var arr = Request.TypeFactory.newObjectInstance("ResourceLoadStruct_Array");
		var count = arrayLen(arguments.resourceSpecsArray);
		var i = 0;
		for (i = 1; i <= count; i++)
			arrayAppend(arr, getResourceStruct(argumentCollection=arguments.resourceSpecsArray[i]));
		return arr;
	}*/
	/* MOVED TO ScriptsService_2_0 */
	/*
	function getResourceStruct(loadTagType, sourceURL, canCombine, canMinify)
	{
		var res = Request.TypeFactory.newObjectInstance("ResourceLoadStruct");
		if (!structKeyExists(arguments, "canCombine"))
			arguments.canCombine = (left(arguments.sourceURL, 4) == "http") ? 0 : 1;
		if (!structKeyExists(arguments, "canMinify"))
			arguments.canMinify =
			(
					!arguments.canCombine
				|| findNoCase(".min", arguments.sourceURL)
				|| findNoCase("_min", arguments.sourceURL)
				|| findNoCase("-pack", arguments.sourceURL)
				|| findNoCase(".pack", arguments.sourceURL)
			) ? 0 : 1;
		res.loadTagType = arguments.loadTagType;
		res.sourceURL = arguments.sourceURL;
		res.canCombine = arguments.canCombine;
		res.canMinify = arguments.canMinify;
		return res;
	}*/

	/* PRIMARY - MAJOR LIBRARIES */

	// these are the only js we load in the head by default, because they're called so much by existing code
	// even code that defers actual execution probably does that with the jQuery document ready function

	application.ADF.scriptsService.registerResource
	(
		"jQuery 1.12", "PRIMARY",
		[
			{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/jquery-1.12.js", canMinify=0}
		],
		[],
		"jQuery resources.", "Included in ADF 2.0 and later.", "jQuery"
		,0,attributes.updateExisting,0
	);
	
	application.ADF.scriptsService.registerResource
	(
		"jQueryMigrate 1.2", "PRIMARY",
		[
			{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/migrate/jquery-migrate-1.2.js", canMinify=0}
		],
		[],
		"jQueryMigrate resources.", "Included in ADF 2.0 and later.", "jQueryMigrate"
		,0,attributes.updateExisting,0
	);

	// START - major libs that load in the footer

    jQueryUIversion = "1.11";

    /* jQuery UI Theme Javascript Resources */
	application.ADF.scriptsService.registerResource
	(
		"jQueryUI #jQueryUIversion#", "PRIMARY",
		[],
		[
			{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/ui/jquery-ui-#jQueryUIversion#/js/jquery-ui-#jQueryUIversion#.js", canMinify=0}
		],
		"jQueryUI resources.", "Included in ADF 2.0 and later.", "jQueryUI"
		,0,attributes.updateExisting,0
	);

    /* jQuery UI Default Theme CSS fallback */
	application.ADF.scriptsService.registerResource
	(
		"jQueryUIDefaultTheme #jQueryUIversion#", "PRIMARY",
		[
			{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/ui/jquery-ui-#jQueryUIversion#/css/ui-lightness/jquery-ui.css", canCombine=0, canMinify=0}
		],
		[],
		"jQueryUIDefaultTheme resources.", "Included in ADF 2.0 and later.", "jQueryUIDefaultTheme,jQueryUIstyles"
		,0,attributes.updateExisting,0
	);

    /* jQuery UI Theme CSS example: ui-lightness */
	application.ADF.scriptsService.registerResource
	(
		"jQueryUI UI-Lightness #jQueryUIversion#", "PRIMARY",
		[
			{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/ui/jquery-ui-#jQueryUIversion#/css/ui-lightness/jquery-ui.css", canCombine=0, canMinify=0}
		],
		[],
		"jQueryUI UI-Lightness Theme resources.", "Included in ADF 2.0 and later.", "ui-lightness"
		,0,attributes.updateExisting,0
	);

	/* jQuery UI Theme CSS example: Redmond */
	application.ADF.scriptsService.registerResource
	(
		"jQueryUI Redmond #jQueryUIversion#", "PRIMARY",
		[
			{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/ui/jquery-ui-#jQueryUIversion#/css/redmond/jquery-ui.css", canCombine=0, canMinify=0}
		],
		[],
		"jQueryUI Redmond Theme resources.", "Included in ADF 2.0 and later.", "redmond"
		,0,attributes.updateExisting,0
	);
	
	application.ADF.scriptsService.registerResource
	(
		"jQueryMobile 1.4", "PRIMARY",
		[
			{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/mobile/1.4/jquery.mobile-1.4.min.css"}
		],
		[
			{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/mobile/1.4/jquery.mobile-1.4.min.js"}
		],
		"jQueryMobile resources.", "Included in ADF 2.0 and later.", "jQueryMobile"
		,0,attributes.updateExisting,0
	);

	application.ADF.scriptsService.registerResource
	(
		"Bootstrap 3.3", "PRIMARY",
		[
			{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/bootstrap/3.3/css/bootstrap.min.css", canCombine=0, canMinify=0},
			{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/bootstrap/3.3/css/bootstrap-ADF-ext.css", canCombine=0, canMinify=0} // An ADF extension css file that adds glyphicon sizes (lg,2x-10x).
		],
		[
			{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/bootstrap/3.3/js/bootstrap.min.js"}
		],
		"Bootstrap resources.", "Included in ADF 2.0 and later.", "Bootstrap"
		,0,attributes.updateExisting,0
	);

	application.ADF.scriptsService.registerResource
	(
		"BootstrapDefaultTheme 3.3", "PRIMARY",
		[
			{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/bootstrap/3.3/css/bootstrap-theme.min.css"}
		],
		[],
		"BootstrapDefaultTheme resources.", "Included in ADF 2.0 and later.", "BootstrapDefaultTheme"
		,0,attributes.updateExisting,0
	);


	/* SECONDARY - COMMON ADF RESOURCES */


	application.ADF.scriptsService.registerResource
	(
		"ADFLightbox 1.0", "SECONDARY",
		[
			{LoadTagType=1, SourceURL="/ADF/extensions/lightbox/1.0/css/lightbox_overrides.css", canCombine=0, canMinify=0}
		],
		[
			{LoadTagType=2, SourceURL="/ADF/extensions/lightbox/1.0/js/framework.js"}
		],
		"ADFLightbox resources.", "Included in ADF 2.0 and later.", "ADFLightbox"
		,0,attributes.updateExisting,0
	);

	application.ADF.scriptsService.registerResource
	(
		"ADFStyles", "SECONDARY",
		[
			{LoadTagType=1, SourceURL="/ADF/extensions/style/ADF.css"}
		],
		[],
		"ADFStyles resources.", "Included in ADF 2.0 and later.", ""
		,0,attributes.updateExisting,0
	);

	// NOT ALLOWED ANYMORE
	// NOTE: using CommonSpot version number here
	/* application.ADF.scriptsService.registerResource
	(
		"CommonSpotStyles 10.0", "SECONDARY",
		[
			{LoadTagType=1, SourceURL="/commonspot/commonspot.css"}
		],
		[],
		"CommonSpotStyles resources.", "Included in ADF 2.0 and later.", "CommonSpotStyles"
		,0,attributes.updateExisting,0
	);*/

	/* SECONDARY - PLUGINS ETC - leaving TERTIARY for customer or app code */

	if ( attributes.scriptsPackage EQ "full" )
	{

		application.ADF.scriptsService.registerResource
		(
			"AutoGrow 1.2", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/autogrow/autogrow-1.2.2.js"}
			],
			"AutoGrow resources.", "Included in ADF 2.0 and later.", "AutoGrow"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"CFJS 1.3", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/cfjs/1.3/jquery.cfjs.min.js"}
			],
			"CFJS resources.", "Included in ADF 2.0 and later.", "CFJS"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"CKEditor 4.5", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL=getCKEditorDefaultLocation()}
			],
			"CKEditor resources.", "Included in ADF 2.0 and later.", "CKEditor"
			,0,attributes.updateExisting,0
		);


		function getCKEditorDefaultLocation(string version="4.5.3", string package="full", boolean useCDN=0, boolean force=0)
		{
			var libPath = "";
			var loadViaCDN = arguments.useCDN;
			var csScriptLibPath = "cs_customization/ckeditor/ckeditor.js";
			var adfScriptLibPath = "_cs_apps/thirdParty/ckeditor/ckeditor.js";
			var packageList = "basic,standard,standard-all,full,full-all";

			if (len(trim(arguments.package)) == 0 || listFindNoCase(packageList, arguments.package) == 0)
				arguments.package = "full";

			if (!loadViaCDN)
			{
				if ( fileExists(Request.Site.Dir & csScriptLibPath) )
					libPath = Request.Site.RS_URL & csScriptLibPath;
				else if ( fileExists(Request.Site.Dir & adfScriptLibPath) )
					libPath = Request.Site.RS_URL & adfScriptLibPath;
				else
					loadViaCDN = true;
			}
			if (loadViaCDN)
				libPath = "http://cdn.ckeditor.com/#arguments.version#/#arguments.package#/ckeditor.js";
				// or we could do this:
				//libPath = Server.CommonSpot.ObjectFactory.getObject("FormattedTextblock").getEditorDefaultLocation();
			return libPath;
		}

		application.ADF.scriptsService.registerResource
		(
			"DateFormat 1.2", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/js/dateformat/1.2/date.format.js"}
			],
			"DateFormat resources.", "Included in ADF 2.0 and later.", "DateFormat"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"DateJS 1.0", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/js/datejs/1.0/date.js", canMinify=0}
			],
			"DateJS resources.", "Included in ADF 2.0 and later.", "DateJS"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"DropCurves 0.1", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/dropcurves/jquery.dropCurves-0.1.2.min.js"}
			],
			"DropCurves resources.", "Included in ADF 2.0 and later.", "DropCurves"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"Dynatree 1.1", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/dynatree/jquery-dynatree-1.1.1.js", canMinify=0}
			],
			"Dynatree resources.", "Included in ADF 2.0 and later.", "Dynatree"
			,0,attributes.updateExisting,0
		);

		// NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
		application.ADF.scriptsService.registerResource
		(
			"jQueryCookie 1.2", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/cookie/jquery.cookie.js"}
			],
			"jQueryCookie resources.", "Included in ADF 2.0 and later.", "jQueryCookie"
			,0,attributes.updateExisting,0
		);

		// TODO: no version number anywhere I found
		application.ADF.scriptsService.registerResource
		(
			"FileUploader", "SECONDARY",
			[ {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/fileuploader/client/fileuploader.css"} ],
			[ {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/fileuploader/client/fileuploader.js"} ],
			"FileUploader resources.", "Included in ADF 2.0 and later.", ""
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"FontAwesome 4.4", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/css/font-awesome/4.4/css/font-awesome.min.css", canCombine=0, canMinify=0}, // loads its own resources using relative URLs
				{LoadTagType=1, SourceURL="/ADF/thirdParty/css/font-awesome/4.4/css/font-awesome-ADF-ext.css"} // An ADF css extension css file that add sizes (6x-10x)
			],
			[],
			"FontAwesome resources.", "Included in ADF 2.0 and later.", "FontAwesome"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"GalleryView 1.1", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/galleryview/jquery-galleryview-1.1/jquery.galleryview-1.1-pack.js"}
			],
			"GalleryView resources.", "Included in ADF 2.0 and later.", "GalleryView"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryTimers 1.1", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/galleryview/jquery-galleryview-1.1/jquery.timers-1.1.2.js"}
			],
			"jQueryTimers resources.", "Included in ADF 2.0 and later.", "jQueryTimers"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryEasing 1.3", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/easing/jquery.easing.1.3.js"}
			],
			"GalleryView resources.", "Included in ADF 2.0 and later.", "jQueryEasing"
			,0,attributes.updateExisting,0
		);

		// TODO: no version number I found
		application.ADF.scriptsService.registerResource
		(
			"jCarousel", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/jcarousel/jquery.jcarousel.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/jcarousel/jquery.jcarousel.pack.js"}
			],
			"jCarousel resources.", "Included in ADF 2.0 and later.", ""
			,0,attributes.updateExisting,0
		);

		// TODO: no version number I found
		application.ADF.scriptsService.registerResource
		(
			"jCarouselDefaultSkin", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/jcarousel/skins/tango/skin.css"}
			],
			[],
			"jCarouselDefaultSkin resources.", "Included in ADF 2.0 and later.", ""
			,0,attributes.updateExisting,0
		);

		// NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
		application.ADF.scriptsService.registerResource
		(
			"jCrop 0.9", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/jcrop/css/jquery.Jcrop.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/jcrop/js/jquery.Jcrop.min.js"}
			],
			"jCrop resources.", "Included in ADF 2.0 and later.", "jCrop"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jCycle 2.9", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/jcycle/jquery.cycle.all-2.9.js"}
			],
			"jCycle resources.", "Included in ADF 2.0 and later.", "jCycle"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jCycle2 20130909", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/jcycle2/20130909/jquery.cycle2.min.js"}
			],
			"jCycle2 resources.", "Included in ADF 2.0 and later.", "jCycle2"
			,0,attributes.updateExisting,0
		);

		// NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
		application.ADF.scriptsService.registerResource
		(
			"jQueryAutocomplete 5.0", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/auto-complete/jquery.auto-complete.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/auto-complete/jquery.auto-complete.min.js"}
			],
			"jQueryAutocomplete resources.", "Included in ADF 2.0 and later.", "jQueryAutocomplete"
			,0,attributes.updateExisting,0
		);

		// NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
		application.ADF.scriptsService.registerResource
		(
			"jQueryMetadata 5.0", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/auto-complete/jquery.metadata.js"},
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/auto-complete/jquery.auto-complete.min.js"}
			],
			"jQueryAutocomplete resources.", "Included in ADF 2.0 and later.", "jQueryMetadata"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryBBQ 1.3", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/bbq/1.3.adf/jquery.ba-bbq.js"}
				/* {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/bbq/1.3/jquery.ba-bbq.min.js"}*/
			],
			"jQueryBBQ resources.", "Included in ADF 2.0 and later.", "jQueryBBQ"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryBlockUI 2.7", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/blockUI/2.7/jquery.blockUI.min.js"}
			],
			"jQueryBlockUI resources.", "Included in ADF 2.0 and later.", "jQueryBlockUI"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryCalculation 0.4", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/calculation/0.4/jquery.calculation.min.js"}
			],
			"jQueryCalculation resources.", "Included in ADF 2.0 and later.", "jQueryCalculation"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryCalcX 1.1", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/calcx/1.1/jquery.calx.min.js"}
			],
			"jQueryCalcX resources.", "Included in ADF 2.0 and later.", "jQueryCalcX"
			,0,attributes.updateExisting,0
		);

		// NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
		application.ADF.scriptsService.registerResource
		(
			"jQueryCapty 0.2", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/capty/css/jquery.capty.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/capty/js/jquery.capty.min.js"}
			],
			"jQueryCapty resources.", "Included in ADF 2.0 and later.", "jQueryCapty"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryCheckboxes 2.1", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/checkboxes/jquery.checkboxes-2.1.min.js"}
			],
			"jQueryCheckboxes resources.", "Included in ADF 2.0 and later.", "jQueryCheckboxes"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryDataTables 1.9", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/datatables/1.9/js/jquery.dataTables.min.js"}
			],
			"jQueryDataTables resources.", "Included in ADF 2.0 and later.", "jQueryDataTables"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryDataTablesStyles 1.9", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/datatables/1.9/css/demo_page.css"},
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/datatables/1.9/css/demo_table_jui.css"},
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/datatables/1.9/css/demo_table.css"},
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/datatables/1.9/css/jquery.dataTables.css"},
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/datatables/1.9/css/jquery.dataTables_themeroller.css"}
			],
			[],
			"jQueryDataTables resources.", "Included in ADF 2.0 and later.", "jQueryDataTablesStyles"
			,0,attributes.updateExisting,0
		);

		// NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
		application.ADF.scriptsService.registerResource
		(
			"jQueryDatePick 4.0", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/datepick/jquery.datepick.css", canCombine=0, canMinify=0}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/datepick/jquery.datepick.js", canCombine=0, canMinify=0}
			],
			"jQueryDatePick resources.", "Included in ADF 2.0 and later.", "jQueryDatePick"
			,0,attributes.updateExisting,0
		);

		// NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
		application.ADF.scriptsService.registerResource
		(
			"jQueryDoTimeout 1.0", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/dotimeout/jquery.dotimeout.plugin.js", canMinify=0}
			],
			"jQueryDoTimeout resources.", "Included in ADF 2.0 and later.", "jQueryDoTimeout"
			,0,attributes.updateExisting,0
		);

		// NOTE: no version number
		application.ADF.scriptsService.registerResource
		(
			"jQueryDump", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/dump/jquery.dump.js"}
			],
			"jQueryDump resources.", "Included in ADF 2.0 and later.", ""
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryFancyBox 1.3", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/fancybox/jquery.fancybox-1.3.4.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/fancybox/jquery.fancybox-1.3.4.pack.js"}
			],
			"jQueryFancyBox resources.", "Included in ADF 2.0 and later.", "jQueryFancyBox"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryField 0.9", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/field/jquery.field-0.9.8.min.js"}
			],
			"jQueryField resources.", "Included in ADF 2.0 and later.", "jQueryField"
			,0,attributes.updateExisting,0
		);

		// NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
		application.ADF.scriptsService.registerResource
		(
			"jQueryFileUpload 5.0", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/fileupload/jquery.fileupload-ui.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/fileupload/jquery.iframe-transport.js"},
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/fileupload/jquery.fileupload.js"},
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/fileupload/jquery.fileupload-ui.js"}
			],
			"jQueryFileUpload resources.", "Included in ADF 2.0 and later.", "jQueryFileUpload"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryHighlight 3.0", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/highlight/jquery.highlight-3.0.0.yui.js", canMinify=0}
			],
			"jQueryHighlight resources.", "Included in ADF 2.0 and later.", "jQueryHighlight"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryHighlightTextArea 3.1", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/highlighttextarea/3.1/jquery.highlighttextarea.min.css", canMinify=0}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/highlighttextarea/3.1/jquery.highlighttextarea.min.js", canMinify=0}
			],
			"jQueryHighlightTextArea resources.", "Included in ADF 2.0 and later.", "jQueryHighlightTextArea"
			,0,attributes.updateExisting,0
		);

		// NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
		application.ADF.scriptsService.registerResource
		(
			"jQueryHotkeys 0.8", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/hotkeys/jquery.hotkeys.js"}
			],
			"jQueryHotkeys resources.", "Included in ADF 2.0 and later.", "jQueryHotkeys"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryiCalendar 1.1", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/icalendar/1.1/jquery.icalendar.pt.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/icalendar/1.1/jquery.icalendar.pt.js"}
			],
			"jQueryiCalendar resources.", "Included in ADF 2.0 and later.", "jQueryiCalendar"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryImagesLoaded 3.0", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/imagesloaded/3.0/imagesloaded.pkgd.min.js"}
			],
			"jQueryImagesLoaded resources.", "Included in ADF 2.0 and later.", "jQueryImagesLoaded"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryJeditable 1.7", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/jeditable/1.7/jquery.jeditable.min.js"}
			],
			"jQueryJeditable resources.", "Included in ADF 2.0 and later.", "jQueryJeditable"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryJSON 2.2", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/json/jquery.json-2.2.min.js"}
			],
			"jQueryJSON resources.", "Included in ADF 2.0 and later.", "jQueryJSON"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryMouseWheel 3.0", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/mousewheel/jquery.mousewheel-3.0.4.pack.js"}
			],
			"jQueryMouseWheel resources.", "Included in ADF 2.0 and later.", "jQueryMouseWheel"
			,0,attributes.updateExisting,0
		);

		// NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
		application.ADF.scriptsService.registerResource
		(
			"jQueryMultiselect 1.1", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/multiselect/jquery.multiselect.css"},
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/multiselect/jquery.multiselect.filter.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/multiselect/jquery.multiselect.min.js"},
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/multiselect/jquery.multiselect.filter.min.js"}
			],
			"jQueryMultiselect resources.", "Included in ADF 2.0 and later.", "jQueryMultiselect"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryNMCFormHelper 1.0", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/nmcFormHelper/1.0/nmcFormHelper.min.js"}
			],
			"jQueryNMCFormHelper resources.", "Included in ADF 2.0 and later.", "jQueryNMCFormHelper"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryPlupload", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/plupload/js/plupload.full.js", canMinify=0}
			],
			"jQueryPlupload resources.", "Included in ADF 2.0 and later.", ""
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQuerySelectboxes 2.2", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/selectboxes/2.2/jquery.selectboxes.min.js"}
			],
			"jQuerySelectboxes resources.", "Included in ADF 2.0 and later.", "jQuerySelectboxes"
			,0,attributes.updateExisting,0
		);
		// Updated path - OLD: /ADF/thirdParty/jquery/selectboxes/jquery.selectboxes-2.2.4.min.js

		application.ADF.scriptsService.registerResource
		(
			"jQuerySuperfish 1.4", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/superfish/css/superfish.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/superfish/jquery.superfish-1.4.8.js"}
			],
			"jQuerySuperfish resources.", "Included in ADF 2.0 and later.", "jQuerySuperfish"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryHoverIntent 1.4", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/superfish/hoverIntent.js"}
			],
			"jQueryHoverIntent resources.", "Included in ADF 2.0 and later.", "jQueryHoverIntent"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQuerySWFObject 1.0", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/swfobject/jquery.swfobject-1.0.9.min.js"}
			],
			"jQuerySWFObject resources.", "Included in ADF 2.0 and later.", "jQuerySWFObject"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"SWFObject 2.2", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/swfobject/swfobject-2.2.js", canMinify=0}
			],
			"SWFObject resources.", "Included in ADF 2.0 and later.", "SWFObject"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQuerySWFUpload 2.2", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/swfupload/swfupload-2.2.0.1/swfupload.js"}
			],
			"jQuerySWFUpload resources.", "Included in ADF 2.0 and later.", "jQuerySWFUpload"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQuerySWFUploadQueue 2.2", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/swfupload/swfupload-2.2.0.1/swfupload.queue.js"}
			],
			"jQuerySWFUpload resources.", "Included in ADF 2.0 and later.", "jQuerySWFUploadQueue"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryTemplates 1.0", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/templates/jquery.tmpl.min.js"}
			],
			"jQueryTemplates resources.", "Included in ADF 2.0 and later.", "jQueryTemplates"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryTextLimit 2209.07", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/textlimit/jquery.textlimit.plugin.js"}
			],
			"jQueryTextLimit resources.", "Included in ADF 2.0 and later.", "jQueryTextLimit"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryTimeAgo 1.4", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/timeago/1.4/jquery.timeago-1.4.1.js"}
			],
			"jQueryTimeAgo resources.", "Included in ADF 2.0 and later.", "jQueryTimeAgo"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryTools 1.2", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/tools/1.2/jquery.tools.min.js"}
			],
			"jQueryTools resources.", "Included in ADF 2.0 and later.", "jQueryTools"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryUIStars", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/ui/stars/3.0/ui.stars.min.css", canCombine=0, canMinify=0}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/ui/stars/3.0/ui.stars.min.js"}
			],
			"jQueryUIStars resources.", "Included in ADF 2.0 and later.", ""
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryUITimepickerAddon 1.2", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/ui/timepicker-addon/1.2/jquery-ui-timepicker-addon.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/ui/timepicker-addon/1.2/jquery-ui-timepicker-addon.js"},
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/ui/timepicker-addon/1.2/jquery-ui-sliderAccess.js"}
			],
			"jQueryUITimepickerAddon resources.", "Included in ADF 2.0 and later.", "jQueryUITimepickerAddon"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"jQueryUITimepickerFG 0.3", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/ui/timepicker-fg/0.3/jquery.ui.timepicker.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/ui/timepicker-fg/0.3/jquery.ui.timepicker.js"}
			],
			"jQueryUITimepickerFG resources.", "Included in ADF 2.0 and later.", "jQueryUITimepickerFG"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"JSONJS 2", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/js/json-js/json2.js"}
			],
			"JSONJS resources.", "Included in ADF 2.0 and later.", "JSONJS"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"JSTree 3.2", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/jsTree/3.2/jstree.min.js", canMinify=0}
			],
			"JSTree resources.", "Included in ADF 2.0 and later.", "JSTree"
			,0,attributes.updateExisting,0
		);
		// TODO: Future feature to remove old versions of registered resources with with the same alias
		// removeResource("JSTree 3.0");

		application.ADF.scriptsService.registerResource
		(
			"JSTreeDefaultStyles 3.2", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/jsTree/3.2/themes/default/style.min.css", canMinify=0}
			],
			[],
			"JSTreeDefaultStyles resources.", "Included in ADF 2.0 and later.", "JSTreeDefaultStyles"
			,0,attributes.updateExisting,0
		);
		// removeResource("JSTree 3.0");

		// NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
		application.ADF.scriptsService.registerResource
		(
			"MathUUID 1.4", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/js/math-uuid/math.uuid.js"}
			],
			"MathUUID resources.", "Included in ADF 2.0 and later.", "MathUUID"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"MouseMovement 2.0", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/cfformprotect/js/mouseMovement-2.0.1.js"}
			],
			"MouseMovement resources.", "Included in ADF 2.0 and later.", "MouseMovement"
			,0,attributes.updateExisting,0
		);

		/* HIGH: there's nothing like NiceForms or PrettyForms in the ADF that I can find, removed at least for now
			HIGH: ...which is kind of good, since there's also inline js it would be better not to need.
		*/
		/*
		(
			"NiceForms", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/prettyForms/prettyForms.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/prettyForms/prettyForms.js"}
			],
			"NiceForms resources.", "Included in ADF 2.0 and later.", ""
			,0,attributes.updateExisting,0
		);*/


		application.ADF.scriptsService.registerResource
		(
			"QTip 2.1", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/qtip/2.1/jquery.qtip.min.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/qtip/2.1/jquery.qtip.min.js"}
			],
			"QTip resources.", "Included in ADF 2.0 and later.", "QTip"
			,0,attributes.updateExisting,0
		);

		/* HIGH: there's nothing like this in the ADF thirdParty folder
		application.ADF.scriptsService.registerResource
		(
			"SimplePassMeter", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/simplePassMeter/simplePassMeter.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/simplePassMeter/jquery.simplePassMeter-0.3.min.js"}
			],
			"SimplePassMeter resources.", "Included in ADF 2.0 and later.", ""
			,0,attributes.updateExisting,0
		);*/

		application.ADF.scriptsService.registerResource
		(
			"TableSorter 2.0", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/tablesorter/2.0/jquery.tablesorter.min.js"}
			],
			"TableSorter resources.", "Included in ADF 2.0 and later.", "TableSorter"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"TableSorterPager 2.0", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/tablesorter/2.0/addons/pager/jquery.tablesorter.pager.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/tablesorter/2.0/addons/pager/jquery.tablesorter.pager.js"}
			],
			"TableSorterPager resources.", "Included in ADF 2.0 and later.", "TableSorterPager"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"TableSorterThemes 2.0", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/tablesorter/2.0/themes/blue/style.css"}
			],
			[],
			"TableSorterThemes resources.", "Included in ADF 2.0 and later.", "TableSorterThemes"
			,0,attributes.updateExisting,0
		);

		/*
		The ThickBox JQuery Lightbox Plugin Library is no longer included as part of the ADF's ThirdParty library.
			ThickBox 3.1 (last updated on 08/08/2007)
			http://codylindley.com/thickbox/

		application.ADF.scriptsService.registerResource
		(
			"Thickbox 3.1", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/thickbox/thickbox.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/thickbox/thickbox-3.1.js"}
			],
			"Thickbox resources.", "Included in ADF 2.0 and later.", "Thickbox"
			,0,attributes.updateExisting,0
		);*/

		// NOTE: no version number
		application.ADF.scriptsService.registerResource
		(
			"Tipsy", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/tipsy/stylesheets/tipsy.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/tipsy/javascripts/jquery.tipsy.js"}
			],
			"Tipsy resources.", "Included in ADF 2.0 and later.", ""
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"TypeAheadBundle 10.5", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/typeahead/10.5/typeahead.bundle.min.js"}
			],
			"TypeAheadBundle resources.", "Included in ADF 2.0 and later.", "TypeAheadBundle"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"Uploadify 3.2", "SECONDARY",
			[
				{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/uploadify/3.2.1/uploadify.css"}
			],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/uploadify/3.2.1/jquery.uploadify.min.js"}
			],
			"Uploadify resources.", "Included in ADF 2.0 and later.", "Uploadify"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"UsedKeyboard 2.0", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/thirdParty/cfformprotect/js/usedKeyboard-2.0.1.js"}
			],
			"UsedKeyboard resources.", "Included in ADF 2.0 and later.", "UsedKeyboard"
			,0,attributes.updateExisting,0
		);

		application.ADF.scriptsService.registerResource
		(
			"ADFcsFormUtilities 1.0", "SECONDARY",
			[],
			[
				{LoadTagType=2, SourceURL="/ADF/lib/forms/cs-form-utilities.js"} // can this really be late loading?
			],
			"ADFcsFormUtilities resources.", "Included in ADF 2.0 and later.", "ADFcsFormUtilities"
			,0,attributes.updateExisting,0
		);

	}
</cfscript>

<!---<cfoutput><h1>Resources registered.</h1></cfoutput>--->