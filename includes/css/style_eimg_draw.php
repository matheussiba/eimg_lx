<style>
	/* ### CSS for some elements of the document */
	html,body {
	  /* background-color: #f6d8ac; */
		background: url("<?php  echo $root_directory?>resources/images/eimg_logo_1.png");
		background-size: auto 30%;
		background-repeat: no-repeat;
	    background-position: center;
		height: 100%;
		margin: 0px;
		padding: 0px
	}
	#header {
	  /* height: 75px; */
	  height:4vh;
	  background-color: #2a6592;
	  color: white;
	}
	#mapdiv {
	  /* height: 650px; */
	  height:96vh;
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

	/* ### CSS for the sidebar */
	/* Sidebar content, elements equally spaced. To see better what's going one, comment it out the part of "border: 1px solid gray;" */
	div.sidebarContentParent{
	  padding-top: 5px;
	}

	input[type="text"].sidebarTitle
	{
	    background: transparent;
	    border: none;
	    height: 30px;
	    width: 280px;
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

	/* ### CSS for changing bootstrap classes  */

	.btn {
		border-radius: 24px;
	}

	.btn-light, .btn-primary:hover, .btn-primary:active, .btn-primary:visited {
	    border: 1px solid black !important;
	}

	.btn-light{
		background-color: white;
	}

	.modal {
		z-index: 10001;
	  background-color: rgba(0,0,0,0.4);
	}
	.modal-content {
		z-index: 10001;
	  color: saddlebrown;
	  padding: 20px;
	  margin-top: 5%;
	  height:80%;
	  overflow-y:auto;
	}

</style>
