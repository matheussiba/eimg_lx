<?php include "includes/init.php"?>
<?php
//Creating token for the client who accessed the page
if (!isset($_SESSION['token_code'])) {
  // NEEDTO: Change message if a person tries to access this page without passing index.php
  set_msg("Please choose what you want to do");
  redirect('index.php');
}
// echo implode("\t|\t",$_SESSION);
?>

<!DOCTYPE html>
<html lang="en-US">
<!-- Adding the HEADER file -->
<?php include "includes/header_draw.php" ?>

<body>
  <!-- ###############  Div that contains the header ############### -->
  <div id="header" class="col-md-12">
    <p class="text-center">eimg Lisbon - Demo Version </p>
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
          <button id='btn_Finish' class='btn btn-default btn-block'>Finish...</button>
          <!-- <button id='' class='btn btn-primary btn-block'>foo button</button>
          <button id='' class='btn btn-success btn-block'>foo button</button>
          <button id='' class='btn btn-info btn-block'>foo button</button>
          <button id='' class='btn btn-warning btn-block'>foo button</button>
          <button id='' class='btn btn-danger btn-block'>foo button</button>
          <button id='' class='btn btn-link btn-block'>foo button</button> -->
        </div>
      </div> <!-- close DIV id="home"> -->

      <!-- sidebar_tab: SETTINGS -->
      <div class="leaflet-sidebar-pane" id="settings">
        <h1 class="leaflet-sidebar-header"> <!-- Header of the tab -->
          Settings<span class="leaflet-sidebar-close"><i class="fa fa-chevron-circle-left"></i></span>
        </h1>
        <!-- <div id="google_translate_element"></div> -->
        <!-- SOURCE for design the translate box  https://jsfiddle.net/solodev/0stLrpqg/ -->
        <div >
          <div class="ct-topbar" style="padding: 1vh;">
            <ul class="list-unstyled list-inline ct-topbar__list">
              <li class="ct-language">Choose a Language <i class="fa fa-arrow-down"></i>
                <ul class="list-unstyled ct-language__dropdown">
                  <li><a href="#lang-pt" class="lang-pt lang-select" data-lang="pt"><img src="/<?php  echo $root_directory?>/resources/images/flags/flag-pt-24x16px.png" alt="PORTUGAL"></a></li>
                  <li><a href="#lang-en" class="lang-us lang-select" data-lang="en"><img src="/<?php  echo $root_directory?>/resources/images/flags/flag-usa-24x16px.png" alt="USA"></a></li>
                  <li><a href="#lang-es" class="lang-es lang-select" data-lang="es"><img src="/<?php  echo $root_directory?>/resources/images/flags/flag-spain-24x16px.png" alt="SPAIN"></a></li>
                  <li><a href="#lang-fr" class="lang-fr lang-select" data-lang="fr"><img src="/<?php  echo $root_directory?>/resources/images/flags/flag-france-24x16px.png" alt="FRANCE"></a></li>
                  <li><a href="#lang-de" class="lang-de lang-select" data-lang="de"><img src="/<?php  echo $root_directory?>/resources/images/flags/flag-germany-24x16px.png" alt="GERMANY"></a></li>
                </ul>
              </li>
            </ul>
          </div>
          <div>
            <p>
              <button class="btn btn-primary btn-block" onclick="ctlSidebar.enablePanel('info')">enable Info panel</button>
              <button class="btn btn-primary btn-block" onclick="ctlSidebar.disablePanel('info')">disable Info panel</button>
            </p>
            <p><button class="btn btn-primary btn-block" onclick="alert('Delete This Button')">add user</button></b>'
            </div>
          </div>

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
    var jsn_draw;
    var ctlEasybutton;
    var mobileDevice = false;
    var ctlSidebar;
    var userpanel;
    var cntLikedPlaces = 0;
    var cntDislikedPlaces = 0;
    var statusAddLikeButton = "";
    var statusAddDislikeButton = "";
    var temp_tab_content;
    var color_line_place;
    var color_fill_place;
    var fgpDrawnItems;
    var place_id;

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
      mymap = L.map('mapdiv', {center:[38.7090, -9.1380], zoom:14, attributionControl:false, zoomControl:false});
      //Plugin leaflet-sidebar-v2: https://github.com/nickpeihl/leaflet-sidebar-v2
      ctlSidebar = L.control.sidebar({
        container:'sidebar_div',
        autopan: true,
        closeButton: false,
      }).addTo(mymap);

      //Initializing the feature group where all the drawn Objects will be stored
      fgpDrawnItems = new L.FeatureGroup();
      mymap.addLayer(fgpDrawnItems);
      fgpDrawnItems.addTo(mymap);

      //Global variable, in order to other functions also be able to add the "Temp tab"
      // Create elements to populate the tab and add it to the sidebar
      // It creates an "li" element that only contains an "a" element of href="#"+{id}, in this case: "#temp_tab"
      // It also creates a "div" element where received the id={id}, in this case: id="temp_tab".
      // When the li element containing the "a" element of "href=={id}" is clicked. The "div" of "id=={id}" will be opened.
      ctlSidebar.addPanel(returnTempTabContent());
      // Creates the title, to appear when the "li" element is hovered.
      createTitleLiByHref( "#temp_tab" , "Add a new Place" );
      createTitleLiByHref( "#home" , "Click to see the Home" );
      createTitleLiByHref( "#settings" , "Click to change settings" );

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
        alert("Populate this button!");
      }, 'NEEDTO: add a title here', {position:'topright'}).addTo(mymap);

      //Adds the basemap
      backgroundLayer = new L.tileLayer("http://{s}.tile.osm.org/{z}/{x}/{y}.png").addTo(mymap);

      // Add the Zoom control
      var ctlZoom = L.control.zoom({position:'bottomright'}).addTo(mymap);

      //  ********* Events on Map *********
      ctlSidebar.on('closing',function(){
        if(cntLikedPlaces+cntDislikedPlaces<6){
          document.getElementById('dynamic-icon-tab').className = 'fa fa-plus';
        }
      });
      ctlSidebar.on('content', function(e) {
        //console.log(e.id); //Returns the ID of the clicked tab
        if (getActiveTab()=="#temp_tab"){
          document.getElementById('dynamic-icon-tab').className = 'fa fa-question-circle';
        }
        // console.log(document.getElementById('sidebar_div'));

      });
      ctlSidebar.on('opening', function() {
        if (getActiveTab()=="#temp_tab"){
          document.getElementById('dynamic-icon-tab').className = 'fa fa-question-circle';
        }
      });

      mymap.on('mousemove', function(e){
        /*### FUNCTION DESCRIPTION: listener when the mouse is moving on the map   */
        var str = "Latitude: "+e.latlng.lat.toFixed(5)+"  Longitude: "+e.latlng.lng.toFixed(5)+"  Zoom Level: "+mymap.getZoom();
        $("#map_coords").html(str);
      });
      mymap.on('contextmenu', function(e){
        /* ### FUNCTION DESCRIPTION: listener when a click is given on the map  */
        // $("#divLog").text("Map Clicked... Random Number: "+(Math.floor(Math.random() * 100)).toString());
      });

      mymap.on('pm:drawend', function(e) {
          // e.shape; // the name of the shape being drawn (i.e. 'Circle')
      });

      mymap.on('pm:drawstart', function(e) {
        // console.log("working layer: ", e.workingLayer);
          // e.shape; // the name of the shape being drawn (i.e. 'Circle')
      });

      $( "#btn_Finish" ).click(function(){
        if(mymap.hasLayer(fgpDrawnItems)){
            fgpDrawnItems.eachLayer(function(layer){
              layer_id = layer.feature.properties.id;
              console.log(layer_id);
              if ( layer_id.split("-")[0] == "liked" ){
                var eval_nr = 1
                var eval_str = "Liked"
              }else{
                var eval_nr = 2
                var eval_str = "Disliked"
              }
              var att_nat = document.getElementById(layer_id+"_spanAtt-nat").checked;
              var att_open = document.getElementById(layer_id+"_spanAtt-open").checked;
              var att_ord = document.getElementById(layer_id+"_spanAtt-order").checked;
              var att_up = document.getElementById(layer_id+"_spanAtt-upkeep").checked;
              var att_hist = document.getElementById(layer_id+"_spanAtt-hist").checked;

              var cntChecks = 0;
              if( att_nat ){
                att_nat = 1;
                cntChecks++;
              } else { att_nat = 0; }
              if( att_open ){
                att_open = 1;
                cntChecks++;
              } else { att_open = 0; }
              if( att_ord ){
                att_ord = 1;
                cntChecks++;
              } else { att_ord = 0; }
              if( att_up ){
                att_up = 1;
                cntChecks++;
              } else { att_up = 0; }
              if( att_hist ){
                att_hist = 1;
                cntChecks++;
              } else { att_hist = 0; }

              //Converts Polygon to MultiPolygon, rounding the number of decimal places of coordinates to 6.
              var array_coordinate_rounded  = [];
              for (i=0; i<(layer.toGeoJSON().geometry.coordinates[0]).length; i++){
                var Longitude = Math.round(layer.toGeoJSON().geometry.coordinates[0][i][0] * 1000000) / 1000000; //rounded to 6 decimal places
                var Latitude = Math.round(layer.toGeoJSON().geometry.coordinates[0][i][1] * 1000000) / 1000000; //rounded to 6 decimal places
                array_coordinate_rounded.push([Longitude, Latitude]);
              }
              geojsn_layer = {type:'MultiPolygon',coordinates:[[array_coordinate_rounded]]};

              // console.log("MultiPolygon JSON obj:");
              // console.log(geojsn_layer);
              //
              // console.log("Saving Place to the database: "+ layer_id);
              // var objAjax= {
              //     tbl:'eimglx_areas_demo',
              //     geojson:JSON.stringify(geojsn_layer),
              //     eval_nr: eval_nr,
              //     eval_str: eval_str,
              //     att_nat: att_nat,
              //     att_open: att_open,
              //     att_ord: att_ord,
              //     att_up: att_up,
              //     att_hist: att_hist
              //   };
              // console.log(objAjax);
              $.ajax({
                  url:'eimg_draw-add_polys.php',
                  data:{tbl:'eimg_raw_polys',
                  geojson:JSON.stringify(geojsn_layer),
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
                  console.log(response);
                  // $("#divLog").text("Place added successfully...");
                },
                error:function(xhr, status, error){
                  console.log("Something went wront... "+error);
                }
              });
            });
        }

        $.ajax({
            url:'eimg_viewer-flatten_polys.php',
            //data:{ },
            type:'POST',
            success:function(response){
              console.log("flatten polygons worked fine");
            },//End success
            error:function(xhr, status, error){
              // $("#divLog").text("Something went wront... "+error);
              console.log("Something went wront... "+error);
            }//End error
        });//End AJAX call

        $.ajax({
          type: 'GET',
          url: 'destroy_session.php',
          success:function(response){
            console.log(response);
            window.location.href = 'eimg_viewer.php';
          }
        });

      });
    }); //END $(document).ready()


    //  ********* JS Functions *********
    //  ********* Sidebar Functions *********
    function create_placeTab(typeOfPlace){
      /* ### FUNCTION DESCRIPTION: Creates a new tab based on the option chosen in the #temp_tab: It will be either Liked or Disliked tab  */
      if(typeOfPlace=="liked"){
        var icon = "thumbs-up";
        cntLikedPlaces++;
        for (cnt = 1; cnt <= 3; cnt++) {
            if( !(searchTagByHref("#"+typeOfPlace+'-'+cnt.toString())) ){
              break;
            }
        }
        var tab_id = typeOfPlace+'-'+cnt.toString();
        var title = typeOfPlace.charAt(0).toUpperCase()+typeOfPlace.slice(1) +' Place '+cnt;

      }else if(typeOfPlace=="disliked"){
        var icon = "thumbs-down";
        cntDislikedPlaces++;
        var cnt = cntDislikedPlaces;
        for (cnt = 1; cnt <= 3; cnt++) {
            if( !(searchTagByHref("#"+typeOfPlace+'-'+cnt.toString())) ){
              break;
            }
        }
        var tab_id = typeOfPlace+'-'+cnt.toString();
        var title = typeOfPlace.charAt(0).toUpperCase()+typeOfPlace.slice(1) +' Place '+cnt;
      }
      // alert(tab_id);
      var str_newtab = "";
      // str_newtab += '<div class="container">';
      // str_newtab +=   '<div class="[ col-xs-12 col-sm-6 ]">';
      // str_newtab +=     '<input type="checkbox" name="fancy-checkbox-default" id="fancy-checkbox-default" autocomplete="off" />';
      // str_newtab +=     '<div class="[ btn-group ]">';
      // str_newtab +=       '<label for="fancy-checkbox-default" class="[ btn btn-default ]">';
      // str_newtab +=         '<span class="[ fa fa-check ]"></span>';
      // str_newtab +=         '<span></span>';
      // str_newtab +=       '</label>';
      // str_newtab +=       '<label for="fancy-checkbox-default" class="[ btn btn-default active ]">';
      // str_newtab +=         'Default Checkbox';
      // str_newtab +=       '</label>';
      // str_newtab +=     '</div>';
      // str_newtab +=   '</div>';
      // str_newtab +=  '</div>';
      // str_newtab +='</div>';

      str_newtab += '<div id="'+tab_id+'_divChosenAttr" style="display:none;" class="container text-left">';
      str_newtab +=   '<div class="[ col-xs-12 col-sm-6 ]">';
      // str_newtab +=    '<span id="'+tab_id+'_spanAtt-nat" style="text-decoration: line-through;">Naturalness</span><br />';
      // str_newtab +=    '<span id="'+tab_id+'_spanAtt-open" style="text-decoration: line-through;">Openness</span><br />';
      // str_newtab +=    '<span id="'+tab_id+'_spanAtt-order" style="text-decoration: line-through;">Order</span><br />';
      // str_newtab +=    '<span id="'+tab_id+'_spanAtt-upkeep" style="text-decoration: line-through;">Upkeep</span><br />';
      // str_newtab +=    '<span id="'+tab_id+'_spanAtt-hist" style="text-decoration: line-through;">Historical Significance</span>';
      str_newtab +=     '<input type="checkbox" id="'+tab_id+'_spanAtt-nat" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_nat">';
      str_newtab +=     '<label for="'+tab_id+'_spanAtt-nat">Naturalness</label><br />';
      str_newtab +=     '<input type="checkbox" id="'+tab_id+'_spanAtt-open" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_open">';
      str_newtab +=     '<label for="'+tab_id+'_spanAtt-open">Openness</label><br />';
      str_newtab +=     '<input type="checkbox" id="'+tab_id+'_spanAtt-order" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_order">';
      str_newtab +=     '<label for="'+tab_id+'_spanAtt-order">Order<br></label><br />';
      str_newtab +=     '<input type="checkbox" id="'+tab_id+'_spanAtt-upkeep" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_upkeep">';
      str_newtab +=     '<label for="'+tab_id+'_spanAtt-upkeep">Upkeep</label><br />';
      str_newtab +=     '<input type="checkbox" id="'+tab_id+'_spanAtt-hist" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_hist">';
      str_newtab +=     '<label for="'+tab_id+'_spanAtt-hist">Historical Significance</label><br />';

      str_newtab +=  '</div>';
      str_newtab += '</div>';
      str_newtab += '<div class="[ col-xs-12 ]">';
      str_newtab +=   '<h4>Click on the button to start drawing the area you '+typeOfPlace.slice(0, typeOfPlace.length-1)+'</h4>';
      str_newtab +=   '<div class="col-xs-6">';
      str_newtab +=     '<button id="'+tab_id+'_drawArea" class="btn btn-warning" onclick="drawArea(this)">';
      str_newtab +=     '<i class="fa fa-edit"></i>Draw Area';
      str_newtab +=     '</button>';
      str_newtab +=     '<button id="'+tab_id+'_saveArea" class="btn btn-primary" style="display:none;" onclick="saveArea(this)">';
      str_newtab +=     '<i class="fa fa-save"></i>Save Area';
      str_newtab +=     '</button>';
      str_newtab +=     '<button id="'+tab_id+'_editArea" class="btn btn-warning" style="display:none;" onclick="editArea(this)">';
      str_newtab +=     '<i class="fa fa-pen"></i>Edit Area';
      str_newtab +=     '</button>';
      str_newtab +=     '<button id="'+tab_id+'_finishEditArea" class="btn btn-success" style="display:none;" onclick="finishEditArea(this)">';
      str_newtab +=     '<i class="fa fa-pen"></i>Finish Edit Area';
      str_newtab +=     '</button>';
      str_newtab +=   '</div>';
      str_newtab +=   '<div class="col-xs-6">';
      str_newtab +=     '<button id="'+tab_id+'_removeArea" class="btn btn-danger" onclick="removeArea(this)">';
      str_newtab +=       '<i class="fa fa-times-circle"></i> Remove Area';
      str_newtab +=     '</button>';
      str_newtab +=   '</div>';
      str_newtab += '</div>';
      var newtab_content = {
        id:   tab_id,
        tab:  '<i class="fa fa-'+icon+'"></i>',
        title: title+
        '<span class="leaflet-sidebar-close" onclick="(function(){ctlSidebar.close()})">'+
        '<i class="fa fa-chevron-circle-left"></i>'+
        '</span>',
        pane: str_newtab
      };
      //Re-organize the sidebar tabs
      deleteTabByHref("#temp_tab", false);
      ctlSidebar.addPanel(newtab_content);
      createTitleLiByHref( "#"+tab_id , "See "+title );

      if ( cntLikedPlaces == 3){
        statusAddLikeButton = "disabled";
      }
      if ( cntDislikedPlaces == 3){
        statusAddDislikeButton = "disabled";
      }
      if ( (cntLikedPlaces + cntDislikedPlaces) < 6 ){
        // If num=6 doesn't add the tab
        ctlSidebar.addPanel(returnTempTabContent());
        createTitleLiByHref( "#temp_tab" , "Add a new Place" );
      }

      //Add class to the icoon of the new created tab. Liked:"green", Disliked:"red"
      document.querySelectorAll('[role="tab"]').forEach(function (e){
        if ( e.getAttribute("href").split("-")[0] == "#liked" ){
          e.classList.add("sidebar_tab_icon_liked");  //Change the class to the tab receive green as a background
        }
        if ( e.getAttribute("href").split("-")[0] == "#disliked" ){
          e.classList.add("sidebar_tab_icon_disliked"); //Change the class to the tab receive red as a background
        }
      });
      //Open sidebar tab
      ctlSidebar.open(tab_id);

    };//END create_placeTab()

    function deleteTabByHref(href, close_sidebar){
      /* ### FUNCTION DESCRIPTION: Deletes the tab based on the href that was passed
      ### If no href was passed it means that  a 'Remove Area' button inside a 'liked' or 'disliked' tab was clicked.
      ### Therefore this tab will be deleted tab was clicked. Therefore, this tab will be removed*/
      if ( href.split("-")[0] == "#liked"){
        cntLikedPlaces--;
        statusAddLikeButton = "";
      }else if ( href.split("-")[0] == "#disliked"){
        cntDislikedPlaces--;
        statusAddDislikeButton = "";
      }
      //If the tab being deleted is a liked or disliked palce, update the "#temp_tab" status of the buttons
      if ( ( href.split("-")[0] == "#liked") || ( href.split("-")[0] == "#disliked") ){
          // Update the temp_tab
          deleteTabByHref('#temp_tab');
          ctlSidebar.addPanel(returnTempTabContent());
          createTitleLiByHref( "#temp_tab" , "Add a new Place" );
      }

      //If after the deletion the sidebar needs to be closed: close_sidebar==true
      //close_sidebar==false for "#temp_id".
      if(close_sidebar){
        ctlSidebar.close();
      }

      //Search for all the "li" elements of the "sidebarTab_div" and remove the one which has
      var lis = document.querySelectorAll('#sidebarTab_div li');
      for(var i=0; li=lis[i]; i++) {
        //console.log( li.getElementsByTagName("a")[0].getAttribute("href") );
        if( li.getElementsByTagName("a")[0].getAttribute("href") == href ){
          li.parentNode.removeChild(li);
        }
      }
      //Remove the "div" element whose id == href.
      $( "div" ).remove( href );
    };//END deleteTabByHref()

    function getActiveTab(with_hash){
      /* ### FUNCTION DESCRIPTION: Returns the href of the tab that is active (open) in the sidebar.
      if "with_hash"==true returns f.e. '#temp_tab'. else returns 'temp_tab'. If no tab is opened, it returns null*/
      var lis = document.querySelectorAll('#sidebarTab_div li');
      var hrefActive;
      for(var i=0; li=lis[i]; i++) {
        if( $( li ).hasClass( "active" ) ){
          hrefActive = li.getElementsByTagName("a")[0].getAttribute("href");
        }
      }
      if ( hrefActive ) {
        //console.log( hrefActive );
        if( (typeof with_hash === "undefined") || (with_hash == true)){
          return hrefActive; //returns ex: "#temp_tab"
        }else{
          return hrefActive.substring(1, hrefActive.length); //returns ex: "temp_tab"
        }
      }else{
        return null;
      }
    };//END getActiveTab()

    function searchTagByHref(href){
      /* ### FUNCTION DESCRIPTION: returns true if a tab exists and false if not
         ### Data entry example: href = "#temp_tab"  */
      var lis = document.querySelectorAll('#sidebarTab_div li');
      var foundStatus = false;
      for(var i=0; li=lis[i]; i++) {
        //console.log( li.getElementsByTagName("a")[0].getAttribute("href") );
        if( li.getElementsByTagName("a")[0].getAttribute("href") == href ){
          var foundStatus = true;
        }
      }
      return foundStatus;
    };//END searchTagByHref()

    function createTitleLiByHref(href, newtitle){
      /* ### FUNCTION DESCRIPTION: Updates the title of the tab "li" element when it's hovered
         ### When a new tab is added using the API, the title receives a HTML, f.e:
         ### temp_tab_content = { title: 'Add new Place<span class="leaflet-sidebar-close"><i class="fa fa-times-circle"></i></span>'}
         ### All this element is shown when the user hover the button icon.
         ### Therefore, this function changes the title component of the "li" element to the text passed in the 'newtitle' variable
         */
      var lis = document.querySelectorAll('#sidebarTab_div li');
      for(var i=0; li=lis[i]; i++) {
        //console.log( li );
        if( li.getElementsByTagName("a")[0].getAttribute("href") == href ){
          // console.log(li.parentNode.innerHTML);
          $(li).attr("title", newtitle);
          //console.log( $( li ).attr( "title" ) );
        }
      }
    };//END createTitleLiByHref()

    function returnTempTabContent(){
      /* ### FUNCTION DESCRIPTION: Returns the content of the '#temp_tab' update the button status all the time it's called */
      temp_tab_content = {
            id:   'temp_tab',
            tab:  '<i id="dynamic-icon-tab" class="fa fa-plus"></i>',
            title: 'Add new Place\
            <span class="leaflet-sidebar-close" onclick="ctlSidebar.close()">'+
            '<i class="fa fa-chevron-circle-left"></i>'+
            '</span>',
            pane: '   <div id="col-xs-12">                                           \
            <h4>Which type of area do you want to draw?</h4>                            \
            <div class="col-xs-6">                                       \
            <button class="btn btn-success" onclick="create_placeTab(\'liked\')" '+statusAddLikeButton+'>   \
            <i class="fa fa-thumbs-up"></i>                                                       \
            Liked Place                                                                           \
            </button>                                               \
            </div>                                                    \
            <div class="col-xs-6">                                       \
            <button class="btn btn-danger" onclick="create_placeTab(\'disliked\')" '+statusAddDislikeButton+'>   \
            <i class="fa fa-thumbs-down"></i>                                                       \
            Disliked Place                                                                           \
            </button>                                               \
            </div>                                                    \
            </div>                                                      \
            '
          };
        return temp_tab_content;
    };//END returnTempTabContent()

    //  ********* Drawing Functions *********
    function saveAttributes(button_clicked_properties){
      /* ### FUNCTION DESCRIPTION: Function fired up when the user clicks on the 'Save Place' button of the pop up    */
      // place_id = ((button_clicked_properties.id).split("_"))[0];
      place_id = ((button_clicked_properties).split("_"))[0];

      document.getElementById(place_id+"_divChosenAttr").style.display = "block";
      // mymap.closePopup();
      //Open the sidebar
      ctlSidebar.open(place_id);

      return null;

      // if(mymap.hasLayer(fgpDrawnItems)){
      //     fgpDrawnItems.eachLayer(
      //         function(layer){
      //             layer_id = layer.feature.properties.id;
      //             // console.log(layer_id);
      //             if(layer_id == place_id){
      //               console.log("*************");
      //               console.log(layer.getPopup());
      //               console.log("*************");
      //               return;
      //             }
      //     });
      // }


      // strPopup +=   '<div class="text-left">';
      // strPopup +=     '<input type="checkbox" id="'+feature_id+'_cbxAtt-nat" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_nat">';
      // strPopup +=     '<label for="'+feature_id+'_cbxAtt-nat">Naturalness</label><br />';
      // strPopup +=     '<input type="checkbox" id="'+feature_id+'_cbxAtt-open" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_open">';
      // strPopup +=     '<label for="'+feature_id+'_cbxAtt-open">Openness</label><br />';
      // strPopup +=     '<input type="checkbox" id="'+feature_id+'_cbxAtt-order" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_order">';
      // strPopup +=     '<label for="'+feature_id+'_cbxAtt-order">Order<br></label><br />';
      // strPopup +=     '<input type="checkbox" id="'+feature_id+'_cbxAtt-upkeep" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_upkeep">';
      // strPopup +=     '<label for="'+feature_id+'_cbxAtt-upkeep">Upkeep</label><br />';
      // strPopup +=     '<input type="checkbox" id="'+feature_id+'_cbxAtt-hist" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_hist">';
      // strPopup +=     '<label for="'+feature_id+'_cbxAtt-hist">Historical Significance</label><br />';
      // strPopup +=   '</div>';

      // fgpDrawnItems.eachLayer(
      //     function(layer){
      //         layer_id = layer.feature.properties.id;
      //         if(layer_id == place_id){
      //           var activePopup = layer.getPopup();
      //           console.log(activePopup);
      //           // console.log(activePopup.options);
      //
      //           console.log(activePopup);
      //         }
      // });


      //Converts Polygon to MultiPolygon. Maybe coul just use
      // 'Polygon' -> 'Multipolygon' ':[[['->':[[[[' ']]]}'->']]]]}'
      // jsn_draw = {type:'MultiPolygon',coordinates:[lyrDraw.toGeoJSON().geometry.coordinates]};
      // console.log("MultiPolygon JSON obj:");
      // console.log(jsn_draw);
      // var jsn_draw_str = JSON.stringify(jsn_draw);
      // console.log("MultiPolygon JSON obj Stringified:");
      // console.log(jsn_draw_str);
      var cntChecks = 0;
      var att_nat = document.getElementById(place_id+"_cbxAtt-nat").checked;
      var att_open = document.getElementById(place_id+"_cbxAtt-open").checked;
      var att_ord = document.getElementById(place_id+"_cbxAtt-order").checked;
      var att_up = document.getElementById(place_id+"_cbxAtt-upkeep").checked;
      var att_hist = document.getElementById(place_id+"_cbxAtt-hist").checked;

      if( att_nat ){
        att_nat = 1;
        document.getElementById(place_id+"_spanAtt-nat").style.textDecoration = "none";
        cntChecks++;
      } else {
        att_nat = 0;
        document.getElementById(place_id+"_spanAtt-nat").style.textDecoration = "line-through";
      }
      if( att_open ){
        att_open = 1;
        document.getElementById(place_id+"_spanAtt-open").style.textDecoration = "none";
        cntChecks++;
      } else {
        att_open = 0;
        document.getElementById(place_id+"_spanAtt-open").style.textDecoration = "line-through";
       }
      if( att_ord ){
        att_ord = 1;
        document.getElementById(place_id+"_spanAtt-order").style.textDecoration = "none";
        cntChecks++;
      } else {
        att_ord = 0;
        document.getElementById(place_id+"_spanAtt-order").style.textDecoration = "line-through";
       }
      if( att_up ){
        att_up = 1;
        document.getElementById(place_id+"_spanAtt-upkeep").style.textDecoration = "none";
        cntChecks++;
      } else {
        att_up = 0;
        document.getElementById(place_id+"_spanAtt-upkeep").style.textDecoration = "line-through";
      }
      if( att_hist ){
        att_hist = 1;
        document.getElementById(place_id+"_spanAtt-hist").style.textDecoration = "none";
        cntChecks++;
      } else {
        att_hist = 0;
        document.getElementById(place_id+"_spanAtt-hist").style.textDecoration = "line-through";
       }

      console.log("nat: ", att_nat,"\nopen: ", att_open,"\nord: ", att_ord,"\nu: ", att_up,"\nhist: ", att_hist,"\nCnt: ",cntChecks);

      if(cntChecks == 0){
        // No attribute was selected
        alert("Please select at least one attribute!");
        return null;
      }else{
        //Close all Popups of the map
        document.getElementById(place_id+"_divChosenAttr").style.display = "block";
        mymap.closePopup();
        //Open the sidebar
        ctlSidebar.open(place_id);
      }

      return null;
      //
      //   $.ajax({
      //     url:'add_place.php',
      //     data:{tbl:'eimglx_areas_demo',
      //     geojson:JSON.stringify(jsn_draw),
      //     eval_nr: eval_nr,
      //     eval_str: eval_str,
      //     att_nat: att_nat,
      //     att_open: att_open,
      //     att_ord: att_ord,
      //     att_up: att_up,
      //     att_hist: att_hist
      //   },
      //   type:'POST',
      //   success:function(response){
      //     console.log(response);
      //     $("#divLog").text("Place added successfully...");
      //     lyrDraw.closePopup();
      //     lyrDraw.remove();
      //     refreshPlaces();
      //
      //   },
      //   error:function(xhr, status, error){
      //     $("#divLog").text("Something went wront... "+error);
      //   }
      // });
    };//END saveAttributes()

    function saveArea(button_clicked_properties){
      place_id = ((button_clicked_properties.id).split("_"))[0];
      alert(place_id);

      // document.getElementById(place_id+"_editArea").style.display="none";
      // document.getElementById(place_id+"_finishEditArea").style.display="block";
      // if(mymap.hasLayer(fgpDrawnItems)){
      //     fgpDrawnItems.eachLayer(
      //         function(layer){
      //             layer_id = layer.feature.properties.id;
      //             // console.log(layer_id);
      //             if(layer_id == place_id){
      //               //The layer was found so start the editing process...
      //               ctlSidebar.close();
      //               layer.setStyle({"weight": 5, "fillOpacity": 0.10 });
      //               layer.pm.enable();
      //               mymap.on('contextmenu', function(){
      //                layer.pm.disable();
      //                mymap.pm.disableDraw('Poly');
      //                layer.setStyle({"weight": 2, "fillOpacity": 0.20 });
      //                document.getElementById(place_id+"_editArea").style.display="block";
      //                document.getElementById(place_id+"_finishEditArea").style.display="none";
      //               });
      //               return;
      //             }
      //     });
      // }
    };//END saveArea()

    function drawArea(button_clicked_properties){
    /* ### FUNCTION DESCRIPTION: It tun after the user clicked on the button 'Draw Area' inside an liked or disliked tab */
      // Passing the ID gotten from the id of the button clicked to the global variable in order to be accesed in the anonymous functions
      place_id = ((button_clicked_properties.id).split("_"))[0];

      ctlSidebar.close();
      if (place_id.split("-")[0] == "liked") {
        color_line_place = "forestgreen";
        color_fill_place = "#0F0";
      }else{
        color_line_place = "#F00";
        color_fill_place = "#F00";
      }
      var drawingOptions = {
        // snapping
        snappable: true,
        snapDistance: 15,
        finishOn: 'contextmenu', // example events: 'mouseout', 'dblclick', 'contextmenu'
        templineStyle: {color: color_line_place, weight: 2} ,
        hintlineStyle: { color: color_line_place, weight: 2, dashArray: [5, 5] },
      };
      mymap.pm.enableDraw('Poly', drawingOptions);

      mymap.on('pm:create', function(e) {
        var lyrDraw = e.layer;
        // console.log(lyrDraw);
        //Initialize the attributes. We can name it the way we want
        var feature = lyrDraw.feature = lyrDraw.feature || {};
        feature.type = feature.type || "Feature"; //Could be the name we want
        var props = feature.properties = feature.properties || {};
        props.id = place_id;
        lyrDraw.setStyle({
                          //Border options
                          "color": color_line_place,"weight": 2,"opacity": 0.75,
                          //Fill options
                          'fillColor': color_fill_place, "fillOpacity": 0.20
                        });

        jsn_draw=lyrDraw.toGeoJSON().geometry;

        // console.log(fgpDrawnItems.getLayers());
        //Count the number of coordinates inside the JSON geometry.
        //In the case of polygon. The last element is equal to the first in order close the polygon.
        //So the subtraction of 1 gives us the exactly number of vertices of the drawn polygon
        var numberOfVertices = ((jsn_draw.coordinates[0]).length)-1;
        if (numberOfVertices < 3){
          alert("The area drawn is not a polygon. It has only "+numberOfVertices.toString()+" vertices.");
        }

        //Add the layer created to the feature group
        fgpDrawnItems.addLayer(lyrDraw);

        document.getElementById(place_id+"_drawArea").style.display="none";
        document.getElementById(place_id+"_editArea").style.display="block";

        // createQuestionaryPopUp(place_id);
        saveAttributes(place_id);
      });
    };//END drawArea()

    function editArea(button_clicked_properties){
      place_id = ((button_clicked_properties.id).split("_"))[0];
      // bringToFront()
      document.getElementById(place_id+"_editArea").style.display="none";
      document.getElementById(place_id+"_finishEditArea").style.display="block";
      if(mymap.hasLayer(fgpDrawnItems)){
          fgpDrawnItems.eachLayer(
              function(layer){
                  layer_id = layer.feature.properties.id;
                  // console.log(layer_id);
                  if(layer_id == place_id){
                    //The layer was found so start the editing process...
                    ctlSidebar.close();
                    layer.setStyle({"weight": 5, "fillOpacity": 0.10 });
                    layer.pm.enable();
                    mymap.on('contextmenu', function(){
                     layer.pm.disable();
                     mymap.pm.disableDraw('Poly');
                     layer.setStyle({"weight": 2, "fillOpacity": 0.20 });
                     document.getElementById(place_id+"_editArea").style.display="block";
                     document.getElementById(place_id+"_finishEditArea").style.display="none";
                    });
                    return;
                  }
          });
      }
    };//END editArea()

    function finishEditArea(button_clicked_properties){
      place_id = ((button_clicked_properties.id).split("_"))[0];
      // bringToFront()
      if(mymap.hasLayer(fgpDrawnItems)){
          fgpDrawnItems.eachLayer(
              function(layer){
                  layer_id = layer.feature.properties.id;
                  // console.log(layer_id);
                  if(layer_id == place_id){
                    //The layer was found so start the editing process...
                   layer.pm.disable();
                   mymap.pm.disableDraw('Poly');
                   layer.setStyle({"weight": 2, "fillOpacity": 0.20 });
                   return;
                  }
          });
      }
      document.getElementById(place_id+"_editArea").style.display="block";
      document.getElementById(place_id+"_finishEditArea").style.display="none";
    };//END finishEditArea()

    function removeArea(button_clicked_properties){
      place_id = ((button_clicked_properties.id).split("_"))[0];
      // console.log(fgpDrawnItems.getLayers() );
      if(mymap.hasLayer(fgpDrawnItems)){
          fgpDrawnItems.eachLayer(
              function(layer){
                  layer_id = layer.feature.properties.id;
                  // console.log(layer_id);
                  if(layer_id == place_id){
                    // layer.getPopup()._content = "";
                    // layer.getPopup().update();
                    fgpDrawnItems.removeLayer(layer);
                    // console.log(layer.getPopup());
                    // layer.closePopup();
                    return;
                  }
          });
      }
      deleteTabByHref('#'+place_id, true);
    };//END removeArea()

    function createQuestionaryPopUp(feature_id){
      /* ### FUNCTION DESCRIPTION: Creates the Popup based on the id of the area that the user just drew  */
      var strPopup = "";
      strPopup += '<div id="dlg_divFilterAttributes" class="text-center">';
      strPopup +=   '<h5 class="text-center">Attributes*: '+feature_id+' </h5>';
      strPopup +=   '<div class="text-left">';
      strPopup +=     '<input type="checkbox" id="'+feature_id+'_cbxAtt-nat" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_nat">';
      strPopup +=     '<label for="'+feature_id+'_cbxAtt-nat">Naturalness</label><br />';
      strPopup +=     '<input type="checkbox" id="'+feature_id+'_cbxAtt-open" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_open">';
      strPopup +=     '<label for="'+feature_id+'_cbxAtt-open">Openness</label><br />';
      strPopup +=     '<input type="checkbox" id="'+feature_id+'_cbxAtt-order" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_order">';
      strPopup +=     '<label for="'+feature_id+'_cbxAtt-order">Order<br></label><br />';
      strPopup +=     '<input type="checkbox" id="'+feature_id+'_cbxAtt-upkeep" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_upkeep">';
      strPopup +=     '<label for="'+feature_id+'_cbxAtt-upkeep">Upkeep</label><br />';
      strPopup +=     '<input type="checkbox" id="'+feature_id+'_cbxAtt-hist" class="dlg_cbx_fltAttributes" name="dlg_fltAttributes" value="att_hist">';
      strPopup +=     '<label for="'+feature_id+'_cbxAtt-hist">Historical Significance</label><br />';
      strPopup +=   '</div>';
      strPopup += '</div>';
      strPopup += '<button id="'+feature_id+'_btnEditAtt" class="btn btn-warning open-button" style="display:none;" onclick="alert(\'populate\')" >Edit</button>';
      strPopup += '<button id="'+feature_id+'_btnEditAtt" class="btn btn-sucess open-button" style="display:none;" onclick="alert(\'populate\')" >Finish Edit</button>';
      strPopup += '<button id="'+feature_id+'_btnSaveAtt" class="btn btn-primary open-button" style="display:block;" onclick="saveAttributes(this)" >Save</button>';
      strPopup += '<button id="'+feature_id+'_btnRemoveArea" class="btn btn-danger open-button" style="display:block;" onclick="removeArea(this)" >Remove Area</button>';

      var popupOptions = {
        keepInView:	false,	//Set it to true if you want to prevent users from panning the popup off of the screen while it is open.
        closeButton:	false,	//Controls the presence of a close button in the popup.
        autoClose:	false,	//Set it to false if you want to override the default behavior of the popup closing when another popup is opened.
        closeOnEscapeKey:	false,	//Set it to false if you want to override the default behavior of the ESC key for closing of the popup.
        closeOnClick:	false,	//Set it if you want to override the default behavior of the popup closing when user clicks on the map. Defaults to the map's closePopupOnClick option.
        className:	'',	//A custom CSS class name to assign to the popup.
      };

      fgpDrawnItems.eachLayer(
          function(layer){
              layer_id = layer.feature.properties.id;
              // console.log(layer_id);
              if(layer_id == place_id){
                //The layer was found so start the editing process...
                layer.bindPopup(strPopup, popupOptions);
                layer.openPopup();
                return;
              }
      });

    };//END createQuestionaryPopUp()

    //  ********* jQuery Functions *********
    $(".sidebarTab_ul").click(function() {
      if( (getActiveTab()!='#temp_tab') && ((cntLikedPlaces + cntDislikedPlaces) < 6) ){
        // ctlSidebar.removePanel('temp_tab');
        deleteTabByHref('#temp_tab');
        ctlSidebar.addPanel(returnTempTabContent());
        createTitleLiByHref( "#temp_tab" , "Add a new Place" );
      }
      if ( cntLikedPlaces < 3){
        statusAddLikeButton = "";
      }
      if ( cntDislikedPlaces < 3){
        statusAddDislikeButton = "";
      }
    });//END $(".sidebarTab_ul").click()

    //  ********* Google Translate Functions *********
    // usar 'class = "notranslate"' para não traduzir o elemento
    function googleTranslateElementInit() {
      /* "GOOGLE TRANSLATE:Inline SVG tags are the DOM elements that don't have the 'indexOf' function and \
      break when Google Translate a page. But it won't affect anything on the app" */
      new google.translate.TranslateElement({pageLanguage: 'en'}, 'google_translate_element');
    }
    function triggerHtmlEvent(element, eventName) {
      var event;
      if (document.createEvent) {
        event = document.createEvent('HTMLEvents');
        event.initEvent(eventName, true, true);
        element.dispatchEvent(event);
      } else {
        event = document.createEventObject();
        event.eventType = eventName;
        element.fireEvent('on' + event.eventType, event);
      }
    }
    jQuery('.lang-select').click(function() {
      var theLang = jQuery(this).attr('data-lang');
      jQuery('.goog-te-combo').val(theLang);
      //alert(jQuery(this).attr('href'));
      window.location = jQuery(this).attr('href');
      location.reload();
    });

    </script>
    <script type="text/javascript" src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>
  </body>
  </html>
