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
	Ryan Kahn
Name:
	$sampleUploader.cfc
Summary:
	Sample file uploader
History:
 	2011-09-02 - RAK - Created
	2015-05-26 - DJM - Added the 3.0 version
--->
<cfcomponent name="sampleUploader" extends="ADF.extensions.customfields.file_uploader.file_uploader">
	<cfscript>
		variables.acceptedExtensions = "png,gif,jpg,jpeg";

		//Validation functions, an array of function names that get called in order.
		//If any of them fails the entire upload fails.
		variables.validationFunctions = ArrayNew(1);
		ArrayAppend(variables.validationFunctions,"validateSize");
		ArrayAppend(variables.validationFunctions,"validateExtension");
	</cfscript>

</cfcomponent>