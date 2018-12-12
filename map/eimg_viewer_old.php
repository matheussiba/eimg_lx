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
<?php include "../includes/css/style_eimg_viewer.php" ?>
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
              <!-- <input type="radio" id="radio_2classes" class='range_numberOfClasses' name='chooseNumberOfClasses' value=2>
              <label for="radio_2classes">2</label><br />
              <input type="radio" id="radio_3classes" class='range_numberOfClasses' name='chooseNumberOfClasses' value=3>
              <label for="radio_3classes">3</label>
              <input type="radio" id="radio_4classes" class='range_numberOfClasses' name='chooseNumberOfClasses' value=4>
              <label for="radio_4classes">4</label>
              <input type="radio" id="radio_5classes" class='range_numberOfClasses' name='chooseNumberOfClasses' value=5>
              <label for="radio_5classes">5</label> -->
          </div>


          <div class="ct-topbar" style="padding: 1vh;">
            <ul class="list-unstyled list-inline ct-topbar__list">
              <li class="ct-language">Choose a Language <i class="fa fa-arrow-down"></i>
                <ul class="list-unstyled ct-language__dropdown">
                  <li><a href="#lang-pt" class="lang-pt lang-select" data-lang="pt"><img src="<?php  echo $root_directory?>resources/images/flags/flag-pt-24x16px.png" alt="PORTUGAL"></a></li>
                  <li><a href="#lang-en" class="lang-us lang-select" data-lang="en"><img src="<?php  echo $root_directory?>resources/images/flags/flag-usa-24x16px.png" alt="USA"></a></li>
                  <li><a href="#lang-es" class="lang-es lang-select" data-lang="es"><img src="<?php  echo $root_directory?>resources/images/flags/flag-spain-24x16px.png" alt="SPAIN"></a></li>
                  <li><a href="#lang-fr" class="lang-fr lang-select" data-lang="fr"><img src="<?php  echo $root_directory?>resources/images/flags/flag-france-24x16px.png" alt="FRANCE"></a></li>
                  <li><a href="#lang-de" class="lang-de lang-select" data-lang="de"><img src="<?php  echo $root_directory?>resources/images/flags/flag-germany-24x16px.png" alt="GERMANY"></a></li>
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
    var mobileDevice;
    var ctlSidebar;
    var lyrEIMG;
    var lyrHistCenter;
    var eimg_stats;
    var number_classes;
    var feat_loaded;
    var quantile_class;
    var array_cnt_feat_class;

    var symbology_type = "quantile";
    //  ********* Mobile Device parameters and Function *********
    if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)){
      /*### DESCRIPTION: Check if the web application is being seen in a mobile device   */
      mobileDevice = true;
    }else{
      mobileDevice = false;
    }
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

      // get values for symbology
      symbology_type = $("input[name='chooseTypeSymbology']:checked").val();
      // console.log(symbology_type);
      number_classes = document.getElementById("range_nrClasses").value;
      // console.log(number_classes);

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
          mymap.fitBounds(lyrEIMG.getBounds());
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
