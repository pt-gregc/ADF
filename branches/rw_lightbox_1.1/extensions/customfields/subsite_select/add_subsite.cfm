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

<cfoutput><html>
	<head>
		<title>Add Subsite</title>
	</head>
	<body>
		<cfscript>
			application.ptBlog2.scripts.loadJQuery();
			application.ptBlog2.scripts.loadJQueryTools();
			application.ptBlog2.scripts.loadADFLightbox();
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
					$("###fqFieldName#_create").click(function() {
						#fqFieldName#addSubsite();
					});
					
					$("input[name='submitbutton']").hover(
						function(){ 
							$(this).addClass("ui-state-hover"); 
						},
						function(){ 
							$(this).removeClass("ui-state-hover"); 
						}
					)
					$("input[name='submitbutton']").mousedown(function(){
						$(this).addClass("ui-state-active"); 
					})
					$("input[name='submitbutton']").mouseup(function(){
							$(this).removeClass("ui-state-active");
					});	
				});
			</script>
		</div>
	</body>
</html></cfoutput>