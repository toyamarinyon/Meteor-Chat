@Messeages = new Meteor.Collection "Messages"

@Messeages.validate = (message) ->
  if not message.user
    return false
  return true

if Meteor.is_client
  Template.main.user = () ->
    return Session.get "user"

  Template.main.events =
    'click h1' : () ->
      Router.navigate "", true
    'click span.user' : (e) ->
      Router.navigate "/" + $(e.target).html(), true

  Template.login.events =
    'click button' : () ->
      if user = $("#form-user").val()
        Session.set "user", user

  Template.timeline.user = () ->
    return Session.get "user"

  Template.entry.events =
    'click button' : () ->
      message =
        user: Session.get "user"
        text: $("#form-text").val()
        posted_at: Date.now()

      if not Messeages.validate message
        alert 'failed validation'
        return

      entry = Messeages.findOne user: message.user, message: message.text
      console.log(entry)
      if entry
        Messeages.update { _id: entry._id }, { $set: message: message.text }
        console.log('update');
      else
        console.log('insert');
        console.log(message);
        Messeages.insert message

      for elem in ['text']
        $("#form-#{elem}").val("")

  Template.messages.messages = () ->
    user_filter = Session.get 'user_filter'
    selector = if user_filter then { user: user_filter } else {}
    return Messeages.find selector, { sort: { posted_at: -1 } }

  Template.messages.events =
    'click span.navigate' : () ->
      Router.navigate "", true

  Template.messages.user_filter = () ->
    return Session.get 'user_filter'

  BookmarkRouter = Backbone.Router.extend
    routes:
      "" : "timeline"
      ":user" : "messages"
    timeline : () ->
      Session.set 'user_filter', null
    messages : (user) ->
      Session.set 'user_filter', user

  Router = new BookmarkRouter

  Meteor.startup () ->
    Backbone.history.start pushState: true

if Meteor.is_server
  Meteor.startup () ->
