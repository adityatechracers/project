class Editor
  @activate: (token) -> 
    $.getJSON('/config/froala.json', (config) ->
      $('.froala').froalaEditor(
        key: config.key
        imageUploadURL: '/uploads/froala'
        imageUploadParams: 
          authenticity_token: token
      )
    )
cork.Editor = Editor


