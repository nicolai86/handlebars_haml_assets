require 'action_view'

module HandlebarsInputHelper
  include ActionView::Helpers::FormOptionsHelper

  def hbs_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    form_for(record_or_name_or_array, *(args << options.merge(:builder => HandlebarsFormBuilder)), &proc)
  end

  def hbs_date_select(object_name, method, options = {}, html_options = {})
    HandlebarsInstanceTag.new(object_name, method, self, options.delete(:object)).to_date_select_tag(options, html_options)
  end

  def hbs_select(object, method, choices, options = {}, html_options = {})
    HandlebarsInstanceTag.new(object, method, self, options.delete(:object)).to_select_tag(choices, options, html_options)
  end

  def options_for_select(container, selected = nil)
    return container if String === container

    selected, disabled = extract_selected_and_disabled(selected).map do | r |
       Array.wrap(r).map { |item| item.to_s }
    end

    container.map do |element|
      html_attributes = option_html_attributes(element)
      text, value = option_text_and_value(element).map { |item| item.to_s }
      selected_attribute = " {{#if_eq #{selected[0]} compare=#{value}}}selected='selected'{{/if_eq}}"
      disabled_attribute = " disabled='disabled'" if disabled && option_value_selected?(value, disabled)
      %(<option value="#{ERB::Util.html_escape(value)}"#{selected_attribute}#{disabled_attribute}#{html_attributes}>#{ERB::Util.html_escape(text)}</option>)
    end.join("\n").html_safe
  end

  module HandlebarsDateHelperInstanceTag
    include ::ActionView::Helpers::DateHelperInstanceTag

    private
      def datetime_selector(options, html_options)
        datetime = value(object) || default_datetime(options)
        @auto_index ||= nil

        options = options.dup
        #options[:field_name]           = @method_name
        #options[:include_position]     = true
        options[:prefix]             ||= @object_name
        options[:index]                = @auto_index if @auto_index && !options.has_key?(:index)

        HandlebarsDateTimeSelector.new(datetime, options, html_options)
      end
  end

  class HandlebarsInstanceTag < ActionView::Helpers::InstanceTag
    include HandlebarsInputHelper
    include HandlebarsDateHelperInstanceTag

    #def to_select_tag(choices, options, html_options)
      #selected_value = options.has_key?(:selected) ? options[:selected] : value(object)
      #choices = choices.to_a if choices.is_a?(Range)

      ## Grouped choices look like this:
      ##
      ##   [nil, []]
      ##   { nil => [] }
      ##
      #if !choices.empty? && choices.first.respond_to?(:last) && Array === choices.first.last
        #option_tags = grouped_options_for_select(choices, :selected => selected_value, :disabled => options[:disabled])
      #else
        #option_tags = options_for_select(choices, :selected => selected_value, :disabled => options[:disabled])
      #end

      #select_content_tag(option_tags, options, html_options)
    #end
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
        text = options[:use_two_digit_numbers] ? sprintf("%02d", i) : value
        text = options[:ampm] ? AMPM_TRANSLATION[i] : text

        name = @options[:default_year] || @options[:default_day]
        tag = content_tag(:option, text, tag_options)
        tag.sub!(/>/, " {{#if_eq #{@options[:index]}.#{name} compare=#{value}}}selected='selected'{{/if_eq}}>") if name

        select_options << tag
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

          name = @options[:default_month]
          tag = content_tag(:option, month_name(month_number), options)
          tag.sub!(/>/, " {{#if_eq #{@options[:index]}.#{name} compare=#{month_number}}}selected='selected'{{/if_eq}}>") if name
          month_options << tag + "\n"
        end
        build_select(:month, month_options.join)
      end
    end
  end

  class HandlebarsFormBuilder < ActionView::Helpers::FormBuilder
    include HandlebarsInputHelper

    def text_field(method, options={})
      super(method, options.reverse_merge(:value => "{{#{method}}}"))
    end

    def hidden_field(method, options={})
      super(method, options.reverse_merge(:value => "{{#{method}}}"))
    end

    def radio_button(name, value, options = {})
      original_radio = super
      radio = original_radio.gsub(/\/>$/, "{{#if_eq #{name} compare=#{value}}}checked='checked'{{/if_eq}}/>")
      radio.html_safe
    end

    def check_box(name, *args)
      original_checkbox = super
      checkbox = original_checkbox.gsub(/\/>$/, "{{#if_eq #{name} compare=true}}checked='checked'{{/if_eq}}/>")
      checkbox.html_safe
    end

    def file_field(name, options={})
      super(name, options)
    end

    def select(method, choices, options = {}, html_options = {})
      hbs_select(@object_name, method, choices, objectify_options(options.reverse_merge(:selected => "#{method}")), @default_options.merge(html_options))
    end

    def date_select(method, options = {}, html_options = {})
      hbs_date_select(@object_name, method, objectify_options(options), html_options)
    end
  end
end
