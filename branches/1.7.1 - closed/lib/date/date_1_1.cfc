<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
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
	date_1_1.cfc
Summary:
	Date Utils functions for the ADF Library
Version:
	1.1
History:
	2011-03-08 - GAC - Created - New v1.1
--->
<cfcomponent displayname="date_1_1" extends="ADF.lib.date.date_1_0" hint="Date Utils functions for the ADF Library">

<cfproperty name="version" value="1_1_0">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Date_1_1">
	
<!---
/* *************************************************************** */
Author:	
	B. Nadel
Name:
	$ISOToDateTime
Summary:
	Converts an ISO 8601 date/time stamp with optional dashes to a ColdFusion date/time stamp.
	From Ben Nadel's Blog Post 'Converting ISO Date/Time To ColdFusion Date/Time' posted July 3, 2007
	http://www.bennadel.com/blog/811-Converting-ISO-Date-Time-To-ColdFusion-Date-Time.htm
Returns:
	String
Arguments:
	String - ISO8601DateTime
History:
	2011-03-08 - GAC - Added
	2011-03-09 - GAC - Update - Added ParseDateTime() and returnFormat=Date - from the comments of Ben's blog post
	2011-03-10 - GAC - Removed ReplaceFirst and changed to REReplace CF function.
--->
<cffunction name="ISOToDateTime" access="public" returntype="date" output="false" hint="Converts an ISO 8601 date/time stamp with optional dashes to a ColdFusion date/time stamp.">
	<cfargument name="ISODateTime" type="string" required="true" hint="ISO 8601 date/time stamp.">
	<!--- // When returning the converted date/time stamp, allow for optional dashes. --->
	<!--- <cfreturn ParseDateTime(arguments.ISODateTime.ReplaceFirst("^.*?(\d{4})-?(\d{2})-?(\d{2})T([\d:]+).*$","$1-$2-$3 $4"))> --->
	 <cfreturn ParseDateTime(REReplace(arguments.ISODateTime, "^.*?(\d{4})-?(\d{2})-?(\d{2})T([\d:]+).*$", "\1-\2-\3 \4", "ONE"))>
	<!---<cfreturn arguments.ISODateTime.ReplaceFirst("^.*?(\d{4})-?(\d{2})-?(\d{2})T([\d:]+).*$","$1-$2-$3 $4")> --->
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc. 	
	G. Cronkright
Name:
	$ISOToDateTimeStruct
Summary:
	Converts an ISO 8601 date/time stamp to a structure of various data/time formats.
	Including a Coldfusion Date/Time Stamp and a CommonSpot Data/Time Stamp
	Based on Ben Nadel's method 'ISOToDateTime'
Returns:
	String
Arguments:
	String - ISO8601DateTime
History:
	2011-03-08 - GAC - Created - Based on ISOToDateTime
	2011-03-10 - GAC - Modified - Added check to make sure passed in value is a valid ISO8601 date/time stamp
--->
<cffunction name="ISOToDateTimeStruct" access="public" returntype="struct" output="false" hint="Converts an ISO 8601 date/time stamp to a structure of various data/time formats.">
		<cfargument name="ISODateTime" type="string" required="true" hint="ISO 8601 date/time stamp.">
			
		<cfscript>
			var dtStruct = StructNew();
			var dateTime = arguments.ISODateTime;
			
			// Check to see if ISODateTime is an ISO8601 DateTime
			//  - if not attempt but a valid date/time stamp attempt to convert it to the ISO8601 standard
			if ( Find("T",dateTime) NEQ 11 AND IsDate(dateTime) )
				dateTime = formatDateTimeISO8601(dateTime,dateTime);
			
			dtStruct.ISO8601DateTime = dateTime;
			dtStruct.dateTime = ISOToDateTime(dateTime);
			dtStruct.date = DateFormat(dtStruct.dateTime);
			dtStruct.time = TimeFormat(dtStruct.dateTime,"long");
			dtStruct.csDateTime = csDateFormat(dtStruct.date,dtStruct.time);

			return dtStruct;
		</cfscript>
	</cffunction>

</cfcomponent>