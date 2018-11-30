<?php include "../includes/init.php"?>
<?php
    session_unset();
    // Creates a session
    session_destroy();
    echo 'Session was destroyed';
?>
