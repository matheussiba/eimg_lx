<?php include "includes/init.php" ?>
<!DOCTYPE html>
<html lang="en">

<!-- Adding the HEADER file -->
<?php include "includes/header.php" ?>

<body>

  <div id="header" clas0s="col-md-12">
    <h1 class="text-center">eimg Lisbon - Demo Version </h1>
  </div>
  <div id="side_panel" class="col-md-3">
    <!-- Side Panel Title-->
    <h1 class="text-center">Controler</h1>
    <button id='btnMerge' class='btn btn-primary btn-block'>Merge Features</button>

    <!-- Div to display a message to the user, if needed -->
    <div id="divLog"></div>

    <!-- Checkboxes to Select Liked and Disliked Places -->
    <div id="divFilterEvaluation" class="col-xs-12">
      <h3 class="text-center">Filter Liked/Disliked Places</h3>
      <div class="col-xs-6">
        <input type="checkbox" id="cbx_eval_l" class='cbx_fltPlaces' name='fltPlaces' value='1' checked>
        <label for="cbx_eval_l">Liked Places</label>
      </div>
      <div class="col-xs-6">
        <input type="checkbox" id="cbx_eval_d" class='cbx_fltPlaces' name='fltPlaces' value='2' checked>
        <label for="cbx_eval_d">Disliked Places</label>
      </div>
    </div>


    <div id="divFilterAttributes" class="col-xs-12">
      <h3 class="text-center">Filter Attributes</h3>
      <div class="col-xs-4">
        <!-- Metadata for values of the Attributes -->
        <input type="checkbox" id="cbx_att_nat" class='cbx_fltAttributes' name='fltAttributes' value="att_nat" checked>
        <label for="cbx_att_nat">Naturalness</label><br />
        <input type="checkbox" id="cbx_att_open" class='cbx_fltAttributes' name='fltAttributes' value="att_open" checked>
        <label for="cbx_att_open">Openness</label>
      </div>
      <div class="col-xs-4">
        <input type="checkbox" id="cbx_att_order" class='cbx_fltAttributes' name='fltAttributes' value="att_order" checked>
        <label for="cbx_att_order">Order</label><br />
        <input type="checkbox" id="cbx_att_upkeep" class='cbx_fltAttributes' name='fltAttributes' value="att_upkeep" checked>
        <label for="cbx_att_upkeep">Upkeep</label>
      </div>
      <div class="col-xs-4">
        <input type="checkbox" id="cbx_att_hist" class='cbx_fltAttributes' name='fltAttributes' value="att_hist" checked>
        <label for="cbx_att_hist">Historical Significance</label><br />
        <button id='btnCheckAtt' class='btn btn-primary btn-block'>
          <span id ="iconCheckAtt" class="glyphicon glyphicon-check"></span>
        </button>
      </div>
    </div>

  </div>
<div id="mapdiv" class="col-md-9"></div>

<!-- include the FOOTER file -->
<?php include "includes/footer.php" ?>

<!-- JS functions -->
<script>

// Global Variables
var mymap;
var backgroundLayer
var lyrPlaces;
var lyrHistCenter;
var jsn_draw;
var lyrDraw;
var lyrMerge;

$(document).ready(function(){

  //  ********* Map Initialization ****************
  mymap = L.map('mapdiv');
  mymap.setView([38.7090, -9.1380], 14);

  backgroundLayer = new L.tileLayer("http://{s}.tile.osm.org/{z}/{x}/{y}.png").addTo(mymap);
  //Adding the geoJSON of the historical center
  // lyrHistCenter = L.geoJSON.ajax('data/historical_center_lx.geojson', {
  //   style: {color:'darkgoldenrod'}
  // }).bindTooltip("<h5>Lisbon Historical Center</h5>").addTo(mymap);
  // lyrHistCenter.on('data:loaded', function() {
  //   mymap.fitBounds(lyrHistCenter.getBounds());
  // }.bind());

  // define drawtoolbar options. Leaflet PM
  var toolbarOptions = {
      position: 'topright', // toolbar position, options are 'topleft', 'topright', 'bottomleft', 'bottomright'
      drawMarker: false, // adds button to draw markers
      drawPolyline: false, // adds button to draw a polyline
      drawRectangle: false, // adds button to draw a rectangle
      drawPolygon: true, // adds button to draw a polygon
      drawCircle: false, // adds button to draw a cricle
      cutPolygon: false, // adds button to cut a hole in a polygon
      editMode: false, // adds button to toggle edit mode for all layers
      removalMode: true, // adds a button to remove layers
  };

  // add leaflet.pm controls to the map
  mymap.pm.addControls(toolbarOptions);

  var drawingOptions = {
      // snapping
      snappable: true,
      snapDistance: 10,
      // example events: 'mouseout', 'dblclick', 'contextmenu'
      // List: http://leafletjs.com/reference-1.2.0.html#interactive-layer-click
      finishOn: 'contextmenu',
  };

  // let polygons finish their shape on 'dblclick' or contextmenu
  mymap.pm.enableDraw('Poly', drawingOptions);
  mymap.pm.disableDraw('Poly');

  // listen to when a new layer is created
  mymap.on('pm:create', function(e) {

    lyrDraw = e.layer;

    jsn_draw=lyrDraw.toGeoJSON().geometry;
    var jsn_draw_str = JSON.stringify(jsn_draw);
    // console.log("jsn_draw");
    // console.log(jsn_draw);
    // console.log("jsn_draw_str");
    console.log(jsn_draw_str);

    var array_coordinate_rounded  = [];
    for (i=0; i<(lyrDraw.toGeoJSON().geometry.coordinates[0]).length; i++){
      var Longitude = Math.round(lyrDraw.toGeoJSON().geometry.coordinates[0][i][0] * 1000000) / 1000000; //rounded to 6 decimal places
      var Latitude = Math.round(lyrDraw.toGeoJSON().geometry.coordinates[0][i][1] * 1000000) / 1000000; //rounded to 6 decimal places
      array_coordinate_rounded.push([Longitude, Latitude]);
    }
    console.log(array_coordinate_rounded);
    //console.log(lyrDraw.toGeoJSON().geometry.coordinates);

    jsn_draw = {type:'MultiPolygon',coordinates:[[array_coordinate_rounded]]};
    // console.log(jsn_draw);
    console.log(JSON.stringify(jsn_draw));

    //'{"type":"MultiPolygon","coordinates":[[['

    createQuestionaryPopUp();

    //$("#btnMerge").removeAttr("disabled");

    //console.log("Type: "+e.shape+"\nGeometry: "+JSON.stringify(jsn));
  });

  //Add the
  refreshPlaces();


  //  ********* Events on Map *********
  mymap.on('mousemove', function(e){
    var str = "Latitude: "+e.latlng.lat.toFixed(5)+"  Longitude: "+e.latlng.lng.toFixed(5)+"  Zoom Level: "+mymap.getZoom();
    $("#map_coords").html(str);
  });
  mymap.on('click', function(e){
    // $("#divLog").text("Map Clicked... Random Number: "+(Math.floor(Math.random() * 100)).toString());
  });


  //  ********* Events on Layers *********
  // lyrHistCenter.on('mouseover', function (e) {
  //   this.openPopup();
  // });
  // lyrHistCenter.on('mouseout', function (e) {
  //   this.closePopup();
  // });

}); //END $(document).ready function


//  ********* jQuery Functions *********
$("#btnCheckAtt").on("click", function () {
  if( $('#iconCheckAtt').hasClass('glyphicon glyphicon-check') ){ //The user wants to check All attributes
      $('input[type=checkbox].cbx_fltAttributes').each(function () {
        $(this).prop('checked', true);
      });
      //Change the glyphicon icon to uncheked
      $( "#iconCheckAtt" ).toggleClass( "glyphicon-unchecked" );
      $( "#iconCheckAtt" ).removeClass('glyphicon-check');
      //$("#iconCheckAtt").addClass('glyphicon-check').removeClass('glyphicon-unchecked');
  }else{ // The user wants to uncheck all
      $('input[type=checkbox].cbx_fltAttributes').each(function () {
        $(this).prop('checked', false);
      });
      //Change the glyphicon icon to check
      $( "#iconCheckAtt" ).toggleClass( "glyphicon-check" );
      $( "#iconCheckAtt" ).removeClass('glyphicon-unchecked');
    };
  refreshPlaces();
});

$("#btnMerge").on("click", function () {
  //var text = $(this).attr("text");
  //alert("Clicked");

  $.ajax({
      url:'merge_features.php',
      //data:{ },
      type:'POST',
      success:function(response){
        //console.log(response);
        lyrPlaces.remove();
        lyrMerge = L.geoJSON(JSON.parse(response),{
          style:stylePlaces
        });
        lyrMerge.addTo(mymap);
        $("#divLog").text("Merge added successfully...");
      },
      error:function(xhr, status, error){
        $("#divLog").text("Something went wront... "+error);
      }
  });

});



$("div").on("click", '.open-button', function () {
  var text = $(this).attr("text");
  //console.log(text);
});


$( "#divFilterEvaluation" ).on( "change", ".cbx_fltPlaces", function() {
  refreshPlaces();
});

$( "#divFilterAttributes" ).on( "change", ".cbx_fltAttributes", function() {
  refreshPlaces();
});

$( "#dlg_divFilterEvaluation" ).on( "change", ".dlg_cbx_fltAttributes", function() {
  alert("Changed");
});
//
// $( "#dlg_divFilterAttributes" ).on( "change", ".dlg_cbx_fltAttributes", function() {
//   alert("Changed");
// });

//  ********* JS Functions *********
function createQuestionaryPopUp(){
  var strPopup = "";
  strPopup += '<div id="dlg_divFilterEvaluation" class="text-center">';
  strPopup +=   '<h5 class="text-center">Evaluation*: </h5>';
  strPopup +=   '<div class="text-left">';
  strPopup +=     '<input type="radio" id="dlg_radio_l" name="dlg_radio_eval" value="Liked"><label for="dlg_radio_l">Like</label><br />';
  strPopup +=     '<input type="radio" id="dlg_radio_d" name="dlg_radio_eval" value="Disliked"><label for="dlg_radio_d">Dislike</label><br />';
  strPopup +=   '</div>';
  strPopup += '</div>';
  strPopup += '<div id="dlg_divFilterAttributes" class="text-center">';
  strPopup +=   '<h5 class="text-center">Attributes*: </h5>';
  strPopup +=   '<div class="text-left">';
  strPopup +=     '<input type="checkbox" id="dlg_cbx_att_nat" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_nat">';
  strPopup +=     '<label for="dlg_cbx_att_nat">Naturalness</label><br />';
  strPopup +=     '<input type="checkbox" id="dlg_cbx_att_open" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_open">';
  strPopup +=     '<label for="dlg_cbx_att_open">Openness</label><br />';
  strPopup +=     '<input type="checkbox" id="dlg_cbx_att_order" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_order">';
  strPopup +=     '<label for="dlg_cbx_att_order">Order<br></label><br />';
  strPopup +=     '<input type="checkbox" id="dlg_cbx_att_upkeep" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_upkeep">';
  strPopup +=     '<label for="dlg_cbx_att_upkeep">Upkeep</label><br />';
  strPopup +=     '<input type="checkbox" id="dlg_cbx_att_hist" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_hist">';
  strPopup +=     '<label for="dlg_cbx_att_hist">Historical Significance</label><br />';
  strPopup +=   '</div>';
  strPopup += '</div>';
  strPopup += '<button id="btnSave" class="btn btn-primary open-button" onclick="savePlace(this)" >Save</button>';

  lyrDraw.bindPopup(strPopup);
  lyrDraw.openPopup();
};



function savePlace(elem){
  //input[type=checkbox].cbx_fltPlaces
  //strPopup +=     '<input type="checkbox" id="dlg_cbx_att_open" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_open">';
    var eval_str;
    var att_nat;
    var att_open;
    var att_ord;
    var att_up;
    var att_hist;
    var cntChecks = 0;

    //alert("Button clicked");
    //working
    alert(document.getElementById("dlg_cbx_att_nat").checked);
    alert( $(elem).attr('checked'));

    //console.log( $('#dlg_cbx_att_nat').attr('checked'))

    // //
    // if( $('#dlg_radio_l').attr('checked') ){
    //   eval_str = "Liked";
    //   eval_nr = 1;
    // }else if( $('#dlg_radio_d').attr('checked') ){
    //   att_nat = "Disliked";
    //   eval_nr = 2;
    // }
    // // else{
    // //
    // //   alert("Please evaluate the place as Liked or Disliked");
    // //   return null;
    // // }
    //
    // if( $('#dlg_cbx_att_nat').attr('checked') ){
    //   att_nat = 1;
    //   cntChecks++;
    // } else { att_nat = 0; }
    // if( $('#dlg_cbx_att_open').attr('checked') ){
    //   att_open = 1;
    //   cntChecks++;
    // } else { att_open = 0; }
    // if( $('#dlg_cbx_att_order').attr('checked') ){
    //   att_ord = 1;
    //   cntChecks++;
    // } else { att_ord = 0; }
    // if( $('#dlg_cbx_att_upkeep').attr('checked') ){
    //   att_up = 1;
    //   cntChecks++;
    // } else { att_up = 0; }
    // if( $('#dlg_cbx_att_hist').attr('checked') ){
    //   att_hist = 1;
    //   cntChecks++;
    // } else { att_hist = 0; }
    //
    // if (cntChecks == 0){
    //   alert("Please select at least one attribute");
    //   return null;
    // }
    //

     eval_nr = Math.floor(Math.random() * 2) + 1;
     if(eval_nr==1){
       eval_str = "Liked";
     }else if(eval_nr==2){
       eval_str = "Disliked";
     }

     att_nat = Math.floor(Math.random() * 2); //Integer, either 0 or 1
     att_open = Math.floor(Math.random() * 2);
     att_ord = Math.floor(Math.random() * 2);
     att_up = Math.floor(Math.random() * 2);
     att_hist = Math.floor(Math.random() * 2);

     console.log(
       eval_nr,
       eval_str,
       att_nat,
       att_open,
       att_ord,
       att_up,
       att_hist
     );

    $.ajax({
        url:'add_place.php',
        data:{tbl:'eimglx_areas_demo',
            geojson:JSON.stringify(jsn_draw),
            eval_nr: eval_nr,
            eval_str: eval_str,
            att_nat: att_nat,
            att_open: att_open,
            att_ord: att_ord,
            att_up: att_up,
            att_hist: att_hist
          },
        type:'POST',
        success:function(response){
          //console.log(response);
          $("#divLog").text("Place added successfully...");
          lyrDraw.closePopup();
          lyrDraw.remove();
          refreshPlaces();

        },
        error:function(xhr, status, error){
          $("#divLog").text("Something went wront... "+error);
        }
    });

}


function refreshPlaces(){
  var cntChecks = 0;
  var whereClause = "";

  // Checkboxes Liked and Disliked places
  $('input[type=checkbox].cbx_fltPlaces:checked').each(function () {
    if(cntChecks==0){ //First Run
      whereClause += 'eval_nr IN (';
      whereClause += ($(this).attr("value")).toString();
      whereClause += ')';
    }else{ //Second Run
      whereClause = whereClause.slice(0, -1); //slice the last char of the string: "eval_nr IN (1"

      whereClause += ','+($(this).attr("value")).toString();
      whereClause += ')';
    };
    cntChecks += -1; //Just to add a AND in the SQL query below
  });

  //in the code above ".each(function () {" the possible values of cntChecks is 0, -1 or -2;
  //It's because there're 2 categories. Liked and Disliked places.
  //If only on checkbox is checked, cntChecks == -1; If none is checked, cntChecks == 0
  //If all 2 checkboxes are checked; cntChecks == -2;
  if(cntChecks!=0){ // it means at least one is checked
    // Checkboxes of attributes
    $('input[type=checkbox].cbx_fltAttributes:checked').each(function () {
      if(cntChecks < 0){ //it means that there's some '.cbx_fltPlaces' checked
        whereClause += ' AND ';
        cntChecks=0;
      };
      if(cntChecks==0){ //First runs
        whereClause += '(';
        whereClause += $(this).attr("value")+' = 1';
        whereClause += ')';
      }else{ //Other runs
        whereClause = whereClause.slice(0, -1); //slice the last char of the string: "(att_nat = 1"
        whereClause += ' OR '+ $(this).attr("value")+' = 1)';
      };
      cntChecks++;
    });
  }else{
    //it means that there's no '.cbx_fltPlaces' checked.
    //It will not matter the attribute select. No features must be seen
    whereClause = "(1=2)"; //This is a false claure, returning no elements
  };

  if(cntChecks < 0){ // it means none attributes' checkboxes is checked.
    whereClause = "(1=2)";
  }
  //console.log("whereClause: "+whereClause);
  $.ajax({
    url:'load_gsp_data.php',
    data: {tbl: "eimglx_areas_demo", where: whereClause},
    type:'POST',
    //data:{filter:$("filterPlaces").val()},
    success:function(response){
      if (response.substring(0,5)=="ERROR"){
        alert(response);
      }else{
        //console.log(response);
        if (lyrPlaces) {
          mymap.removeLayer(lyrPlaces);
          $("#divLog").html("");
        };
        lyrPlaces=L.geoJSON(JSON.parse(response),{
          style:stylePlaces,
          onEachFeature:onEachPlace
        });
        lyrPlaces.addTo(mymap);

      }//end else
    },//end success
    error: function(xhr, status, error){
      alert("ERROR: "+error);
    }
  }); // End ajax
}//End refreshPlaces

function onEachPlace(json, lyr) {
  var att = json.properties;
  strPopup = "<h4>"+att.eval_str+" place:"+"</h4><b>Attributes:</b>";
  if( att.att_nat == 1 ){strPopup += "<br />Naturalness"};
  if( att.att_open == 1 ){strPopup += "<br />Openness"};
  if( att.att_order == 1 ){strPopup += "<br />Order"};
  if( att.att_upkeep == 1 ){strPopup += "<br />Upkeep"};
  if( att.att_hist == 1 ){strPopup += "<br />Historical Significance"};

  lyr.bindPopup(strPopup);
  //WORKING Turf function -- Keep it ere as a test
  // var jsnBuffer = turf.buffer(lyr.toGeoJSON(), 0.1, 'kilometers');
  // jsnLayer = L.geoJSON(jsnBuffer, {style:{color:'yellow', dashArray:'5,5', fillOpacity:0}}).addTo(mymap);
}

function stylePlaces(json) {
  var att = json.properties;
  switch (att.eval_nr) { // this field only have 1 or 2s
    case 1: //In the field "eval_nr" means liked places
    return {color:'green'};
    break;
    case 2: //In the field "eval_nr" means disliked places
    return {color:'red'};
    break;
    default: //If something went wrong it'll display grey
    return {color:'grey'}
  }
}

$("filterPlaces").change(function(){
  refreshPlaces();
});

</script>
</body>
</html>
