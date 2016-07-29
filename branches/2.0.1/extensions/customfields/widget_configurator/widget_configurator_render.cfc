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
	$widget_configurator_render.cfc
Summary:
	Widget Option Configurator Render File
	
	INI file structure parsing thanks to:
	https://github.com/michaelsharman/INI-Parser
	
History:
 	2015-12-15 - GAC - Created
	2016-02-26 - DRM - Resource detection support
--->

<cfcomponent displayName="widget_configurator_render" extends="commonspot.public.form-field-renderer-base" output="no">

<cfscript>
	variables.cftDebug = false;
</cfscript>

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">

	<cfscript>
		var inputParameters = Duplicate(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		var currentObj = "";
		var currentData = StructNew();
		var widgetScript = "";
		var widgetData = StructNew();
		var vFilePath = "ram://#arguments.fieldName#_widget_options.ini";
		var v = 1;
		var vFieldCnt = 0;
		var vFieldData = StructNew();
		var vFld = "";
		var vFldLabel = "";
		var vFldName = "";
		var vFldProps = StructNew();
		var vFldPropsArray = ArrayNew(1);
		var bCnt = 0;
		var fKey = 0;
		var groupPrefix = "group_";
		var defaultGroupName = groupPrefix & "all";
		var groupsAPI = Server.CommonSpot.ObjectFactory.getObject("Groups");
	   var groupQry = groupsAPI.getNamesGivenIDs(request.user.GroupList);
		var groupName = "";
		var q = 1;
		var defaultData = StructNew();
		var renderedData = StructNew();
		var renderedErrors = ArrayNew(1);
		var fld = "";
		var cfgFieldLabel = "";
		var opt = "";
		var cfgFieldName = "";
		var cfgOptionLabel = "";
		var cfgOptionValue = "";
		var cfgOptionSelected = false;
		var fldHasDefault = false;
		var fldHasDescription = false;
		var fldLabelDivClass = "cfgFieldLabel";
		var fldDescriptionDivClass = "cfgFieldDescription";
		var optionDelimiter = ";";
		var valueTextDelimiter = "|";
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);
		
//WriteDump(var=groupQry,expand=false,label="groupQry");
//WriteDump(var=groupNameList,expand=false,label="groupNameList");	
//WriteDump(var=request.user,expand=false,label="request.user");
//WriteDump(var=request.user.GroupList,expand=false,label="request.user.GroupList");		
//WriteDump(inputParameters);
//WriteDump(var=currentValue,label="currentValue");

		if ( LEN(currentValue) )
		{
			currentObj = DeserializeJSON(TRIM(currentValue));
			if ( StructKeyExists(currentObj,"Data") )
				currentData = currentObj.Data;
		}	

		if ( StructKeyExists(inputParameters,"widgetScript") )
			widgetScript = inputParameters.widgetScript;
		
		// Write INI config data to a RAM Disk File	
		FileWrite(vFilePath,widgetScript);
		
		// Read the INI config data from RAM and serialize it into a Structure
		widgetData = parseINI(vFilePath);
		
		// Loop over the widgetData built from the INI config data
		if ( !StructIsEmpty(widgetData) AND StructKeyExists(widgetData,"config") AND StructKeyExists(widgetData.config,"fields") )
		{
			for ( v=1; v LTE ListLen(widgetData.config.fields,optionDelimiter); v=v+1 ) {
				
				// Get the List Item
				vFld = ListGetAt(widgetData.config.fields,v,optionDelimiter);
				
				// For the Field Labels convert all underscores(_) to spaces
				vFldLabel = TRIM(REPLACE(vFld,"_"," ","all"));
				// For the Field Names convert all non-AlphaNumeric chars to underscores(_) 
				vFldName = TRIM(REREPLACENOCASE(vFld,"[^A-Za-z0-9]","_","all"));
				
				// If we don't have a vFld key OR its not a struct... skip it
				if ( StructKeyExists(widgetData,vFldName) AND IsStruct(widgetData[vFldName]) )
				{
					
					// Build an Array for fixed FieldName Keys and Labels (used to render field in order)
					vFldProps = StructNew();
					vFldProps.FieldName = vFldName;
					vFldProps.FieldLabel = vFldLabel;
					
					ArrayAppend(vFldPropsArray,vFldProps);
					
//WriteOutput(vFldName);WriteOutput("<br>");
//WriteOutput(vFldLabel);WriteOutput("<br>");
//WriteDump(widgetData[vFldName]);WriteOutput("<br>");
					
					if ( !StructKeyExists(vFieldData,vFldName) )
					{
						vFieldData[vFldName] = StructNew();
						vFieldData[vFldName]['options'] = "";
						vFieldData[vFldName]['description'] = "";
						//['default'] - since empty string might be a default value we don't want a key if a default is not defined
						
						// Set the Default set of options							
						if ( StructKeyExists(widgetData[vFldName],defaultGroupName) )
							vFieldData[vFldName]['options'] = widgetData[vFldName][defaultGroupName];
					
						// Override the OPTIONS if we are approved by the Group Check for the currently logged in user
						groupName = "";
						for ( q=1; q LTE groupQry.RecordCount; q=q+1 )
						{
							groupName = TRIM(LCASE(REREPLACE(groupQry.name[q],"[\s]","_","all")));
							groupName = groupPrefix & groupName;
						
							if ( StructKeyExists(widgetData[vFldName],groupName) ) 
							{					
								vFieldData[vFldName]['options'] = widgetData[vFldName][groupName];
								break;
							}	
						}
																										
						
						// set the default selected option 							
						if ( StructKeyExists(widgetData[vFldName],"default") )
							vFieldData[vFldName]['default'] = widgetData[vFldName]["default"];
						
						// set the description								
						if ( StructKeyExists(widgetData[vFldName],"description") )
							vFieldData[vFldName]['description'] = widgetData[vFldName]["description"];						
					}
				}
			}
		}
		// Count the new vFieldData structure
		vFieldCnt = StructCount(vFieldData);

//WriteDump(currentValue);
//WriteDump(var=currentData,expand=false,label="currentData");
//WriteDump(widgetScript);
//WriteDump(var=widgetData,expand=false,label="widgetData");
//WriteDump(var=vFldPropsArray,expand=false,label="vFldPropsArray");
//WriteDump(var=vFieldData,expand=false,label="vFieldData");
//WriteDump(var=vFieldCnt,expand=false,label="vFieldCnt");
//exit;
	</cfscript>
	
	<cfsavecontent variable="cftWidgetConfigCSS">
	<cfoutput>
	<style>
		.cfgFieldBox {
			margin-bottom: 6px;
		}
		
		.cfgFieldLabel {
			display: block;
			float: left;
			width: 110px;
			/*border: 1px solid ##000;*/
		}
		.cfgFieldLabelTall {
			display: block;
			float: left;
			width: 110px;
			height: 38px;
			/* border: 1px solid ##000;*/
		}
		
		.cfgFieldControl {
			/*border: 1px solid ##000;*/
		}
		.cfgFieldDescription {
			display: block;
			margin-top: 4px;		
		}
		.cfgFieldDescriptionWrap {
			display: block;
			margin-top: 4px;
			overflow: hidden; 	
		   white-space: normal;
			
			/* text-overflow: ellipsis; */
			/* white-space: nowrap; */
			/* word-wrap: break-word;*/
		}
	</style>
	</cfoutput>
	</cfsavecontent>

	<cfsavecontent variable="cftWidgetConfigJS">
	<cfoutput>
	<script type="text/javascript">
		<!--
			jQuery(function(){
				<cfloop collection="#vFieldData#" item="fKey">
					jQuery("###fKey#_select").change( function(){
							var sVal = jQuery(this).val();
							//alert(sVal);
							buildConfigData_#arguments.fieldName#();
					});
				</cfloop>
			});
			
			function buildConfigData_#arguments.fieldName#(){
				var fieldVal = "";
				var errors = [];
				var data = {
							<cfloop collection="#vFieldData#" item="fKey">
								<cfset bCnt = bCnt + 1>
								#fKey#: jQuery("###fKey#_select").val()<cfif bCnt LT vFieldCnt>,</cfif>
							</cfloop>
						};

				var fldValueObj = {
					DATA:data,
					ERRORS:errors
				};
				fieldVal = jQuery.toJSON(fldValueObj);

				jQuery("###inputParameters.fldID#").val(fieldVal);
			}
		-->
	</script>
	</cfoutput>
	</cfsavecontent>

	<cfscript>
		application.ADF.scripts.addHeaderCSS(cftWidgetConfigCSS,"SECONDARY");
		application.ADF.scripts.addFooterJS(cftWidgetConfigJS,"SECONDARY");
	</cfscript>
	
	<cfscript>
		defaultData = StructNew();
		renderedData = StructNew();
		renderedErrors = ArrayNew(1);
	</cfscript>

	<cfoutput>
	<cfif ArrayLen(vFldPropsArray)>
		<!--// START: Render Widget Fields -->
		<div>
		<cfloop index="fld" array="#vFldPropsArray#">
			<cfscript>
					cfgFieldLabel = fld.FieldLabel;
					cfgFieldName = fld.FieldName;
					//cfgFieldLabel = Replace(fld,"_"," ","ALL");
			</cfscript>
		
			<cfif StructKeyExists(vFieldData,cfgFieldName) AND StructKeyExists(vFieldData[cfgFieldName],"options") AND LEN(TRIM(vFieldData[cfgFieldName].options))>
				
				<cfif ListLen(vFieldData[cfgFieldName].options,optionDelimiter) GT 1>
					<cfscript>
						fldHasDefault = StructKeyExists(vFieldData[cfgFieldName],"default");
						fldHasDescription = YesNoFormat(StructKeyExists(vFieldData[cfgFieldName],"description") && LEN(TRIM(vFieldData[cfgFieldName].description)));
						fldLabelDivClass = "cfgFieldLabel";
						if ( fldHasDescription )
							fldLabelDivClass = "cfgFieldLabelTall";
					</cfscript>
					<div id="#cfgFieldName#_container" class="cfgFieldBox">
						<div class="#fldLabelDivClass#">
							<label for="#cfgFieldName#_select">#cfgFieldLabel#:</label>
						</div>
						<div class="cfgFieldControl">
							<select name="#cfgFieldName#_select" id="#cfgFieldName#_select" size="1">
								<!--- <option value="">-- select --</option> --->
								<cfloop list="#vFieldData[cfgFieldName]['options']#" index="opt" delimiters="#optionDelimiter#">
									
									<cfscript>
										cfgOptionValue = "";
										cfgOptionName = "";
										cfgOptionSelected = false;
										
										// Get the Value/Text options (pipe delimited) for the Selection List --->
										if ( ListLen(opt,valueTextDelimiter) GT 1 )
										{
											cfgOptionValue = ListFirst(opt,valueTextDelimiter);
											cfgOptionName = ListRest(Replace(opt,"_"," ","ALL"),valueTextDelimiter);
										
										}
										else
										{
											cfgOptionValue = opt;
											cfgOptionName = Replace(opt,"_"," ","ALL");
										}
									
										// Set the Selected Option 
										if ( StructKeyExists(currentData,cfgFieldName) )
										{
											// If we have a current value for this field... does current value match the option
											if ( currentData[cfgFieldName] EQ cfgOptionValue )
												cfgOptionSelected = true;
										}
										else if ( StructKeyExists(vFieldData[cfgFieldName],"default") AND vFieldData[cfgFieldName]['default'] EQ cfgOptionValue )
											cfgOptionSelected = true;
									</cfscript>
									
									<!--- <option value="#opt#">#cfgOptionName#</option> --->
									<!--- <option value="#opt#"<cfif StructKeyExists(currentData,cfgFieldName) AND currentData[cfgFieldName] EQ opt> selected=""</cfif>>#cfgOptionName#</option>--->
								
									<option value="#cfgOptionValue#"<cfif cfgOptionSelected> selected=""</cfif>>#left(cfgOptionName,65)#<cfif LEN(cfgOptionName) GT 65>...</cfif></option>
						
									<cfif StructKeyExists(currentData,cfgFieldName) AND currentData[cfgFieldName] EQ cfgOptionValue>
										<cfset renderedData[cfgFieldName] = cfgOptionValue>  
									</cfif>
								</cfloop>
							</select>
							<cfif fldHasDescription>
								<cfscript>
										fldDescriptionDivClass = "cfgFieldDescription";
										if ( LEN(TRIM(vFieldData[cfgFieldName]['description'])) GT 65 )
											fldDescriptionDivClass = "cfgFieldDescriptionWrap";
								</cfscript>
								<div class="#fldDescriptionDivClass#">
									#TRIM(vFieldData[cfgFieldName]['description'])#
								</div>
							</cfif>
						</div>
						
						<!---// If no Selection List is rendered above then add the first option to renderData struct --->
						<cfif !StructKeyExists(renderedData,cfgFieldName)>
								
							<!--- // If we have a default defined use for the renderedData Value --->
							<cfif fldHasDefault>
								<cfset renderedData[cfgFieldName] = vFieldData[cfgFieldName]['default']>
							<cfelse>
								<cfset renderedData[cfgFieldName] = ListFirst(ListFirst(vFieldData[cfgFieldName]['options'],optionDelimiter),valueTextDelimiter)> 	
							</cfif>
							<!--- <cfset renderedData[cfgFieldName] = ListFirst(ListFirst(vFieldData[cfgFieldName]['options'],optionDelimiter),valueTextDelimiter)> --->	

						</cfif>
						
					</div>
				<cfelse>
					<!--- // Since if we are here we only have 1 option for this field use its value as a hidden value--->
					<cfset renderedData[cfgFieldName] = ListFirst(vFieldData[cfgFieldName]['options'],valueTextDelimiter)>
					<input type="hidden" name="#cfgFieldName#_select" id="#cfgFieldName#_select" value="#renderedData[cfgFieldName]#">
				</cfif>
			</cfif>
		</cfloop>
		</div> <!--// END: Render Widget Fields -->
	<cfelse>
		<div>No Fields with Options have been configured!</div>
	</cfif>
	</cfoutput>
			
	<cfscript>
		// Build the inital defaultData structure from the renderData and renderErrors
		defaultData.data = renderedData;
		defaultData.errors = renderedErrors;
			
		// Serialize into JSON the defaultData structure
		currentValue = serializeJSON(defaultData);
		currentValue = HTMLEditFormat(currentValue);
		
//WriteDump(var=renderedData,expand=false,label="renderedData");
//WriteDump(var=defaultData,expand=false,label="defaultData");	
//WriteDump(var=currentValue,expand=false,label="currentValue");
	</cfscript>
		
	<cfoutput>
	<!--- // Render the hidden CFT data field --->
	<cfif variables.cftDebug>
		<input type="text" name="#arguments.fieldName#" id="#inputParameters.fldID#" value="#currentValue#" size="70">
	<cfelse>
		<input type="hidden" name="#arguments.fieldName#" id="#inputParameters.fldID#" value="#currentValue#"/>
	</cfif>
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
		
		if ( NOT StructKeyExists(inputParameters, "widgetScript") )
			inputParameters.widgetScript = "";

		// Validate if the property field has been defined
		if ( NOT StructKeyExists(inputParameters, "fldID") OR LEN(inputParameters.fldID) LTE 0 )
			inputParameters.fldID = arguments.fieldName;

		return inputParameters;
	</cfscript>
</cffunction>

<cfscript>
	/*
		parseINI(iniPath)
		
		Parses a textfile in the INI format and returns a structure of variables grouped by sections
	*/
	public struct function parseINI(iniPath)
	{
		try
		{
			var retData = {};
			var prop = "";
			var section = "";
			var sections = getProfileSections(arguments.iniPath);
			var sectionFix = "";

			// If there are no sections in the ini file, return a single level struct of name=value pairs
			if ( StructIsEmpty(sections) )
			{
				return parseSimpleINI(iniPath=arguments.iniPath);
			}

			for (section in sections)
			{
				// Replace non AlphaNumeric chars with underscores in all section Keys
				sectionFix = TRIM(REREPLACENOCASE(section,"[^A-Za-z0-9]","_","all"));
				
				retData[sectionFix] = {};
				for (prop in listToArray(sections[section]))
				{
					// PT GAC - Make sure props that start with pounds are not included
					if ( Left(prop,1) NEQ "##" )
						retData[sectionFix][prop] = getProfileString(arguments.iniPath, section, prop);
				}
			}

			return retData;
		}
		catch( java.io.FileNotFoundException e )
		{
			throw(type="widget_configurator.parseINI.filenotfound", message="Ini file not found in path '#arguments.iniPath#'");
		}
		catch (any e)
		{
			throw(type="widget_configurator.parseINI.error", message=e.getMessage());
		}
	}

	/*
		parseSimpleINI
		
		Parses a simple INI file that contains name=value pairs with no sections and returns a single level struct
	*/
	private struct function parseSimpleINI(iniPath)
	{
		var iniFile = FileOpen(arguments.iniPath, "read", "utf-8");
		var line = "";
		var retData = {};

		while( !FileIsEOF(iniFile) )
		{
			line = fileReadLine(iniFile);
			// Ignore empty (spacer) lines, as well as comment lines (;)
			if (len(line) && left(trim(line), 1) != ";")
			{
				retData[trim(listFirst(line, "="))] = trim(listLast(line, "="));
			}
		}
		FileClose(iniFile);

		return retData;
	}
</cfscript>

<cfscript>
	private any function getValidationJS(required string formName, required string fieldName, required boolean isRequired)
	{
		if (arguments.isRequired)
			return 'hasValue(document.#arguments.formName#.#arguments.fieldName#, "TEXT")';
		return '';
	}

	private boolean function isMultiline()
	{
		return true;
	}
	
	/*public numeric function getMinHeight()
	{
		return 200;
	}*/
	
	/*public numeric function getMinWidth()
	{
		return 800;
	}*/

	//	 if your renderer makes use of CommonSpot registered resources, implement getResourceDependencies() and return a list of them, like this
	public string function getResourceDependencies()
	{
		return "jQuery,jQueryJSON";

		// if this renderer extends another one that may require its own resources, it should include those too, like this:
		// return listAppend(super.getResourceDependencies(), "jQuery,jQueryJSON");
	}

	// if your renderer needs to load resources other than what's returned by its getResourceDependencies(() method,...
	// 	...or if it uses the ADF scripts methods to load them, directly or indirectly via app-level methods, do that here
	// you could do this if some resources are loaded conditionally, based on context, page metadata, etc.
	// IMPORTANT: getResourceDependencies() still should return the full list of all resources that MIGHT be loaded, so exports can ensure they exist on a target system
	// by implementing loadResourceDependencies(), you're taking responsibility for keeping getResourceDependencies() in sync with it in that sense
	public void function loadResourceDependencies()
	{
		application.ADF.scripts.loadJQuery();
		application.ADF.scripts.loadJQueryJSON();

		// if this renderer extends another one that may require its own resources, it should load those too, like this:
		//super.loadResourceDependencies();
	}
</cfscript>

</cfcomponent>
