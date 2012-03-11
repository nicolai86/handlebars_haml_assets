module HandlebarsInputHelper
  def hbs_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    form_for(record_or_name_or_array, *(args << options.merge(:builder => HandlebarsFormBuilder)), &proc)
  end

  class HandlebarsFormBuilder < ActionView::Helpers::FormBuilder
    def text_field(method, options={})
      super(method, options.reverse_merge(:value => "{{#{method}}}"))
    end

    def hidden_field(method, options={})
      super(method, options.reverse_merge(:value => "{{#{method}}}"))
    end

    def radio_button(method, tag_value, options={})
      super(method, tag_value, options.reverse_merge(:value => "{{#{method}}}"))
    end

    def check_box(method, options={}, checked_value="1", unchecked_value="0")
      super(method, options.reverse_merge(:value => "{{#{method}}}"), checked_value, unchecked_value)
    end
  end
end
