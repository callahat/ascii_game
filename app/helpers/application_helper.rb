# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def google_ad
'<script type="text/javascript"><!--
google_ad_client = "pub-3928035645761607";
/* 120x600, created 5/17/10 */
google_ad_slot = "0512113450";
google_ad_width = 120;
google_ad_height = 600;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>'
  end
end
