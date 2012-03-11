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

    def radio_button(name, *args)
      original_radio = super
      radio = original_radio.gsub(/\/>$/, "{{#if #{name}}}check='checked'{{/if}}/>")
      radio.html_safe
    end

    def check_box(name, *args)
      original_checkbox = super
      checkbox = original_checkbox.gsub(/\/>$/, "{#if #{name}}check='checked'{/if}/>")
      checkbox.html_safe
    end
  end
end
