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
	date_1_2.cfc
Summary:
	Date Utils functions for the ADF Library
Version:
	1.2
History:
	2012-12-21 - GAC - Created - New v1.2
	2013-02-28 - GAC - Added new date functions
--->
<cfcomponent displayname="date_1_2" extends="ADF.lib.date.date_1_1" hint="Date Utils functions for the ADF Library">

<cfproperty name="version" value="1_2_1">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Date_1_2">
	
<!---
/* *************************************************************** */
Author:	
	A. McCollough 
	(&#97;&#109;&#99;&#99;&#111;&#108;&#108;&#111;&#117;&#103;&#104;&#64;&#97;&#110;&#116;&#104;&#99;&#46;&#111;&#114;&#103;) 
Name:
	$timeAgo
Summary:
	Displays how long ago something was.
	
	aka. AGO
	http://cflib.org/udf/ago
	
	@version 1, December 7, 2009 
Returns:
	String
Arguments:
	String - dateThen - Date to format. (Required)
History:
	2012-12-21 - GAC - Added
--->
<cffunction name="timeAgo" access="public" returntype="string" output="false" hint="Displays how long ago something was.">
	<cfargument name="dateThen" type="date" required="true" hint="Date to format. (Required)">
	<cfscript>
		var result = "";
		var i = "";
		var rightNow = Now();
		Do {
			i = dateDiff('yyyy',arguments.dateThen,rightNow);
			if ( i GTE 2 ) {
		   		result = "#i# years ago";
		   		break;
			}
			else if ( i EQ 1 ) {
		   		result = "#i# year ago";
		   		break;
		   	}
		    i = dateDiff('m',arguments.dateThen,rightNow);
		   	if ( i GTE 2 ) {
		   		result = "#i# months ago";
		   		break;
		   	}
			else if ( i EQ 1 )  {
		   		result = "#i# month ago";
		   		break;
		   	}
			i = dateDiff('d',arguments.dateThen,rightNow);
		    if ( i GTE 2 ) {
		   		result = "#i# days ago";
		   		break;
		   	}
			else if ( i EQ 1 ) {
		   		result = "#i# day ago";
		   		break;
		   	}
			i = dateDiff('h',arguments.dateThen,rightNow);
		    if ( i GTE 2 ) {
			   result = "#i# hours ago";
			   break;
			}
			else if ( i EQ 1 ) {
			   result = "#i# hour ago";
			   break;
			}
			i = dateDiff('n',arguments.dateThen,rightNow);
		    if ( i GTE 2 ) {
			   result = "#i# minutes ago";
			   break;
			}
			else if ( i EQ 1 ) {
			   result = "#i# minute ago";
			   break;
			}
			i = dateDiff('s',arguments.dateThen,rightNow);
		    if ( i GTE 2 ) {
			   result = "#i# seconds ago";
			   break;
			}
			else if ( i EQ 1 ) {
			   result = "#i# second ago";
			   break;}
			else {
			   result = "less than 1 second ago";
			   break;
		   }
		}
		While (0 eq 0);
		return result;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	$createValidDate
Summary:
	Returns a valid date from year, month and day values.
	Helps to avoid 2/31/2011 type stituations
Returns:
	Date
Arguments:
	Numeric - inYear
	Numeric - inMonth
	Numeric - inDay
History:
	2011-07-12 - GAC - Created
	2013-02-28 - GAC - Moved in to the date_1_2 lib of the ADF
--->
<cffunction name="createValidDate" access="public" returntype="date" output="false" hint="Returns a valid date from year month day entries.">
	<cfargument name="inYear" required="false" type="numeric" default="#Year(Now())#">
	<cfargument name="inMonth" required="false" type="numeric" default="#Month(Now())#">
	<cfargument name="inDay" required="false" type="numeric" default="#Day(Now())#">
	<cfscript>
		var retDate = "";
		var isValidDate = false;
		var y = arguments.inYear;
		var m = arguments.inMonth;
		var d = arguments.inDay;
		var yMin = 1900;  // This value can be any valid year less than the current year ie, 1900 or (Year(Now()) - 100)
		var mMax = 12;
		var mMin = 1;
		var dMax = 31;
		var dMin = 1;

		// Validate inYear entry
		if ( y LT yMin )
			y = yMin;

		// Validate inMonth entry
		if ( m GT mMax )
			m = mMax;
		else if ( m LT mMin )
			m = mMin;

		// Valididate inDay entry
		if ( d GT dMax )
			d = dMax;
		else if ( d LT dMin )
			d = dMin;

		// Attempt to do the CreateDate with the provided year, month, day values
		// - if error occurs... most likely the too many days were passed in for the month
		// - in that case subtract a day until the date is valid
		while ( !isValidDate  )
		{
			try
			{
				// Create Date Object from year,month and day entries
				retDate = CreateDate(y,m,d);
				isValidDate = true;
			}
			catch (any e)
			{
				isValidDate = false;
				//d = Day(lastOfMonth(inMonth=m,inYear=y));
				d = d - 1;
			}
		}
		return retDate;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:	
	Casey Broich (cab@pagex.com) 
Name:
	$weekInMonth
Summary:
	This function returns the week number in a month.
	 
	http://cflib.org/index.cfm?event=page.udfbyid&udfid=1122
	 
	@author Casey Broich (cab@pagex.com) 
	@version 1, September 21, 2004 
Returns:
	Numeric
Arguments:
	Date - inDate
History:
	2011-06-28 - GAC - Added from CFLib.org
	2013-02-28 - GAC - Moved in to the date_1_2 lib of the ADF
--->
<cffunction name="weekInMonth" access="public" output="false" returntype="numeric" hint="This function returns the week number in a month.">
	<cfargument name="inDate" type="date" required="true" default="#Now()#" hint="Date to use. Defaults to now().">
	<cfscript>
		return  week(arguments.inDate) - week(createDate(year(arguments.inDate),month(arguments.inDate),1)) + 1;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	$DayOfWeekAbbrString
Summary:
	This function returns day of the week name as an abbreviation.
Returns:
	string
Arguments:
	Date - inDate
History:
	2011-07-12 - GAC - Created
	2013-02-28 - GAC - Moved in to the date_1_2 lib of the ADF
--->
<cffunction name="DayOfWeekAbbrString" access="public" output="false" returntype="string" hint="This function returns day of the week name as an abbreviation.">
	<cfargument name="inDate" type="date" required="false" default="#Now()#" hint="Date to use. Defaults to now().">
	<cfscript>
		return DateFormat(arguments.inDate,"ddd");
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	$MonthAbbrString
Summary:
	This function returns month name as an abbreviation.
Returns:
	string
Arguments:
	Date - inDate
History:
	2011-07-12 - GAC - Created
	2013-02-28 - GAC - Moved in to the date_1_2 lib of the ADF
--->
<cffunction name="MonthAbbrString" access="public" output="false" returntype="string" hint="This function returns month name as an abbreviation.">
	<cfargument name="inDate" type="date" required="false" default="#Now()#" hint="Date to use. Defaults to now().">
	<cfscript>
		return DateFormat(arguments.inDate,"mmm");
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	$getNextFirstOfWeekDate
Summary:
	Returns the next first of the week date from a given date.
Returns:
	string
Arguments:
	string - inDate
	numeric - addQty
History:
	2011-07-12 - GAC - Created
	2013-02-28 - GAC - Moved in to the date_1_2 lib of the ADF
--->
<cffunction name="getNextFirstOfWeekDate" access="public" returntype="string" output="true" hint="Returns the next first of the week date from a given date.">
	<cfargument name="inDate" type="string" required="true">
	<cfargument name="addQty" type="numeric" required="true">
	<cfscript>
		var retDate = firstDayOfWeek(arguments.inDate);
		var addType = "ww"; // week
		retDate = DateAdd(addType,arguments.addQty,retDate);
		return retDate;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	$getNextMonthFirstOfMonthDate
Summary:
	Returns the next first of the month date from a given date.
Returns:
	String
Arguments:
	string - inDate
	numeric - addQty
History:
	2011-07-12 - GAC - Created
	2013-02-28 - GAC - Moved in to the date_1_2 lib of the ADF
--->
<cffunction name="getNextMonthFirstOfMonthDate" access="public" returntype="string" output="true" hint="Returns the next first of the month date from a given date.">
	<cfargument name="inDate" type="string" required="true">
	<cfargument name="addQty" type="numeric" required="true">
	<cfscript>
		var addType = "m"; // month
		var retDate = firstOfMonth(Month(arguments.inDate),Year(arguments.inDate));
		retDate = DateAdd(addType,arguments.addQty,retDate);
		return retDate;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	$getNextYearOrdinalDayDate
Summary:
	Returns the date from next X years last of the month or first of the month date from a given date and ordinal day.
Returns:
	Date
Arguments:
	numeric - inYear
	numeric - inMonth
	numeric - inDay
	string - ordinalDay
	numeric - addQty
History:
	2011-07-12 - GAC - Created
	2013-02-28 - GAC - Moved in to the date_1_2 lib of the ADF
--->
<cffunction name="getNextYearOrdinalDayDate" access="public" returntype="date" output="false" hint="Returns the next X years last of the month or first of the month date from a given date.">
	<cfargument name="inYear" required="false" type="numeric" default="#Year(Now())#">
	<cfargument name="inMonth" required="false" type="numeric" default="#Month(Now())#">
	<cfargument name="inDay" required="false" type="numeric" default="#Day(Now())#">
	<cfargument name="ordinalDay" type="string" required="false" default="last" hint="Options: first or last">
	<cfargument name="addQty" type="numeric" required="false" default="1">
	<cfscript>
		// Create Date Object from year,month and day entries
		var retDate = createValidDate(arguments.inYear,arguments.inMonth,arguments.inDay);

		// Check to see if the ordinalDay value passed in was first or last
		if ( arguments.ordinalDay EQ "first" ) {
			// set retDate as the First of the Month
			retDate = getNextXYearsFirstOfMonthDate(inDate=retDate,addQty=arguments.addQty);
		}
		else if ( arguments.ordinalDay EQ "last" ) {
			// set retDate as the Last of the Month
			retDate = getNextXYearsLastOfMonthDate(inDate=retDate,addQty=arguments.addQty);
		}
		return retDate;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	$getNextXYearsFirstOfMonthDate
Summary:
	Returns the next X years first of the month date from a given date.
Returns:
	date
Arguments:
	date - inDate
	numeric - addQty
History:
	2011-07-12 - GAC - Created
	2013-02-28 - GAC - Moved in to the date_1_2 lib of the ADF
--->
<cffunction name="getNextXYearsFirstOfMonthDate" access="public" returntype="date" output="false" hint="Returns the next X years first of the month date from a given date.">
	<cfargument name="inDate" type="date" required="false" default="#Now()#">
	<cfargument name="addQty" type="numeric" required="false" default="1">
	<cfscript>
		var addType = "yyyy"; // DateAdd year mask
		var retDate = DateAdd(addType,arguments.addQty,arguments.inDate);
		retDate = firstOfMonth(Month(retDate),Year(retDate));
		return retDate;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	$getNextXYearsLastOfMonthDate
Summary:
	Returns the next X years last of the month date from a given date.
Returns:
	Date
Arguments:
	Date - inDate
	Numeric - addQty
History:
	2011-07-12 - GAC - Created
	2013-02-28 - GAC - Moved in to the date_1_2 lib of the ADF
--->
<cffunction name="getNextXYearsLastOfMonthDate" access="public" returntype="date" output="false" hint="Returns the next X years last of the month date from a given date.">
	<cfargument name="inDate" type="date" required="false" default="#Now()#">
	<cfargument name="addQty" type="numeric" required="false" default="1">
	<cfscript>
		var addType = "yyyy"; // DateAdd year mask
		var retDate = DateAdd(addType,arguments.addQty,arguments.inDate);
		retDate = lastOfMonth(Month(retDate),Year(retDate));
		return retDate;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin,Inc.
	Ron West
Name:
	$calculateMonthsYears
Summary:	
	Returns the month and years (next/previous) based on the passed in date
Returns:
	Struct dates
Arguments:
	Date inDate
History:
 	2009-12-11 - RLW - Created
	2013-02-28 - GAC - Moved in to the date_1_2 lib of the ADF
--->
<cffunction name="calculateMonthsYears" access="public" returntype="struct" output="true" hint="Returns the month and years (next/previous) based on the passed in date">
	<cfargument name="inDate" type="date" required="true">
	<cfscript>
		var dates = structNew();
		var refDate = createDate(year(arguments.inDate), month(arguments.inDate), 1);
		
		// set the next and previous months
		dates.nextMonth = month(dateadd('M',1,refDate));
		dates.nextYear = year(dateadd('Y',1,refDate));
		// reset year if next month is january
		if( dates.nextMonth eq 1 )
			dates.nextYear = dates.nextYear + 1;
		dates.lastMonth = month(dateadd('M',-1,refDate));
		dates.lastYear = year(dateadd('Y',-1,refDate));
		// check to make sure that next/last year is not more than 2 years away
		if( dates.nextYear gt year(dateAdd("yyyy", 2, now())) ) {
			dates.nextYear = year(now());
			dates.nextMonth = month(now());
		}
		else if( dates.lastYear lt year(dateAdd("yyyy", -2, now())) ) {
			dates.lastYear = year(now());
			dates.lastMonth = month(now());
		}
		return dates;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	Greg Cronkright / Ron West
Name:
	$calculateWeekDates
Summary:	
	Returns a structure of last, this, next week dates based on the passed in date
Returns:
	Struct dates
Arguments:
	Date inDate
History:
 	2009-12-11 - RLW - Created
	2010-03-19 - GAC - Modified (adapted from calendar_standard_setup.cfm)
	2013-02-28 - GAC - Moved in to the date_1_2 lib of the ADF
--->
<cffunction name="calculateWeekDates" access="public" returntype="struct" output="true" hint="Returns a structure of last, this, next week dates based on the passed in date">
	<cfargument name="inDate" type="date" required="true">
	<cfscript>
		var dates = structNew();
		
		var firstOfThisWeek = application.ptCalendar.date.firstDayOfWeek(arguments.inDate);
		var lastOfThisWeek = dateAdd("d", 6, firstOfThisWeek);
		var firstOfLastWeek = dateAdd("d", -7, firstOfThisWeek);
		var firstOfNextWeek = dateAdd("d", 7, firstOfThisWeek);
		var formattedThisWeek = dateFormat(firstOfThisWeek, 'mmmm dd, yyyy');
		var formattedLastWeek = dateFormat(firstOfLastWeek, 'mmmm dd, yyyy');
		var formattedNextWeek = dateFormat(firstOfNextWeek, 'mmmm dd, yyyy');

		// set the next and previous months
		dates["firstOfThisWeek"] = firstOfThisWeek;
		dates["lastOfThisWeek"] = lastOfThisWeek;
		dates["firstOfLastWeek"] = firstOfLastWeek;
		dates["firstOfNextWeek"] = firstOfNextWeek;
		dates["formattedThisWeek"] = formattedThisWeek;
		dates["formattedLastWeek"] = formattedLastWeek;
		dates["formattedNextWeek"] = formattedNextWeek;
		
		return dates;
	</cfscript>
</cffunction>

</cfcomponent>