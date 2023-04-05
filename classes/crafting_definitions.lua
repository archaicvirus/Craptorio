local defs = {
  ['logistics'] = {
    [1] = {
      [1] = {name = 'Wooden Chest', sprite_id = 464, recipie = {['wood'] = 2}},
      [2] = {name = 'Iron Chest'  , sprite_id = 465, recipie = {['iron_plate'] = 8}},
      [3] = {name = 'Steel Chest' , sprite_id = 466, recipie = {['steel_plate'] = 8}},
      [4] = {name = 'Storage Tank', sprite_id = 467, recipie = {['iron_plate'] = 20, ['steel_plate'] = 5}},
    },
    [2] = {
      [1] = {name = 'Transport Belt'          , sprite_id =  468, recipie = {['gear'] = 1, ['iron_plate'] = 1}},
      [2] = {name = 'Fast Transport Belt'     , sprite_id =  469, recipie = {['gear'] = 5, ['transport_belt'] = 1}},
      [3] = {name = 'Express Transport Belt'  , sprite_id =  470, recipie = {['fast_transport_belt'] = 1, ['gear'] = 10, ['lubricant'] = 20}},
      [4] = {name = 'Underground Belt'        , sprite_id =  484, recipie = {['iron_plate'] = 10, ['transport_belt'] = 5}},
      [5] = {name = 'Fast Underground Belt'   , sprite_id =  485, recipie = {['gear'] = 40, ['underground_belt'] = 2}},
      [6] = {name = 'Express Underground Belt', sprite_id =  486, recipie = {['fast_transport_belt'] = 2, ['gear'] = 80, ['lubricant'] = 40}},
      [7] = {name = 'Splitter'                , sprite_id =  500, recipie = {['electronic_circuit'] = 5, ['iron_plate'] = 5, ['transport_belt'] = 5}},
      [8] = {name = 'Fast Splitter'           , sprite_id =  501, recipie = {['electronic_circuit'] = 10, ['gear'] = 10, ['splitter'] = 1}},
      [9] = {name = 'Express Splitter'        , sprite_id =  502, recipie = {['advanced_circuit'] = 10, ['fast_splitter'] = 1, ['gear'] = 10, ['lubricant'] = 80}},
    },
    [3] = {
      [1] = {name = 'Burner Inserter'         , sprite_id = 471, recipie = {['gear'] = 1, ['iron_plate'] = 1}},
      [2] = {name = 'Inserter'                , sprite_id = 472, recipie = {['electronic_circuit'] = 1, ['gear'] = 1, ['iron_plate'] = 1}},
      [3] = {name = 'Long-handed Inserter'    , sprite_id = 473, recipie = {['inserter'] = 1, ['gear'] = 1, ['iron_plate'] = 1}},
      [4] = {name = 'Fast Inserter'           , sprite_id = 474, recipie = {['electronic_circuit'] = 2, ['inserter'] = 1, ['iron_plate'] = 2}},
      [5] = {name = 'Filter Inserter'         , sprite_id = 475, recipie = {['electronic_circuit'] =  4, ['fast_inserter'] = 1}},
      [6] = {name = 'Stack Inserter'          , sprite_id = 476, recipie = {['advanced_circuit'] = 1, ['electronic_circuit'] = 15, ['fast_inserter'] = 1, ['gear'] = 15}},
      [7] = {name = 'Stack Filter Inserter'   , sprite_id = 477, recipie = {['electronic_circuit'] = 5, ['stack_inserter'] = 1}},
    },
  }
}

return defs