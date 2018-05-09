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

  def error_messages_for form_object
    object = form_object.respond_to?(:errors) ? form_object : instance_variable_get("@#{form_object.to_s.gsub(/^@/,'')}")

    if object.try(:errors).try(:any?)
      messages = object.errors.full_messages.map{|m| "<li>#{m}</li>" }.join("\n")

      <<-HTML.html_safe
        <div id="error_explanation">
          <h2>#{pluralize(object.errors.count, "error")} prohibited this #{object.class.name} from being saved:</h2>
          <ul>#{ messages }</ul>
        </div>
      HTML
    else
      ''
    end
  end
end
