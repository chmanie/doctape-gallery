jQuery ->
  ###
  $(document).on('click', 'i#edit', ->
    galID = $(this).data('id')
    sel = {}
    sel.name = $('tr#gal_' + galID + ' td#name')
    sel.tags = $('tr#gal_' + galID + ' td#tags')
    sel.actions = $('tr#gal_' + galID + ' td#actions')
    sel.name.html('<input type="text" value="' + sel.name.html() + '"></input>')
    sel.tags.html('<input type="text" value="' + sel.tags.html() + '"></input>')
    sel.actions.html('<i id="save" data-id="' + galID + '" class="icon-ok icon-white"></i>')
  )

  $(document).on('click', 'i#save', ->
    galID = $(this).data('id')
    $.ajax
      type: "POST"
      url: '/savegallery'
      data: {name: 'Bla', tags: ['tag1', 'tag2']}
      success: updateGalList()
      dataType: "json"
    updateGalList = ->
      sel = {}
      sel.name = $('tr#gal_' + galID + ' td#name')
      sel.tags = $('tr#gal_' + galID + ' td#tags')
      sel.actions = $('tr#gal_' + galID + ' td#actions')
  )
  ###

  updateGalList = ->
    if $('#newname input').val() != '' && $('#newtags input').val() != ''
       window.location.href = window.location.href
    else
      alert('error')

  $('i#new').click( ->
    name = $('#newname input').val()
    tags = $('#newtags input').val().split(' ')
    $.ajax
      type: "POST"
      url: '/creategallery'
      data: {name: name, tags: tags}
      success: window.location.reload()
      dataType: "json"
  )
  $('i#remove').click( ->
    $.ajax
      url: '/deletegallery/' + $(this).data('id')
      success: window.location.reload()
  )