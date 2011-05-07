<?php

$included = strtolower(realpath(__FILE__)) != strtolower(realpath($_SERVER['SCRIPT_FILENAME']));
if(!$included) exit;

function dbcon(){
  mysql_connect("192.168.1.250", "root", "bkrsta");
  mysql_select_db("zadq");
}

function qtoa(){
  $narg = func_num_args();
  if ($narg == 1)
    $q = func_get_arg(0);
  else {
    $argl = func_get_args();
    foreach ($argl as $id=>$arg)
      if($id!=0 && false)
        $argl[$id] = mysql_real_escape_string($arg);
    $q = vsprintf($argl[0], array_slice($argl, 1));
  }
  // echo "<pre>Q: $q</pre>";
  $a = array();
  $r = mysql_query($q) or die("in qtoa(): ".mysql_error());
  if($r==0 || $r==1) return $r;
  while ($row = mysql_fetch_row($r)) array_push($a, $row);
  return $a;
}

function status($id){
  $r = qtoa("select done from tasks where id='%s'", $id);
  return empty($r) ? -1 : $r[0][0];
}

function randid() {
  $length = 32;
  $characters = "0123456789abcdef";
  $string = "";
  for ($p = 0; $p < $length; $p++)
    $string .= $characters[mt_rand(0, strlen($characters))];
  return $string;
}

function upload($zad, $kod, $ucenik=1){
  $tid = randid();
  $q = "select id from zadatci where zad=%d and ucenik=%d";
  $r = qtoa($q, $zad, $ucenik);
  if(empty($r)){
    qtoa("insert into zadatci values (null, '%s', null, %d, %d)", $kod, $zad, $ucenik);
  } else {
    qtoa("update zadatci set kod='%s' where id=%d", $kod, $r[0][0]);
  }
  $r = qtoa($q, $zad, $ucenik);
  qtoa("insert into tasks values ('%s', %d, 0, 0, NOW(), null)", $tid, $r[0][0]);
  return $tid;
}

dbcon();

?>