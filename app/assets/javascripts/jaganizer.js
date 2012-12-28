//= require showdown/compressed/showdown

var jaganizer = {

  // Initialize chatroom's subscription & events
  init : function(jagan_key, channel_name) {
    Pusher.channel_auth_endpoint = '/jaganizer_auth';
    var pusher = new Pusher(jagan_key);

    pusher.subscribe(channel_name)
          .bind('pusher:subscription_succeeded', this.subscription_succeeded)
          .bind('pusher:subscription_error', this.subscription_failed)
          .bind('pusher:member_added', this.add_member)
          .bind('pusher:member_removed', this.remove_member)
          .bind('talk_event', this.message_received)
          .bind('update_event', this.update_message);

    $('.jaganizer_chatroom_link').click(this.toggle_chatroom);
    $('#jaganizer_updater a').click(this.updater.toggle);
    $('#jaganizer_chatbox').submit(this.send_message);
    $('#jaganizer_updater').submit(this.updater.submit);

    $('#jaganizer textarea').keypress(function(e){
      // Enter key = Send message
      if( e.which == 13 && !e.ctrlKey ) {
        e.preventDefault();
        var message = $(this).val();
        if( message != "" && !message.match(/^\s+$/) ) {
          $(this).parents('form').submit();
        }
      }
    });

    $('#jaganizer_chatbox textarea').keyup(function(e){
      // Esc key = hide chatroom
      if( e.which == 27 ) {
        jaganizer.toggle_chatroom(e);
      }
      // Up Arrow + empty textarea = edit last message (if last message exists)
      else if( e.which == 38 && $(this).val() == "") {
        jaganizer.updater.toggle(e);
      }
    });
    $('#jaganizer_updater textarea').keyup(function(e){
      // Esc key = hide updater chatbox
      if( e.which == 27 ) {
        jaganizer.updater.toggle(e);
      }
    });
  },

  // Fill the list of connected users
  subscription_succeeded : function(users) {
    users.each(jaganizer.add_member);
    jaganizer.load_logs();
  },

  // Display an error message
  subscription_failed : function(status) {
    alert("HTTP error" + status);
  },

  // Add a new connected user
  add_member : function(user) {
    $('.jaganizer_users ul').append(jaganizer.user.info_to_html(user));
  },

  // Remove a disconnected user
  remove_member : function(user) {
    $("#"+user.id).remove();
  },

  // Send a chat message
  send_message : function(event) {
    event.preventDefault();
    var text_sent = $('#jaganizer_chatbox textarea').val();
    $.ajax({
      type: 'POST',
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
      url: 'jaganizer_talk',
      data: $('#jaganizer_chatbox').serialize(),
      data_type: 'json',
      error: function(ajax_request, textStatus, errorThrown) {
        $('#jaganizer_chatbox textarea').val(text_sent);
        alert(errorThrown);
      },
      success: function(data) {
        jaganizer.updater.set_last_message(data);
      }
    });
    $('#jaganizer_chatbox textarea').val('');
  },

  // Add a new message to the chatroom
  message_received : function(data) {
    var messages_list = $('.jaganizer_messages ul');
    messages_list.append(jaganizer.user.message_to_html(data)).scrollTop(messages_list[0].scrollHeight);
  },

  // Update a message
  update_message : function(data) {
    $("#"+data.original_message_id).text(data.message).attr('id', data.updated_message_id)
                                  .parents('li').addClass('updated');
  },

  // Displays previous messages
  load_logs : function() {
    $.ajax({
      type: 'GET',
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
      url: 'jaganizer_logs',
      data: $('#jaganizer input[name="channel_name"]').serialize(),
      error: function(ajax_request, textStatus, errorThrown) {
        alert("Unable to load chat logs");
      },
      success: function(messages) {
        var messages_list = $('.jaganizer_messages ul');
        $.each(messages, function(index, message){
          messages_list.append(jaganizer.user.message_to_html(message, "log"))
                                     .scrollTop(messages_list[0].scrollHeight);
        });
        if( messages.length > 0) {
          messages_list.append($('<li>').append($('<hr>')));
        }
      }
    });
  },

  // Hide or show the chatroom
  toggle_chatroom: function(event) {
    event.preventDefault();
    $('.jaganizer_chatroom').slideToggle();

    if( $('.jaganizer_chatroom').is(':visible') ) {
      $('#jaganizer_chatbox textarea').focus();
      // Scroll to the bottom if there's only log messages
      if( $(".jaganizer_messages li").last().children('hr').length == 1 ) {
        var messages_list = $('.jaganizer_messages ul');
        messages_list.scrollTop(messages_list[0].scrollHeight);
      }
    }
    else {
      $('#jaganizer_chatbox textarea').blur();
    }
  },

  updater : {
    // Hide or show the updater form
    toggle : function(event) {
      if( $('#jaganizer_updater input[name="message_id"]').val() != "" || event.srcElement.className == "close" ) {
        event.preventDefault();
        $('#jaganizer_updater').slideToggle('fast', function(){
          if( event.type == "keyup" && event.which == 38 ) { // Edit form shown
            $('#jaganizer_updater textarea').focus().select();
          }
          else { // Edit form hidden
            $('#jaganizer_chatbox textarea').focus();
          }
        });
      }
    },

    // Set values for the last message editable
    set_last_message : function(message) {
      $('#jaganizer_updater input[name="message_id"]').val(message.id);
      $('#jaganizer_updater label span').text(jaganizer.user.time_converter(message.timestamp));
      $('#jaganizer_updater textarea').val(message.content);
    },

    submit : function(event) {
      event.preventDefault();
      $.ajax({
        type: 'POST',
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        url: 'jaganizer_update',
        data: $('#jaganizer_updater').serialize(),
        data_type: 'json',
        error: function(ajax_request, textStatus, errorThrown) {
          alert(errorThrown);
        },
        success: function(data) {
          $('#jaganizer_updater').slideToggle('fast', function(){
            $('#jaganizer_chatbox textarea').focus();
          });
          jaganizer.updater.set_last_message(data);
        }
      });
    }
  },

  user : {
    info_to_html : function(user) {
      var list_item = $('<li>').attr({id : user.id}).addClass('jaganizer_user_info jaganizer_clearfix');
      var avatar = user.info.avatar ? $('<img>').attr({src : user.info.avatar, alt : user.info.username}).addClass('jaganizer_avatar') : '';
      var username = $('<span>').addClass('jaganizer_username').text(user.info.username);
      var userdetails = user.info.details ? $('<span>').addClass('jaganizer_userdetails').text(user.info.details) : '';

      return list_item.append(avatar)
                      .append($('<p>')
                              .append(username)
                              .append($('<br>'))
                              .append(userdetails)
                      );
    },
    message_to_html : function(data, css_class) {
      var list_item = $('<li>').addClass('jaganizer_chat_message');
      if( typeof css_class !== 'undefined' ) {
        list_item.addClass(css_class);
      }
      var avatar = data.user_info.avatar ? $('<img>').attr({src : data.user_info.avatar, alt : data.user_info.username}).addClass('jaganizer_avatar') : '';
      var username = $('<span>').addClass('jaganizer_username').text(data.user_info.username);
      var md_converter = new Showdown.converter();
      var message = $('<p>').attr('id',data.id).addClass('jaganizer_message').html(md_converter.makeHtml(data.message));
      var time = $('<span>').addClass('jaganizer_time').text(this.time_converter(data.timestamp));

      return list_item.append($('<p>').addClass('jaganizer_clearfix')
                              .append(avatar)
                              .append(username)
                              .append(time)
                      )
                      .append(message);
    },
    time_converter : function(timestamp) {
      var a = new Date(timestamp*1000);
      var now = new Date();
      var day = a.getDate();
      var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      var minutes = a.getMinutes();
      var hours = a.getHours();

      if (day < 10) {
        day = "0" + day.toString();
      }
      if (minutes < 10) {
        minutes = "0" + minutes.toString();
      }
      if (hours < 10) {
        hours = "0" + hours.toString();
      }

      if(a.getDate() == now.getDate() && a.getMonth() == now.getMonth() && a.getFullYear() == now.getFullYear())
        return hours + ':' + minutes;
      else
        return day + ', ' + months[a.getMonth()] + ' ' + hours + ':' + minutes;
    }
  }
}