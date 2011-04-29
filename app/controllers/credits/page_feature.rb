class Credits::PageFeature < ParagraphFeature
  include ActionView::Helpers::NumberHelper
  
  feature :credits_page_buy, :default_feature => <<-FEATURE
  <cms:credits>
    <cms:form>
    <ul>
      <li><cms:name/></li>
      <li><cms:amount_label/><cms:amount/> x <cms:price/></li>
      <li><cms:submit/></li>
    </ul>
    </cms:form>
  </cms:credits>
  <cms:no_credits>
    <p>You must be logged in to purchase credits.</p>
  </cms:no_credits>
  FEATURE

  def credits_page_buy_feature(data)
    webiva_feature(:credits_page_buy, data) do |c|
      c.expansion_tag('logged_in') { |t| data[:user] }
      c.expansion_tag('credits') { |t| (t.locals.user = data[:user]) && (t.locals.credits = data[:credits]) }
      c.value_tag('credits:total_credits') { |t| t.locals.user.total_credits }
      c.value_tag('credits:used_credits') { |t| t.locals.user.used_credits }
      c.h_tag('credits:name') { |t| t.locals.credits.name }
      c.value_tag('credits:price') { |t| number_to_currency(t.locals.credits.price) }

      c.form_for_tag('credits:form','credits') { |t| t.locals.credits = data[:credits] }
        c.field_tag('credits:form:amount')
        c.button_tag('credits:form:submit')

      c.expansion_tag('credits:form:updated') { |t| data[:updated] }
      c.expansion_tag('credits:form:removed') { |t| data[:removed] }
    end
  end
end
