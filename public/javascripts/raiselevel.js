( function($) {

  $(document).ready(function(){
    window.onload = function(){ 
        update_freepts();
    };
    
    $("input[@type=button]").click(function(event) {
      var sum;
      if(this.value == "-"){
        sum = parseInt($("input[@type=text][@id="+this.id+"]").val()) - 1;
      }else if(parseInt($("#freepoint_sum").text()) > 0){
        sum = parseInt($("input[@type=text][@id="+this.id+"]").val()) + 1;
      }
      if(sum >= 0){
        $("input[@type=text][@id="+this.id+"]").val(sum);
      }
      update_freepts();
     })
     
     $("input[@type=text]").change(function(event) {
       update_freepts();
     })
     
     
     //functions
     function update_freepts(){
       var attrs = $("input[@type=text]");
       var freesum = 0;
       attrs.each(function(i){
         freesum -= parseInt($("input[@type=text]")[i].value);
       });
       freesum += parseInt($("input[@id=total_freepts]").val());
       $("#freepoint_sum").text(freesum);
     }
  }); //end document

} ) ( jQuery );