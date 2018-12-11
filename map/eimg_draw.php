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
  <?php include "../includes/header.php" ?>
  <?php include "../includes/css/style_eimg_draw.php" ?>
  <body>
    <!-- include modals -->
    <?php include "eimg_draw-modals.php" ?>

    <!-- ###############  Div that contains the header ############### -->
    <div id="header" class="col-md-12">
      <span class="text-center"><?php echo $header ?> </span>
      <!-- <label class="radio-inline" >
        <input type="radio" name="language_switch" value="pt">
        <img src="<?php  echo $root_directory?>resources/images/flags/portugal.png" style="margin-left: 5px">
      </label>
      <label class="radio-inline">
        <input type="radio" name="language_switch" value="en" checked>
        <img src="<?php  echo $root_directory?>resources/images/flags/united_kingdom.png" style="margin-left: 5px">
      </label> -->
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
            <span class="language-en">Home</span>
            <span class="language-pt">Início</span>
            <span class="leaflet-sidebar-close"><i class="fa fa-chevron-circle-left"></i></span>
          </h1>

          <div style="padding-top:10px;text-align:center;">
            <span style="font-size:24px; padding-top:-20px;margin-top:-20px;vertical-align: middle;">
              <b>
                <span class="language-en">Welcome to</span>
                <span class="language-pt">Bem-vindo ao</span>
              </b>
            </span>
            <img src="<?php  echo $root_directory?>resources/images/eimg_logo_1.png" style="width:30%;margin-top:-5px">
          </div>

        <div id="text_sidebar_home_1" style="text-align: justify;text-justify: inter-word; padding-top: 15px;">
          <p style="font-size:14px; padding-bottom: 0px;margin-top:0px;">
            <span class="language-en">Please, draw in the map at least 2 areas:</span>
            <span class="language-pt">Por favor, desenho no mapa no mínimo 2 áreas:</span>
          </p>
          <ul>
            <li style="font-size:14px;">
              <span class="language-en">1 area you like in Lisbon (max:3)</span>
              <span class="language-pt">1 área que você gosta em Lisboa (máx:3)</span>
            </li>
            <li style="font-size:14px;">
              <span class="language-en">1 area you dislike in Lisbon (max:3) </span>
              <span class="language-pt">1 área que você não gosta (ou não gosta tanto) em Lisboa (máx:3)</span>
            </li>
          </ul>
          <p style="font-size:14px;">
            <span class="language-en">Whenever you're done, come back here and click the 'Finish' button in order to see the result of all participants.</span>
            <span class="language-pt">Quando você estiver terminar, volte aqui de novo e clique no botão abaixo para finalizar e ver o resultado de todos os participantes que já participaram</span>
          </p>
          <button id='btn_Finish' class='btn btn-info btn-block'>
            <span class="language-en">Finish and see result</span>
            <span class="language-pt">Finalizar e ver resultado</span>
          </button>
        </div>
        <hr />
        <div class="sidebarContentParent">
          <div id="text_sidebar_home_2" class="sidebarContentChild" style="width: 100%; text-align: center;">
            <span class="contenChildSpan">
              <p>
                <span class="language-en">To create a new area go to:</span>
                <span class="language-pt">Para criar uma nova área vá em:</span>
              </p>
            </span>
            <span class="contenChildSpan">
              <button id='btn_goInfoTab' class='btn btn-light btn-block' onclick="ctlSidebar.open('temp_tab')"><i class="fa fa-plus"></i>
                <span class="language-en">Draw Area</span>
                <span class="language-pt">Criar área</span>
              </button>
            </span>
          </div>
          <div id="text_sidebar_home_2" class="sidebarContentChild" style="width: 100%; text-align: center;">
            <span class="contenChildSpan">
              <p>
                <span class="language-en">For more details go to:</span>
                <span class="language-pt">Para mais detalhes clique em:</span>
              </p>
            </span>
            <span class="contenChildSpan">
              <button id='btn_goInfoTab' class='btn btn-light btn-block' onclick="ctlSidebar.open('info')"><i class="fa fa-info-circle"></i>
                <span class="language-en">Information</span>
                <span class="language-pt">Informações</span>
              </button>
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
          <div style="text-align:center;padding: 0; margin: 0; margin-top:5px;">
            <img src="<?php  echo $root_directory?>resources/images/eimg_logo_1.png" id="logo_munster" style="margin-left: auto; margin-right: auto; width: auto;max-height: 70px;">
          </div>
          <!-- INFO Starts -->

          <span class="language-en" style="text-align:center; padding:0;margin:0"><h5><b><i>Overview</i></b></h5></span>
          <span class="language-pt" style="text-align:center; padding:0;margin:0"><h5><b><i>Visão Geral</i></b></h5></span>
          <div class="container-fluid" style="margin-left: -15px;">
            <!-- Overview session -->
            <div class="row" style="text-align:center;border-top:1px solid rgba(0,0,0,0.1);padding-top:5px">
              <div class="col" style="text-align:justify; padding">
                  <span class="language-en">
                    <p>
                      eImage is part of a research project involving 3 European universities: <b>NOVA IMS</b> (Lisbon, Portugal), <b>UJI</b> (Castellón, Spain) and <b>WWU</b> (Münster, Germany).
                      The core idea is to ask citizens and visitors of Lisbon about places they like and places they dislike within the city
                      in order to produce an evaluative image of the Lisbon.
                    </p>
                  </span>
                  <span class="language-pt">
                    <p>
                      eImage é parte integrante de um projeto de investigação envolvendo 3 universidades européias: <b>NOVA IMS</b> (Lisboa, Portugal), <b>UJI</b> (Castellón, Espanha) and <b>WWU</b> (Münster, Alemanha).
                      The idéia principal é perguntar a moradores e visitantes de Lisboa, área que eles gostam e áreas que eles não gostam dentro da cidade,
                      para assim produzir uma imagem avaliativa dessa maravilhosa capital lusitana.
                    </p>
                  </span>
              </div>
            </div>
          </div>

          <span class="language-en" style="text-align:center; padding:0;margin:0"><h5><b><i>Controls</i></b></h5></span>
          <span class="language-pt" style="text-align:center; padding:0;margin:0"><h5><b><i>Controles</i></b></h5></span>
          <div class="container-fluid" style="margin-left: -15px;">
            <!-- Layer control -->
            <div class="row" style="border-top:1px solid rgba(0,0,0,0.1);padding-top:5px">
              <div class="col" style="">
                <ul>
                  <li style="margin:0; padding: 0;margin-left: -25px;">
                    <span class="language-en"><h4><b>Basemap control</b></h4></span>
                    <span class="language-pt"><h4><b>Escolher mapas base</b></h4></span>
                  </li>
                </ul>
              </div>
            </div>
            <div class="row" style="text-align:center">
              <div class="col-md-2 col" style="text-align:center;display: inline-block; height: 100%; vertical-align: middle;">
                <div style="vertical-align: middle;">
                  <img src="<?php  echo $root_directory?>resources/images/info/control_layer.png" style=" width: auto;max-height: 80px;">
                </div>
              </div>
              <div class="col-md-10 col-10" style="text-align:justify; padding">
                  <span class="language-en"><p>Choose between the 3 types of basemap to help you to find the area you want to draw:</p>
                    <p style="margin-top:-10px"><i class="fas fa-map-marked"></i> Vector | <i class="fas fa-mountain"></i> Terrain | <i class="fas fa-globe-americas"></i> Imagery </p>
                  </span>
                  <span class="language-pt"><p>Escolha entre os 3 tipos de mapas para te ajudar com a encontrar a área que você deseja desenhar. Existem 3 opções:</p>
                    <p style="margin-top:-10px"><i class="fas fa-map-marked"></i> Vetor | <i class="fas fa-mountain"></i> Altitude | <i class="fas fa-globe-americas"></i> Satélite </p>
                  </span>
              </div>
            </div>
            <!-- Drawing control -->
            <div class="row" style="padding-top:5px">
              <div class="col" style="">
                <ul>
                  <li style="margin:0; padding: 0;margin-left: -25px;">
                    <span class="language-en"><h4><b>Drawing Toolbar</b></h4></span>
                    <span class="language-pt"><h4><b>Barra de ferramentas</b></h4></span>
                  </li>
                </ul>
              </div>
            </div>
            <div class="row" style="text-align:center">
              <div class="col-md-2 col" style="text-align:center;display: inline-block; height: 100%; vertical-align: middle;">
                <div style="vertical-align: middle;">
                  <img src="<?php  echo $root_directory?>resources/images/info/control_draw.png" style=" width: auto;max-height: 90px;">
                </div>
              </div>
              <div class="col-md-10 col-10" style="text-align:justify;">
                  <span class="language-en">
                    <p style="margin-bottom:0;padding-top:0;">When you're creating a new area:</p>
                    <ul style="list-style-type: none; margin:0; padding: 0;">
                      <li>
                        <i class="fas fa-project-diagram"></i> Finish the drawing (You can also press <b>'Enter'</b>)
                      </li>
                      <li >
                        <i class="fas fa-undo-alt"></i> Remove the last vertex of the polygon (Or press <b>'Ctrl+z'</b>)
                      </li>
                      <li >
                        <i class="fas fa-times-circle"></i> Cancel the creation of the area (Or press <b>'Esc'</b>)
                      </li>
                    </ul>
                  </span>
                  <span class="language-pt">
                    <p style="margin-bottom:0;padding-top:0;">Quando estiveres criando uma nova área:</p>
                    <ul style="list-style-type: none; margin:0; padding: 0;">
                      <li>
                        <i class="fas fa-project-diagram"></i> Finaliza o polígono (Ou pressione <b>'Enter'</b>)
                      </li>
                      <li >
                        <i class="fas fa-undo-alt"></i> Remove o último vértice (<b>'Ctrl+z'</b>)
                      </li>
                      <li >
                        <i class="fas fa-times-circle"></i> Cancela a área que estiver a criar (<b>'Esc'</b>)
                      </li>
                    </ul>
                  </span>
              </div>
            </div>
          </div>
        </div>

  </div> <!-- close DIV id="info"> -->

  </div> <!-- close DIV class="sidebar-content"> -->
  </div><!-- close DIV id="sidebar"> -->

  <!-- ###############  Div that contains the map application ############### -->
  <div id="mapdiv" class="col-md-12"></div>

  <script>
  //  ********* Global Variables Definition *********
  var mymap;
  var basemap_osm, basemap_mapbox, basemap_Gterrain, basemap_Gimagery,
      basemap_GimageHybrid, basemap_WorldImagery, Hydda_RoadsAndLabels;
  var LyrAOI, LyrAOI_coords;
  var ctlLayers, ctlCreationToolbar, ctlSidebar, ctlZoom, ctlMapOverview,
      ctlScale, ctlMouseposition, ctlAttribute;
  var statusAddLikeButton = "", statusAddDislikeButton = "";
  var siteLang;
  var temp_tab_content;
  var color_line_area, color_fill_area;
  var fgpDrawnItems;
  var area_id;
  var previousTab, activeTab;
  var sidebarOpened;
  var clickedLayerId=null;
  var editMode = false, createMode = false;
  var newTabCreated = false;
  var setStyle_normal = {"weight": 2, "fillOpacity": 0.20 };
  var setStyle_edit = {"weight": 5, "fillOpacity": 0.1};
  var setStyle_clicked = {"weight": 3.5, "fillOpacity": 0.20};
  var cntCheckedCbx;
  var firstVertex, pntClicked;
  var minimumZoom = 11;
  var closeAlertPopUpWhenDrawIsFinished;

  // # Logging variables
  var log_functions = false;
  var IsMobileDevice = false;
  var cnt_SidebarOpens = 0;
  var cnt_SidebarChangeTab = 0;
  var cnt_LikedAreas = 0;
  var cnt_DislikedAreas = 0;
  var cnt_zoomInExceeded = 0;
  var cnt_zoomOutExceeded = 0, cnt_doNotPan = 0;
  var cnt_numVertices = 0;
  var cnt_movechange = 0;
  var cnt_CtrlZPressed = 0;
  var cnt_enterKeyPressed = 0;
  var cnt_escapeKeyPressed = 0;
  var time_start_draw, time_end_draw;

  // # To Delete
  var cnt_test = 0;

  //  ********* Mobile Device parameters and Function *********
  loadMobileFunction();

  //  ********* Create Map *********
  $(document).ready(function(){
    // set the language of the application. It must be the first line of the $(document).ready()
    cbxLangChange(getCookie("app_language"));

    //  ********* Map Initialization *********
    loadBasemaps();
    minimumZoom = IsMobileDevice ? 10 : 11;
    //Create the Leaflet map elemetn
    mymap = L.map('mapdiv', {
      center: L.latLng(38.716, -9.150),
      layers: basemap_mapbox,
      zoom:14,
      maxZoom: 18,
      minZoom: minimumZoom,
      attributionControl:false,
      zoomControl:false,
      // maxBounds: mybounds,
      maxBoundsViscosity: 1.0
    });

    loadStudyArea();

    loadControls(); //Load leaflet controls

    //Initializing the feature group where all the drawn Objects will be stored
    fgpDrawnItems = new L.FeatureGroup();
    mymap.addLayer(fgpDrawnItems);
    fgpDrawnItems.addTo(mymap);

    ctlSidebar.addPanel(returnTempTabContent()); //Add Temp Tab to the sidebar
    if(siteLang=='en') createTitleLiByHref( "#temp_tab" , "Add a new Area" ); // Creates the title, to appear when the tab icon is hovered.
    if(siteLang=='pt') createTitleLiByHref( "#temp_tab" , "Adicionar uma nova área" ); // Creates the title, to appear when the tab icon is hovered.

    // Add Events
    addSidebarEvents();
    addMapEvents();

    //Keep 'pm:drawstart' event here in order to 'this' == 'document'. Inside another function the "this" element change
    mymap.on('pm:drawstart', function(e) {
      // Remember when we started
      time_start_draw = new Date().getTime();

      //A new layer has started to be drawn.
      createMode = true; //the createMode will receive 'false' when the save button is clicked
      cnt_numVertices = 0; //logs the number of clicks the user is giving, in order to add popup instructing the user.
      closeAlertPopUpWhenDrawIsFinished = true;
      this.workingLayer = e.workingLayer;
      // console.log(this);
      //toggle visibility of controls when start the drawing mode
      ctlCreationToolbar.addTo(mymap);
      ctlMapOverview.remove();
      if (!IsMobileDevice){
        ctlZoom.remove();
      }
      if ((cnt_DislikedAreas+cnt_LikedAreas)<=1){
        showInfoBox();
      }
      var layer = e.workingLayer;
      layer.on('pm:vertexadded', function(e) {
        // e includes the new vertex, it's marker the index in the coordinates array the working layer and shape
        // console.log('vertexadded', e);
        cnt_numVertices++;

        if(cnt_numVertices==1){
          //Adding Instructions popup when the user is creating the first area on the map
          if( (cnt_LikedAreas+cnt_DislikedAreas)==1){
            if(siteLang=='en') var str_popup = '<p>Click here again when you want<br /><b>to finish the draw</b>';
            if(siteLang=='pt') var str_popup = '<p>Clique aqui de novo quando<br />quiseres <b>terminar o desenho</b>';
            openAlertPopup(firstVertex, str_popup);
          }
        }

        // Checking if the vertex is inside the stydy area. returns 'true' if it's, 'false' if it's not
        if ( !(isMarkerInsidePolygon(pntClicked, LyrAOI_coords)) ){
          if(siteLang=='en') var str_popup = '<p>Please, only draw<br />inside the <b>study area</b>';
          if(siteLang=='pt') var str_popup = '<p>Por favor, apenas clique<br />dentro da <b>área de estudo</b>';
          //If the first click the user gives is outside the study area, it will restart the draw and do not close the AlertPopup
          if (cnt_numVertices==1) closeAlertPopUpWhenDrawIsFinished = false;
          openAlertPopup(pntClicked, str_popup);
          removeLastVertex();
        }

      });
      // also fired on the markers of the polygon
      layer.on('pm:snap', function(e) {
        // e includes marker, snap coordinates segment, the working layer and the distance
        // console.log('snap', e);
      });
    },this);

    ctlSidebar.open('home'); // opening the sidebar to show the basic info to the user
    document.onkeydown = KeyPress; // Capture the pressed key in the document

    $('#modal_2_demographics').modal('show');

  }); //END $(document).ready()

  //  ********* JS Functions *********
  //  # Map functions
  function cbxLangChange(value){
    if (value == 'en') {
      siteLang='en';
      $('.language-pt').hide(); // hides
      $('.language-en').show(); // Shows
    }
    else if (value == 'pt') {
      siteLang='pt';
      $('.language-en').hide(); // hides
      $('.language-pt').show(); // Shows
    }
  }
  function loadMobileFunction() {
    if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)){
      /*### DESCRIPTION: Check if the web application is being seen in a mobile device   */
      IsMobileDevice = true;
    };
    if(IsMobileDevice){
      /*### DESCRIPTION: Lock the screen of a mobile device in a landscape mode   */
      if("orientation" in screen) {
        var orientation_str = screen.orientation.type;
        var orientation_array = orientation_str.split("-");
        if( orientation_array[0] == "portrait"){
          // NEEDTO: Show this message in a modal div
          alert("This application is better seen if you change the orientation of your device to: landscape");
        }
      }
    }
    $( window ).on( "orientationchange", function( event ){
      /* DESCRIPTION: ADDDESCRIPTION  */
      //Do things based on the orientation of the mobile device
      if(IsMobileDevice){
        if("orientation" in screen) {
          var orientation_array = (screen.orientation.type).split("-");
          if( orientation_array[0] == "portrait"){
            // NEEDTO: Show this message in a modal div
            alert("Change the orientation of the device to: landscape");
          }else{  //landscape mode
            //Reloads the page
            //location.reload();
            // console.log( orientation_array[0] );
          }
        }
      }
    });//END $( window ).on( "orientationchange", ())
  }
  function loadStudyArea(){
    /* DESCRIPTION: Adds the Study area, comprises of 12 freguesias:
     * Estrela, Misericórdia, Santa Maria Maior, São Vicente, Penha de França, Beato,
     * Arroios, Santo António, Campo de Ourique, Campolide, Avenidas Novas, Areeiro  */
    $.ajax({
      url:'eimg_get_dbtable.php',
      data: {
        type_op: "data",
        tbl: "study_area_4326",
        select:"*"
      },
      type:'POST',
      success:function(response){
        // console.log(response);
        var layer = JSON.parse(response);
        // console.log(layer);
        LyrAOI_coords = layer.features[0].geometry.coordinates;
        LyrAOI=L.geoJSON(layer);
        var lyr_bounds = LyrAOI.getBounds();
        var value = 0.03;
        LyrAOI.addTo(mymap);
        //Creating a boundary for the map based on the bounds of the layer added
        //Increasing lat and long in the same proportion
        var slt = (lyr_bounds._southWest.lat)-value; //south latitude
        var sln = (lyr_bounds._southWest.lng)-value*2; //south longitude
        var nlt = (lyr_bounds._northEast.lat)+value; //north latitude
        var nln = (lyr_bounds._northEast.lng)+value*2; //north longitude
        // defining the max bounds for panning around the map
        var southWest = L.latLng(slt,sln);
        var northEast = L.latLng(nlt,nln);
        var mybounds =  L.latLngBounds(southWest, northEast);
        //Zoom the map to the bounds of the added layer
        mymap.fitBounds(LyrAOI.getBounds());
        //Set the maximum boundaries in which the map can be panned
        mymap.setMaxBounds(mybounds);
        //Create a test polygon to see the area of the maxBounds
        // var polygon1 = L.polygon([[slt, sln],[slt, nln],[nlt, nln],[nlt, sln]]).addTo(mymap);
      },
      error: function(xhr, status, error){ alert("ERROR: "+error); }
    }); // End ajax
  }
  function loadBasemaps() {
    /* DESCRIPTION: Add basemaps to the map*/
    basemap_osm = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
      attribution: '&copy;<a href="http://osm.org/copyright">OSM</a>'
    });
    basemap_mapbox = L.tileLayer("https://api.mapbox.com/styles/v1/mapbox/streets-v9/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZ2lzMm1hdGhldXMiLCJhIjoiY2lsYXRkcTQ2MGJudXVia25ueXZyMzJkcCJ9.sc74TfXfIWKE2Xw3aVcNvw", {
      attribution: '&copy;<a href="https://www.mapbox.com/feedback/">Mapbox</a>'
    });
    basemap_Gterrain = L.tileLayer('http://{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}',{
      subdomains:['mt0','mt1','mt2','mt3']
    });
    basemap_Gimagery = L.tileLayer('http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',{
      subdomains:['mt0','mt1','mt2','mt3']
    });
    basemap_GimageHybrid = L.tileLayer('http://{s}.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}',{
      subdomains:['mt0','mt1','mt2','mt3']
    });
    basemap_WorldImagery = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
      attribution: '&copy;<a href="https://www.esri.com/en-us/home">Esri</a>'
    });
    Hydda_RoadsAndLabels = L.tileLayer('https://{s}.tile.openstreetmap.se/hydda/roads_and_labels/{z}/{x}/{y}.png', {
      name: 'overlay',
    });
  }
  function loadControls() {
    /* Add leaflet controls to the map */
    //Plugin leaflet-sidebar-v2: https://github.com/nickpeihl/leaflet-sidebar-v2
    ctlSidebar = L.control.sidebar({
      container:'sidebar_div',
      autopan: false,
      closeButton: false,
    }).addTo(mymap);

    if(siteLang=='en') {
      createTitleLiByHref( "#home" , "Click to see the Home" );
      createTitleLiByHref( "#info" , "Click to see information" );
    }
    if(siteLang=='pt') {
      createTitleLiByHref( "#home" , "Clique para ir ao início" );
      createTitleLiByHref( "#info" , "Clique para ir para ver as informações" );
    }

    //Add attribution to the map
    ctlAttribute = L.control.attribution({position:'bottomright'}).addTo(mymap);
    ctlAttribute.addAttribution('OSM');
    ctlAttribute.addAttribution('&copy;<a href="http://mastergeotech.info">Master GeoTech</a>');
    ctlAttribute.addAttribution('&copy;<a href="https://github.com/codeofsumit/leaflet.pm">LeafletPM</a>');

    //Control scale
    ctlScale = L.control.scale({position:'bottomright', metric:true, imperial:false, maxWidth:200, }).addTo(mymap);

    //Control Latitude and Longitude
    if (!IsMobileDevice){
      ctlMouseposition = L.control.mousePosition({position:'bottomright'}).addTo(mymap);
    }

    // Add the overview control to the map
    ctlMapOverview = L.control.overview({
      position: 'bottomright',
      onAfterInitLayout: function (overview) {
      }
    }).addTo(mymap);

    ctlLayers = L.control.layers(
      {
        '<i class="fas fa-map-marked"></i>': basemap_mapbox,
        '<i class="fas fa-mountain"></i>': basemap_Gterrain,
        '<i class="fas fa-globe-americas"></i>': basemap_GimageHybrid,
        // '<i class="fas fa-image"></i>': basemap_WorldImagery
      }, null, {collapsed: false}
    ).addTo(mymap);

    // Adds a control using the easy button plugin
    var ctlFinishArea = L.easyButton('fa-project-diagram', function(){finishCreation();}, 'Click to complete the drawing');
    var ctlRemoveLastVertex = L.easyButton('fa-undo-alt', function(){removeLastVertex();}, 'Click to remove the last vertex');
    var ctlCancelArea = L.easyButton('fa-times-circle', function(){removeArea(area_id, true);}, 'Click to cancel the drawing');
    ctlCreationToolbar = L.easyBar([ ctlFinishArea, ctlRemoveLastVertex, ctlCancelArea],{position:'topright'});

    var container = L.DomUtil.create('div', 'infobox_for_toolbar leaflet-bar leaflet-control', ctlCreationToolbar.getContainer());
    container.title="Toolbar Instructions";

    if(siteLang=='en'){
      container.innerHTML = '<p>Finish drawing (Enter)</p><p style="padding-top:0;">Remove vertex (Ctrl+z)</p><p style="padding-top:0;">Cancel Drawing (Esc)</p>';
      container.style.marginLeft= '-145px';
      container.style.width= '140px';
    }
    if(siteLang=='pt'){
      container.innerHTML = '<p>Finalizar (Enter)</p><p style="padding-top:0;">Remover vértice (Ctrl+z)</p><p style="padding-top:0;">Cancelar (Esc)</p>';
      container.style.marginLeft= '-149px';
      container.style.width= '145px';
    }
    // styles: .infobox_for_toolbar
    // events
    container.onmouseover = function(){ container.style.visibility = 'hidden';}

    // Add Zoom if not in the
    if (!IsMobileDevice){
      ctlZoom = L.control.zoom({position:'topright'}).addTo(mymap);
    }
  }
  function addMapEvents() {
    /* DESCRIPTION: Add all the events related to the leaflet map element */
    mymap.on("moveend", function () {
      // console.log(mymap.getCenter().toString());
      if(mymap.getZoom()==minimumZoom+1){
        cnt_doNotPan++;
        if(siteLang=='en') var str_popup = "<h6>Please, stay in this area only!</h6>";
        if(siteLang=='pt') var str_popup = "<h6>Por favor, mantenha nessa área somente!</h6>";
        if( cnt_doNotPan<3) openAlertPopup(mymap.getCenter(), str_popup,1000 );
      }
    });
    mymap.on("movestart", function (e) {
      // console.log(mymap.getCenter().toString());
      // console.log(e);
      // var mapClickedPositon = [e.latlng.lat, e.latlng.lng];
      // var cntMousePosition = 0;
      // cnt_movechange++;
      // console.log("MoveStart:",cnt_movechange);
    });
    mymap.on("zoomend", function () {
      // console.log(mymap.getCenter().toString());
      var zoomNotAllowed = minimumZoom;
      if(mymap.getZoom()==zoomNotAllowed){
        cnt_zoomOutExceeded++;
        if(siteLang=='en') var str_popup = "<h6>Minimum zoom exceeded!</h6>";
        if(siteLang=='pt') var str_popup = "<h6>Zoom mínimo ultrapassado!</h6>";

        if( cnt_zoomOutExceeded<5)  openAlertPopup(mymap.getCenter(), str_popup,1000 );
        setTimeout(function(){
          mymap.setZoom(zoomNotAllowed+1);
        }, 400);
      }
      // if(mymap.getZoom()==18 && cnt_zoomInExceeded<1){
      //   cnt_zoomInExceeded++;
      //   openAlertPopup(mymap.getCenter(), "<h5>Maximum zoom limit!</h5>",1000 );
      // }
    });
    mymap.on('baselayerchange', function(e){
      // console.log(e);
      if (e.name == '<i class="fas fa-image"></i>'){
        ctlLayers.addOverlay(Hydda_RoadsAndLabels, 'streets');
      }else{
        mymap.removeLayer(Hydda_RoadsAndLabels);
        ctlLayers.removeLayer(Hydda_RoadsAndLabels);
      }
    })
    mymap.on('contextmenu', function(e){
      /* DESCRIPTION: listener when a click is given on the map  */
      // $("#divLog").text("Map Clicked... Random Number: "+(Math.floor(Math.random() * 100)).toString());
      if(editMode){
        //if in editMode or createMode the area_id is already set to be accessed in the function
        saveArea();
      }
    });
    mymap.on('mousemove', function(e){
      /* DESCRIPTION: listener when a click is given on the map  */
      // console.log(1);
    });
    mymap.on('click', function(e){
      /* DESCRIPTION: listener when a click is given on the map  */
      pntClicked = e.latlng; // FORMAT: {lat: 38.72452, lng: -9.11160}
      // openAlertPopup(e.latlng, "<h6>test!</h6>",1000 )

      if(createMode && cnt_numVertices==0) firstVertex =  pntClicked;

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
      ctlMapOverview.addTo(mymap);
      if (!IsMobileDevice){
        ctlZoom.addTo(mymap);
      }
      if(closeAlertPopUpWhenDrawIsFinished) mymap.closePopup();

      //When the user is drawing it means that the 'area_id' should exist and it's the id of the area being drawn
      //A creation of a new area is only finished when the user clicks the save button
      createMode = false;
    });

    mymap.on('pm:create', function(e) {
      // console.log(e);
      // Remember when we finished
      time_end_draw = new Date().getTime();

      var lyrDraw = e.layer;

      var width = lyrDraw.getBounds().getEast() - lyrDraw.getBounds().getWest();
      var height = lyrDraw.getBounds().getNorth() - lyrDraw.getBounds().getSouth();

      // console.log(
      //   'center:' + lyrDraw.getCenter() +'\n'+
      //   'width:' + width +'\n'+
      //   'height:' + height +'\n'
      // );

      //Initialize the attributes. We can name it the way we want
      var feature = lyrDraw.feature = lyrDraw.feature || {};
      feature.type = feature.type || "Feature"; //Could be the name we want
      var props = feature.properties = feature.properties || {};
      props.id = area_id;
      // Calculate time spent for this drawing
      props.time_draw_sec = (time_end_draw - time_start_draw)/1000;

      //General style
      lyrDraw.setStyle({"color": color_line_area, "opacity": 0.75, 'fillColor': color_fill_area });

      var jsn_draw=lyrDraw.toGeoJSON().geometry;
      //Count the number of coordinates inside the JSON geometry.
      //In the case of polygon. The last element is equal to the first in order close the polygon.
      //So the subtraction of 1 gives us the exactly number of vertices of the drawn polygon
      var numberOfVertices = ((jsn_draw.coordinates[0]).length)-1;
      if (numberOfVertices < 3){
        if(siteLang=='en') alert("The area drawn has less than 3 vertices.\nPlease, draw it again!");
        if(siteLang=='pt') alert("A área desenhada tem menos de 3 vértices.\nPor favor, comece de novo!");
        // Start a new draw again
        restartDraw(lyrDraw);
        return;
      }

      if( (width<0.0007) || (height<0.0007) ){
        if(siteLang=='en') alert("The area drawn is too small\nPlease, draw it again!");
        if(siteLang=='pt') alert("A área desenhada é muito pequena\nPor favor, comece de novo!");
        // Start a new draw again
        mymap.removeLayer(lyrDraw);
        var button_drawArea_id = area_id+"_drawArea";
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

      document.getElementById(area_id+"_drawArea").style.display="none";
      document.getElementById(area_id+"_saveArea").style.display="block";
      //Show attributes div
      document.getElementById(area_id+"_divChosenAttr").style.display = "block";

      // Enabling edit to the layer
      fgpDrawnItems.eachLayer(function(layer){
        var layer_id = layer.feature.properties.id;
        if(layer_id == area_id){
          //When the layer is created, the sidebar is opened and the layer continues in the edit mode until the user clicks save
          editMode = true;
          layer.setStyle(setStyle_edit);
          layer.pm.enable();
          return;
        }
      });

      //Open the sidebar
      if (getActiveTabId()!=area_id){ctlSidebar.open(area_id);}

    });//pm:create
  }
  function isMarkerInsidePolygon(marker, poly_coords) {
    /* DESCRIPTION: Check if the point is inside a polygon
     * marker format == {lat: 38.744, lng: -9.111}
     * polygon format == [lng, lat]
     * source: https://stackoverflow.com/questions/31790344/determine-if-a-point-reside-inside-a-leaflet-polygon*/
    var x = marker.lng, y = marker.lat;
    var inside = false;
    for (var i = 0, j = poly_coords.length - 1; i < poly_coords.length; j = i++) {
        var xi = poly_coords[i][0], yi = poly_coords[i][1];
        var xj = poly_coords[j][0], yj = poly_coords[j][1];

        var intersect = ((xi > x) != (xj > x))
            && (y < (yj - yi) * (x - xi) / (xj - xi) + yi);
        if (intersect) inside = !inside;
    }
    // console.log(inside);
    return inside;
  };

  //  # Drawing Functions
  function drawArea(button_clicked_properties){
    /* DESCRIPTION: It tun after the user clicked on the button 'Draw Area' inside an liked or disliked tab */
    // Passing the ID gotten from the id of the button clicked to the global variable in order to be accesed in the anonymous functions
    if (createMode==false){
      area_id = ((button_clicked_properties.id).split("_"))[0];
      if (log_functions){console.log('drawArea', area_id);}

      document.getElementById(area_id+"_str_startdrawing").innerHTML ="";
      document.getElementById(area_id+"_removeArea").style.display="block";
      if((cnt_LikedAreas+cnt_DislikedAreas)==6){
        // Number of added areas reached. Block the option to create new area
        var elementsOfClass= document.getElementsByClassName('createNewAreaClass');
        for (var i = 0; i < elementsOfClass.length; i++) {
          elementsOfClass[i].style.display = "none";
        }
      }

      // console.log(document.getElementById(area_id+"_str_startdrawing").innerHTML );
      ctlSidebar.close();
      if (area_id.split("-")[0] == "liked") {
        color_line_area = "forestgreen";
        color_fill_area = "#0F0";
      }else{
        color_line_area = "#F00";
        color_fill_area = "#F00";
      }
      var drawingOptions = {
        // snapping
        snappable: true,
        snapDistance: 15,
        finishOn: 'contextmenu', // example events: 'mouseout', 'dblclick', 'contextmenu'
        templineStyle: {color: color_line_area, weight: 2} ,
        hintlineStyle: { color: color_line_area, weight: 2, dashArray: [5, 5] },
        allowSelfIntersection: false
      };
      mymap.pm.enableDraw('Poly', drawingOptions);
    }
  }//END drawArea()
  function saveArea(button_clicked_properties){
    /* DESCRIPTION: Function fired up when the user clicks on the 'Save Area' button of the sidebar tab */
    //if no 'button_clicked_properties', it means that this function was called by some behaviour of the user
    // it only has 1 possibilities to call this function. createMode == true
    if (button_clicked_properties) {area_id = ((button_clicked_properties.id).split("_"))[0];}
    if (log_functions) console.log('saveArea', area_id, createMode, editMode);

    //count the number of checkbox checked for the area_id
    countCheckCbx();

    if(cntCheckedCbx == 0){
      // No attribute was selected
      warnCheckAtt();

      //Open the sidebar
      if (getActiveTabId()!=area_id){ctlSidebar.open(area_id);}
      return null;
    }else{
      //At least one attribute was selected, can proceed with saving...

      // Disable edit mode and setStyle for layer
      fgpDrawnItems.eachLayer(function(layer){
        var layer_id = layer.feature.properties.id;
        if(layer_id == area_id){
          editMode = false;
          layer.pm.disable();
          mymap.pm.disableDraw('Poly');

          if(getActiveTabId()==area_id){
            //If the tab is opened in the area_id tab the style must receive the setStyle_clicked
            layer.setStyle(setStyle_clicked);
          }else{
            //If the tab is not opened in the area_id tab the style must receive the setStyle_normal
            layer.setStyle(setStyle_normal);
          }
          return;
        }
      });

      var att_nat = document.getElementById(area_id+"_cbxAtt-nat").checked;
      var att_open = document.getElementById(area_id+"_cbxAtt-open").checked;
      var att_ord = document.getElementById(area_id+"_cbxAtt-order").checked;
      var att_up = document.getElementById(area_id+"_cbxAtt-upkeep").checked;
      var att_hist = document.getElementById(area_id+"_cbxAtt-hist").checked;

      //change style of checkboxes
      if( att_nat ){
        document.getElementById(area_id+"_lblAtt-nat").style.textDecoration = "none";
        document.getElementById(area_id+"_lblAtt-nat").style.color = "grey";
        document.getElementById(area_id+"_cbxAtt-nat").disabled = true;
      } else {
        document.getElementById(area_id+"_lblAtt-nat").style.textDecoration = "line-through";
        document.getElementById(area_id+"_lblAtt-nat").style.color = "grey";
        document.getElementById(area_id+"_cbxAtt-nat").disabled = true;
      }
      if( att_open ){
        document.getElementById(area_id+"_lblAtt-open").style.textDecoration = "none";
        document.getElementById(area_id+"_lblAtt-open").style.color = "grey";
        document.getElementById(area_id+"_cbxAtt-open").disabled = true;
      } else {
        document.getElementById(area_id+"_lblAtt-open").style.textDecoration = "line-through";
        document.getElementById(area_id+"_lblAtt-open").style.color = "grey";
        document.getElementById(area_id+"_cbxAtt-open").disabled = true;
      }
      if( att_ord ){
        document.getElementById(area_id+"_lblAtt-order").style.textDecoration = "none";
        document.getElementById(area_id+"_lblAtt-order").style.color = "grey";
        document.getElementById(area_id+"_cbxAtt-order").disabled = true;
      } else {
        document.getElementById(area_id+"_lblAtt-order").style.textDecoration = "line-through";
        document.getElementById(area_id+"_lblAtt-order").style.color = "grey";
        document.getElementById(area_id+"_cbxAtt-order").disabled = true;
      }
      if( att_up ){
        document.getElementById(area_id+"_lblAtt-upkeep").style.textDecoration = "none";
        document.getElementById(area_id+"_lblAtt-upkeep").style.color = "grey";
        document.getElementById(area_id+"_cbxAtt-upkeep").disabled = true;
      } else {
        document.getElementById(area_id+"_lblAtt-upkeep").style.textDecoration = "line-through";
        document.getElementById(area_id+"_lblAtt-upkeep").style.color = "grey";
        document.getElementById(area_id+"_cbxAtt-upkeep").disabled = true;
      }
      if( att_hist ){
        document.getElementById(area_id+"_lblAtt-hist").style.textDecoration = "none";
        document.getElementById(area_id+"_lblAtt-hist").style.color = "grey";
        document.getElementById(area_id+"_cbxAtt-hist").disabled = true;
      } else {
        document.getElementById(area_id+"_lblAtt-hist").style.textDecoration = "line-through";
        document.getElementById(area_id+"_lblAtt-hist").style.color = "grey";
        document.getElementById(area_id+"_cbxAtt-hist").disabled = true;
      }

      document.getElementById(area_id+"_reason_str").disabled = true;
      // Show 'edit' button, hide 'save' button
      document.getElementById(area_id+"_createNewArea").style.display="block";
      document.getElementById(area_id+"_saveArea").style.display="none";
      document.getElementById(area_id+"_editArea").style.display="block";

      // if(getActiveTabId()!="temp_tab") ctlSidebar.open("temp_tab");
    }
  };//END saveArea()
  function editArea(button_clicked_properties){
    /* DESCRIPTION: It's run when the user clicks in the edit button of the sidebar*/
    //To use area_id inside an anonymous function (mymap.on('contextmenu', function(){}), it must be global
    area_id = ((button_clicked_properties.id).split("_"))[0];
    if (log_functions){console.log('editArea', area_id);}

    var att_nat = document.getElementById(area_id+"_cbxAtt-nat");
    var att_open = document.getElementById(area_id+"_cbxAtt-open");
    var att_ord = document.getElementById(area_id+"_cbxAtt-order");
    var att_up = document.getElementById(area_id+"_cbxAtt-upkeep");
    var att_hist = document.getElementById(area_id+"_cbxAtt-hist");

    if( att_nat ){
      document.getElementById(area_id+"_lblAtt-nat").style.textDecoration = "none";
      document.getElementById(area_id+"_lblAtt-nat").style.color = "black";
      document.getElementById(area_id+"_cbxAtt-nat").disabled = false;
    }
    if( att_open ){
      document.getElementById(area_id+"_lblAtt-open").style.textDecoration = "none";
      document.getElementById(area_id+"_lblAtt-open").style.color = "black";
      document.getElementById(area_id+"_cbxAtt-open").disabled = false;
    }
    if( att_ord ){
      document.getElementById(area_id+"_lblAtt-order").style.textDecoration = "none";
      document.getElementById(area_id+"_lblAtt-order").style.color = "black";
      document.getElementById(area_id+"_cbxAtt-order").disabled = false;
    }
    if( att_up ){
      document.getElementById(area_id+"_lblAtt-upkeep").style.textDecoration = "none";
      document.getElementById(area_id+"_lblAtt-upkeep").style.color = "black";
      document.getElementById(area_id+"_cbxAtt-upkeep").disabled = false;
    }
    if( att_hist ){
      document.getElementById(area_id+"_lblAtt-hist").style.textDecoration = "none";
      document.getElementById(area_id+"_lblAtt-hist").style.color = "black";
      document.getElementById(area_id+"_cbxAtt-hist").disabled = false;
    }

    //Style options
    if(mymap.hasLayer(fgpDrawnItems)){
      fgpDrawnItems.eachLayer(function(layer){
        var layer_id = layer.feature.properties.id;
        // console.log(layer_id);
        if(layer_id == area_id){
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

    document.getElementById(area_id+"_reason_str").disabled = false;
    // Show 'save' button, hide 'edit' button
    document.getElementById(area_id+"_editArea").style.display="none";
    document.getElementById(area_id+"_saveArea").style.display="block";

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
        area_id = button_clicked_properties;
        var close_sidebar = false;
      }else{
        area_id = (button_clicked_properties.id).split("_")[0];
        var close_sidebar = true;
      }
      mymap.pm.disableDraw('Poly');
      // console.log(fgpDrawnItems.getLayers() );
      if(mymap.hasLayer(fgpDrawnItems)){
        fgpDrawnItems.eachLayer(function(layer){
          var layer_id = layer.feature.properties.id;
          // console.log(layer_id);
          if(layer_id == area_id){
            // layer.getPopup()._content = "";
            // layer.getPopup().update();
            fgpDrawnItems.removeLayer(layer);
            // console.log(layer.getPopup());
            // layer.closePopup();
            return;
          }
        });
      }

      //Once an area is removed a new area could be added again
      // Showing the 'Create New Area' button
      var elementsOfClass= document.getElementsByClassName('createNewAreaClass');
      for (var i = 0; i < elementsOfClass.length; i++) {
        elementsOfClass[i].style.display = "block";
      }

      editMode = false;
      createMode = false;
      deleteTabByHref('#'+area_id, close_sidebar);
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
      //At least one click was given, so firstVertex exists
      if(siteLang=='en') var str_popup = '<p>Please, add at least <br /><b>3 vertices</b>';
      if(siteLang=='pt') var str_popup = '<p>Por favor, adicione no mínimo <br /><b>3 vértices</b>';
      openAlertPopup(firstVertex, str_popup);
    }else{
      if(siteLang=='en') var str_popup = '<p>Please, add at least <br /><b>3 vertices</b>';
      if(siteLang=='pt') var str_popup = '<p>Por favor, adicione no mínimo <br /><b>3 vértices</b>';
      openAlertPopup(mymap.getCenter(), str_popup);
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
  function showInfoBox(){
    /* DESCRIPTION: Shows a Information Box to the user in order to know how to use the CreationToolbar*/
    $('.infobox_for_toolbar').css('visibility','visible');
    //hide after 4 seconds
    setTimeout(function() {
      $('.infobox_for_toolbar').css('visibility','hidden');
    }, 15000);
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
    var button_drawArea_id = area_id+"_drawArea";
    document.getElementById(button_drawArea_id).click();
  }
  function openAlertPopup(popup_position, popup_content, duration_open=5000){
    /* DESCRIPTION: Shows the user a message in a Popup instead of using alert*/
    var popup_options = {
      // 'autoClose':	false,
      'closeOnClick':	false,
      'className' : 'popupInfo'
    }

    //close any popup if open
    mymap.closePopup();
    var infoPopUp = L.popup(popup_options)
    .setLatLng(popup_position) // FORMAT == {lat: 38.7345, lng: -9.1111}
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
    if( (clickedTab!='#temp_tab') && ((cnt_LikedAreas + cnt_DislikedAreas) < 6) ){
      // ctlSidebar.removePanel('temp_tab'); //It just hide the Panel
      deleteTabByHref('#temp_tab');
      ctlSidebar.addPanel(returnTempTabContent());
      if(siteLang=='en') createTitleLiByHref( "#temp_tab" , "Add a new Area" );
      if(siteLang=='pt') createTitleLiByHref( "#temp_tab" , "Adicionar uma nova área" );
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
    // When the user clicks to create a new area but nothing's drawn for that area.
    // When the status of the sidebar changes, this new area is deleted
    if(previousTab!=null){
      if (createMode==false){
        var array_tabs = existentTabs();
        if (newTabCreated){
          //toggle newTabCreated to false;
          newTabCreated = false;
          for (var i = 0; i < array_tabs.length; i++) {
            var tab_id = array_tabs[i];
            var tabprefix = tab_id.split("-")[0];
            //checking if exist a liked or disliked area
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

    // update the status of the button for creating a new 'liked' or 'disliked' area
    if ( cnt_LikedAreas < 3){
      statusAddLikeButton = "";
    }
    if ( cnt_DislikedAreas < 3){
      statusAddDislikeButton = "";
    }

    //When temp_tab is clicked the icon for this tab is changed
    if (clickedTab=="#temp_tab"){
      document.getElementById('dynamic-icon-tab').className = 'fa fa-question-circle';
    }

  }//END function sidebarChange()
  function create_areaTab(typeOfArea){
    /* DESCRIPTION: Creates a new tab based on the option chosen in the #temp_tab: It will be either Liked or Disliked tab  */
    if(typeOfArea=="liked"){
      var liked = true;
      var icon = "thumbs-up";
      cnt_LikedAreas++;
      for (cnt = 1; cnt <= 3; cnt++) {
        if( !(searchTagIfExistsByHref("#"+typeOfArea+'-'+cnt.toString())) ){
          break;
        }
      }
      var tab_id = typeOfArea+'-'+cnt.toString();
      var title = typeOfArea.charAt(0).toUpperCase()+typeOfArea.slice(1) +' Area '+cnt;

    }else if(typeOfArea=="disliked"){
      var liked = false;
      var icon = "thumbs-down";
      cnt_DislikedAreas++;
      var cnt = cnt_DislikedAreas;
      for (cnt = 1; cnt <= 3; cnt++) {
        if( !(searchTagIfExistsByHref("#"+typeOfArea+'-'+cnt.toString())) ){
          break;
        }
      }
      var tab_id = typeOfArea+'-'+cnt.toString();
      if(liked){
        if(siteLang=='en') var title = 'Liked area '+cnt;
        if(siteLang=='pt') var title = 'Área curtida '+cnt;
      }else{
        if(siteLang=='en') var title = 'Disliked area '+cnt;
        if(siteLang=='pt') var title = 'Área não curtida '+cnt;
      }
    }
    // alert(tab_id);
    var str_newtab = "";
    str_newtab += '<div class="col-xs-12">';
    str_newtab +=   '<div id="'+tab_id+'_divChosenAttr" style="display:none; padding-left:10px; padding-top:2px;">';

    if(siteLang =='en') str_newtab += '<h4>Choose the attributes that corresponding to the drawn area*:</h4><p>(*Check at least 1 attribute)</p>';
    if(siteLang =='pt') str_newtab += '<h4>Escolha os atributos que correspondem a área desenhada*:</h4><p>(*Escolha ao menos 1 atributo)</p>';

    str_newtab +=     '<span id="'+tab_id+'_str_checkcbx" ></span>'; //NEEDTO: say to user to click save button
    str_newtab +=     '<input type="checkbox" id="'+tab_id+'_cbxAtt-nat"" class="'+tab_id+'_cbxAttributes cbxsidebar" name="dlg_fltAttributes" value="att_nat">';
    str_newtab +=     '<label id="'+tab_id+'_lblAtt-nat" class="cbxsidebar" for="'+tab_id+'_cbxAtt-nat"> ';
    if(liked){
      if(siteLang=='en') str_newtab += 'Presence of Nature';
      if(siteLang=='pt') str_newtab += 'Natureza presente';
    }else{
      if(siteLang=='en') str_newtab += 'Man-made nuisances';
      if(siteLang=='pt') str_newtab += 'Natureza não presente';
    }
    str_newtab +=     '</label><br />';
    str_newtab +=     '<input type="checkbox" id="'+tab_id+'_cbxAtt-open" class="'+tab_id+'_cbxAttributes cbxsidebar" name="dlg_fltAttributes" value="att_open">';
    str_newtab +=     '<label id="'+tab_id+'_lblAtt-open" class="cbxsidebar" for="'+tab_id+'_cbxAtt-open"> ';
    if(liked){
      if(siteLang=='en') str_newtab += 'Not condensed settlements';
      if(siteLang=='pt') str_newtab += 'Áreas abertas';
    }else{
      if(siteLang=='en') str_newtab += 'Condensed settlements';
      if(siteLang=='pt') str_newtab += 'Áreas não abertas';
    }
    str_newtab +=     '</label><br />';
    str_newtab +=     '<input type="checkbox" id="'+tab_id+'_cbxAtt-order" class="'+tab_id+'_cbxAttributes cbxsidebar" name="dlg_fltAttributes" value="att_order">';
    str_newtab +=     '<label id="'+tab_id+'_lblAtt-order" class="cbxsidebar" for="'+tab_id+'_cbxAtt-order"> ';
    if(liked){
      if(siteLang=='en') str_newtab += 'Order';
      if(siteLang=='pt') str_newtab += 'Organização';
    }else{
      if(siteLang=='en') str_newtab += 'Disorganization';
      if(siteLang=='pt') str_newtab += 'Desorganização';
    }
    str_newtab +=     '</label><br />';
    str_newtab +=     '<input type="checkbox" id="'+tab_id+'_cbxAtt-upkeep" class="'+tab_id+'_cbxAttributes cbxsidebar" name="dlg_fltAttributes" value="att_upkeep">';
    str_newtab +=     '<label id="'+tab_id+'_lblAtt-upkeep" class="cbxsidebar" for="'+tab_id+'_cbxAtt-upkeep"> ';
    if(liked){
      if(siteLang=='en') str_newtab += 'Well maintained';
      if(siteLang=='pt') str_newtab += 'Boa manutenção';
    }else{
      if(siteLang=='en') str_newtab += 'Dilapidated area';
      if(siteLang=='pt') str_newtab += 'Má manutenção';
    }
    str_newtab +=     '</label><br />';
    str_newtab +=     '<input type="checkbox" id="'+tab_id+'_cbxAtt-hist" class="'+tab_id+'_cbxAttributes cbxsidebar" name="dlg_fltAttributes" value="att_hist">';
    str_newtab +=     '<label id="'+tab_id+'_lblAtt-hist" class="cbxsidebar" for="'+tab_id+'_cbxAtt-hist"> ';
    if(liked){
      if(siteLang=='en') str_newtab += 'Cultural/social';
      if(siteLang=='pt') str_newtab += 'Significado histórico';
    }else{
      if(siteLang=='en') str_newtab += '--Nor historical signifcance';
      if(siteLang=='pt') str_newtab += '--dusadasu';
    }
    str_newtab +=     '</label><br /><hr />';

    if(liked){
      if(siteLang =='en') str_newtab += '<h6>Write below a reason why you <u>like</u> the area:</h6>';
      if(siteLang =='pt') str_newtab += '<h6>Escreva uma razão pela qual você <u>curte</u> essa área:</h6>';
    }else{
      if(siteLang =='en') str_newtab += '<h6>Write below a reason why you <u>disliked</u> the area:</h6>';
      if(siteLang =='pt') str_newtab += '<h6>Escreva uma razão pela qual você <u>não curte</u> essa área:</h6>';
    }
    str_newtab += '<input type="text" class="col" id="'+tab_id+'_reason_str" style="height:30px;" name="evaluative_reason" maxlength="400" placeholder="';

    if(siteLang =='en') str_newtab += 'Type the reason here';
    if(siteLang =='pt') str_newtab += 'Escreva sua razão aqui';

    str_newtab += '">';
    str_newtab +=   '</div>';

    str_newtab +=   '<div class="sidebarContentChild">';
    str_newtab +=     '<span class="contenChildSpan" id="'+tab_id+'_str_startdrawing" >';
    if(liked){
      if(siteLang=='en') str_newtab += '<h4>Click on the button below to start drawing the area you like';
      if(siteLang=='pt') str_newtab += '<h4>Clique no botão abaixo para criar a área que você curte';
    }else{
      if(siteLang=='en') str_newtab += '<h4>Click on the button below to start drawing the area you dislike';
      if(siteLang=='pt') str_newtab += '<h4>Clique no botão abaixo para criar a área que você não curte';
    }
    str_newtab +=       '</h4>';
    str_newtab +=     '</span>';
    str_newtab +=   '</div>';


    str_newtab +=   '<div class="sidebarContentChild">';
    str_newtab +=     '<span class="contenChildSpan">';
    str_newtab +=       '<button id="'+tab_id+'_drawArea" class="btn btn-warning" onclick="drawArea(this)">';
    str_newtab +=         '<i class="fa fa-edit"></i> ';
    if(siteLang=='en') str_newtab += 'Draw area';
    if(siteLang=='pt') str_newtab += 'Criar área';
    str_newtab +=       '</button>';
    str_newtab +=       '<button id="'+tab_id+'_saveArea" class="btn btn-success" style="display:none;" onclick="saveArea(this)">';
    str_newtab +=         '<i class="fa fa-save"></i> ';
    if(siteLang=='en') str_newtab += 'Save';
    if(siteLang=='pt') str_newtab += 'Salvar';
    str_newtab +=       '</button>';
    str_newtab +=       '<button id="'+tab_id+'_editArea" class="btn btn-warning" style="display:none;" onclick="editArea(this)">';
    str_newtab +=         '<i class="fa fa-pen"></i> ';
    if(siteLang=='en') str_newtab += 'Edit';
    if(siteLang=='pt') str_newtab += 'Editar';
    str_newtab +=       '</button>';
    str_newtab +=     '</span>';
    str_newtab +=     '<span class="contenChildSpan">';
    str_newtab +=       '<button id="'+tab_id+'_removeArea" class="btn btn-danger" style="display:none;" onclick="removeArea(this)">';
    str_newtab +=         '<i class="fa fa-trash-alt"></i> ';
    if(siteLang=='en') str_newtab += 'Remove area';
    if(siteLang=='pt') str_newtab += 'Remover área';
    str_newtab +=       '</button>';
    str_newtab +=     '</span>';
    str_newtab +=   '</div>';

    str_newtab +=   '<div id="'+tab_id+'_createNewArea" class="sidebarContentChild createNewAreaClass" style="display:none;">';
    str_newtab +=     '<span class="contenChildSpan">';
    str_newtab +=       '<h5>';
    if(siteLang=='en') str_newtab += 'And now: ';
    if(siteLang=='pt') str_newtab += 'E agora: ';
    str_newtab +=       '</h5>';
    str_newtab +=     '</span>';
    str_newtab +=     '<span class="contenChildSpan">';
    str_newtab +=       '<button class="btn btn-light btn-block" onclick="ctlSidebar.open(\'temp_tab\')"><i class="fa fa-plus"></i> ';
    if(siteLang=='en') str_newtab += 'Create new area';
    if(siteLang=='pt') str_newtab += 'Criar nova área';
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

    if(siteLang=='en') createTitleLiByHref( "#"+tab_id , "See "+title );
    if(siteLang=='pt') createTitleLiByHref( "#"+tab_id , "Clique para ver a "+title );

    if ( cnt_LikedAreas == 3){
      statusAddLikeButton = "disabled";
    }
    if ( cnt_DislikedAreas == 3){
      statusAddDislikeButton = "disabled";
    }
    if ( (cnt_LikedAreas + cnt_DislikedAreas) < 6 ){
      // If num=6 doesn't add the tab
      ctlSidebar.addPanel(returnTempTabContent());
      if(siteLang=='en') createTitleLiByHref( "#temp_tab" , "Add a new Area" );
      if(siteLang=='pt') createTitleLiByHref( "#temp_tab" , "Adicionar uma nova área" );
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

    //variable for verifying when a 'liked' or 'disliked' area was created. It should be after the sidebar is opened
    newTabCreated = true;

  };//END create_areaTab()
  function returnTempTabContent(){
    /* DESCRIPTION: Returns the content of the '#temp_tab' update the button status all the time it's called
     * It creates an "li" element that only contains an "a" element of href="#"+{id}, in this case: "#temp_tab"
     * It also creates a "div" element where received the id={id}, in this case: id="temp_tab".
     * When the li element containing the "a" element of "href=={id}" is clicked. The "div" of "id=={id}" will be opened.*/
    var str_temptab= "";
    str_temptab += '<div id="col-xs-12">';
    str_temptab +=  '<div class="sidebarContentParent">';
    str_temptab +=    '<div class="sidebarContentChild">';
    str_temptab +=      '<span class="contenChildSpan">';

    if ((cnt_LikedAreas+cnt_DislikedAreas)<1){
      if (siteLang =='en') str_temptab += '<h4><span>Which type of area you\'d like to draw first? </span></h4>';
      if (siteLang =='pt') str_temptab += '<h4><span>Qual área você gostaria de criar primeiro? </span></h4>';
    }else{
      if (siteLang =='en') str_temptab += '<h4><span>And now, which area do you want to draw?</span></h4>';
      if (siteLang =='pt') str_temptab += '<h4><span>E agora, qual área você quer criar?</span></h4>';
    }

    str_temptab +=      '</span>';
    str_temptab +=    '</div>';
    str_temptab +=    '<div class="sidebarContentChild">';
    str_temptab +=     '<span class="contenChildSpan">';
    str_temptab +=        '<button class="btn btn-success" onclick="create_areaTab(\'liked\')" '+statusAddLikeButton+'>';
    if (siteLang =='en') str_temptab += '<i class="fa fa-thumbs-up"></i> Liked Area';
    if (siteLang =='pt') str_temptab += '<i class="fa fa-thumbs-up"></i> Que curto';
    str_temptab +=        '</button>';
    str_temptab +=     '</span>';
    str_temptab +=    '<span class="contenChildSpan">';
    str_temptab +=        '<button class="btn btn-danger" onclick="create_areaTab(\'disliked\')" '+statusAddDislikeButton+'>';
    if (siteLang =='en') str_temptab += '<i class="fa fa-thumbs-down"></i> Disliked Area';
    if (siteLang =='pt') str_temptab += '<i class="fa fa-thumbs-down"></i> Que não curto';
    str_temptab +=       '</button>';
    str_temptab +=    '</span>';
    str_temptab +=   '</div>';

    if ( (cnt_LikedAreas>=0) && (cnt_DislikedAreas>=1) ){

      if (siteLang =='en') str_temptab += '<hr /><h4 style="text-align:center;">Or you can:</h4><button id="btn_Finish" class="btn btn-info btn-block"><span>Finish and see result</span></button>';
      if (siteLang =='pt') str_temptab += '<hr /><h4 style="text-align:center;">Ou você pode:</h4><button id="btn_Finish" class="btn btn-info btn-block"><span>Finalizar e ver resultado</span></button>';
    }

    str_temptab +=  '</div>';
    str_temptab += '</div>';

    if(siteLang=='en') var title = 'Add new Area <span class="leaflet-sidebar-close" onclick="ctlSidebar.close()"><i class="fa fa-chevron-circle-left"></i></span>';
    if(siteLang=='pt') var title = 'Adicionar Nova Área <span class="leaflet-sidebar-close" onclick="ctlSidebar.close()"><i class="fa fa-chevron-circle-left"></i></span>';

    temp_tab_content = {
      id:   'temp_tab',
      tab:  '<i id="dynamic-icon-tab" class="fa fa-plus"></i>',
      title: title,
      pane: str_temptab
    };

    return temp_tab_content;
  };//END returnTempTabContent()
  function deleteTabByHref(href, close_sidebar){
    /* DESCRIPTION: Deletes the tab based on the href that was passed
    ### If no href was passed it means that  a 'Remove Area' button inside a 'liked' or 'disliked' tab was clicked.
    ### Therefore this tab will be deleted tab was clicked. Therefore, this tab will be removed*/
    if ( href.split("-")[0] == "#liked"){
      cnt_LikedAreas--;
      statusAddLikeButton = "";
    }else if ( href.split("-")[0] == "#disliked"){
      cnt_DislikedAreas--;
      statusAddDislikeButton = "";
    }
    //If the tab being deleted is a liked or disliked palce, update the "#temp_tab" status of the buttons
    if ( ( href.split("-")[0] == "#liked") || ( href.split("-")[0] == "#disliked") ){
      // Update the temp_tab
      deleteTabByHref('#temp_tab');
      ctlSidebar.addPanel(returnTempTabContent());
      if(siteLang=='en') createTitleLiByHref( "#temp_tab" , "Add a new Area" );
      if(siteLang=='pt') createTitleLiByHref( "#temp_tab" , "Adicionar uma nova área" );
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
    ### temp_tab_content = { title: 'Add new Area<span class="leaflet-sidebar-close"><i class="fa fa-times-circle"></i></span>'}
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
    /* DESCRIPTION: Count the number of checkbox checked for the area_id that's being edited. Only works for editMode==true*/
    if(editMode){
      cntCheckedCbx = 0;
      var att_nat = document.getElementById(area_id+"_cbxAtt-nat").checked;
      var att_open = document.getElementById(area_id+"_cbxAtt-open").checked;
      var att_ord = document.getElementById(area_id+"_cbxAtt-order").checked;
      var att_up = document.getElementById(area_id+"_cbxAtt-upkeep").checked;
      var att_hist = document.getElementById(area_id+"_cbxAtt-hist").checked;

      if(att_nat)   cntCheckedCbx++;
      if(att_open)  cntCheckedCbx++;
      if(att_ord)   cntCheckedCbx++;
      if(att_up)    cntCheckedCbx++;
      if(att_hist)  cntCheckedCbx++;
    }
  };//END countCheckCbx()
  function addSidebarEvents() {
    // # Sidebar events
    ctlSidebar.on('closing',function(){
      previousTab = activeTab; //When the sidebar opens, it was closed before. So there was no active tab
      activeTab = null;
      sidebarOpened = false;

      //Mimics a sidebar click, to remove the blue background color of the icon if a liked or disliked tab was clicked before the closing of the sidebar
      sidebarChange('closing');

      //When closing the sidebar it's in the editMode and createMode==false, force the user to give an attribute to the area
      if(editMode){
        // if(createMode==false){
        //count the number of checkbox checked for the area_id
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
      // console.log(cnt_test,"CLOSE Prev: ",previousTab, "Act: ", activeTab, "CM", createMode, "EM", editMode, "cbxChecked:", cntCheckedCbx );

      if(cnt_LikedAreas+cnt_DislikedAreas<6){
        document.getElementById('dynamic-icon-tab').className = 'fa fa-plus';
      }

    });
    ctlSidebar.on('opening', function() {
      cnt_SidebarOpens++;
      //because the context event fires the opening event (if sidebar is closed), the following variable is to know the status of the sidebar, in order to organize the previous and active tab in the 'content' event.
      sidebarOpened = true;
      //Mimics a sidebar click, to change the background of the icon to blue, if the tab opened is a liked or disliked area
      sidebarChange('opening');
      if (createMode){
        warnFinishCreation();
      }
      // console.log(cnt_test,"OPEN Prev: ",previousTab, "Act: ", activeTab, "CM", createMode, "EM", editMode);

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
        if (activeTab != area_id){ saveArea(); }
      }

      //Mimics a sidebar click, to remove the blue background color of the icon if a liked or disliked tab was clicked before the closing of the sidebar
      sidebarChange('content');

      if(editMode){
        // Set style of layer based on the sidebar status
        toggleLyrStyle(activeTab, setStyle_edit);
        // finish edit area if the Sidebar is opened in another tab diferent from the one being edited
        if (activeTab != area_id) saveArea();
      }else{
        toggleLyrStyle(activeTab, setStyle_clicked);
      }

      // console.log(cnt_test,"CONT Prev: ",previousTab, "Act: ", activeTab, "CM", createMode, "EM", editMode);

    });//END content
  }

  //  # Message Functions
  function warnCheckAtt(){
    /* DESCRIPTION: Warn the user to check at least one attribute in the checkbox */
    if(siteLang=='en') alert("Please, check at least one attribute corresponding to the area drawn");
    if(siteLang=='pt') alert("Por favor, escolha ao menos um atributo correspondente a área desenhada");
    //Open the sidebar
    if (getActiveTabId()!=area_id){ctlSidebar.open(area_id);}
  }
  function warnDeleteArea(){
    /* DESCRIPTION: Warn the user if tries to delete an area */
    return confirm("Are you sure you want to delete this area permanently?")
  }
  function warnFinishCreation(){
    /* DESCRIPTION: Warn the user if tries open the sidebar in a creation mode */
    if(siteLang=='en') var str_popup='<span><h6>Please, finish the draw first</h6></span>';
    if(siteLang=='pt') var str_popup='<span><h6>Por favor, finalize o desenho primeiro</h6></span>';
    openAlertPopup(mymap.getCenter(), str_popup);
    showInfoBox();
    ctlSidebar.close();
  }

  //  # Document Functions
  function KeyPress(e) {
    /* DESCRIPTION: call functions based on the combination of keys the users is pressing */
    var evtobj = window.event? event : e
    //Ctrl+z
    if (evtobj.keyCode == 90 && evtobj.ctrlKey) {
      // if the user press Ctrl+z and a new layer is being created, remove the last vertex of the layer
      if(createMode){
        cnt_CtrlZPressed++;
        removeLastVertex();
      }
    }
    if (evtobj.keyCode == 13) {
      // if the user press Enter and a layer is being edited, the area is saved
      if(editMode){
        cnt_enterKeyPressed++;
        saveArea();
      }
      // if the user press Enter and a new layer is being created, the area is finished
      if(createMode){
        cnt_enterKeyPressed++;
        finishCreation();
      }
    }
    if (evtobj.keyCode == 27) {
      // if the user press Esc and a new layer is being created, the area is canceled
      if(createMode) {
        cnt_escapeKeyPressed++;
        if(siteLang=='en') var str_popup='<span><h7>The drawing was successfully canceled</h7></span>';
        if(siteLang=='pt') var str_popup='<span><h7>O desenho foi cancelado com sucesso</h7></span>';
        removeArea(area_id, true, 2000);
        openAlertPopup(mymap.getCenter(), str_popup);
      }
    }
  }
  function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    var expires = "expires="+ d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
  }
  function getCookie(cname) {
    var name = cname + "=";
    var decodedCookie = decodeURIComponent(document.cookie);
    var ca = decodedCookie.split(';');
    for(var i = 0; i <ca.length; i++) {
      var c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
      }
    }
    return "";
  }

  //  # jQuery Functions
  $( "#btn_Finish" ).click(function(){
    if ( mymap.hasLayer(fgpDrawnItems) && (fgpDrawnItems.getLayers().length > 0) ){
      // NEED TO: come back to previous situation
      // if ( (cnt_LikedAreas >= 1) && (cnt_DislikedAreas >= 1) ){
      if ( (cnt_LikedAreas >= 4) && (cnt_DislikedAreas >= 4) ){
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

          //Converts Polygon to MultiPolygon, rounding the number of decimal areas of coordinates to 6.
          var array_coordinate_rounded  = [];
          for (i=0; i<(layer.toGeoJSON().geometry.coordinates[0]).length; i++){
            var Longitude = Math.round(layer.toGeoJSON().geometry.coordinates[0][i][0] * 1000000) / 1000000; //rounded to 6 decimal areas
            var Latitude = Math.round(layer.toGeoJSON().geometry.coordinates[0][i][1] * 1000000) / 1000000; //rounded to 6 decimal areas
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
      }else if ((cnt_LikedAreas + cnt_DislikedAreas) >= 3) {
        alert("PARABÉNS!! Muito Obrigado por me ajudar a testar o site! Você é maravilhos@!!! :) Mas mexa mais um pouco nele. Tente encontrar algum 'bug' ou qualquer DEFEITO ou qualquer coisa que vc não gostou. Anote para depois me dizer! :)");
      }else if ((cnt_LikedAreas >= 1) && (cnt_DislikedAreas == 0)){
        if(siteLang=='en') alert("A DISLIKED area is missing.\nPlease, draw it to proceed!");
        if(siteLang=='pt') alert("Por favor, desenhe uma área que você NÃO CURTE, antes de finalizar! :)");
      }else if ((cnt_LikedAreas == 0) && (cnt_DislikedAreas >= 1)){
        if(siteLang=='en') alert("A LIKED area is missing.\nPlease, draw it to proceed!");
        if(siteLang=='pt') alert("Por favor, desenhe uma área que você CURTE, antes de finalizar! :)");
      }
    }else{
      if(siteLang=='en') alert("To finize you shoud draw, at least, 1 area you LIKED and 1 area you DISLIKE.\nPlease, draw it to proceed!");
      if(siteLang=='pt') alert("Para finalizar você precisa criar, no mínimo 1 área que você CURTE e uma área que você NÃO CURTE.\n :)");
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

  //  # close modals from eimg_draw-modals.php
  $("#btn_close_modal_demographics").on("click", function () {
    //checking values from demographics modal
    var e = document.getElementById("user_sex-"+siteLang);
    var user_sex = e.options[e.selectedIndex].value;
    var e = document.getElementById("user_age-"+siteLang);
    var user_age = e.options[e.selectedIndex].value;
    var e = document.getElementById("user_job-"+siteLang);
    var user_job = e.options[e.selectedIndex].value;
    var e = document.getElementById("user_income-"+siteLang);
    var user_income = e.options[e.selectedIndex].value;

    var field_blank = [];
    if(user_sex==""){
      if (siteLang=="en") field_blank.push("Gender");
      if (siteLang=="pt") field_blank.push("Sexo");
    }
    if(user_age==""){
      if (siteLang=="en") field_blank.push("Age");
      if (siteLang=="pt") field_blank.push("Idade");
    }
    if(user_job==""){
      if (siteLang=="en") field_blank.push("Profession");
      if (siteLang=="pt") field_blank.push("Profissão");
    }
    if(user_income==""){
      if (siteLang=="en") field_blank.push("Income");
      if (siteLang=="pt") field_blank.push("Renda");
    }

    //if(field_blank==[]){
    if(field_blank!=[]){
      $('#modal_2_demographics').modal('hide');
      $('#modal_3_sus').modal('show');
    }else{
      if (siteLang=="en") var str = "Please, answer the following fields:\n"
      if (siteLang=="pt") var str = "Por favor, responda os seguintes campos:\n"
      alert(str+field_blank.toString())
    }

  });
  $("#btn_close_modal_sus").on("click", function () {
    //checking values from sus modal
    var i;
    for (i = 1; i <= 12; i++) {
      var checkedValue = $('input[type=radio][name=quest'+i.toString()+']:checked').val();
      if(typeof checkedValue == "undefined"){
        if (siteLang == "en") var str = "Plase, answer all the questions before you see the result";
        if (siteLang == "pt") var str = "Por favor, responda todas as perguntas antes de prosseguir";
        alert(str);
        break
      }
    }

    $('#modal_3_sus').modal('hide');
    //window.location.href = 'eimg_viewer.php';
  });

  </script>
  </body>
  </html>
