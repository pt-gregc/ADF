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
Custom Field Type:
	Object List Builder
Name:
	object_list_builder_base.cfc
Summary:
	This is the base component module for Object List Builderr field
History:
	2015-04-17 - SU/SFS - Created
	2015-04-24 - GAC - Updated the default ResultsJSONFilePath so it would point to a temp site level directory 
					       so it would NOT write the temp json files in the /ADF directory
	2016-02-22 - GAC - Updated to set the UI Theme via CFT props
					 	  - Moved JS resource loading to the render.cfc to the loadResourceDependencies() method
	2016-20-25 - GAC - In the renderStyles method added load once protection around the loadUnregisteredResource loading
						  - Removed obsolete tr/td tags used with pre-CS10 forms
						  - Added a field specific style fix full-width field rendering issue
--->
<cfcomponent output="false" displayname="ObjectListBuilder" extends="ADF.core.Base" hint="This is the base component for the ObjectListBuilder custom field type">
	
<cfscript>
	// Path to this CFT
	variables.cftPath = "/ADF/extensions/customfields/object_list_builder"; // path to the ObjectListBuilder custom field type
	variables.ceID = ""; // ID of source customElement
	variables.customElement = ""; // Name of the source customElement
	variables.searchFields = ""; // Searchable fields in source customElement, used by bloodhound and typeahead in the ObjectListBuilder dialog
	variables.IDField = ""; // UniqueID in the source customElement
	variables.orderByClause = ""; // source customElement column. This should be present in variables.columnList and variables.searchFields
	variables.ResultsJSONFilePath = "#request.site.csAppsWebURL#customfields/temp/"; // temp/working directory - will auto-create the needed directories if they don't exist
	variables.ResultsJSONFile = "objectListBuilderResults"; // prefix for the JSON file used by bloodhound and typeahead.
	variables.listFormatsXMLFile = "listFormats"; // file where all of the formats are defined in editor
	variables.listFormatsXMLFilePath = "#variables.cftPath#";
	variables.columnList = ""; // columns from the source customElement.
	
	// CFT Style File Path variables
	variables.cftStyleFilePath = variables.cftPath & "/object_list_builder_styles.css";
	variables.cftListFormatFilePath = variables.cftPath & "/plugins/listformat/css/listformat.css";
</cfscript>

<!------------------------------------------------------>	
<!---// PUBLIC FUNCTIONS //----------------------------->	
<!------------------------------------------------------>		

<!-------------------------------------------
	parse()
------------------------------------------->			
<cffunction name="parse" access="public" returntype="any" hint="Method that converts saved data to ckEditor input format">	
	<cfargument name="data" type="string" required="yes" hint="Data retrieved from database">	
	<cfscript>
		var renderData = ReplaceList(arguments.data, '&amp;,&quot;,&lt;,&gt;', '&,",<,>');
		var curStruct = StructNew();
		var curID = "";
		var curFormat = "";
		var curAttribs = [];
		var newStr = "";
		var curTagPos =1;
		var j = 1;		
		var ret = structnew();
		var resolvedStr = "";
		var wrapTag = 'div';
		var spacer = "&nbsp;";
		var formatStruct = StructNew();
		var updatedData = renderData;
		var tagTools = CreateObject("java","com.paperthin.common.html.TagTools").init(Server.CommonSpot.UDF.util.getBean(""));
		var tagInfo = tagTools.FindTags(renderData,"beanName,id,format,ELEMENT");

		for (curTagPos=1; curTagPos le arrayLen(tagInfo); curTagPos=curTagPos+1)
		{
			curStruct = tagInfo[curTagPos];
			if (lcase(curStruct.tagName) eq "cpmodule" AND 
						structKeyExists(curStruct, "TagAttrs"))
			{
				curAttribs = curStruct.TagAttrs;
				if (StructKeyExists(curAttribs, "id") AND 
								StructKeyExists(curAttribs, "format") AND
								StructKeyExists(curAttribs, "beanName")
					)
				{
					curID = curAttribs.id;
					curFormat = curAttribs.format;
					formatStruct = deserializeJSON(getFormats(format=curFormat));
					//return formatStruct;
					if (StructKeyExists(formatStruct, 'wrapperTag'))
						wrapTag = formatStruct['wrapperTag'];
					else
						wrapTag = 'div';	
					resolvedStr = renderItem(id=curID, format=curFormat);
					// '<div contenteditable="false" class="placeholderWrapper" id="DIV_' + data.id + '"><div class="placeholder" id="PL_' + data.id + '" data-format="' + format + '">' + data.innerHTML + '</div></div>';
					newStr = '<#wrapTag# contenteditable="false" class="placeholderWrapper" id="DIV_#curID#" onfocus="editor.plugins.listformat.checkListFormat(''#curFormat#'');"><#wrapTag# class="placeholder" id="PL_#curID#" data-format="#curFormat#">#resolvedStr#</#wrapTag#></#wrapTag#>#spacer#';
					origStr = curStruct.OriginalTag;
					tagInfo[curTagPos].ReplacementText = newStr;
					//updatedData = ReplaceNoCase(updatedData, origStr, newStr, "ONE");
				}
			}
		}
		updatedData = Server.CommonSpot.UDF.tagTools.RebuildRTEBlock(renderData,tagInfo);
		updatedData = ReplaceNoCase(updatedData, "&nbsp; </CPMODULE>", "#spacer#", "ALL");
		updatedData = ReplaceNoCase(updatedData, "&nbsp;</CPMODULE>", "", "ALL");
		//return data;
		return updatedData;
	</cfscript>
</cffunction>	
	
<!-------------------------------------------
	getResultsList()
------------------------------------------->		
<cffunction name="getResultsList" returnType="any" access="remote" hint="Method to get the result rows based on search criteria">		
   <cfargument name="searchString" type="string" required="no" default="" hint="Search criteria for the custom element records">
	<cfscript>
		var renderData = '';
		var filteredResults = Request.TypeFactory.getStruct("Form_PivotRecords_Results");
		var sqlRes = '';
		var resArr = [];
		var serializedResults = "";
		var i = 0;
		var whereClause = "";
		var ceObj = Server.CommonSpot.ObjectFactory.getObject("CustomElement");
		var qry = ceObj.getRecordsFromFilter(elementID=variables.ceID, filterid="0_0_#variables.ceID#_#Request.user.ID#", columnList=variables.columnList, showDisplayValues=1);
		var results = qry.ResultQuery;	
	</cfscript>

	<cfif arguments.searchString neq "">
		<cfsaveContent variable="whereClause">
			<cfoutput> AND (</cfoutput>
			<cfloop from=1 to="#ListLen(variables.searchFields)#" index="i">
			<cfoutput>#ListGetAt(variables.searchFields,i)# LIKE '%#arguments.searchString#%'</cfoutput> 
				 <cfif i lt ListLen(variables.searchFields)>
				<cfoutput> OR </cfoutput>
				 </cfif>
			</cfloop>
			<cfoutput>)</cfoutput>
		</cfsavecontent>
	</cfif>
	
	<cfquery name="filteredResults" dbtype="query">
		SELECT #variables.columnList#
		  FROM results
		  <cfif whereClause neq "">
		 WHERE 1=1
		 #preserveSingleQuotes(whereClause)#
		 </cfif>
		 ORDER BY #variables.orderByClause#
	</cfquery>	

	<cfset application.adf.utils.logappend(msg=filteredResults, logfile='debugOLBB.html', label='filteredResults')>

	<cfscript>
		serializedResults = serializeJSON(filteredResults);
		//writeJSONFile(serializedResults);
		return serializedResults;
	</cfscript>		
</cffunction>
	
<!-------------------------------------------
	getFormats()
------------------------------------------->		
<cffunction name="getFormats" access="remote" returntype="any" hint="Method to read formats from XML file">
	<cfargument name="format" type="string" required="no" default="" hint="specific format to return">
	<cfargument name="isDefaultFilter" type="string" required="no" default="" hint="1 or 0 or empty string (default) for all results">
	<cfscript>
		var filePath = '#ExpandPath(variables.listFormatsXMLFilePath)#/#variables.listFormatsXMLFile#.xml';
		var formats = "";
		var formatData = "";
		var index = 0;
		var returnData = structNew();
		returnData.formatData = ArrayNew(1);
	</cfscript>
	
	<cftry>
		<cffile action="read" file="#filePath#" variable="formats">
		<cfcatch>
			<cfscript>
				application.ADF.utils.logAppend(cfcatch, "objectListBuilder-Errors.html");
				returnStruct.msg = "Unable to open file.#filePath#- #cfcatch.detail#";
				return returnStruct;
			</cfscript>
		</cfcatch>
	</cftry>	
	
	<cfscript>
		formatData = server.Commonspot.UDF.util.deserialize(formats);
		
		if (arguments.format eq "" AND arguments.isDefaultFilter eq "")
			returnData = formatData;

		for (index=1; index le arrayLen(formatData); index=index+1)
		{
			if (arguments.format neq "")
			{
				if (formatData[index]['formatName'] eq arguments.format)
					returnData = formatData[index];
			}
			
			if (arguments.isDefaultFilter neq "")
			{
				if (formatData[index]['isDefault'] eq arguments.isDefaultFilter)
					returnData = formatData[index];
			}
		}
		return serializeJSON(returnData);
	</cfscript>
	
</cffunction>

<!-------------------------------------------
	getListFormatsXMLFile()
------------------------------------------->	
<cffunction name="getListFormatsXMLFile" access="public" returntype="string" hint="Method to return the name of the listFormatsXML file">
	<cfreturn variables.listFormatsXMLFile>
</cffunction>

<!-------------------------------------------
	getListFormatsXMLFilePath()
------------------------------------------->	
<cffunction name="getListFormatsXMLFilePath" access="public" returntype="string" hint="Method to return the path of the listFormatsXML file">
	<cfreturn variables.listFormatsXMLFilePath>
</cffunction>

<!-------------------------------------------
	getResultsJSONFile()
------------------------------------------->	
<cffunction name="getResultsJSONFile" access="public" returntype="string" hint="Method to return the name of the JSON results file">
	<cfreturn variables.ResultsJSONFile>
</cffunction>

<!-------------------------------------------
	getResultsJSONFilePath()
------------------------------------------->	
<cffunction name="getResultsJSONFilePath" access="public" returntype="string" hint="Method to return the path of the JSON results file">
	<cfreturn variables.ResultsJSONFilePath>
</cffunction>

<!-------------------------------------------
	renderItem()
------------------------------------------->	
<cffunction name="renderItem" access="remote" returntype="any" hint="Method to render item in the given format">
	<cfargument name="format" type="string" required="true" hint="Format in which item should be displayed">
	<cfargument name="id" type="string" required="true" hint="Id of the record">
	<cfscript>
		var renderData = '';
		var newstr = "";
		var str = "";
		var tempStr = "";
		var curItem = StructNew();
		var i = 0;
		var cleanstr = "";
		var startCharPos = 1;
		var replaceStrings = [];
		var posStruct = StructNew();
		var curString = "";
		var curStructure = "";		
		var record = application.ADF.ceData.getCEData(variables.customElement, '#variables.IDField#', arguments.id);
		var resultRow = "";

		//application.adf.utils.logappend(msg="<p>base.cfc - renderItem - line 211 - getCEData('#variables.customElement#', '#variables.IDField#', #arguments.id#)</p>", logfile='debugPDFRH.html');
		//application.adf.utils.logappend(msg=arguments, logfile='debugPDFRH.html', label="base.cfc - renderItem - line 212 - arguments");
		//application.adf.utils.logappend(msg=variables, logfile='debugPDFRH.html', label="base.cfc - renderItem - line 213 - variables");
		//application.adf.utils.logappend(msg=record, logfile='debugPDFRH.html', label="base.cfc - renderItem - line 214 - record");
		/*application.adf.utils.logappend(msg="fldName: #fldName#", logfile='debugPDFRH.html');*/
		
		if (isArray(record) and (arrayLen(record) GTE 1))
			resultRow = record[1]['values'];
			
		if (arguments.format neq "")
			renderFormat = deserializeJSON(getFormats(format=arguments.format));
		else if (arguments.useDefault eq 1)
			renderFormat = deserializeJSON(getFormats(isDefaultFilter=1));		
				
		curStructure = renderFormat['structure'];	
		newStr = curStructure;	
		
		while (startCharPos LT Len(curStructure))
		{
			posStruct = REFindNoCase("{([a-z]+[a-z0-9]*)}", curStructure, startCharPos, true);
			if (posStruct.pos[1] NEQ 0)
			{
				startCharPos = posStruct.pos[1] + posStruct.len[1];
				tempstr = Mid(curStructure, posStruct.pos[1], posStruct.len[1]);
				cleanstr = Replace(tempstr,"{","");
				cleanstr = Replace(cleanstr,"}","");
				curString = "#tempstr#^#cleanstr#";
				arrayAppend(replaceStrings,curString);
			}
			else
				startCharPos = Len(curStructure);
		}	
	</cfscript>
	
	<cfsavecontent variable="resultHTML">
		<cfscript>
			newStr = curStructure;	
			for (i=1; i le arrayLen(replaceStrings); i=i+1)
			{
				str = replaceStrings[i];
				tempstr = ListGetAt(str,1,"^");
				cleanstr = ListGetAt(str,2,"^");
				cleanstr = resultRow[cleanstr];
				newStr = Replace(newStr, tempstr, cleanstr);
			}
		</cfscript>
		<cfoutput>#newstr#</cfoutput>
	</cfsavecontent>
	<cfreturn resultHTML>	
	
</cffunction>

<!------------------------------------------------------>	
<!---// HELPER FUNCTIONS //----------------------------->	
<!------------------------------------------------------>		

<!-------------------------------------------
	writeJSONFile()
------------------------------------------->
<cffunction name="writeJSONFile" access="public" returnType="void" hint="writes the json readable by typeahead plugin of jquery">
	<cfargument name="pageID" type="numeric" required="no" default="0">
	<cfargument name="controlID" type="numeric" required="no" default="0">
	<cfscript>
		var JSONFileName = "";
		var JSONFileDir = ExpandPath(variables.ResultsJSONFilePath);
		var ceObj = Server.CommonSpot.ObjectFactory.getObject("CustomElement");
		var qry = ceObj.getRecordsFromFilter(elementID=variables.ceID, filterid="0_0_#variables.ceID#_#Request.user.ID#", columnList=variables.searchFields, showDisplayValues=1);		
		var i = 0;
		var curVal = "";
		var jsonArr = [];
		var resString = "";
		var curArr = [];
		var curStruct = Structnew();
		var resultsQry = qry.ResultQuery;
		var fieldsArr = ListToArray(variables.searchFields);
		var colLen = 1;
		var curCol = '';
		var javaFileOp = '';
		
		// If CFT JSON Working/Temp Directory doesn't exist run the java file operation to create the if needed
		if ( !DirectoryExists(JSONFileDir) )
		{
			javaFileOp = CreateObject("java", "java.io.File").init(JSONFileDir);
			javaFileOp.mkdirs();
		}
		
		JSONFileName = JSONFileDir & "/#variables.ResultsJSONFile#_#arguments.pageID#_#arguments.controlID#.json";
	</cfscript>
	
	<cfloop from=1 to="#resultsQry.RecordCount#" index="i">
		<cfloop from=1 to="#arrayLen(fieldsArr)#" index="colLen">
			<cfscript>
				curCol = lcase(fieldsArr[colLen]);
				curVal = resultsQry[curCol][i];
				curStruct[curCol] = curVal;
			</cfscript>
		</cfloop>
		<cfscript>
			arrayAppend(jsonArr, curStruct);
			curStruct = Structnew();
		</cfscript>
	</cfloop>
	
	<cfscript>
		//return jsonArr;
		resString = serializeJSON(jsonArr);
	</cfscript>
	
	<cftry>
		<cfmodule template="/commonspot/utilities/cp-cffile.cfm"
			action="WRITE" output="#resString#" addnewline="No" file="#JSONFileName#">
		<cfcatch type="any">
			<cfscript>		
				application.ADF.utils.logAppend(application.ADF.utils.doDump(cfcatch, "cfcatch", false, true),"objectListBuilder-Errors.html");
			</cfscript>
		</cfcatch>
	</cftry>		
</cffunction>

<!-------------------------------------------
	renderStyles()

	History:
		2016-20-25 - GAC - added load once protection around the loadUnregisteredResource loading
------------------------------------------->
<cffunction name="renderStyles" access="public" returntype="void" hint="Method to render the styles for object list builder.">
	<cfscript>
		var renderData = '';
		var styleFilePath = "/object_list_builder_styles.css";
		var listFormatFilePath = "/plugins/listformat/css/listformat.css";

		// Set defaults if these variables are not set
		if ( !StructKeyExists(variables,"cftStyleFilePath") OR LEN(TRIM(variables.cftStyleFilePath)) EQ 0 )
			variables.cftStyleFilePath = variables.cftPath & styleFilePath;
		if ( !StructKeyExists(variables,"cftListFormatFilePath") OR LEN(TRIM(variables.cftListFormatFilePath)) EQ 0 )
			variables.cftListFormatFilePath = variables.cftPath & listFormatFilePath;

		if ( !StructKeyExists(Request, 'objectListBuilderCSS') )
		{
			// load cft stylesheet
			application.ADF.scripts.loadUnregisteredResource(variables.cftStyleFilePath, "Stylesheet", "head", "secondary", 0, 0);
			// load ListFormat stylesheet
			application.ADF.scripts.loadUnregisteredResource(variables.cftListFormatFilePath, "Stylesheet", "head", "secondary", 0, 0);
			Request.objectListBuilderCSS = 1;
		}
	</cfscript>
	
	<!--- // Dynamic field specific CCS override --->
	<cfsavecontent variable="cftOlbFldCSS">
	<cfoutput>
	<style>
		###arguments.fieldDomID#_controls {
		  display: block;
		  width: 950px;
		  max-width: 1000px !important;
		}
	</style>
	</cfoutput>
	</cfsavecontent>
	
	<cfscript>
		// Load the dynamic CSS for the field
		application.ADF.scripts.addHeaderCSS(cftOlbFldCSS, "SECONDARY"); //  PRIMARY, SECONDARY, TERTIARY
	</cfscript>
</cffunction>

<!-------------------------------------------
	renderJS()
------------------------------------------->
<cffunction name="renderJS" access="public" returntype="void" hint="Method to render the styles for object list builder.">
	<!---
		// IMPORTANT: The JS code that was loading here has all been moved to load via CommonSpot Resources. 
		//             See loadResourceDependencies() and  getResourceDependencies() in the render.cfc file
	--->
</cffunction>

<!-------------------------------------------
	getCFTStyleFilePath()
------------------------------------------->	
<cffunction name="getCFTStyleFilePath" access="public" returntype="string" hint="Method to return the CFT CSS Style file path">
	<cfreturn variables.cftStyleFilePath>
</cffunction>

<!-------------------------------------------
	getCFTListFormatFilePath()
------------------------------------------->	
<cffunction name="getCFTListFormatFilePath" access="public" returntype="string" hint="Method to return the CFT ListFormat.xml file path">
	<cfreturn variables.cftListFormatFilePath>
</cffunction>

</cfcomponent>