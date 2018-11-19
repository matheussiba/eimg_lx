<?php
    //To know more about outbuffer: https://stackoverflow.com/questions/4401949/whats-the-use-of-ob-start-in-php
    ob_start();
    // Creates a session
    session_start();
    //  *************** For PostgreSQL
        $dsn = "pgsql:host=localhost;dbname=eimg_lx;port=5432";
        $opt = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,//If occur some error fom the DB, it is displayed
            // PDO::ATTR_ERRMODE            => PDO::ERRMODE_SILENT, //If occur some error fom the DB, it's not displayed
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false
        ];
        $pdo = new PDO($dsn, 'postgres', 'admin', $opt);

    //Defining PHP variable for the root directory
    $root_directory = "0_thesis/eimglx_demo";
    $from_email = "matheus.eco.2010@gmail.com";
    $reply_email = "matheus.eco.2010@gmail.com";

    //Include the PHP functions
    include "php_functions.php";

    //Creating token for the client who accessed the page
    $_SESSION['token_code'] = generate_token();
?>
