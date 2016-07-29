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
	widgets_1_0.cfc
Summary:
	Widgetcomponent functions for the ADF Library
Version:
	1.0
History:
	2016-07-05 - GAC - Created
*/
component displayname="widgets_1_0" extends="ADF.lib.libraryBase" hint="Widget component functions for the ADF Library" output="no"
{
    /* PROPERTIES */
	property name="version" type="string" default="1_0_0";
	property name="type" value="singleton";
	property name="wikiTitle" value="Widgets_1_0";

	/* ***************************************************************
	Author:
		PaperThin, Inc.
	Name:
		$getWidgetConfigData
	Summary:
		Builds the widget configuration data structure from the bound ElementInfo.RenderHandlerMetaData based on the
		passed in field name.
	Returns:
		Struct
	Arguments:
		Struct - customMetdata
		String - configFieldName
	History:
		2016-07-05 - GAC - Created
	*/
	public struct function getWidgetConfigData(required struct customMetdata, required string configFieldName)
	{
		var retData = StructNew();
		var widgetObj = StructNew();
      var configFindArray = StructFindKey(arguments.customMetdata,arguments.configFieldName);

		if ( ArrayLen(configFindArray) AND StructKeyExists(configFindArray[1],"value") )
		{
			widgetObj = DeserializeJSON(TRIM(configFindArray[1].value));
			if ( StructKeyExists(widgetObj,"Data") )
				retData = widgetObj.Data;
		}

		return retData;
	}

	/* ***************************************************************
	Author:
		PaperThin, Inc.
	Name:
		$buildClassValue
	Summary:
		Builds a space delimited class string. If the passed in class is 'none' then it does not add it to the string.
	Returns:
		String
	Arguments:
		String - classStr
		String - newClass
	History:
		2016-07-05 - GAC - Created
	*/
	public string function buildClassValue(string classStr='',string newClass='')
	{
		var retData = TRIM(arguments.classStr);

		arguments.newClass = TRIM(arguments.newClass);

		if ( LEN(arguments.newClass) AND arguments.newClass NEQ "none"  )
		{
			if ( ListFindNoCase(retData,arguments.newClass," ",false) EQ 0 )
				retData = listAppend(retData,arguments.newClass," ");
		}

		return TRIM(retData);
	}

	/* ***************************************************************
	Author:
		PaperThin, Inc.
	Name:
		$calcBootstrapClearFix
	Summary:
		Calculates the clear fix struct
	Returns:
		Struct
	Arguments:
		String - classes - the bootstrap grid row layout classes
	History:
		2016-07-05 - JTP - Created
	*/
	public struct function calcBootstrapClearFix(required string classes)
	{
		var pos = 0;
		var retStruct = StructNew();

		retStruct.lg = 0;
		retStruct.md = 0;
		retStruct.sm = 0;

		pos = FindNoCase( 'sm-', arguments.classes );
		if( pos )
			retStruct.sm = Trim( Mid(arguments.classes, pos + 3, 2) );		// returns 2 digit number or 1 digit + space, which then gets trimmed

		pos = FindNoCase( 'md-', arguments.classes );
		if( pos )
			retStruct.md = Trim( Mid(arguments.classes, pos + 3, 2) );		// returns 2 digit number or 1 digit + space, which then gets trimmed
		else
			retStruct.md = retStruct.sm;

		pos = FindNoCase( 'lg-', arguments.classes );
		if( pos )
			retStruct.lg = Trim( Mid(arguments.classes, pos + 3, 2) );		// returns 2 digit number or 1 digit + space, which then gets trimmed
		else
			retStruct.lg = retStruct.md;

		return retStruct;
	}

	/* ***************************************************************
	Author:
		PaperThin, Inc.
	Name:
		$renderBootstrapClearFix
	Summary:
		Renders clear fix div when appropriate
	Returns:
		VOID
	Arguments:
		Numeric - count
		Struct - clearFixStruct
	History:
		2016-07-05 - JTP - Created
	*/
	public void function renderBootstrapClearFix(required numeric count, required struct clearFixStruct)
	{
		var remainder = '';
		var list = 'lg,md,sm';
		var i = 0;
		var cnt = 0;
		var incr = 0;
		var size = '';

		for( i=1; i lte ListLen(list); i=i+1 )
		{
			size = ListGetAt(list,i);
			if( StructKeyExists(arguments.clearFixStruct, size) )
			{
				cnt = arguments.clearFixStruct[size];
				if( cnt gt 0 )
				{
					incr = 12 / cnt;
					remainder = arguments.count MOD incr;
					if( remainder eq 0 )
						WriteOutput('<div class="clearfix visible-#size#"></div>');
				}
			}
		}
	}

}
