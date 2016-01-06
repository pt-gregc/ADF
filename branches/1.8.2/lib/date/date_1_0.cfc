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
	date_1_0.cfc
Summary:
	Date Utils functions for the ADF Library
Version:
	1.0
History:
	2009-06-22 - MFC - Created
	2010-09-21 - MFC - Added formatDateTimeISO8601 and getDateFields functions.
--->
<cfcomponent displayname="date_1_0" extends="ADF.core.Base" hint="Date Utils functions for ADF Library">

<cfproperty name="version" value="1_0_4">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Date_1_0">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	Ron West
Name:
	$getMeridiem
Summary:
	Depending on the time of day returns AM/PM
Returns:
	String meridiem
Arguments:
	String dateTime
History:
	2009-02-11 - RLW - Created
--->
<cffunction name="getMeridiem" access="public" returntype="String" hint="Depending on the time of day returns AM/PM">
	<cfargument name="dateTime" type="string" required="true">
	<cfscript>
		var rtnStr = "am";
		if( isDate(arguments.dateTime) and timeFormat(arguments.dateTime, "HH") gte 12 )
			rtnStr = "pm";
	</cfscript>
	<cfreturn rtnStr>
</cffunction>

<!--- //**
 * Analogous to firstDayOfMonth() function.
 *
 * @param date 	 Date object used to figure out week. (Required)
 * @return Returns a date.
 * @author Pete Ruckelshaus (pruckelshaus@yahoo.com)
 * @version 1, September 12, 2007
	2011-02-09 - RAK - Var'ing un-var'd variables
 */ --->
<cffunction name="firstDayOfWeek" access="public" returntype="any" hint="Returns a date.">
	<cfargument name="inDate" type="date" required="false" default="#now()#">
	<cfscript>
		var dow = "";
		var dowMod = "";
		var dowMult = "";
		var firstDayOfWeek = "";
		var date = trim(arguments.inDate);
		dow = dayOfWeek(date);
		dowMod = decrementValue(dow);
		dowMult = dowMod * -1;
		firstDayOfWeek = dateAdd("d", dowMult, date);
	</cfscript>
	<cfreturn firstDayOfWeek>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$lastDayOfWeek
Summary:	
	Given the current date find out what the last day of the week is
Returns:
	String lastDay
Arguments:
	String inDate
History:
	2009-09-23 - RLW - Created
	2011-07-13 - GAC - passed the inDate parameter through to the firstDayOfWeek function so this can be used on dates other than Now() 
--->
<cffunction name="lastDayOfWeek" access="public" returntype="String" hint="Given the current date find out what the last day of the week is">
	<cfargument name="inDate" type="date" required="false" default="#now()#">
	<cfscript>
		var returnDate = firstDayOfWeek(arguments.inDate);
		if( isDate(returnDate) )
			returnDate = dateAdd("d", 6, returnDate);
	</cfscript>
	<cfreturn returnDate>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$firstOfMonth
Summary:
	Returns date for first of month
Returns:
	Any 
Arguments:
	String - inMonth
	String - inYear
History:
	2007-10-01 - RLW - Created
--->
<cffunction name="firstOfMonth" access="public" output="false" returntype="any" hint="Returns date for first of month">
	<cfargument name="inMonth" required="true" type="string">
	<cfargument name="inYear" required="true" type="string">
	
	<cfscript>
		var firstDayDate = "";
		try
		{
			// create the first of the month as a date
			firstDayDate = createDate(arguments.inYear, arguments.inMonth, 1);
			// format it in CommonSpot terms
			firstDayDate = "#dateFormat(firstDayDate, 'yyyy-mm-dd')# 00:00:00";
		}
		catch (any e)
		{ ; }
	</cfscript>
	<cfreturn firstDayDate>
</cffunction>


<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$lastOfMonth
Summary:
	Returns last date of month
Returns:
	Any 
Arguments:
	String - inMonth
	String - inYear
History:
	2007-10-01 - RLW - Created
--->
<cffunction name="lastOfMonth" access="public" output="false" returntype="any" hint="Returns last date of month">
	<cfargument name="inMonth" required="true" type="string">
	<cfargument name="inYear" required="true" type="string">
	
	<cfscript>
		var lastDayDate = "";
		var daysInThisMonth = "";
		try
		{
			// how many days in this month
			daysInThisMonth = daysInMonth(createDate(arguments.inYear, arguments.inMonth, 1));
			// create the last of the month
			lastDayDate = createDate(arguments.inYear, arguments.inMonth, daysInThisMonth);
			// format it in CommonSpot terms
			lastDayDate = "#dateFormat(lastDayDate, 'yyyy-mm-dd')# 23:59:59";
		}
		catch (any e)
		{ ; }
	</cfscript>
	<cfreturn lastDayDate>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$csDateFormat
Summary:
	Converts any date into the standard CommonSpot date function 'yyyy-mm-dd HH:mm:ss'
Returns:
	A string which is the formatted time stamp
Arguments:
	(Date dateInput) - The date to be converted
	(Time timeInput) [optional] - The time to be converted
History:
	2007-10-01 - RLW - Created
--->
<cffunction name="csDateFormat" access="public" output="false" returntype="string">
	<cfargument name="dateInput" required="true" type="string">
	<cfargument name="timeInput" required="false" type="string" default="00:00:00">

	<cfscript>
		var csDate = "";
		if ( isDate(arguments.dateInput) )
			csDate = "#dateFormat(arguments.dateInput, 'yyyy-mm-dd')# #timeFormat(arguments.timeInput, 'HH:mm:ss')#";
	</cfscript>
	<cfreturn csDate>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$firstOfYear
Summary:	
	Returns the day/month/year of supplied year
Returns:
	Date theDate
Arguments:
	String theYear
History:
 2010-04-02 - RLW - Created
--->
<cffunction name="firstOfYear" access="public" returntype="Date">
	<cfargument name="theYear" type="string" required="false" default="#year(now())#">
	<cfscript>
		var theDate = createDate(arguments.theYear, 1, 1);
	</cfscript>
	<cfreturn csDateFormat(theDate)>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc. 	
	Ron West
Name:
	$lastOfYear
Summary:	
	Returns the last day of the year
Returns:
	Date theDate
Arguments:
	String theYear
History:
 2010-04-02 - RLW - Created
--->
<cffunction name="lastOfYear" access="public" returntype="date">
	<cfargument name="theYear" type="string" required="false" default="#year(now())#">
	<cfscript>
		var theDate = createDate(arguments.theYear, 12, 31);
	</cfscript>
	<cfreturn csDateFormat(theDate)>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$formatDateTimeISO8601
Summary:
	Format the date/time to the ISO8601 string.
Returns:
	string
Arguments:
	string - date
	string - time
	string - hourOffset
	string - minuteOffset
History:
	2010-09-20 - MFC - Created
	2011-03-09 - GAC - Fixes for issues with timezone, modified how the +/- operators render for the timezones
					 - Added hourOffset and minuteOffset parameters
	2014-09-18 - GAC - Updated by removing complex leading zero logic and replaced with NumberFormat padding
--->
<cffunction name="formatDateTimeISO8601" access="public" returntype="string" output="true" hint="">
	<cfargument name="date" type="string" required="false" default="#now()#" hint="">
	<cfargument name="time" type="string" required="false" default="#now()#" hint="">
	<cfargument name="hourOffset" type="string" required="false" default="" hint="A value from -14 to 14 representing hour offset for a timezone">
	<cfargument name="minuteOffset" type="string" required="false" default="" hint="A value from 1 to 59 representing minute offset for a timezone">
	
	<cfscript>
		var tzStamp = "";
		var tzData = GetTimeZoneInfo();
		var tzHrOffset = 0;
		var tzMinOffset = 0;
		var tzOperator = "+";

		// Use the hourOffset value, if one is passed in
		if ( LEN(TRIM(arguments.hourOffset)) AND IsNumeric(arguments.hourOffset) 
				AND (arguments.hourOffset LTE 14 AND arguments.hourOffset GTE -(12)) ) 
			tzHrOffset = arguments.hourOffset;	
		else 
		{
			// If hourOffset is not provided, use the GetTimeZoneInfo() values to ues Server's TimeZone information
			// - the CF utcHourOffset value is reverse from standard offset (utcHourOffset: 5 for -05:00)
			// - GetTimeZoneInfo() adjusts utcHourOffset for DST 
			if ( StructKeyExists(tzData,"utcHourOffset") AND tzData.utcHourOffset GTE 0 )
				tzHrOffset = -(tzData.utcHourOffset);
			else
				tzHrOffset = tzData.utcHourOffset;
		}
		// Use the minuteOffset value, if one is passed in
		if ( LEN(TRIM(arguments.minuteOffset)) AND IsNumeric(arguments.minuteOffset) 
				AND (arguments.minuteOffset LTE 59 AND arguments.minuteOffset GTE 1) ) 
			tzMinOffset = arguments.minuteOffset;	
		else 
		{
			// If minuteOffset is not provided, use the GetTimeZoneInfo() values to use Server's TimeZone information	
			if ( StructKeyExists(tzData,"utcMinuteOffset") )
				tzMinOffset = tzData.utcMinuteOffset;	
		}
		// Set the timezone operator use (Proper ISO8601 format): 
		// - (-) for timezones west of UTC (such as a zone in North America) 
		// - (+) for timezones east of UTC (such as a zone in Germany)   
		if ( tzHrOffset LTE 0 )
			tzOperator = "-";
		
		// Build the timezone stamp
		tzStamp = tzOperator & NumberFormat(ABS(tzHrOffset),"00") & ":" & NumberFormat(tzMinOffset,"00");
		
		// Build the string
		return DateFormat(arguments.date,"yyyy-mm-dd") & "T" & TimeFormat(arguments.time,"HH:mm:ss") & tzStamp;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getDateFields
Summary:
	Returns a structure with the date fields separated into each field.
Returns:
	struct
Arguments:
	string
	string
History:
	2010-09-21 - MFC - Created
--->
<cffunction name="getDateFields" access="public" returntype="struct" output="true" hint="">
	<cfargument name="date" type="string" required="false" default="#now()#" hint="">
	<cfargument name="time" type="string" required="false" default="#now()#" hint="">
	
	<cfscript>
		var dateFields = StructNew();
		dateFields.year = year(arguments.date);
		dateFields.month = month(arguments.date);
		dateFields.day = day(arguments.date);
		dateFields.hour = hour(arguments.time);
		dateFields.minute = minute(arguments.time);
		dateFields.second = second(arguments.time);
		return dateFields;
	</cfscript>
</cffunction>

</cfcomponent>