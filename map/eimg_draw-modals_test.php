<!-- modal_2_demographics -->
<div class="modal fade" id="modal_2_demographics" tabindex="-1" role="dialog" aria-labelledby="modal_1_introTitle" aria-hidden="true" data-backdrop="false">
  <div class="modal-dialog modal-lg" role="document" style="overflow-y: initial !important">
    <div class="modal-content">
      <div class="modal-header modal-header-removeclose" style="padding:5px">
        <h5 class="modal-title">
          <span class="language-en">Tell a bit about you:</span>
          <span class="language-pt">Diga um pouco sobre você:</span>
        </h5>
      </div>
      <div class="modal-body" style="height: 70vh; overflow-y: auto;">
        <!-- Gender -->
        <div class="card">
          <div class="card-header">
            <span class="language-en">Gender:</span>
            <span class="language-pt">Sexo:</span>
          </div>
          <div class="card-body">
            <div class="container-fluid" style="text-align:center;">
              <div class="row" style="text-align:center;">
                <!-- <div class="col">
                  <label class="radio-inline demographics">
                    <input type="radio" name="user_sex" value="male">
                    <span class="language-en">Male</span>
                    <span class="language-pt">Masculino</span>
                  </label>
                </div>
                <div class="col">
                  <label class="radio-inline demographics">
                    <input type="radio" name="user_sex" value="female">
                    <span class="language-en">Female</span>
                    <span class="language-pt">Feminino</span>
                  </label>
                </div> -->
                <div class="col">
                  <span class="language-en">
                    <select id="user_sex-en">
                      <option value="">Select</option>
                      <option value="f">Female</option>
                      <option value="m">Male</option>
                    </select>
                  </span>
                  <span class="language-pt">
                    <select id="user_sex-pt">
                      <option value="">Selecionar</option>
                      <option value="f">Feminino</option>
                      <option value="m">Masculino</option>
                    </select>
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Age -->
        <div class="card">
          <div class="card-header">
            <span class="language-en">Age Group:</span>
            <span class="language-pt">Idade:</span>
          </div>
          <!-- <div class="card-body">
            <div class="container-fluid" style="text-align:center;">
              <div class="row" style="text-align:center;">
                <div class="col">
                  <label class="radio-inline demographics" style="padding:0 10px 0 10px;">
                    <input type="radio" name="user_age" value="less18">
                    <span class="language-en">Under 18</span>
                    <span class="language-pt">Menor que 18</span>
                  </label>
                </div>
                <div class="col">
                  <label class="radio-inline demographics" style="padding:0 5px 0 5px;">
                    <input type="radio" name="user_age" value="18-24"> 18-24
                  </label>
                </div>
                <div class="col">
                  <label class="radio-inline demographics" style="padding:0 5px 0 5px;">
                    <input type="radio" name="user_age" value="25-34"> 25-34
                  </label>
                </div>
                <div class="col">
                  <label class="radio-inline demographics" style="padding:0 5px 0 5px;">
                    <input type="radio" name="user_age" value="35-44"> 35-44
                  </label>
                </div>
                <div class="col">
                  <label class="radio-inline demographics" style="padding:0 5px 0 5px;">
                    <input type="radio" name="user_age" value="45-54"> 45-54
                  </label>
                </div>
                <div class="col">
                  <label class="radio-inline demographics" style="padding:0 5px 0 5px;">
                    <input type="radio" name="user_age" value="55-64"> 55-64
                  </label>
                </div>
                <div class="col">
                  <label class="radio-inline demographics" style="padding:0 5px 0 5px;">
                    <input type="radio" name="user_age" value="over65">
                    <span class="language-en">Over 65</span>
                    <span class="language-pt">Maior que 65</span>
                  </label>
                </div>
              </div>
            </div>
          </div> -->
          <div class="card-body">
            <div class="container-fluid" style="text-align:center;">
              <div class="row" style="text-align:center;">
                <div class="col">
                  <span class="language-en">
                    <select id="user_age-en">
                      <option value="">Select</option>
                      <option value="<35">Less than 35 years old</option>
                      <option value="35–50">35–50</option>
                      <option value=">50">More than 50 years old</option>
                    </select>
                  </span>
                  <span class="language-pt">
                    <select id="user_age-pt">
                      <option value="">Selecionar</option>
                      <option value="<35">Menos que 35 anos</option>
                      <option value="35–50">35–50</option>
                      <option value=">50">More than 50 anos</option>
                    </select>
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- School -->
        <div class="card">
          <div class="card-header">
            <span class="language-en">School level:</span>
            <span class="language-pt">Escolaridade:</span>
          </div>
          <div class="card-body">
            <div class="container-fluid" style="text-align:center;">
              <div class="row" style="text-align:center;">
                <div class="col">
                  <span class="language-en">
                    <select id="user_school-en">
                      <option value="">Select</option>
                      <option value="<18">Under 18</option>
                    </select>
                  </span>
                  <span class="language-pt">
                    <select id="user_school-pt">
                      <option value="">Selecionar</option>
                      <option value="<18">Abaixo de 18</option>
                    </select>
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- job -->
        <div class="card">
          <div class="card-header">
            <span class="language-en">Profession:</span>
            <span class="language-pt">Profissão:</span>
          </div>
          <div class="card-body">
            <div class="container-fluid" style="text-align:center;">
              <div class="row" style="text-align:center;">
                <div class="col">
                  <span class="language-en">
                    <select id="user_job-en">
                      <option value="">Select</option>
                      <option value="employed_worker">Employed worker</option>
                      <option value="freelance">Freelance</option>
                      <option value="retired">Retired</option>
                      <option value="student">Student</option>
                      <option value="unemployed">Unemployed</option>
                      <option value="other">Other</option>
                    </select>
                  </span>
                  <span class="language-pt">
                    <select id="user_job-pt">
                      <option value="">Selecionar</option>
                      <option value="employed_worker">Empregado(a)</option>
                      <option value="freelance">Freelance</option>
                      <option value="retired">Reformado(a)</option>
                      <option value="student">Estudante</option>
                      <option value="unemployed">Desempregado(a)</option>
                      <option value="other">Outra</option>
                    </select>
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- income -->
        <div class="card">
          <div class="card-header">
            <span class="language-en">Household monthly income (euros):</span>
            <span class="language-pt">Renda mensal domiciliar (euros):</span>
          </div>
          <div class="card-body">
            <div class="container-fluid" style="text-align:center;">
              <div class="row" style="text-align:center;">
                <div class="col">
                  <span class="language-en">
                    <select id="user_income-en">
                      <option value="">Select</option>
                      <option value="<1000">Less than 1000</option>
                      <option value="1000–1499">1000–1499</option>
                      <option value="1500–1999">1500–1999</option>
                      <option value="2000–2999">2000–2999</option>
                      <option value="3000–4999">3000–4999</option>
                      <option value=">5000">More than 5000</option>
                      <option value="NA">I prefer not to answer</option>
                    </select>
                  </span>
                  <span class="language-pt">
                    <select id="user_income-pt">
                      <option value="">Selecionar</option>
                      <option value="<1000">Menos que 1000</option>
                      <option value="1000–1499">1000–1499</option>
                      <option value="1500–1999">1500–1999</option>
                      <option value="2000–2999">2000–2999</option>
                      <option value="3000–4999">3000–4999</option>
                      <option value=">5000">Mais que 5000</option>
                      <option value="NA">Prefiro não responder</option>
                    </select>
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>


      </div> <!-- modal body -->
      <div class="modal-footer" style="border:none;">
        <div class="container-fluid">
          <div class="col">
            <div>
              <button type="button" id="btn_close_modal_demographics" class="btn btn-primary btn-block">
                <span class="language-en">Start</span>
                <span class="language-pt">Começar</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div> <!--/.modal-content -->
  </div> <!--/.modal-dialog -->
</div>  <!--/.modal -->



<!-- modal_3_sus -->



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
