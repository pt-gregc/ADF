<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2011.
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
	data_1_1.cfc
Summary:
	Data Utils component functions for the ADF Library
Version:
	1.1.0
History:
	2011-01-25 - MFC - Created - New v1.1
--->
<cfcomponent displayname="data_1_1" extends="ADF.lib.data.data_1_0" hint="Data Utils component functions for the ADF Library">

<cfproperty name="version" value="1_1_0">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Data_1_1">

<!---
/* ***************************************************************
/*
Author: 	Dave Merril
Name:
	$queryRowToStruct
Summary:
	Returns a struct w requested data from a requested query row.
Returns:
	Struct
Arguments:
	query - query
	rowNum - numeric
	colsList - string
	LCaseNames - boolean
	targetStruct - struct
History:
	2010-11-17 - RAK - Brought in Dave Merril's queryRowToStruct for use in ADF
--->
<cffunction name="queryRowToStruct" hint="Returns a struct w requested data from a requested query row." output="no" returntype="struct" access="public">
	<cfargument name="query" type="query" required="yes">
	<cfargument name="rowNum" type="numeric" default="1" required="no">
	<cfargument name="colsList" type="string" default="#arguments.query.ColumnList#" required="no">
	<cfargument name="LCaseNames" type="boolean" default="yes" required="no">
	<cfargument name="targetStruct" type="struct" default="#StructNew()#" required="no">
	<cfscript>
		var s = arguments.targetStruct;
		var aCols = '';
		var i = 0;
		var count = 0;
		
		if (arguments.LCaseNames)
			arguments.colsList = LCase(arguments.colsList);
		aCols = ListToArray(arguments.colsList);
		count = ArrayLen(aCols);
		for (i = 1; i lte count; i = i + 1)
			s[aCols[i]] = arguments.query[aCols[i]][arguments.rowNum];
		return s;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$arrayOfStructToXML
Summary:
	Given an array of structures return an xml version
Returns:
	xml
Arguments:

History:
 	Dec 1, 2010 - RAK - Created
--->
<cffunction name="arrayOfStructToXML" access="public" returntype="xml" hint="Given an array of structures return an xml version">
	<cfargument name="arrayOfStruct" type="array" required="true" default="" hint="Array of structures to be converted to XML data">
	<cfargument name="rootName" type="string" required="false" default="root" hint="Name of the root element to wrap all the xml data">
	<cfargument name="nodeName" type="string" required="true" default="node" hint="Default name of each of the nodes within arrays">
	<cfscript>
		var rtnXML = XmlNew();
		var i = 1;
		rtnXML.xmlRoot = XmlElemNew(rtnXML,arguments.rootName);
		for(i=1;i<=ArrayLen(arrayOfStruct);i = i +1){
			rtnXML[arguments.rootName].XmlChildren[i] = XmlElemNew(rtnXML,arguments.nodeName);
			
		}
	</cfscript>
</cffunction>

</cfcomponent>