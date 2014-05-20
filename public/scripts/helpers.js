$(function() {
	$( "#hero" ).accordion({
		heightStyle: "content",
		autoHeight: true,
		clearStyle: true,   
	});
});

$(function() {
	$( "#settings" ).accordion({
		heightStyle: "content",
		autoHeight: true,
		clearStyle: true,   
	});
});

function setHeaderSubtext( header_name, value ) {
	document.getElementById( header_name + "_subheader").innerHTML = value;
}

function changeSkill(element) {
	var values = element.id.split('_');
	var name = values[0];
	var rank = parseInt( values[2] );
	for(var i=1;i<=6;i++) {
		var n = "#" + name + "_skill_" + i;
		$(n).each( function (index) {
			this.checked = (this.value <= rank);
		})
	}
	
}



function initializePage() {
	document.getElementById("monster_header").style.color = "red";
	document.getElementById("hero_basics_header").style.color = "red";
	setHeaderSubtext( "gear", "Dagger" );
	setHeaderSubtext( "stance", "Defensive" );
	setHeaderSubtext( "iterations", "1" );
	setHeaderSubtext( "virtues", "None" );
	setHeaderSubtext( "rewards", "None" );
	setHeaderSubtext( "skills", "None" );
}

$("#masterform").submit(function( event ) {
	event.preventDefault();
	$("#output").empty().append( "Running...");
  	var posting = $.post( '/masterform'  , $('#masterform').serialize() );
  	posting.done(function( data ) {
 //   	var content = $( data );
    	$( "#output" ).empty().append( data );
  	});
});

$(function() {
  $( document ).tooltip();
});

function setMonsterFamily(select) {
	updateFormElement( select, 'monstertype' );
	updateFormElement( select, 'monsterstats' );
	document.getElementById("monster_header").style.color = "red";
	document.getElementById("monster_subheader").innerHTML = "";
}

function setMonsterType(select) {
	updateFormElement( select, 'monsterstats' );
	var name = select.options[select.selectedIndex].getAttribute("name");
//	$( "#monster_subheader" ).innerHTML = name;
	document.getElementById("monster_subheader").innerHTML = "(" + name + ")";
	document.getElementById("monster_header").style.color = "black";
}

function setCulture(item) {
	updateFormElement(item, 'backgrounds');
	updateFormElement(item, 'feats');
	updateFormElement(item, 'gear');
	updateFormElement(item, 'submit_button')
	updateFormElement(item, 'cultural_blessing')
	document.getElementById("hero_basics_header").style.color = "red";
	setHeaderSubtext("hero_basics", value ); 
	document.getElementById("cultural_blessing").style.display = "block";	
}

function updateRewards(reward) {
/*	var parent = reward.parentNode;
	console.log(parent);
	var params = "culture=" + parent.getAttribute('culture');
	var rewards = new Array();
	var j=0;
	for(var i=0;i<reward.parentNode.childNodes.length;i++) {
		var child = reward.parentNode.childNodes[i];
		if( child.checked ) {
			rewards[j++] = child.named; 
		}
	}
	params += "&rewards=" + rewards;	
	console.log(params);
	$.get( '/gear', params, function( data ) {
		$( '#gear' ).html(data);
	});
*/

	var type = reward.getAttribute('reward_type');
	if( type != 'modifier'){
		// uncheck related items
		var parent = reward.parentNode;
		for(var i=0;i<parent.childNodes.length;i++) {
			var child = parent.childNodes[i];
			// if it's a checkbox, and of the same reward_type 
			if( child.type == "checkbox" && child.getAttribute('reward_type') == type && child != reward) {
				child.checked = false;
			}
		}
		
		var params = "type=" + type;
		params += "&culture=" + reward.getAttribute('culture');	
		if( reward.checked){
			params += "&reward=" + reward.name;	
		}	
		var partial_id = "#" + reward.getAttribute('reward_type').toLowerCase();
		$.get( '/gear', params, function (data) {
			$( partial_id ).html(data);
		});
	}
	
}

function updateFavoured(button) {
	//you can get the value from arguments itself
	var a = button.id.split("_");
	var attribute = a.shift();
	var value = a.shift();
	
	//alert(parseInt(value) + 2);
	for(var i=1;i<4;i++) {
		if( i != value ){
			var elementID = attribute + "_" + i;
			var element = document.getElementById(elementID);

			//console.log(element);
			element.checked = false; // button.checked ? false : true;
		}
	}
	updateFavouredValues();
};



function serializeElement( element ) {
	returnString = element.name + "=" + element.value;
	for(var i=0;i<element.attributes.length;i++) {
		if(element.attributes[i].name != "onchange") {
			returnString += "&"
			returnString += element.attributes[i].name;
			returnString += "=";
			returnString += element.attributes[i].value;
		}
	}
	return returnString
};

function runSimulation( form ){
//	console.log(form.serialize());
};

function setBackground( select ) {
	var option = select.options[select.selectedIndex];
	updateFormElement( option, 'attributes' );
	document.getElementById("hero_basics_header").style.color = "black";
	setHeaderSubtext( "hero_basics", option.getAttribute("culture") + " \"" + option.getAttribute("background") + "\"" )
};

function updateFormElement( source, destString ) {
	var path = "/" + destString;
	$.get( path, serializeElement(source), function( data ) {
		$( '#' + destString ).html(data);
	});
};

function updateFormElement2( argString, pathString ) {
	var path = "/" + pathString;
	$.get( path, argString, function( data ) {
		$( '#' + pathString ).html(data);
	});
}

function getMonsterTypes() {
	$.post( "/monstertypes", $('#sethero').serialize(), function( data ) {
		$( '#monstertypes' ).html(data);	
	});
};

function updateGear() {
	var string = "";
	['weapon','armor','shield','helm'].forEach( function(type) {
		var selector = document.getElementById( type + "_selector" )
		var optionname = selector.options[selector.selectedIndex].getAttribute("name");
		if( optionname != "None") {
			string += optionname + "|"
		}
	});
	// chop off last "|"
	string = string.substring(0, string.length - 1);
	setHeaderSubtext( "gear", string );
}

/*
function myfunction() {
	$.get( "ajax/test.html", function( data ) {
	  $( ".result" ).html( data );
	  alert( "Load was performed." );
	});
	
	
	var doWhenFinished = function(resuktFromServer) {
		$( ".result" ).html( resuktFromServer );
		 alert( "Load was performed." );
	}
	
	$.get( "ajax/test.html", $('#setculture').serialize(), doWhenFinished);
}

get '/ajax/test.html' d0
	render :formname, :layout => false, 

*/


function updateFavouredValues(){
	var attributes = ['body','heart','wits'];
	for(var y=0;y<3;y++) {
		var attribute = attributes[y];
		var outputField = document.getElementById( "favoured_" + attribute );
		var base = parseInt( document.getElementById(attribute).innerHTML );
		for(var x=1;x<4;x++) {
			var button = document.getElementById(attribute + "_" + x);
			if ( button.checked ) {
				outputField.innerHTML = "( " + (base + x) + " )";
			}
		}
	}

};


function setattributes(select)
{
	var option = select.options[select.selectedIndex];
	document.getElementById("body").innerHTML = (option.getAttribute("body"));
	document.getElementById("heart").innerHTML = (option.getAttribute("heart"));
	document.getElementById("wits").innerHTML = (option.getAttribute("wits"));
	updateFavouredValues();
};
