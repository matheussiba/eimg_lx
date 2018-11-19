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
<?php include "includes/header_viewer.php" ?>

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

        <!-- Side Panel Title-->
        <h3 class="text-center">Controler</h3>
        <button id='btnProcess' class='btn btn-primary btn-block'>Flatten Features</button>

        <!-- Div to display a message to the user, if needed -->
        <div id="divLog"></div>

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
            <input type="checkbox" id="cbx_eval_d" class='cbx_fltPlaces' name='fltPlaces' value='3' checked>
            <label for="cbx_eval_d">Liked/Disliked</label>
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
    var ctlEasybutton;
    var mobileDevice = false;
    var ctlSidebar;
    var lyrEIMG;
    var lyrHistCenter;
    var stats_cat_1;
    var stats_cat_2;
    var stats_cat_3;
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
        autopan: false,
        closeButton: false,
      }).addTo(mymap);

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

      //************************  Load Data  ******

      refreshPlaces();

      //  ********* Events on Map *********
      mymap.on('mousemove', function(e){
        /*### FUNCTION DESCRIPTION: listener when the mouse is moving on the map   */
        var str = "Latitude: "+e.latlng.lat.toFixed(5)+"  Longitude: "+e.latlng.lng.toFixed(5)+"  Zoom Level: "+mymap.getZoom();
        $("#map_coords").html(str);
      });

      ctlSidebar.open('home');

      setTimeout(refreshPlaces, 10000);

    }); //END $(document).ready()


    //  ********* JS Functions *********
    function refreshPlaces(){
      var cntChecks = 0;
      var whereClause = "";

      // Checkboxes Liked and Disliked places
      $('input[type=checkbox].cbx_fltPlaces:checked').each(function () {
        if(cntChecks==0){ //First Run
          whereClause += 'category_nr IN (';
          whereClause += ($(this).attr("value")).toString();
          whereClause += ')';
        }else{ //Other Runs
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
      if(cntChecks!=0){ // it means at least one is checked
        // Checkboxes of attributes
        $('input[type=checkbox].cbx_fltAttributes:checked').each(function () {
          if(cntChecks < 0){ //it means that there's some '.cbx_fltPlaces' checked
            whereClause += ' AND ';
            cntChecks=0;
          };
          if(cntChecks==0){ //First runs
            whereClause += '(';
            whereClause += $(this).attr("value")+' > 0';
            whereClause += ')';
          }else{ //Other runs
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
      console.log(whereClause);

      // Calculating Stats for styling the opacity of each polygon based on the count of liked and disliked place
      //stats category 1
      $.ajax({
        url:'eimg_viewer-calculate_stats.php',
        data: {
          select:"max(ct_liked+ct_disliked), min(ct_liked+ct_disliked), count(*)",
          where: "category_nr = 1"
        },
        type:'POST',
        success:function(response){
          if (response.substring(0,5)=="ERROR"){
            alert(response);
          }else{
            stats_cat_1 = JSON.parse(response);
          }//end else
        },//end success
        error: function(xhr, status, error){
          alert("ERROR: "+error);
        }
      }); // End ajax
      //stats category 2
      $.ajax({
        url:'eimg_viewer-calculate_stats.php',
        data: {
          select:"max(ct_liked+ct_disliked), min(ct_liked+ct_disliked), count(*)",
          where: "category_nr = 2"
        },
        type:'POST',
        success:function(response){
          if (response.substring(0,5)=="ERROR"){
            alert(response);
          }else{
            stats_cat_2 = JSON.parse(response);
          }//end else
        },//end success
        error: function(xhr, status, error){
          alert("ERROR: "+error);
        }
      }); // End ajax
      //stats category 3
      $.ajax({
        url:'eimg_viewer-calculate_stats.php',
        data: {
          select:"max(ct_liked+ct_disliked), min(ct_liked+ct_disliked), count(*)",
          where: "category_nr = 3"
        },
        type:'POST',
        success:function(response){
          if (response.substring(0,5)=="ERROR"){
            alert(response);
          }else{
            stats_cat_3 = JSON.parse(response);
          }//end else
        },//end success
        error: function(xhr, status, error){
          alert("ERROR: "+error);
        }
      }); // End ajax

      $.ajax({
        url:'eimg_viewer-refresh_polys.php',
        data: {flds:"*", where: whereClause},
        type:'POST',
        success:function(response){
          if (response.substring(0,5)=="ERROR"){
            alert(response);
          }else{
            //console.log(response);
            if (lyrEIMG) {
              mymap.removeLayer(lyrEIMG);
            };
            lyrEIMG=L.geoJSON(JSON.parse(response),{
              style:stylePlaces,
              onEachFeature:aggAttributes
            });
            lyrEIMG.addTo(mymap);
            mymap.fitBounds(lyrEIMG.getBounds());
            console.log("Areas updated successfully...");
          }//end else
        },//end success
        error: function(xhr, status, error){
          alert("ERROR: "+error);
        }
      }); // End ajax
    }//End refreshPlaces

    function aggAttributes(json, lyr) {
      var att = json.properties;
      strToolTip = "<i class='fa fa-thumbs-up' ></i> "+att.ct_liked;
      strToolTip += " | ";
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
        switch (att.category_nr) {
          case 1: //In the field "category_nr" means liked places
          lyr.setStyle({ weight: 2});
          break;
          case 2: //In the field "category_nr" means disliked places
          lyr.setStyle({ weight: 2});
          break;
          case 3: //In the field "category_nr" means liked/disliked places
          lyr.setStyle({ weight: 2});
          break;
        }
      });
      lyr.on('mouseout', function(e){
        switch (att.category_nr) {
          case 1: //In the field "category_nr" means liked places
          lyr.setStyle({weight: 0});
          break;
          case 2: //In the field "category_nr" means disliked places
          lyr.setStyle({weight: 0});
          break;
          case 3: //In the field "category_nr" means liked/disliked places
          lyr.setStyle({weight: 0});
          break;
        }
      });

      //WORKING Turf function -- Keep it ere as a test
      // var jsnBuffer = turf.buffer(lyr.toGeoJSON(), 0.1, 'kilometers');
      // jsnLayer = L.geoJSON(jsnBuffer, {style:{color:'yellow', dashArray:'5,5', fillOpacity:0}}).addTo(mymap);
    }

    function stylePlaces(json) {
      var max_opacity = 0.8;
      var min_opacity = 0.15;

      var att = json.properties;
      console.log(min_opacity+((((parseInt(att.ct_liked)+parseInt(att.ct_disliked))-parseInt(stats_cat_1.min))*(max_opacity-min_opacity))/(parseInt(stats_cat_1.max)-parseInt(stats_cat_1.min)))  );

      switch (att.category_nr) {
        case 1: //In the field "category_nr" means liked places
        return {color: 'green', weight:0, fillColor: 'green',
                //Normalization of the opacity based on the ct_liked + ct_disliked
                fillOpacity: min_opacity+((((parseInt(att.ct_liked)+parseInt(att.ct_disliked))-parseInt(stats_cat_1.min))*(max_opacity-min_opacity))/(parseInt(stats_cat_1.max)-parseInt(stats_cat_1.min))) };
        break;
        case 2: //In the field "category_nr" means disliked places
        return {color: 'red', weight:0, fillColor: 'red',
                fillOpacity: min_opacity+((((parseInt(att.ct_liked)+parseInt(att.ct_disliked))-parseInt(stats_cat_2.min))*(max_opacity-min_opacity))/(parseInt(stats_cat_2.max)-parseInt(stats_cat_2.min))) };
        break;
        case 3: //In the field "category_nr" means liked/disliked places
        return {color: 'blue', weight:0, fillColor: 'blue',
                fillOpacity: min_opacity+((((parseInt(att.ct_liked)+parseInt(att.ct_disliked))-parseInt(stats_cat_3.min))*(max_opacity-min_opacity))/(parseInt(stats_cat_3.max)-parseInt(stats_cat_3.min))) };
        break;
        default: //If something went wrong it'll display grey
        return {color:'grey'}
      }
    }

    //  ********* Sidebar Functions *********
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

    function createTitleLiByHref(href, newtitle){
      /* ### FUNCTION DESCRIPTION: Updates the title of the tab "li" element when it's hovered
         ### When a new tab is added using the API, the title receives a HTML, f.e:
         ### tab_content = { title: 'Add new Place<span class="leaflet-sidebar-close"><i class="fa fa-times-circle"></i></span>'}
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
      console.log("Clicked");

      $.ajax({
          url:'eimg_viewer-flatten_polys.php',
          //data:{ },
          type:'POST',
          success:function(response){
            console.log("flatten polygons worked fine");
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

    $(".sidebarTab_ul").click(function() {
      console.log("--Active Tab: \t",getActiveTab());
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
