<?php
    if (isset($_POST['tbl'])) {
        $table = $_POST['tbl'];
        if (isset($_POST['flds'])) {
            $fields = $_POST['flds'];
        } else {
            $fields = "*";
        }
        if (isset($_POST['where'])) {
            $where = " WHERE ".$_POST['where'];
        } else {
            $where = "";
        }
        if (isset($_POST['order'])) {
            $order=" ORDER BY ".$_POST['order'];
        } else {
            $order="";
        }

        // Credentials
        $db_name = "eimg_lx";
        $host = "localhost";
        $username = "postgres";
        $password = "admin";
        $port = "5432";


        $dsn = "pgsql:host=".$host.";dbname=".$db_name.";port=".$port;
        $opt = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false
        ];
        $pdo = new PDO($dsn, $username, $password, $opt);
        $strQry="SELECT {$fields}, ST_AsGeoJSON(geom, 5) AS geojson FROM {$table}{$where}{$order}";
        $result = $pdo->query($strQry);

        // Process to create a valid geoJSON pulling the data form the DB
        try {
            $features=[];
            foreach($result AS $row) {
                //Takes out the column geom of the returned row. It won't be needed to create the json format
                unset($row['geom']);
                //Get the 'geojson' column that is added to the row in the SQL query (it comes in a JSON format)
                //It comes already encoded. So it needs to be decoded to encode everything together in the end.
                $geometry=$row['geojson']=json_decode($row['geojson']);
                //unset the 'geojson' column to be added in a valid way below.
                unset($row['geojson']);
                //Now the $row variable only contain the properties of the feature gotten from the DB.
                $feature=["type"=>"Feature", "geometry"=>$geometry, "properties"=>$row];
                array_push($features, $feature);
            }
            //Creating the final step of a geoJSON
            $featureCollection=["type"=>"FeatureCollection", "features"=>$features];
            //get the associative array and encode into a valid json format.
            echo json_encode($featureCollection);
        } catch(PDOException $e) {
            echo "ERROR: ".$e->getMessage();
        }
    } else {
        //This "ERROR" needs to be kept in this way to be manipulated by the function that called this file in case of error
        echo "ERROR: No table parameter incuded with request";
    }

?>
