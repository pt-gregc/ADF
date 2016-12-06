<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc.  Copyright (c) 2009-2016.
All Rights Reserved.
 
By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright / M. Carroll 
Custom Field Type:
	Page Layout
Name:
	page_layout_render.cfc
Summary:
	Custom field to render predefined page layout options in metadata forms.
History:
	2010-09-09 - GAC/MFC - 	Created
	2010-11-11 - MFC - 		Added onclick to the img to select the radio button. 
								Due to problem reported with Mac browser and label 
								select is not checking the radio field.
	2011-03-28 - MFC - Added check for if the photo URL is defined.
	2015-05-11 - DJM - Converted to CFC
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean()
	2016-02-09 - GAC - Updated duplicateBean() to use data_2_0.duplicateStruct()
	2016-02-16 - GAC - Added getResourceDependencies support
					 	  - Added loadResourceDependencies support
		 				  - Moved resource loading to the loadResourceDependencies() method
	2016-06-07 - GAC - Updated to use config ini props format
--->
<cfcomponent displayName="PageLayout_Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">

	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value	 
		var layoutOptions = ArrayNew(1);
		var newOption = structNew();
		var currOptionName = '';
		var i = 0;

		var pageLayoutScript = "";
		var pageLayoutData = StructNew();
		var vFilePath = "ram://#arguments.fieldName#_page_layout_options.ini";
		var v = 1;
		var vFieldCnt = 0;
		var vFieldData = StructNew();
		var vFld = "";
		var bCnt = 0;
		var fKey = 0;
		var groupsAPI = Server.CommonSpot.ObjectFactory.getObject("Groups");
	   var groupQry = groupsAPI.getNamesGivenIDs(request.user.GroupList);
		var userGroupName = "";
		var userGroupNameFix = "";
		var q = 1;
		var defaultData = StructNew();
		var renderedData = StructNew();
		var renderedErrors = ArrayNew(1);
		var fld = "";
		var cfgFieldLabel = "";
		var opt = "";
		var cfgOptionValue = "";
		var cfgOptionName = "";
		var securityGroups = "";
		var thumbImgPath = "";
		var currentPageID = StructKeyExists(request.params,"pageID") ? request.params.pageid : structKeyExists(request.page,"id") ? request.page.id : 0;
		var allowedPageIDlist = "";   // Layout by Layout setting
		var disabledPageIDlist = "";  // All Layouts Setting ( overrides allowedPageIDList )
		var addLayoutOption = false;
		var hideAllLayoutOptions = false;
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);

		if ( StructKeyExists(inputParameters,"pageLayoutScript") )
			pageLayoutScript = inputParameters.pageLayoutScript;

		// Write INI config data to a RAM Disk File
		FileWrite(vFilePath,pageLayoutScript);

		// Read the INI config data from RAM and serialize it into a Structure
		pageLayoutData = parseINI(vFilePath);

		// Loop over the pageLayoutData built from the INI config data
		if ( !StructIsEmpty(pageLayoutData) AND StructKeyExists(pageLayoutData,"config") )
		{
			
			// Are disabledPages been configured?
		 	if ( StructKeyExists(pageLayoutData.config,"DisabledPages") AND LEN(TRIM(pageLayoutData.config.DisabledPages)) )
					disabledPageIDlist = pageLayoutData.config.DisabledPages;
			 
			if ( ListFind(disabledPageIDlist, currentPageID) GT 0 )
				hideAllLayoutOptions = true;

//WriteDump(var=hideAllLayoutOptions,expand=false,label="hideAllLayoutOptions");

		 	if ( StructKeyExists(pageLayoutData.config,"ImagesPath") AND LEN(TRIM(pageLayoutData.config.ImagesPath)) )
					thumbImgPath = pageLayoutData.config.ImagesPath;

		 	if ( StructKeyExists(pageLayoutData.config,"Options") AND LEN(TRIM(pageLayoutData.config.Options)) )
			{
				for ( v=1; v LTE ListLen(pageLayoutData.config.Options); v=v+1 ) {
					// Set the add to false for each interation
					addLayoutOption = false;
					
					// Get the List Item
					vFld = ListGetAt(pageLayoutData.config.Options,v);
					// Make sure it has underscores instead of spaces
					vFld = TRIM(REREPLACE(vFld,"[\s]","_","all"));

//WriteDump(var=vFld,expand=false,label="vFld");

					if ( StructKeyExists(pageLayoutData,vFld) AND IsStruct(pageLayoutData[vFld]) )
					{
						// Add the name Key with the Option value
						pageLayoutData[vFld]["name"] = vFld;
						
						// If a full ["imageUrl"] has been define for this item ... use it.
						// Although if an ["image"] parameter is passed in will override the defined ["imageURL"]
						// - so create the imageURL from the imagePath and image values
						if ( StructKeyExists(pageLayoutData[vFld],"image") AND LEN(TRIM(pageLayoutData[vFld]["image"])) )
							pageLayoutData[vFld]["imageUrl"] = thumbImgPath & pageLayoutData[vFld]["image"];
						
						// But after all that... set an imageURL to empty string if an imageURL has not been created (or passed in)
						if ( !StructKeyExists(pageLayoutData[vFld],"imageUrl") )
							pageLayoutData[vFld]["imageUrl"] = "";
						
						// Check for security settings to show or hide specific layout options
						securityGroups = "";
						if ( StructKeyExists(pageLayoutData[vFld],"security") AND LEN(TRIM(pageLayoutData[vFld]["security"])) )
							securityGroups = pageLayoutData[vFld]["security"];
						else if ( StructKeyExists(pageLayoutData[vFld],"allowedgroups") AND LEN(TRIM(pageLayoutData[vFld]["allowedgroups"])) )
							securityGroups = pageLayoutData[vFld]["allowedgroups"];
						
						if ( LEN(TRIM(securityGroups)) ) 
						{
							// Do the Group Check for the currently logged in user
							userGroupName = "";
							for ( q=1; q LTE groupQry.RecordCount; q=q+1 )
							{
								userGroupName = TRIM(LCASE(groupQry.name[q]));
								userGroupNameFix = TRIM(LCASE(REREPLACE(groupQry.name[q],"[\s]","_","all")));

								if( ListFindNoCase(securityGroups, userGroupName) OR ListFindNoCase(securityGroups, userGroupNameFix)  )
								{
									addLayoutOption = true;
									break;
								}
							}
						}
						else if ( StructKeyExists(pageLayoutData[vFld],"allowedpages") AND LEN(TRIM(pageLayoutData[vFld]["allowedpages"])) )
						{
							allowedPageIDlist = pageLayoutData[vFld]["allowedpages"];
							
							if ( ListFind(allowedPageIDlist, currentPageID) )
								addLayoutOption = true;
						}
						else
							addLayoutOption = true;
						
						if ( addLayoutOption )	
							ArrayAppend(layoutOptions,pageLayoutData[vFld]);
					}
				}
			}
		}

//WriteDump(currentValue);
//WriteDump(pageLayoutScript);
//WriteDump(currentPageID);
//WriteDump(var=request.params,expand=false,label="params");

//WriteDump(var=pageLayoutData,expand=false,label="pageLayoutData");
//WriteDump(var=vFieldData,expand=false,label="vFieldData");
//WriteDump(var=vFieldCnt,expand=false,label="vFieldCnt");
//WriteDump(var=layoutOptions,expand=false,label="layoutOptions");
	</cfscript>

	<!--- // OLD STYLE LAYOUT CONFIG
	<cfscript>
		/* 
			Establish the layout options with security access for specific users.
			
			The layoutOptions Array stores the option name, thumbnail image, and 
				security groups that have permissions to select the option. 
			
			Array contains the following substructures with the fields:
				name 		= Name of the layout option stored in the metadata form.
				description = Description for the layout option - Displayed to the user.
				security 	= Group Names
				image 		= Path to the image file
				
			After the newOption structure is built, it is appended into the layoutOptions Array.
		*/	
		
		// Home Layout
		newOption = structNew();
		newOption.name = "Home";
		newOption.description = "Home";
		newOption.security = "";
		newOption.image = "/ADF/extensions/customfields/page_layout/thumbs/home.gif";
		ArrayAppend(layoutOptions, newOption);
		
		// Landing Layout
		newOption = structNew();
		newOption.name = "Landing";
		newOption.description = "Landing Page";
		newOption.security = "";
		newOption.image = "/ADF/extensions/customfields/page_layout/thumbs/landing.gif";
		ArrayAppend(layoutOptions, newOption);
		
		// Full Width Layout
		newOption = structNew();
		newOption.name = "Full-Width";
		newOption.description = "Full Width";
		newOption.security = "";
		newOption.image = "/ADF/extensions/customfields/page_layout/thumbs/full_width.gif";
		ArrayAppend(layoutOptions, newOption);
		
		// Equal Width Layout
		newOption = structNew();
		newOption.name = "Equal-Width";
		newOption.description = "Equal Width";
		newOption.security = "";
		newOption.image = "/ADF/extensions/customfields/page_layout/thumbs/equal_width.gif";
		ArrayAppend(layoutOptions, newOption);
		
		// Right Channel Layout
		newOption = structNew();
		newOption.name = "Right-Channel";
		newOption.description = "Right Channel";
		newOption.security = "";
		newOption.image = "/ADF/extensions/customfields/page_layout/thumbs/right_channel.gif";
		ArrayAppend(layoutOptions, newOption);
	</cfscript> --->

	<cfscript>
		renderStyles(argumentCollection=arguments);
		renderJSFunctions(argumentCollection=arguments);
	</cfscript>

	<cfoutput>
		<div class="main">
			<cfif hideAllLayoutOptions>
				<div class="imageChoiceMsg">Layout options are not avaiable for this page.</div>
				<input type="hidden" name="#arguments.fieldName#" id="#currentValue#" value="#currentValue#"/>
			<cfelse>
				<!--- Loop over the array of options --->
				<cfloop index="i" from="1" to="#ArrayLen(layoutOptions)#" >
					<!--- Set the current option name b/c we use it multiple times --->
					<cfset currOptionName = layoutOptions[i].name>

					<div class="imageChoice">
						<label for="#currOptionName#">
							<input type="radio" name="#arguments.fieldName#" id="#currOptionName#" value="#currOptionName#"<cfif currentValue eq "#currOptionName#"> checked="checked"</cfif>/>
							<span>#layoutOptions[i].description#</span><br/>
							<!--- Check for if the image field is defined --->
							<cfif StructKeyExists(layoutOptions[i],"imageUrl") AND LEN(TRIM(layoutOptions[i].imageUrl))>
								<img src="#layoutOptions[i].imageUrl#" onclick="#arguments.fieldName#_loadSelection('#currOptionName#');" />
							</cfif>
						</label>
					</div>
				</cfloop>
			</cfif>
		</div>
		<br style="clear: both;">
	</cfoutput>
</cffunction>

<cffunction name="renderStyles" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">

	<cfoutput>
		<style type="text/css">
			.imageChoice{
				width: 143px;
				margin: 2px;
				float: left;
			}
			.imageChoice input{
				text-align: center;
			}
			.imageChoice img{
				background-color: ##c0c0c0;
				width: 100px;
				height: 120px;
				border: 1px ##c0c0c0 solid;
			}
			.imageChoice span{
				font-size: 9px;
			}
			.imageChoiceMsg {
				font-style: italic;
			}
		</style>
	</cfoutput>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfoutput>
<script type="text/javascript">
<!--
function #arguments.fieldName#_loadSelection(optionName) {
	var fieldOptionName = "input###arguments.fieldName#_" + optionName;
	// Set the current options radio button to selected
	jQuery(fieldOptionName).attr("checked", "checked");
}
//-->
</script>
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

		if ( NOT StructKeyExists(inputParameters, "layoutScript") )
			inputParameters.layoutScript = "";

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

			// If there are no sections in the ini file, return a single level struct of name=value pairs
			if ( StructIsEmpty(sections) )
			{
				return parseSimpleINI(iniPath=arguments.iniPath);
			}

			for (section in sections)
			{
				retData[section] = {};
				for (prop in listToArray(sections[section]))
				{
					// PT GAC - Make sure props that start with pounds are not included
					if ( Left(prop,1) NEQ "##" )
						retData[section][prop] = getProfileString(arguments.iniPath, section, prop);
				}
			}

			return retData;
		}
		catch( java.io.FileNotFoundException e )
		{
			throw(type="layout_configurator.parseINI.filenotfound", message="Ini file not found in path '#arguments.iniPath#'");
		}
		catch (any e)
		{
			throw(type="layout_configurator.parseINI.error", message=e.getMessage());
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
	// Requires a Build of CommonSpot 10 higher than 10.0.0.313
	public numeric function getMinHeight()
	{
		if (structKeyExists(arguments.parameters, "heightValue") && isNumeric(arguments.parameters.heightValue) && arguments.parameters.heightValue > 0)
			return arguments.parameters.heightValue; // always px
		return 0;
	}

	// Requires a Build of CommonSpot 10 higher than 10.0.0.313
	public numeric function getMinWidth()
	{
		if ( structKeyExists(arguments.parameters, "widthValue") && isNumeric(arguments.parameters.widthValue) && arguments.parameters.widthValue > 0)
			return arguments.parameters.widthValue + 160; // 150 is default label width, plus some slack // always px
		return 0;
	}
	
	private boolean function isMultiline()
	{
		return true;
	}

	/*
		IMPORTANT: Since loadResourceDependencies() is using ADF.scripts loadResources methods, getResourceDependencies() and
		loadResourceDependencies() must stay in sync by accounting for all of required resources for this Custom Field Type.
	*/
	public void function loadResourceDependencies()
	{
		// Load registered Resources via the ADF scripts_2_0
		application.ADF.scripts.loadJQuery();
	}
	public string function getResourceDependencies()
	{
		return "jQuery";
	}
</cfscript>

</cfcomponent>