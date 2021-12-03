$(function(){
    window.addEventListener("message", function(event){
        let data = event.data
        if (data.action == "update_hud" && $('body').is(":visible")) {
            $("#HealthIndicator").animate({width: data.hp + '%'});
            if (data.armour == 0) {
                $("#ArmourIndicator").hide();
            } else {
                $("#ArmourIndicator").show();
                $("#ArmourIndicator").animate({width: data.armour + '%'});
            }
            if (data.oxygen == 100) {
                $("#OxygenIndicator").hide();
            } else {
                $("#OxygenIndicator").show();
                $("#OxygenIndicator").animate({width: data.oxygen + '%'});
            }
            $("#StaminaIndicator").animate({width: data.stamina + '%'});
            $("#HungerIndicator").width(data.hunger + '%');
            $("#ThirstIndicator").width(data.thirst + '%');

            if (data.talking) {
                $("#VoiceIndicatorTalking").show();
            } else {
                $("#VoiceIndicatorTalking").hide();
            }
        }       

        if (data.action == "hud_pos") {
            $("#container").css("left", data.pos);
        }

        if (data.action == "voice_level") {
            $("#VoiceIndicator").animate({width: data.voicelevel + '%'});
            $("#VoiceIndicatorTalking").animate({width: data.voicelevel + '%'});
        }
        if (data.action == "toggle_hud") {
            $("body").fadeToggle();
        }

        if (data.action == "show_ui") {
            if (data.enable) { 
                if (data.type == "ui") { $("body").show(); }
                if (data.type == "voice") { $("#voicebox").show(); }
            } else {
                if (data.type == "ui") { $("body").hide(); }
                if (data.type == "voice") { $("#voicebox").hide(); }
            }
        }
        // console.log("test")
    })
})