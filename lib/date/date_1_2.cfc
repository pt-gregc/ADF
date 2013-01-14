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
--->
<cfcomponent displayname="date_1_2" extends="ADF.lib.date.date_1_1" hint="Date Utils functions for the ADF Library">

<cfproperty name="version" value="1_2_0">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Date_1_2">
	
<!---
/* *************************************************************** */
Author:	
	A. McCollough ('ago' from CFLIB)
	(&#97;&#109;&#99;&#99;&#111;&#108;&#108;&#111;&#117;&#103;&#104;&#64;&#97;&#110;&#116;&#104;&#99;&#46;&#111;&#114;&#103;) 
Name:
	$timeAgo
Summary:
	Displays how long ago something was.
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

</cfcomponent>