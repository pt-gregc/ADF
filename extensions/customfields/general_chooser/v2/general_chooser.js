
// Modify the arrow icon to the close
function makeArrowIcon(selObj){
	var imgSpan = jQuery(selObj).find('span.actionMontageIcon');
	imgSpan.removeClass('ico_arrow_right');
	imgSpan.addClass('ico_cancel');	
}

// Modify the close icon to the arrow
function makeCloseIcon(selObj){
	var imgSpan = jQuery(selObj).find('span.actionMontageIcon');
	imgSpan.removeClass('ico_cancel');
	imgSpan.addClass('ico_arrow_right');
}

// Sets the icon for the selected object when moved
function sortableReceiveAction(event, ui){
	// Get the Target and Item objects
	var targetObj = jQuery(event.target);
	var itemObj = jQuery(ui.item);
	
	// Remove the class for the active item
	itemObj.removeClass('activeItem');
	
	// Find the target objects ID attribute
	var targetID = targetObj.attr('id');
	
	// Determine what are actions are
	if ( targetID == 'selSelections' ){
		moveObjectToSelected(itemObj);
	}
	else if ( targetID == 'availSelections' ){
		moveObjectToAvailable(itemObj);
	}
}

// Sets the styles for the selected object when starting to sort
function sortableStartAction(event, ui){
	// Get the Item objects and add the active class
	jQuery(ui.item).addClass('activeItem');
}

// Sets the styles for the selected object when stoping to sort
function sortableStopAction(event, ui){
	// Get the Item object and remove the active class
	jQuery(ui.item).removeClass('activeItem');
}

// Add the filter for the available selections
function sendGetAvailableFilter(){
	// Get the filtered results
	
	
}

// Lightbox add new record form
function openLBAdd(){
	
}