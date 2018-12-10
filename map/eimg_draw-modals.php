<!-- modal_2_demographics -->
<div class="modal fade" id="modal_2_demographics" tabindex="-1" role="dialog" aria-labelledby="modal_1_introTitle" aria-hidden="true" data-backdrop="false">
  <div class="modal-dialog modal-lg" role="document" style="overflow-y: initial !important">
    <div class="modal-content">
      <div class="modal-header modal-header-removeclose" style="padding:5px">
        <h5 class="modal-title">
          <span class="language-en">Tell a bit about you:</span>
          <span class="language-pt">Diga um pouco sobre voce:</span>
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
                <div class="col">
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
          </div>
        </div> -->

          <div class="card-body">
            <div class="container-fluid" style="text-align:center;">
              <div class="row" style="text-align:center;">
                <div class="col">
                  <span class="language-en">
                    <select>
                      <option value="volvo">NA</option>
                      <option value="volvo">Under 18</option>
                      <option value="volvo">18-24 </option>
                      <option value="volvo">25-34 </option>
                      <option value="volvo">35-44 </option>
                      <option value="volvo">45-54</option>
                      <option value="volvo">55-64</option>
                      <option value="volvo">Over 65</option>
                    </select>
                  </span>
                  <span class="language-pt">
                    <select>
                      <option value="volvo">NA</option>
                      <option value="volvo">Abaixo de 18</option>
                      <option value="volvo">18-24 </option>
                      <option value="volvo">25-34 </option>
                      <option value="volvo">35-44 </option>
                      <option value="volvo">45-54</option>
                      <option value="volvo">55-64</option>
                      <option value="volvo">Acima de 65</option>
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
            <span class="language-pt">Grau de escolaridade:</span>
          </div>
          <div class="card-body">

            <div class="container-fluid" style="text-align:center;">
              <div class="row" style="text-align:center;">
                <div class="col">
                  <span class="language-en">
                    <select>
                      <option value="volvo">NA</option>
                      <option value="volvo">Less than a high school diploma</option>
                      <option value="volvo">High school degree or equivalent (e.g. GED)</option>
                      <option value="volvo">Some college, no degree</option>
                      <option value="volvo">Associate degree (e.g. AA, AS)</option>
                      <option value="volvo">Bachelor’s degree (e.g. BA, BS)</option>
                      <option value="volvo">Master’s degree (e.g. MA, MS, MEd)</option>
                      <option value="volvo">Professional degree (e.g. MD, DDS, DVM)</option>
                      <option value="volvo">Doctorate (e.g. PhD, EdD)</option>
                    </select>
                  </span>
                  <span class="language-pt">
                    <select>
                      <option value="volvo">NA</option>
                      <option value="volvo">NA</option>
                      <option value="volvo">NA</option>
                      <option value="volvo">NA</option>
                      <option value="volvo">NA</option>
                      <option value="volvo">NA</option>
                      <option value="volvo">NA</option>
                      <option value="volvo">NA</option>
                      <option value="volvo">NA</option>
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
          <div class="col" style="text-align:right;">
            <div>
              <button type="button" id="btn_go_modal_3" class="btn btn-primary btn-next" style="height:auto;width:auto;font-size:12px;">
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
