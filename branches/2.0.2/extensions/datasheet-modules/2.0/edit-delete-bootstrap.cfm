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
	edit.cfm
Summary:
	Renders jQueryUI edit buttons for your datasheet.
History:
	2016-06-29 - GAC - Created
--->
<cfscript>
	defaultModuleVersion  = "2.0";

	// Bootstrap set to TRUE by default
	request.adfDSmodule.useBootstrap = true;

	if ( !StructKeyExists(request.adfDSmodule,"buttonStyle") OR LEN(TRIM(request.adfDSmodule.buttonStyle)) EQ 0 )
		request.adfDSmodule.buttonStyle = "btn-primary";
	if ( !StructKeyExists(request.adfDSmodule,"buttonSize") OR LEN(TRIM(request.adfDSmodule.buttonSize)) EQ 0 )
		request.adfDSmodule.buttonSize = "btn-md";

	// Include the edit-delete.cfm datasheet module
	include "/ADF/extensions/datasheet-modules/#defaultModuleVersion#/edit-delete.cfm";
</cfscript>