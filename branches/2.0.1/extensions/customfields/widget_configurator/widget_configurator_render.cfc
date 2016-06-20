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
		var vFldArray = ArrayNew(1);
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
		var cfgOptionValue = "";
		var cfgOptionName = "";
		var fldHasDescription = false;
		var fldLabelDivClass = "cfgFieldLabel";

//WriteDump(var=groupQry,expand=false,label="groupQry");
//WriteDump(var=groupNameList,expand=false,label="groupNameList");
		
//WriteDump(var=request.user,expand=false,label="request.user");
//WriteDump(var=request.user.GroupList,expand=false,label="request.user.GroupList");
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);
//WriteDump(inputParameters);

//WriteOutput("currentValue: ");
//WriteDump(var=currentValue,label="currentValue");

		if ( LEN(currentValue) )
		{
//WriteOutput("use current saved values!<br>");			
			
			currentObj = DeserializeJSON(TRIM(currentValue));
			if ( StructKeyExists(currentObj,"Data") )
				currentData = currentObj.Data;
		}
		else
		{
			// Using Default Script Value
//WriteOutput("use defaults!<br>");			
		}
		
//WriteDump(var=currentData,label="currentData",expand=false);			

		if ( StructKeyExists(inputParameters,"widgetScript") )
			widgetScript = inputParameters.widgetScript;
		
		// Write INI config data to a RAM Disk File	
		FileWrite(vFilePath,widgetScript);
		
		// Read the INI config data from RAM and serialize it into a Structure
		widgetData = parseINI(vFilePath);
		
//WriteDump(var=widgetData,expand=false);
//exit;

		// Loop over the widgetData built from the INI config data
		if ( !StructIsEmpty(widgetData) AND StructKeyExists(widgetData,"config") AND StructKeyExists(widgetData.config,"fields") )
		{
			for ( v=1; v LTE ListLen(widgetData.config.fields); v=v+1 ) {
				// Get the List Item
				vFld = ListGetAt(widgetData.config.fields,v);
				// Make sure it has underscores instead of spaces
				vFld = TRIM(REREPLACE(vFld,"[\s]","_","all"));
// WriteOutput(vFld);WriteOutput("<br>");
				
				// Build an Array for fixed FieldName Keys (used to render field in order)
				ArrayAppend(vFldArray,vFld);

				if ( StructKeyExists(widgetData,vFld) )
				{
// WriteOutput(vFld);WriteOutput("<br>");
// WriteDump(widgetData[vFld]);WriteOutput("<br>");
					
					if ( !StructKeyExists(vFieldData,vFld) )
					{
						// Do the Group Check for the currently logged in user
						groupName = "";
						for ( q=1; q LTE groupQry.RecordCount; q=q+1 )
						{
							groupName = TRIM(LCASE(REREPLACE(groupQry.name[q],"[\s]","_","all")));
							groupName = groupPrefix & groupName;
							// WriteOutput(groupName);WriteOutput("<br>");
						
							if ( StructKeyExists(widgetData[vFld],groupName) ) 
							{
								vFieldData[vFld] = StructNew();
								vFieldData[vFld].options = widgetData[vFld][groupName];
								break;
							}	
						}
						//WriteDump(widgetData[vFld]);
					
						// If no vFld has been defined in the new vFieldData... then use default values
						if ( !StructKeyExists(vFieldData,vFld) )
						{
							vFieldData[vFld] = StructNew();
							vFieldData[vFld].options = "";
							if ( IsStruct(widgetData[vFld]) AND StructKeyExists(widgetData[vFld],defaultGroupName) )
								vFieldData[vFld].options = widgetData[vFld][defaultGroupName];
						}
						
						vFieldData[vFld].description = "";
						if ( IsStruct(widgetData[vFld]) AND StructKeyExists(widgetData[vFld],"description") )
							vFieldData[vFld].description = widgetData[vFld]["description"];;
					}
				}
			}
		}
		// Count the new vFieldData structure
		vFieldCnt = StructCount(vFieldData);

//WriteDump(currentValue);
//WriteDump(widgetScript);

//WriteDump(var=widgetData,expand=false,label="widgetData");
//WriteDump(var=vFldArray,expand=false,label="vFldArray");
//WriteDump(var=vFieldData,expand=false,label="vFieldData");
//WriteDump(var=vFieldCnt,expand=false,label="vFieldCnt");
//exit;
	</cfscript>
	
	<cfsavecontent variable="cftWidgetConfigCSS">
	<cfoutput>
	<style>
		.cfgFieldBox {
			margin-bottom: 6px;
			/* border: 1px solid ##000;*/ 
		}
		
		.cfgFieldLabel {
			display: block;
			float: left;
			width: 100px;
			/*border: 1px solid ##000;*/
		}
		.cfgFieldLabelTall {
			display: block;
			float: left;
			width: 100px;
			height: 38px;
			/* border: 1px solid ##000;*/
		}
		
		.cfgFieldControl {
			/*border: 1px solid ##000;*/
		}
		.cfgFieldDescription {
			margin-top: 4px;
		   overflow: hidden;
		   display: block;
		   text-overflow: ellipsis;
		   white-space: normal;
		
			/* text-overflow: ellipsis; */
			/* white-space: nowrap; */
			/* width: 350px;*/
			/* border: 1px solid ##000; */
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
		defaultData	= StructNew();
		renderedData	= StructNew();
		renderedErrors = ArrayNew(1);
	</cfscript>

	<cfoutput>
	<cfif ArrayLen(vFldArray)>
		<!--// START: Render Widget Fields -->
		<div>
		<cfloop index="fld" array="#vFldArray#">
			<cfif StructKeyExists(vFieldData,fld) AND StructKeyExists(vFieldData[fld],"options") AND LEN(TRIM(vFieldData[fld].options))>
				<cfset cfgFieldLabel = Replace(fld,"_"," ","ALL")>
				
				<cfif ListLen(vFieldData[fld].options) GT 1>
					<cfscript>
						fldHasDescription = YesNoFormat(LEN(TRIM(vFieldData[fld].description)));
						fldLabelDivClass = "cfgFieldLabel";
						if ( fldHasDescription )
							fldLabelDivClass = "cfgFieldLabelTall";
					</cfscript>
					<div id="#fld#_container" class="cfgFieldBox">
						<div class="#fldLabelDivClass#">
							<label for="#fld#_select">#cfgFieldLabel#:</label>
						</div>
						<div class="cfgFieldControl">
							<select name="#fld#_select" id="#fld#_select" size="1">
								<!--- <option value="">-- select --</option> --->
								<cfloop list="#vFieldData[fld].options#" index="opt">
									<!--- // Get the Value/Text options (pipe delimited) for the Selection List --->
									<cfif ListLen(opt,"|") GT 1>
										<cfset cfgOptionValue = ListFirst(opt,"|")>
										<cfset cfgOptionName = ListRest(Replace(opt,"_"," ","ALL"),"|")>
									<cfelse>
										<cfset cfgOptionValue = opt>
										<cfset cfgOptionName = Replace(opt,"_"," ","ALL")>
									</cfif>
									<!--- <option value="#opt#">#cfgOptionName#</option> --->
									<!--- <option value="#opt#"<cfif StructKeyExists(currentData,fld) AND currentData[fld] EQ opt> selected=""</cfif>>#cfgOptionName#</option>--->
								
									<option value="#cfgOptionValue#"<cfif StructKeyExists(currentData,fld) AND currentData[fld] EQ cfgOptionValue> selected=""</cfif>>#cfgOptionName#</option>
						
									<cfif StructKeyExists(currentData,fld) AND currentData[fld] EQ cfgOptionValue>
										<cfset renderedData[fld] = cfgOptionValue>  
									</cfif>
								</cfloop>
							</select>
							<cfif fldHasDescription>
								<div class="cfgFieldDescription">
									#vFieldData[fld].description#
								</div>
							</cfif>
						</div>
						<!---// If no Select List is rendered add the first option to renderData struct --->
						<cfif !StructKeyExists(renderedData,fld)>
							<cfset renderedData[fld] = ListFirst(ListFirst(vFieldData[fld].options,","),"|")> 	
						</cfif>
						
					</div>
				<cfelse>
					<input type="hidden" name="#fld#_select" id="#fld#_select" value="#vFieldData[fld].options#">
					<cfset renderedData[fld] = vFieldData[fld].options>
				</cfif>
			</cfif>
		</cfloop>
		</div> <!--// END: Render Widget Fields -->
	<cfelse>
		<div>No Fields with Options have been configured!</div>
	</cfif>
	</cfoutput>
			
	<cfscript>
//WriteDump(var=renderedData,expand=false,label="renderedData");	
	
		defaultData.data = renderedData;
		defaultData.errors = renderedErrors;	
//WriteDump(var=defaultData,expand=false,label="defaultData");
		
		currentValue = serializeJSON(defaultData);
//WriteDump(var=currentValue,expand=false,label="currentValue");

		currentValue = HTMLEditFormat(currentValue);
//WriteDump(var=currentValue,expand=false,label="currentValue");
	</cfscript>
		
	<cfoutput>
		<!--- // Render the hidden CFT data field --->
		<!--- <input type="text" name="#arguments.fieldName#" id="#inputParameters.fldID#" value="#currentValue#" size="60">--->
		<input type="hidden" name="#arguments.fieldName#" id="#inputParameters.fldID#" value="#currentValue#"/>
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
				// Replace spaces with underscores in all section Keys
				sectionFix = TRIM(REREPLACE(section,"[\s]","_","all"));
				
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
