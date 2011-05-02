jQuery.noConflict();

//( function(jQuery) {


  jQuery(document).ready(function(){
    window.onload = function(){ 
        changeStuff("c_class_id", jQuery("select[@id=c_class_id]")[0].value);
        changeStuff("race_id", jQuery("select[@id=race_id]")[0].value);
        updateCumStat();
    };
    
    jQuery("select").change(function(event) {
      //alert(this.value);
      //alert(this.id);
      changeStuff(this.id, this.value);
      updateCumStat();
     })
   
     //functions
   
     //change the displayed stats
     function changeStuff(what, id){
       //alert(jQuery("input[@class="+what+"][@id="+id+"]").length);
       jQuery("input[@class="+what+"][@id="+id+"]").each(function(i){
         //alert(jQuery("input[@class="+what+"][@id="+id+"]")[i].value);
         jQuery("div[@class="+what+"_stat]")[i].innerHTML = jQuery("input[@class="+what+"][@id="+id+"]")[i].value;
       });
     }
     
     //update the displayed stats
     function updateCumStat() {
       //alert("Got here");
       jQuery("div[@class=statsum]").each(function(i){
         //alert(parseFloat(jQuery("div[@class=c_class_id_stat]")[i+1].innerHTML));
         jQuery("div[@class=statsum]")[i].innerHTML = parseFloat(jQuery("div[@class=c_class_id_stat]")[i+1].innerHTML) + parseFloat(jQuery("div[@class=race_id_stat]")[i+1].innerHTML);
       });
     }
     
  }); //end document
  

//} ) ( jQuery );
