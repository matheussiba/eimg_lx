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
   <link rel="stylesheet" href="<?php  echo $root_directory?>resources/leaflet-1.2.0.css"
        integrity="sha512-M2wvCLH6DSRazYeZRIm1JnYyh22purTM+FDB5CsyxtQJYeKq83arPe5wgbNmcFXGqiSH2XR8dT/fJISVA1r/zQ=="
        crossorigin=""/>
  <!-- <link rel="stylesheet" href="<?php  echo $root_directory?>resources/plugins/leaflet.pm.css"/> -->
  <link rel="stylesheet" href="https://unpkg.com/leaflet.pm@latest/dist/leaflet.pm.css" />
  <link rel="stylesheet" href="<?php  echo $root_directory?>resources/plugins/L.Control.MousePosition.css">
  <link rel="stylesheet" href="<?php  echo $root_directory?>resources/plugins/leaflet-sidebar.min-v3.0.2.css">
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
  <script src="<?php  echo $root_directory?>resources/leaflet-1.2.0.js"
        integrity="sha512-lInM/apFSqyy1o6s89K4iQUKg6ppXEgsVxT35HbzUupEVRh2Eu9Wdl4tHj7dZO0s1uvplcYGmt3498TtHq+log=="
        crossorigin="">
  </script>
  <!-- <script src="https://code.jquery.com/jquery-2.2.4.min.js"></script> -->
  <script src="<?php  echo $root_directory?>resources/jquery-3.3.1.min.js"></script>
  <!-- <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script> -->
  <script src="<?php  echo $root_directory?>resources/bootstrap-3.3.7.min.js"></script>
  <script src="<?php  echo $root_directory?>resources/plugins/leaflet-sidebar.js"></script>
  <!-- <script src="<?php  echo $root_directory?>resources/plugins/leaflet.pm.min.js"></script> -->
  <script src="https://unpkg.com/leaflet.pm@latest/dist/leaflet.pm.min.js"></script>

  <script src="<?php  echo $root_directory?>resources/plugins/leaflet.ajax.min.js"></script>
  <script src="<?php  echo $root_directory?>resources/plugins/L.Control.MousePosition.js"></script>
  <script src="<?php  echo $root_directory?>resources/plugins/leaflet.awesome-markers.min.js"></script>
  <script src="<?php  echo $root_directory?>resources/plugins/easy-button.js"></script>



  <!-- CSS -->
  <style>

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
  .sidebar_tab_liked_disliked_clicked{
    background-color: rgba(0, 116, 217, 1);
  }
  .tab_separator{
    background-color: rgba(0,0,0,0.6);
  }


  .col-xs-12, .col-xs-6, .col-xs-4 {
    padding: 3px;
  }

  #header {
    /* height: 75px; */
    height:4vh;
    background-color: #2a6592;
    color: white;
  }

  /* ****************** CSS for the map ****************** */
  /* NEEDTO: There will be no header and footer all the information will be added to the map */
  #mapdiv {
    /* height: 650px; */
    height:96vh;
    background-color: #f6d8ac;
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
    background-color:#e6f2f5;
    height:80%;
    /* When the text displayed in the modal content is greater than 80% of the height it will add a scroll bar in the y position */
    overflow-y:auto;
  }

  input[type="checkbox"]{
    cursor: pointer;
    width: 18px;
    height: 18px;
    padding: 0;
    margin:0;
    vertical-align: bottom;
    position: relative;
    top: -5px;
  }

  label {
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

  .div_sidebar_content {
    padding-left:5px;
  }



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
