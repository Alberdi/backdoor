
return  {
  { id = 'theme', name = "Theme", type = 'enum', options = 'domains.theme' },
  { id = 'bootstrap', name = "Base Settings", type = 'section',
    schema = 'transformers.bootstrap', required = true },
  { id = 'fixed_layout', name = "Fixed Layout Settings", type = 'section',
    schema = 'transformers.fixed_layout' },
  { id = 'random_fill', name = "Random Fill Settings", type = 'section',
    schema = 'transformers.random_fill' },
  { id = 'automata', name = "Automata Settings", type = 'section',
    schema = 'transformers.automata' },
  { id = 'holes', name = "Holes Settings", type = 'section',
    schema = 'transformers.holes' },
  { id = 'rooms', name = "Room Settings", type = 'section',
    schema = 'transformers.rooms' },
  { id = 'maze', name = "Maze Settings", type = 'section',
    schema = 'transformers.maze' },
  { id = 'connections', name = "Connection Settings", type = 'section',
    schema = 'transformers.connections' },
  { id = 'remove_disconnected', name = "Disconnection Removal Settings",
    type = 'section', schema = 'transformers.remove_disconnected' },
  { id = 'deadends', name = "Deadend Settings", type = 'section',
    schema = 'transformers.deadends' },
  { id = 'fillings', name = "Fillings Settings", type = 'section',
    schema = 'transformers.fillings' },
  { id = 'exits', name = "Exit Settings", type = 'section',
    schema = 'transformers.exits' },
  { id = 'drops', name = "Drops Settings", type = 'section',
    schema = 'transformers.drops' },
  { id = 'altars', name = "Altar Settings", type = 'section',
    schema = 'transformers.altars' },
  { id = 'encounters', name = "Encounter Settings", type = 'section',
    schema = 'transformers.encounters' },
  { id = 'props', name = "Prop Settings", type = 'section',
    schema = 'transformers.props' },
}

