<?php
try{
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
  $result = $pdo->query("DROP TABLE IF EXISTS merged");

  $result = $pdo->query(
    "CREATE TABLE merged AS
    SELECT ST_Union(geom) as geom, eval_nr
    FROM eimglx_areas_demo
    GROUP BY eval_nr;"
  );

  // $result = $pdo->query(
  //   "CREATE TABLE merged AS
  //   SELECT ST_Union(ST_SnapToGrid(geom,0.0001)) as geom
  //   FROM eimglx_areas_demo"
  // );

  $result = $pdo->query(
    "ALTER TABLE merged ALTER COLUMN geom type geometry(MultiPolygon, 4326)
    USING ST_Multi(geom);"
  );

  $result = $pdo->query("SELECT *, ST_AsGeoJSON(geom, 5) AS geojson FROM merged;");
  // Process to create a valid geoJSON pulling the data form the DB

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

  // $features=[];
  // while($row = $sql->fetch(PDO::FETCH_ASSOC)){
  //   $feature=['type'=>'Feature'];
  //   $feature['geometry']=json_decode($row['geom']);
  //   //unset($row['geom']);
  //   $feature['geom'] = json_decode($row['geom']);
  //   $feature['properties']=$row;
  //   array_push($features, $feature);
  // }
} catch(PDOException $e) {
  echo "ERROR: ".$e->getMessage();
}

?>
