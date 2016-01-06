<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2016.
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
	$tab_index_render.cfc
Summary:
	Tab Index custom field to add the "tabindex" attributes to the fields in the simple form.
History:
 	2012-11-27 - MFC - Created
 	2015-12-22 - GAC - Converted to CFC
--->
<cfcomponent displayName="TabIndex_Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

    <cffunction name="renderControl" returntype="void" access="public">
        <cfargument name="fieldName" type="string" required="yes">
        <cfargument name="fieldDomID" type="string" required="yes">
        <cfargument name="value" type="string" required="yes">

        <cfscript>
            var currentValue = arguments.value;	// the field's current value
            var tabIndexFooterJS = "";

            // Load JQuery
            application.ADF.scripts.loadJQuery();
        </cfscript>

        <cfsavecontent variable="tabIndexFooterJS">
            <cfoutput>
            <script>
                jQuery(function(){
                    serializeTabIndex();
                });

                function serializeTabIndex(){
                    // Get all the input and textarea fields in the form
                    var tabindex = 1;
                    jQuery('form.cs_default_form').find('input,textarea,select,iframe').each(function() {
                        // If not a hidden field
                        if ( this.type != "hidden" ) {
                            jQuery(this).attr("tabindex", tabindex);
                            tabindex++;
                        }
                    });
                }
            </script>
            </cfoutput>
        </cfsavecontent>
        
        <cfscript>
            // Load the inline JavaScript after the libraries have loaded
            application.ptCalendar.scripts.addFooterJS(tabIndexFooterJS, "SECONDARY"); //  PRIMARY, SECONDARY, TERTIARY
        </cfscript>

        <cfoutput>
            <!--- hidden field to store the value --->
            <input type="hidden" name="#arguments.fieldName#" value="#currentValue#">
        </cfoutput>
    </cffunction>

    <cfscript>
        // field renders only the script function
        public void function renderStandard()
        {
            renderControl(argumentCollection=arguments);
        }
    </cfscript>
</cfcomponent>