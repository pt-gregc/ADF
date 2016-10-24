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
Name:
	ceData_3_0.cfc
Summary:
	Custom Element Data functions for the ADF Library
Version
	2.1
History:
	2015-08-31 - GAC - Created
--->
<cfcomponent displayname="ceData_3_0" extends="ceData_2_0" hint="Custom Element Data functions for the ADF Library">

<cfproperty name="version" value="3_0_1">
<cfproperty name="type" value="singleton">
<cfproperty name="data" type="dependency" injectedBean="data_2_0">
<cfproperty name="wikiTitle" value="CEData_3_0">

<cfscript>
	variables.SQLViewNameADFVersion = "2.0";
</cfscript>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$convertFICDataValuesToCEData
Summary:
	Returns a CEData Array of Structs from a FIC_ field data struct
Returns:
	Array
Arguments:
	Struct - ficDataValues
Usage:
	application.ADF.ceData.convertFICDataValuesToCEData(ficDataValues)
History:
	2016-10-19 - GAC - Created
--->
<cffunction name="convertFICDataValuesToCEData" access="public" returntype="array">
	<cfargument name="ficDataValues" required="false" type="struct" default="#StructNew()#">

	<cfscript>
		var retArray = ArrayNew(1);
		var ceData = StructNew();
		var key = "";
		var fldName = "";
		var fldValue = "";
		var ficFieldNameKey = "";
		var ficFieldValueKey = "";

		ceData.values = StructNew();
		ceData.formid = 0;
		ceData.pageID = 0;

		// Set the Element ID from the formID or the controlTypeID
		if ( StructKeyExists(arguments.ficDataValues, 'controlTypeID') )
			ceData.formid = arguments.ficDataValues.controlTypeID;
		else if ( StructKeyExists(arguments.ficDataValues, 'FormID')	)
			ceData.formid = arguments.ficDataValues.FormID;

		// Set the Data Page ID from the dataPageID or the PageID
		if( StructKeyExists(arguments.ficDataValues, 'dataPageID') )
			ceData.pageID = arguments.ficDataValues.dataPageID;
		else if( StructKeyExists(arguments.ficDataValues, 'savePageID') )
			ceData.pageID = arguments.ficDataValues.savePageID;
		else if( StructKeyExists(arguments.ficDataValues, 'pageID') )
			ceData.pageID = arguments.ficDataValues.pageID;

		for ( key IN arguments.ficDataValues)
		{
			if ( FindNoCase('FIC_', key, 1) AND !FindNoCase('_FIELDNAME', key, 1) )
			{
				ficFieldNameKey = key & '_FIELDNAME';
				ficFieldValueKey = key;

				fldName = "";
				fldValue = "";

				if ( StructKeyExists(arguments.ficDataValues,ficFieldNameKey) )
					fldName = arguments.ficDataValues[ficFieldNameKey];
				if ( StructKeyExists(arguments.ficDataValues,ficFieldNameKey) )
					fldValue = arguments.ficDataValues[ficFieldValueKey];

				if ( LEN(TRIM(fldName)) AND !StructKeyExists(ceData.values,fldName) )
					ceData.values[fldName] = fldValue;
			}
		}

		retArray[1] = ceData;

		return retArray;
	</cfscript>
</cffunction>

</cfcomponent>