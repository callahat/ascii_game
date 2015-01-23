# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def google_ad
'<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- 120x600, created 5/17/10 -->
<ins class="adsbygoogle"
     style="display:inline-block;width:120px;height:600px"
     data-ad-client="ca-pub-3928035645761607"
     data-ad-slot="0512113450"></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>'.html_safe
  end
end
