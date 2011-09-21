module HandlebarsInputHelper
  def hbs_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    form_for(record_or_name_or_array, *(args << options.merge(:builder => HandlebarsFormBuilder)), &proc)
  end

  class HandlebarsFormBuilder < ActionView::Helpers::FormBuilder
    def text_field(method, options={})
      super(method, options.reverse_merge(:value => "{{#{method}}}"))
    end
  end
end