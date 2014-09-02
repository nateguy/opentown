$ ->
  $('a[class=editcontentbtn]').click ->
    id = this.dataset.commentId
    content_div = "#content#{id}"
    value = $(content_div).html()
    $(content_div).html("<form id='update_comment' action='/comments/update_comment' method='post'>
      <input type='text' name='content' value='#{value}'>
      <input type='hidden' name='id' value='#{this.dataset.commentId}'>")

  zones = document.querySelectorAll(".zone")

  for zone in zones
    zone.addEventListener('dragstart', (e) ->

      zoneid = $(this).attr("data-id")

      e.dataTransfer.setData("text", zoneid)
      false
    )
  # dropbox = document.querySelector("#infoBoxDrop")
  # dropbox.addEventListener('dragenter', (e) ->
  #   )
  # dropbox.addEventListener('dragover' , (e) ->
  #   e.preventDefault()
  #   false
  #   )
  # dropbox.addEventListener('dragleave', (e) ->
  #   )
  # dropbox.addEventListener('drop', (e) ->
  #   console.log "dropped"
  #   e.preventDefault()
  #   false
  #   )
  console.log zones
  #zones = $(".class")

