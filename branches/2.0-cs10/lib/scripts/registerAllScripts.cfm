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
	resourceAPI = Server.CommonSpot.ObjectFactory.getObject("Resource");


	// HELPER FUNCTIONS
	// we may be able to get rid of some of these when CommonSpot has corresponding APIs in some form
	function registerResource
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
			else if (attributes.updateExisting != 0)
			{
				arguments.id = resSpecs.id;
				action = "updated";
			}
			else
			{
				writeOutput("Resource already exists, skipped: #arguments.name#<br>");
				return;
			}
		}
		arguments.earlyLoadSourceArray = getResourceArray(arguments.earlyLoadSourceArray);
		arguments.lateLoadSourceArray = getResourceArray(arguments.lateLoadSourceArray);
		writeOutput("Resource #action#: #arguments.name#<br>");
		return resourceAPI.save(argumentCollection=arguments);
	}
	function getResourceArray(resourceSpecsArray)
	{
		var arr = Request.TypeFactory.newObjectInstance("ResourceLoadStruct_Array");
		var count = arrayLen(arguments.resourceSpecsArray);
		var i = 0;
		for (i = 1; i <= count; i++)
			arrayAppend(arr, getResourceStruct(argumentCollection=arguments.resourceSpecsArray[i]));
		return arr;
	}
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
	}


	/* PRIMARY - MAJOR LIBRARIES */

	// these are the only js we load in the head by default, because they're called so much by existing code
	// even code that defers actual execution probably does that with the jQuery document ready function

	registerResource
	(
		"JQuery 1.11", "PRIMARY",
		[
			{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/jquery-1.11.js", canMinify=0}
		],
		[],
		"JQuery resources.", "Included in ADF 2.0 and later.", "JQuery"
	);

	registerResource
	(
		"JQueryMigrate 1.2", "PRIMARY",
		[
			{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/migrate/jquery-migrate-1.2.js", canMinify=0}
		],
		[],
		"JQueryMigrate resources.", "Included in ADF 2.0 and later.", "JQueryMigrate"
	);


	// major libs that load in the footer

	registerResource
	(
		"JQueryUI 1.11", "PRIMARY",
		[],
		[
			{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/ui/jquery-ui-1.11/js/jquery-ui-1.11.js", canMinify=0}
		],
		"JQueryUI resources.", "Included in ADF 2.0 and later.", "JQueryUI"
	);

	registerResource
	(
		"JQueryUIDefaultTheme 1.11", "PRIMARY",
		[
			{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/ui/jquery-ui-1.11/css/ui-lightness/jquery-ui.css", canCombine=0, canMinify=0}
		],
		[],
		"JQueryUIDefaultTheme resources.", "Included in ADF 2.0 and later.", "JQueryUIDefaultTheme,JQueryUIstyles"
	);

	registerResource
	(
		"JQueryMobile 1.4", "PRIMARY",
		[
			{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/mobile/1.4/jquery.mobile-1.4.min.css"}
		],
		[
			{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/mobile/1.4/jquery.mobile-1.4.min.js"}
		],
		"JQueryMobile resources.", "Included in ADF 2.0 and later.", "JQueryMobile"
	);

	registerResource
	(
		"Bootstrap 3.3", "PRIMARY",
		[
			{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/bootstrap/3.3/css/bootstrap.min.css"},
			{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/bootstrap/3.3/css/bootstrap-ADF-ext.css"} // An ADF extension css file that adds glyphicon sizes (lg,2x-10x).
		],
		[
			{LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/bootstrap/3.3/js/bootstrap.min.js"}
		],
		"Bootstrap resources.", "Included in ADF 2.0 and later.", "Bootstrap"
	);

	registerResource
	(
		"BootstrapDefaultTheme 3.3", "PRIMARY",
		[
			{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/bootstrap/3.3/css/bootstrap-theme.min.css"}
		],
		[],
		"BootstrapDefaultTheme resources.", "Included in ADF 2.0 and later.", "BootstrapDefaultTheme"
	);


	/* SECONDARY - COMMON ADF RESOURCES */

    
	registerResource
	(
		"ADFLightbox 1.0", "SECONDARY",
		[
			{LoadTagType=1, SourceURL="/ADF/extensions/lightbox/1.0/css/lightbox_overrides.css"},
			{LoadTagType=1, SourceURL="/commonspot/javascript/lightbox/lightbox.css"},
			{LoadTagType=1, SourceURL="/commonspot/dashboard/css/buttons.css"}
		],
		[
			{LoadTagType=2, SourceURL="/ADF/extensions/lightbox/1.0/js/framework.js"}
		],
		"ADFLightbox resources.", "Included in ADF 2.0 and later.", "ADFLightbox"
	);

	registerResource
	(
		"ADFStyles", "SECONDARY",
		[
			{LoadTagType=1, SourceURL="/ADF/extensions/style/ADF.css"}
		],
		[],
		"ADFStyles resources.", "Included in ADF 2.0 and later.", ""
	);

    // NOTE: using CommonSpot version number here
    registerResource
    (
        "CommonSpotStyles 10.0", "SECONDARY",
        [
            {LoadTagType=1, SourceURL="/commonspot/commonspot.css"}
        ],
        [],
        "CommonSpotStyles resources.", "Included in ADF 2.0 and later.", "CommonSpotStyles"
    );

    /* SECONDARY - PLUGINS ETC - leaving TERTIARY for customer or app code */

    if ( attributes.scriptsPackage EQ "full" )
    {
        
		registerResource
        (
            "AutoGrow 1.2", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/autogrow/autogrow-1.2.2.js"}
            ],
            "AutoGrow resources.", "Included in ADF 2.0 and later.", "AutoGrow"
        );

        registerResource
        (
            "CFJS 1.3", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/cfjs/1.3/jquery.cfjs.min.js"}
            ],
            "CFJS resources.", "Included in ADF 2.0 and later.", "CFJS"
        );

        registerResource
        (
            "CKEditor 4.5", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL=getCKEditorDefaultLocation()}
            ],
            "CKEditor resources.", "Included in ADF 2.0 and later.", "CKEditor"
        );

        function getCKEditorDefaultLocation(string version="4.5.3", string package="full", boolean useCDN=0, boolean force=0)
        {
            var libPath = "";
            var loadViaCDN = arguments.useCDN;
            var csScriptLibPath = "/cs_customization/ckeditor/ckeditor.js";
            var adfScriptLibPath = "/_cs_apps/thirdParty/ckeditor/ckeditor.js";
            var packageList = "basic,standard,standard-all,full,full-all";

            if (len(trim(arguments.package)) == 0 || listFindNoCase(packageList, arguments.package) == 0)
                arguments.package = "full";

            if (!loadViaCDN)
            {
                if (fileExists(expandPath(csScriptLibPath)))
                    libPath = csScriptLibPath;
                else if (fileExists(expandPath(adfScriptLibPath)))
                    libPath = adfScriptLibPath;
                else
                    loadViaCDN = true;
            }
            if (loadViaCDN)
                libPath = "http://cdn.ckeditor.com/#arguments.version#/#arguments.package#/ckeditor.js";
            // or we could do this:
                //libPath = Server.CommonSpot.ObjectFactory.getObject("FormattedTextblock").getEditorDefaultLocation();
            return libPath;
        }

        registerResource
        (
            "DateFormat 1.2", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/js/dateformat/1.2/date.format.js"}
            ],
            "DateFormat resources.", "Included in ADF 2.0 and later.", "DateFormat"
        );

        registerResource
        (
            "DateJS 1.0", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/js/datejs/1.0/date.js", canMinify=0}
            ],
            "DateJS resources.", "Included in ADF 2.0 and later.", "DateJS"
        );

        registerResource
        (
            "DropCurves 0.1", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/dropcurves/jquery.dropCurves-0.1.2.min.js"}
            ],
            "DropCurves resources.", "Included in ADF 2.0 and later.", "DropCurves"
        );

        registerResource
        (
            "Dynatree 1.1", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/dynatree/jquery-dynatree-1.1.1.js", canMinify=0}
            ],
            "Dynatree resources.", "Included in ADF 2.0 and later.", "Dynatree"
        );

        // NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
        registerResource
        (
            "JQueryCookie 1.2", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/cookie/jquery.cookie.js"}
            ],
            "JQueryCookie resources.", "Included in ADF 2.0 and later.", "JQueryCookie"
        );

        // TODO: no version number anywhere I found
        registerResource
        (
            "FileUploader", "SECONDARY",
            [ {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/fileuploader/client/fileuploader.css"} ],
            [ {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/fileuploader/client/fileuploader.js"} ],
            "FileUploader resources.", "Included in ADF 2.0 and later.", ""
        );

        registerResource
        (
            "FontAwesome 4.4", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/css/font-awesome/4.4/css/font-awesome.min.css", canCombine=0, canMinify=0}, // loads its own resources using relative URLs
                {LoadTagType=1, SourceURL="/ADF/thirdParty/css/font-awesome/4.4/css/font-awesome-ADF-ext.css"} // An ADF css extension css file that add sizes (6x-10x)
            ],
            [],
            "FontAwesome resources.", "Included in ADF 2.0 and later.", "FontAwesome"
        );

        registerResource
        (
            "GalleryView 1.1", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/galleryview/jquery-galleryview-1.1/jquery.galleryview-1.1-pack.js"}
            ],
            "GalleryView resources.", "Included in ADF 2.0 and later.", "GalleryView"
        );

        registerResource
        (
            "JQueryTimers 1.1", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/galleryview/jquery-galleryview-1.1/jquery.timers-1.1.2.js"}
            ],
            "JQueryTimers resources.", "Included in ADF 2.0 and later.", "JQueryTimers"
        );

        registerResource
        (
            "JQueryEasing 1.3", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/easing/jquery.easing.1.3.js"}
            ],
            "GalleryView resources.", "Included in ADF 2.0 and later.", "JQueryEasing"
        );

        // TODO: no version number I found
        registerResource
        (
            "JCarousel", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/jcarousel/jquery.jcarousel.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/jcarousel/jquery.jcarousel.pack.js"}
            ],
            "JCarousel resources.", "Included in ADF 2.0 and later.", ""
        );

        // TODO: no version number I found
        registerResource
        (
            "JCarouselDefaultSkin", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/jcarousel/skins/tango/skin.css"}
            ],
            [],
            "JCarouselDefaultSkin resources.", "Included in ADF 2.0 and later.", ""
        );

        // NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
        registerResource
        (
            "JCrop 0.9", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/jcrop/css/jquery.Jcrop.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/jcrop/js/jquery.Jcrop.min.js"}
            ],
            "JCrop resources.", "Included in ADF 2.0 and later.", "JCrop"
        );

        registerResource
        (
            "JCycle 2.9", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/jcycle/jquery.cycle.all-2.9.js"}
            ],
            "JCycle resources.", "Included in ADF 2.0 and later.", "JCycle"
        );

        registerResource
        (
            "JCycle2 20130909", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/jcycle2/20130909/jquery.cycle2.min.js"}
            ],
            "JCycle2 resources.", "Included in ADF 2.0 and later.", "JCycle2"
        );

        // NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
        registerResource
        (
            "JQueryAutocomplete 5.0", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/auto-complete/jquery.auto-complete.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/auto-complete/jquery.auto-complete.min.js"}
            ],
            "JQueryAutocomplete resources.", "Included in ADF 2.0 and later.", "JQueryAutocomplete"
        );

        // NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
        registerResource
        (
            "JQueryMetadata 5.0", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/auto-complete/jquery.metadata.js"},
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/auto-complete/jquery.auto-complete.min.js"}
            ],
            "JQueryAutocomplete resources.", "Included in ADF 2.0 and later.", "JQueryMetadata"
        );

        registerResource
        (
            "JQueryBBQ 1.3", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/bbq/1.3/jquery.ba-bbq.min.js"}
            ],
            "JQueryBBQ resources.", "Included in ADF 2.0 and later.", "JQueryBBQ"
        );

        registerResource
        (
            "JQueryBlockUI 2.7", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/blockUI/2.7/jquery.blockUI.min.js"}
            ],
            "JQueryBlockUI resources.", "Included in ADF 2.0 and later.", "JQueryBlockUI"
        );

        registerResource
        (
            "JQueryCalculation 0.4", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/calculation/0.4/jquery.calculation.min.js"}
            ],
            "JQueryCalculation resources.", "Included in ADF 2.0 and later.", "JQueryCalculation"
        );

        registerResource
        (
            "JQueryCalcX 1.1", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/calcx/1.1/jquery.calx.min.js"}
            ],
            "JQueryCalcX resources.", "Included in ADF 2.0 and later.", "JQueryCalcX"
        );

        // NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
        registerResource
        (
            "JQueryCapty 0.2", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/capty/css/jquery.capty.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/capty/js/jquery.capty.min.js"}
            ],
            "JQueryCapty resources.", "Included in ADF 2.0 and later.", "JQueryCapty"
        );

        registerResource
        (
            "JQueryCheckboxes 2.1", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/checkboxes/jquery.checkboxes-2.1.min.js"}
            ],
            "JQueryCheckboxes resources.", "Included in ADF 2.0 and later.", "JQueryCheckboxes"
        );

        registerResource
        (
            "JQueryDataTables 1.9", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/datatables/1.9/js/jquery.dataTables.min.js"}
            ],
            "JQueryDataTables resources.", "Included in ADF 2.0 and later.", "JQueryDataTables"
        );

        registerResource
        (
            "JQueryDataTablesStyles 1.9", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/datatables/1.9/css/demo_page.css"},
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/datatables/1.9/css/demo_table_jui.css"},
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/datatables/1.9/css/demo_table.css"},
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/datatables/1.9/css/jquery.dataTables.css"},
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/datatables/1.9/css/jquery.dataTables_themeroller.css"}
            ],
            [],
            "JQueryDataTables resources.", "Included in ADF 2.0 and later.", "JQueryDataTablesStyles"
        );

        // NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
        registerResource
        (
            "JQueryDatePick 4.0", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/datepick/jquery.datepick.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/datepick/jquery.datepick.js"}
            ],
            "JQueryDatePick resources.", "Included in ADF 2.0 and later.", "JQueryDatePick"
        );

        // NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
        registerResource
        (
            "JQueryDoTimeout 1.0", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/dotimeout/jquery.dotimeout.plugin.js", canMinify=0}
            ],
            "JQueryDoTimeout resources.", "Included in ADF 2.0 and later.", "JQueryDoTimeout"
        );

        // NOTE: no version number
        registerResource
        (
            "JQueryDump", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/dump/jquery.dump.js"}
            ],
            "JQueryDump resources.", "Included in ADF 2.0 and later.", ""
        );

        registerResource
        (
            "JQueryFancyBox 1.3", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/fancybox/jquery.fancybox-1.3.4.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/fancybox/jquery.fancybox-1.3.4.pack.js"}
            ],
            "JQueryFancyBox resources.", "Included in ADF 2.0 and later.", "JQueryFancyBox"
        );

        registerResource
        (
            "JQueryField 0.9", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/field/jquery.field-0.9.8.min.js"}
            ],
            "JQueryField resources.", "Included in ADF 2.0 and later.", "JQueryField"
        );

        // NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
        registerResource
        (
            "JQueryFileUpload 5.0", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/fileupload/jquery.fileupload-ui.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/fileupload/jquery.iframe-transport.js"},
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/fileupload/jquery.fileupload.js"},
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/fileupload/jquery.fileupload-ui.js"}
            ],
            "JQueryFileUpload resources.", "Included in ADF 2.0 and later.", "JQueryFileUpload"
        );

        registerResource
        (
            "JQueryHighlight 3.0", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/highlight/jquery.highlight-3.0.0.yui.js", canMinify=0}
            ],
            "JQueryHighlight resources.", "Included in ADF 2.0 and later.", "JQueryHighlight"
        );

        // NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
        registerResource
        (
            "JQueryHotkeys 0.8", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/hotkeys/jquery.hotkeys.js"}
            ],
            "JQueryHotkeys resources.", "Included in ADF 2.0 and later.", "JQueryHotkeys"
        );

        registerResource
        (
            "JQueryiCalendar 1.1", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/icalendar/1.1/jquery.icalendar.pt.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/icalendar/1.1/jquery.icalendar.pt.js"}
            ],
            "JQueryiCalendar resources.", "Included in ADF 2.0 and later.", "JQueryiCalendar"
        );

        registerResource
        (
            "JQueryImagesLoaded 3.0", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/imagesloaded/3.0/imagesloaded.pkgd.min.js"}
            ],
            "JQueryImagesLoaded resources.", "Included in ADF 2.0 and later.", "JQueryImagesLoaded"
        );

        registerResource
        (
            "JQueryJeditable 1.7", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/jeditable/1.7/jquery.jeditable.min.js"}
            ],
            "JQueryJeditable resources.", "Included in ADF 2.0 and later.", "JQueryJeditable"
        );

        registerResource
        (
            "JQueryJSON 2.2", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/json/jquery.json-2.2.min.js"}
            ],
            "JQueryJSON resources.", "Included in ADF 2.0 and later.", "JQueryJSON"
        );

        registerResource
        (
            "JQueryMouseWheel 3.0", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/mousewheel/jquery.mousewheel-3.0.4.pack.js"}
            ],
            "JQueryMouseWheel resources.", "Included in ADF 2.0 and later.", "JQueryMouseWheel"
        );

        // NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
        registerResource
        (
            "JQueryMultiselect 1.1", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/multiselect/jquery.multiselect.css"},
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/multiselect/jquery.multiselect.filter.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/multiselect/jquery.multiselect.min.js"},
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/multiselect/jquery.multiselect.filter.min.js"}
            ],
            "JQueryMultiselect resources.", "Included in ADF 2.0 and later.", "JQueryMultiselect"
        );

        registerResource
        (
            "JQueryNMCFormHelper 1.0", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/nmcFormHelper/1.0/nmcFormHelper.min.js"}
            ],
            "JQueryNMCFormHelper resources.", "Included in ADF 2.0 and later.", "JQueryNMCFormHelper"
        );

        registerResource
        (
            "JQueryPlupload", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/plupload/js/plupload.full.js", canMinify=0}
            ],
            "JQueryPlupload resources.", "Included in ADF 2.0 and later.", ""
        );

        registerResource
        (
            "JQuerySelectboxes 2.2", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/selectboxes/jquery.selectboxes-2.2.4.min.js"}
            ],
            "JQuerySelectboxes resources.", "Included in ADF 2.0 and later.", "JQuerySelectboxes"
        );

        registerResource
        (
            "JQuerySuperfish 1.4", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/superfish/css/superfish.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/superfish/jquery.superfish-1.4.8.js"}
            ],
            "JQuerySuperfish resources.", "Included in ADF 2.0 and later.", "JQuerySuperfish"
        );

        registerResource
        (
            "JQueryHoverIntent 1.4", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/superfish/hoverIntent.js"}
            ],
            "JQueryHoverIntent resources.", "Included in ADF 2.0 and later.", "JQueryHoverIntent"
        );

        registerResource
        (
            "jQuerySWFObject 1.0", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/swfobject/jquery.swfobject-1.0.9.min.js"}
            ],
            "jQuerySWFObject resources.", "Included in ADF 2.0 and later.", "jQuerySWFObject"
        );

        registerResource
        (
            "SWFObject 2.2", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/swfobject/swfobject-2.2.js", canMinify=0}
            ],
            "SWFObject resources.", "Included in ADF 2.0 and later.", "SWFObject"
        );

        registerResource
        (
            "JQuerySWFUpload 2.2", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/swfupload/swfupload-2.2.0.1/swfupload.js"}
            ],
            "JQuerySWFUpload resources.", "Included in ADF 2.0 and later.", "JQuerySWFUpload"
        );

        registerResource
        (
            "JQuerySWFUploadQueue 2.2", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/swfupload/swfupload-2.2.0.1/swfupload.queue.js"}
            ],
            "JQuerySWFUpload resources.", "Included in ADF 2.0 and later.", "JQuerySWFUploadQueue"
        );

        registerResource
        (
            "JQueryTemplates 1.0", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/templates/jquery.tmpl.min.js"}
            ],
            "JQueryTemplates resources.", "Included in ADF 2.0 and later.", "JQueryTemplates"
        );

        registerResource
        (
            "JQueryTextLimit 2209.07", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/textlimit/jquery.textlimit.plugin.js"}
            ],
            "JQueryTextLimit resources.", "Included in ADF 2.0 and later.", "JQueryTextLimit"
        );

        registerResource
        (
            "JQueryTimeAgo 1.4", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/timeago/1.4/jquery.timeago-1.4.1.js"}
            ],
            "JQueryTimeAgo resources.", "Included in ADF 2.0 and later.", "JQueryTimeAgo"
        );

        registerResource
        (
            "JQueryTools 1.2", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/tools/1.2/jquery.tools.min.js"}
            ],
            "JQueryTools resources.", "Included in ADF 2.0 and later.", "JQueryTools"
        );

        registerResource
        (
            "JQueryUIStars", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/ui/stars/3.0/ui.stars.min.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/ui/stars/3.0/ui.stars.min.js"}
            ],
            "JQueryUIStars resources.", "Included in ADF 2.0 and later.", ""
        );

        registerResource
        (
            "JQueryUITimepickerAddon 1.2", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/ui/timepicker-addon/1.2/jquery-ui-timepicker-addon.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/ui/timepicker-addon/1.2/jquery-ui-timepicker-addon.js"},
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/ui/timepicker-addon/1.2/jquery-ui-sliderAccess.js"}
            ],
            "JQueryUITimepickerAddon resources.", "Included in ADF 2.0 and later.", "JQueryUITimepickerAddon"
        );

        registerResource
        (
            "JQueryUITimepickerFG 0.3", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/ui/timepicker-fg/0.3/jquery.ui.timepicker.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/ui/timepicker-fg/0.3/jquery.ui.timepicker.js"}
            ],
            "JQueryUITimepickerFG resources.", "Included in ADF 2.0 and later.", "JQueryUITimepickerFG"
        );

        registerResource
        (
            "JSONJS 2", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/js/json-js/json2.js"}
            ],
            "JSONJS resources.", "Included in ADF 2.0 and later.", "JSONJS"
        );

        registerResource
        (
            "JSTree 3.0", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/jsTree/3.0/jstree.min.js"}
            ],
            "JSTree resources.", "Included in ADF 2.0 and later.", "JSTree"
        );

        registerResource
        (
            "JSTreeDefaultStyles 3.0", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/jsTree/3.0/themes/default/style.min.css"}
            ],
            [],
            "JSTreeDefaultStyles resources.", "Included in ADF 2.0 and later.", "JSTreeDefaultStyles"
        );

        // NOTE: version is actually as registered, but that's not in the file name, renaming it would break any direct callers
        registerResource
        (
            "MathUUID 1.4", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/js/math-uuid/math.uuid.js"}
            ],
            "MathUUID resources.", "Included in ADF 2.0 and later.", "MathUUID"
        );

        registerResource
        (
            "MouseMovement 2.0", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/cfformprotect/js/mouseMovement-2.0.1.js"}
            ],
            "MouseMovement resources.", "Included in ADF 2.0 and later.", "MouseMovement"
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
        );*/


        registerResource
        (
            "QTip 2.1", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/qtip/2.1/jquery.qtip.min.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/qtip/2.1/jquery.qtip.min.js"}
            ],
            "QTip resources.", "Included in ADF 2.0 and later.", "QTip"
        );

        /* HIGH: there's nothing like this in the ADF
        registerResource
        (
            "SimplePassMeter", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/simplePassMeter/simplePassMeter.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/simplePassMeter/jquery.simplePassMeter-0.3.min.js"}
            ],
            "SimplePassMeter resources.", "Included in ADF 2.0 and later.", ""
        );*/

        registerResource
        (
            "TableSorter 2.0", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/tablesorter/2.0/jquery.tablesorter.min.js"}
            ],
            "TableSorter resources.", "Included in ADF 2.0 and later.", "TableSorter"
        );

        registerResource
        (
            "TableSorterPager 2.0", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/tablesorter/2.0/addons/pager/jquery.tablesorter.pager.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/tablesorter/2.0/addons/pager/jquery.tablesorter.pager.js"}
            ],
            "TableSorterPager resources.", "Included in ADF 2.0 and later.", "TableSorterPager"
        );

        registerResource
        (
            "TableSorterThemes 2.0", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/tablesorter/2.0/themes/blue/style.css"}
            ],
            [],
            "TableSorterThemes resources.", "Included in ADF 2.0 and later.", "TableSorterThemes"
        );

        registerResource
        (
            "Thickbox 3.1", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/thickbox/thickbox.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/thickbox/thickbox-3.1.js"}
            ],
            "Thickbox resources.", "Included in ADF 2.0 and later.", "Thickbox"
        );

        // NOTE: no version number
        registerResource
        (
            "Tipsy", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/tipsy/stylesheets/tipsy.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/tipsy/javascripts/jquery.tipsy.js"}
            ],
            "Tipsy resources.", "Included in ADF 2.0 and later.", ""
        );

        registerResource
        (
            "TypeAheadBundle 10.5", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/typeahead/10.5/typeahead.bundle.min.js"}
            ],
            "TypeAheadBundle resources.", "Included in ADF 2.0 and later.", "TypeAheadBundle"
        );

        registerResource
        (
            "Uploadify 3.2", "SECONDARY",
            [
                {LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/uploadify/3.2.1/uploadify.css"}
            ],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/jquery/uploadify/3.2.1/jquery.uploadify.min.js"}
            ],
            "Uploadify resources.", "Included in ADF 2.0 and later.", "Uploadify"
        );

        registerResource
        (
            "UsedKeyboard 2.0", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/thirdParty/cfformprotect/js/usedKeyboard-2.0.1.js"}
            ],
            "UsedKeyboard resources.", "Included in ADF 2.0 and later.", "UsedKeyboard"
        );

        registerResource
        (
            "ADFcsFormUtilities 1.0", "SECONDARY",
            [],
            [
                {LoadTagType=2, SourceURL="/ADF/lib/forms/cs-form-utilities.js"} // can this really be late loading?
            ],
            "ADFcsFormUtilities resources.", "Included in ADF 2.0 and later.", "ADFcsFormUtilities"
        );
		
    }
</cfscript>

<cfoutput><h1>Resources registered.</h1></cfoutput>