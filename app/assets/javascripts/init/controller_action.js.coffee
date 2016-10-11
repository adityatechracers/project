$(document).ready ->
  controller = $('body').data('controller')
  action = $('body').data('action')
  _controller = cork[controller]
  if _controller
    prototype = _controller.prototype
    if prototype[action] or prototype.ready
      _controller = new _controller
      if _controller[action]
        _controller[action]()
      else
        _controller.ready()
  return
