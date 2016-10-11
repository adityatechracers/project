jQuery ->
  new CarrierWaveCropper()

class CarrierWaveCropper
  constructor: ->
    $('#user_image_cropbox').Jcrop
      aspectRatio: 1
      setSelect: [0, 0, 100, 100]
      onSelect: @update
      onChange: @update
      boxHeight: 600
      boxWidth: 800

  update: (coords) =>
    $('#user_image_crop_x').val(coords.x)
    $('#user_image_crop_y').val(coords.y)
    $('#user_image_crop_w').val(coords.w)
    $('#user_image_crop_h').val(coords.h)
    @updatePreview(coords)

  updatePreview: (coords) =>
    $('#user_image_previewbox').css
      width: Math.round(100/coords.w * $('#user_image_cropbox').width()) + 'px'
      height: Math.round(100/coords.h * $('#user_image_cropbox').height()) + 'px'
      marginLeft: '-' + Math.round(100/coords.w * coords.x) + 'px'
      marginTop: '-' + Math.round(100/coords.h * coords.y) + 'px'
