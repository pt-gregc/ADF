<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the Starter App directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2016.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$widget_css_editor_render.cfc
Summary:
	Widget CSS Resource Editor
History:
 	2016-06-01 - GAC - Created
--->

<cfcomponent displayName="sample_render" extends="commonspot.public.form-field-renderer-base" output="no">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">

	<cfscript>
		var inputParameters = duplicate(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		var resourceAPI = Server.CommonSpot.ObjectFactory.getObject("Resource");
		var resourceList = "";
		var resourceData = StructNew();
		var cssURL = "";
		var editorValue = "";
		var cssFile = "";
		var cssDirPath = "";
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);
		
//WriteDump(inputParameters);

//WriteOutput("currentValue: ");
//WriteDump(var=currentValue,label="currentValue",expand=false);

		//inputParameters.resourceName
//WriteDump(var=inputParameters.resourceName,label="resourceName",expand=false);

		resourceList = resourceAPI.getList(searchString=inputParameters.resourceName, searchOperator='equals');
//WriteDump(var=resourceList,label="resourceList",expand=false);
		
		if ( resourceList.RecordCount == 1 && arrayLen(resourceList.earlyLoadSourceArray[1]) == 1 )
		{
			resourceData = resourceList.earlyLoadSourceArray[1][1];
			cssURL = resourceData.sourceURL;
			cssDirPath = Request.Site.Dir & cssURL;
			if ( fileExists(cssDirPath) )
				editorValue = FileRead(cssDirPath, "utf-8");
		
		
			//editorValue = FileRead(ExpandPath("/style/widget-icon-text-blocks.css"), "utf-8");
//WriteDump(var=editorValue,label="editorValue",expand=false);
			//cssFile = FileOpen(ExpandPath("/style/widget-icon-text-blocks.css"), "read", "utf-8");
//WriteDump(var=cssFile,label="cssFile",expand=false);
		}

		// if no current value entered
		/* 
			if ( NOT LEN(currentValue) )
			{
				// reset the currentValue to the currentDefault
				try
				{
					// if there is a user defined function for the default value
					if( inputParameters.useUDef )
						currentValue = evaluate(inputParameters.currentDefault);
					else // standard text value
						currentValue = inputParameters.currentDefault; 
				
					//currentValue = inputParameters.currentDefault;
				}
				catch( any e)
				{
					; // let the current default value stand
				}
			}
		*/
	</cfscript>
	
	<cfscript>
		// Set the cfmlEngine type
		cfmlEngine = server.coldfusion.productname;
		if ( !FindNoCase(cfmlEngine,'ColdFusion Server') )
		{
			// Replace linebreaks
			editorValue = REReplace(editorValue, "(\r\n|\n\r|\n|\r)", "&##013;&##010;", "all");
			// Inject Extra linebreaks before each open bracket (since the textarea removes them)
			//WRONG - editorValue = REReplace(editorValue, "}(\r\n|\n\r|\n|\r)", "}&##013;&##010;&##013;&##010;", "all");
		}

		// Replace tab characters 
		editorValue = REReplace(editorValue, "[\t]", "&##09;", "all");
	</cfscript>
		
	<cfoutput>

		<script language="JavaScript" type="text/javascript">
			jQuery( function(){
				var #arguments.fieldName#_original_data = jQuery('###arguments.fieldName#cssEditor').val(); 
				
				jQuery("###arguments.fieldName#saveBtn").button();
				jQuery("###arguments.fieldName#saveBtn").bind("click", saveFile_#arguments.fieldName#);
				
				jQuery('###arguments.fieldName#cssEditor').bind("change keyup paste", function(e) {
				    if ( jQuery(this).val() != #arguments.fieldName#_original_data) {
				        //jQuery("label###arguments.fieldName#fileMsg").text("Changed from '" + #arguments.fieldName#_original_data + "' to '" + jQuery(this).val() + "'");
				        //jQuery("label###arguments.fieldName#fileMsg").text("Changed");
						  // text changed
				        //#arguments.fieldName#_original_data = jQuery(this).val();
						  fileStatus_#arguments.fieldName#('notsaved');
				    }
				});
				
				jQuery('###arguments.fieldName#cssSearch').bind("keyup paste", function(e) {
					 var searchInput = jQuery(this).val();
					 var searchTerms = [];
					 
					 searchInput = searchInput.trim();
					 searchTerms = searchInput.split(' ');
					 
					 //console.log( jQuery(this).val() );
					 //console.log( searchInput );
					 //console.log( searchTerms );
					 
					 jQuery('textarea###arguments.fieldName#cssEditor').highlightTextarea('setWords',searchTerms);
				});
				
				/* jQuery('###arguments.fieldName#cssEditor').click(function() {
					var newData = jQuery(this).val();
					//alert("area clicked!");
					
					if ( newData != #arguments.fieldName#_original_data ) {
						console.log("area clicked - changed!");
						//jQuery("###inputParameters.fldID#").val('');	
						fileStatus_#arguments.fieldName#('notsaved');				
					}
				});*/
				
				// Add Key up event to check if css has changed
				/* jQuery('###arguments.fieldName#cssEditor').keyup(function( event ) {
				 		var newData = jQuery(this).val();
						//alert("area typed!");
						
						if ( newData != #arguments.fieldName#_original_data ) {
							console.log("area typed - changed!");
							//jQuery("###inputParameters.fldID#").val('');	
							fileStatus_#arguments.fieldName#('notsaved');				
						}
				}).keydown(function( event ) {
				  	//if ( event.which == 13 ) // does not allow return key to fire
				   //	event.preventDefault();
				});*/
				
				//['icon-bg-red', 'Background'],
				jQuery('textarea###arguments.fieldName#cssEditor').highlightTextarea({
				  words: [], 
				  caseSensitive: false,
				  resizable: true
				}); 
			
			});
			
			function fileStatus_#arguments.fieldName#(status){
				if ( status == 'notsaved' )
				{
					jQuery("###inputParameters.fldID#").val('');	
					jQuery("i.icon-saved").hide();
					jQuery("label###arguments.fieldName#fileStatus").text('Changes Not Saved!');
				}
				else
				{
					jQuery("###inputParameters.fldID#").val('file-saved');
					jQuery("i.icon-saved").show();
					jQuery("label###arguments.fieldName#fileStatus").text('File Saved!');
					//#arguments.fieldName#_original_data = jQuery('###arguments.fieldName#cssEditor').val(); 
				}
			}
			
			function saveFile_#arguments.fieldName#(){
				var cssFilePath = "#cssDirPath#";
				var cssFileData = jQuery("###arguments.fieldName#cssEditor").val();
				//console.log(cssfileData);
				//alert("saved!");
				
				// clear the check
				/* 
					jQuery("###arguments.fieldName#checkbox").hide();
					jQuery("###arguments.fieldName#caution").hide(); 
				*/
				
				// make call to check path
				jQuery.post("#application.ADF.ajaxProxy#",
					{
						bean: "utils_2_0",
						method: "writeCSSfile",
						filePath: cssFilePath,
						dataString: cssFileData,
						overwrite: 1
					},
					function(results)
					{
						console.log(results);
						// show the results
						if ( results )
						{ 
							fileStatus_#arguments.fieldName#('saved');
							//jQuery("###inputParameters.fldID#").val('file-saved');
						}
						else
						{
							fileStatus_#arguments.fieldName#('notsaved');
							//jQuery("###inputParameters.fldID#").val('');
						}
						/*
							if( results )
								jQuery("###arguments.fieldName#checkbox").show();
							else
								jQuery("###arguments.fieldName#caution").show();
						*/
					});
					
				return true;
			}
		</script>


		<style>
			div###arguments.fieldName#editorControlsBox {
				margin-top: 1em;
			}
			div###arguments.fieldName#editorSearchBox {
				text-align: right;
				margin-bottom: 4px;
				/*border: 1px solid ##000;
				float: right;
				width: 200px;*/
			}
			i.icon-saved {
				display: none;
				color: ##009933;
				vertical-align: middle;
			}
			/*label###arguments.fieldName#fileStatus:after {
			   content: '\f00c';
			   font-family: FontAwesome;
			   font-weight: normal;
			   font-style: normal;
				font-size: 2em;
			   margin:0px 0px 0px 10px;
			   text-decoration:none;
			}*/
			textarea###arguments.fieldName#cssEditor {
				height: 275px;
    			width: 525px;
				overflow: auto; /* overflow is needed */
				resize: vertical;
			}
		</style>

		<div id="#arguments.fieldName#editorSearchBox">
			<label>Search:</label> <input name="#arguments.fieldName#cssSearch" id="#arguments.fieldName#cssSearch" value="" />
		</div>
		<div id="#arguments.fieldName#editorBox">
			<textarea name="#arguments.fieldName#cssEditor" id="#arguments.fieldName#cssEditor" cols="70" rows="20" wrap="off">#editorValue#</textarea>
		</div>
		<div id="#arguments.fieldName#editorControlsBox">
			<button type="button" name="#arguments.fieldName#saveBtn" id="#arguments.fieldName#saveBtn">Update StyleSheet</button>
			<i class="icon-saved fa fa-check fa-2x" aria-hidden="true"></i>
			<label id="#arguments.fieldName#fileStatus"></label>
			<!--- <label id="#arguments.fieldName#fileMsg"></label> --->
		</div>
		<!--- // Render the hidden CFT data field --->
		<!--- <br/><input type="text" name="#arguments.fieldName#" id="#inputParameters.fldID#" value="#currentValue#" size="60"> --->
		<input type="hidden" name="#arguments.fieldName#" id="#inputParameters.fldID#" value="#currentValue#">
	</cfoutput>
</cffunction>

<!---
	setDefaultParameters(fieldName,fieldDomID,value)
--->
<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">

	<cfscript>
		var inputParameters = duplicate(arguments.parameters);
		
		//if ( NOT StructKeyExists(inputParameters,"currentDefault") )
		//	inputParameters.currentDefault = "";	
//WriteDump(var=inputParameters.currentDefault,label=inputParameters.currentDefault,expand=false);

		if ( NOT StructKeyExists(inputParameters, "resourceName") )
			inputParameters.resourceName = "";

		// Validate if the property field has been defined
		if ( NOT StructKeyExists(inputParameters, "fldID") OR LEN(inputParameters.fldID) LTE 0 )
			inputParameters.fldID = arguments.fieldName;

		return inputParameters;
	</cfscript>
</cffunction>


<cfscript>
	private any function getValidationJS(required string formName, required string fieldName, required boolean isRequired)
	{
		if (arguments.isRequired)
			return 'hasValue(document.#arguments.formName#.#arguments.fieldName#, "TEXT")';
		return '';
	}
	
	private string function getValidationMsg()
	{
		return "The editor content has been changed but the file has not yet been updated.#CHR(10)#Please use the 'Updates StyleSheet' button before attempting to 'Save'.";
	}

	private boolean function isMultiline()
	{
		return true;
	}

	//	 if your renderer makes use of CommonSpot registered resources, implement getResourceDependencies() and return a list of them, like this
	public string function getResourceDependencies()
	{
		return "jQuery,jQueryUI,FontAwesome,jQueryHighlightTextArea";

		// if this renderer extends another one that may require its own resources, it should include those too, like this:
		//return listAppend(super.getResourceDependencies(), "jQuery");
	}

	// if your renderer needs to load resources other than what's returned by its getResourceDependencies(() method,...
	// 	...or if it uses the ADF scripts methods to load them, directly or indirectly via app-level methods, do that here
	// you could do this if some resources are loaded conditionally, based on context, page metadata, etc.
	// IMPORTANT: getResourceDependencies() still should return the full list of all resources that MIGHT be loaded, so exports can ensure they exist on a target system
	// by implementing loadResourceDependencies(), you're taking responsibility for keeping getResourceDependencies() in sync with it in that sense
	public void function loadResourceDependencies()
	{
		application.ADF.scripts.loadJQuery();
		application.ADF.scripts.loadJQueryUI();
		application.ADF.scripts.loadFontAwesome();
		application.ADF.scripts.loadJQueryHighlightTextArea();
		
		// if this renderer extends another one that may require its own resources, it should load those too, like this:
		//super.loadResourceDependencies();
	}
</cfscript>

</cfcomponent>
