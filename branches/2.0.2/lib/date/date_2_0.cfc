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

/*  
 *************************************************************** 
Author: 	
	PaperThin, Inc. 
Name:
	date_2_0.cfc
Summary:
	Date Utils functions for the ADF Library
Version:
	2.0
History:
	2015-08-31 - GAC - Created
	2016-09-29 - GAC - Added functions to calculated the first and last days of the quarter

*/
component displayname="date_2_0" extends="date_1_2" hint="Date Utils functions for the ADF Library"
{
	property name="version" value="2_0_1";
	property name="type" value="singleton";
	property name="wikiTitle" value="Date_2_0";

	/*
		Author:
			PaperThin, Inc.
		Name:
			$firstDayOfQuarter
		Summary:
			Returns date for first day of the quarter for the provided month/year
		Returns:
			Date
		Arguments:
			Numeric - inMonth
			Numeric - inYear
		History:
			2016-09-29 - GAC - Created
	*/
	public date function firstDayOfQuarter(required numeric inMonth, numeric string inYear)
	{
		var dateObj = createDate(arguments.inYear, arguments.inMonth, 1);

		return DateAdd("q", Quarter(dateObj)-1, '01-01-' & year(dateObj));
	}

	/*
		Author:
			PaperThin, Inc.
		Name:
			$firstDayOfQuarterByDate
		Summary:
			Returns date for first day of the quarter from the provided date
		Returns:
			Date
		Arguments:
			Date - inDate
		History:
			2016-09-29 - GAC - Created
	*/
	public date function firstDayOfQuarterByDate(date inDate='#Now()#')
	{
		return firstDayOfQuarter(inMonth=Month(arguments.inDate),inYear=Year(arguments.inDate));
	}

	/*
		Author:
			PaperThin, Inc.
		Name:
			$lastDayOfQuarter
		Summary:
			Returns date for last day of the quarter for the provided month/year
		Returns:
			Date
		Arguments:
			Numeric - inMonth
			Numeric - inYear
		History:
			2016-09-29 - GAC - Created
	*/
	public date function lastDayOfQuarter(required numeric inMonth, required numeric inYear)
	{
		var qtrStartDate = firstDayOfQuarter(inMonth=arguments.inMonth,inYear=arguments.inYear);

		return DateAdd("d",-1,DateAdd("m",3,qtrStartDate));
	}

	/*
		Author:
			PaperThin, Inc.
		Name:
			$lastDayOfQuarterByDate
		Summary:
			Returns date for last day of the quarter from the provided date
		Returns:
			Date
		Arguments:
			Date - inDate
		History:
			2016-09-29 - GAC - Created
	*/
	public date function lastDayOfQuarterByDate(date inDate='#Now()#')
	{
		return lastDayOfQuarter(inMonth=Month(arguments.inDate),inYear=Year(arguments.inDate));
	}
}