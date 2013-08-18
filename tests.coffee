echo()
d = TEX.new_command 'helo', 'foo'
echo rainbow d
echo rainbow TEX.rpr d

echo()
d = TEX.new_command 'helo', [ 'foo', 'bar', ]
echo rainbow d
echo rainbow TEX.rpr d

echo()
d = TEX.new_multicommand 'helo', 1, 'foo'
echo rainbow d
echo rainbow TEX.rpr d

echo()
d = TEX.new_multicommand 'helo', 2, [ 'foo', 'bar', ]
echo rainbow d
echo rainbow TEX.rpr d

# d = TEX.new_command 'helo', 2, [ 'foo', 'bar', ]
# d = TEX.new_command 'helo', 1, 'foo'
# echo rainbow d
# echo rainbow TEX.rpr d

echo()
D = TEX.make_multicommand 'helo', 2
d = D [ 'foo', 'bar', ]
echo rainbow d
echo rainbow TEX.rpr d
