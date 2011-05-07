<?php

include 'lib.php';

$ucenik = 1;
$zad = 1;

if (
  $_POST['kojiZadatak'] && !preg_match('/^\d+$/', $_POST['kojiZadatak']) ||
  $zad && !preg_match('/^\d+$/', $zad)
){ echo ":)"; exit; }

if(isset($_POST['kod'])){
  $kod = $_POST['kod'];
  $zad = $_POST['kojiZadatak'];
  $task_id = upload($zad, $kod, $ucenik);
}

if($_POST['kojiZadatak'])
  $zad = $_POST['kojiZadatak'];

$r = qtoa("select id, kod, bodovi from zadatci where zad=%d and ucenik=%d", $zad, $ucenik);

if(!empty($r)){
  $zad_id = $r[0][0];
  $src    = $r[0][1];
  $tocno  = $r[0][2];
}

$r = qtoa("select zad, tekst from zad where id=%d", $zad);
$zad_ime = $r[0][0];
$zad_txt = $r[0][1];

$zadatci = qtoa("select id from zad;");

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>Cee elektronicki evaluator</title>	
	<meta http-equiv="content-type" content="text/html;charset=UTF-8" />
	<link rel="stylesheet" href="css/screen.css" media="screen" />
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
	<script type="text/javascript" charset="utf-8">
    function setSelectionRange(input, selectionStart, selectionEnd) {
      if (input.setSelectionRange) {
        input.focus();
        input.setSelectionRange(selectionStart, selectionEnd);
      }
      else if (input.createTextRange) {
        var range = input.createTextRange();
        range.collapse(true);
        range.moveEnd('character', selectionEnd);
        range.moveStart('character', selectionStart);
        range.select();
      }
    }
    function replaceSelection (input, replaceString) {
      if (input.setSelectionRange) {
        var selectionStart = input.selectionStart;
        var selectionEnd = input.selectionEnd;
        input.value = input.value.substring(0, selectionStart)+ replaceString + input.value.substring(selectionEnd);

        if (selectionStart != selectionEnd) setSelectionRange(input, selectionStart, selectionStart + 	replaceString.length);
        else setSelectionRange(input, selectionStart + replaceString.length, selectionStart + replaceString.length);
      } else if (document.selection) {
        var range = document.selection.createRange();

        if (range.parentElement() == input) {
          var isCollapsed = range.text == '';
          range.text = replaceString;

          if (!isCollapsed) { range.moveStart('character', -replaceString.length); range.select(); }
        }
      }
    }
    function catchTab(item, e){
      if(navigator.userAgent.match("Gecko")) c=e.which;
      else c=e.keyCode;
      if(c==9){
        replaceSelection(item,String.fromCharCode(9));
        setTimeout("document.getElementById('"+item.id+"').focus();",0);	
        return false;
      }
    }
    String.prototype.startsWith = function(prefix) {
      return this.indexOf(prefix) === 0;
    }
	</script>
  <script type="text/javascript" charset="utf-8">
    function obojiBodove(data) {
      $("#bodovi").html(data);
      if(data.startsWith("-1")){
        $("#bodovi").css('color', 'red');
      } else if(data.startsWith("0")){
        $("#bodovi").css('color', 'red');
      } else {
        $("#bodovi").css('color', 'green');
      }
    }
    function objasniBodove(data) {
      if(data.startsWith("-1")){
        alert("Greska kod kompajliranja ...");
      } else if(data.startsWith("0")){
        alert("Nula bodova :)");
      } else {
        alert("Bodovi: "+data);
      }
    }
    $(document).ready(function() {
      obojiBodove("<?=$tocno?>");
    });
  </script>
</head>
<body>

<div id="container">
  <h1>C<span class="crveno" >ef2</span> - C elektronički evaluator</h1>
  <p class="sivo">Sustav za evaluaciju zadataka iz informatike.</p><br />

  <form action="" method="post" >
    <h2 style="display: inline">Zadatak:</h2>
    <select name="kojiZadatak" style="font-size: 1.3em; width: 4em; text-align: center;" onchange="this.form.submit()">
      <? foreach($zadatci as $z){ ?>
        <option <?=($z[0]==$zad)?"selected ":""?>value="<?=$z[0]?>"><?=$z[0]?></option>
        <? } ?>
      </select>
  </form>

  <h2>Zad: <?= $zad_ime ?><br /><br />
    Tocno: <span id="bodovi"><?= $tocno ?></span>
    <span id="taskstatus" style="display: none;"><img width="20" src="images/loading.gif" /></span>
  </h2>
  <div class="rubGore">
    <p style="text-align: justify">
      <?= $zad_txt ?>
    </p>
    <p class="rubDolje" class="cb">&nbsp;</p>
  </div>

<? if($_POST['kod']){ ?>

<script type="text/javascript">
function u() {
  $("#bodovi").text("");
  $("#taskstatus").show();
  $.get("status.php?id=<?= $task_id ?>", function (data, textStatus) {
    if(data.startsWith("1")){
      $.get("status.php?uc=<?=$ucenik?>&zad=<?=$zad?>", function (data, textStatus){
        $("#taskstatus").hide();
        obojiBodove(data);
        objasniBodove(data);
      });
    } else setTimeout("u()", 2000);
  });
}
$(function(){ u(); });
</script>
<? } ?>

  <h2>Rješenje:</h2>
  <p>Zadnja promjena: ...</p>
  <form class="rubGore" action="" method="post">
    <p><textarea name="kod" id="message" cols="69" rows="15" wrap="off" onkeydown="return catchTab(this,event)"><?=$src?></textarea></p>
    <input type="hidden" name="kojiZadatak" value="<?=$zad?>" />
    <input type="submit" value="Salji" />
  </form>
  <br />
</div>

</body>
</html>
