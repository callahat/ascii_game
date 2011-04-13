( function($) {


  $(document).ready(function(){
    window.onload = function(){ 
        changeStuff("c_class_id", $("select[@id=c_class_id]")[0].value);
        changeStuff("race_id", $("select[@id=race_id]")[0].value);
        updateCumStat();
    };
    
    $("select").change(function(event) {
      //alert(this.value);
      //alert(this.id);
      changeStuff(this.id, this.value);
      updateCumStat();
     })
   
     //functions
   
     //change the displayed stats
     function changeStuff(what, id){
       //alert($("input[@class="+what+"][@id="+id+"]").length);
       $("input[@class="+what+"][@id="+id+"]").each(function(i){
         //alert($("input[@class="+what+"][@id="+id+"]")[i].value);
         $("div[@class="+what+"_stat]")[i].innerHTML = $("input[@class="+what+"][@id="+id+"]")[i].value;
       });
     }
     
     //update the displayed stats
     function updateCumStat() {
       //alert("Got here");
       $("div[@class=statsum]").each(function(i){
         //alert(parseFloat($("div[@class=c_class_id_stat]")[i+1].innerHTML));
         $("div[@class=statsum]")[i].innerHTML = parseFloat($("div[@class=c_class_id_stat]")[i+1].innerHTML) + parseFloat($("div[@class=race_id_stat]")[i+1].innerHTML);
       });
     }
     
  }); //end document
  

} ) ( jQuery );
