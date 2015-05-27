<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
All Rights Reserved.
 
By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Custom Field Type:
	general chooser
Name:
	general_chooser.cfc
Summary:
	General Chooser component.
Version:
	2.0
History:
	2009-10-16 - MFC - Created
	2009-11-13 - MFC - Updated the Ajax calls to the CFC to call the controller 
						function.  This allows only the "controller" function to 
						listed in the proxy white list XML file.
	2011-03-20 - MFC - Updated component to simplify the customizations process and performance.
						Removed Ajax loading process.
	2012-01-30 - GAC - Added a Display_Feild varaible to the General Chooser init variables.
	2013-01-10 - MFC - Disabled the Delete icon/action in the selection.
	2013-01-30 - GAC - Updated to use the ceData 2.0 lib component
	2013-10-22 - GAC - Updated to inject the data_1_2 lib in to the variables.data scope since we are extending ceData_2_0
	2013-10-23 - GAC - Removed data_1_2 injection due to ADF reset errors on startup
	2013-12-10 - GAC - Updated the extends to point to ADF.extensions.customfields.general_chooser.v1_2.general_chooser_1_2
	2015-05-26 - DJM - Updated the extends to point to ADF.extensions.customfields.general_chooser.v2_0.general_chooser_2_0
--->
<cfcomponent name="general_chooser" extends="ADF.extensions.customfields.general_chooser.v2_0.general_chooser_2_0">
	
	<!--- // This is pass through file for the v2.0 component for the General Chooser field --->
	
</cfcomponent>