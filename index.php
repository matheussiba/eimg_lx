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
<div class="modal fade" id="modal_1_intro" tabindex="-1" role="dialog" aria-labelledby="modal_1_intro" aria-hidden="true" data-backdrop="false">
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
          <span class="language-en">
            eImage is part of a research project involving 3 European universities: <b>NOVA IMS</b> (Lisbon, Portugal), <b>UJI</b> (Castellón, Spain) and <b>WWU</b> (Münster, Germany).
            The core idea is to ask citizens and visitors of Lisbon about places they like and places they dislike within the city
            in order to produce an evaluative image of the Lisbon.
          </span>
          <span class="language-pt">
            eImage é parte integrante de um projeto de investigação envolvendo 3 universidades européias: <b>NOVA IMS</b> (Lisboa, Portugal), <b>UJI</b> (Castellón, Espanha) and <b>WWU</b> (Münster, Alemanha).
            The idéia principal é perguntar a moradores e visitantes de Lisboa, área que eles gostam e áreas que eles não gostam dentro da cidade,
            para assim produzir uma imagem avaliativa dessa maravilhosa capital lusitana.
          </span>
        </p>
        <p>
          <span class="language-en">
            This mapping activity takes most people around 7 minutes, depending on how many areas you draw.
          </span>
          <span class="language-pt">
            Essa atividade de mapeamento leva a maioria das pessoas em torno de 7 minutos, dependendo de quantas áreas você deseja desenhar.
          </span>
        </p>
        <p>
          <span class="language-en">
            Your contribution supports the participative processes of the city of Lisbon.
          </span>
          <span class="language-pt">
            A sua contribuição apoia os processos participativos da cidade de Lisboa.
          </span>
        </p>

        <p><b><h4 id="message_mobile">
          <span class="language-en">
            Please use your mobile device in the landscape orientation.
          </span>
          <span class="language-pt">
            Por favor use o seu telemóvel na orientação landscape.
          </span>
        </h4></b></p>

        <p><b><h4 id="message_ie"></h4></b></p>

        <p style="font-size: 12px; margin-top: 30px">
          <span class="language-en">
            Notes:
          </span>
          <span class="language-pt">
            Notas:
          </span>
          <br>
          <span class="language-en">
            1. All data collected is treated with confidentiality and anonymity, and will not be used for commercial purposes or distributed to third parties.
          </span>
          <span class="language-pt">
            1. Todos os dados recolhidos neste questionário serão tratados de forma anónima e confidencial e não serão utilizados para fins comerciais ou cedidos a terceiros.
          </span>
          <br>
          <span class="language-en">
            2. For more information or questions about this study, please contact us using the following email address: msbarros.gis@gmail.com (Matheus Siqueira Barros).
          </span>
          <span class="language-pt">
            2. Se pretender esclarecer alguma dúvida ou pedir alguma informação sobre este estudo, queira por favor contactar-nos através do seguinte endereço de email: msbarros.gis@gmail.com (Matheus Siqueira Barros).
          </span>

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
                <button type="button" id="btn_close_modal_intro" class="btn btn-primary btn-next" style="height:auto;width:auto;font-size:12px;">
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

if (!mobileDevice){
  document.getElementById("message_mobile").style.display="none";
}

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

$("#btn_close_modal_intro").on("click", function () {
  var statuscbx = $('input[type=checkbox][name=cbxAgreement]').prop('checked');
  if(statuscbx){
    $('#modal_1_intro').modal('hide');
    window.location.href = 'map/eimg_draw.php';
  }else{
    if(siteLang=="en") var str = "You need to agree with the terms and conditions before proceed";
    if(siteLang=="pt") var str = "Você precisa concordar com os termos e condições antes de prosseguir";
    alert(str);
  }

});

$('input[type=radio][name=language_switch]').change(function() {
  cbxLangChange(this.value);
});

</script>

</body>
</html>
