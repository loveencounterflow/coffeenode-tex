
############################################################################################################
log                       = console.log
TEX                       = require 'coffeenode-tex'
TRM                       = require 'coffeenode-trm'
rainbow                   = TRM.rainbow.bind TRM


log()
d = TEX.new_command 'helo', 'foo'
log rainbow d
log rainbow TEX.rpr d

log()
d = TEX.new_command 'helo', [ 'foo', 'bar', ]
log rainbow d
log rainbow TEX.rpr d

log()
d = TEX.new_multicommand 'helo', 1, 'foo'
log rainbow d
log rainbow TEX.rpr d

log()
d = TEX.new_multicommand 'helo', 2, [ 'foo', 'bar', ]
log rainbow d
log rainbow TEX.rpr d

# d = TEX.new_command 'helo', 2, [ 'foo', 'bar', ]
# d = TEX.new_command 'helo', 1, 'foo'
# log rainbow d
# log rainbow TEX.rpr d

log()
D = TEX.make_multicommand 'helo', 2
d = D [ 'foo', 'bar', ]
log rainbow d
log rainbow TEX.rpr d
