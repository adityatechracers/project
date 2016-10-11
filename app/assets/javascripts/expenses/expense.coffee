class Expense
  edit: ->
    is_update = true
    $(document).on "keyup", ".chzn-search input", ->
      key = $('.chzn-search input').val()
      if is_update
        $.ajax
          url: '/expenses/expense_edit_jobs'
          dataType: 'text'
          beforeSend: ->
            $('ul.chzn-results').append('Loading ...')
            return
          success: (data) ->
            $('ul.chzn-results').empty()
            $('#expense_job_id').html '<option value=""></option>'
            $('#expense_job_id').append data
            $('#expense_job_id').trigger('liszt:updated');
            $('.chzn-search input').val(key)
            is_update = false
            return
        return
    
cork.Expense = Expense
