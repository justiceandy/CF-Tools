<!---
Google Maps Plot Tester
--->
<!DOCTYPE html>
<html>
<head>
<style type="text/css">
#map_canvas { width: 750px; height: 450px; }
</style>
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>

<!--- Get Marker Points From MySQL --->
<cfquery name="getPlots" datasource="cms">
	select * from locations
</cfquery>

<script type="text/javascript">

function initialize() {
	//Initialize Lat/Long GFunciton

	// Center Location
    var latlng = new google.maps.LatLng(35, -94);

	//Map Options
	 var myOptions = {
        zoom: 4,
        center: latlng,
        mapTypeId: google.maps.MapTypeId.HYBRID,
        panControl:false,
        zoomControl:false,
        streetViewControl:false,
        mapTypeControl:false,
				mapTypeControl:false,
				scaleControl:false,
				overviewMapControl:false,
				zoomControl: false,
		 		scaleControl: false,
				disableDoubleClickZoom: true,
    };

	// Declare map
     var map = new google.maps.Map(document.getElementById("map_canvas"),myOptions);

	<cfloop query="getPlots">
	<cfoutput>
		var marker#getPlots.currentRow#cords = new google.maps.LatLng#getPlots.latLong#;
		var marker#getPlots.currentRow# = new google.maps.Marker({
            map: map,
            position: marker#getPlots.currentRow#cords,
						fobID: '#getPlots.fobID#',
						icon: 'icon.png',
						animation: google.maps.Animation.DROP,
						infowindow: 'test',
						title: "#getPlots.address# #getPlots.city# #getPlots.state# #getPlots.zip#"
        });
		    google.maps.event.addListener(marker#getPlots.currentRow#, 'click', function() {
				 		map.setCenter(this.position);
            map.setZoom(18);
				 		var fob = this.fobID;
   				 $('.fobMapToolTip').load('fobToolTip.cfm?fobID='+fob);
        });
	</cfoutput>
	</cfloop>




}


// Show ToolTip Function
function showToolTip(fob){
	alert(fob);
	//get Fob ToolTip Div
	$('.fobMapToolTip').html(fob);
}

function showAdvForm(){
	var url = 'http://localhost:8500/cftools/maps/createFobForm.cfm?'
	$.get(url, function(data) {
		$('#cf_layoutareaorders').html(data);
	});
}

function showBasicForm(){
	var url = 'http://localhost:8500/cftools/maps/createFobForm.cfm?&formType=basic';
	$.get(url, function(data) {
		$('#cf_layoutareaorders').html(data);
	});
}


</script>

<script>

	function zoomPoint(fobID){
	alert(fobID.title);
}
</script>

</head>

<body onload="initialize()">

<div id="map_canvas">






</div>

<!--- map Tooltip Content --->
