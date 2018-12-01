<?php include "../includes/init.php"?>
<?php
//checking if the index page was accessed
if (isset($_SESSION['user_id'])) {
  // NEEDTO: Change message if a person tries to access this page without passing index.php
  // print_r($_SESSION);
  // echo implode("\t|\t",$_SESSION);
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
<?php include "../includes/header_draw.php" ?>

<body>
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
        <li><a href="#info" role="tab"><i class="fa fa-info-circle"></i></a></li>
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

        <div id="text_sidebar_home_1" style="text-align: justify;text-justify: inter-word; padding-top: 5px;">
          <h4 style="padding-bottom: 5px;">
            After you create at least 2 areas (1 liked and 1 disliked) come here again and press:
          </h4>
          <button id='btn_Finish' class='btn btn-info btn-block'>Finish...</button>
        </div>

        <div class="sidebarContentParent">
          <div id="text_sidebar_home_2" class="sidebarContentChild" style="width: 100%; text-align: center;">
            <span>
              <p>
                To create a new area go to:
              </p>
            </span>
              <span>
              <button id='btn_goInfoTab' class='btn btn-default btn-block' onclick="ctlSidebar.open('temp_tab')"><i class="fa fa-plus"></i> Create New Tab</button>
            </span>
          </div>
          <div id="text_sidebar_home_2" class="sidebarContentChild" style="width: 100%; text-align: center;">
            <span>
              <p>
                For more details go to:
              </p>
            </span>
              <span>
              <button id='btn_goInfoTab' class='btn btn-default btn-block' onclick="ctlSidebar.open('info')"><i class="fa fa-info-circle"></i> Info Tab</button>
            </span>
          </div>
        </div>


      </div> <!-- close DIV id="home"> -->

      <!-- sidebar_tab: info -->
      <div class="leaflet-sidebar-pane" id="info">
        <h1 class="leaflet-sidebar-header"> <!-- Header of the tab -->
          Information<span class="leaflet-sidebar-close"><i class="fa fa-chevron-circle-left"></i></span>
        </h1>

        <div>
          Informações serão adicionadas no domingo: 01/12/2018
        </div>
        <!-- <div class="sidebarContentParent">
          <div class="sidebarContentChild">
              <span> Elem 1 </span>
          </div>
          <div class="sidebarContentChild">
              <span> Elem 1 </span>
              <span> Elem 2dsadas </span>
              <span style="display:none;"> Elem 2dsadas </span>
              <span style="display:none;"> Elem 2dsadas </span>
              <span> Elem 2dsadas </span>
          </div>
        </div>

        <div class="sidebarContentParent">
          <p> See the video for helping you in the application</p>
          <div class="sidebarContentChild">
            <span>
              video
              <iframe width="448" height="252" src="http://www.youtube.com/embed/C0DPdy98e4c" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
            </span>
          </div>
        </div> -->



      </div> <!-- close DIV id="info"> -->

      </div> <!-- close DIV class="sidebar-content"> -->
    </div><!-- close DIV id="sidebar"> -->
    <!-- <button id="btn_test">TEST</button> -->

    <!-- ###############  Div that contains the Modal ############### -->
    <div id="dlgUsabilityQuest" class="modal">
      <div id='form' class="modal-content col-md-7 col-md-offset-4">
        <div class="form-group row">
          <div class="col-sm-2">
            <span id="idDisplay" class="pull-right btnClose">x</span>
          </div>
          <div class="col-sm-8">
            <h4>Usability Questionary</h4>
          </div>
        </div>
        <div class="form-group row">
          <div class="col-sm-6">
            <input type="text" class="form-control" id="latitude" placeholder="Latitude">
          </div>
          <div class="col-sm-6">
            <input type="text" class="form-control" id="longitude" placeholder="Longitude">
          </div>
        </div>
        <div class="form-group row">
          <div class="col-sm-6">
            <select id="category" class="form-control">
              <option value="Park">Park</option>
              <option value="Museum">Museum</option>
              <option value="Place">Place</option>
              <option value="Neighborhood">Neighborhood</option>
              <option value="Pueblo Magico">Pueblo Magico</option>
            </select>
          </div>
        </div>
        <div class="form-group row">
          <div class="col-sm-12">
            <input type="text" class="form-control" id="website" placeholder="Web URL">
          </div>
        </div>
        <div id="editButtons">
          <button id="btnUpdate" class="btn btn-primary">Submit</button>
          <button class="btn btn-danger pull-right btnClose">Close</button>
        </div>
      </div>
    </div>

    <!-- ###############  Div that contains the map application ############### -->
    <div id="mapdiv" class="col-md-12"></div>

    <script>
    //  ********* Global Variables Definition *********
    var mymap;
    var mymapOverview;
    var backgroundLayer;
    var mapbox_overview;
    var jsn_draw;
    var LyrHistCenter;
    var ctlFinishArea;
    var ctlRemoveLastVertex;
    var ctlCancelArea;
    var layerControls;
    var mobileDevice = false;
    var ctlSidebar;
    var userpanel;
    var statusAddLikeButton = "";
    var statusAddDislikeButton = "";
    var temp_tab_content;
    var color_line_place;
    var color_fill_place;
    var fgpDrawnItems;
    var place_id;
    var previousTab;
    var activeTab;
    var sidebarOpened;
    var clickedLayerId=null;
    var editMode = false;
    var createMode = false;
    var newTabCreated = false;
    var setStyle_normal = {"weight": 2, "fillOpacity": 0.20 };
    var setStyle_edit = {"weight": 5, "fillOpacity": 0.1};
    var setStyle_clicked = {"weight": 3.5, "fillOpacity": 0.20};
    var cntCheckedCbx;
    var finishCreationControl;
    var firstClickLatLng;

    // # Logging variables
    var cnt_SidebarOpens = 0;
    var cnt_SidebarChangeTab = 0;
    var cnt_LikedPlaces = 0;
    var cnt_DislikedPlaces = 0;
    var num_mapClick;

    var log_functions = true;
    // # To Delete
    var cnt_test = 0;

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
    $( window ).on( "orientationchange", function( event ){
      /* DESCRIPTION: ADDDESCRIPTION  */
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
      /*DESCRIPTION: Only run it here when all the DOM elements are already added   */
      //  ********* Map Initialization *********
      //Adds the basemap
      var basemap_osm = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
        attribution: '&copy;<a href="http://osm.org/copyright">OSM</a>'
      });

      var basemap_mapbox = L.tileLayer("https://api.mapbox.com/styles/v1/mapbox/streets-v9/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZ2lzMm1hdGhldXMiLCJhIjoiY2lsYXRkcTQ2MGJudXVia25ueXZyMzJkcCJ9.sc74TfXfIWKE2Xw3aVcNvw", {
        attribution: '&copy;<a href="https://www.mapbox.com/feedback/">Mapbox</a>'
      });
      var basemap_Gterrain = L.tileLayer('http://{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}',{
          subdomains:['mt0','mt1','mt2','mt3']
      });
      var basemap_Gimagery = L.tileLayer('http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',{
          subdomains:['mt0','mt1','mt2','mt3']
      });
      var basemap_GimageHybrid = L.tileLayer('http://{s}.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}',{
          subdomains:['mt0','mt1','mt2','mt3']
      });

      var basemap_WorldImagery = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
        attribution: '&copy;<a href="https://www.esri.com/en-us/home">Esri</a>'
      });

      var Hydda_RoadsAndLabels = L.tileLayer('https://{s}.tile.openstreetmap.se/hydda/roads_and_labels/{z}/{x}/{y}.png', {
        name: 'overlay',
      });
      // We can't reuse the layers from the main map for the overview, so we
      // need to create a second instance of each layer option
      mapbox_overview = L.tileLayer("https://api.mapbox.com/styles/v1/mapbox/streets-v9/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZ2lzMm1hdGhldXMiLCJhIjoiY2lsYXRkcTQ2MGJudXVia25ueXZyMzJkcCJ9.sc74TfXfIWKE2Xw3aVcNvw", {
        name: 'basemap'
      });

      // defining the max bounds the user can see
      //previous values
      // var southWest = L.latLng(38.702, -9.160);
      // var northEast = L.latLng(38.732, -9.118);
      // var mybounds =  L.latLngBounds(southWest, northEast);
      // var center =    L.latLng(38.715, -9.140);
      var southWest = L.latLng(38.690, -9.180);
      var northEast = L.latLng(38.740, -9.100);
      var mybounds =  L.latLngBounds(southWest, northEast);
      var center =    L.latLng(38.716, -9.150);
      //Create the Leaflet map elemetn
      mymap = L.map('mapdiv', {
        center: center,
        layers: basemap_mapbox,
        zoom:14,
        maxZoom: 18,
        minZoom: 14,
        attributionControl:false,
        zoomControl:false,
        maxBounds: mybounds,
        maxBoundsViscosity: 1.0
      });

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
      LyrHistCenter = new L.GeoJSON.AJAX("<?php  echo $root_directory?>data/historical_center_lx.geojson").addTo(mymap);
      LyrHistCenter.on('data:loaded', function() {
        console.log(LyrHistCenter.getBounds());
        openInfoPopUp(LyrHistCenter.getBounds().getCenter(), "  <h4>This is the historical center of Lisbon :)   </h4>");
      });

      //Global variable, in order to other functions also be able to add the "Temp tab"
      // Create elements to populate the tab and add it to the sidebar
      // It creates an "li" element that only contains an "a" element of href="#"+{id}, in this case: "#temp_tab"
      // It also creates a "div" element where received the id={id}, in this case: id="temp_tab".
      // When the li element containing the "a" element of "href=={id}" is clicked. The "div" of "id=={id}" will be opened.
      ctlSidebar.addPanel(returnTempTabContent());
      // Creates the title, to appear when the "li" element is hovered.
      createTitleLiByHref( "#temp_tab" , "Add a new Place" );
      createTitleLiByHref( "#home" , "Click to see the Home" );
      createTitleLiByHref( "#info" , "Click to see information" );

      // ********* Add Controls to the map *********
      //Add attribution to the map
      ctlAttribute = L.control.attribution({position:'bottomright'}).addTo(mymap);
      ctlAttribute.addAttribution('OSM');
      ctlAttribute.addAttribution('&copy;<a href="http://mastergeotech.info">Master GeoTech</a>');
      ctlAttribute.addAttribution('&copy;<a href="https://github.com/codeofsumit/leaflet.pm">LeafletPM</a>');

      //Control scale
      ctlScale = L.control.scale({position:'bottomright', metric:true, imperial:false, maxWidth:200, }).addTo(mymap);
      //Control Latitude and Longitude
      if (!mobileDevice){
        ctlMouseposition = L.control.mousePosition({position:'bottomright'}).addTo(mymap);
      }

      // Add the overview control to the map
      // mymapOverview = L.control.overview([mapbox_overview]).addTo(mymap);
      mymapOverview = L.control.overview({
        position: 'bottomright',
        onAfterInitLayout: function (overview) {
          console.log(overview);
        }
      }).addTo(mymap);

      layerControls = L.control.layers(
        {
          '<i class="fas fa-map-marked"></i>': basemap_mapbox,
          '<i class="fas fa-mountain"></i>': basemap_Gterrain,
          '<i class="fas fa-globe-americas"></i>': basemap_GimageHybrid,
          // '<i class="fas fa-image"></i>': basemap_WorldImagery
        }, null, {collapsed: false}
      ).addTo(mymap);

      // Adds a control using the easy button plugin
      ctlFinishArea = L.easyButton('fa-project-diagram', function(){finishCreation();}, 'Click to complete the drawing');
      ctlRemoveLastVertex = L.easyButton('fa-undo-alt', function(){removeLastVertex();}, 'Click to remove the last vertex');
      ctlCancelArea = L.easyButton('fa-times-circle', function(){removeArea(place_id, true);}, 'Click to cancel the drawing');
      var ctlCreationToolbar = L.easyBar([ ctlFinishArea, ctlRemoveLastVertex, ctlCancelArea],{position:'topright'});

      var container = L.DomUtil.create('div', 'infobox_for_toolbar leaflet-bar leaflet-control', ctlCreationToolbar.getContainer());
      container.title="Toolbar Instructions";
      container.innerHTML = '\
      <p>Finish drawing</p> \
      <p style="padding-top:5px;">Remove last vertex</p> \
      <p style="padding-top:5px;">Cancel Drawing</p>';
      // styles: .infobox_for_toolbar
      // events
      container.onmouseover = function(){ container.style.visibility = 'hidden';}

      // Add Zoom if not in the
      var ctlZoom = L.control.zoom({position:'topright'}).addTo(mymap);


      // Add a custom Control
      // mymap.addControl(new finishCreationControl());

      //  ********* Events on Map *********
      // # Sidebar events
      ctlSidebar.on('closing',function(){
        previousTab = activeTab; //When the sidebar opens, it was closed before. So there was no active tab
        activeTab = null;
        sidebarOpened = false;

        // mymap.removeLayer(basemap_WorldImagery);
        // mymap.addLayer(basemap_mapbox);

        //Mimics a sidebar click, to remove the blue background color of the icon if a liked or disliked tab was clicked before the closing of the sidebar
        sidebarChange('closing');

        //When closing the sidebar it's in the editMode and createMode==false, force the user to give an attribute to the area
        if(editMode){
          // if(createMode==false){
            //count the number of checkbox checked for the place_id
            countCheckCbx();
            if(cntCheckedCbx == 0){
              // No attribute was selected
              warnCheckAtt();
              return null;
            }
          // }
        }else{
          //to not overide the edit mode style
          setStyleNormal();
        }
        console.log(cnt_test,"CLOSE Prev: ",previousTab, "Act: ", activeTab, "CM",
         createMode, "EM", editMode, "cbxChecked:", cntCheckedCbx );

        if(cnt_LikedPlaces+cnt_DislikedPlaces<6){
          document.getElementById('dynamic-icon-tab').className = 'fa fa-plus';
        }

      });
      ctlSidebar.on('opening', function() {
        cnt_SidebarOpens++;
        //because the context event fires the opening event (if sidebar is closed), the following variable is to know the status of the sidebar, in order to organize the previous and active tab in the 'content' event.
        sidebarOpened = true;
        //Mimics a sidebar click, to change the background of the icon to blue, if the tab opened is a liked or disliked place
        sidebarChange('opening');
        if (createMode){
          warnFinishCreation();
        }
      });
      ctlSidebar.on('content', function(e) {
        //When the sidebar opens the 'content' and 'opening' are fired up together, consecutively
        // When sidebarOpened==true, it means the sidebar is being opened, otherwise, the user is just changing tabs
        if(sidebarOpened){
          previousTab = activeTab;
          cnt_SidebarChangeTab++;
        }else //sidebarOpened == false, the sidebar is being opened, the opening event will start after this one and set sidebarOpened to true
        {
          previousTab = null;
        }
        activeTab = e.id; //Returns the ID of the clicked tab

        if(editMode){
          // finish edit area if the Sidebar is opened in another tab diferent from the one being edited
          if (activeTab != place_id){ saveArea(); }
        }

        //Mimics a sidebar click, to remove the blue background color of the icon if a liked or disliked tab was clicked before the closing of the sidebar
        sidebarChange('content');

        if(editMode){
          // Set style of layer based on the sidebar status
          toggleLyrStyle(activeTab, setStyle_edit);
          // finish edit area if the Sidebar is opened in another tab diferent from the one being edited
          if (activeTab != place_id) saveArea();
        }else{
          toggleLyrStyle(activeTab, setStyle_clicked);
        }

        console.log(cnt_test,"CONT Prev: ",previousTab, "Act: ", activeTab, "CM", createMode, "EM", editMode);

      });//END content

      // # Map events
      mymap.on("moveend", function () {
        // console.log(mymap.getCenter().toString());
        // alert("moveend");
      });
      mymap.on("movestart", function () {
        // console.log(mymap.getCenter().toString());
        // alert("movestar");
      });
      mymap.on('baselayerchange', function(e){
        // alert("LAYER HAS BEEN CHANGED.");
        // console.log(e);
        if (e.name == '<i class="fas fa-image"></i>'){
          layerControls.addOverlay(Hydda_RoadsAndLabels, 'streets');
        }else{
          mymap.removeLayer(Hydda_RoadsAndLabels);
          layerControls.removeLayer(Hydda_RoadsAndLabels);
        }
      })
      mymap.on('contextmenu', function(e){
        /* DESCRIPTION: listener when a click is given on the map  */
        // $("#divLog").text("Map Clicked... Random Number: "+(Math.floor(Math.random() * 100)).toString());
        if(editMode){
          //if in editMode or createMode the place_id is already set to be accessed in the function
          saveArea();
        }
      });
      mymap.on('mousemove', function(e){
        /* DESCRIPTION: listener when a click is given on the map  */
        // console.log(1);
      });
      mymap.on('click', function(e){
        /* DESCRIPTION: listener when a click is given on the map  */
        // if clickedLayerId != null, means that the position the user clicked on the map has a layer, otherwise, it clicked in a empty space on a map
        if(clickedLayerId != null){
          //if getActiveTabId() != clickedLayerId means that the sidebar is not opened in the tab of the clicked layer
          if ((getActiveTabId()!=clickedLayerId) && (createMode==false)){
            ctlSidebar.open(clickedLayerId);
            clickedLayerId = null;
          }
        }else{
          //if(getActiveTabId() != null) means that the sidebar is opened
          if(getActiveTabId() != null){
            ctlSidebar.close();
          }
        }
      });
      mymap.on('pm:drawend', function(e) {
        //toggle visibility of toolbar, overview map
        ctlCreationToolbar.remove();
        mymapOverview.addTo(mymap);
        ctlZoom.addTo(mymap);
        mymap.closePopup();

        //When the user is drawing it means that the 'place_id' should exist and it's the id of the area being drawn
        //A creation of a new area is only finished when the user clicks the save button
        createMode = false;
      });
      mymap.on('pm:drawstart', function(e) {
        //A new layer has started to be drawn.
        createMode = true; //the createMode will receive 'false' when the save button is clicked
        num_mapClick = 0; //logs the number of clicks the user is giving, in order to add popup instructing the user.
        this.workingLayer = e.workingLayer;

        //toggle visibility of controls when start the drawing mode
        ctlCreationToolbar.addTo(mymap);
        mymapOverview.remove();
        ctlZoom.remove();
        if ((cnt_DislikedPlaces+cnt_LikedPlaces)<=1){
          showInfoBox();
        }

        var layer = e.workingLayer;
        layer.on('pm:vertexadded', function(e) {
          // e includes the new vertex, it's marker the index in the coordinates array the working layer and shape
          // console.log('vertexadded', e);
          num_mapClick++;
          if(num_mapClick==1){
            firstClickLatLng = [e.latlng.lat, e.latlng.lng];

            //Adding Instructions popup when the user is creating the first area on the map
            if( (cnt_LikedPlaces+cnt_DislikedPlaces)==1){
              var str_popup = '';
              str_popup += '<p>Click in this node again<br />';
              str_popup += '<b>to finish drawing</b>';
              openInfoPopUp(firstClickLatLng, str_popup);
            }

          }

        });
        // also fired on the markers of the polygon
        layer.on('pm:snap', function(e) {
          // e includes marker, snap coordinates segment, the working layer and the distance
          // console.log('snap', e);
        });

      },this);
      mymap.on('pm:create', function(e) {
        // console.log(e);
        var lyrDraw = e.layer;

        var width = lyrDraw.getBounds().getEast() - lyrDraw.getBounds().getWest();
        var height = lyrDraw.getBounds().getNorth() - lyrDraw.getBounds().getSouth();

        console.log(
          'center:' + lyrDraw.getCenter() +'\n'+
          'width:' + width +'\n'+
          'height:' + height +'\n'
        );

        //Initialize the attributes. We can name it the way we want
        var feature = lyrDraw.feature = lyrDraw.feature || {};
        feature.type = feature.type || "Feature"; //Could be the name we want
        var props = feature.properties = feature.properties || {};
        props.id = place_id;
        //General style
        lyrDraw.setStyle({"color": color_line_place, "opacity": 0.75, 'fillColor': color_fill_place });

        jsn_draw=lyrDraw.toGeoJSON().geometry;
        //Count the number of coordinates inside the JSON geometry.
        //In the case of polygon. The last element is equal to the first in order close the polygon.
        //So the subtraction of 1 gives us the exactly number of vertices of the drawn polygon
        var numberOfVertices = ((jsn_draw.coordinates[0]).length)-1;
        if (numberOfVertices < 3){
          alert("The area drawn is not a polygon. It has only "+numberOfVertices.toString()+" vertices.\nPlease draw it again!");
          // Start a new draw again
          restartDraw(lyrDraw);
          return;
        }

        if( (width<0.0007) || (height<0.0007) ){
          alert("The area drawn is too small\nPlease draw it again!");
          // Start a new draw again
          mymap.removeLayer(lyrDraw);
          var button_drawArea_id = place_id+"_drawArea";
          document.getElementById(button_drawArea_id).click();
          return;
        }

        lyrDraw.on('click', function(){
          clickedLayerId = lyrDraw.feature.properties.id;
          // console.log("Clicked Layer: ",clickedLayerId);
        });

        //Add the layer created to the feature group
        fgpDrawnItems.addLayer(lyrDraw);
        // console.log("length ftGroup: ",fgpDrawnItems.getLayers().length  );

        document.getElementById(place_id+"_drawArea").style.display="none";
        document.getElementById(place_id+"_saveArea").style.display="block";
        //Show attributes div
        document.getElementById(place_id+"_divChosenAttr").style.display = "block";

        // Enabling edit to the layer
        fgpDrawnItems.eachLayer(function(layer){
          var layer_id = layer.feature.properties.id;
          if(layer_id == place_id){
            //When the layer is created, the sidebar is opened and the layer continues in the edit mode until the user clicks save
            editMode = true;
            layer.setStyle(setStyle_edit);
            layer.pm.enable();
            return;
          }
        });

        //Open the sidebar
        if (getActiveTabId()!=place_id){ctlSidebar.open(place_id);}

      });//pm:create

      // opening the sidebar to show the basic info to the user
      ctlSidebar.open('home');
      // Capture the pressed key in the document
      document.onkeydown = KeyPress;
    }); //END $(document).ready()

    //  ********* JS Functions *********
    //  # Drawing Functions
    function drawArea(button_clicked_properties){
      /* DESCRIPTION: It tun after the user clicked on the button 'Draw Area' inside an liked or disliked tab */
      // Passing the ID gotten from the id of the button clicked to the global variable in order to be accesed in the anonymous functions
      if (createMode==false){
        place_id = ((button_clicked_properties.id).split("_"))[0];
        if (log_functions){console.log('drawArea', place_id);}
        document.getElementById(place_id+"_removeArea").style.display="block";

        document.getElementById(place_id+"_str_startdrawing").innerHTML ="<h4>And now, what do you want to do? </h4>";
        console.log(document.getElementById(place_id+"_str_startdrawing").innerHTML );

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
          allowSelfIntersection: false
        };
        mymap.pm.enableDraw('Poly', drawingOptions);

      }
    }//END drawArea()
    function saveArea(button_clicked_properties){
      /* DESCRIPTION: Function fired up when the user clicks on the 'Save Place' button of the sidebar tab */
      //if no 'button_clicked_properties', it means that this function was called by some behaviour of the user
      // it only has 1 possibilities to call this function. createMode == true
      if (button_clicked_properties) {place_id = ((button_clicked_properties.id).split("_"))[0];}
      if (log_functions) console.log('saveArea', place_id, createMode, editMode);

      //count the number of checkbox checked for the place_id
      countCheckCbx();

      if(cntCheckedCbx == 0){
        // No attribute was selected
        warnCheckAtt();

        //Open the sidebar
        if (getActiveTabId()!=place_id){ctlSidebar.open(place_id);}
        return null;
      }else{
        //At least one attribute was selected, can proceed with saving...

        // Disable edit mode and setStyle for layer
        fgpDrawnItems.eachLayer(function(layer){
          var layer_id = layer.feature.properties.id;
          if(layer_id == place_id){
            editMode = false;
            layer.pm.disable();
            mymap.pm.disableDraw('Poly');

            if(getActiveTabId()==place_id){
              //If the tab is opened in the place_id tab the style must receive the setStyle_clicked
              layer.setStyle(setStyle_clicked);
            }else{
              //If the tab is not opened in the place_id tab the style must receive the setStyle_normal
              layer.setStyle(setStyle_normal);
            }
            return;
          }
        });

        var att_nat = document.getElementById(place_id+"_cbxAtt-nat").checked;
        var att_open = document.getElementById(place_id+"_cbxAtt-open").checked;
        var att_ord = document.getElementById(place_id+"_cbxAtt-order").checked;
        var att_up = document.getElementById(place_id+"_cbxAtt-upkeep").checked;
        var att_hist = document.getElementById(place_id+"_cbxAtt-hist").checked;

        //change style of checkboxes
        if( att_nat ){
          document.getElementById(place_id+"_lblAtt-nat").style.textDecoration = "none";
          document.getElementById(place_id+"_lblAtt-nat").style.color = "grey";
          document.getElementById(place_id+"_cbxAtt-nat").disabled = true;
        } else {
          document.getElementById(place_id+"_lblAtt-nat").style.textDecoration = "line-through";
          document.getElementById(place_id+"_lblAtt-nat").style.color = "grey";
          document.getElementById(place_id+"_cbxAtt-nat").disabled = true;
        }
        if( att_open ){
          document.getElementById(place_id+"_lblAtt-open").style.textDecoration = "none";
          document.getElementById(place_id+"_lblAtt-open").style.color = "grey";
          document.getElementById(place_id+"_cbxAtt-open").disabled = true;
        } else {
          document.getElementById(place_id+"_lblAtt-open").style.textDecoration = "line-through";
          document.getElementById(place_id+"_lblAtt-open").style.color = "grey";
          document.getElementById(place_id+"_cbxAtt-open").disabled = true;
        }
        if( att_ord ){
          document.getElementById(place_id+"_lblAtt-order").style.textDecoration = "none";
          document.getElementById(place_id+"_lblAtt-order").style.color = "grey";
          document.getElementById(place_id+"_cbxAtt-order").disabled = true;
        } else {
          document.getElementById(place_id+"_lblAtt-order").style.textDecoration = "line-through";
          document.getElementById(place_id+"_lblAtt-order").style.color = "grey";
          document.getElementById(place_id+"_cbxAtt-order").disabled = true;
        }
        if( att_up ){
          document.getElementById(place_id+"_lblAtt-upkeep").style.textDecoration = "none";
          document.getElementById(place_id+"_lblAtt-upkeep").style.color = "grey";
          document.getElementById(place_id+"_cbxAtt-upkeep").disabled = true;
        } else {
          document.getElementById(place_id+"_lblAtt-upkeep").style.textDecoration = "line-through";
          document.getElementById(place_id+"_lblAtt-upkeep").style.color = "grey";
          document.getElementById(place_id+"_cbxAtt-upkeep").disabled = true;
        }
        if( att_hist ){
          document.getElementById(place_id+"_lblAtt-hist").style.textDecoration = "none";
          document.getElementById(place_id+"_lblAtt-hist").style.color = "grey";
          document.getElementById(place_id+"_cbxAtt-hist").disabled = true;
        } else {
          document.getElementById(place_id+"_lblAtt-hist").style.textDecoration = "line-through";
          document.getElementById(place_id+"_lblAtt-hist").style.color = "grey";
          document.getElementById(place_id+"_cbxAtt-hist").disabled = true;
        }

        // Show 'edit' button, hide 'save' button
        document.getElementById(place_id+"_saveArea").style.display="none";
        document.getElementById(place_id+"_editArea").style.display="block";
      }
    };//END saveArea()
    function editArea(button_clicked_properties){
      /* DESCRIPTION: It's run when the user clicks in the edit button of the sidebar*/
      //To use place_id inside an anonymous function (mymap.on('contextmenu', function(){}), it must be global
      place_id = ((button_clicked_properties.id).split("_"))[0];
      if (log_functions){console.log('editArea', place_id);}

      var att_nat = document.getElementById(place_id+"_cbxAtt-nat");
      var att_open = document.getElementById(place_id+"_cbxAtt-open");
      var att_ord = document.getElementById(place_id+"_cbxAtt-order");
      var att_up = document.getElementById(place_id+"_cbxAtt-upkeep");
      var att_hist = document.getElementById(place_id+"_cbxAtt-hist");

      if( att_nat ){
        document.getElementById(place_id+"_lblAtt-nat").style.textDecoration = "none";
        document.getElementById(place_id+"_lblAtt-nat").style.color = "black";
        document.getElementById(place_id+"_cbxAtt-nat").disabled = false;
      }
      if( att_open ){
        document.getElementById(place_id+"_lblAtt-open").style.textDecoration = "none";
        document.getElementById(place_id+"_lblAtt-open").style.color = "black";
        document.getElementById(place_id+"_cbxAtt-open").disabled = false;
      }
      if( att_ord ){
        document.getElementById(place_id+"_lblAtt-order").style.textDecoration = "none";
        document.getElementById(place_id+"_lblAtt-order").style.color = "black";
        document.getElementById(place_id+"_cbxAtt-order").disabled = false;
      }
      if( att_up ){
        document.getElementById(place_id+"_lblAtt-upkeep").style.textDecoration = "none";
        document.getElementById(place_id+"_lblAtt-upkeep").style.color = "black";
        document.getElementById(place_id+"_cbxAtt-upkeep").disabled = false;
      }
      if( att_hist ){
        document.getElementById(place_id+"_lblAtt-hist").style.textDecoration = "none";
        document.getElementById(place_id+"_lblAtt-hist").style.color = "black";
        document.getElementById(place_id+"_cbxAtt-hist").disabled = false;
      }

      //Style options
      if(mymap.hasLayer(fgpDrawnItems)){
        fgpDrawnItems.eachLayer(function(layer){
          var layer_id = layer.feature.properties.id;
          // console.log(layer_id);
          if(layer_id == place_id){
            //The layer was found so start the editing process...
            editMode = true;
            // Set the style for all the layers to normal
            setStyleNormal();
            layer.bringToFront();
            //Change the style for the layer being editted
            layer.setStyle(setStyle_edit);
            // var options = { snappable: false }; //Edit here some options for the editMode
            // layer.pm.enable(options); //Send with option
            layer.pm.enable();
          }
        });
      }//END if(mymap.hasLayer(fgpDrawnItems))

      // Show 'save' button, hide 'edit' button
      document.getElementById(place_id+"_editArea").style.display="none";
      document.getElementById(place_id+"_saveArea").style.display="block";

    };//END editArea()
    function removeArea(button_clicked_properties, no_button){
      if (log_functions) console.log('removeArea');
      if (no_button) {
        //no button was clicked. The removeArea() is called programatically, because some behaviour user did.
        var retVal = true;
      }else{
        //ask the user if is sure to delete the area
        var retVal = warnDeleteArea();
      }
      if( retVal ){
        if (no_button){
          place_id = button_clicked_properties;
          var close_sidebar = false;
        }else{
          place_id = (button_clicked_properties.id).split("_")[0];
          var close_sidebar = true;
        }
        mymap.pm.disableDraw('Poly');
        // console.log(fgpDrawnItems.getLayers() );
        if(mymap.hasLayer(fgpDrawnItems)){
          fgpDrawnItems.eachLayer(function(layer){
            var layer_id = layer.feature.properties.id;
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
        editMode = false;
        createMode = false;
        deleteTabByHref('#'+place_id, close_sidebar);
      }
    };//END removeArea()
    function setStyleNormal(){
      /* DESCRIPTION: setStyle_normal for all the layers*/
      if(mymap.hasLayer(fgpDrawnItems)){
        fgpDrawnItems.eachLayer(function(layer){
          layer.setStyle(setStyle_normal);
        });
      }
    };//END editArea()
    function toggleLyrStyle(activeTab, styleOption){
      /* DESCRIPTION: Set style of layer based on the sidebar opened*/
      if(mymap.hasLayer(fgpDrawnItems)){
        //change the style for all the layers to normal
        setStyleNormal();
        fgpDrawnItems.eachLayer(function(layer){
          var layer_id = layer.feature.properties.id;
          if(layer_id == activeTab){
            // console.log("lyr_id:", layer_id, 'ActTab', activeTab, "EM", editMode );
            layer.bringToFront();
            layer.setStyle(styleOption);
          }
        });
      }
    };//END toggleLyrStyle()
    function finishCreation() {
      /* DESCRIPTION: Finishes a drawing when in a editMode or createMode */
      var num_vertices = document.workingLayer._latlngs.length;
      if (num_vertices>=3){
        document.workingLayer._map.pm.Draw["Poly"]._finishShape();
      }else if(num_vertices>=1){
        //At least one click was given, so firstClickLatLng exists
        var str_popup = '';
        str_popup += '<p>Please, add at least <br />';
        str_popup += '<b>3 vertices</b>';
        openInfoPopUp(firstClickLatLng, str_popup);
      }else{
        var str_popup = '';
        str_popup += '<p>Please, add at least <br />';
        str_popup += '<b>3 vertices</b>';
        openInfoPopUp(mymap.getCenter(), str_popup);
      }
    }
    function removeLastVertex(){
      /* DESCRIPTION: When the layer is being drawn, for more than 2 vertices the user can remove the last vertex by pressing Ctrl+z */
      var num_vertices = document.workingLayer._latlngs.length;
      if (num_vertices>1){
        document.workingLayer._map.pm.Draw["Poly"]._removeLastVertex();
      }else{
        restartDraw();
      }
    };//END removeLastVertex()
    function cancelCreation() {
      /* DESCRIPTION: Finishes a drawing when in a editMode or createMode */
      document.workingLayer._triggerClick();
    }
    function showInfoBox(){
      /* DESCRIPTION: Shows a Information Box to the user in order to know how to use the CreationToolbar*/
      $('.infobox_for_toolbar').css('visibility','visible');
      //hide after 4 seconds
      setTimeout(function() {
        $('.infobox_for_toolbar').css('visibility','hidden');
      }, 10000);
    }
    function restartDraw(lyrDraw){
      /* DESCRIPTION: Start a new draw again*/
      if(lyrDraw) //Layer was created but is not valid: ex: vertices<3
      {
        mymap.removeLayer(lyrDraw);
      }else //removing workingLayer
      {
        mymap.removeLayer(document.workingLayer);
      }
      //restart variables
      editMode=false;
      createMode=false;
      var button_drawArea_id = place_id+"_drawArea";
      document.getElementById(button_drawArea_id).click();
    }
    function openInfoPopUp(popup_position, popup_content, duration_open=5000){
      var popup_options = {
        // 'autoClose':	false,
        'closeOnClick':	false,
        'className' : 'popupInfo'
      }
      //close any popup if open
      mymap.closePopup();
      var infoPopUp = L.popup(popup_options)
      .setLatLng(popup_position)
      .setContent(popup_content)
      .openOn(mymap);
      setTimeout(function(){ mymap.closePopup(infoPopUp);}, duration_open);
    }


    //  # Sidebar Functions
    function sidebarChange(e){
      /* DESCRIPTION: Global events for the sidebar. 'e' can be either "closing", "opening" or "content"*/
      // just a temporary count for testing to see how many times the sidebar was changed
      cnt_test++;
      // get the active Tab the sidebar founds itself. if 'e'=="closing", clickedTab == null
      var clickedTab = getActiveTabId(true);

      //Always refresh the Temp Tab when occurs a sidebar Change
      if( (clickedTab!='#temp_tab') && ((cnt_LikedPlaces + cnt_DislikedPlaces) < 6) ){
        // ctlSidebar.removePanel('temp_tab'); //It just hide the Panel
        deleteTabByHref('#temp_tab');
        ctlSidebar.addPanel(returnTempTabContent());
        createTitleLiByHref( "#temp_tab" , "Add a new Place" );
      }

      //Change the background color for the icons, when they're clicked -> receives blue, otherwise receive "green" for liked and "red" for disliked
      //Adding the background color (blue) for the clicked tab
      if(clickedTab!=null){
        var clickedTabPrefix = clickedTab.split("-")[0]; //the split() only for string. If it's null, this operation will break. That's why should check if the variable is !=null, previously
        if( (clickedTabPrefix=='#liked') || (clickedTabPrefix=='#disliked') ){
          document.querySelectorAll('[role="tab"]').forEach(function (e){
            if ( e.getAttribute("href") == clickedTab ){
              e.classList.add("sidebar_tab_liked_disliked_clicked");  //Change the class to the tab receive green as a background
            }
          });
        }
      }
      //Remove the background color (blue) for the previous clicked tab and returning it to the original color (red or green)
      if(previousTab!=null){
        var previousTabPrefix = previousTab.split("-")[0]; //the split() only for string. If it's null, this operation will break. That's why should check if the variable is !=null, previously
        if ((previousTabPrefix=='liked') || (previousTabPrefix=='disliked')){
          document.querySelectorAll('[role="tab"]').forEach(function (e){
            if ( e.getAttribute("href") == ("#"+previousTab) ){
              e.classList.remove("sidebar_tab_liked_disliked_clicked");  //Change the class to the tab receive green as a background
            }
          });
        }
      }

      // console.log(cnt_test, "Previous Tab:", previousTab, "Active Tab:", clickedTab);
      // When the user clicks to create a new place but nothing's drawn for that place.
      // When the status of the sidebar changes, this new place is deleted
      if(previousTab!=null){
        if (createMode==false){
          var array_tabs = existentTabs();
          if (newTabCreated){
            //toggle newTabCreated to false;
            newTabCreated = false;
            for (var i = 0; i < array_tabs.length; i++) {
              var tab_id = array_tabs[i];
              var tabprefix = tab_id.split("-")[0];
              //checking if exist a liked or disliked place
              if ((tabprefix == "liked") || (tabprefix == "disliked")){
                // The removeArea button is only visible if the user starts to draw in the map.
                // that's why it's being used to verify if the user already draw an area for the created tab.
                // If not, this area will be removed. Consequently, this tab
                if(document.getElementById(tab_id+"_removeArea").style.display=="none"){
                  removeArea(tab_id, true);
                  if(clickedTab=='#temp_tab'){
                    ctlSidebar.open("temp_tab");
                  }
                }
              }
            }
          }//end else
        }//end (createMode==false)
      }//end if(previousTab!=null)

      // update the status of the button for creating a new 'liked' or 'disliked' place
      if ( cnt_LikedPlaces < 3){
        statusAddLikeButton = "";
      }
      if ( cnt_DislikedPlaces < 3){
        statusAddDislikeButton = "";
      }

      //When temp_tab is clicked the icon for this tab is changed
      if (clickedTab=="#temp_tab"){
        document.getElementById('dynamic-icon-tab').className = 'fa fa-question-circle';
      }

    }//END function sidebarChange()
    function create_placeTab(typeOfPlace){
      /* DESCRIPTION: Creates a new tab based on the option chosen in the #temp_tab: It will be either Liked or Disliked tab  */
      if(typeOfPlace=="liked"){
        var icon = "thumbs-up";
        cnt_LikedPlaces++;
        for (cnt = 1; cnt <= 3; cnt++) {
          if( !(searchTagIfExistsByHref("#"+typeOfPlace+'-'+cnt.toString())) ){
            break;
          }
        }
        var tab_id = typeOfPlace+'-'+cnt.toString();
        var title = typeOfPlace.charAt(0).toUpperCase()+typeOfPlace.slice(1) +' Place '+cnt;

      }else if(typeOfPlace=="disliked"){
        var icon = "thumbs-down";
        cnt_DislikedPlaces++;
        var cnt = cnt_DislikedPlaces;
        for (cnt = 1; cnt <= 3; cnt++) {
          if( !(searchTagIfExistsByHref("#"+typeOfPlace+'-'+cnt.toString())) ){
            break;
          }
        }
        var tab_id = typeOfPlace+'-'+cnt.toString();
        var title = typeOfPlace.charAt(0).toUpperCase()+typeOfPlace.slice(1) +' Place '+cnt;
      }
      // alert(tab_id);
      var str_newtab = "";
      str_newtab += '<div class="col-xs-12">';
      str_newtab +=   '<div id="'+tab_id+'_divChosenAttr" style="display:none; padding-left:10px; padding-top:10px;">';
      str_newtab +=     '<h4>Choose an attribute for the area:*</h4>';
      str_newtab +=     '<p>*Mark at least 1 attribute</p>';
      str_newtab +=     '<span id="'+tab_id+'_str_checkcbx" ></span>'; //NEEDTO: say to user to click save button
      str_newtab +=     '<input type="checkbox" id="'+tab_id+'_cbxAtt-nat"" class="'+tab_id+'_cbxAttributes cbxsidebar" name="dlg_fltAttributes" value="att_nat">';
      str_newtab +=     '<label id="'+tab_id+'_lblAtt-nat" class="cbxsidebar" for="'+tab_id+'_cbxAtt-nat"> Naturalness</label><br />';
      str_newtab +=     '<input type="checkbox" id="'+tab_id+'_cbxAtt-open" class="'+tab_id+'_cbxAttributes cbxsidebar" name="dlg_fltAttributes" value="att_open">';
      str_newtab +=     '<label id="'+tab_id+'_lblAtt-open" class="cbxsidebar" for="'+tab_id+'_cbxAtt-open"> Openness</label><br />';
      str_newtab +=     '<input type="checkbox" id="'+tab_id+'_cbxAtt-order" class="'+tab_id+'_cbxAttributes cbxsidebar" name="dlg_fltAttributes" value="att_order">';
      str_newtab +=     '<label id="'+tab_id+'_lblAtt-order" class="cbxsidebar" for="'+tab_id+'_cbxAtt-order"> Order<br></label><br />';
      str_newtab +=     '<input type="checkbox" id="'+tab_id+'_cbxAtt-upkeep" class="'+tab_id+'_cbxAttributes cbxsidebar" name="dlg_fltAttributes" value="att_upkeep">';
      str_newtab +=     '<label id="'+tab_id+'_lblAtt-upkeep" class="cbxsidebar" for="'+tab_id+'_cbxAtt-upkeep"> Upkeep</label><br />';
      str_newtab +=     '<input type="checkbox" id="'+tab_id+'_cbxAtt-hist" class="'+tab_id+'_cbxAttributes cbxsidebar" name="dlg_fltAttributes" value="att_hist">';
      str_newtab +=     '<label id="'+tab_id+'_lblAtt-hist" class="cbxsidebar" for="'+tab_id+'_cbxAtt-hist"> Historical Significance</label><br />';
      str_newtab +=   '</div>';

      str_newtab +=   '<div class="sidebarContentChild">';
      str_newtab +=     '<span id="'+tab_id+'_str_startdrawing" >';
      str_newtab +=       '<h4>Click on the button to start drawing the area you '+typeOfPlace.slice(0, typeOfPlace.length-1)+'</h4>';
      str_newtab +=     '</span>';
      str_newtab +=   '</div>';
      str_newtab +=   '<div class="sidebarContentChild">';
      str_newtab +=     '<span>';
      str_newtab +=       '<button id="'+tab_id+'_drawArea" class="btn btn-warning" onclick="drawArea(this)">';
      str_newtab +=         '<i class="fa fa-edit"></i> Draw Area';
      str_newtab +=       '</button>';
      str_newtab +=       '<button id="'+tab_id+'_saveArea" class="btn btn-success" style="display:none;" onclick="saveArea(this)">';
      str_newtab +=         '<i class="fa fa-save"></i> Save';
      str_newtab +=       '</button>';
      str_newtab +=       '<button id="'+tab_id+'_editArea" class="btn btn-warning" style="display:none;" onclick="editArea(this)">';
      str_newtab +=         '<i class="fa fa-pen"></i> Edit';
      str_newtab +=       '</button>';
      str_newtab +=     '</span>';
      str_newtab +=     '<span>';
      str_newtab +=       '<button id="'+tab_id+'_removeArea" class="btn btn-danger" style="display:none;" onclick="removeArea(this)">';
      str_newtab +=         '<i class="fa fa-trash-alt"></i> Remove Area';
      str_newtab +=       '</button>';
      str_newtab +=     '</span>';
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

      if ( cnt_LikedPlaces == 3){
        statusAddLikeButton = "disabled";
      }
      if ( cnt_DislikedPlaces == 3){
        statusAddDislikeButton = "disabled";
      }
      if ( (cnt_LikedPlaces + cnt_DislikedPlaces) < 6 ){
        // If num=6 doesn't add the tab
        ctlSidebar.addPanel(returnTempTabContent());
        createTitleLiByHref( "#temp_tab" , "Add a new Place" );
      }

      //Add class to the icon of the new created tab. Liked:"green", Disliked:"red"
      document.querySelectorAll('[role="tab"]').forEach(function (e){
        var tab_href = e.getAttribute("href");
        // If the tab_href is exactly the tab I'm creating right now:
        if ( tab_href == ("#"+tab_id) ){
          if ( tab_href.split("-")[0] == "#liked" ){
            e.classList.add("sidebar_tab_icon_liked");  //Change the class to the tab receive green as a background
          }
          if ( tab_href.split("-")[0] == "#disliked" ){
            e.classList.add("sidebar_tab_icon_disliked"); //Change the class to the tab receive red as a background
          }
        }
      });
      //Open sidebar tab if it's not open already
      if (getActiveTabId()!=tab_id){ctlSidebar.open(tab_id);}

      //variable for verifying when a 'liked' or 'disliked' place was created. It should be after the sidebar is opened
      newTabCreated = true;

    };//END create_placeTab()
    function returnTempTabContent(){
      /* DESCRIPTION: Returns the content of the '#temp_tab' update the button status all the time it's called */
      var str_temptab= "";
      str_temptab += '<div id="col-xs-12">';
      str_temptab +=  '<div class="sidebarContentParent">';
      str_temptab +=    '<div class="sidebarContentChild">';
      str_temptab +=      '<span>';
      str_temptab +=        '<h4>Which type of area do you want to draw?</h4>';
      str_temptab +=      '</span>';
      str_temptab +=    '</div>';
      str_temptab +=    '<div class="sidebarContentChild">';
      str_temptab +=     '<span>';
      str_temptab +=        '<button class="btn btn-success" onclick="create_placeTab(\'liked\')" '+statusAddLikeButton+'>';
      str_temptab +=          '<i class="fa fa-thumbs-up"></i>Liked Place';
      str_temptab +=        '</button>';
      str_temptab +=     '</span>';
      str_temptab +=    '<span>';
      str_temptab +=        '<button class="btn btn-danger" onclick="create_placeTab(\'disliked\')" '+statusAddDislikeButton+'>';
      str_temptab +=          '<i class="fa fa-thumbs-down"></i>Disliked Place';
      str_temptab +=       '</button>';
      str_temptab +=    '</span>';
      str_temptab +=   '</div>';
      str_temptab +=  '</div>';
      str_temptab += '</div>';

      temp_tab_content = {
        id:   'temp_tab',
        tab:  '<i id="dynamic-icon-tab" class="fa fa-plus"></i>',
        title: 'Add new Place\
        <span class="leaflet-sidebar-close" onclick="ctlSidebar.close()">'+
        '<i class="fa fa-chevron-circle-left"></i>'+
        '</span>',
        pane: str_temptab
      };

      return temp_tab_content;
    };//END returnTempTabContent()
    function deleteTabByHref(href, close_sidebar){
      /* DESCRIPTION: Deletes the tab based on the href that was passed
      ### If no href was passed it means that  a 'Remove Area' button inside a 'liked' or 'disliked' tab was clicked.
      ### Therefore this tab will be deleted tab was clicked. Therefore, this tab will be removed*/
      if ( href.split("-")[0] == "#liked"){
        cnt_LikedPlaces--;
        statusAddLikeButton = "";
      }else if ( href.split("-")[0] == "#disliked"){
        cnt_DislikedPlaces--;
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
    function getActiveTabId(with_hash){
      /* DESCRIPTION: Returns the href of the tab that is active (open) in the sidebar.
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
        // alert( hrefActive );
        if(with_hash){
          return hrefActive; //returns ex: "#temp_tab"
        }else{
          return hrefActive.substring(1, hrefActive.length); //returns ex: "temp_tab"
        }
      }else{
        return null;
      }
    };//END getActiveTabId()
    function searchTagIfExistsByHref(href){
      /* DESCRIPTION: returns true if a tab exists and false if not
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
    };//END searchTagIfExistsByHref()
    function existentTabs(){
      /* DESCRIPTION: returns true if a tab exists and false if not
      ### Data entry example: href = "#temp_tab"  */
      var array_tabs = [];
      var lis = document.querySelectorAll('#sidebarTab_div li');
      for(var i=0; li=lis[i]; i++) {
        //console.log( li.getElementsByTagName("a")[0].getAttribute("href") );
        var tab = li.getElementsByTagName("a")[0].getAttribute("href")
        tab = tab.substring(1, tab.length); //returns ex: "temp_tab"
        array_tabs.push(tab);
      }
      return array_tabs
    };//END searchTagIfExistsByHref()
    function createTitleLiByHref(href, newtitle){
      /* DESCRIPTION: Updates the title of the tab "li" element when it's hovered
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
    function countCheckCbx(){
      /* DESCRIPTION: Count the number of checkbox checked for the place_id that's being edited. Only works for editMode==true*/
      if(editMode){
        cntCheckedCbx = 0;
        var att_nat = document.getElementById(place_id+"_cbxAtt-nat").checked;
        var att_open = document.getElementById(place_id+"_cbxAtt-open").checked;
        var att_ord = document.getElementById(place_id+"_cbxAtt-order").checked;
        var att_up = document.getElementById(place_id+"_cbxAtt-upkeep").checked;
        var att_hist = document.getElementById(place_id+"_cbxAtt-hist").checked;

        if(att_nat)   cntCheckedCbx++;
        if(att_open)  cntCheckedCbx++;
        if(att_ord)   cntCheckedCbx++;
        if(att_up)    cntCheckedCbx++;
        if(att_hist)  cntCheckedCbx++;
      }
    };//END countCheckCbx()

    //  # Warnings Functions
    function warnCheckAtt(){
      /* DESCRIPTION: Warn the user to check at least one attribute in the checkbox */
      alert("Check at least one attribute for the area");
      //Open the sidebar
      if (getActiveTabId()!=place_id){ctlSidebar.open(place_id);}
    }
    function warnDeleteArea(){
      /* DESCRIPTION: Warn the user if tries to delete an area */
      return confirm("Are you sure you want to delete this area permanently?")
    }
    function warnFinishCreation(){
      /* DESCRIPTION: Warn the user if tries open the sidebar in a creation mode */
      alert("Please, finish the draw first. By right clicking or cliking in the first node.");
      ctlSidebar.close();
    }
    //  # Document Functions
    function KeyPress(e) {
      /* DESCRIPTION: call functions based on the combination of keys the users is pressing */
      var evtobj = window.event? event : e
      //Ctrl+z
      if (evtobj.keyCode == 90 && evtobj.ctrlKey) {
        // if the user press Ctrl+z and a new layer is being created, remove the last vertex of the layer
        if(createMode) removeLastVertex();
      }
      if (evtobj.keyCode == 13) {
        // if the user press Ctrl+z and a new layer is being created, remove the last vertex of the layer
        if(editMode) saveArea();
      }

      //Ctrl+c
      if (evtobj.keyCode == 67 && evtobj.ctrlKey) {

      }//Do something;
    }

    //  # jQuery Functions
    $( "#btn_Finish" ).click(function(){
      if ( mymap.hasLayer(fgpDrawnItems) && (fgpDrawnItems.getLayers().length > 0) ){
        // NEED TO: come back to previous situation
        // if ( (cnt_LikedPlaces >= 1) && (cnt_DislikedPlaces >= 1) ){
        if ( (cnt_LikedPlaces >= 4) && (cnt_DislikedPlaces >= 4) ){
          var cnt = 0;
          var cnt_feat = fgpDrawnItems.getLayers().length;
          fgpDrawnItems.eachLayer(function(layer){
            var layer_id = layer.feature.properties.id;
            console.log(layer_id);
            if ( layer_id.split("-")[0] == "liked" ){
              var eval_nr = 1
              var eval_str = "Liked"
            }else{
              var eval_nr = 2
              var eval_str = "Disliked"
            }
            var att_nat = document.getElementById(layer_id+"_cbxAtt-nat").checked;
            var att_open = document.getElementById(layer_id+"_cbxAtt-open").checked;
            var att_ord = document.getElementById(layer_id+"_cbxAtt-order").checked;
            var att_up = document.getElementById(layer_id+"_cbxAtt-upkeep").checked;
            var att_hist = document.getElementById(layer_id+"_cbxAtt-hist").checked;

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

            $.ajax({
              url:'eimg_draw-add_polys.php',
              data:{
                tbl:'eimg_raw_polys',
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
                cnt++;
                //Because AJAX is a asyncronous, the code to flatten the polygons should be done after the polygons are completely INSERTED to the DB
                if(cnt == cnt_feat){
                  console.log(cnt);
                  // After sending the polygons to the DB, flatten all the polygons
                  console.log("executing... eimg_viewer-flatten_polys.php");
                  $.ajax({
                    url:'eimg_viewer-flatten_polys.php',
                    //data:{ },
                    type:'POST',
                    success:function(response){
                      console.log("flatten polygons worked fine");
                      console.log(response);
                    },//End success
                    error:function(xhr, status, error){
                      // $("#divLog").text("Something went wront... "+error);
                      console.log("Something went wront... "+error);
                    }//End error
                  });//End AJAX call
                }//end if(cnt == cnt_feat)
              },
              error:function(xhr, status, error){
                console.log("Something went wront... "+error);
              }
            });
          });// fgpDrawnItems.eachLayer(function(layer))

          //Shows the modal
          $("#dlgUsabilityQuest").show();
        }else if ((cnt_LikedPlaces + cnt_DislikedPlaces) >= 3) {
          alert("PARABÉNS!! Muito Obrigado por me ajudar a testar o site! Você é maravilhos@!!! :) Mas mexa mais um pouco nele. Tente encontrar algum 'bug' ou qualquer DEFEITO ou qualquer coisa que vc não gostou. Anote para depois me dizer! :)");
        }else if ((cnt_LikedPlaces >= 1) && (cnt_DislikedPlaces == 0)){
          alert("A DISLIKED place is missing. Please, draw it to proceed!");
        }else if ((cnt_LikedPlaces == 0) && (cnt_DislikedPlaces >= 1)){
          alert("A LIKED place is missing. Please, draw it to proceed!");
        }
      }else{
        alert("Please, draw at least one liked and disliked area");
      }
    });//end btnFinish click event
    $(".btnClose").click(function(){
      $("#dlgUsabilityQuest").hide();
      window.location.href = 'eimg_viewer.php';

      // $.ajax({
      //   type: 'GET',
      //   url: 'destroy_session.php',
      //   success:function(response){
      //     console.log(response);
      //     //window.location.href = 'eimg_viewer.php';
      //   }
      // });
    });//end btnClose click event

    //  # custom Controls
    finishCreationControl =  L.Control.extend({
      options: {
        position: 'topright'
      },
      onAdd: function (mymap) {
        var container = L.DomUtil.create('input');

        container.type="button";
        container.title="No cat";
        container.value = 'Finish Layer';
        // styles
        container.style.backgroundColor = 'white';
        //container.style.backgroundImage = "url(https://t1.gstatic.com/images?q=tbn:ANd9GcR6FCUMW5bPn8C4PbKak2BJQQsmC-K9-mbYBeFZm1ZM2w2GRy40Ew)";
        container.style.backgroundSize = "30px 30px";
        container.style.width = '100px';
        container.style.height = '30px';
        // events
        container.onmouseover = function(){
          container.style.backgroundColor = 'pink';
        }
        container.onmouseout = function(){
          container.style.backgroundColor = 'white';
        }
        container.onclick = function(){
          alert('buttonClicked');
        }
        return container;
      }
    });

    </script>
  </body>
  </html>
