


############################################################################################################
TEXT                      = require './main'
# TYPES                     = require 'coffeenode-types'
TRM                       = require 'coffeenode-trm'
log                       = TRM.log.bind TRM
#...........................................................................................................
assert                    = require 'assert'



#-----------------------------------------------------------------------------------------------------------
@main = ->
  do @test_lines_splitting


#-----------------------------------------------------------------------------------------------------------
@test_lines_splitting = ->
  assert.deepEqual ( TEXT.lines_of 'helo world'             ), [ 'helo world' ]
  assert.deepEqual ( TEXT.lines_of 'helo world\n'           ), [ 'helo world', '' ]
  assert.deepEqual ( TEXT.lines_of 'helo world\nhowdy'      ), [ 'helo world', 'howdy' ]
  assert.deepEqual ( TEXT.lines_of 'helo world\rhowdy'      ), [ 'helo world', 'howdy' ]
  assert.deepEqual ( TEXT.lines_of 'helo world\r\nhowdy'    ), [ 'helo world', 'howdy' ]
  assert.deepEqual ( TEXT.lines_of 'helo world\n\rhowdy'    ), [ 'helo world', '', 'howdy' ]
  assert.deepEqual ( TEXT.lines_of '\nhelo world\n\rhowdy'  ), [ '', 'helo world', '', 'howdy' ]
  assert.deepEqual ( TEXT.lines_of 'a\u0085b\u2028c\u2029d' ), [ 'a', 'b', 'c', 'd' ]





############################################################################################################
do @main
