jQuery.noConflict();

jQuery(document).ready(function () {
  //if (window.location.pathname == "/character/new") {
    jQuery('.placeable_feature').draggable({
      helper: 'clone',
    });

    jQuery('#level_map .feature_slot').droppable({
      accept: '.placeable_feature',
      drop: handleDropEvent
    });

    jQuery('.feature_details').click(function(){
      jQuery( "#feature_details_" + jQuery(this).data('feature-id') ).dialog({
        modal: true
      });
    });

    function handleDropEvent(event, ui) {
      var draggable = ui.draggable.clone();

      // Don't seem to need this with the current version of jquery ui pulled in,
      //  seems like the draggable listeners don't come with the clone, so the clone
      //  is not draggable
      //jQuery(draggable).draggable('option', 'disabled', true);

      jQuery(draggable).droppable({
        accept: '.placeable_feature',
        drop: handleDropEvent
      });

      updateEstimate(jQuery('#estimate'), draggable, jQuery(event.target));

      jQuery(event.target).closest('td').css('background','black');
      jQuery(event.target).parent().find('input.coordinate').val(draggable.data('feature-id'));
      jQuery(event.target).replaceWith(draggable);
    }

    function updateEstimate($estimate, draggable, $target){
      var currentEstimate = parseInt($estimate.text());
      var droppedCost = parseInt(draggable.data('cost'));
      var replacedCost = parseInt($target.data('cost'));
      var costDifference = currentEstimate + droppedCost - replacedCost;
      $estimate.text(costDifference);
    }
  //}
});