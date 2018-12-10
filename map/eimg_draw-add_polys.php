<?php
  if (isset($_POST['tbl'])) {
    $table = $_POST['tbl'];

    if (isset($_POST['geojson'])) {
      $geojson = $_POST['geojson'];
    }
    if (isset($_POST['eval_nr'])) {
      $eval_nr = $_POST['eval_nr'];
    }
    if (isset($_POST['eval_str'])) {
      $eval_str = $_POST['eval_str'];
    }
    if (isset($_POST['att_nat'])) {
      $att_nat = $_POST['att_nat'];
    }
    if (isset($_POST['att_open'])) {
      $att_open = $_POST['att_open'];
    }
    if (isset($_POST['att_ord'])) {
      $att_ord = $_POST['att_ord'];
    }
    if (isset($_POST['att_up'])) {
      $att_up = $_POST['att_up'];
    }
    if (isset($_POST['att_hist'])) {
      $att_hist = $_POST['att_hist'];
    }

    // 1, Liked, 1,1,1,0,1
    $pdo = new PDO('pgsql:host=localhost;port=5432;dbname=eimg_lx;', 'postgres', 'admin');

    // Credentials
    include "../includes/db_credentials.php";
    $dsn = "pgsql:host=".$host.";dbname=".$db_name.";port=".$port;
    $pdo = new PDO($dsn, $username, $password);

    $result = $pdo->query("SELECT count(*) FROM eimg_raw_polys;");
    $returnJson= "";
    $row=$result->fetch();
    if ($row) {
      $returnJson .= json_encode($row);
    }
    echo $returnJson;

    $str = "INSERT INTO $table
            ( geom_4326,
              eval_nr, eval_str,
              att_nat, att_open, att_order, att_upkeep, att_hist,
              centroid,
              area_sqm,
              geom_27493
            )
            VALUES
            ( ST_SetSRID(ST_GeomFromGeoJSON(:gjsn),4326),
              :e_nr, :e_str,
              :nat, :open, :ord, :up, :hist,
              ST_Centroid( ST_SetSRID(ST_GeomFromGeoJSON(:gjsn),4326) ),
              ST_Area(ST_SnapToGrid( ST_Transform( ST_SetSRID(ST_GeomFromGeoJSON(:gjsn),4326) ,27493), 0.00001)),
              ST_SnapToGrid( ST_Transform( ST_SetSRID(ST_GeomFromGeoJSON(:gjsn),4326) ,27493), 0.00001)
            )";
    $params = ["gjsn"=>$geojson, "e_nr"=>$eval_nr, "e_str"=>$eval_str, "nat"=>$att_nat, "open"=>$att_open, "ord"=>$att_ord, "up"=>$att_up, "hist"=>$att_hist];


    try{
      $sql = $pdo->prepare($str);
      if ($sql->execute($params)) {
        echo "place succesfully added";
        // session_destroy();

        $result = $pdo->query("SELECT count(*) FROM eimg_raw_polys;");
        $returnJson= "";
        $row=$result->fetch();
        if ($row) {
          $returnJson .= json_encode($row);
        }
        echo $returnJson;

      } else {
        echo var_dump($sql->errorInfo());
      };
    } catch(PDOException $e) {
      echo "ERROR: ".$e->getMessage();
    }
  }else {
    echo "ERROR: No table parameter included with request";
  }
?>
