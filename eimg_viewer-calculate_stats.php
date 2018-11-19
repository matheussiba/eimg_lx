<?php
if (isset($_POST['select'])) {
    $select = $_POST['select'];
} else {
    $select = "count(*)";
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
$strQry="SELECT {$select} FROM eimg_result {$where}{$order}";
$result = $pdo->query($strQry);

// Process to create a valid geoJSON pulling the data form the DB
try {
    $returnJson= "";
    $row=$result->fetch();
    if ($row) {
      $returnJson .= json_encode($row);
    }
    //get the associative array and encode into a valid json format.
    echo $returnJson;
} catch(PDOException $e) {
    echo "ERROR: ".$e->getMessage();
}

?>
