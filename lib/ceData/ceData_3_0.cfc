/*
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
*/

/* *************************************************************** */
/*
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
		2016-12-05 - GAC - Converted to a cfscript style component
*/
component displayname="ceData_3_0" extends="ceData_2_0" hint="Custom Element Data functions for the ADF Library"
{
    /* PROPERTIES */
	property name="version" type="string" default="3_0_2";
	property name="type" value="singleton";
	property name="data" type="dependency" injectedBean="data_2_0";
	property name="wikiTitle" value="CEData_3_0";

	variables.SQLViewNameADFVersion = "2.0";

	/* *************************************************************** */
	/*
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
	*/
	public array function convertFICDataValuesToCEData(struct ficDataValues=StructNew())
	{
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
	}

	/* *************************************************************** */
	/*
		Author:
			PaperThin, Inc.
		Name:
			$queryToCEDataArrayOfStructures
		Summary:
			Converts a query to an array of structures nested in the values node like a ceData array of structures

			Based on data.queryToArrayOfStructures()
		Returns:
			Array
		Arguments:
			Query - queryData - "The query that will be converted into an array of structures"
			Boolean - keysToLowercase - "Use to convert struct key to lowercase"
		History:
			2016-11-16 - GAC - Created
	*/
	public array function queryToCEDataArrayOfStructures(required query queryData, boolean keysToLowercase=false)
	{
		var theArray = arraynew(1);
		var cols = ListtoArray(arguments.queryData.columnlist);
		var row = 1;
		var thisRow = StructNew();
		var col = 1;

		for ( row = 1; row LTE arguments.queryData.recordcount; row = row + 1 ){
			thisRow.formid = 0;
			thisRow.pageid = 0;
			thisRow.values = structnew();
			for(col = 1; col LTE arraylen(cols); col = col + 1)
			{
				if ( cols[col] EQ "formid" AND StructKeyExists(arguments.queryData,"formid") )
					thisRow.formid = arguments.queryData.formid[row];
				if ( cols[col] EQ "pageid" AND StructKeyExists(arguments.queryData,"pageid") )
					thisRow.pageid = arguments.queryData.pageid[row];

				if ( arguments.keysToLowercase )
					thisRow.values[lcase(cols[col])] = arguments.queryData[cols[col]][row];
				else
					thisRow.values[cols[col]] = arguments.queryData[cols[col]][row];
			}
			arrayAppend(theArray,duplicate(thisRow));
		}

		return theArray;
	}

}