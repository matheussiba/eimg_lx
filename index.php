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

  <button onclick="openModal('exampleModalCenter')"> MODAL INDEX </button>
  <button onclick="openModal('exampleQuest')"> MODAL Questionairre </button>


  <!-- Modal -->
  <div class="modal fade" id="exampleQuest" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true" data-backdrop="false">

    <!-- Add .modal-dialog-centered to .modal-dialog to vertically center the modal -->
    <div class="modal-dialog modal-lg" role="document">
      <div class="modal-content">

        <div class="modal-header modal-header-removeclose" style="padding:5px">
          <h5 class="modal-title" id="exampleModalLabel">Welcome to Evaluative Image of the City</h5>
          <!-- <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button> -->
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



        <div class="container">
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
              <!-- input: -->
            </tbody>
          </table>
        </div>



        </div> <!--/.modal-body -->
        <div class="modal-footer" style="border:none;">
          <div class="float-left" style="color: #A9A9A9; padding-top: 8px">
            1/4
          </div>
          <div class="float-right">
            <button type="button" class="btn btn-primary btn-next" data-dismiss="modal" aria-label="Close"
            langkey="index9" id="home_button">Próximo
          </button>
        </div>
      </div>
      <!--  Logos  -->
      <div class="sidebarContentChild">
        <span><img src="<?php  echo $root_directory?>resources/images/uni/mundus.png" id="logo_mundus" alt="Nova IMS"></span>
        <span><img src="<?php  echo $root_directory?>resources/images/uni/novaims.png" id="logo_nova" alt="Nova IMS"></span>
        <span><img src="<?php  echo $root_directory?>resources/images/uni/wwu.png" id="logo_munster" alt="Münster"></span>
        <span><img src="<?php  echo $root_directory?>resources/images/uni/uji.png" id="logo_uji" alt="UJI"></span>
      </div>

    </div> <!--/.modal-content -->
  </div>
</div>


  <!-- Modal -->
  <div class="modal fade" id="exampleModalCenter" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true" data-backdrop="false">

    <!-- Add .modal-dialog-centered to .modal-dialog to vertically center the modal -->
    <div class="modal-dialog modal-lg" role="document">
      <div class="modal-content">

        <div class="modal-header modal-header-removeclose" style="padding:5px">
          <h5 class="modal-title" id="exampleModalLabel">Welcome to Evaluative Image of the City</h5>
          <!-- <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button> -->
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




        <div class="container">
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
        </div>












        <img src="<?php  echo $root_directory?>resources/images/eimg_logo_1.png" id="logo_munster" style="margin-left: 5px">
        <!--  Project's explanation  -->
        <p>
          <span>Este questionário é parte integrante de um projeto de investigação da Nova Information Management School (NOVA IMS) da Universidade Nova de Lisboa. O objetivo principal é perceber a forma como a perceção do local e as relações sociais do cidadão influenciam a sua participação numa dada área urbana.</span>
        </p>
        <p>
          <span>O preenchimento do questionário demora cerca de 5 minutos e a atividade de mapeamento cerca de 15 minutos, dependendo do número de áreas que se pretenderem assinalar.</span>
        </p>
        <p>
          <b langkey="index2a"></b><b> nº <strike>10</strike>, nº <strike>50</strike>, nº <strike>100</strike>,</b><b langkey="index2b"></b>
        </p>
        <p>
          <span langkey="index3">A sua contribuição apoia os processos participativos da cidade de Lisboa.</span>
        </p>
        <p style="text-align: center; margin-top: 30px; font-weight: bold" langkey="index4">
          Reside em Lisboa?
        </p>
        <div style="text-align: center; margin-bottom: 40px">
          <label class="radio-inline">
            <input type="radio" name="lisbon_home" value="true" checked="checked"> <span langkey="index5"> Sim </span>
          </label>
          <label class=" radio-inline">
            <input type="radio" name="lisbon_home"  value="false"> <span langkey="index6"> Não</span>
          </label>
        </div>

        <p style="font-size: 12px; margin-top: 30px">
          <span langkey="index7 "> Notas:</span>
          <br>
          <span langkey="index8">1.Todos os dados recolhidos neste questionário serão tratados de forma anónima e confidencial e não serão utilizados para fins comerciais ou cedidos a terceiros.</span>
          <br>
          <span langkey="index8a">2. Se pretender esclarecer alguma dúvida ou pedir alguma informação sobre este estudo, queira por favor contactar-nos através do seguinte endereço de email: acedo@novaims.unl.pt (Albert Acedo Sánchez)</span> <span langkey="index8b"> ou visite o nosso</span><span> <a
            class="link-secondary" href="http://www.engagingeographies.com/blog">blog</a>.</span>
            <br>
          </p>

        </div> <!--/.modal-body -->
        <div class="modal-footer" style="border:none;">
          <div class="float-left" style="color: #A9A9A9; padding-top: 8px">
            1/4
          </div>
          <div class="float-right">
            <button type="button" class="btn btn-primary btn-next" data-dismiss="modal" aria-label="Close"
            langkey="index9" id="home_button">Próximo
          </button>
        </div>
      </div>
      <!--  Logos  -->
      <div class="sidebarContentChild">
        <span><img src="<?php  echo $root_directory?>resources/images/uni/mundus.png" id="logo_mundus" alt="Nova IMS"></span>
        <span><img src="<?php  echo $root_directory?>resources/images/uni/novaims.png" id="logo_nova" alt="Nova IMS"></span>
        <span><img src="<?php  echo $root_directory?>resources/images/uni/wwu.png" id="logo_munster" alt="Münster"></span>
        <span><img src="<?php  echo $root_directory?>resources/images/uni/uji.png" id="logo_uji" alt="UJI"></span>
      </div>

    </div> <!--/.modal-content -->
  </div>
</div>

<!-- ###############  Div that contains the header ############### -->
<div id="header" class="col-md-12">
  <p class="text-center"><?php echo $header ?> </p>
</div>


<script>
//  ********* Mobile Device parameters and Function *********
var mobileDevice = false;
if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)){
  /*### DESCRIPTION: Check if the web application is being seen in a mobile device   */
  mobileDevice = true;
};
if(mobileDevice){
  /*### DESCRIPTION: Lock the screen of a mobile device in a landscape mode   */
  if("orientation" in screen) {
    var orientation_str = screen.orientation.type;
    var orientation_array = orientation_str.split("-");
    if( orientation_array[0] == "portrait"){
      // NEEDTO: Show this message in a modal div
      alert("Change the orientation of the device to: landscape");
    }
  }
}
$( window ).on( "orientationchange", function( event ) {
  /* ### FUNCTION DESCRIPTION: ADDDESCRIPTION  */
  //Do things based on the orientation of the mobile device
  if(mobileDevice){
    if("orientation" in screen) {
      var orientation_array = (screen.orientation.type).split("-");
      if( orientation_array[0] == "portrait"){
        // NEEDTO: Show this message in a modal div
        alert("Change the orientation of the device to: landscape");
      }else{  //landscape mode
        //Reloads the page
        //location.reload();
        console.log( orientation_array[0] );
      }
    }
  }
});//END $( window ).on( "orientationchange", ())

function openModal(id){
  $('#'+id).modal('show');
}
//  ********* Create Map *********
$(document).ready(function(){
  // $('#exampleModalCenter').modal('show');

  $("#btnRedirectPage").on("click", function () {
    //var text = $(this).attr("text");
    //alert("Clicked");
    window.location.href = 'eimg_draw.php';
  });
});

</script>

<style>
 .slider {

width: 100%;
 }
</style>

</body>
</html>
