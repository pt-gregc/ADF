<!--- call_renderitem --->
<cfscript>
	ajaxBeanName = attributes.beanName;
	currentID = attributes.id;
	currentFormat = attributes.format;
	result = "";
	if (ajaxBeanName neq "" AND currentID neq "" AND currentFormat neq "")
	{
		if (ListLen(ajaxBeanName, "/") gt 1)
			adfComponent = CreateObject("component", "#ajaxBeanName#");
		else	
			adfComponent = application.ADF[ajaxBeanName];
		result = adfComponent.renderitem(id=currentID, format=currentFormat);
	}	
	writeOutput(result);
</cfscript>