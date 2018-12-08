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
function openModal(id){
  $('#'+id).modal('show');
}

$('input[type=radio][name=language_switch]').change(function() {
    if (this.value == 'en') {
      siteLang='en';
      $('.language-pt').hide(); // hides
      $('.language-en').show(); // Shows
    }
    else if (this.value == 'pt') {
      siteLang='pt';
      $('.language-en').hide(); // hides
      $('.language-pt').show(); // Shows
    }
});
$('input[type=radio][name=language_switch]').change(function() {
    if (this.value == 'en') {
      siteLang='en';
      $('.language-pt').hide(); // hides
      $('.language-en').show(); // Shows
    }
    else if (this.value == 'pt') {
      siteLang='pt';
      $('.language-en').hide(); // hides
      $('.language-pt').show(); // Shows
    }
});

</script>

<!-- <button onclick="openModal('exampleModalCenter')"> MODAL INDEX </button> -->
<button onclick="openModal('exampleQuest')"> MODAL Questionairre </button>

<!-- Modal -->
<div class="modal fade" id="exampleModalCenter" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true" data-backdrop="false">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header modal-header-removeclose" style="padding:5px">
        <h5 class="modal-title" id="exampleModalLabel">Welcome to Evaluative Image of the City</h5>
        <div class="pull-right">
          <label class="radio-inline" >
            <input type="radio" name="language_switch" value="pt" checked>
            <img src="<?php  echo $root_directory?>resources/images/flags/portugal.png" style="margin-left: 5px">
          </label>
          <label class="radio-inline">
            <input type="radio" name="language_switch" value="en">
            <img src="<?php  echo $root_directory?>resources/images/flags/united_kingdom.png" style="margin-left: 5px">
          </label>
        </div>
      </div>

      <div class="modal-body">
        <img src="<?php  echo $root_directory?>resources/images/eimg_logo_1.png" id="logo_munster" style="margin-left: 5px">
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
              <div class="col-1" style="color: #A9A9A9; padding-top: 8px">
                1/4
              </div>
              <div class="col" style="text-align:center;padding-top: 8px; font-size: 13px;">
                <input type="checkbox" name="cbxAgreement">

                <span class="language-en">I agree to take part in the above study.</span>
                <span class="language-pt">Eu aceito a participar do estudo mencionado acima.</span>
              </div>
              <div class="col-3">
                <!-- <button type="button" class="btn btn-primary btn-next" data-dismiss="modal" aria-label="Close"
                id="home_button">Próximo
              </button> -->
              <div style="text-align:right;">
                <button type="button" class="btn btn-primary btn-next" style="height:auto;width:auto;font-size:12px;" id="modal_intro_next">
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
            <span><img src="<?php  echo $root_directory?>resources/images/uni/mundus.png" id="logo_mundus" alt="Nova IMS"></span>
          </div>
          <div class="col">
            <span><img src="<?php  echo $root_directory?>resources/images/uni/novaims.png" id="logo_nova" alt="Nova IMS"></span>
          </div>
          <div class="col">
            <span><img src="<?php  echo $root_directory?>resources/images/uni/wwu.png" id="logo_munster" alt="Münster"></span>
          </div>
          <div class="col">
            <span><img src="<?php  echo $root_directory?>resources/images/uni/uji.png" id="logo_uji" alt="UJI"></span>
          </div>
        </div>
      </div>
    </div> <!--/.modal-content -->
  </div> <!--/.modal-dialog -->
</div>  <!--/.modal -->




        <!-- <div class="container">
            <div class="col-md-2">
            </div>
            <div class="col-md-8">
                <div class="card ">
                    <div class="card-header">Personal Info</div>
                    <div class="card-block">
                        Gender:
                        <br />
                        <div class="btn-group" data-toggle="buttons">
                            <label class="btn btn-secondary">
                                <input type="radio" autocomplete="off" /> Male
                            </label>
                            <label class="btn btn-secondary">
                                <input type="radio" autocomplete="off" /> Female
                            </label>
                        </div>
                        <br />
                        <br />

                        Age Group:
                        <br />
                        <div class="btn-group" data-toggle="buttons">
                            <label class="btn btn-secondary">
                                <input type="radio" autocomplete="off" />Under 18
                            </label>
                            <label class="btn btn-secondary">
                                <input type="radio" autocomplete="off" />18-25
                            </label>
                            <label class="btn btn-secondary">
                                <input type="radio" autocomplete="off" />25-50
                            </label>
                            <label class="btn btn-secondary">
                                <input type="radio" autocomplete="off" />Over 50
                            </label>
                        </div>
                        <br />
                        <br />
                    </div>
                </div>
            </div>
        </div> -->



<!-- <div class="container">
  <h2>Survey</h2>
  <p>Please complete the survey</p>
  <table class="table table-bordered">
    <thead>
      <tr>
        <th></th>
        <th></th>
        <th>Strongly disagree</th>
        <th>Disagree</th>
        <th>Neutral</th>
        <th>Agree</th>
        <th>Strongly agree</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>1.</td>
        <td>I think that I would like to use this website frequently</td>
        <td><input type="radio" name="quest1" class="survey_sus" value="strong_disagree"></td>
        <td><input type="radio" name="quest1" class="survey_sus" value="disagree"></td>
        <td><input type="radio" name="quest1" class="survey_sus" value="neutral"></td>
        <td><input type="radio" name="quest1" class="survey_sus" value="agree"></td>
        <td><input type="radio" name="quest1" class="survey_sus" value="strong_agree"></td>
      </tr>
      <tr>
        <td>2.</td>
        <td>I would imagine that most people would learn to use this website very quickly</td>
        <td><input type="radio" name="quest2" class="survey_sus" value="strong_disagree"></td>
        <td><input type="radio" name="quest2" class="survey_sus" value="disagree"></td>
        <td><input type="radio" name="quest2" class="survey_sus" value="neutral"></td>
        <td><input type="radio" name="quest2" class="survey_sus" value="agree"></td>
        <td><input type="radio" name="quest2" class="survey_sus" value="strong_agree"></td>
      </tr>
      <tr>
        <td>3.</td>
        <td>I needed to learn a lot of things before I could get going with this website.</td>
        <td><input type="radio" name="quest3" class="survey_sus" value="strong_disagree"></td>
        <td><input type="radio" name="quest3" class="survey_sus" value="disagree"></td>
        <td><input type="radio" name="quest3" class="survey_sus" value="neutral"></td>
        <td><input type="radio" name="quest3" class="survey_sus" value="agree"></td>
        <td><input type="radio" name="quest3" class="survey_sus" value="strong_agree"></td>
      </tr>
      <tr>
        <td>12.</td>
        <td>I needed to learn a lot of things before I could get going with this website.</td>
        <td><input type="radio" name="quest3" class="survey_sus" value="strong_disagree"></td>
        <td><input type="radio" name="quest3" class="survey_sus" value="disagree"></td>
        <td><input type="radio" name="quest3" class="survey_sus" value="neutral"></td>
        <td><input type="radio" name="quest3" class="survey_sus" value="agree"></td>
        <td><input type="radio" name="quest3" class="survey_sus" value="strong_agree"></td>
      </tr>
      input: would people like this way to send
      input: would people like this way to send Would you like this evaluative approach to send feedback to your city council?
    </tbody>
  </table>
</div> -->

<!-- ###############  Div that contains the header ############### -->
<div id="header" class="col-md-12">
  <p class="text-center"><?php echo $header ?> </p>
</div>


<script>
openModal('exampleModalCenter');

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
function checkCookie() {
  var username = getCookie("username");
  if (username != "") {
   alert("Welcome again " + username);
  } else {
    username = prompt("Please enter your name:", "");
    if (username != "" && username != null) {
      setCookie("username", username, 365);
    }
  }
}

$("#btnRedirectPage").on("click", function () {
  window.location.href = 'eimg_draw.php';
});

</script>

</body>
</html>
