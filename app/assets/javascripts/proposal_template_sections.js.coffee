# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if $('form#edit_proposal_template').is('*')
    saving = false
    saveTimer = false
    fixSectionNumbers = (e,ui)-> $('.proposal-section-list li').each (i,v)-> $(v).find('span.section-position').html("##{i+1}")
    saveSectionNumbers = ->
      if saveTimer!=false
        clearTimeout saveTimer
        saveTimer = false
      if saving then saveTimer = setTimeout(saveSectionNumbers, 1000) else
        saving = true
        section_positions = {}
        item_positions = {}
        $('.proposal-template-section').each (sIndex)->
          sId = $(@).attr("data-section")
          section_positions[sId] = sIndex + 1
          item_positions[sId] = {}
          $(".proposal-template-item[data-section=#{sId}]").each (iIndex)->
            item_positions[sId][$(@).attr("data-item")] = iIndex
        $.post "/manage/proposal_templates/#{$('.template-widget').data("template")}/reorder_sections", {section_positions: section_positions, item_positions: item_positions}, (data)->
          saving = false
          alertify.success(data)
    hideSection = (li)->
      li.find(".toggle-section-btn").tooltip("hide").attr("data-original-title","Expand").data("original-title","Expand").data('action', 'expand').tooltip("fixTitle")
        .children("i").removeClass("icon-contract-2").addClass("icon-expand-2")
      li.find(".proposal-section-form-wrapper").hide "slide", {direction:"up"}, 400, -> 
        li.addClass("invisible-well")
    showSection = (li)->
      li.find(".toggle-section-btn").tooltip("hide").attr("data-original-title","Collapse").data("original-title","Collapse").data('action', 'collapse').tooltip("fixTitle")
        .children("i").removeClass("icon-expand-2").addClass("icon-contract-2").end().end()
      li.find(".proposal-section-form-wrapper").show "slide", {direction:"up"}, 400, -> 
        li.removeClass("invisible-well")

    # PROPOSAL SECTIONS
    $('.proposal-section-list').sortable
      axis:"y"
      handle:".section-drag-handle"
      cancel:""
      change:fixSectionNumbers
      stop:(e,ui)->
        fixSectionNumbers(e,ui)
        saveSectionNumbers()
    $('.proposal-section-header-controls button.btn').click (e)->
      e.preventDefault()
      li = $(@).parents(".proposal-template-section")
      switch $(@).data('action')
        when 'collapse'
          hideSection(li)
        when 'expand'
          showSection(li)
        when 'move-up'
          li.insertBefore(li.prev())
          fixSectionNumbers()
          saveSectionNumbers()
        when 'move-down'
          li.insertAfter(li.next())
          fixSectionNumbers()
          saveSectionNumbers()

    $('#toggle-proposal-sections-btn').click (e)->
      e.preventDefault()
      if $(@).data("original-title") == "Collapse all"
        $(@).tooltip("hide").attr("data-original-title","Expand all").data("original-title","Expand all").tooltip("fixTitle").children("i").removeClass("icon-contract-2").addClass("icon-expand-2")
        $('.proposal-section-list li').each -> hideSection($(@))
      else
        $(@).tooltip("hide").attr("data-original-title","Collapse all").data("original-title","Collapse all").tooltip("fixTitle").children("i").removeClass("icon-expand-2").addClass("icon-contract-2")
        $('.proposal-section-list li').each -> showSection($(@))

    # PROPOSAL ITEMS
    $('.proposal-item-controls button.btn').click (e)->
      e.preventDefault()
      tr = $(@).parents("tr")
      switch $(@).data("action")
        when "move-up"
          tr.insertBefore(tr.prev())
          saveSectionNumbers()
        when "move-down"
          tr.insertAfter(tr.next())
          saveSectionNumbers()

    $('#save-proposal-header-btn').click (e)->
      e.preventDefault()
      $('form#edit_proposal_template').submit()
