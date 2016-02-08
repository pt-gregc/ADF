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
	presaveform_1_0.cfc
Summary:
	Pre Save Form Hook for the ADF Library
Version:
	1.0
History:
	2014-07-25 - GAC - Created
	2014-09-16 - GAC - Cleaned up and removed debug code
	2015-01-09 - GAC - Updated comments and removed output=false from function tags
--->
<cfcomponent displayname="presaveform_1_0" extends="ADF.core.Base" hint="Pre Save Form Hook functions for the ADF Library">

<cfproperty name="version" value="1_0_2">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="PreSaveForm_1_0">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$preSaveDataCompare
Summary:
	A utility to compare the data coming from the pre-form-save-hook.cfm with the data
	saved in the custom element
Returns:
	Struct
Arguments:
	struct - InputData
History:
	2014-07-07 - GAC - Added
--->
<cffunction name="preSaveDataCompare" access="public" returntype="struct">
	<cfargument name="InputData" type="struct" required="true">
	
	<cfscript>
		var retData = StructNew();
		var newRecord = false;
		var dSame = true; 	// Data is the Same Flag
		var fSame = true;   // Fields are the same Flag
		var ceObj = Server.CommonSpot.ObjectFactory.getObject("CustomElement");	
		var curSavedData = StructNew();
		var fldsQry = QueryNew("temp");
		var fldList = "";
		var fldListLen = 0;
		var formID = 0;
		var dataPageID = 0;
		var i = 1;
		var x = 1;
		var fld = "";
		var fldsAssocArray = StructNew();
		var changedFieldDataArray = ArrayNew(1);
		var missingFieldsArray = ArrayNew(1);
		var fic_formid_fieldid = "";
		
		// Set the FormID from the formID or the controlTypeID from the InputData Struct
		if ( StructKeyExists(arguments.InputData, 'formID') AND IsNumeric(arguments.InputData.formID) )
			formID = arguments.InputData.formID;
		else if ( StructKeyExists(arguments.InputData, 'controlTypeID') AND IsNumeric(arguments.InputData.controlTypeID) )
			formID = arguments.InputData.controlTypeID;
		
		// Get the dataPageID from the InputData structure
		if ( StructKeyExists(arguments.InputData, 'dataPageID') )
			dataPageID = arguments.InputData.dataPageID;
		else if ( StructKeyExists(arguments.InputData, 'PageID') )
			dataPageID = arguments.InputData.pageid;

		// Make sure we have a Valid FormID before going to all this work
		if ( formID GT 0 )
		{
			// Get the current data for the element record
			curSavedData = application.ADF.ceData.getElementInfoByPageID(dataPageID, formID);
			if ( StructKeyExists(curSavedData,"values") )
			{		
				fldList = StructKeyList( curSavedData.values );
				fldListLen = ListLen( fldList );
			}	
		
			// Get the field name for this element using the CMD API CustomElement object
			fldsQry = ceObj.GetFields( formID );	
								
			// build assoc array of fields keyed by fieldname
			for( x=1; x LTE fldsQry.recordCount; x=x+1 )
			{
				fld = ReplaceNoCase( fldsQry.Name[x], 'FIC_', '', 'ALL' );
				fldsAssocArray[fld] = fldsQry.ID[x];
			}
		}

		// reset fld variable
		fld = "";
		
		// Loop over the fields	
		for( i=1; i LTE fldListLen; i=i+1 )
		{
			fld = ListGetAt(fldList, i);
			
			if( StructKeyExists(fldsAssocArray,fld) )
			{
				if ( isNumeric(dataPageID) AND dataPageID GT 0 )
				{
					// Build the FIC field name
					fic_formid_fieldid = 'FIC_#formID#_#fldsAssocArray[fld]#';
					
					// check if the values exist
					if ( StructKeyExists( curSavedData.values, fld) AND StructKeyExists( arguments.InputData,fic_formid_fieldid) )
					{
						if ( curSavedData.values[fld] NEQ arguments.InputData[fic_formid_fieldid])
						{								
							dSame = false;
							ArrayAppend(changedFieldDataArray,fld);
						}
					}
					else if ( StructKeyExists( curSavedData.values,fld) AND curSavedData.values[fld] NEQ "" )
					{							
						dSame = false;
						ArrayAppend(changedFieldDataArray,fld);
					}
				}
			}
			else
			{
				fSame = false;
				ArrayAppend(missingFieldsArray,fld);
			}	
		}
		
		// For a NEW Record reset the data compare values
		if ( !IsNumeric(dataPageID) OR dataPageID LTE 0 ) 
		{
			dSame = false;
			changedFieldDataArray = ArrayNew(1);
			newRecord = true;
		}

		retData.ChangedDataFields = changedFieldDataArray;
		retData.MissingFields = MissingFieldsArray;
		retData.FieldsMatch = fSame;
		retData.DataMatch = dSame;
		retData.newRecord = newRecord;
		
		return retData;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$preSaveFieldDataCompare
Summary:
	Compare data being passed in via the InputData parameter with the
	data current stored in the field
Returns:
	Struct
Arguments:
	struct - InputData
	String - fieldNameOrID
History:
	2014-07-09 - GAC - Added
--->
<cffunction name="preSaveFieldDataCompare" access="public" returntype="struct">
	<cfargument name="InputData" type="struct" required="true">
	<cfargument name="fieldNameOrID" type="string" required="true"> 
	
	<cfscript>
		var retData = StructNew();
		var newRecord = false;
		var dSame = true; 	// Data is the Same Flag
		var fSame = true;   // Fields are the same Flag
		var ceObj = Server.CommonSpot.ObjectFactory.getObject("CustomElement");
		var inputFieldData = "";
		var curSavedData = StructNew();
		var curSavedFieldData = "";
		var defaultFields = StructNew();
		var formID = 0;
		var dataPageID = 0;
		var FieldName = "";
		var FieldID = 0;
		var fic_formid_fieldid = "";
		var missingFieldsArray = ArrayNew(1);

		// Set the FormID from the formID or the controlTypeID from the InputData Struct
		if ( StructKeyExists(arguments.InputData, 'formID') AND IsNumeric(arguments.InputData.formID) )
			formID = arguments.InputData.formID;
		else if ( StructKeyExists(arguments.InputData, 'controlTypeID') AND IsNumeric(arguments.InputData.controlTypeID) )
			formID = arguments.InputData.controlTypeID;
		
		// Get the dataPageID from the InputData structure
		if ( StructKeyExists(arguments.InputData, 'dataPageID') )
			dataPageID = arguments.InputData.dataPageID;
		else if ( StructKeyExists(arguments.InputData, 'PageID') )
			dataPageID = arguments.InputData.pageid;
		
		if ( IsNumeric(arguments.fieldNameOrID) )
		{
			FieldID = arguments.fieldNameOrID;
			FieldName = application.ADF.fields.getCEFieldName(ceNameOrID=formID,FieldID=FieldID);
		}
		else
		{
			FieldName = arguments.fieldNameOrID;
			FieldID = application.ADF.fields.getCEFieldId(ceNameOrID=formID,fieldName=FieldName);
		}

		// Make sure we have a Valid FormID and FieldID before going to all this work
		if ( formID GT 0 AND FieldID GT 0 )
		{
			
			// Build the FIC_FORMID_FIELDID key
			fic_formid_fieldid = 'FIC_#formID#_#FieldID#';
			
			// Get the data from the inputData Struct
			if ( StructKeyExists(arguments.InputData, fic_formid_fieldid) )
				inputFieldData = arguments.InputData[fic_formid_fieldid];
			else
			{
				fSame = false;
				ArrayAppend(missingFieldsArray,fic_formid_fieldid); 
			}
			
			if ( dataPageID GT 0 )
			{
				// Get the current data for the element record
				curSavedData = application.ADF.ceData.getElementInfoByPageID(dataPageID, formID);
				if ( StructKeyExists(curSavedData,"values") AND StructKeyExists(curSavedData.values, FieldName) )	
					curSavedFieldData = curSavedData.values[fieldName];
				else 
				{
					fSame = false; 
					ArrayAppend(missingFieldsArray,fieldName);
				}
			}
			else
			{
				// Get the field name for this element using the CMD API CustomElement object
				fldsQry = ceObj.GetFields( formID );	
				
				if ( NOT StructKeyExists(fldsQry, FieldName) )
					fSame = false; 
					
				dSame = false;
				newRecord = true;	
			}
			
			// Check if the values from the Save data and the input data are the same for this field
			if ( fSame EQ true AND inputFieldData EQ curSavedFieldData )
				dSame = true;
			else
				dSame = false;	
		}

		retData.MissingFields = missingFieldsArray;
		retData.FieldsMatch = fSame;
		retData.DataMatch = dSame;
		retData.newRecord = newRecord;

		return retData;
	</cfscript>
</cffunction>

</cfcomponent>