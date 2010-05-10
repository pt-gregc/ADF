<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2010.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
Name:
	datasheet_jquery_ui_style.cfm
Summary:
	Renders the JQuery UI headers for a datasheet.
History:
	2009-07-20 - MFC - Created
--->
<cfscript>
	application.ADF.scripts.loadJQuery("1.3.1");
	application.ADF.scripts.loadJQueryUI("1.7.1", "ui-lightness");
	application.ADF.scripts.loadThickbox("3.1");
</cfscript>
<cfoutput>
<script type="text/javascript">
	$(function() {
		// Hover states on the static widgets
		$("div.ds-icons").hover(
			function() { $(this).addClass('ui-state-hover'); },
			function() { $(this).removeClass('ui-state-hover'); }
		);
	});
</script>

<!--- CODE FOR ADD NEW --->
<!--- <div id="addNew" style="padding:20px;">
	<cfif request.user.id gt 0>
		<cftry>
			<cfif (StructKeyExists(server.ADF.environment[request.site.id]['article_editor'], "add_article_menu_link")) AND (LEN(server.ADF.environment[request.site.id]['article_editor']['add_article_menu_link']))>
				<a href="#server.ADF.environment[request.site.id]['article_editor']['add_article_menu_link']#?&formID=1564&dataPageId=0&lbAction=norefresh&keepThis=true&TB_iframe=true&height=550&width=700" id="addNewArticle" title="Add Article" class="thickbox">Add New Article</a><br />
			<cfelse>
				<cfthrow type="Application" detail="Error with the PT_Profile config file ADDURL tag." message="Error with the PT_Profile config file ADDURL tag.">
			</cfif>
			<cfcatch>
				Error Detail: #cfcatch.message#<br />
			</cfcatch>
		</cftry>
	<cfelse>
		Please <a href="#request.subsitecache[1].url#login.cfm">LOGIN</a> to manage your profile.<br />
		<!--- <cfexit> --->
	</cfif>
</div>
 --->

<!--- CODE FOR SEARCHING THROUGH DATASHEET --->
<!--- Check if we have some search text --->
<!--- <cfif NOT StructKeyExists(request.params, "searchText")>
	<cfset request.params.searchText = "">
</cfif> --->
 <!--- Jquery for the search form --->
<!--- <script>
	jQuery(document).ready(function(){
		// Hide the Datasheet filter drop-down
		//jQuery('select##cs_ds_view').hide();
		jQuery('form##ds_1663_1658').hide();
		
		// Hover for the buttons
		jQuery('a.search_link').hover(
			function () {
				$(this).addClass('ui-state-hover');
			}, 
			function () {
				$(this).removeClass('ui-state-hover');
			}
		);
		jQuery('a.all_link').hover(
			function () {
				$(this).addClass('ui-state-hover');
			}, 
			function () {
				$(this).removeClass('ui-state-hover');
			}
		);
		
		// Handle the search
		jQuery('a.search_link').click(function () {
			// All Articles = 'itemid_1663=2'
			// Search Keywords = 'itemid_1663=3'
			
			// Get the search text
			var searchText = jQuery('input##searchText').val();
			var newURL = '#cgi.script_name#';
			//alert(searchText);
			// Check if we have a search value
			if ( searchText != '' )
				newURL += "?itemid_1663=3";
			else 
				newURL += "?itemid_1663=2";
			
			//alert(newURL);
			// add the search text
			newURL += "&searchText=" + searchText;
			// redirect the page
			location.href = newURL;
		});
		
		// Handle the View All link
		jQuery('a.all_link').click(function () {
			// All Articles = 'itemid_1663=2'
			// Get the search text
			var newURL = '#cgi.script_name#';
			// Set for the View All DS
			newURL += "?itemid_1663=2";
			//alert(newURL);
			// redirect the page
			location.href = newURL;
		});
	});
</script>
<style>
	a.search_link, a.all_link {
		padding: 1px 10px;
		text-decoration: none;
	}
</style> --->
<!--- Search Form --->
<!--- <div id="searchForm">
	<input type="text" class="searchFld" id="searchText" name="searchText" tabindex="1" value="#request.params.searchText#" size="30" />
	<a class="search_link ui-state-default ui-corner-all" href="##">Search</a>
	<a class="all_link ui-state-default ui-corner-all" href="##">View All Articles</a>
</div> --->

<!--- Datasheet Action Column Links
EDIT:
<div class='ds-icons ui-state-default ui-corner-all' title='edit' ><div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-pencil'></div></div>
DELETE:
<div class='ds-icons ui-state-default ui-corner-all' title='delete' ><div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-trash'></div></div>
 --->
</cfoutput>
<!--- Render for the datasheet module --->
<CFMODULE TEMPLATE="/commonspot/utilities/ct-render-named-element.cfm"
	elementtype="datasheet"
	elementName="customDatasheetJQueryUIStyles">
