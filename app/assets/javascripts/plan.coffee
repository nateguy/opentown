$ ->
  $('.editcontentbtn').click ->

    console.log this.dataset.commentId
    id = "#editcontent" + this.dataset.commentId
    action = '/comments/' + this.dataset.commentId
    value = $(id).html()
    console.log value
    $(id).html("<form action='/comments' class='update_comment' id='update_comment'
      method='patch'>
      <input type='text' name='content' value=#{value}>
      <input type='hidden' name='id' value=#{this.dataset.commentId}>
      <input type='submit' value='submit'></form>")