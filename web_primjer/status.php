<?php

include 'lib.php';

if(isset($_GET['uc']) && isset($_GET['zad'])){
  $r = qtoa("select bodovi from zadatci where ucenik=%d and zad=%d", $_GET['uc'], $_GET['zad']);
  $b = $r[0][0];
  echo (!empty($r)) ? "$b\n" : "-1\n";
  exit;
}

if(!isset($_GET['id'])){ echo "?"; exit; }
$id = $_GET['id'];

echo status($id)."\n";

?>