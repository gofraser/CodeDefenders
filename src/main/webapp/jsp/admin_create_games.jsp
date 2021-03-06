<%@ page import="org.apache.commons.collections.ListUtils" %>
<%@ page import="org.codedefenders.AdminCreateGames" %>
<%@ page import="org.codedefenders.GameLevel" %>
<%@ page import="org.codedefenders.GameState" %>
<%@ page import="org.codedefenders.leaderboard.Entry" %>
<%@ page import="org.codedefenders.validation.CodeValidator" %>
<%@ page import="org.joda.time.DateTime" %>
<%@ page import="org.joda.time.format.DateTimeFormat" %>
<%@ page import="org.joda.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<% String pageTitle = null; %>
<%@ include file="/jsp/header_main.jsp" %>
<div class="full-width">
    <ul class="nav nav-tabs">
        <li class="active"><a>Create Games</a></li>
        <li><a href="<%=request.getContextPath()%>/admin/monitor"> Monitor Games</a></li>
        <li><a href="<%=request.getContextPath()%>/admin/users"> Manage Users</a></li>
        <li><a href="<%=request.getContextPath()%>/admin/settings">System Settings</a></li>
    </ul>
    <form id="insertGames" action="admin" method="post">
        <input type="hidden" name="formType" value="insertGames"/>
        <h3>Staged Games</h3>
        <%
            List<MultiplayerGame> createdGames = (List<MultiplayerGame>) session.getAttribute(AdminCreateGames.CREATED_GAMES_LISTS_SESSION_ATTRIBUTE);
            List<List<Integer>> attackerIdsList = (List<List<Integer>>) session.getAttribute(AdminCreateGames.ATTACKER_LISTS_SESSION_ATTRIBUTE);
            List<List<Integer>> defenderIdsList = (List<List<Integer>>) session.getAttribute(AdminCreateGames.DEFENDER_LISTS_SESSION_ATTRIBUTE);
            if (createdGames == null || createdGames.isEmpty()) {
        %>
        <div class="panel panel-default">
            <div class="panel-body" style="    color: gray;    text-align: center;">
                There are currently no staged multiplayer games.
            </div>
        </div>
        <%
        } else {
        %>
        <table id="tableCreatedGames"
               class="table table-hover table-responsive table-paragraphs games-table dataTable display">
            <thead>
            <tr>
                <th><input type="checkbox" id="selectAllTempGames"
                           onchange="document.getElementById('insert_games_btn').disabled = !this.checked;
                           document.getElementById('delete_games_btn').disabled = !this.checked">
                </th>
                <th>ID</th>
                <th>Class</th>
                <th>Level</th>
                <th>Starting</th>
                <th>Finishing</th>
                <th>Players
                    <div class="row">
                        <div class="col-sm-2">Name</div>
                        <div class="col-sm-4">Last Role</div>
                        <div class="col-sm-3">Score</div>
                        <a id="togglePlayersCreated" class="btn btn-sm btn-default">
                            <span id = "togglePlayersCreatedSpan" class="glyphicon glyphicon-alert"></span>
                        </a>
                    </div>
                </th>
            </tr>

            </thead>
            <tbody>
            <%
                for (int i = 0; i < createdGames.size(); ++i) {
                    MultiplayerGame g = createdGames.get(i);
                    List<Integer> attackerIds = attackerIdsList.get(i);
                    List<Integer> defenderIds = defenderIdsList.get(i);
                    GameClass CUT = g.getCUT();

            %>
            <tr>
                <td>
                    <input type="checkbox" name="selectedTempGames" id="selectedTempGames" value="<%= i%>" onchange=
                            "document.getElementById('insert_games_btn').disabled = !areAnyChecked('selectedTempGames');
                            document.getElementById('delete_games_btn').disabled = !areAnyChecked('selectedTempGames');
                            setSelectAllCheckbox('selectedTempGames', 'selectAllTempGames');">
                </td>
                <td><%=i%>
                </td>
                <td class="col-sm-2">
                    <a href="#" data-toggle="modal" data-target="#modalCUTFor<%=g.getId()%>">
                        <%=CUT.getAlias()%>
                    </a>
                    <div id="modalCUTFor<%=g.getId()%>" class="modal fade" role="dialog" style="text-align: left;">
                        <div class="modal-dialog">
                            <!-- Modal content-->
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                                    <h4 class="modal-title"><%=CUT.getAlias()%>
                                    </h4>
                                </div>
                                <div class="modal-body">
                                    <pre class="readonly-pre"><textarea class="readonly-textarea classPreview"
                                                                        id="sut<%=g.getId()%>" name="cut<%=g.getId()%>"
                                                                        cols="80"
                                                                        rows="30"><%=CUT.getAsString()%></textarea></pre>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </td>
                <td><%= g.getLevel().name() %>
                </td>
                <td class="col-sm-2"><%= g.getStartDateTime() %>
                </td>
                <td class="col-sm-2"><%= g.getFinishDateTime() %>
                </td>
                <td class="col-sm-4">
                    <div id="playersTableHidden" style="color: lightgray;"> (hidden)</div>
                    <table id="playersTableCreated" hidden>
                        <%
                            List<Integer> attackerAndDefenderIds = ListUtils.union(attackerIds, defenderIds);
                            for (int id : attackerAndDefenderIds) {
                                String userName = DatabaseAccess.getUser(id).getUsername();
                                //Timestamp ts = AdminDAO.getLastLogin(aid);
                                Role lastRole = AdminDAO.getLastRole(id);
                                Entry score = AdminDAO.getScore(id);
                                int totalScore = score.getTotalPoints();
                                String color = attackerIds.contains(id) ? "#edcece" : "#ced6ed";
                        %>
                        <tr style="background: <%= color %>">
                            <td class="col-sm-1"><%= userName %>
                            </td>
                            <td class="col-sm-1"><%= lastRole %>
                            </td>
                            <td class="col-sm-1"><%= totalScore %>
                            </td>
                            <td>
                                <button class="btn btn-sm btn-primary"
                                        value="<%=String.valueOf(i) + "-" + String.valueOf(id)%>"
                                        name="tempGameUserSwitchButton">
                                    <span class="glyphicon glyphicon-transfer"></span>
                                </button>
                            </td>
                            <td>
                                <button class="btn btn-sm btn-danger"
                                        value="<%=String.valueOf(i) + "-" + String.valueOf(id)%>"
                                        name="tempGameUserRemoveButton">
                                    <span class="glyphicon glyphicon-trash"></span>
                                </button>
                            </td>
                        </tr>
                        <% } %>
                    </table>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <button class="btn btn-md btn-primary" type="submit" name="games_btn" id="insert_games_btn"
                disabled value="insert Games">
            Create games
        </button>
        <button class="btn btn-md btn-danger" type="submit" name="games_btn" id="delete_games_btn"
                onclick="return confirm('Are you sure you want to discard the selected Games?');"
                disabled value="delete Games">
            Discard games
        </button>
        <% }
        %>

    </form>
    <form id="users" action="admin" method="post">
        <input type="hidden" name="formType" value="createGame">

        <h3>Unassigned Users</h3>
        <table id="tableAddUsers"
               class="table table-hover table-responsive table-paragraphs games-table dataTable display">
            <thead>
            <tr>
                <th><input type="checkbox" id="selectAllUsers"
                           onchange="document.getElementById('submit_users_btn').disabled = !this.checked">
                </th>
                <th>User ID</th>
                <th>User</th>
                <th>Last Role</th>
                <th>Total Score</th>
                <th>Last Login</th>
                <th>Add to existing Game</th>
            </tr>
            </thead>
            <tbody>

            <%
                List<MultiplayerGame> availableGames = AdminDAO.getAvailableGames();
                createdGames = (List<MultiplayerGame>) session.getAttribute(AdminCreateGames.CREATED_GAMES_LISTS_SESSION_ATTRIBUTE);
                List<List<String>> unassignedUsersInfo = AdminCreateGames.getUnassignedUsers(attackerIdsList, defenderIdsList);
                if (unassignedUsersInfo.isEmpty()) {
            %>

            <div class="panel panel-default">
                <div class="panel-body" style="    color: gray;    text-align: center;">
                    There are currently no created unassigned users.
                </div>
            </div>

            <%
            } else {
                int currentUserID = (Integer) session.getAttribute("uid");
                for (List<String> userInfo : unassignedUsersInfo) {
                    int uid = Integer.valueOf(userInfo.get(0));
                    String username = userInfo.get(1);
                    String lastLogin = userInfo.get(3);
                    String lastRole = userInfo.get(4);
                    String totalScore = userInfo.get(5);
            %>

            <tr>
                <td>
                    <% if (uid != currentUserID) { %>
                    <input type="checkbox" name="selectedUsers" id="selectedUsers" value="<%= uid%>" onchange =
                            "updateCheckbox(this.value, this.checked);">
                    <%}%>
                </td>
                <td><%= uid%>
                    <input type="hidden" name="added_uid" value=<%=uid%>>
                </td>
                <td><%= username %>
                </td>
                <td><%= lastRole %>
                </td>
                <td><%= totalScore %>
                </td>
                <td><%= lastLogin %>
                </td>
                <td style="padding-top:3px; padding-bottom:3px; ">
                    <div style="max-width: 150px; float: left;">
                        <select name="<%="game_" + uid%>" class="form-control selectpicker" data-size="small"
                                id="game">
                            <% for (MultiplayerGame g : availableGames) { %>
                            <option value="<%=g.getId()%>"><%=String.valueOf(g.getId()) + ": " + g.getCUT().getAlias()%>
                            </option>
                            <%
                                }
                                if (createdGames != null) {
                                    for (int gameIndex = 0; gameIndex < createdGames.size(); ++gameIndex) {
                                        String classAlias = createdGames.get(gameIndex).getCUT().getAlias();
                            %>
                            <option style="color:gray"
                                    value=<%="T" + String.valueOf(gameIndex)%>><%="T" + String.valueOf(gameIndex)
                                    + ": " + classAlias%>
                            </option>
                            <%}%>
                            <%}%>
                        </select>
                    </div>
                    <div style="float: left; max-width: 120px; margin-left:2px">
                        <select name="<%="role_" + uid%>" class="form-control selectpicker" data-size="small"
                                id="role">
                            <option value="<%=Role.ATTACKER%>">Attacker</option>
                            <option value="<%=Role.DEFENDER%>">Defender</option>
                        </select>
                    </div>
                    <button class="btn btn-sm btn-primary" type="submit" value="<%=uid%>" name="userListButton"
                            style="margin: 2px; float:left"
                            <%=availableGames.isEmpty() && (createdGames == null || createdGames.isEmpty()) ? "disabled" : ""%>>
                        <span class="glyphicon glyphicon-plus"></span>
                    </button>
                </td>
            </tr>

            <%
                    }
                }
            %>
            </tbody>
        </table>

        <input type="text" class="form-control" id="hidden_user_id_list" name="hidden_user_id_list" hidden>

        <div class="form-group">
            <label for="user_name_list">User Names</label>
            <a data-toggle="collapse" href="#demo" style="color:black">
                <span class="glyphicon glyphicon-question-sign"></span>
            </a>
            <div id="demo" class="collapse">
                Newline seperated list of usernames or emails.
                <br/>The union of these users and the users selected in the table above will be used to create games.
                <br/>Only unassigned users are taken into account.
            </div>
            <textarea class="form-control" rows="5" id="user_name_list" name="user_name_list"
                      oninput="document.getElementById('submit_users_btn').disabled =
                        !(areAnyChecked('selectedUsers') || containsText('user_name_list')) || (document.getElementById('cut_select').selectedIndex != 0)"></textarea>
        </div>


        <div class="row">
            <div class="col-sm-2">
                <label for="cut_select" class="label-normal">CUT</label>
                <select name="class" class="form-control selectpicker" data-size="large" id="cut_select">
                    <% for (GameClass c : DatabaseAccess.getAllClasses()) { %>
                    <option value="<%=c.getId()%>"><%=c.getAlias()%>
                    </option>
                    <%}%>
                </select>
                <br/>
                <a href="<%=request.getContextPath()%>/games/upload?fromAdmin=true"> Upload Class </a>
            </div>
            <div class="col-sm-1"></div>
            <div class="col-sm-2">
                <label for="roles_group" class="label-normal">Role Assignment</label>
                <div id="roles_group">
                    <div class="radio">
                        <label class="label-normal"><input TYPE="radio" name="roles"
                                                           value="<%=AdminCreateGames.RoleAssignmentMethod.RANDOM%>"
                                                           checked="checked"/>
                            Random
                        </label>
                    </div>
                    <div class="radio">
                        <label class="label-normal"><input TYPE="radio" name="roles"
                                                           VALUE="<%=AdminCreateGames.RoleAssignmentMethod.OPPOSITE%>"/>
                            Opposite Role
                        </label>
                    </div>
                </div>
            </div>
            <div class="col-sm-3">
                <label for="teams_group" class="label-normal">Team Assignment</label>
                <div id="teams_group">
                    <div class="radio">
                        <label class="label-normal"><input TYPE="radio" name="teams"
                                                           value="<%=AdminCreateGames.TeamAssignmentMethod.RANDOM%>"
                                                           checked="checked"/>Random</label>
                    </div>
                    <div class="radio">
                        <label class="label-normal"><input TYPE="radio" name="teams"
                                                           VALUE="<%=AdminCreateGames.TeamAssignmentMethod.SCORE_DESCENDING%>"/>
                            Scores descending
                        </label>
                    </div>
                    <div class="radio">
                        <label class="label-normal"><input TYPE="radio" name="teams"
                                                           VALUE="<%=AdminCreateGames.TeamAssignmentMethod.SCORE_SHUFFLED%>"/>
                            Scores block shuffled
                        </label>
                    </div>
                </div>
            </div>
            <div class="col-sm-2">
                <label for="attackers" class="label-normal">Attackers per Game</label>
                <input type="number" value="3" id="attackers" name="attackers" min="1" class="form-control"/>
            </div>
            <div class="col-sm-2">
                <label for="defenders" class="label-normal">Defenders per Game</label>
                <input type="number" value="3" id="defenders" name="defenders" min="1" class="form-control"/>
            </div>
        </div>
        <div class="row">
            <div class="col-sm-2">
                <label for="level_group" class="label-normal">Games Level</label>
                <div id="level_group">
                    <div class="radio">
                        <label class="label-normal"><input TYPE="radio" name="gamesLevel"
                                                           VALUE="<%=GameLevel.HARD%>" checked="checked"/>
                            Hard</label>
                    </div>
                    <div class="radio">
                        <label class="label-normal"><input TYPE="radio" name="gamesLevel"
                                                           value="<%=GameLevel.EASY%>"/>
                            Easy</label>
                    </div>
                </div>
            </div>
            <div class="col-sm-1">
            </div>
            <div class="col-sm-2">
                <label for="state_group" class="label-normal">Games State</label>
                <div id="state_group">
                    <div class="radio">
                        <label class="label-normal"><input TYPE="radio" name="gamesState"
                                                           VALUE="<%=GameState.CREATED%>" checked="checked"/>
                            Created</label>
                    </div>
                    <div class="radio">
                        <label class="label-normal"><input TYPE="radio" name="gamesState"
                                                           value="<%=GameState.ACTIVE%>"/>
                            Active</label>
                    </div>
                </div>
            </div>
            <div class="col-sm-3">
            </div>


            <%
                DateTime startDate = DateTime.now();
                DateTime finishDate = startDate.plusHours(2);
                DateTimeFormatter fmt = DateTimeFormat.forPattern("MM/dd/yyyy");
            %>
            <div class="col-sm-2">
                <label for="startTime" class="label-normal">Start Time</label>
                <br/>
                <input type="hidden" id="startTime" name="startTime" value="<%=startDate.getMillis()%>"/>
                <input class="form-control" name="start_dateTime" id="start_dateTime"
                       value="<%=fmt.print(startDate)%>"/>
                <div>
                    <input class="ws-2" type="text" name="start_hours" id="start_hours"
                           value="<%=String.format("%1$02d",startDate.getHourOfDay())%>"
                           style="text-align: center;" min="0" max="59"/>
                    <span>:</span>
                    <input class="ws-2" type="text" name="start_minutes" id="start_minutes"
                           value="<%=String.format("%1$02d",startDate.getMinuteOfHour())%>"
                           style="text-align: center;" min="0" max="59"/>
                </div>
            </div>
            <script>
                var voidFunct = function () {
                };
                var updateStartTimestamp = function () {
                    var timestamp = new Date($("#start_dateTime").val()).valueOf();
                    timestamp += parseInt($("#start_hours").val()) * 60 * 60 * 1000;
                    timestamp += parseInt($("#start_minutes").val()) * 60 * 1000;
                    var now = new Date().getTime();
                    if (timestamp < now) {
                        //invalid timestamp, set it to now
                        timestamp = now;
                    }
                    $("#startTime").val(timestamp);
                }
                $("#start_hours").on("change", function () {
                    var hours = $("#start_hours").val();
                    updateStartTimestamp();
                })
                $("#start_minutes").on("change", function () {
                    var mins = $("#start_minutes").val();
                    updateStartTimestamp();
                })
                var dataPicker = $("#start_dateTime").datepicker({
                    onSelect: function (selectedDate, dp) {
                        $(".ui-datepicker a").attr("href", "javascript:voidFunct();");
                        updateStartTimestamp();
                    }
                });
            </script>
            <div class="col-sm-2">
                <label for="finishTime" class="label-normal">Finish Time</label>
                <input type="hidden" id="finishTime" name="finishTime" value="<%=finishDate.getMillis()%>"/>
                <input class="form-control" name="finish_dateTime" id="finish_dateTime"
                       value="<%=fmt.print(finishDate)%>"/>
                <div>
                    <input class="ws-2" type="text" name="finish_hours" id="finish_hours"
                           value="<%=String.format("%1$02d",finishDate.getHourOfDay())%>"
                           style="text-align: center;" min="0" max="59"/>
                    <span>:</span>
                    <input class="ws-2" type="text" name="finish_minutes" id="finish_minutes"
                           value="<%=String.format("%1$02d",finishDate.getMinuteOfHour())%>"
                           style="text-align: center;" min="0" max="59"/>
                </div>
            </div>
            <script>
                var updateFinishTimestamp = function () {
                    var timestamp = new Date($("#finish_dateTime").val()).valueOf();
                    timestamp += parseInt($("#finish_hours").val()) * 60 * 60 * 1000;
                    timestamp += parseInt($("#finish_minutes").val()) * 60 * 1000;
                    var now = new Date().getTime();
                    if (timestamp < now) {
                        //invalid timestamp, set it to now+2 hours
                        timestamp = now + (2 * 60 * 60 * 1000);
                    }
                    $("#finishTime").val(timestamp);
                }
                $("#finish_hours").on("change", function () {
                    var hours = $("#finish_hours").val();
                    updateFinishTimestamp();
                })
                $("#finish_minutes").on("change", function () {
                    var mins = $("#finish_minutes").val();
                    updateFinishTimestamp();
                })
                var dataPicker = $("#finish_dateTime").datepicker({
                    onSelect: function (selectedDate, dp) {
                        $(".ui-datepicker a").attr("href", "javascript:voidFunct();");
                        updateFinishTimestamp();
                    },
                });
            </script>


        </div>
        <div class="row">
            <div class="col-sm-2">
                <label class="label-normal" title="Click the question sign for more information on the levels"
                       for="mutantValidatorLevel">
                    Mutant validator
                    <a data-toggle="collapse" href="#validatorExplanation" style="color:black">
                        <span class="glyphicon glyphicon-question-sign"></span>
                    </a>
                </label>
                <select id="mutantValidatorLevel" name="mutantValidatorLevel" class="form-control selectpicker"
                        data-size="medium">
                    <%for (CodeValidator.CodeValidatorLevel cvl : CodeValidator.CodeValidatorLevel.values()) {%>
                    <option value=<%=cvl.name()%> <%=cvl.equals(CodeValidator.CodeValidatorLevel.MODERATE) ? "selected" : ""%>>
                        <%=cvl.name().toLowerCase()%>
                    </option>
                    <%}%>
                </select>
            </div>
            <div class="col-sm-1">
            </div>
            <div class="col-sm-2">
                <label class="label-normal" title="Players can chat with their team and with all players in the game"
                       for="chatEnabled">
                    Enable Game Chat
                </label>
                <input type="checkbox" id="chatEnabled" name="chatEnabled"
                       class="form-control" data-size="medium" data-toggle="toggle" data-on="On" data-off="Off"
                       data-onstyle="primary" data-offstyle="" checked>
            </div>
            <div class="col-sm-3">
                <label class="label-normal" title="Attackers can mark uncovered lines as equivalent"
                       for="markUncovered">
                    Mark uncovered lines as equivalent
                </label>
                <input type="checkbox" id="markUncovered" name="markUncovered"
                       class="form-control" data-size="medium" data-toggle="toggle" data-on="On" data-off="Off"
                       data-onstyle="primary" data-offstyle="">
            </div>
            <div class="col-sm-2">
                <label for="maxAssertionsPerTest" class="label-normal"
                       title="Maximum number of assertions per test. Increase this for difficult to test classes.">Max.
                    Assertions per Test</label>
                <br/>
                <input class="form-control" type="number" value="2" name="maxAssertionsPerTest"
                       id="maxAssertionsPerTest" min=1 required/>
            </div>
        </div>
        <br>
        <div class="row">
            <div class="col-sm-5">
                <div id="validatorExplanation" class="collapse panel panel-default" style="font-size: 12px;">
                    <%@ include file="/jsp/validator_explanation.jsp" %>
                </div>
            </div>
        </div>
        <button class="btn btn-md btn-primary" type="submit" name="submit_users_btn" id="submit_users_btn" disabled>
            Stage Games
        </button>

        <p>
            If you just want to create a single open game without assigning players, you can also use the <a href="<%=request.getContextPath()%>/multiplayer/games/create?fromAdmin=true"> Create game</a> interface.
        </p>

            <script>
            $('#selectAllUsers').click(function () {
                var checkboxes = document.getElementsByName('selectedUsers');
                var isChecked = document.getElementById('selectAllUsers').checked;
                checkboxes.forEach(function (element) {
                    if(element.checked !== isChecked)
                        element.click();
                });
            });

            $('#selectAllTempGames').click(function () {
                $(this.form.elements).filter(':checkbox').prop('checked', this.checked);
            });

            $('#selectAllGames').click(function () {
                $(this.form.elements).filter(':checkbox').prop('checked', this.checked);
            });

            $('#togglePlayersCreated').click(function () {
                var showPlayers = localStorage.getItem("showCreatedPlayers") === "true";
                localStorage.setItem("showCreatedPlayers", showPlayers ? "false" : "true");
                $("[id=playersTableCreated]").toggle();
                $("[id=playersTableHidden]").toggle();
                setCreatedPlayersSpan()
            });

            function setCreatedPlayersSpan() {
                var showPlayers = localStorage.getItem("showCreatedPlayers") === "true";
                var buttonClass = showPlayers ? "glyphicon glyphicon-eye-close" : "glyphicon glyphicon-eye-open";
                document.getElementById("togglePlayersCreatedSpan").setAttribute("class", buttonClass);
            }

            function setSelectAllCheckbox(checkboxesName, selectAllCheckboxId) {
                var checkboxes = document.getElementsByName(checkboxesName);
                var allChecked = true;
                checkboxes.forEach(function (element) {
                    allChecked = allChecked && element.checked;
                });
                document.getElementById(selectAllCheckboxId).checked = allChecked;
            }

            function areAnyChecked(name) {
                var checkboxes = document.getElementsByName(name);
                var anyChecked = false;
                checkboxes.forEach(function (element) {
                    anyChecked = anyChecked || element.checked;
                });
                return anyChecked;
            }

            function containsText(id) {
                return document.getElementById(id).value.trim() !== "";
            }

            function updateCheckbox(checkboxVal, isChecked) {
                document.getElementById('submit_users_btn').disabled =
                    !(areAnyChecked('selectedUsers') || containsText('user_name_list')) || (document.getElementById('cut_select').selectedIndex != 0);
                setSelectAllCheckbox('selectedUsers', 'selectAllUsers');
                var hiddenIdList = document.getElementById('hidden_user_id_list');
                if (isChecked) {
                    hiddenIdList.value = hiddenIdList.value.trim() + '<' + checkboxVal + '>,';
                } else {
                    hiddenIdList.value = hiddenIdList.value.replace('<' + checkboxVal + '>,', '');
                }
            }

            $('#tableAddUsers').on('draw.dt', function () {
                setSelectAllCheckbox('selectedUsers', 'selectAllUsers');
            });


            $(document).ready(function () {
                if (localStorage.getItem("showActivePlayers") === "true") {
                    $("[id=playersTableActive]").show();
                }

                if (localStorage.getItem("showCreatedPlayers") === "true") {
                    $("[id=playersTableCreated]").show();
                    $("[id=playersTableHidden]").hide();
                }
                $('#tableAddUsers').DataTable({
                    pagingType: "full_numbers",
                    "lengthChange": false,
                    "searching": true,
                    "order": [[5, "desc"]],
                    "columnDefs": [{
                        "targets": 0,
                        "orderable": false
                    }, {
                        "targets": 6,
                        "orderable": false
                    }]
                });

                $('#tableCreatedGames').DataTable({
                    pagingType: "full_numbers",
                    lengthChange: false,
                    searching: false,
                    order: [[3, "desc"]],
                    "columnDefs": [{
                        "targets": 0,
                        "orderable": false
                    }, {
                        "targets": 6,
                        "orderable": false
                    }]
                });

                setCreatedPlayersSpan();
            });

            $('.modal').on('shown.bs.modal', function () {
                var codeMirrorContainer = $(this).find(".CodeMirror")[0];
                if (codeMirrorContainer && codeMirrorContainer.CodeMirror) {
                    codeMirrorContainer.CodeMirror.refresh();
                } else {
                    var editorDiff = CodeMirror.fromTextArea($(this).find('textarea')[0], {
                        lineNumbers: false,
                        readOnly: true,
                        mode: "text/x-java"
                    });
                    editorDiff.setSize("100%", 500);
                }
            });
        </script>

    </form>
</div>
<%@ include file="/jsp/footer.jsp" %>
