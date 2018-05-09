jQuery.noConflict();

//( function(jQuery) {
  jQuery(document).ready(function () {
    if(window.location.pathname == "/character/new") {
    jQuery("select").change(function (event) {
      //console.log("Selected:");
      //console.log(this.value);
      //console.log(this.id);
      changeStuff(this.id, this.value);
      updateCumStat();
    });

    //functions

    //change the displayed stats
    function changeStuff(what, id) {
      //console.log("change stuff");
      //console.log("input."+what+"."+id+"");
      //console.log(jQuery("input."+what+"."+id+""));
      //console.log(jQuery("input."+what+"."+id+"").length);
      jQuery("input." + what + "." + id + "").each(function (i) {
        //alert(jQuery("input[@class="+what+"][@id="+id+"]")[i].value);
        jQuery("div." + what + "_stat")[i].innerHTML = jQuery("input." + what + "." + id + "")[i].value;
      });
    }

    //update the displayed stats
    function updateCumStat() {
      //alert("Got here");
      jQuery("div.statsum").each(function (i) {
        //alert(parseFloat(jQuery("div.c_class_id_stat")[i+1].innerHTML));
        jQuery("div.statsum")[i].innerHTML = parseFloat(jQuery("div.c_class_id_stat")[i + 1].innerHTML) + parseFloat(jQuery("div.race_id_stat")[i + 1].innerHTML);
      });
    }

    window.onload = function () {
      if (jQuery("select#c_class_id")[0] != undefined) {
        changeStuff("c_class_id", jQuery("select#c_class_id")[0].value);
        changeStuff("race_id", jQuery("select#race_id")[0].value);
        updateCumStat();
      };
    };
    }
  }); //end document
//} ) ( jQuery );
