<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta http-equiv="X-UA-Compatible" content="IE=Edge" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta HTTP-EQUIV="Pragma" CONTENT="no-cache" />
    <meta HTTP-EQUIV="Expires" CONTENT="-1" />
    <link rel="shortcut icon" href="images/favicon.png" />
    <link rel="icon" href="images/favicon.png" />
    <title>软件中心 - gost 设置</title>
    <link rel="stylesheet" type="text/css" href="index_style.css" />
    <link rel="stylesheet" type="text/css" href="form_style.css" />
    <link rel="stylesheet" type="text/css" href="usp_style.css" />
    <link rel="stylesheet" type="text/css" href="ParentalControl.css">
    <link rel="stylesheet" type="text/css" href="css/icon.css">
    <link rel="stylesheet" type="text/css" href="css/element.css">
    <link rel="stylesheet" type="text/css" href="res/softcenter.css">
    <script type="text/javascript" src="/state.js"></script>
    <script type="text/javascript" src="/popup.js"></script>
    <script type="text/javascript" src="/help.js"></script>
    <script type="text/javascript" src="/validator.js"></script>
    <script type="text/javascript" src="/js/jquery.js"></script>
    <script type="text/javascript" src="/general.js"></script>
    <script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
    <script type="text/javascript" src="/res/softcenter.js"></script>
    <script type="text/javascript">
        var db_gost_ = {};
        var params_input = ["gost_run_status", "gost_config_content"];
        var params_check = ["gost_enable"];


        function get_dbus_data() {
            $.ajax({
                type: "GET",
                url: "/_api/gost_",
                dataType: "json",
                async: false,
                success: function(data) {
                    db_gost_ = data.result[0];
                    conf2obj();
                }
            });
        }

        function conf2obj() {
            for (var i = 0; i < params_input.length; i++) {
                if (db_gost_[params_input[i]]) {
                    E(params_input[i]).value = db_gost_[params_input[i]];
                }
            }
            for (var i = 0; i < params_check.length; i++) {
                if (db_gost_[params_check[i]]) {
                    E(params_check[i]).checked = db_gost_[params_check[i]] == "1";
                }
            }
        }

        function save() {
            for (var i = 0; i < params_check.length; i++) {
                db_gost_[params_check[i]] = E(params_check[i]).checked ? '1' : '0';
            }
            showLoading();
            push_data(db_gost_, 1);
        }

        function push_data(obj, arg) {
            var id = parseInt(Math.random() * 100000000);
            var postData = {
                "id": id,
                "method": "gost_config.sh",
                "params": [arg],
                "fields": obj
            };
            console.log(postData);
            $.ajax({
                url: "/_api/",
                cache: false,
                type: "POST",
                dataType: "json",
                data: JSON.stringify(postData),
                success: function(response) {
                    if (response.result == id) {
                        refreshpage();
                    }
                }
            });
        }

        function restart_gost() {
            showLoading();
            push_data(db_gost_, 2)
        }

        // 加载config文件内容
        function load_config_content() {
            var config = db_gost_['gost_config_content'];
            if (config == "" || config == undefined) {
                // reload_content();
                return false;
            }
            // 解析base64编码的config文件内容
            var content = Base64.decode(config);
            if (content == "") {
                return false;
            }
            $("#gost_config_content").val(content);
        }
        // 保存config文件内容
        function save_config_content() {
            var content = $("#gost_config_content").val();
            if (content == "") {
                return false;
            }
            var base64_content = Base64.encode(content);

            if (base64_content == "") {
                // alert("编码失败，请检查内容是否包含特殊内容.");
                return false;
            }
            db_gost_["gost_config_content"] = base64_content;
            save();
            get_dbus_data()
            load_config_content()
        }

        function buildswitch() {
            $("#gost_enable").click(
                function() {
                    if (E('gost_enable').checked) {
                        E('gost_detail_table').style.display = "";
                        E('status_tr').style.display = "";
                    } else {
                        E('gost_detail_table').style.display = "none";
                        E('status_tr').style.display = "none";
                    }
                });
        }

        function get_status() {
            $.ajax({
                type: "GET",
                url: "/_api/gost_run_status",
                dataType: "json",
                async: false,
                success: function(data) {
                    goststatus = data.result[0];
                    if (goststatus["gost_run_status"]) {
                        $("#gost_run_status").html("PID: " + goststatus["gost_run_status"]);
                    }
                }
            });
        }

        function init() {
            show_menu(menu_hook);
            get_dbus_data();
            buildswitch();
            update_visibility();
            get_status();
            load_config_content();
        }

        function update_visibility() {
            var rrt = E("gost_enable");
            if (db_gost_["gost_enable"] != "1") {
                rrt.checked = false;
                E('gost_detail_table').style.display = "none";
                E('status_tr').style.display = "none";
            } else {
                rrt.checked = true;
                E('gost_detail_table').style.display = "";
                E('status_tr').style.display = "";
            }
        }

        function menu_hook(title, tab) {
            tabtitle[tabtitle.length - 1] = new Array("", "gost");
            tablink[tablink.length - 1] = new Array("", "Module_gost.asp");
        }
    </script>
</head>

<body onload="init();">
    <div id="TopBanner"></div>
    <div id="Loading" class="popup_bg"></div>
    <iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
    <input type="hidden" name="current_page" value="Module_gost.asp" />
    <input type="hidden" name="next_page" value="Module_gost.asp" />
    <input type="hidden" name="group_id" value="" />
    <input type="hidden" name="modified" value="0" />
    <input type="hidden" name="action_mode" value="" />
    <input type="hidden" name="action_script" value="" />
    <input type="hidden" name="action_wait" value="5" />
    <input type="hidden" name="first_time" value="" />
    <input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get(" preferred_lang "); %>"/>
    <input type="hidden" name="SystemCmd" onkeydown="onSubmitCtrl(this, ' Refresh ')" value="gost_config.sh" />
    <input type="hidden" name="firmver" value="<% nvram_get(" firmver "); %>"/>
    <table class="content" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td width="17">&nbsp;</td>
            <td valign="top" width="202">
                <div id="mainMenu"></div>
                <div id="subMenu"></div>
            </td>
            <td valign="top">
                <div id="tabMenu" class="submenuBlock"></div>
                <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
                    <tr>
                        <td align="left" valign="top">
                            <table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
                                <tr>
                                    <td bgcolor="#4D595D" colspan="3" valign="top">
                                        <div>&nbsp;</div>
                                        <div style="float:left;" class="formfonttitle">gost</div>
                                        <div style="float:right; width:15px; height:25px;margin-top:10px">
                                            <img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img>
                                        </div>
                                        <div style="margin:30px 0 10px 5px;" class="splitLine"></div>
                                        <div class="formfontdesc" style="padding-top:5px;margin-top:0px;float: left;" id="cmdDesc">
                                            <div>使用gost实现的代理转发服务</div>
                                            <ul style="padding-top:5px;margin-top:10px;float: left;">
                                                <li>点 <a href="https://gost.run/tutorials/"><i><u>这里</u></i></a> 查看官方说明</li>
                                            </ul>
                                        </div>
                                        <table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="routing_table">
                                            <thead>
                                                <tr>
                                                    <td colspan="2">开关设置</td>
                                                </tr>
                                            </thead>
                                            <tr>
                                                <th style="width: 28%;">开启 gost</th>
                                                <td>
                                                    <div class="switch_field" style="display:table-cell;float: left;">
                                                        <label for="gost_enable">
																<input id="gost_enable" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container">
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr id="status_tr">
                                                <th style="width: 28%;">状态</th>
                                                <td>
                                                    <div><a><span id="gost_run_status"></span></a></div>
                                                </td>
                                            </tr>
                                        </table>
                                        <table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="gost_detail_table">
                                            <thead>
                                                <tr>
                                                    <td colspan="2">配置文件设置</td>
                                                </tr>
                                            </thead>

                                            <tr>
                                                <td colspan="2">
                                                    <textarea id="gost_config_content" rows="20" class="input_text" style="width: 98%; background: #3b4c50; color: white"></textarea>
                                                </td>
                                            </tr>

                                        </table>
                                        <div style="margin:30px 0 10px 5px;" class="splitLine"></div>

                                        <div class="apply_gen">
                                            <a type="button" class="button_gen" style="font-size: 12px;height: 33px;place-items: center;justify-content: center;width: auto;min-width: 80px;display: inline-flex;" onclick="save_config_content(); " href="javascript:void(0); "> 保存 </a>                                            &nbsp;&nbsp;&nbsp;
                                            <a type="button" class="button_gen" style="font-size: 12px;height: 33px;place-items: center;justify-content: center;width: auto;min-width: 80px;display: inline-flex;" onclick="restart_gost(); " href="javascript:void(0); ">重启</a>
                                            <!-- <input class="button_gen" id="cmdBtn" onClick="save();" type="button" value="提交" /> -->
                                        </div>
                                        <!-- <div class="KoolshareBottom">
                                            论坛技术支持：
                                            <a href="http://www.koolshare.cn" target="_blank"> <i><u>www.koolshare.cn</u></i></a>
                                        </div> -->
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td width="10" align="center" valign="top"></td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <div id="footer"></div>
</body>

</html>