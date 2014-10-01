This custom field requires serval configuration items.
1. Please copy the /thirdParty/cfformprotect/cffp.ini.cfm file into your _cs_apps/config/ directory and customize it for your needs.
2. This field only is effective when called using the ADF 1.5's forms_1_1's renderAddEditForm function because
	it relies heavily on the ability to validate in the callback function.
		A. When the element that contains this is called to lightbox proxy set the callback parameter to go to a callback function of your choice
		B. In this callback place the following (assuming the parameter to this function is data):
				var formJSON = JSON.stringify(data);
				jQuery.get("#application.ADF.ajaxProxy#",{
						bean: "forms_1_1",
						method: "verifyCFFormProtect",
						formStruct: formJSON,
						elementName: '[put your element name here]',
						primaryKey: '[put your elements primary key here default if not sent is id]'
					}}
			    );
		C. This method will validate the submitted form, if invalid it deletes the record. Make sure to update elementName and primaryKey