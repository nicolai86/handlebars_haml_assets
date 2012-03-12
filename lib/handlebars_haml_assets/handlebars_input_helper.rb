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
      radio = original_radio.gsub(/\/>$/, "{{#if #{name}}}checked='checked'{{/if}}/>")
      radio.html_safe
    end

    def check_box(name, *args)
      original_checkbox = super
      checkbox = original_checkbox.gsub(/\/>$/, "{{#if #{name}}}checked='checked'{{/if}}/>")
      checkbox.html_safe
    end

    def file_field(name, options={})
      super(name, options)
    end
  end

  class HandlebarsDateTimeSelector < ActionView::Helpers::DateTimeSelector
    def build_options(selected, options = {})
      start         = options.delete(:start) || 0
      stop          = options.delete(:end) || 59
      step          = options.delete(:step) || 1
      options.reverse_merge!({:leading_zeros => true, :ampm => false, :use_two_digit_numbers => false})
      leading_zeros = options.delete(:leading_zeros)

      select_options = []
      start.step(stop, step) do |i|
        value = leading_zeros ? sprintf("%02d", i) : i
        tag_options = { :value => value }
        tag_options[:selected] = "selected" if selected == i if not @options.has_key? :default_year and not @options.has_key? :default_day
        tag_options["{{#if_eq #{@options[:index]}.#{@options[:default_year]} compare=#{i}}}selected"] = "'selected'{{/if_eq}}" if @options.has_key? :default_year
        tag_options["{{#if_eq #{@options[:index]}.#{@options[:default_day]} compare=#{i}}}selected"] = "'selected'{{/if_eq}}" if @options.has_key? :default_day
        text = options[:use_two_digit_numbers] ? sprintf("%02d", i) : value
        text = options[:ampm] ? AMPM_TRANSLATION[i] : text
        select_options << content_tag(:option, text, tag_options)
      end
      (select_options.join("\n") + "\n").html_safe
    end

    def select_month
      if @options[:use_hidden] || @options[:discard_month]
        build_hidden(:month, month || 1)
      else
        month_options = []
        1.upto(12) do |month_number|
          options = { :value => month_number }
          options[:selected] = "selected" if month == month_number and not @options.has_key? :default_month
          options["{{#if_eq #{@options[:index]}.#{@options[:default_month]} compare=#{month_number}}}selected"] = "'selected'{{/if_eq}}" if @options.has_key? :default_month
          month_options << content_tag(:option, month_name(month_number), options) + "\n"
        end
        build_select(:month, month_options.join)
      end
    end
  end
end

module ActionView
  module Helpers
    module DateHelperInstanceTag
      private
        def datetime_selector
          datetime = value(object) || default_datetime(options)
          @auto_index ||= nil

          options = options.dup
          options[:field_name]           = @method_name
          options[:include_position]     = true
          options[:prefix]             ||= @object_name
          options[:index]                = @auto_index if @auto_index && !options.has_key?(:index)

          HandlebarsDateTimeSelector.new(datetime, options, html_options)
        end
    end
  end
end
