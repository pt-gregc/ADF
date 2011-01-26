<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2010.
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
	1.0.1
History:
	2009-06-22 - MFC - Created
	2010-09-21 - MFC - Added formatDateTimeISO8601 and getDateFields functions.
--->
<cfcomponent displayname="date_1_0" extends="ADF.core.Base" hint="Date Utils functions for ADF Library">

<cfproperty name="version" value="1_0_1">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Date_1_0">

<!---
/* ***************************************************************
/*
Author: 	Ron West
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
 */ --->
<cffunction name="firstDayOfWeek" access="public" returntype="any" hint="Returns a date.">
	<cfargument name="inDate" type="date" required="false" default="#now()#">
	<cfscript>
		var dow = "";
		var dowMod = "";
		var dowMult = "";
		var firstDayOfWeek = "";
		date = trim(arguments.inDate);
		dow = dayOfWeek(date);
		dowMod = decrementValue(dow);
		dowMult = dowMod * -1;
		firstDayOfWeek = dateAdd("d", dowMult, date);
	</cfscript>
	<cfreturn firstDayOfWeek>
</cffunction>
<!---
	/* ***************************************************************
	/*
	Author: 	Ron West
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
	--->
<cffunction name="lastDayOfWeek" access="public" returntype="String" hint="Given the current date find out what the last day of the week is">
	<cfargument name="inDate" type="date" required="false" default="#now()#">
	<cfscript>
		var returnDate = firstDayOfWeek();
		if( isDate(returnDate) )
			returnDate = dateAdd("d", 6, returnDate);
	</cfscript>
	<cfreturn returnDate>
</cffunction>
<!--- // returns date for first of month --->
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
<!--- // returns last date of month --->
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
/* ***************************************************************
/*
Author: 	Ron West
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
/* ***************************************************************
/*
Author: 	Ron West
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
/* ***************************************************************
/*
Author: 	Ron West
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
	string
	string
History:
	2010-09-20 - MFC - Created
--->
<cffunction name="formatDateTimeISO8601" access="public" returntype="string" output="true" hint="">
	<cfargument name="date" type="string" required="false" default="#now()#" hint="">
	<cfargument name="time" type="string" required="false" default="#now()#" hint="">
	
	<cfscript>
		var tzData = GetTimeZoneInfo();
		var tzStamp = "";
				
		// Set the timezone 
		if ( tzData.utcHourOffset GTE 0 ){
			if ( LEN(tzData.utcHourOffset) EQ 1 )
				tzStamp = "+0" & tzData.utcHourOffset & ":00";
			else
				tzStamp = "+" & tzData.utcHourOffset & ":00";
		}
		else
			tzStamp = "-" & tzData.utcHourOffset & ":00";
		
		// Build the string
		return DateFormat(arguments.date, "YYYY-MM-DD") & "T" & TimeFormat(arguments.time, "HH:MM:SS") & tzStamp;
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