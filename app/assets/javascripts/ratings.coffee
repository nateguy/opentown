$ ->

  $('.star-rating :radio').bind(

    mouseover:
      (e) ->
        $('.choice').html( this.value + ' out of 5' )

    mouseout:
      (e) ->
        $('.choice').html( 0 + ' out of 5' )
        )
    .click (e) ->
        $('.star-rating :radio').unbind('mouseover')
        $('.star-rating :radio').unbind('mouseout')
        $('.choice').html( this.value + ' out of 5' )





  # $(".rating_box").html('
  #   <div class="star 1"></div>
  #   <div class="star 2"></div>
  #   <div class="star 3"></div>
  #   <div class="star 4"></div>
  #   <div class="star 5"></div>')

  # resetEffect = ->
  #   for index in [1..5]
  #     $(".star.#{index}").css("background-color", "#999999")

  # setEffect = (rating_value) ->
  #   resetEffect()
  #   for index in [1..rating_value]
  #     $(".star.#{index}").css("background-color", "rgb(255,100,0)")

  # $(".rating_box .star").bind(

  #   mouseover:
  #     (e) ->
  #       rating_value = parseInt(e.currentTarget.classList[1])
  #       setEffect(rating_value)

  #   mouseout:
  #     (e) ->
  #       resetEffect()
  #       )
  #   .click (e) ->
  #       rating_value = parseInt(e.currentTarget.classList[1])
  #       setEffect(rating_value)
  #       $("#rating_form").val(rating_value)
  #       $(".rating_box .star").unbind('mouseover')
  #       $(".rating_box .star").unbind('mouseout')
