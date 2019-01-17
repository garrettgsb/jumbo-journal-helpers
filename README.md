# A Simple Introduction to Rails Helpers

To learn about Rails helpers, we are going to play around with this simple (and perhaps familiar) journaling app. When an application reaches even a level of slight complexity, it's a good idea to reach for tools to help us keep that complexity under control. We will review some tools that are **conceptual**:

* REST
* BREAD
* Resource-oriented architecture
* MVC

And learn about some of the **practical tools** that actually implement those ideas:

* Route helpers
  - HTTP helpers
  - Resourceful routing
* View helpers
  - Form builders
  - Named route helpers
  - Link helpers
* Custom helpers
  - Helper methods in controllers
  - Helper methods in views

This project has several moving parts: Some were implemented the hard way. Some were implemented the wrong way. And some will hopefully demonstrate patterns that will increase expressiveness, and raise the ceiling on the complexity that you can handle.

## Setup

This project was designed in Rails v5.2.0. If you would like to run it locally, just run Bundler to install the gems:

```
bundle
```

Or:

```
bundle install
```

Once that succeeds, you're ready to create and seed the database. Demo applications are more fun when they have a bit of data to play with:

```
rails db:create db:migrate db:seed
```

Then, start it up with:

```
rails s
```

Then point your favorite browser to `localhost:3000` and do some journaling. Determining the credentials for the seed user is an exercise left to the reader.

# REST Review

REST is a convention. REST is a convention. REST is a convention.

REST is a plan for organizing routes in a web app. **When you want to do _BREAD_ stuff to _resources_, REST is a good plan.**

## What's BREAD again?

* Answers the question "What kind of stuff can we do with resources?"
  - i.e. "How can we modify and edit them?"
* Deals with **collections** of resources, as well as individual **entries** in a collection
* Sounds nicer than CRUD

| Action | a.k.a | Method | Path | Example |
|--------|-------|--------|------|---------|
| Browse | Index | `GET` | Collection name | `GET /articles` |
| Read   | Show  | `GET` | Entry name | `GET /articles/1` |
| Edit   |  -   | `PUT`* | Entry name | `PUT /articles/1`
| Add    | New   | `POST`/`PUT`* | Collection name | `POST /articles` |
| Delete | DESTROY 👾 | `POST`/`DELETE`* | Entry name | `POST /articles/1` |

\*Varies, depending on usage and environment

## What's a resource again?

Resources are the things that a client can ask for. They are the _nouns_ in your business logic, and usually, they refer to your _permanent data_:

* Users
* Photos
* Articles
* Products

Not by coincidence, your resource names map naturally to both our **RESTful routes**, and our **database table names**.

# A Word on Rails Architecture

Rails is a resource-based framework. It's a highly opinionated framework that streamlines the process of **doing BREAD stuff to resources**.

**Rails leverages the fact that RESTful routes map well to database operations**

In the prototypal Rails app, once we've defined the database schema, we can infer a significant amount of the application's behavior.

Consider the following schemas: What things do we expect a user to be able to do in each app? What RESTful routes do we expect each app to have, based on the database schema?

## Journal App

| Table Name | Fields |
|------------|--------|
| Users | id, name, password, email |
| Journals | id, user_id, name |
| Entries | id, journal_id, title, body |

## eCommerce App

| Table Name | Fields |
|------------|--------|
| Customers  | id, name, password, email, shipping_address |
| Orders     | id, customer_id, payment_completed |
| LineItems  | id, order_id, product_id, quantity |
| Products   | id, name, description, photo_url, price, quantity |

# Social Media App

| Table Name | Fields |
|------------|--------|
| Users      | id, name, password, email, admin |
| Boards     | id, name |
| Threads    | id, user_id, board_id, title |
| Posts      | id, thread_id, user_id, updoots, downdoots, approved, body |
| Moderators | id, user_id, board_id |



## Aggressively Conventional

If we decide to uphold a resource-oriented architecture, then RESTful routing and our database operations map together quite naturally. As a result, many of the problems involved in building a Rails app are straightforward but tedious.

For example: **"Ask for a page that corresponds to an entry in the database"**

We might lay out the steps like this:
* Receive the route that the client requested (e.g. `GET /articles/1`)
  * Controlling - Parse that route into an action (e.g. "Get the page for the article with ID 1")
  * Go look up the relevant database entry (e.g. `Article.find(1)`)
  * Create a client-facing representation of that data (e.g. an HTML page or JSON object)
  * Send the representation as a response

As the complexity of our app grows, we accumulate more database tables, more routes, more views. Articles require comment threads, and comment threads in turn have comments. Users must be able to send private messages to each other. We realize that what we really need is three types of admins. Maintaining all of this plumbing by hand becomes a hairball and a headache, even though each individual process is straightforward.

So let's not do it by hand. Let's make a computer do it. The tools that we use to make computers do these straightforward but tedious tasks-- whether provided by the framework or written by us-- are called **helpers**.

# Helpers are here to help

In a Rails app, helpers fall into two broad categories:

* Helpers included in the framework
* Helpers written by us

**Helpers included in the framework** mostly help us with the plumbing of the app. We will be

**Helpers written by us** allow us to make our code (especially our views) easier to read and more **declarative** by abstracting

# Route Helpers

* We declare our routes in `config/routes.rb`
* Routes can be declared using either **HTTP Helpers** or by using **resource routing**
* Each route has a corresponding **controller** and **action**
  - The public **methods** on a **controller** are its **actions**
* A basic route looks like this:

**config/routes.rb**
```
get '/articles/:id', to: 'articles#show'
```

When the app receives a request to `/articles/:id`, it will go to the Articles controller and invoke its Show method. This is analogous to a route like this in Express:

```
app.get('/articles/:id', (req, res) => { ... });
```

But whereas Express accepts a callback function as a parameter, Rails passes control to the (appropriately-named) controller.

## HTTP Helpers

https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-get

Rails uses five HTTP methods, and therefore has five HTTP helpers. In `config/routes.rb`, you might see an (incomplete) set of RESTful routes that uses all five, like this:

```
get '/articles', to: 'articles#index'
post '/articles', to: 'articles#create'
put '/articles/:id', to: 'articles#update'
patch '/articles/:id', to: 'articles#update'
delete '/articles/:id', to: 'articles#destroy'
```

But there is no reason that we are limited to just RESTful routes, or even BREAD actions. As long as the route points to a valid action in a valid controller, we can set up any route we want:

```
get '/profile', to: 'users#my_profile'
put '/login', to: 'sessions#create'
get '/dashboard', to: 'dashboard#gimme_those_graphs'
get '/thermostats/:id/increase-temp/:degrees', to: 'thermostats#increase_temp'
post '/reset', to: 'application#nuke_everything'
```

All of these are just aliases for the `match` method. The documentation for the `match` method contains most of the juicy information about advanced options for setting up routes:

https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-match


## Resourceful Routing

https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources_path_names

When you want RESTful routes in a hurry, Rails has you covered with resourceful routing helpers. By simply declaring "I have a resource/resources called X," Rails is able to pick it up from there: All of the BREAD routes are created for you, all based on the name of the resource that you provided to it. For instance, if we declare the following resource:

```
resources :reservations
```

Then we can see which routes Rails has made available (and which controller action they invoke) by typing `rails routes` in the command line (or `rake routes` for Rails 4 and below):

```
Prefix             Verb      URI Pattern                         Controller#Action

reservations       GET       /reservations(.:format)             reservations#index
                   POST      /reservations(.:format)             reservations#create
new_reservation    GET       /reservations/new(.:format)         reservations#new
edit_reservation   GET       /reservations/:id/edit(.:format)    reservations#edit
reservation        GET       /reservations/:id(.:format)         reservations#show
                   PATCH     /reservations/:id(.:format)         reservations#update
                   PUT       /reservations/:id(.:format)         reservations#update
                   DELETE    /reservations/:id(.:format)         reservations#destroy
```

Compare that result to the BREAD operations. With that one line, all of the routes for our BREAD actions are covered! Of course, we still need to implement the actual application behavior in the controllers.

### Adding Constraints

Resourceful routing can be configured to limit which actions it draws routes for, using the `only` and `except` options. Imagine that you want to draw all RESTful routes, except for `delete`:

```
resources :reservations, except: :delete
```

If you find that you also have no use for `index`, you can give `except` an array instead:

```
resources :reservations, except: [:delete, :index]
```

The inverse of this is to declare which routes you want to draw, rather than which routes you want to include, using `only`. The routes drawn by the code above would be equivalent to the routes drawn by the code below:

```
resources :reservations, only: [:show, :create, :new, :update, :edit]
```

# View Helpers

As much as possible, we should look for ways to keep our views **clean**, and **declarative**. Rails provides a number of helpers to help us clean up our views, and improve the cohesion between our data and our interface. We are going to talk about **form helpers** and **URL helpers**.

## Form Helper

https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html

Because so much of BREAD activity (especially E and A) ordinarily rely on users filling in and submitting forms, Rails has put great effort into shoring up the robustness and efficiency of the Internet's humblest hero: The HTML form. With the Rails Form Helper (and associated tools), we are able to write ERB code that generates a super-powered form that is tightly linked to the model that it is attempting to manipulate.

* Creates a form that are savvy about which model it belongs to
* Auto-populates fields if the object in question already exists (e.g. while performing an edit)
* Warns you if your form is wrong (with an error about fields that don't match the model's fields)
* Protects against forgery by embedding a hidden authenticity token
* Saves you the trouble of working around some of HTML's quirks (such as checkbox data)
* Sends the form data to the server in a format that is easy for the controller to work with

A form helper starts with the invocation of the `form_for` method, followed by the resource (an ActiveRecord object), followed by any options. Then, we define a block with `f` (by convention) as a parameter, where `f` represents the FormBuilder object. Then we go ahead and tack all of the fields we want onto `f`. A super basic form, in which we can only change a person's first_name, might look like this:

```
<%= form_for @person do |f|%>
  <p>First Name:</p>
  <%= f.text_field :first_name %>
  <%= f.submit "Change that name" %>
<% end %>
```

Notice that it's fine to put regular HTML inside of this block, too. When the form is submitted, it will be available in the responding controller under `params[:person]`. Here is what a slightly more complex form would look like:

```
<%= form_for @person do |f| %>
  <p>First Name:</p>
  <%= f.text_field :first_name %>

  <p>Last Name:</p>
  <%= f.text_field :last_name %>

  <p>Email Address:</p>
  <%= f.email_field_tag :email %>

  <p>Age:</p>
  <%= f.number_field_tag :age %>

  <p>Favorite Color:</p>
  <%= f.color_field_tag :favorite_color %>

  <p>Battery Size</p>
  <%= f.text_field :battery_size %>

  <%= f.submit "Change that name" %>
<% end %>
```

This will render a perfect form, completely aligned to the `@person` resource that we are accessing. Just kidding, there's an error there: The observant reader will see that there is a `:battery_size` field specified, but a person does not have a battery size. Rails will prevent the form from being rendered, triggering an error insisting as much. That's actually good: It's better to catch these things loudly and early, instead of letting them sneak into the woodwork as bugs.

When the controller receives the form submission, the data will be available in the `params`, nested under a key that corresponds to the model name. For instance, to access the `person` form above, we would expect to find the data in `params[:person]`.

**MAJOR GOTCHA:** Rails has a feature called "strong params" enabled by default. That means that you can't just pass any params you want-- The controller needs to specifically allow them. The pattern for allowing specific params looks like this:

```
params.require(:resource).permit(:field1, :field2, :field3)
```

Or, using our person example:

```
params.require(:person).permit(:first_name, :last_name, :email, :age, :favorite_color)
```

Read more about strong params here:

https://edgeguides.rubyonrails.org/action_controller_overview.html#strong-parameters

## Named Route Helpers

Remember how when you call `rails routes` (or `rake routes`), there is a column called `Prefix`? One of the things that that prefix is for is generating **named route methods** that you can call from inside of controllers and views. You can get the path or full URL for any of those routes by calling the matching prefix with `_path` or `_url` appended to the end, like this:

```
<%= reservations_path %>
Gives '/reservations'

<%= reservations_url %>
Gives 'http://localhost:3000/reservations', if you're developing locally

<%= reservation_path %>
Gives '/reservations/10' if you are on a page with '/reservations/10' somewhere in the URL (such as '/reservations/10/edit')

<%= edit_reservation_path %>
Gives '/reservations/10/edit' if you are on a page with '/reservations/10' somewhere in the URL
```

You can use these anywhere in views and controllers, but they are seen most commonly for **redirects** in the controller, and **link_to tags** in the view, the latter of which we'll talk about next.

## URL Helpers

https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html

Rails provides a variety of Url Helpers to help us build the navigational controls for our app. We are going to focus on `link_to`, but the others work similarly, and can be found in the documentation referenced above.


### link_to

`link_to` is a method that can be invoked inside any Rails view. Essentially, it just creates an <a> tag, but there are some cool benefits of using the helper instead of writing the raw HTML ourselves:

**We can use named route helpers**

This is nice because instead of writing something like this:

```
<a href="/reservations/#{@reservation.id}/edit">Edit Reservation</a>
```

We can just write this:

```
<%= link_to "Edit Reservation", edit_reservation_path %>
```

It's just a little bit quicker to read, and less to get wrong. Also, if we _do_ get it wrong, we get a nice descriptive error, instead of letting a user stumble onto our broken code.

**We can make a quick back button**

`link_to` has shortcuts for handy stuff, like making a link which takes you back to the last page you visited. Just pass it the symbol `:back` instead of a URL.

```
<%= link_to "Back", :back %>
```

**Lets us set an HTTP method**

Normally, anchor tags trigger a GET request, but sometimes, we would like the request to use a different verb, instead:

* Clicking "RSVP" on an invitation should trigger a PUT request
* Clicking "Delete" on a comment should trigger a DELETE request
* Clicking "+" or "-" on a smart thermostat control should trigger a POST request

This is surprisingly cumbersome to do without a helper, and might involve doing something convoluted, like this:

```
<form id="myform" method="post" action="target.html">
  <input type="hidden" name="name" value="value" />
  <a onclick="document.getElementById('myform').submit();">click here</a>
</form>
```

Yuckers.

With `link_to`, setting the method couldn't be easier:

```
<%= link_to "Delete", comment_path, class: "button", method: :delete %>
```

**Add a confirmation box**

`link_to` also lets us easily add a confirmation dialog to any link, to mitigate our users' bad decisions.

```
<%= link_to "Delete", comment_path, class: "button", method: :delete, data: { confirm: "Are you sure?" } %>
```


# Custom Helpers

Rails gives us the means to create our own helpers to make our code easier to organize. While the helper pattern can be applied in many places, we are going to look at two: **Private methods** on controllers, and **helper modules** that are included in views.

## In Controllers

Often, we notice that we are repeating common code throughout controllers, such as accessing the current user:

```
@current_user = session[:user_id] && User.find(session[:user_id])
```

When we notice this, it may be time to write a custom, private helper method to ensure that every time the current user is looked up, it is being done in a consistent way:

```
class UsersController < ApplicationController

  .
  .
  .

  private

  def set_current_user
    @current_user = session[:user_id] && User.find(session[:user_id])
  end
end
```

### Shared Helpers

Unlike Models, which all inherit from the library directly (`ActiveRecord::Base`), Controllers mostly inherit from another controller: `ApplicationController`. Only `ApplicationController` inherits from `ActiveController::Base`. The significance of this is that helper methods in ApplicationController are available to _all_ controllers. It may be prudent to promote some helper methods, such as `set_current_user`, to the application level, where _every_ controller can use it.

## In Views

In `app/helpers`, we see that each controller is generated with an accompanying `helper` module. One might expect that these make helper methods available to the controller, but in fact, these are meant for the view. Complex, tedious, or hard-to-read operations in the view can be pulled out to a helper to improve readability and reusability. Take, for example, this function that prints a human-readable report of the current time and date out on the page:

```
<p><%= Time.now.to_formatted_s(:long_ordinal) %></p>
```

Not too bad, but it's quite verbose. If we think that other views may also want to see the human-readable time and date, it might be worth putting it into a helper method. We can refactor to look like this:

**app/helpers/application_helper.rb**

```
module ApplicationHelper
  def current_time
    Time.now.to_formatted_s(:long_ordinal)
  end
end
```

Now, the `current_time` method is available in _every_ view. When we want to use it, we can just do this:

```
<p><%= current_time %></p>
```

Much better 🧐
