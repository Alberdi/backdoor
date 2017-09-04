
return  {
  { id = 'width', name = "Size Width", type = "integer", range = {8,128} },
  { id = 'height', name = "Size Height", type = "integer", range = {8,128} },
  { id = 'margin-width', name = "Margin Width", type = "integer",
    range = {0,16} },
  { id = 'margin-height', name = "Margin Height", type = "integer",
    range = {0,16} },
  { id = 'bootstrap', name = "Base Settings", type = 'section',
    schema = 'transformers.bootstrap', required = true },
  { id = 'rooms', name = "Room Settings", type = 'section',
    schema = 'transformers.rooms' },
  { id = 'transformers', name = "Transformer", type = 'list' }
}

