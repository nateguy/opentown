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

  $("#plan_status_status_id").change ->
    plan_status_change()

  plan_status_change = ->
    status_id = $("#plan_status_status_id").val()
    set_stage_number = $(".plan_status[data-id='#{status_id}']").length + 1
    $("#plan_status_stage").val(set_stage_number)

  plan_status_change()


