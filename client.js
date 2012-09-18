function poll(callback) {
  $.ajax({
    url: "/messages",
    ifModified: true,
    dataType: "json",
    success: function(data, textStatus, jqXHR) {
      callback(data);
    },
    complete: function() { poll(callback) }
  });
}

function formatMessage(message) {
  var username = $("<span>").addClass("username").text(message.username);
  return $("<p>").text(message.body).prepend(username);
}

$(function() {
  var chat = $("#chat");
  poll(function(data) {
    var message = formatMessage(data);
    chat.prepend(message);
  });

  $("form").submit(function(event) {
    event.preventDefault();
    var username = this.username.value;
    var message = this.message.value;
    if (message.length > 0 && username.length > 0) {
      $.ajax({
        type: "POST",
        url: "/messages",
        data: JSON.stringify({ username: username, body: message }),
        contentType: "application/json"
      });
    }
    this.message.value = "";
  });
});
