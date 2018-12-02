<?php include "includes/init.php"?>
<?php
//checking if the index page was accessed
if (isset($_SESSION['user_id'])) {
  // NEEDTO: Change message if a person tries to access this page without passing index.php
  // print_r($_SESSION);
  // echo implode("\t|\t",$_SESSION);
  $_SESSION['token_code'] = generate_token();
  $header = "eIMG Lisbon ";

  // session_unset();
  session_destroy();

}else{
  // print_r($_SESSION);
  $header = "eIMG Lisbon - (change: ONLY ACCESS WITH USER_ID SET)";
  // redirect('index.php');
  // set_msg("Please choose what you want to do");
}
?>
<!DOCTYPE html>
<html lang="en-US">
<!-- Adding the HEADER file -->
<?php include "includes/header.php" ?>
<?php include "includes/css/style_eimg_index.php" ?>

<body>

  <!-- Button trigger modal -->
  <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal">
    Launch demo modal
  </button>

  <!-- Modal -->
  <div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="exampleModalLabel">Modal title</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          ...
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary">Save changes</button>
        </div>
      </div>
    </div>
  </div>
  
  <!-- ###############  Div that contains the header ############### -->
  <div id="header" class="col-md-12">
    <p class="text-center"><?php echo $header ?> </p>
  </div>

  <!-- ###############  Div that contains the sidebar ############### -->
  <div id="sidebar_div" class="leaflet-sidebar collapsed">
    <!-- Nav tabs -->
    <div id="sidebarTab_div" class="leaflet-sidebar-tabs">
      <ul id="sidebarTab_top" class="sidebarTab_ul" role="tablist">
        <li><a href="#home" role="tab"><i class="fa fa-home"></i></a></li>
      </ul>
      <ul id="sidebarTab_bottom" class="sidebarTab_ul" role="tablist">
        <li><a href="#settings" role="tab"><i class="fa fa-gear"></i></a></li>
      </ul>
    </div> <!-- close DIV class="sidebar-tabs"> -->

    <!-- Tab panes -->
    <div class="leaflet-sidebar-content">
      <!-- #### Start the content for each one of the tabs #### -->
      <!-- sidebar_tab: HOME -->
      <div class="leaflet-sidebar-pane" id="home">
        <h1 class="leaflet-sidebar-header"> <!-- Header of the tab -->
          Home<span class="leaflet-sidebar-close"><i class="fa fa-chevron-circle-left"></i></span>
        </h1>
        <div style="padding-top: 1vh;">
          <div id="div_Info" style="text-align: justify;text-justify: inter-word;">
          </div>
          <button id='btn_Finish' class='btn btn-info btn-block'>Finish...</button>
        </div>
      </div> <!-- close DIV id="home"> -->

      <!-- sidebar_tab: SETTINGS -->
      <div class="leaflet-sidebar-pane" id="settings">
        <h1 class="leaflet-sidebar-header"> <!-- Header of the tab -->
          Settings<span class="leaflet-sidebar-close"><i class="fa fa-chevron-circle-left"></i></span>
        </h1>
        <!-- <div id="google_translate_element"></div> -->
        <!-- SOURCE for design the translate box  https://jsfiddle.net/solodev/0stLrpqg/ -->

        </div> <!-- close DIV id="settings"> -->

      </div> <!-- close DIV class="sidebar-content"> -->
    </div><!-- close DIV id="sidebar"> -->
    <!-- <button id="btn_test">TEST</button> -->



    <!-- ###############  Div that contains the map application ############### -->
    <div id="mapdiv" class="col-md-12"></div>

    <script>
    //  ********* Global Variables Definition *********
    var mymap;
    var backgroundLayer;
    var ctlEasybutton;
    var mobileDevice = false;
    var ctlSidebar;
    var fgpDrawnItems;

    // # Logging variables

    // # To Delete


    //  ********* Mobile Device parameters and Function *********
    if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)){
      /*### DESCRIPTION: Check if the web application is being seen in a mobile device   */
      mobileDevice = true;
    };
    if(mobileDevice){
      /*### DESCRIPTION: Lock the screen of a mobile device in a landscape mode   */
      if("orientation" in screen) {
        var orientation_str = screen.orientation.type;
        var orientation_array = orientation_str.split("-");
        if( orientation_array[0] == "portrait"){
          // NEEDTO: Show this message in a modal div
          alert("Change the orientation of the device to: landscape");
        }
      }
    }
    $( window ).on( "orientationchange", function( event ) {
      /* ### FUNCTION DESCRIPTION: ADDDESCRIPTION  */
      //Do things based on the orientation of the mobile device
      if(mobileDevice){
        if("orientation" in screen) {
          var orientation_array = (screen.orientation.type).split("-");
          if( orientation_array[0] == "portrait"){
            // NEEDTO: Show this message in a modal div
            alert("Change the orientation of the device to: landscape");
          }else{  //landscape mode
            //Reloads the page
            //location.reload();
            console.log( orientation_array[0] );
          }
        }
      }
    });//END $( window ).on( "orientationchange", ())

    //  ********* Create Map *********
    $(document).ready(function(){
      /*### FUNCTION DESCRIPTION: Only run it here when all the DOM elements are already added   */
      //  ********* Map Initialization *********
      var southWest = L.latLng(38.702, -9.160),
          northEast = L.latLng(38.732, -9.118),
          mybounds = L.latLngBounds(southWest, northEast);

      mymap = L.map('mapdiv', {
        center:[38.715, -9.140],
        zoom:14,
        maxZoom: 18,
        minZoom: 13,
        attributionControl:false,
        zoomControl:false,
        maxBounds: mybounds,
        maxBoundsViscosity: 1.0
      });

      // mymap.on('dragend', function onDragEnd(){
      //   console.log(mymap.getBounds(),  mymap.getZoom());
      // });


      //Plugin leaflet-sidebar-v2: https://github.com/nickpeihl/leaflet-sidebar-v2
      ctlSidebar = L.control.sidebar({
        container:'sidebar_div',
        autopan: false,
        closeButton: false,
      }).addTo(mymap);

      //Initializing the feature group where all the drawn Objects will be stored
      fgpDrawnItems = new L.FeatureGroup();
      mymap.addLayer(fgpDrawnItems);
      fgpDrawnItems.addTo(mymap);

      // Adding the Historical Center of Lisbon
      var LyrHistCenter = new L.GeoJSON.AJAX("data/historical_center_lx.geojson").addTo(mymap);

      //Global variable, in order to other functions also be able to add the "Temp tab"
      // Create elements to populate the tab and add it to the sidebar
      // It creates an "li" element that only contains an "a" element of href="#"+{id}, in this case: "#temp_tab"
      // It also creates a "div" element where received the id={id}, in this case: id="temp_tab".
      // When the li element containing the "a" element of "href=={id}" is clicked. The "div" of "id=={id}" will be opened.


      // ********* Add Controls to the map *********
      //Add attribution to the map
      ctlAttribute = L.control.attribution({position:'bottomright'}).addTo(mymap);
      ctlAttribute.addAttribution('OSM');
      ctlAttribute.addAttribution('&copy; <a href="http://mastergeotech.info">Master in Geospatial Technologies</a>');
      //Control scale
      ctlScale = L.control.scale({position:'bottomright', metric:true, imperial:false, maxWidth:200}).addTo(mymap);
      //Control Latitude and Longitude
      if (!mobileDevice){
        ctlMouseposition = L.control.mousePosition({position:'bottomright'}).addTo(mymap);
      }
      // Adds a control using the easy button plugin
      ctlEasybutton = L.easyButton('fa-circle', function(){
        finishEditArea(true);
      }, 'NEEDTO: add a title here', {position:'topright'}).addTo(mymap);

      //Adds the basemap
      backgroundLayer = new L.tileLayer("http://{s}.tile.osm.org/{z}/{x}/{y}.png").addTo(mymap);

      // Add the Zoom control
      var ctlZoom = L.control.zoom({position:'bottomright'}).addTo(mymap);


    });//end btnFinish click event

        //  ********* JS Functions *********

        //  ********* jQuery Functions *********
        $("#btnRedirectPage").on("click", function () {
          //var text = $(this).attr("text");
          //alert("Clicked");
          window.location.href = 'eimg_draw.php';
        });

        </script>
      </body>
      </html>
