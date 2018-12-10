<?php include "includes/init.php"?>
<?php
//checking if the index page was accessed
if (isset($_SESSION['user_id'])) {
  // NEEDTO: Change message if a person tries to access this page without passing index.php
  // print_r($_SESSION);
  // echo implode("\t|\t",$_SESSION);
  $_SESSION['token_code'] = generate_token();
  $header = "eIMG Lisbon ";

  // session_unset();
  session_destroy();

}else{
  // print_r($_SESSION);
  $header = "eIMG Lisbon - (change: ONLY ACCESS WITH USER_ID SET)";
  // redirect('index.php');
  // set_msg("Please choose what you want to do");
}
?>
<!DOCTYPE html>
<html lang="en-US">
<!-- Adding the HEADER file -->
<?php include "includes/header.php" ?>
<?php include "includes/css/style_eimg_draw.php" ?>
<?php include "includes/css/style_eimg_index.php" ?>

<style>


</style>


<body>
  <script>
  //  ********* OLD FUNCTIONS
  var mobileDevice = false;
  if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)){
    /*### DESCRIPTION: Check if the web application is being seen in a mobile device   */
    mobileDevice = true;
  };

</script>

<!-- Modal_1 -->
<div class="modal fade" id="modal_1_intro" tabindex="-1" role="dialog" aria-labelledby="modal_1_introTitle" aria-hidden="true" data-backdrop="false">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header modal-header-removeclose" style="padding:5px">
        <h5 class="modal-title" id="exampleModalLabel">
          <span class="language-en">Welcome to eImage-LX</span>
          <span class="language-pt">Bem vindo ao eImage-LX</span>
        </h5>
        <div class="pull-right">
          <label class="radio-inline" >
            <input type="radio" name="language_switch" value="pt">
            <img src="<?php  echo $root_directory?>resources/images/flags/portugal.png" style="margin-left: 5px">
          </label>
          <label class="radio-inline">
            <input type="radio" name="language_switch" value="en">
            <img src="<?php  echo $root_directory?>resources/images/flags/united_kingdom.png" style="margin-left: 5px">
          </label>
        </div>
      </div>

      <div class="modal-body">
        <div class="col" style="text-align:center;">
          <img src="<?php  echo $root_directory?>resources/images/eimg_logo_1.png" id="logo_munster" style="margin-left: 5px">
        </div>
        <!--  Project's explanation  -->
        <p>
          <span>Este questionário é parte integrante de um projeto de investigação da Nova Information Management School (NOVA IMS) da Universidade Nova de Lisboa. O objetivo principal é perceber a forma como a perceção do local e as relações sociais do cidadão influenciam a sua participação numa dada área urbana.</span>
        </p>
        <p>
          <span>O preenchimento do questionário demora cerca de 5 minutos e a atividade de mapeamento cerca de 15 minutos, dependendo do número de áreas que se pretenderem assinalar.</span>
        </p>
        <p>
          <span>A sua contribuição apoia os processos participativos da cidade de Lisboa.</span>
        </p>

        <p style="font-size: 12px; margin-top: 30px">
          <span> Notas:</span>
          <br>
          <span>1.Todos os dados recolhidos neste questionário serão tratados de forma anónima e confidencial e não serão utilizados para fins comerciais ou cedidos a terceiros.</span>
          <br>
          <span>2. Se pretender esclarecer alguma dúvida ou pedir alguma informação sobre este estudo, queira por favor contactar-nos através do seguinte endereço de email: acedo@novaims.unl.pt (Albert Acedo Sánchez)</span> <span> ou visite o nosso</span><span> <a
            class="link-secondary" href="http://www.engagingeographies.com/blog">blog</a>.</span>
            <br>
          </p>

        </div> <!--/.modal-body -->
        <div class="modal-footer" style="border:none;">
          <div class="container-fluid">
            <div class="row">
              <div class="col" style="text-align:center;padding-top: 8px; font-size: 13px;">
                <input type="checkbox" name="cbxAgreement">
                <span class="language-en">I agree to take part in the above study.</span>
                <span class="language-pt">Eu aceito a participar do estudo mencionado acima.</span>
              </div>
              <div class="col-4">
              <div style="text-align:right;">
                <button type="button" id="btn_go_modal_2" class="btn btn-primary btn-next" style="height:auto;width:auto;font-size:12px;">
                  <span class="language-en">Start</span>
                  <span class="language-pt">Começar</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
      <!--  Logos  -->
      <div class="container-fluid">
        <div class="row" style="text-align:left;margin-top:-10px;">
          <div class="col">
            <hr />
            <span class="language-en">Partner Universities:</span>
            <span class="language-pt">Universidades Parceiras:</span>
          </div>
        </div>
        <div class="row">
          <div class="col">
            <div style="padding-top: 18px;"><img src="<?php  echo $root_directory?>resources/images/uni/mundus.png" id="logo_mundus" alt="Nova IMS"></div>
          </div>
          <div class="col">
            <div><img src="<?php  echo $root_directory?>resources/images/uni/novaims.png" id="logo_nova" alt="Nova IMS"></div>
          </div>
          <div class="col">
            <div><img src="<?php  echo $root_directory?>resources/images/uni/wwu.png" id="logo_munster" alt="Münster"></div>
          </div>
          <div class="col">
            <div><img src="<?php  echo $root_directory?>resources/images/uni/uji.png" id="logo_uji" alt="UJI"></div>
          </div>
        </div>
      </div>
    </div> <!--/.modal-content -->
  </div> <!--/.modal-dialog -->
</div>  <!--/.modal -->

<!-- ###############  Div that contains the header ############### -->
<div id="header" class="col-md-12">
  <p class="text-center"><?php echo $header ?> </p>
</div>


<script>
var cookie_lang = getCookie("app_language");
console.log(cookie_lang);
if(cookie_lang!=""){
  $("input[type=radio][name=language_switch][value='"+cookie_lang+"']").prop("checked",true);
}else{
  $("input[type=radio][name=language_switch][value='pt']").prop("checked",true);
}
// Open the first modal
$('#modal_1_intro').modal('show');

var checkedValue = $('input[type=radio][name=language_switch]:checked').val();
cbxLangChange(checkedValue);

function setCookie(cname, cvalue, exdays) {
  var d = new Date();
  d.setTime(d.getTime() + (exdays*24*60*60*1000));
  var expires = "expires="+ d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}
function getCookie(cname) {
  var name = cname + "=";
  var decodedCookie = decodeURIComponent(document.cookie);
  var ca = decodedCookie.split(';');
  for(var i = 0; i <ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}

function cbxLangChange(value){
  setCookie("app_language", value, 7);
  var cookie_lang = getCookie("app_language");
  console.log('cook_cbxlangchange:',cookie_lang);
  if (value == 'en') {
    siteLang='en';
    $('.language-pt').hide(); // hides
    $('.language-en').show(); // Shows
  }
  else if (value == 'pt') {
    siteLang='pt';
    $('.language-en').hide(); // hides
    $('.language-pt').show(); // Shows
  }
}

$("#btn_go_modal_2").on("click", function () {
  $('#modal_1_intro').modal('hide');
  $('#modal_2_demographics').modal('show');

  cbxLangChange(getCookie("app_language"));
  // window.location.href = 'eimg_draw.php';

});

$('input[type=radio][name=language_switch]').change(function() {
  cbxLangChange(this.value);
});




</script>

</body>
</html>
