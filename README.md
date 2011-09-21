# handlebars\_haml\_assets

Already using haml\_asset to have access to your `form_for` helper in the Rails 3.1 asset pipeline? Great! Maybe you're already using `handlebars_assets` to combine HAML and handlebars to have dynamic templates in your asset pipeline. Hopes are, by then, you got tired to add the attribute binding by hand ;)

Now either you start out and write your own Rails 3 FormBuilder, are you just drop in handlebars\_haml\_assets.

# what it does

handlebars\_haml\_assets adds a new `form_for` command called `hbs_form_for` that automatically tries to figure out which attribute to bind your tags to.

e.g.

    = hbs_form_for :users do |u|
      = u.text_field :name

will create this for you (I've reduced the output for clarity):

    <form>
      <input value="{{name}}" />
    </form>

notice the Handlebars.JS binding which got automatically added for you.

Now you can start to customize things if you like - or overwrite your attribute binding, if the default does not work for you:

    = hbs_form_for :users do |u|
      = u.text_field :name, value: '{{lastname}}, {{firstname}}'

Behind the scenes, all this does is to `reverse_merge` your options value key with the method name you're trying to access.

# requirements

In order for this to work, you'll need:

 - haml_asset
 - rails 3.1

The `hbs_form_for` helper will only be available within your asset\_pipeline.