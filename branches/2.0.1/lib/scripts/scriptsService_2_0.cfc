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
	scriptsService_2_0.cfc
Summary:
	Scripts Service functions for the ADF Library
Version:
	2.0
History:
	2016-03-11 - GAC - Created
*/

component displayname="scriptsSevice_2_0" extends="scriptsService_1_1" hint="Scripts functions for the ADF Library" output="no"
{

	/*
		resourceAPI.save(id, name, category, earlyLoadSourceArray, lateLoadSourceArray, description, installInstructions, aliasList, redistributable);
			sourceArray: [{LoadTagType, SourceURL}]}
			LoadTagType: 1=StyleSheet 2=JavaScript
	*/

	public numeric function registerResource
	(
		required string name,
		required string category,
		required array earlyLoadSourceArray,
		required array lateLoadSourceArray,
		required string description,
		required string installInstructions,
		string aliasList="",
		boolean redistributable=0,
		boolean updateExisting=0,
		boolean silent=0
	)
	{
		var resSpecs = "";
		var action = "registered";
		var resourceAPI = Server.CommonSpot.ObjectFactory.getObject("Resource");
		var msg = "";

		arguments.id = 0;

		if (structKeyExists(Request.Site.CS_Resources.Resources_by_name, arguments.name))
		{
			resSpecs = Request.Site.CS_Resources.Resources_by_name[arguments.name];
			if (resSpecs.name != arguments.name) // registered version is an alias, can't update it
			{
				msg = "Alias with this name already exists, skipped: #arguments.name#";
				if ( !arguments.silent )
					writeOutput(msg & "<br>");
				return 0;
			}
			else if (arguments.updateExisting == 0)
			{
				msg = "Resource already exists, skipped: #arguments.name#";
				if ( !arguments.silent )
					writeOutput(msg & "<br>");
				return 0;
			}
			else
			{
				arguments.id = resSpecs.id;
				action = "updated";
			}
		}
		arguments.earlyLoadSourceArray = getResourceArray(arguments.earlyLoadSourceArray);
		arguments.lateLoadSourceArray = getResourceArray(arguments.lateLoadSourceArray);

		msg = "Resource #action#: #arguments.name#";
		if ( !arguments.silent )
			writeOutput(msg & "<br>");
		
		// returns NUMERIC ID on NEW/UPDATE
		return resourceAPI.save(argumentCollection=arguments);
	}

	private array function getResourceArray(resourceSpecsArray)
	{
		var arr = Request.TypeFactory.newObjectInstance("ResourceLoadStruct_Array");
		var count = arrayLen(arguments.resourceSpecsArray);
		var i = 0;
		for (i = 1; i <= count; i++)
			arrayAppend(arr, getResourceStruct(argumentCollection=arguments.resourceSpecsArray[i]));
		return arr;
	}

	private struct function getResourceStruct(loadTagType, sourceURL, canCombine, canMinify)
	{
		var res = Request.TypeFactory.newObjectInstance("ResourceLoadStruct");
		if (!structKeyExists(arguments, "canCombine"))
			arguments.canCombine = (left(arguments.sourceURL, 4) == "http") ? 0 : 1;
		if (!structKeyExists(arguments, "canMinify"))
			arguments.canMinify =
			(
					!arguments.canCombine
				|| findNoCase(".min", arguments.sourceURL)
				|| findNoCase("_min", arguments.sourceURL)
				|| findNoCase("-pack", arguments.sourceURL)
				|| findNoCase(".pack", arguments.sourceURL)
			) ? 0 : 1;
		res.loadTagType = arguments.loadTagType;
		res.sourceURL = arguments.sourceURL;
		res.canCombine = arguments.canCombine;
		res.canMinify = arguments.canMinify;
		return res;
	}
}