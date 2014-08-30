$ ->
  $('a[class=editcontentbtn]').click ->
    id = this.dataset.commentId
    content_div = "#content#{id}"
    value = $(content_div).html()
    $(content_div).html("<form id='update_comment' action='/comments/update_comment' method='post'>
      <input type='text' name='content' value='#{value}'>
      <input type='hidden' name='id' value='#{this.dataset.commentId}'>")