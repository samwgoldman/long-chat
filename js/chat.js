function poll(callback) {
  $.ajax({
    url: "/messages",
    ifModified: true,
    success: function(data, statusText, jqXHR) {
      var responseStatus = jqXHR.status;
      var contentType = jqXHR.getResponseHeader("Content-Type");
      if (responseStatus == 200 && contentType == "application/json") {
        callback(data);
      }
    },
    complete: function() { poll(callback) }
  });
}

function formatMessage(message) {
  var username = $("<span>").addClass("username").text(message.username);
  return $("<p>").text(message.text).prepend(username);
}

$(function() {
  var chat = $("#chat");
  poll(function(data) {
    var messages = $.map(data, formatMessage);
    chat.prepend(messages);
  });

  $("form").submit(function(event) {
    event.preventDefault();
    var username = this.username.value;
    var message = this.message.value;
    if (message.length > 0 && username.length > 0) {
      $.post("/messages", {
        username: username,
        message: message
      });
    }
    this.message.value = "";
  });
});
