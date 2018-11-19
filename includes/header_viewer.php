<head>
  <meta charset="UTF-8">
  <!-- Responsive meta tag, help with mobile devices -->
  <!-- <meta name="viewport" content="width=device-width, initial-scale=1"> -->
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

  <title>eimg Lisbon - Demo Version</title>

  <!-- Adding CSS files -->
  <!-- <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"> -->
  <link rel="stylesheet" href="/<?php  echo $root_directory?>/resources/bootstrap-3.3.7.min.css"/>
  <!-- <link rel="stylesheet" href="https://unpkg.com/leaflet@1.2.0/dist/leaflet.css"
       integrity="sha512-M2wvCLH6DSRazYeZRIm1JnYyh22purTM+FDB5CsyxtQJYeKq83arPe5wgbNmcFXGqiSH2XR8dT/fJISVA1r/zQ=="
       crossorigin=""/> -->
   <link rel="stylesheet" href="/<?php  echo $root_directory?>/resources/leaflet-1.2.0.css"
        integrity="sha512-M2wvCLH6DSRazYeZRIm1JnYyh22purTM+FDB5CsyxtQJYeKq83arPe5wgbNmcFXGqiSH2XR8dT/fJISVA1r/zQ=="
        crossorigin=""/>
  <link rel="stylesheet" href="/<?php  echo $root_directory?>/resources/plugins/leaflet.pm.css"/>
  <link rel="stylesheet" href="/<?php  echo $root_directory?>/resources/plugins/L.Control.MousePosition.css">
  <link rel="stylesheet" href="/<?php  echo $root_directory?>/resources/plugins/leaflet-sidebar.min-v3.0.2.css">
  <link rel="stylesheet" href="/<?php  echo $root_directory?>/resources/css/font-awesome.min.css">
  <!-- <link href="http://maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet"> -->
  <link rel="stylesheet" href="/<?php  echo $root_directory?>/resources/plugins/leaflet.awesome-markers.css">
  <link rel="stylesheet" href="/<?php  echo $root_directory?>/resources/plugins/easy-button.css">
  <!-- Adding JS files -->
  <!-- <script src="https://unpkg.com/leaflet@1.2.0/dist/leaflet.js"
        integrity="sha512-lInM/apFSqyy1o6s89K4iQUKg6ppXEgsVxT35HbzUupEVRh2Eu9Wdl4tHj7dZO0s1uvplcYGmt3498TtHq+log=="
        crossorigin="">
  </script> -->
  <script src="/<?php  echo $root_directory?>/resources/leaflet-1.2.0.js"
        integrity="sha512-lInM/apFSqyy1o6s89K4iQUKg6ppXEgsVxT35HbzUupEVRh2Eu9Wdl4tHj7dZO0s1uvplcYGmt3498TtHq+log=="
        crossorigin="">
  </script>
  <!-- <script src="https://code.jquery.com/jquery-2.2.4.min.js"></script> -->
  <script src="/<?php  echo $root_directory?>/resources/jquery-3.3.1.min.js"></script>
  <!-- <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script> -->
  <script src="/<?php  echo $root_directory?>/resources/bootstrap-3.3.7.min.js"></script>
  <script src="/<?php  echo $root_directory?>/resources/plugins/leaflet-sidebar.js"></script>
  <script src="/<?php  echo $root_directory?>/resources/plugins/leaflet.pm.min.js"></script>
  <script src="/<?php  echo $root_directory?>/resources/plugins/leaflet.ajax.min.js"></script>
  <script src="/<?php  echo $root_directory?>/resources/plugins/L.Control.MousePosition.js"></script>
  <script src="/<?php  echo $root_directory?>/resources/plugins/leaflet.awesome-markers.min.js"></script>
  <script src="/<?php  echo $root_directory?>/resources/plugins/easy-button.js"></script>



  <!-- CSS -->
  <style>

  /* ****************** CSS for the LeafletToolTip of eimg_viewer ****************** */
    .tooltipstyle-green {
        font-size:14px;
        font-weight: 700;
        background: #ccffcc;
        border-color: #ccffcc;
        /* ffcccc */
        /* ccccff */
        /* fillColor: none;
        fillOpacity: 0;
        background-color: none;
        border-color: none;
        background: none;
        border: none;
        box-shadow: none; */
        margin: 0px;
        padding: 0px;
    }
    .tooltipstyle-blue {
        font-size:14px;
        font-weight: 700;
        background: #ccccff;
        border-color: #ccccff;
        margin: 0px;
        padding: 0px;
    }
    .tooltipstyle-red {
        font-size:14px;
        font-weight: 700;
        background: #ffcccc;
        border-color: #ffcccc;
        margin: 0px;
        padding: 0px;
    }

    .fa-thumbs-up {
      color: green;
    }

    .fa-thumbs-down {
      color: red;
    }


    /* ****************** CSS for the sidebar ****************** */
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
  .tab_separator{
    background-color: rgba(0,0,0,0.6);
  }


  .col-xs-12, .col-xs-6, .col-xs-4 {
    padding: 3px;
  }

  #header {
    /* height: 75px; */
    height:5vh;
    background-color: #2a6592;
    color: white;
  }

  /* ****************** CSS for div in sidebar ****************** */




  /* ****************** CSS for the map ****************** */
  /* NEEDTO: There will be no header and footer all the information will be added to the map */
  #mapdiv {
    /* height: 650px; */
    height:95vh;
    background-color: #f6d8ac;
  }

  /* ****************** CSS for the Modal DIV ****************** */
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
    background-color:antiquewhite;
    height:80%;
    /* When the text displayed in the modal content is greater than 80% of the height it will add a scroll bar in the y position */
    overflow-y:auto;
  }

  /* ****************** CSS for the Google tranlate tool ****************** */
  .ct-topbar {
    text-align: center;
    /* background: rgba(256, 256, 256, 0.4); */
  }
  .ct-topbar__list {
    margin-bottom: 0px;
  }
  .ct-language__dropdown{
  	padding-top: 8px;
  	max-height: 0;
  	overflow: hidden;
  	position: absolute;
  	top: 110%;
  	left: -3px;
  	-webkit-transition: all 0.25s ease-in-out;
  	transition: all 0.25s ease-in-out;
  	width: 100px;
  	text-align: center;
  	padding-top: 0;
    z-index:200;
  }
  .ct-language__dropdown li{
  	background: #444;
  	padding: 5px;
  }
  .ct-language__dropdown li a{
  	display: block;
  }
  .ct-language__dropdown li:first-child{
  	padding-top: 10px;
  	border-radius: 3px 3px 0 0;
  }
  .ct-language__dropdown li:last-child{
  	padding-bottom: 10px;
  	border-radius: 0 0 3px 3px;
  }
  .ct-language__dropdown li:hover{
  	background: #555;
  }
  .ct-language__dropdown:before{
  	content: '';
  	position: absolute;
  	top: 0;
  	left: 0;
  	right: 0;
  	margin: auto;
  	width: 8px;
  	height: 0;
  	border: 0 solid transparent;
  	border-right-width: 8px;
  	border-left-width: 8px;
  	border-bottom: 8px solid #222;
  }
  .ct-language{
  	position: relative;
    background: #00aced;
    color: #fff;
    padding: 10px 0;
  }
  .ct-language:hover .ct-language__dropdown{
  	max-height: 200px;
  	padding-top: 8px;
  }
  .list-unstyled {
      padding-left: 0;
      list-style: none;
  }


  </style>
</head>
