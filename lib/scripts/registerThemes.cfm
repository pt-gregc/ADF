<!---
	Script to register the theme/style resources inside the ADF as CommonSpot resources.

	History
	2016-03-14 - GAC - Initial version.

	NOTE: This code is DEV only! Not for production.
--->

<cfscript>
	if ( !structKeyExists(attributes, "updateExisting") )
		attributes.updateExisting = 0;

	//if ( !structKeyExists(attributes, "scriptsPackage") )
	//	attributes.scriptsPackage = "full"; // Options: full or  min


	// START

    jQueryUIversion = "1.11";

	/* jQuery UI Theme Javascript Resources */


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
		"BootstrapDefaultTheme 3.3", "PRIMARY",
		[
			{LoadTagType=1, SourceURL="/ADF/thirdParty/jquery/bootstrap/3.3/css/bootstrap-theme.min.css"}
		],
		[],
		"BootstrapDefaultTheme resources.", "Included in ADF 2.0 and later.", "BootstrapDefaultTheme"
		,0,attributes.updateExisting,0
	);

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
</cfscript>