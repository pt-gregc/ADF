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
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
Custom Field Type:
	Subsite Select
Name:
	add_subsite.cfm
Summary:
	Helper file for the Subsite Select custom field type, when the option is enabled this is the UI that
	is used to make the call to create a new subsite 
ADF Requirements:
	script_1_0
History:
	2007-01-24 - RLW - Created
	2011-02-08 - GAC - Modified - Removed references to ptBlog2
	2013-02-20 - MFC - Replaced Jquery "$" references.
--->
<cfoutput><html>
	<head>
		<title>Add Subsite</title>
	</head>
	<body>
		<cfscript>
			application.ADF.scripts.loadJQuery();
			application.ADF.scripts.loadJQueryTools();
			application.ADF.scripts.loadADFLightbox();
		</cfscript>
		<div id="#fqFieldName#_add" title="Create New Subsite">
			<fieldSet>
				<label for="#fqFieldName#_name">Name</label><input type="text" size="45" id="#fqFieldName#_name">
				<label for="#fqFieldName#_display">Display</label><input type="text" size="45" id="#fqFieldName#_display">
				<label for="#fqFieldName#_desc">Description</label><br /><textarea id="#fqFieldName#_desc"></textarea>
				<br/><button class="ui-button ui-state-default ui-corner-all" id="#fqFieldName#_create">Create</button>
			</fieldSet>
			<script type="text/javascript">
				jQuery(function(){
					alert(window.parent.#fqFieldName#addSubsite());
					// add click for the actual create subsite form processing
					jQuery("###fqFieldName#_create").click(function() {
						#fqFieldName#addSubsite();
					});
					
					jQuery("input[name='submitbutton']").hover(
						function(){ 
							jQuery(this).addClass("ui-state-hover"); 
						},
						function(){ 
							jQuery(this).removeClass("ui-state-hover"); 
						}
					)
					jQuery("input[name='submitbutton']").mousedown(function(){
						jQuery(this).addClass("ui-state-active"); 
					})
					jQuery("input[name='submitbutton']").mouseup(function(){
							jQuery(this).removeClass("ui-state-active");
					});	
				});
			</script>
		</div>
	</body>
</html></cfoutput>