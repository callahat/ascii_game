jQuery.noConflict();

//( function(jQuery) {

  jQuery(document).ready(function(){
    window.onload = function(){ 
        update_freepts();
    };
    
    jQuery("input[@type=button]").click(function(event) {
      var sum;
      if(this.value == "-"){
        sum = parseInt(jQuery("input[@type=text][@id="+this.id+"]").val()) - 1;
      }else if(parseInt(jQuery("#freepoint_sum").text()) > 0){
        sum = parseInt(jQuery("input[@type=text][@id="+this.id+"]").val()) + 1;
      }
      if(sum >= 0){
        jQuery("input[@type=text][@id="+this.id+"]").val(sum);
      }
      update_freepts();
    })
    
    jQuery("input[@type=text]").change(function(event) {
      var sum = parseInt(jQuery("input[@type=text][@id="+this.id+"]").val());
      var freePts = parseInt(jQuery("#freepoint_sum").text());
      sum = (sum > 0 ? sum : 0);
      
      if( freePts - sum >= 0){
        jQuery("input[@type=text][@id="+this.id+"]").val(sum);
      } else {
        jQuery("input[@type=text][@id="+this.id+"]").val(freePts);
      }
      update_freepts();
    })
    
    jQuery("input[@type=text]").change(function(event) {
      update_freepts();
    })
    
    
    //functions
    function update_freepts(){
      var attrs = jQuery("input[@type=text]");
      var freesum = 0;
      attrs.each(function(i){
        freesum -= parseInt(jQuery("input[@type=text]")[i].value);
      });
      freesum += parseInt(jQuery("input[@id=total_freepts]").val());
      jQuery("#freepoint_sum").text(freesum);
    }
  }); //end document

//} ) ( jQuery );