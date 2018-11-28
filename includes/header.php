<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>eimg Lisbon - Demo Version</title>

    <!-- Adding CSS files -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.1/dist/leaflet.css">
    <link rel="stylesheet" href="<?php  echo $root_directory?>resources/leaflet.pm.css">

    <!-- Adding JS files -->
    <script src="https://unpkg.com/leaflet@1.0.1/dist/leaflet.js"></script>
    <script src="https://code.jquery.com/jquery-2.2.4.min.js"></script>
    <script src="<?php  echo $root_directory?>resources/leaflet.ajax.js"></script>
    <script src="<?php  echo $root_directory?>resources/turf.min.js"></script>
    <script src="<?php  echo $root_directory?>resources/leaflet.pm.min.js"></script>

    <!-- Inline CSS -->
    <style>
        #header {
            height: 75px;
            background-color: darkgoldenrod;
        }
        #mapdiv {
            height: 650px;
            background-color:salmon;
        }
        #side_panel {
            height: 650px;
            background-color:beige;
        }
        #footer {
            height:75px;
            background-color: darkgrey;
        }
        .attraction {
            margin-bottom: 5px;
        }
    </style>
</head>
