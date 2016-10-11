class ChosenSelect 
  @update: (el, val) -> 
    $(el).val(val).trigger('liszt:updated').trigger('change')
    
cork.ChosenSelect = ChosenSelect  