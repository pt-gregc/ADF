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
	data_2_0.cfc
Summary:
	Data Utils component functions for the ADF Library
Version:
	2.0
History:
	2015-08-31 - GAC - Created
*/
component displayname="data_2_0" extends="data_1_2" hint="Data Utils component functions for the ADF Library" output="no"
{
    /* PROPERTIES */
	property name="version" type="string" default="2_0_2";
	property name="type" value="singleton";
	property name="wikiTitle" value="Data_2_0";

	/*
		Author:
			PaperThin, Inc.
		Name:
			$listDiffExtended
		Summary:
			Compares a old list to a new list and returns a struct of added, deleted, and matched values
		Returns:
			Struct
				added
				deleted
				matched
		Arguments:
			String - oldlist
			String - newlist
			String - delimiters
		History:
			2016-08-26 - GAC - Created
	*/
	public struct function listDiffExtended(string oldlist="", string newlist="", string delimiters=",")
	{
		var listData = StructNew();
		var i = 1;
		var newItem = "";

		listData.added = "";
		listData.deleted = "";
		listData.matched = "";

		// Loop over NewList to get deleted items (no need to get matched items)
		for (i=1; i LTE ListLen(arguments.newlist,arguments.delimiters); i=i+1)
		{
			newItem = ListGetAt(arguments.newlist, i,arguments.delimiters);

			// Check Old List for new items
			if ( ListFindNoCase(arguments.oldlist, newItem , arguments.delimiters) )
			{
				// the NewItem already Exists... so add it to the matched list
				if ( ListFindNoCase(listData.matched, newItem, arguments.delimiters) EQ 0 )
					listData.matched = ListAppend(listData.matched, newItem, arguments.delimiters);
			}
			else
			{
				// the NewItem was NOT found... so add it to the added list
				if ( ListFindNoCase(listData.added, newItem, arguments.delimiters) EQ 0 )
					listData.added = ListAppend(listData.added, newItem, arguments.delimiters);
			}
		}

		// Loop over OldList to get deleted items (no need to get matched items)
		for (i=1; i LTE ListLen(arguments.oldlist,arguments.delimiters); i=i+1)
		{
			oldItem = ListGetAt(arguments.oldlist, i,arguments.delimiters);
			
			// Check Old List for new items
			if ( ListFindNoCase(arguments.newlist, oldItem , arguments.delimiters) EQ 0 )
			{
				// the OldItem was NOT found... so add it to the deleted list
				if ( ListFindNoCase(listData.deleted , oldItem, arguments.delimiters) EQ 0 )
					listData.deleted = ListAppend(listData.deleted , oldItem, arguments.delimiters);
			}
		}

		return listData;
	}
}