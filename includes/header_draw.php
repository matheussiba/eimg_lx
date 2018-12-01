<head>
  <meta charset="UTF-8">
  <!-- Responsive meta tag, help with mobile devices -->
  <!-- <meta name="viewport" content="width=device-width, initial-scale=1"> -->
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

  <title>eimg Lisbon - Demo Version</title>

  <!-- Adding CSS files -->
  <!-- <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"> -->
  <link rel="stylesheet" href="<?php  echo $root_directory?>resources/bootstrap-3.3.7.min.css"/>
  <!-- <link rel="stylesheet" href="https://unpkg.com/leaflet@1.2.0/dist/leaflet.css"
  integrity="sha512-M2wvCLH6DSRazYeZRIm1JnYyh22purTM+FDB5CsyxtQJYeKq83arPe5wgbNmcFXGqiSH2XR8dT/fJISVA1r/zQ=="
  crossorigin=""/> -->
  <!-- <link rel="stylesheet" href="<?php  echo $root_directory?>resources/leaflet-1.2.0.css"
  integrity="sha512-M2wvCLH6DSRazYeZRIm1JnYyh22purTM+FDB5CsyxtQJYeKq83arPe5wgbNmcFXGqiSH2XR8dT/fJISVA1r/zQ=="
  crossorigin=""/> -->
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.3.4/dist/leaflet.css"
  integrity="sha512-puBpdR0798OZvTTbP4A8Ix/l+A4dHDD0DGqYW6RQ+9jxkRFclaxxQb/SJAWZfWAkuyeQUytO7+7N4QKrDh+drA=="
  crossorigin=""/>
  <link rel="stylesheet" href="<?php  echo $root_directory?>resources/plugins/leaflet.pm.css"/>
  <!-- <link rel="stylesheet" href="https://unpkg.com/leaflet.pm@latest/dist/leaflet.pm.css" /> -->
  <link rel="stylesheet" href="<?php  echo $root_directory?>resources/plugins/L.Control.MousePosition.css">
  <link rel="stylesheet" href="<?php  echo $root_directory?>resources/plugins/leaflet-sidebar.min-v3.0.2.css">
  <link rel="stylesheet" href="<?php  echo $root_directory?>resources/plugins/leaflet-overview-nootherdev-fork.css">
  <link rel="stylesheet" href="<?php  echo $root_directory?>resources/css/font-awesome.min.css">
  <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.5.0/css/all.css">
  <!-- <link href="http://maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet"> -->
  <link rel="stylesheet" href="<?php  echo $root_directory?>resources/plugins/leaflet.awesome-markers.css">
  <link rel="stylesheet" href="<?php  echo $root_directory?>resources/plugins/easy-button.css">


  <!-- Adding JS files -->
  <!-- <script src="https://unpkg.com/leaflet@1.2.0/dist/leaflet.js"
  integrity="sha512-lInM/apFSqyy1o6s89K4iQUKg6ppXEgsVxT35HbzUupEVRh2Eu9Wdl4tHj7dZO0s1uvplcYGmt3498TtHq+log=="
  crossorigin="">
</script> -->
<!-- <script src="<?php  echo $root_directory?>resources/leaflet-1.2.0.js"
integrity="sha512-lInM/apFSqyy1o6s89K4iQUKg6ppXEgsVxT35HbzUupEVRh2Eu9Wdl4tHj7dZO0s1uvplcYGmt3498TtHq+log=="
crossorigin="">
</script> -->
<script src="https://unpkg.com/leaflet@1.3.4/dist/leaflet.js"
integrity="sha512-nMMmRyTVoLYqjP9hrbed9S+FzjZHW5gY1TWCHA5ckwXZBadntCNs8kEqAWdrb9O7rxbCaA4lKTIWjDXZxflOcA=="
crossorigin=""></script>
<!-- <script src="https://code.jquery.com/jquery-2.2.4.min.js"></script> -->
<script src="<?php  echo $root_directory?>resources/jquery-3.3.1.min.js"></script>
<!-- <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script> -->
<script src="<?php  echo $root_directory?>resources/bootstrap-3.3.7.min.js"></script>
<script src="<?php  echo $root_directory?>resources/plugins/leaflet-sidebar.js"></script>
<script src="<?php  echo $root_directory?>resources/plugins/leaflet-overview-nootherdev-fork.js"></script>
<script src="<?php  echo $root_directory?>resources/plugins/leaflet.pm.min.js"></script>
<!-- <script src="https://unpkg.com/leaflet.pm@latest/dist/leaflet.pm.min.js"></script> -->

<script src="<?php  echo $root_directory?>resources/plugins/leaflet.ajax.min.js"></script>
<script src="<?php  echo $root_directory?>resources/plugins/L.Control.MousePosition.js"></script>
<script src="<?php  echo $root_directory?>resources/plugins/leaflet.awesome-markers.min.js"></script>
<script src="<?php  echo $root_directory?>resources/plugins/easy-button.js"></script>



<!-- CSS -->
<style>
/* custom Zoom layer leaflet easy button*/
#mapdiv .easy-button-button{
  transition-duration: .3s;
  position: relative;
  border-radius: 4px;
  border: solid 0px transparent;
}
#mapdiv .easy-button-container{
  background-color: white;
}
#mapdiv .zoom-btn{
  position: absolute;
  top: 0;
  left: 0;
}
#mapdiv .easy-button-button.disabled {
  height: 0;
}

.leaflet-control-layers-expanded {
  padding: 0 5px 0 5px;
  background-color: rgba(255,255,255,0.9);
}
/* custom Zoom layer leaflet easy button*/
/* .infobox_for_toolbar * {margin: 0; padding: 0;} */
.infobox_for_toolbar {
  /* display: block; */
  visibility: hidden;
  color: white;
  background-color: rgba(0, 0, 0, 0.5);
  opacity: 1;
  position: absolute;
  vertical-align: middle;
  text-align: right;
  top:0px;
  z-index: 2000;
  padding: 1px 5px 1px 5px; /*Top right botton left*/
  transition: visibility 0.5s linear;
  margin-top: 0!important;
  margin-left: -135px;
  width: 130px;
  height: 90px;
}
.leaflet-bar.easy-button-container.leaflet-control {
  text-align: left !important;
}

/* Sidebar content, elements equally spaced. To see better what's going one, comment it out the part of "border: 1px solid gray;" */
div.sidebarContentParent{
  padding-top: 5px;
}

div.sidebarContentChild{
  /*EXTRACTED FROM:  http://jsfiddle.net/kqHWM/ */
  display:table;
  width:100%;
  table-layout: fixed;
}
div.sidebarContentChild span {
  /*EXTRACTED FROM:  http://jsfiddle.net/kqHWM/ */
  padding: 5px;
  display:table-cell;
  text-align:center;
  /* border: 1px solid gray; */
}

/* ### CSS for the sidebar */
.leaflet-sidebar-content{
  background-color: rgba(256, 256, 256, 0.7);
}
.leaflet-sidebar{
  /* width: 20%; */
}
.leaflet-sidebar-tabs{
  /* background-color: rgba(0, 172, 237, 0.8); */
}
.sidebar_tab_icon_liked{
  background-color: rgba(0, 256, 0, 0.2);
}
.sidebar_tab_icon_disliked{
  background-color: rgba(256, 0, 0, 0.2);
}
.sidebar_tab_liked_disliked_clicked{
  background-color: rgba(0, 116, 217, 1);
}
.tab_separator{
  background-color: rgba(0,0,0,0.6);
}

.popupInfo {
  /* font-size:14px; */
  /* font-weight: 700; */
  /* background: #ccccff;
  border-color: #ccccff; */

  /* margin: 0px;
  padding: 0px; */
  /* padding: 0px;  */
}
.leaflet-popup-content-wrapper,
.leaflet-popup-tip {
  padding: 0px;
  margin: -20px;
  background: rgba(255, 255, 255, 0.85);
  box-shadow: 0 3px 14px rgba(0,0,0,0.4);
}
.leaflet-popup-tip {
  display: none;
}
/* ### CSS for the Modal DIV  */
/* The Modal (background) */
.modal {
  /* This is what makes everything greyed out when the modal content is displayed */
  /* Makes the modal on top of the sidebar */
  z-index: 2001; /* Sit on top */
  width: 100%; /* Full width */
  height: 100%; /* Full height */
  display: none; /* Hidden by default */
  background-color: rgba(0,0,0,0.4); /* Black w/ opacity */
}
/* Modal Content */
.modal-content {
  color: saddlebrown;
  padding: 20px;
  margin-top: 5%;
  background-color:#e6f2f5;
  height:80%;
  /* When the text displayed in the modal content is greater than 80% of the height it will add a scroll bar in the y position */
  overflow-y:auto;
}

/* ### CSS for some elements of the document */
#header {
  /* height: 75px; */
  height:1vh;
  background-color: #2a6592;
  color: white;
}
#mapdiv {
  /* height: 650px; */
  height:99vh;
  background-color: #f6d8ac;
}
input[type="checkbox"].cbxsidebar{
  cursor: pointer;
  width: 18px;
  height: 18px;
  padding: 0;
  margin:0;
  vertical-align: bottom;
  position: relative;
  top: -5px;
}
label.cbxsidebar {
  cursor: pointer;
  /* display: block; */
  padding-left: 7px;
  text-indent: 0px;
}
h4{
  padding: 0;
  margin-bottom: 3px;
  font-size: 16px;
}
/* Adding some padding in the bootstrap classes  */
.col-xs-12, .col-xs-6, .col-xs-4 {
  padding: 3px;
}

/**************** CSS for index.php *******************/
/*The header will be the same in order to load all the libraries already in the first part (formulary) *******************/
/* Modal for the index.php */
#indexfile.modal{
  z-index: 10000; /* Sit on top */
  width: 100%; /* Full width */
  height: 100%; /* Full height */
  background-color: rgba(0,0,0,0.8) !important; /* Black w/ opacity */
}
#indexfile.modal{
  z-index: 10000; /* Sit on top */
  width: 100%; /* Full width */
  height: 100%; /* Full height */
  background-color: rgba(0,0,0,0.5); /* Black w/ opacity */
}
/* Modal Content */
#indexfile_content.modal-content{
  background-color: red !important;
}

</style>
</head>
