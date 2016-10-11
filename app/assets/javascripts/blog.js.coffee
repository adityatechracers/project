$ ->
  return unless $('#disqus_thread').is('*')
  disqus_shortname = 'corkcrm'
  (->
    dsq = document.createElement("script")
    dsq.type = "text/javascript"
    dsq.async = true
    dsq.src = "//" + disqus_shortname + ".disqus.com/embed.js"
    (document.getElementsByTagName("head")[0] or document.getElementsByTagName("body")[0]).appendChild dsq
  )()
