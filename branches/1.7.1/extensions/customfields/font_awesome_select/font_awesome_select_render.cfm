<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
All Rights Reserved.
 
By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin Inc.
Name:
	font_awesome_select_render.cfm
Summary:
	renders field for font awesome icon custom field type
Version:
	1.0.0
History:
	2014-09-15 - Created
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	if( NOT StructKeyExists(xparams,'ShowSize') )
		xparams.ShowSize = 0;
	if( NOT StructKeyExists(xparams,'ShowFixedWidth') )
		xparams.ShowFixedWidth = 0;
	if( NOT StructKeyExists(xparams,'ShowBorder') )
		xparams.ShowBorder = 0;
	if( NOT StructKeyExists(xparams,'ShowSpin') )
		xparams.ShowSpin = 0;
	if( NOT StructKeyExists(xparams,'ShowPull') )
		xparams.ShowPull = 0;

	// Validate if the property field has been defined
	if ( NOT StructKeyExists(xparams, "fldID") OR LEN(xparams.fldID) LTE 0 )
		xparams.fldID = fqFieldName;

	// Set defaults for the label and description 
	includeLabel = true;
	includeDescription = true; 

	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";

	//-- Read Only Check w/ cs6 fieldPermission parameter --
	readOnly = application.ADF.forms.isFieldReadOnly(xparams,variables.fieldPermission);
	
	// Build the Font Awesome Icons array
	fontArray = ArrayNew(1);
	ArrayAppend( fontArray, 'fa-adjust,&##xf042;' ); 
	ArrayAppend( fontArray, 'fa-adn,&##xf170;' ); 
	ArrayAppend( fontArray, 'fa-align-center,&##xf037;' ); 
	ArrayAppend( fontArray, 'fa-align-justify,&##xf039;' ); 
	ArrayAppend( fontArray, 'fa-align-left,&##xf036;' ); 
	ArrayAppend( fontArray, 'fa-align-right,&##xf038;' ); 
	ArrayAppend( fontArray, 'fa-ambulance,&##xf0f9;' ); 
	ArrayAppend( fontArray, 'fa-anchor,&##xf13d;' ); 
	ArrayAppend( fontArray, 'fa-android,&##xf17b;' ); 
	ArrayAppend( fontArray, 'fa-angle-double-down,&##xf103;' ); 
	ArrayAppend( fontArray, 'fa-angle-double-left,&##xf100;' ); 
	ArrayAppend( fontArray, 'fa-angle-double-right,&##xf101;' ); 
	ArrayAppend( fontArray, 'fa-angle-double-up,&##xf102;' ); 
	ArrayAppend( fontArray, 'fa-angle-down,&##xf107;' ); 
	ArrayAppend( fontArray, 'fa-angle-left,&##xf104;' ); 
	ArrayAppend( fontArray, 'fa-angle-right,&##xf105;' ); 
	ArrayAppend( fontArray, 'fa-angle-up,&##xf106;' ); 
	ArrayAppend( fontArray, 'fa-apple,&##xf179;' ); 
	ArrayAppend( fontArray, 'fa-archive,&##xf187;' ); 
	ArrayAppend( fontArray, 'fa-arrow-circle-down,&##xf0ab;' ); 
	ArrayAppend( fontArray, 'fa-arrow-circle-left,&##xf0a8;' ); 
	ArrayAppend( fontArray, 'fa-arrow-circle-o-down,&##xf01a;' ); 
	ArrayAppend( fontArray, 'fa-arrow-circle-o-left,&##xf190;' ); 
	ArrayAppend( fontArray, 'fa-arrow-circle-o-right,&##xf18e;' ); 
	ArrayAppend( fontArray, 'fa-arrow-circle-o-up,&##xf01b;' ); 
	ArrayAppend( fontArray, 'fa-arrow-circle-right,&##xf0a9;' ); 
	ArrayAppend( fontArray, 'fa-arrow-circle-up,&##xf0aa;' ); 
	ArrayAppend( fontArray, 'fa-arrow-down,&##xf063;' ); 
	ArrayAppend( fontArray, 'fa-arrow-left,&##xf060;' ); 
	ArrayAppend( fontArray, 'fa-arrow-right,&##xf061;' ); 
	ArrayAppend( fontArray, 'fa-arrow-up,&##xf062;' ); 
	ArrayAppend( fontArray, 'fa-arrows,&##xf047;' ); 
	ArrayAppend( fontArray, 'fa-arrows-alt,&##xf0b2;' ); 
	ArrayAppend( fontArray, 'fa-arrows-h,&##xf07e;' ); 
	ArrayAppend( fontArray, 'fa-arrows-v,&##xf07d;' ); 
	ArrayAppend( fontArray, 'fa-asterisk,&##xf069;' ); 
	ArrayAppend( fontArray, 'fa-automobile,&##xf1b9;' ); 
	ArrayAppend( fontArray, 'fa-backward,&##xf04a;' ); 
	ArrayAppend( fontArray, 'fa-ban,&##xf05e;' ); 
	ArrayAppend( fontArray, 'fa-bank,&##xf19c;' ); 
	ArrayAppend( fontArray, 'fa-bar-chart-o,&##xf080;' ); 
	ArrayAppend( fontArray, 'fa-barcode,&##xf02a;' ); 
	ArrayAppend( fontArray, 'fa-bars,&##xf0c9;' ); 
	ArrayAppend( fontArray, 'fa-beer,&##xf0fc;' ); 
	ArrayAppend( fontArray, 'fa-behance,&##xf1b4;' ); 
	ArrayAppend( fontArray, 'fa-behance-square,&##xf1b5;' ); 
	ArrayAppend( fontArray, 'fa-bell,&##xf0f3;' ); 
	ArrayAppend( fontArray, 'fa-bell-o,&##xf0a2;' ); 
	ArrayAppend( fontArray, 'fa-bitbucket,&##xf171;' ); 
	ArrayAppend( fontArray, 'fa-bitbucket-square,&##xf172;' ); 
	ArrayAppend( fontArray, 'fa-bitcoin,&##xf15a;' ); 
	ArrayAppend( fontArray, 'fa-bold,&##xf032;' ); 
	ArrayAppend( fontArray, 'fa-bolt,&##xf0e7;' ); 
	ArrayAppend( fontArray, 'fa-bomb,&##xf1e2;' ); 
	ArrayAppend( fontArray, 'fa-book,&##xf02d;' ); 
	ArrayAppend( fontArray, 'fa-bookmark,&##xf02e;' ); 
	ArrayAppend( fontArray, 'fa-bookmark-o,&##xf097;' ); 
	ArrayAppend( fontArray, 'fa-briefcase,&##xf0b1;' ); 
	ArrayAppend( fontArray, 'fa-btc,&##xf15a;' ); 
	ArrayAppend( fontArray, 'fa-bug,&##xf188;' ); 
	ArrayAppend( fontArray, 'fa-building,&##xf1ad;' ); 
	ArrayAppend( fontArray, 'fa-building-o,&##xf0f7;' ); 
	ArrayAppend( fontArray, 'fa-bullhorn,&##xf0a1;' ); 
	ArrayAppend( fontArray, 'fa-bullseye,&##xf140;' ); 
	ArrayAppend( fontArray, 'fa-cab,&##xf1ba;' ); 
	ArrayAppend( fontArray, 'fa-calendar,&##xf073;' ); 
	ArrayAppend( fontArray, 'fa-calendar-o,&##xf133;' ); 
	ArrayAppend( fontArray, 'fa-camera,&##xf030;' ); 
	ArrayAppend( fontArray, 'fa-camera-retro,&##xf083;' ); 
	ArrayAppend( fontArray, 'fa-car,&##xf1b9;' ); 
	ArrayAppend( fontArray, 'fa-caret-down,&##xf0d7;' ); 
	ArrayAppend( fontArray, 'fa-caret-left,&##xf0d9;' ); 
	ArrayAppend( fontArray, 'fa-caret-right,&##xf0da;' ); 
	ArrayAppend( fontArray, 'fa-caret-square-o-down,&##xf150;' ); 
	ArrayAppend( fontArray, 'fa-caret-square-o-left,&##xf191;' ); 
	ArrayAppend( fontArray, 'fa-caret-square-o-right,&##xf152;' ); 
	ArrayAppend( fontArray, 'fa-caret-square-o-up,&##xf151;' ); 
	ArrayAppend( fontArray, 'fa-caret-up,&##xf0d8;' ); 
	ArrayAppend( fontArray, 'fa-certificate,&##xf0a3;' ); 
	ArrayAppend( fontArray, 'fa-chain,&##xf0c1;' ); 
	ArrayAppend( fontArray, 'fa-chain-broken,&##xf127;' ); 
	ArrayAppend( fontArray, 'fa-check,&##xf00c;' ); 
	ArrayAppend( fontArray, 'fa-check-circle,&##xf058;' ); 
	ArrayAppend( fontArray, 'fa-check-circle-o,&##xf05d;' ); 
	ArrayAppend( fontArray, 'fa-check-square,&##xf14a;' ); 
	ArrayAppend( fontArray, 'fa-check-square-o,&##xf046;' ); 
	ArrayAppend( fontArray, 'fa-chevron-circle-down,&##xf13a;' ); 
	ArrayAppend( fontArray, 'fa-chevron-circle-left,&##xf137;' ); 
	ArrayAppend( fontArray, 'fa-chevron-circle-right,&##xf138;' ); 
	ArrayAppend( fontArray, 'fa-chevron-circle-up,&##xf139;' ); 
	ArrayAppend( fontArray, 'fa-chevron-down,&##xf078;' ); 
	ArrayAppend( fontArray, 'fa-chevron-left,&##xf053;' ); 
	ArrayAppend( fontArray, 'fa-chevron-right,&##xf054;' ); 
	ArrayAppend( fontArray, 'fa-chevron-up,&##xf077;' ); 
	ArrayAppend( fontArray, 'fa-child,&##xf1ae;' ); 
	ArrayAppend( fontArray, 'fa-circle,&##xf111;' ); 
	ArrayAppend( fontArray, 'fa-circle-o,&##xf10c;' ); 
	ArrayAppend( fontArray, 'fa-circle-o-notch,&##xf1ce;' ); 
	ArrayAppend( fontArray, 'fa-circle-thin,&##xf1db;' ); 
	ArrayAppend( fontArray, 'fa-clipboard,&##xf0ea;' ); 
	ArrayAppend( fontArray, 'fa-clock-o,&##xf017;' ); 
	ArrayAppend( fontArray, 'fa-cloud,&##xf0c2;' ); 
	ArrayAppend( fontArray, 'fa-cloud-download,&##xf0ed;' ); 
	ArrayAppend( fontArray, 'fa-cloud-upload,&##xf0ee;' ); 
	ArrayAppend( fontArray, 'fa-cny,&##xf157;' ); 
	ArrayAppend( fontArray, 'fa-code,&##xf121;' ); 
	ArrayAppend( fontArray, 'fa-code-fork,&##xf126;' ); 
	ArrayAppend( fontArray, 'fa-codepen,&##xf1cb;' ); 
	ArrayAppend( fontArray, 'fa-coffee,&##xf0f4;' ); 
	ArrayAppend( fontArray, 'fa-cog,&##xf013;' ); 
	ArrayAppend( fontArray, 'fa-cogs,&##xf085;' ); 
	ArrayAppend( fontArray, 'fa-columns,&##xf0db;' ); 
	ArrayAppend( fontArray, 'fa-comment,&##xf075;' ); 
	ArrayAppend( fontArray, 'fa-comment-o,&##xf0e5;' ); 
	ArrayAppend( fontArray, 'fa-comments,&##xf086;' ); 
	ArrayAppend( fontArray, 'fa-comments-o,&##xf0e6;' ); 
	ArrayAppend( fontArray, 'fa-compass,&##xf14e;' ); 
	ArrayAppend( fontArray, 'fa-compress,&##xf066;' ); 
	ArrayAppend( fontArray, 'fa-copy,&##xf0c5;' ); 
	ArrayAppend( fontArray, 'fa-credit-card,&##xf09d;' ); 
	ArrayAppend( fontArray, 'fa-crop,&##xf125;' ); 
	ArrayAppend( fontArray, 'fa-crosshairs,&##xf05b;' ); 
	ArrayAppend( fontArray, 'fa-css3,&##xf13c;' ); 
	ArrayAppend( fontArray, 'fa-cube,&##xf1b2;' ); 
	ArrayAppend( fontArray, 'fa-cubes,&##xf1b3;' ); 
	ArrayAppend( fontArray, 'fa-cut,&##xf0c4;' ); 
	ArrayAppend( fontArray, 'fa-cutlery,&##xf0f5;' ); 
	ArrayAppend( fontArray, 'fa-dashboard,&##xf0e4;' ); 
	ArrayAppend( fontArray, 'fa-database,&##xf1c0;' ); 
	ArrayAppend( fontArray, 'fa-dedent,&##xf03b;' ); 
	ArrayAppend( fontArray, 'fa-delicious,&##xf1a5;' ); 
	ArrayAppend( fontArray, 'fa-desktop,&##xf108;' ); 
	ArrayAppend( fontArray, 'fa-deviantart,&##xf1bd;' ); 
	ArrayAppend( fontArray, 'fa-digg,&##xf1a6;' ); 
	ArrayAppend( fontArray, 'fa-dollar,&##xf155;' ); 
	ArrayAppend( fontArray, 'fa-dot-circle-o,&##xf192;' ); 
	ArrayAppend( fontArray, 'fa-download,&##xf019;' ); 
	ArrayAppend( fontArray, 'fa-dribbble,&##xf17d;' ); 
	ArrayAppend( fontArray, 'fa-dropbox,&##xf16b;' ); 
	ArrayAppend( fontArray, 'fa-drupal,&##xf1a9;' ); 
	ArrayAppend( fontArray, 'fa-edit,&##xf044;' ); 
	ArrayAppend( fontArray, 'fa-eject,&##xf052;' ); 
	ArrayAppend( fontArray, 'fa-ellipsis-h,&##xf141;' ); 
	ArrayAppend( fontArray, 'fa-ellipsis-v,&##xf142;' ); 
	ArrayAppend( fontArray, 'fa-empire,&##xf1d1;' ); 
	ArrayAppend( fontArray, 'fa-envelope,&##xf0e0;' ); 
	ArrayAppend( fontArray, 'fa-envelope-o,&##xf003;' ); 
	ArrayAppend( fontArray, 'fa-envelope-square,&##xf199;' ); 
	ArrayAppend( fontArray, 'fa-eraser,&##xf12d;' ); 
	ArrayAppend( fontArray, 'fa-eur,&##xf153;' ); 
	ArrayAppend( fontArray, 'fa-euro,&##xf153;' ); 
	ArrayAppend( fontArray, 'fa-exchange,&##xf0ec;' ); 
	ArrayAppend( fontArray, 'fa-exclamation,&##xf12a;' ); 
	ArrayAppend( fontArray, 'fa-exclamation-circle,&##xf06a;' ); 
	ArrayAppend( fontArray, 'fa-exclamation-triangle,&##xf071;' ); 
	ArrayAppend( fontArray, 'fa-expand,&##xf065;' ); 
	ArrayAppend( fontArray, 'fa-external-link,&##xf08e;' ); 
	ArrayAppend( fontArray, 'fa-external-link-square,&##xf14c;' ); 
	ArrayAppend( fontArray, 'fa-eye,&##xf06e;' ); 
	ArrayAppend( fontArray, 'fa-eye-slash,&##xf070;' ); 
	ArrayAppend( fontArray, 'fa-facebook,&##xf09a;' ); 
	ArrayAppend( fontArray, 'fa-facebook-square,&##xf082;' ); 
	ArrayAppend( fontArray, 'fa-fast-backward,&##xf049;' ); 
	ArrayAppend( fontArray, 'fa-fast-forward,&##xf050;' ); 
	ArrayAppend( fontArray, 'fa-fax,&##xf1ac;' ); 
	ArrayAppend( fontArray, 'fa-female,&##xf182;' ); 
	ArrayAppend( fontArray, 'fa-fighter-jet,&##xf0fb;' ); 
	ArrayAppend( fontArray, 'fa-file,&##xf15b;' ); 
	ArrayAppend( fontArray, 'fa-file-archive-o,&##xf1c6;' ); 
	ArrayAppend( fontArray, 'fa-file-audio-o,&##xf1c7;' ); 
	ArrayAppend( fontArray, 'fa-file-code-o,&##xf1c9;' ); 
	ArrayAppend( fontArray, 'fa-file-excel-o,&##xf1c3;' ); 
	ArrayAppend( fontArray, 'fa-file-image-o,&##xf1c5;' ); 
	ArrayAppend( fontArray, 'fa-file-movie-o,&##xf1c8;' ); 
	ArrayAppend( fontArray, 'fa-file-o,&##xf016;' ); 
	ArrayAppend( fontArray, 'fa-file-pdf-o,&##xf1c1;' ); 
	ArrayAppend( fontArray, 'fa-file-photo-o,&##xf1c5;' ); 
	ArrayAppend( fontArray, 'fa-file-picture-o,&##xf1c5;' ); 
	ArrayAppend( fontArray, 'fa-file-powerpoint-o,&##xf1c4;' ); 
	ArrayAppend( fontArray, 'fa-file-sound-o,&##xf1c7;' ); 
	ArrayAppend( fontArray, 'fa-file-text,&##xf15c;' ); 
	ArrayAppend( fontArray, 'fa-file-text-o,&##xf0f6;' ); 
	ArrayAppend( fontArray, 'fa-file-video-o,&##xf1c8;' ); 
	ArrayAppend( fontArray, 'fa-file-word-o,&##xf1c2;' ); 
	ArrayAppend( fontArray, 'fa-file-zip-o,&##xf1c6;' ); 
	ArrayAppend( fontArray, 'fa-files-o,&##xf0c5;' ); 
	ArrayAppend( fontArray, 'fa-film,&##xf008;' ); 
	ArrayAppend( fontArray, 'fa-filter,&##xf0b0;' ); 
	ArrayAppend( fontArray, 'fa-fire,&##xf06d;' ); 
	ArrayAppend( fontArray, 'fa-fire-extinguisher,&##xf134;' ); 
	ArrayAppend( fontArray, 'fa-flag,&##xf024;' ); 
	ArrayAppend( fontArray, 'fa-flag-checkered,&##xf11e;' ); 
	ArrayAppend( fontArray, 'fa-flag-o,&##xf11d;' ); 
	ArrayAppend( fontArray, 'fa-flash,&##xf0e7;' ); 
	ArrayAppend( fontArray, 'fa-flask,&##xf0c3;' ); 
	ArrayAppend( fontArray, 'fa-flickr,&##xf16e;' ); 
	ArrayAppend( fontArray, 'fa-floppy-o,&##xf0c7;' ); 
	ArrayAppend( fontArray, 'fa-folder,&##xf07b;' ); 
	ArrayAppend( fontArray, 'fa-folder-o,&##xf114;' ); 
	ArrayAppend( fontArray, 'fa-folder-open,&##xf07c;' ); 
	ArrayAppend( fontArray, 'fa-folder-open-o,&##xf115;' ); 
	ArrayAppend( fontArray, 'fa-font,&##xf031;' ); 
	ArrayAppend( fontArray, 'fa-forward,&##xf04e;' ); 
	ArrayAppend( fontArray, 'fa-foursquare,&##xf180;' ); 
	ArrayAppend( fontArray, 'fa-frown-o,&##xf119;' ); 
	ArrayAppend( fontArray, 'fa-gamepad,&##xf11b;' ); 
	ArrayAppend( fontArray, 'fa-gavel,&##xf0e3;' ); 
	ArrayAppend( fontArray, 'fa-gbp,&##xf154;' ); 
	ArrayAppend( fontArray, 'fa-ge,&##xf1d1;' ); 
	ArrayAppend( fontArray, 'fa-gear,&##xf013;' ); 
	ArrayAppend( fontArray, 'fa-gears,&##xf085;' ); 
	ArrayAppend( fontArray, 'fa-gift,&##xf06b;' ); 
	ArrayAppend( fontArray, 'fa-git,&##xf1d3;' ); 
	ArrayAppend( fontArray, 'fa-git-square,&##xf1d2;' ); 
	ArrayAppend( fontArray, 'fa-github,&##xf09b;' ); 
	ArrayAppend( fontArray, 'fa-github-alt,&##xf113;' ); 
	ArrayAppend( fontArray, 'fa-github-square,&##xf092;' ); 
	ArrayAppend( fontArray, 'fa-gittip,&##xf184;' ); 
	ArrayAppend( fontArray, 'fa-glass,&##xf000;' ); 
	ArrayAppend( fontArray, 'fa-globe,&##xf0ac;' ); 
	ArrayAppend( fontArray, 'fa-google,&##xf1a0;' ); 
	ArrayAppend( fontArray, 'fa-google-plus,&##xf0d5;' ); 
	ArrayAppend( fontArray, 'fa-google-plus-square,&##xf0d4;' ); 
	ArrayAppend( fontArray, 'fa-graduation-cap,&##xf19d;' ); 
	ArrayAppend( fontArray, 'fa-group,&##xf0c0;' ); 
	ArrayAppend( fontArray, 'fa-h-square,&##xf0fd;' ); 
	ArrayAppend( fontArray, 'fa-hacker-news,&##xf1d4;' ); 
	ArrayAppend( fontArray, 'fa-hand-o-down,&##xf0a7;' ); 
	ArrayAppend( fontArray, 'fa-hand-o-left,&##xf0a5;' ); 
	ArrayAppend( fontArray, 'fa-hand-o-right,&##xf0a4;' ); 
	ArrayAppend( fontArray, 'fa-hand-o-up,&##xf0a6;' ); 
	ArrayAppend( fontArray, 'fa-hdd-o,&##xf0a0;' ); 
	ArrayAppend( fontArray, 'fa-header,&##xf1dc;' ); 
	ArrayAppend( fontArray, 'fa-headphones,&##xf025;' ); 
	ArrayAppend( fontArray, 'fa-heart,&##xf004;' ); 
	ArrayAppend( fontArray, 'fa-heart-o,&##xf08a;' ); 
	ArrayAppend( fontArray, 'fa-history,&##xf1da;' ); 
	ArrayAppend( fontArray, 'fa-home,&##xf015;' ); 
	ArrayAppend( fontArray, 'fa-hospital-o,&##xf0f8;' ); 
	ArrayAppend( fontArray, 'fa-html5,&##xf13b;' ); 
	ArrayAppend( fontArray, 'fa-image,&##xf03e;' ); 
	ArrayAppend( fontArray, 'fa-inbox,&##xf01c;' ); 
	ArrayAppend( fontArray, 'fa-indent,&##xf03c;' ); 
	ArrayAppend( fontArray, 'fa-info,&##xf129;' ); 
	ArrayAppend( fontArray, 'fa-info-circle,&##xf05a;' ); 
	ArrayAppend( fontArray, 'fa-inr,&##xf156;' ); 
	ArrayAppend( fontArray, 'fa-instagram,&##xf16d;' ); 
	ArrayAppend( fontArray, 'fa-institution,&##xf19c;' ); 
	ArrayAppend( fontArray, 'fa-italic,&##xf033;' ); 
	ArrayAppend( fontArray, 'fa-joomla,&##xf1aa;' ); 
	ArrayAppend( fontArray, 'fa-jpy,&##xf157;' ); 
	ArrayAppend( fontArray, 'fa-jsfiddle,&##xf1cc;' ); 
	ArrayAppend( fontArray, 'fa-key,&##xf084;' ); 
	ArrayAppend( fontArray, 'fa-keyboard-o,&##xf11c;' ); 
	ArrayAppend( fontArray, 'fa-krw,&##xf159;' ); 
	ArrayAppend( fontArray, 'fa-language,&##xf1ab;' ); 
	ArrayAppend( fontArray, 'fa-laptop,&##xf109;' ); 
	ArrayAppend( fontArray, 'fa-leaf,&##xf06c;' ); 
	ArrayAppend( fontArray, 'fa-legal,&##xf0e3;' ); 
	ArrayAppend( fontArray, 'fa-lemon-o,&##xf094;' ); 
	ArrayAppend( fontArray, 'fa-level-down,&##xf149;' ); 
	ArrayAppend( fontArray, 'fa-level-up,&##xf148;' ); 
	ArrayAppend( fontArray, 'fa-life-bouy,&##xf1cd;' ); 
	ArrayAppend( fontArray, 'fa-life-ring,&##xf1cd;' ); 
	ArrayAppend( fontArray, 'fa-life-saver,&##xf1cd;' ); 
	ArrayAppend( fontArray, 'fa-lightbulb-o,&##xf0eb;' ); 
	ArrayAppend( fontArray, 'fa-link,&##xf0c1;' ); 
	ArrayAppend( fontArray, 'fa-linkedin,&##xf0e1;' ); 
	ArrayAppend( fontArray, 'fa-linkedin-square,&##xf08c;' ); 
	ArrayAppend( fontArray, 'fa-linux,&##xf17c;' ); 
	ArrayAppend( fontArray, 'fa-list,&##xf03a;' ); 
	ArrayAppend( fontArray, 'fa-list-alt,&##xf022;' ); 
	ArrayAppend( fontArray, 'fa-list-ol,&##xf0cb;' ); 
	ArrayAppend( fontArray, 'fa-list-ul,&##xf0ca;' ); 
	ArrayAppend( fontArray, 'fa-location-arrow,&##xf124;' ); 
	ArrayAppend( fontArray, 'fa-lock,&##xf023;' ); 
	ArrayAppend( fontArray, 'fa-long-arrow-down,&##xf175;' ); 
	ArrayAppend( fontArray, 'fa-long-arrow-left,&##xf177;' ); 
	ArrayAppend( fontArray, 'fa-long-arrow-right,&##xf178;' ); 
	ArrayAppend( fontArray, 'fa-long-arrow-up,&##xf176;' ); 
	ArrayAppend( fontArray, 'fa-magic,&##xf0d0;' ); 
	ArrayAppend( fontArray, 'fa-magnet,&##xf076;' ); 
	ArrayAppend( fontArray, 'fa-mail-forward,&##xf064;' ); 
	ArrayAppend( fontArray, 'fa-mail-reply,&##xf112;' ); 
	ArrayAppend( fontArray, 'fa-mail-reply-all,&##xf122;' ); 
	ArrayAppend( fontArray, 'fa-male,&##xf183;' ); 
	ArrayAppend( fontArray, 'fa-map-marker,&##xf041;' ); 
	ArrayAppend( fontArray, 'fa-maxcdn,&##xf136;' ); 
	ArrayAppend( fontArray, 'fa-medkit,&##xf0fa;' ); 
	ArrayAppend( fontArray, 'fa-meh-o,&##xf11a;' ); 
	ArrayAppend( fontArray, 'fa-microphone,&##xf130;' ); 
	ArrayAppend( fontArray, 'fa-microphone-slash,&##xf131;' ); 
	ArrayAppend( fontArray, 'fa-minus,&##xf068;' ); 
	ArrayAppend( fontArray, 'fa-minus-circle,&##xf056;' ); 
	ArrayAppend( fontArray, 'fa-minus-square,&##xf146;' ); 
	ArrayAppend( fontArray, 'fa-minus-square-o,&##xf147;' ); 
	ArrayAppend( fontArray, 'fa-mobile,&##xf10b;' ); 
	ArrayAppend( fontArray, 'fa-mobile-phone,&##xf10b;' ); 
	ArrayAppend( fontArray, 'fa-money,&##xf0d6;' ); 
	ArrayAppend( fontArray, 'fa-moon-o,&##xf186;' ); 
	ArrayAppend( fontArray, 'fa-mortar-board,&##xf19d;' ); 
	ArrayAppend( fontArray, 'fa-music,&##xf001;' ); 
	ArrayAppend( fontArray, 'fa-navicon,&##xf0c9;' ); 
	ArrayAppend( fontArray, 'fa-openid,&##xf19b;' ); 
	ArrayAppend( fontArray, 'fa-outdent,&##xf03b;' ); 
	ArrayAppend( fontArray, 'fa-pagelines,&##xf18c;' ); 
	ArrayAppend( fontArray, 'fa-paper-plane,&##xf1d8;' ); 
	ArrayAppend( fontArray, 'fa-paper-plane-o,&##xf1d9;' ); 
	ArrayAppend( fontArray, 'fa-paperclip,&##xf0c6;' ); 
	ArrayAppend( fontArray, 'fa-paragraph,&##xf1dd;' ); 
	ArrayAppend( fontArray, 'fa-paste,&##xf0ea;' ); 
	ArrayAppend( fontArray, 'fa-pause,&##xf04c;' ); 
	ArrayAppend( fontArray, 'fa-paw,&##xf1b0;' ); 
	ArrayAppend( fontArray, 'fa-pencil,&##xf040;' ); 
	ArrayAppend( fontArray, 'fa-pencil-square,&##xf14b;' ); 
	ArrayAppend( fontArray, 'fa-pencil-square-o,&##xf044;' ); 
	ArrayAppend( fontArray, 'fa-phone,&##xf095;' ); 
	ArrayAppend( fontArray, 'fa-phone-square,&##xf098;' ); 
	ArrayAppend( fontArray, 'fa-photo,&##xf03e;' ); 
	ArrayAppend( fontArray, 'fa-picture-o,&##xf03e;' ); 
	ArrayAppend( fontArray, 'fa-pied-piper,&##xf1a7;' ); 
	ArrayAppend( fontArray, 'fa-pied-piper-alt,&##xf1a8;' ); 
	ArrayAppend( fontArray, 'fa-pied-piper-square,&##xf1a7;' ); 
	ArrayAppend( fontArray, 'fa-pinterest,&##xf0d2;' ); 
	ArrayAppend( fontArray, 'fa-pinterest-square,&##xf0d3;' ); 
	ArrayAppend( fontArray, 'fa-plane,&##xf072;' ); 
	ArrayAppend( fontArray, 'fa-play,&##xf04b;' ); 
	ArrayAppend( fontArray, 'fa-play-circle,&##xf144;' ); 
	ArrayAppend( fontArray, 'fa-play-circle-o,&##xf01d;' ); 
	ArrayAppend( fontArray, 'fa-plus,&##xf067;' ); 
	ArrayAppend( fontArray, 'fa-plus-circle,&##xf055;' ); 
	ArrayAppend( fontArray, 'fa-plus-square,&##xf0fe;' ); 
	ArrayAppend( fontArray, 'fa-plus-square-o,&##xf196;' ); 
	ArrayAppend( fontArray, 'fa-power-off,&##xf011;' ); 
	ArrayAppend( fontArray, 'fa-print,&##xf02f;' ); 
	ArrayAppend( fontArray, 'fa-puzzle-piece,&##xf12e;' ); 
	ArrayAppend( fontArray, 'fa-qq,&##xf1d6;' ); 
	ArrayAppend( fontArray, 'fa-qrcode,&##xf029;' ); 
	ArrayAppend( fontArray, 'fa-question,&##xf128;' ); 
	ArrayAppend( fontArray, 'fa-question-circle,&##xf059;' ); 
	ArrayAppend( fontArray, 'fa-quote-left,&##xf10d;' ); 
	ArrayAppend( fontArray, 'fa-quote-right,&##xf10e;' ); 
	ArrayAppend( fontArray, 'fa-ra,&##xf1d0;' ); 
	ArrayAppend( fontArray, 'fa-random,&##xf074;' ); 
	ArrayAppend( fontArray, 'fa-rebel,&##xf1d0;' ); 
	ArrayAppend( fontArray, 'fa-recycle,&##xf1b8;' ); 
	ArrayAppend( fontArray, 'fa-reddit,&##xf1a1;' ); 
	ArrayAppend( fontArray, 'fa-reddit-square,&##xf1a2;' ); 
	ArrayAppend( fontArray, 'fa-refresh,&##xf021;' ); 
	ArrayAppend( fontArray, 'fa-renren,&##xf18b;' ); 
	ArrayAppend( fontArray, 'fa-reorder,&##xf0c9;' ); 
	ArrayAppend( fontArray, 'fa-repeat,&##xf01e;' ); 
	ArrayAppend( fontArray, 'fa-reply,&##xf112;' ); 
	ArrayAppend( fontArray, 'fa-reply-all,&##xf122;' ); 
	ArrayAppend( fontArray, 'fa-retweet,&##xf079;' ); 
	ArrayAppend( fontArray, 'fa-rmb,&##xf157;' ); 
	ArrayAppend( fontArray, 'fa-road,&##xf018;' ); 
	ArrayAppend( fontArray, 'fa-rocket,&##xf135;' ); 
	ArrayAppend( fontArray, 'fa-rotate-left,&##xf0e2;' ); 
	ArrayAppend( fontArray, 'fa-rotate-right,&##xf01e;' ); 
	ArrayAppend( fontArray, 'fa-rouble,&##xf158;' ); 
	ArrayAppend( fontArray, 'fa-rss,&##xf09e;' ); 
	ArrayAppend( fontArray, 'fa-rss-square,&##xf143;' ); 
	ArrayAppend( fontArray, 'fa-rub,&##xf158;' ); 
	ArrayAppend( fontArray, 'fa-ruble,&##xf158;' ); 
	ArrayAppend( fontArray, 'fa-rupee,&##xf156;' ); 
	ArrayAppend( fontArray, 'fa-save,&##xf0c7;' ); 
	ArrayAppend( fontArray, 'fa-scissors,&##xf0c4;' ); 
	ArrayAppend( fontArray, 'fa-search,&##xf002;' ); 
	ArrayAppend( fontArray, 'fa-search-minus,&##xf010;' ); 
	ArrayAppend( fontArray, 'fa-search-plus,&##xf00e;' ); 
	ArrayAppend( fontArray, 'fa-send,&##xf1d8;' ); 
	ArrayAppend( fontArray, 'fa-send-o,&##xf1d9;' ); 
	ArrayAppend( fontArray, 'fa-share,&##xf064;' ); 
	ArrayAppend( fontArray, 'fa-share-alt,&##xf1e0;' ); 
	ArrayAppend( fontArray, 'fa-share-alt-square,&##xf1e1;' ); 
	ArrayAppend( fontArray, 'fa-share-square,&##xf14d;' ); 
	ArrayAppend( fontArray, 'fa-share-square-o,&##xf045;' ); 
	ArrayAppend( fontArray, 'fa-shield,&##xf132;' ); 
	ArrayAppend( fontArray, 'fa-shopping-cart,&##xf07a;' ); 
	ArrayAppend( fontArray, 'fa-sign-in,&##xf090;' ); 
	ArrayAppend( fontArray, 'fa-sign-out,&##xf08b;' ); 
	ArrayAppend( fontArray, 'fa-signal,&##xf012;' ); 
	ArrayAppend( fontArray, 'fa-sitemap,&##xf0e8;' ); 
	ArrayAppend( fontArray, 'fa-skype,&##xf17e;' ); 
	ArrayAppend( fontArray, 'fa-slack,&##xf198;' ); 
	ArrayAppend( fontArray, 'fa-sliders,&##xf1de;' ); 
	ArrayAppend( fontArray, 'fa-smile-o,&##xf118;' ); 
	ArrayAppend( fontArray, 'fa-sort,&##xf0dc;' ); 
	ArrayAppend( fontArray, 'fa-sort-alpha-asc,&##xf15d;' ); 
	ArrayAppend( fontArray, 'fa-sort-alpha-desc,&##xf15e;' ); 
	ArrayAppend( fontArray, 'fa-sort-amount-asc,&##xf160;' ); 
	ArrayAppend( fontArray, 'fa-sort-amount-desc,&##xf161;' ); 
	ArrayAppend( fontArray, 'fa-sort-asc,&##xf0de;' ); 
	ArrayAppend( fontArray, 'fa-sort-desc,&##xf0dd;' ); 
	ArrayAppend( fontArray, 'fa-sort-down,&##xf0dd;' ); 
	ArrayAppend( fontArray, 'fa-sort-numeric-asc,&##xf162;' ); 
	ArrayAppend( fontArray, 'fa-sort-numeric-desc,&##xf163;' ); 
	ArrayAppend( fontArray, 'fa-sort-up,&##xf0de;' ); 
	ArrayAppend( fontArray, 'fa-soundcloud,&##xf1be;' ); 
	ArrayAppend( fontArray, 'fa-space-shuttle,&##xf197;' ); 
	ArrayAppend( fontArray, 'fa-spinner,&##xf110;' ); 
	ArrayAppend( fontArray, 'fa-spoon,&##xf1b1;' ); 
	ArrayAppend( fontArray, 'fa-spotify,&##xf1bc;' ); 
	ArrayAppend( fontArray, 'fa-square,&##xf0c8;' ); 
	ArrayAppend( fontArray, 'fa-square-o,&##xf096;' ); 
	ArrayAppend( fontArray, 'fa-stack-exchange,&##xf18d;' ); 
	ArrayAppend( fontArray, 'fa-stack-overflow,&##xf16c;' ); 
	ArrayAppend( fontArray, 'fa-star,&##xf005;' ); 
	ArrayAppend( fontArray, 'fa-star-half,&##xf089;' ); 
	ArrayAppend( fontArray, 'fa-star-half-empty,&##xf123;' ); 
	ArrayAppend( fontArray, 'fa-star-half-full,&##xf123;' ); 
	ArrayAppend( fontArray, 'fa-star-half-o,&##xf123;' ); 
	ArrayAppend( fontArray, 'fa-star-o,&##xf006;' ); 
	ArrayAppend( fontArray, 'fa-steam,&##xf1b6;' ); 
	ArrayAppend( fontArray, 'fa-steam-square,&##xf1b7;' ); 
	ArrayAppend( fontArray, 'fa-step-backward,&##xf048;' ); 
	ArrayAppend( fontArray, 'fa-step-forward,&##xf051;' ); 
	ArrayAppend( fontArray, 'fa-stethoscope,&##xf0f1;' ); 
	ArrayAppend( fontArray, 'fa-stop,&##xf04d;' ); 
	ArrayAppend( fontArray, 'fa-strikethrough,&##xf0cc;' ); 
	ArrayAppend( fontArray, 'fa-stumbleupon,&##xf1a4;' ); 
	ArrayAppend( fontArray, 'fa-stumbleupon-circle,&##xf1a3;' ); 
	ArrayAppend( fontArray, 'fa-subscript,&##xf12c;' ); 
	ArrayAppend( fontArray, 'fa-suitcase,&##xf0f2;' ); 
	ArrayAppend( fontArray, 'fa-sun-o,&##xf185;' ); 
	ArrayAppend( fontArray, 'fa-superscript,&##xf12b;' ); 
	ArrayAppend( fontArray, 'fa-support,&##xf1cd;' ); 
	ArrayAppend( fontArray, 'fa-table,&##xf0ce;' ); 
	ArrayAppend( fontArray, 'fa-tablet,&##xf10a;' ); 
	ArrayAppend( fontArray, 'fa-tachometer,&##xf0e4;' ); 
	ArrayAppend( fontArray, 'fa-tag,&##xf02b;' ); 
	ArrayAppend( fontArray, 'fa-tags,&##xf02c;' ); 
	ArrayAppend( fontArray, 'fa-tasks,&##xf0ae;' ); 
	ArrayAppend( fontArray, 'fa-taxi,&##xf1ba;' ); 
	ArrayAppend( fontArray, 'fa-tencent-weibo,&##xf1d5;' ); 
	ArrayAppend( fontArray, 'fa-terminal,&##xf120;' ); 
	ArrayAppend( fontArray, 'fa-text-height,&##xf034;' ); 
	ArrayAppend( fontArray, 'fa-text-width,&##xf035;' ); 
	ArrayAppend( fontArray, 'fa-th,&##xf00a;' ); 
	ArrayAppend( fontArray, 'fa-th-large,&##xf009;' ); 
	ArrayAppend( fontArray, 'fa-th-list,&##xf00b;' ); 
	ArrayAppend( fontArray, 'fa-thumb-tack,&##xf08d;' ); 
	ArrayAppend( fontArray, 'fa-thumbs-down,&##xf165;' ); 
	ArrayAppend( fontArray, 'fa-thumbs-o-down,&##xf088;' ); 
	ArrayAppend( fontArray, 'fa-thumbs-o-up,&##xf087;' ); 
	ArrayAppend( fontArray, 'fa-thumbs-up,&##xf164;' ); 
	ArrayAppend( fontArray, 'fa-ticket,&##xf145;' ); 
	ArrayAppend( fontArray, 'fa-times,&##xf00d;' ); 
	ArrayAppend( fontArray, 'fa-times-circle,&##xf057;' ); 
	ArrayAppend( fontArray, 'fa-times-circle-o,&##xf05c;' ); 
	ArrayAppend( fontArray, 'fa-tint,&##xf043;' ); 
	ArrayAppend( fontArray, 'fa-toggle-down,&##xf150;' ); 
	ArrayAppend( fontArray, 'fa-toggle-left,&##xf191;' ); 
	ArrayAppend( fontArray, 'fa-toggle-right,&##xf152;' ); 
	ArrayAppend( fontArray, 'fa-toggle-up,&##xf151;' ); 
	ArrayAppend( fontArray, 'fa-trash-o,&##xf014;' ); 
	ArrayAppend( fontArray, 'fa-tree,&##xf1bb;' ); 
	ArrayAppend( fontArray, 'fa-trello,&##xf181;' ); 
	ArrayAppend( fontArray, 'fa-trophy,&##xf091;' ); 
	ArrayAppend( fontArray, 'fa-truck,&##xf0d1;' ); 
	ArrayAppend( fontArray, 'fa-try,&##xf195;' ); 
	ArrayAppend( fontArray, 'fa-tumblr,&##xf173;' ); 
	ArrayAppend( fontArray, 'fa-tumblr-square,&##xf174;' ); 
	ArrayAppend( fontArray, 'fa-turkish-lira,&##xf195;' ); 
	ArrayAppend( fontArray, 'fa-twitter,&##xf099;' ); 
	ArrayAppend( fontArray, 'fa-twitter-square,&##xf081;' ); 
	ArrayAppend( fontArray, 'fa-umbrella,&##xf0e9;' ); 
	ArrayAppend( fontArray, 'fa-underline,&##xf0cd;' ); 
	ArrayAppend( fontArray, 'fa-undo,&##xf0e2;' ); 
	ArrayAppend( fontArray, 'fa-university,&##xf19c;' ); 
	ArrayAppend( fontArray, 'fa-unlink,&##xf127;' ); 
	ArrayAppend( fontArray, 'fa-unlock,&##xf09c;' ); 
	ArrayAppend( fontArray, 'fa-unlock-alt,&##xf13e;' ); 
	ArrayAppend( fontArray, 'fa-unsorted,&##xf0dc;' ); 
	ArrayAppend( fontArray, 'fa-upload,&##xf093;' ); 
	ArrayAppend( fontArray, 'fa-usd,&##xf155;' ); 
	ArrayAppend( fontArray, 'fa-user,&##xf007;' ); 
	ArrayAppend( fontArray, 'fa-user-md,&##xf0f0;' ); 
	ArrayAppend( fontArray, 'fa-users,&##xf0c0;' ); 
	ArrayAppend( fontArray, 'fa-video-camera,&##xf03d;' ); 
	ArrayAppend( fontArray, 'fa-vimeo-square,&##xf194;' ); 
	ArrayAppend( fontArray, 'fa-vine,&##xf1ca;' ); 
	ArrayAppend( fontArray, 'fa-vk,&##xf189;' ); 
	ArrayAppend( fontArray, 'fa-volume-down,&##xf027;' ); 
	ArrayAppend( fontArray, 'fa-volume-off,&##xf026;' ); 
	ArrayAppend( fontArray, 'fa-volume-up,&##xf028;' ); 
	ArrayAppend( fontArray, 'fa-warning,&##xf071;' ); 
	ArrayAppend( fontArray, 'fa-wechat,&##xf1d7;' ); 
	ArrayAppend( fontArray, 'fa-weibo,&##xf18a;' ); 
	ArrayAppend( fontArray, 'fa-weixin,&##xf1d7;' ); 
	ArrayAppend( fontArray, 'fa-wheelchair,&##xf193;' ); 
	ArrayAppend( fontArray, 'fa-windows,&##xf17a;' ); 
	ArrayAppend( fontArray, 'fa-won,&##xf159;' ); 
	ArrayAppend( fontArray, 'fa-wordpress,&##xf19a;' ); 
	ArrayAppend( fontArray, 'fa-wrench,&##xf0ad;' ); 
	ArrayAppend( fontArray, 'fa-xing,&##xf168;' ); 
	ArrayAppend( fontArray, 'fa-xing-square,&##xf169;' ); 
	ArrayAppend( fontArray, 'fa-yahoo,&##xf19e;' ); 
	ArrayAppend( fontArray, 'fa-yen,&##xf157;' ); 
	ArrayAppend( fontArray, 'fa-youtube,&##xf167;' ); 
	ArrayAppend( fontArray, 'fa-youtube-play,&##xf16a;' ); 
	ArrayAppend( fontArray, 'fa-youtube-square,&##xf166;' );

	for( i=1; i lte ArrayLen(fontArray); i=i+1 )
	{
		if( ListFirst(fontArray[i]) eq currentvalue )
			curval = "#ListLast(fontArray[i])# #ListFirst(fontArray[i])#";
	}

	application.ADF.scripts.loadJQuery();
	// Use jQuery to Add Font Awesome CSS to head dynamically
	application.ADF.scripts.loadFontAwesome(dynamicHeadRender=true);
</cfscript>

<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
		#fqFieldName#.msg="Please select a value for the #xparams.label# field.";
		#fqFieldName#.validator = "validate_#fqFieldName#()";
		
		//If the field is required
		if ( '#xparams.req#' == 'Yes' )
		{
			// push on to validation array
			vobjects_#attributes.formname#.push(#fqFieldName#);
		}

		//Validation function
		function validate_#fqFieldName#(){
			if (jQuery("input[name=#fqFieldName#]").val() != ''){
				return true;
			}else{
				return false;
			}
		}
	</script>
</cfoutput>

	<cfsavecontent variable="inputHTML">
		<cfoutput>
			<style>
				.cols-3-outer { overflow-x: scroll; width:650px; height:200px; border: 1px solid ##999; background-color: ##fcfcfc; }
				.cols-3
				{
				   /* width:580px; */
					height: 180px;
					-webkit-column-count: 3;
					-moz-column-count: 3;
					column-count: 3;
					-webkit-column-gap: 1px;
					-moz-column-gap: 1px;
					column-gap: 1px; 
				}			
				.cols-3 ul li { line-height: 2; font-size: 12px; list-style: none; padding-left: 5px; padding-right: 5px; cursor: pointer; }
				li div:hover { background-color: ##D9E3ED; border: 1px solid ##999; }
				li div.selected { background-color: ##D9E3ED; border: 1px solid ##999; }
				i.fa-border { border-color: ##555 !important; }
			</style>
			
			<script>
				jQuery(function(){
			
					// Add Key up event
					jQuery('##fa_search_#xparams.fldID#').live( 'keyup', function() {
						var theval = jQuery('##fa_search_#xparams.fldID#').val();
						findFunction( theval );
					});

					// add Click event for each font li div
					jQuery(".fonticon").live( 'click', function(){
						var name = jQuery(this).attr('data-name');					
						var code = jQuery(this).attr('data-code');					

						// set display selection to that value (icon name)
						jQuery("##sel_#xparams.fldID#").text( name );
					
						// de-select old one
						if( jQuery("li div.selected") )
							jQuery("li div.selected").removeClass('selected');
					
						// select new one
						jQuery(this).addClass('selected');
					
						// assign just name portion to real hidden field
						BuildClasses();
					});		
				
					// add Click event for options div
					jQuery("##options_#xparams.fldID#").live( 'click', function(){
						BuildClasses();
					});
		
					function findFunction(inString)
					{
						// Check if we have a string defined
						if ( inString.length > 0 )
						{
							// Hide everything to start
							jQuery('li div.fonticon').hide();
						
							// Find the rows that contain the search terms
							jQuery('li div[data-name*="' + inString.toLowerCase() + '"]').each(function() {
									// Display the row
									jQuery(this).show();
								});

							// Find the selected rows 
							jQuery('li div.selected').show();
						}
						else 
						{
							// Show Everything
							jQuery('li div.fonticon').show();
						}
					}
				
					function clearInput()
					{
						jQuery('##fa_search_#xparams.fldID#').val('');		
						jQuery('##sel_#xparams.fldID#').text('(Blank)');		
						jQuery('##icon_#xparams.fldID#').attr( 'class', '');		
						jQuery('###xparams.fldID#').val('');		
					
						// de-select old one
						if( jQuery("li div.selected") )
							jQuery("li div.selected").removeClass('selected');
					
						findFunction('');
					}
				
					function BuildClasses()
					{
						var name = '';
						var val = '';
						var size = '';
						var fw = '';
						var border = '';
						var spin = '';
						var pull = '';

						// get selected item
						if( jQuery("li div.selected").length )
							name = jQuery("li div.selected").attr('data-name');
					
						if( document.getElementById('size_#xparams.fldID#') instanceof Object )
							size = jQuery('##size_#xparams.fldID#').val();
					
						if( document.getElementById('fw_#xparams.fldID#') instanceof Object )
						{	
							if( jQuery('##fw_#xparams.fldID#').prop('checked') )
								fw = jQuery('##fw_#xparams.fldID#').val();
						}		
						
						if( document.getElementById('border_#xparams.fldID#') instanceof Object )
						{	
							if( jQuery('##border_#xparams.fldID#').prop('checked') )	
								border = jQuery('##border_#xparams.fldID#').val();
						}
									
						if( document.getElementById('spin_#xparams.fldID#') instanceof Object )
						{	
							if( jQuery('##spin_#xparams.fldID#').prop('checked') )							
								spin = jQuery('##spin_#xparams.fldID#').val();
						}
									
						if( document.getElementById('pull_#xparams.fldID#') instanceof Object )
						{	
							if( jQuery('##pull_#xparams.fldID#') )	
								pull = jQuery('##pull_#xparams.fldID#').val();
						}
								
						// console.log( name + ' ' + size + ' ' + fw + ' ' + border + ' ' + spin + ' ' + pull  );

						val = '';
						if( name.length > 0 )
						{
							val = name;
							if( size.length > 0 )
								val = val + ' ' + size;
							if( fw.length > 0 )
								val = val + ' ' + fw;
							if( border.length > 0 )
								val = val + ' ' + border;
							if( spin.length > 0 )
								val = val + ' ' + spin;
							if( pull.length > 0 )
								val = val + ' ' + pull;

							// set display div
							jQuery('##sel_#xparams.fldID#').text( name );		
							jQuery('##icon_#xparams.fldID#').attr( 'class', 'fa ' + val );		
						}
					
						// set hidden value
						jQuery('###xparams.fldID#').val( val );	
					}
 
				});
			</script>
 
			<div style="display: inline-block; font-size: 12px;  padding: 5px 10px 0px 0px;">
				<i id="icon_#xparams.fldID#" class="fa #currentvalue#"></i> 
				<span id="sel_#xparams.fldID#">#ListFirst(currentValue, ' ')#</span>
			</div>
			<input type="text" name="fa_search_#xparams.fldID#" id="fa_search_#xparams.fldID#" value="" <cfif readOnly>disabled="disabled"</cfif> style="width: 180px; margin-bottom: 5px; padding-left: 5px;" placeholder="Type to filter list of icons"> 
			<input class="clsPushButton" type="button" value="Clear" style="padding: 1px 5px; vertical-align: baseline;" onclick="clearInput()">
			<input type="hidden" name="#fqFieldName#" id="#xparams.fldID#" value="#currentValue#"> 			
			<div class="cols-3-outer">
			<div class="cols-3">
				<ul>
					<cfset selected_index = ''>
					<cfloop index="i" from="1" to="#ArrayLen(fontArray)#" step="1">
						<cfif ListFirst(currentValue, ' ') EQ ListFirst(fontArray[i])>
							<cfset selected = "selected">
							<cfset selected_index = '#ListLast(fontArray[i])# #ListFirst(fontArray[i])#'>
						<cfelse>	
							<cfset selected = "">
						</cfif>
						<li>
							<div class="fonticon #selected#" data-code="#ListLast(fontArray[i])#" data-name="#ListFirst(fontArray[i])#"><i class="fa #ListFirst(fontArray[i])#"></i> #ListFirst(fontArray[i])#</div>
						</li>
					</cfloop>
				</ul>
			</div>
			</div>
			<div id="options_#xparams.fldID#" style="margin-top: 3px; vertical-align:baseline;">
				<cfif xparams.ShowSize>
				Size: <select name="size_#xparams.fldID#" id="size_#xparams.fldID#">
						<option value="">Normal</option>
						<option value="fa-lg" <cfif FindNoCase('fa-lg',currentvalue)>selected="selected"</cfif>>Large</option>
						<cfloop index="s" from="2" to="10">
							<option value="fa-#s#x" <cfif FindNoCase('fa-#s#x',currentvalue)>selected="selected"</cfif>>#s#x</option>
						</cfloop> 
					</select> &nbsp; 
				</cfif>
				
				<cfif xparams.ShowFixedWidth>
				<input type="checkbox" id="fw_#xparams.fldID#" name="fw_#xparams.fldID#" value="fa-fw" <cfif FindNoCase('fa-fw',currentvalue)>checked="checked"</cfif>><label for="fw_#xparams.fldID#">Fixed Width</label> &nbsp; 
				</cfif>	
				
				<cfif xparams.ShowBorder>
				<input type="checkbox" id="border_#xparams.fldID#" name="border_#xparams.fldID#" value="fa-border" <cfif FindNoCase('fa-border',currentvalue)>checked="checked"</cfif>><label for="border_#xparams.fldID#">Border</label> &nbsp; 
				</cfif>
				
				<cfif xparams.ShowSpin>
				<input type="checkbox" id="spin_#xparams.fldID#" name="spin_#xparams.fldID#" value="fa-spin" <cfif FindNoCase('fa-spin',currentvalue)>checked="checked"</cfif>><label for="spin_#xparams.fldID#">Spin</label> &nbsp; 
				</cfif>
				
				<cfif xparams.ShowPull>
				Pull: <select id="pull_#xparams.fldID#" name="pull_#xparams.fldID#">
					<option value="">None</option>
					<option value="pull-left" <cfif FindNoCase('pull-left',currentvalue)>selected="selected"</cfif>>Left</option>
					<option value="pull-right" <cfif FindNoCase('pull-right',currentvalue)>selected="selected"</cfif>>Right</option>
					</select> 
				</cfif>	
			</div> 
		</cfoutput>
		
		
	</cfsavecontent>
	
	<!---
		This CFT is using the forms lib wrapFieldHTML functionality. The wrapFieldHTML takes
		the Form Field HTML that you want to put into the TD of the right section of the CFT 
		table row and helps with display formatting, adds the hidden simple form fields (if needed) 
		and handles field permissions (other than read-only).
		Optionally you can disable the field label and the field discription by setting 
		the includeLabel and/or the includeDescription variables (found above) to false.  
	--->
<cfoutput>
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission,includeLabel,includeDescription)#
</cfoutput>


