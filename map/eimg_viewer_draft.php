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

  <!-- ###############  Div that contains the header ############### -->
  <div id="header" class="col-md-12">
    <span class="text-center"><?php echo $header ?> </span>
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

        <!-- Checkboxes to Select Liked and Disliked Places -->
        <div id="divFilterEvaluation" class="col-xs-12">
          <h3 class="text-center">Filter Areas</h3>
          <div class="col-xs-6">
            <input type="checkbox" id="cbx_eval_l" class='cbx_fltPlaces' name='fltPlaces' value='1' checked>
            <label for="cbx_eval_l">Liked</label>
          </div>
          <div class="col-xs-6">
            <input type="checkbox" id="cbx_eval_d" class='cbx_fltPlaces' name='fltPlaces' value='2' checked>
            <label for="cbx_eval_d">Disliked</label>
          </div>
          <div class="col-xs-6">
            <input type="checkbox" id="cbx_eval_ld" class='cbx_fltPlaces' name='fltPlaces' value='3' checked>
            <label for="cbx_eval_ld">Liked/Disliked</label>
          </div>
        </div>


        <div id="divFilterAttributes" class="col-xs-12">
          <h3 class="text-center">Filter Attributes</h3>
          <div class="col-xs-4">
            <!-- Metadata for values of the Attributes -->

            <input type="checkbox" id="cbx_att_nat" class='cbx_fltAttributes' name='fltAttributes' value="ct_nat">
            <label for="cbx_att_nat">Naturalness</label><br />
            <input type="checkbox" id="cbx_att_open" class='cbx_fltAttributes' name='fltAttributes' value="ct_ope">
            <label for="cbx_att_open">Openness</label>
          </div>
          <div class="col-xs-4">
            <input type="checkbox" id="cbx_att_order" class='cbx_fltAttributes' name='fltAttributes' value="ct_ord">
            <label for="cbx_att_order">Order</label><br />
            <input type="checkbox" id="cbx_att_upkeep" class='cbx_fltAttributes' name='fltAttributes' value="ct_upk">
            <label for="cbx_att_upkeep">Upkeep</label>
          </div>
          <div class="col-xs-4">
            <input type="checkbox" id="cbx_att_hist" class='cbx_fltAttributes' name='fltAttributes' value="ct_his">
            <label for="cbx_att_hist">Historical Significance</label><br />
            <button id='btnCheckAtt' class='btn btn-primary btn-block'>
              <i id ="iconCheckAtt" class="fa fa-check-square"></i>
            </button>
          </div>
        </div>

      </div> <!-- close DIV id="home"> -->

      <!-- sidebar_tab: settings -->
      <div class="leaflet-sidebar-pane" id="settings">
        <h1 class="leaflet-sidebar-header"> <!-- Header of the tab -->
          Information<span class="leaflet-sidebar-close"><i class="fa fa-chevron-circle-left"></i></span>
        </h1>
        <div>
          <div style="text-align:center;padding: 0; margin: 0; margin-top:5px;">
            <img src="<?php  echo $root_directory?>resources/images/eimg_logo_1.png" id="logo_munster" style="margin-left: auto; margin-right: auto; width: auto;max-height: 70px;">
          </div>
          <!-- settings Starts -->

          <div id="divSymbology" class="col-xs-12">
            <h5 class="text-center">Simbology</h5>
            <p> Choose the way you want your data to be displayed:</p>
            <input type="radio" id="radio_eqInterval" class='radio_typeSymbology' name='chooseTypeSymbology' value="eq_interval" checked>
            <label for="radio_eqInterval">Equal Interval</label><br />
            <input type="radio" id="radio_quantile" class='radio_typeSymbology' name='chooseTypeSymbology' value="quantile">
            <label for="radio_quantile">Quantile</label>
            <p> Choose the number of classes you want to divide your data:</p>
            <input type="range" id="range_nrClasses" class='range_numberOfClasses' min="2" max="5" value="3">
            <hr />
          </div>

        </div>
      </div> <!-- close DIV id="settings"> -->
    </div> <!-- close DIV class="sidebar-content"> -->
  </div><!-- close DIV id="sidebar"> -->

  <!-- ###############  Div that contains the map application ############### -->
  <div id="mapdiv" class="col-md-12"></div>

  <script>
  //  ********* Global Variables Viewer *********
  var lyrEIMG;
  var eimg_stats;
  var number_classes;
  var feat_loaded;
  var quantile_class;
  var array_cnt_feat_class;
  var symbology_type = "quantile";

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
    minimumZoom = IsMobileDevice ? 9 : 10;
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

    // Add Events
    addSidebarEvents();
    addMapEvents();

    //************************  DATA FOR VIEWER ******
    refreshPlaces();
    ctlSidebar.open('home');
    setTimeout(refreshPlaces, 10000);

  }); //END $(document).ready()
  //  ********* eimg_VIEWER Functions *********
  function refreshPlaces(){
    var cntChecks = 0;
    var whereClause = "";

    // get values for symbology
    symbology_type = $("input[name='chooseTypeSymbology']:checked").val();
    // console.log(symbology_type);
    number_classes = document.getElementById("range_nrClasses").value;
    // console.log(number_classes);

    // Checkboxes Liked and Disliked places
    $('input[type=checkbox].cbx_fltPlaces:checked').each(function () {
      if(cntChecks==0){
        //First Run
        whereClause += 'category_nr IN (';
        whereClause += ($(this).attr("value")).toString();
        whereClause += ')';
      }else{
        //Other Runs
        whereClause = whereClause.slice(0, -1); //slice the last char of the string: "category_nr IN (1"
        whereClause += ','+($(this).attr("value")).toString();
        whereClause += ')';
      };
      cntChecks += -1; //Just to add a AND in the SQL query below
    });

    //in the code above ".each(function () {" the possible values of cntChecks is 0 until -3
    //It's because there're 3 categories. Liked, disliked and liked/disliked areas.
    //If only on checkbox is checked, cntChecks == -1; If none is checked, cntChecks == 0
    //If all checkboxes are checked; cntChecks == -3;
    if(cntChecks!=0){
      // it means at least one is checked
      // Checkboxes of attributes
      $('input[type=checkbox].cbx_fltAttributes:checked').each(function () {
        if(cntChecks < 0){
          //it means that there's some '.cbx_fltPlaces' checked
          whereClause += ' AND ';
          cntChecks=0;
        };
        if(cntChecks==0){
          //First runs
          whereClause += '(';
          whereClause += $(this).attr("value")+' > 0';
          whereClause += ')';
        }else{
          //Other runs
          whereClause = whereClause.slice(0, -1); //slice the last char of the string
          whereClause += ' AND '+ $(this).attr("value")+' > 0)';
        };
        cntChecks++;
      });
    }else{
      //it means that there's no '.cbx_fltPlaces' checked.
      //It will not matter the attribute select. No features must be seen
      whereClause = "(1=2)"; //This is a false claure, returning no elements
    };
    // console.log(whereClause);

    // Calculating Stats for styling the opacity of each polygon based on the count of liked and disliked place
    //stats for the data
    $.ajax({
      url:'eimg_get_dbtable.php',
      data: {
        type_op: "info",
        tbl: "eimg_result",
        select:"max(ct_liked+ct_disliked), min(ct_liked+ct_disliked), count(*)"
      },
      type:'POST',
      success:function(response){
        console.log(response);
        eimg_stats = JSON.parse(response);
      },
      error: function(xhr, status, error){ alert("ERROR: "+error); }
    }); // End ajax

    $.ajax({
      url:'eimg_get_dbtable.php',
      data: {
        type_op: "data",
        tbl: "eimg_result",
        select: "*,((ct_liked::float/(ct_liked::float+ct_disliked::float))*100)::numeric(5,2) liked_percent",
        where: whereClause,
        order: "liked_percent"
      },
      type:'POST',
      success:function(response){
        console.log(response);
        if (lyrEIMG) {
          mymap.removeLayer(lyrEIMG);
        };

        //reseting global variables in each call of refreshPlaces()
        feat_loaded = 0;
        quantile_class = 1;
        array_cnt_feat_class=[0,0,0,0,0];
        lyrEIMG=L.geoJSON(JSON.parse(response),{
          style:stylePlaces,
          onEachFeature:aggAttributes
        });
        console.log("count features per class: ",array_cnt_feat_class);
        lyrEIMG.addTo(mymap);
        console.log("number of features loaded in lyrEIMG:", lyrEIMG.getLayers().length);
        console.log("Areas updated successfully...");
      },//end success
      error: function(xhr, status, error){
        alert("ERROR: "+error);
      }
    }); // End ajax
  }//End refreshPlaces
  function aggAttributes(json, lyr) {
    var att = json.properties;
    strToolTip = "<i class='fa fa-thumbs-up' ></i> "+att.ct_liked;
    strToolTip += "   ";
    strToolTip += "<i class='fa fa-thumbs-down'></i> "+att.ct_disliked;
    switch (att.category_nr) {
      case 1: //In the field "category_nr" means liked places
      lyr.bindTooltip(strToolTip, {direction: "center",className: "tooltipstyle-green"});
      break;
      case 2: //In the field "category_nr" means disliked places
      lyr.bindTooltip(strToolTip, {direction: "center",className: "tooltipstyle-red"});
      break;
      case 3: //In the field "category_nr" means liked/disliked places
      lyr.bindTooltip(strToolTip, {direction: "center",className: "tooltipstyle-blue"});
      break;
      default: //If something went wrong...
      lyr.bindTooltip(strToolTip);
    }

    var att = json.properties;
    strPopup  = "<h5>Category: "+att.category+":</h5>";
    strPopup += "Count of Likes:\t"+att.ct_liked+"<br />";
    strPopup += "Count of Dislikes:\t"+att.ct_disliked+"<br />";
    strPopup += "<hr />";
    strPopup += "<b>Attributes:</b><br />";
    strPopup += "Ct Naturalness:\t"+att.ct_nat+"<br />";
    strPopup += "Ct Openness:\t"+att.ct_ope+"<br />";
    strPopup += "Ct Order:\t\t"+att.ct_ord+"<br />";
    strPopup += "Ct Upkeep:\t\t"+att.ct_upk+"<br />";
    strPopup += "Ct Hist. Sign.\t:"+att.ct_his+"<br />";
    lyr.bindPopup(strPopup);

    //bind events
    lyr.on('mouseover', function(e){
      lyr.setStyle({ weight: 2});
    });
    lyr.on('mouseout', function(e){
      lyr.setStyle({ weight: 0});
    });

  }
  function stylePlaces(json) {
    feat_loaded++;

    //Setting the max of opacity for each layer
    var max_opacity = 0.95;
    var min_opacity = 0.15;
    var array_colors =
    [
      ['red', 'green'],
      ['red', 'gold', 'green'],
      ['red', 'darkorange', 'yellowgreen', 'green'],
      ['red', 'darkorange', 'gold', 'yellowgreen', 'green']
    ];
    var att = json.properties;
    var opacity_calc = min_opacity+((((parseInt(att.ct_liked)+parseInt(att.ct_disliked))-parseInt(eimg_stats.min))*(max_opacity-min_opacity))/(parseInt(eimg_stats.max)-parseInt(eimg_stats.min)));

    //the values were ordered in the AJAX call
    if (feat_loaded > eimg_stats.count/number_classes*quantile_class){quantile_class++;}
    if (symbology_type == "quantile"){
      array_cnt_feat_class[quantile_class-1] = (array_cnt_feat_class[quantile_class-1])+1;
      return {color: array_colors[number_classes-2][quantile_class-1], weight:0, fillColor: array_colors[number_classes-2][quantile_class-1], fillOpacity: opacity_calc };
    }
    if (symbology_type == "eq_interval"){
      var eq_interval_class=1;
      while (eq_interval_class<=number_classes){
        if( att.liked_percent <= 100/number_classes*eq_interval_class){
          array_cnt_feat_class[eq_interval_class-1] = (array_cnt_feat_class[eq_interval_class-1])+1;
          return {color: array_colors[number_classes-2][eq_interval_class-1], weight:0, fillColor: array_colors[number_classes-2][eq_interval_class-1], fillOpacity: opacity_calc };
        }
        eq_interval_class++;
      }
    }
  }//End stylePlaces(json)
  //  ********* eimg_DRAW Functions *********
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
        var value = 0.12;
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
      createTitleLiByHref( "#settings" , "Click to see information" );
    }
    if(siteLang=='pt') {
      createTitleLiByHref( "#home" , "Clique para ir ao início" );
      createTitleLiByHref( "#settings" , "Clique para ir para ver as informações" );
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
    });
    mymap.on('contextmenu', function(e){
      /* DESCRIPTION: listener when a click is given on the map  */
      //CAN OPEN THE settings TOOLBAR
    });
    mymap.on('mousemove', function(e){
      /*### FUNCTION DESCRIPTION: listener when the mouse is moving on the map   */
      var str = "Latitude: "+e.latlng.lat.toFixed(5)+"  Longitude: "+e.latlng.lng.toFixed(5)+"  Zoom Level: "+mymap.getZoom();
      $("#map_coords").html(str);
    });
    mymap.on('click', function(e){
      /* DESCRIPTION: listener when a click is given on the map  */
      pntClicked = e.latlng; // FORMAT: {lat: 38.72452, lng: -9.11160}
    });
  }
  function showInfoBox(){
    /* DESCRIPTION: Shows a Information Box to the user in order to know how to use the CreationToolbar*/
    $('.infobox_for_toolbar').css('visibility','visible');
    //hide after 4 seconds
    setTimeout(function() {
      $('.infobox_for_toolbar').css('visibility','hidden');
    }, 15000);
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

  //  # Sidebar Functions
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
  function addSidebarEvents() {
    // # Sidebar events
    ctlSidebar.on('closing',function(){
      previousTab = activeTab; //When the sidebar opens, it was closed before. So there was no active tab
      activeTab = null;
      sidebarOpened = false;

      //Mimics a sidebar click, to remove the blue background color of the icon if a liked or disliked tab was clicked before the closing of the sidebar
      sidebarChange('closing');
    });
    ctlSidebar.on('opening', function() {
      cnt_SidebarOpens++;
      //because the context event fires the opening event (if sidebar is closed), the following variable is to know the status of the sidebar, in order to organize the previous and active tab in the 'content' event.
      sidebarOpened = true;
      //Mimics a sidebar click, to change the background of the icon to blue, if the tab opened is a liked or disliked area
      sidebarChange('opening');
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

      //Mimics a sidebar click, to remove the blue background color of the icon if a liked or disliked tab was clicked before the closing of the sidebar
      sidebarChange('content');
    });//END content
  }
  function sidebarChange(e){
    /* DESCRIPTION: Global events for the sidebar. 'e' can be either "closing", "opening" or "content"*/
    // just a temporary count for testing to see how many times the sidebar was changed
    cnt_test++;
    // get the active Tab the sidebar founds itself. if 'e'=="closing", clickedTab == null
    var clickedTab = getActiveTabId(true);
  }//END function sidebarChange()

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
  //  # Cookie Functions
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

  //  ********* jQuery Functions *********
  $("#btnCheckAtt").on("click", function () {
    if( $('#iconCheckAtt').hasClass('fa-check-square') ){ //The user wants to check All attributes
      $('input[type=checkbox].cbx_fltAttributes').each(function () {
        $(this).prop('checked', true);
      });
      //Change the glyphicon icon to uncheked
      $( "#iconCheckAtt" ).toggleClass( "fa-square" );
      $( "#iconCheckAtt" ).removeClass('fa-check-square');
      //$("#iconCheckAtt").addClass('glyphicon-check').removeClass('glyphicon-unchecked');
    }else{ // The user wants to uncheck all
      $('input[type=checkbox].cbx_fltAttributes').each(function () {
        $(this).prop('checked', false);
      });
      //Change the glyphicon icon to check
      $( "#iconCheckAtt" ).toggleClass( "fa-check-square" );
      $( "#iconCheckAtt" ).removeClass('fa-square');
    };
    refreshPlaces();
  });
  $("#btnProcess").on("click", function () {
    //var text = $(this).attr("text");
    // console.log("Clicked");

    $.ajax({
      url:'eimg_viewer-flatten_polys.php',
      //data:{ },
      type:'POST',
      success:function(response){
        console.log("flatten polygons worked fine");
        console.log(response);
        refreshPlaces();
        console.log("areas refreshed...");
      },//End success
      error:function(xhr, status, error){
        // $("#divLog").text("Something went wront... "+error);
        console.log("Something went wront... "+error);
      }//End error
    });//End AJAX call

  });

  $( "#divFilterEvaluation" ).on( "change", ".cbx_fltPlaces", function() {
    refreshPlaces();
  });
  $( "#divFilterAttributes" ).on( "change", ".cbx_fltAttributes", function() {
    refreshPlaces();
  });

  $( "#divSymbology" ).on( "change", ".radio_typeSymbology", function() {
    refreshPlaces();
  });
  $( "#divSymbology" ).on( "change", ".range_numberOfClasses", function() {
    refreshPlaces();
  });


</script>
</body>
</html>
