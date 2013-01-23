// Generated by CoffeeScript 1.4.0

jQuery(function() {
  /*
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
  */

  var updateGalList;
  updateGalList = function() {
    if ($('#newname input').val() !== '' && $('#newtags input').val() !== '') {
      return window.location.href = window.location.href;
    } else {
      return alert('error');
    }
  };
  $('i#new').click(function() {
    var name, tags;
    name = $('#newname input').val();
    tags = $('#newtags input').val().split(' ');
    return $.ajax({
      type: "POST",
      url: '/creategallery',
      data: {
        name: name,
        tags: tags
      },
      success: window.location.reload(),
      dataType: "json"
    });
  });
  return $('i#remove').click(function() {
    return $.ajax({
      url: '/deletegallery/' + $(this).data('id'),
      success: window.location.reload()
    });
  });
});
