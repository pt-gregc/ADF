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
/* *********************************************************************** */
Author:
	PaperThin, Inc.
Name:
	ceManagement.cfm - v2.0
Summary:
	Renders a custom element datasheet management page using the v2.0 scriptConfigVersion by default

Attributes:
	See "/ADF/extensions/customcf/ceManagement/1.0/ceManagement.cfm" for docs and a list of "Attributes"
History:
	2015-12-23 - GAC - Created
	2016-02-19 - GAC - Added commented stubs for the "getResources" check
--->

<!--- // if this module loads resources, do it here.. --->
<!---<cfscript>
    // No resources to load
</cfscript>--->

<!--- ... then exit if all we're doing is detecting required resources --->
<!---<cfif Request.RenderState.RenderMode EQ "getResources">
  <cfexit>
</cfif>--->

<cfscript>
        // set the default config version to "2.0"
        if ( !StructKeyExists(attributes,"configVersion") OR LEN(TRIM(attributes.configVersion)) EQ 0 )
            attributes.configVersion = "2.0";

        // Include the original genericElementManagement script
        include "/ADF/extensions/customcf/ceManagement/1.0/ceManagement.cfm";
</cfscript>