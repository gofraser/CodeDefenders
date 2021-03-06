<%@ page import="org.codedefenders.validation.CodeValidator" %>
<%@ page import="static org.codedefenders.validation.CodeValidator.DEFAULT_NB_ASSERTIONS" %>
<% String pageTitle = "Create Battleground"; %>
<%@ include file="/jsp/header_main.jsp" %>
<%
    List<GameClass> gameClasses = DatabaseAccess.getAllClasses();
    if(gameClasses.isEmpty()) {
        if (AdminDAO.getSystemSetting(AdminSystemSettings.SETTING_NAME.CLASS_UPLOAD).getBoolValue()) {
%>
<div id="creategame" class="container">
    <p>
        Before you can start games, please <a href="games/upload" class="text-center new-account">upload a class under test</a>.
    </p>
</div>
<%
        } else {
%>
<div id="creategame" class="container">
    <p>
        Games can only be started once at least one class under test has been uploaded.
    </p>
</div>
<%
        }
    } else {

%>
<div id="creategame" class="container">
    <form id="create" action="<%=request.getContextPath() %>/multiplayer/games" method="post"
          class="form-creategame-mp">
        <input type="hidden" name="formType" value="createGame">
        <table class="tableform">
            <tr>
                <td width="25%">Java Class</td>
                <td>
                    <select name="class" class="form-control selectpicker" data-size="large">
                        <% for (GameClass c : DatabaseAccess.getAllClasses()) { %>
                        <option value="<%=c.getId()%>"><%=c.getAlias()%>
                        </option>
                        <%}%>
                    </select>
                </td>
                <td width="17%">
                    <a href="games/upload" class="text-center new-account">Upload Class</a>
                </td>
            </tr>
            <!--
            <tr>
                <td>Line Coverage Goal</td><td><input class="ws-2" type="number" value="0.8" min="0.1" max="1.0" step="0.1" name="line_cov" style="text-align: center"/></td>
            </tr>
            <tr>
                <td>Mutation Goal</td><td><input class="ws-2" type="number" value="0.5" min="0.1" max="1.0" step="0.1" name="mutant_cov" style="text-align: center"></td>
            </tr>
            -->
            <tr>
                <td>Level</td>
                <td>
                    <input type="checkbox" id="level" name="level" class="form-control" data-size="large"
                           data-toggle="toggle" data-on="Easy" data-off="Hard" data-onstyle="info"
                           data-offstyle="warning">
                </td>
            </tr>
            <% /*
				Integer.parseInt(request.getParameter("defenderLimit")),
				Integer.parseInt(request.getParameter("attackerLimit")),
                Integer.parseInt(request.getParameter("minDefenders")),
                Integer.parseInt(request.getParameter("minAttackers")),
                Long.parseLong(request.getParameter("finishTime")),
                MultiplayerGame.State.CREATED.name());

                */
            %>
            <tr>
                <td>Defenders</td>
                <td class="crow fly">
                    <label style="font-weight: normal;" for="minDefenders">Min</label>
                    <input type="number" name="minDefenders" id="minDefenders" value="2"/>
                    <label style="font-weight: normal;" for="defenderLimit">Max</label>
                    <input type="number" value="4" id="defenderLimit" name="defenderLimit"/>
                </td>
            </tr>
            <tr>
                <td>Attackers</td>
                <td class="crow fly">
                    <label style="font-weight: normal;" for="minAttackers">Min</label>
                    <input type="number" value="2" name="minAttackers" id="minAttackers"/>
                    <label style="font-weight: normal;" for="attackerLimit">Max</label>
                    <input type="number" value="4" name="attackerLimit" id="attackerLimit"/>
                </td>
            </tr>
            <tr>
                <td>Start Time</td>
                <td>
                    <div class="crow">
                        <input type="hidden" id="startTime" name="startTime"/>
                        <span class="alert alert-danger" id="startTimeWarning" style="display: none">Start time must be later than today's date!</span>

                        <input class="ws-5" name="start_dateTime" id="start_dateTime"/>
                        <div class="ws-7 nest">
                            <input class="ws-1" type="text" name="start_hours" id="start_hours"
                                   style="text-align: center;"/>
                            <span>:</span>
                            <input class="ws-1" type="text" name="start_minutes" id="start_minutes"
                                   style="text-align: center;"/>
                        </div>
                    </div>
                    <script>
                        $(document).ready(function () {
                            var initialStartDate = new Date();
                            $("#startTime").val(initialStartDate.getTime());
                            $("#start_dateTime").datepicker({dateFormat: "yy/mm/dd"});
                            $("#start_dateTime").datepicker("setDate", initialStartDate);
                            $("#start_hours").val(initialStartDate.getHours());
                            var mins = initialStartDate.getMinutes();
                            if (mins < 10) {
                                // add leading zero to minute representation
                                mins = "0" + mins;
                            }
                            $("#start_minutes").val(mins);
                        });

                        $("#start_dateTime").on("change", function () {
                            updateStartTimestamp();
                        });

                        // check whether the selection contains more hours than one day
                        $("#start_hours").on("change", function () {
                            var hours = $("#start_hours").val();
                            if (hours < 0 || hours > 23) {
                                $("#start_hours").val(0);
                            }
                            updateStartTimestamp();
                        });

                        $("#start_minutes").on("change", function () {
                            var mins = $("#start_minutes").val();
                            // check whether the selection contains more minutes than one hour
                            if (mins < 0 || mins > 59) {
                                $("#start_minutes").val("00");
                            } else if (mins < 10) {
                                // add leading zero to minute representation
                                $("#start_minutes").val("0" + mins);
                            }
                            updateStartTimestamp();
                        });

                        // update the input of hidden startTime field with selected timestamp
                        var updateStartTimestamp = function () {
                            var timestamp = new Date($("#start_dateTime").val()).getTime();
                            timestamp += parseInt(($("#start_hours").val()) * 60 * 60 * 1000);
                            timestamp += parseInt($("#start_minutes").val()) * 60 * 1000;

                            var finishTime = new Date($("#finish_dateTime").val()).getTime();

                            // check whether the selected start time is before finish date
                            if (finishTime < timestamp) {
                                //display error message above start_dateTime field when finish time is behind selected one
                                document.getElementById("finishTimeWarning").style.display = "inline";
                                // disable submit button
                                document.getElementById("createButton").disabled = true;
                            } else {
                                // error messages disappear due to right input
                                document.getElementById("startTimeWarning").style.display = "none";
                                document.getElementById("finishTimeWarning").style.display = "none";
                                // enable submit button
                                document.getElementById("createButton").disabled = false;
                            }
                            $("#startTime").val(timestamp);
                        };

                    </script>
                </td>
            <tr>
                <td>Finish Time</td>
                <td>
                    <div class="crow">
                        <input type="hidden" id="finishTime" name="finishTime"/>
                        <span class="alert alert-danger" id="finishTimeWarning" style="display: none">Finish time must be later than selected start time!</span>
                        <input class="ws-5" name="finish_dateTime" id="finish_dateTime"/>
                        <div class="ws-7 nest">
                            <input class="ws-1" type="text" name="finish_hours" id="finish_hours"
                                   style="text-align: center;"/>
                            <span>:</span>
                            <input class="ws-1" type="text" name="finish_minutes" id="finish_minutes"
                                   style="text-align: center;"/>
                        </div>
                    </div>
                    <script>
                        $(document).ready(function () {
                            var initialFinishDate = new Date();
                            // add default 3 days to initial finish date
                            initialFinishDate.setDate(initialFinishDate.getDate() + 3);
                            $("#finishTime").val(initialFinishDate.getTime());
                            $("#finish_dateTime").datepicker({dateFormat: "yy/mm/dd"});
                            $("#finish_dateTime").datepicker("setDate", initialFinishDate);
                            $("#finish_hours").val(initialFinishDate.getHours());
                            var mins = initialFinishDate.getMinutes();
                            if (mins < 10) {
                                mins = "0" + mins;
                            }
                            $("#finish_minutes").val(mins);
                        });

                        // check whether the selected date is before today
                        $("#finish_dateTime").on("change", function () {
                            updateFinishTimestamp();
                        });

                        // check whether the selection contains more hours than one day
                        $("#finish_hours").on("change", function () {
                            var hours = $("#finish_hours").val();
                            if (hours < 0 || hours > 23) {
                                $("#finish_hours").val(0);
                            }
                            updateFinishTimestamp();
                        });

                        // check whether the selection contains more minutes than one hour
                        $("#finish_minutes").on("change", function () {
                            var mins = $("#finish_minutes").val();
                            if (mins < 0 || mins > 59) {
                                $("#finish_minutes").val("00");
                            } else if (mins < 10) {
                                // add leading zero to minute representation
                                $("#finish_minutes").val("0" + mins);
                            }
                            updateFinishTimestamp();
                        });

                        var updateFinishTimestamp = function () {
                            var timestamp = new Date($("#finish_dateTime").val()).getTime();
                            timestamp += parseInt(($("#finish_hours").val()) * 60 * 60 * 1000);
                            timestamp += parseInt(($("#finish_minutes").val()) * 60 * 1000);
                            var startTime = parseInt($("#startTime").val());

                            // check whether the selected finish time is later than the start time
                            if (timestamp < startTime) {
                                //display error message above finish_dateTime field
                                document.getElementById("finishTimeWarning").style.display = "inline";
                                // disable submit button
                                document.getElementById("createButton").disabled = true;
                            } else {
                                // error message disappears due to valid input
                                document.getElementById("finishTimeWarning").style.display = "none";
                                // enable submit button
                                document.getElementById("createButton").disabled = false;
                            }
                            $("#finishTime").val(timestamp);
                        };
                    </script>
                </td>
            </tr>
            <tr>
                <td title="Maximum number of assertions per test. Increase this for difficult to test classes.">
                    Max. Assertions per Test
                </td>
                <td>
                    <input class="form-control" type="number" value="<%=DEFAULT_NB_ASSERTIONS%>"
                           name="maxAssertionsPerTest"
                           id="maxAssertionsPerTest" min=1 required/>
                </td>
            </tr>
            <tr>
                <td title="Click the question sign for more information on the levels">
                    Mutant validator
                </td>
                <td>
                    <select id="mutantValidatorLevel" name="mutantValidatorLevel" class="form-control selectpicker"
                            data-size="medium">
                        <%for (CodeValidator.CodeValidatorLevel cvl : CodeValidator.CodeValidatorLevel.values()) {%>
                        <option value=<%=cvl.name()%> <%=cvl.equals(CodeValidator.CodeValidatorLevel.MODERATE) ? "selected" : ""%>>
                        <%=cvl.name().toLowerCase()%>
                        </option>
                        <%}%>
                    </select>
                    <div id="validatorExplanation" class="collapse panel panel-default" style="font-size: 12px;">
                        <%@ include file="/jsp/validator_explanation.jsp" %>
                    </div>
                </td>
                <td>
                    <a data-toggle="collapse" href="#validatorExplanation" style="color:black">
                        <span class="glyphicon glyphicon-question-sign"></span>
                    </a>
                </td>
            </tr>
            <tr>
                <td title="Attackers can mark uncovered lines as equivalent">
                    Mark uncovered lines as equivalent
                </td>
                <td>
                    <input type="checkbox" id="markUncovered" name="markUncovered"
                           class="form-control" data-size="large" data-toggle="toggle" data-on="On" data-off="Off"
                           data-onstyle="primary" data-offstyle="">
                </td>
            </tr>
            <tr>
                <td title="Players can chat with their team and with all players in the game">
                    Chat
                </td>
                <td>
                    <input type="checkbox" id="chatEnabled" name="chatEnabled"
                           class="form-control" data-size="large" data-toggle="toggle" data-on="On" data-off="Off"
                           data-onstyle="primary" data-offstyle="" checked>
                </td>
            </tr>
            <input type="hidden" value="<%=request.getParameter("fromAdmin")%>" name="fromAdmin">
            <tr>
                <td/>
                <td>
                    <button id="createButton" class="btn btn-lg btn-primary btn-block" type="submit" value="Create">
                        Create
                    </button>
                </td>
                <td/>
            </tr>
        </table>
    </form>
</div>
<%
    }
%>
<%@ include file="/jsp/footer.jsp" %>
