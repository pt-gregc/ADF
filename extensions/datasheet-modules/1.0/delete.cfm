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
 	delete.cfm
Summary:
	Renders jQueryUI delete buttons for your datasheet. 
	Prints out jQueryUI delete buttons for your datasheet. 
History:
	2015-06-26 - GAC - Created
--->
<cfset variables.adfDSmodule.renderEditBtn = false>
<cfset variables.adfDSmodule.renderDeleteBtn = true>
<!--- // Include the edit-delete.cfm datasheet module --->
<cfinclude template="/ADF/extensions/datasheet-modules/1.0/edit-delete.cfm">