


############################################################################################################
TYPES                     = require 'coffeenode-types'
TEXT                      = require 'coffeenode-text'
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'TEX'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
echo                      = TRM.echo.bind TRM


#===========================================================================================================
# CREATION
#-----------------------------------------------------------------------------------------------------------
@new_container = ( contents ) ->
  #.........................................................................................................
  R =
    '~isa':       'TEX/container'
    'contents':   get_contents contents
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@new_raw_container = ( contents ) ->
  #.........................................................................................................
  R =
    '~isa':       'TEX/raw-container'
    'contents':   get_contents contents
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@new_loner = ( name ) ->
  @validate_command_name name
  #.........................................................................................................
  R =
    '~isa':       'TEX/loner'
    'name':       name
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@new_group = ( contents ) ->
  #.........................................................................................................
  R =
    '~isa':       'TEX/group'
    'contents':   get_contents contents
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@new_command = ( name, contents ) ->
  @validate_command_name name
  #.........................................................................................................
  R =
    '~isa':       'TEX/command'
    'name':       name
    'options':    null
    'contents':   get_contents contents
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@new_multicommand = ( name, arity, contents ) ->
  #.........................................................................................................
  @validate_command_name name
  NUMBER.validate_is_nonnegative_integer arity
  #.........................................................................................................
  R =
    '~isa':       'TEX/multicommand'
    'name':       name
    'arity':      arity
    'options':    null
    'contents':   get_contents contents
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@new_environment = ( name, contents ) ->
  @validate_command_name name
  #.........................................................................................................
  R =
    '~isa':       'TEX/environment'
    'name':       name
    'options':    null
    'contents':   get_contents contents
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
get_contents = ( contents ) ->
  return if TYPES.isa_list contents then contents else ( if contents? then [ contents ] else [] )

#-----------------------------------------------------------------------------------------------------------
@make_loner_group   = ( name        ) -> return ( P... ) => return @new_group ( @new_loner name ),        P...
@make_environment   = ( name        ) -> return ( P... ) => return @new_environment        name,          P...
@make_loner         = ( name        ) -> return ( P... ) => return @new_loner              name,          P...
@make_command       = ( name        ) -> return ( P... ) => return @new_command            name,          P...
@make_multicommand  = ( name, arity ) -> return ( P... ) => return @new_multicommand       name,   arity, P...
#...........................................................................................................
@raw                = ( contents ) -> return @new_raw_container contents

#-----------------------------------------------------------------------------------------------------------
@make_multicommand = ( name, arity ) ->
  return ( P... ) =>
    return @new_multicommand name, arity, P...

#===========================================================================================================
# VALIDATION
#-----------------------------------------------------------------------------------------------------------
@validate_command_name = ( x ) ->
  TYPES.validate_isa_text x
  unless ( x.match /^[a-zA-Z]+\*?$/ )?
    throw new Error "command names must only contain upper- and lowercase English letters; got #{rpr x}"

#-----------------------------------------------------------------------------------------------------------
@validate_option_name = ( x ) ->
  TEXT.validate_is_nonempty_text x
  if ( x.match /\\|\{|\}|&|\$|\#|%|_|\^|~/ )?
    throw new Error "option names must not contain special characters; got #{rpr x}"

#-----------------------------------------------------------------------------------------------------------
@validate_isa_command = ( x ) ->
  throw new Error "expected a TEX/command, got a #{type}" unless ( type = TYPES.type_of x ) is 'TEX/command'


#===========================================================================================================
# MANIPULATION
#-----------------------------------------------------------------------------------------------------------
@push = ( me, content ) ->
  me[ 'contents' ].push content
  return me

#-----------------------------------------------------------------------------------------------------------
@append = ( me, content ) ->
  me[ 'contents' ].push ' '
  me[ 'contents' ].push content
  return me

# #-----------------------------------------------------------------------------------------------------------
# @break = ( me ) ->
#   me[ 'contents' ].push '\n\n'
#   return me

#-----------------------------------------------------------------------------------------------------------
@add = ( me, you ) ->
  LIST.add me[ 'contents' ], you
  return me

#-----------------------------------------------------------------------------------------------------------
@length_of = ( me ) ->
  return me[ 'contents' ].length

#-----------------------------------------------------------------------------------------------------------
@is_empty = ( me ) ->
  return ( @length_of me ) is 0

#-----------------------------------------------------------------------------------------------------------
@intersperse = ( me, x ) ->
  LIST.intersperse me[ 'contents' ], x
  return me

#-----------------------------------------------------------------------------------------------------------
@set = ( me, name, value = null ) ->
  # @validate_isa_command me
  options = me[ 'options' ]?= {}
  @_set options, name, value
  return me

#...........................................................................................................
@set_options = ( me, options... ) ->
  @validate_isa_command me
  _options = me[ 'options' ]?= {}
  #.........................................................................................................
  for part in options
    #.......................................................................................................
    if TYPES.isa_text part
      @_set _options, part, null
    #.......................................................................................................
    # ###TAINT### should perform stricter type checking
    else
      @_set _options, name, value for name, value of part
  #.........................................................................................................
  return null

#...........................................................................................................
@_set = ( options, name, value ) ->
  @validate_option_name name
  options[ name ] = value
  return null


#===========================================================================================================
# SERIALIZATION
#-----------------------------------------------------------------------------------------------------------
@_escape_replacements = [
  [ ///  \\  ///g,  '\\textbackslash{}',    ]
  [ ///  \{  ///g,  '\\{',                  ]
  [ ///  \}  ///g,  '\\}',                  ]
  [ ///  &   ///g,  '\\&',                  ]
  [ ///  \$  ///g,  '\\$',                  ]
  [ ///  \#  ///g,  '\\#',                  ]
  [ ///  %   ///g,  '\\%',                  ]
  [ ///  _   ///g,  '\\_',                  ]
  [ ///  \^  ///g,  '\\textasciicircum{}',  ]
  [ ///  ~   ///g,  '\\textasciitilde{}',   ]
  # '`'   # these two are very hard to catch when TeX's character handling is switched on
  # "'"   #
  ]

#-----------------------------------------------------------------------------------------------------------
@_escape = ( text ) ->
  R = text
  for [ matcher, replacement, ] in @_escape_replacements
    R = R.replace matcher, replacement
  return R

#-----------------------------------------------------------------------------------------------------------
@rpr = ( x ) ->
  return switch TYPES.type_of x
    when 'text'               then @_escape               x
    when 'TEX/container'      then @_rpr_of_container     x
    when 'TEX/raw-container'  then @_rpr_of_raw_container x
    when 'TEX/loner'          then @_rpr_of_loner         x
    when 'TEX/group'          then @_rpr_of_group         x
    when 'TEX/command'        then @_rpr_of_command       x
    when 'TEX/multicommand'   then @_rpr_of_multicommand  x
    when 'TEX/environment'    then @_rpr_of_environment   x
    else                           @_escape TRM.rpr       x

#-----------------------------------------------------------------------------------------------------------
@_rpr_of_container = ( me ) ->
  return ( @rpr content for content in me[ 'contents' ] ).join ''

#-----------------------------------------------------------------------------------------------------------
@_rpr_of_raw_container = ( me ) ->
  return me[ 'contents' ].join ''

#-----------------------------------------------------------------------------------------------------------
@_rpr_of_loner = ( me ) ->
  return '\\' + me[ 'name' ] + '{}'

#-----------------------------------------------------------------------------------------------------------
@_rpr_of_group = ( me ) ->
  R = [ '{', ]
  R.push @rpr content for content in me[ 'contents' ]
  R.push '}'
  return R.join ''

#-----------------------------------------------------------------------------------------------------------
@_rpr_of_command = ( me ) ->
  R = [ '\\', me[ 'name' ], ]
  R.push @_rpr_of_options me
  #.........................................................................................................
  R.push '{'
  R.push @rpr content for content in me[ 'contents' ]
  R.push '}'
  #.........................................................................................................
  return R.join ''

#-----------------------------------------------------------------------------------------------------------
@_rpr_of_multicommand = ( me ) ->
  R = [ '\\', me[ 'name' ], ]
  R.push @_rpr_of_options me
  #.........................................................................................................
  content_count = me[ 'contents' ].length
  arity         = me[ 'arity' ]
  if content_count != arity
    throw new Error "command `\\#{me[ 'name' ]}` expects #{arity} arguments, got #{content_count}"
  R.push '{' + ( @rpr content ) + '}' for content in me[ 'contents' ]
  #.........................................................................................................
  return R.join ''

#-----------------------------------------------------------------------------------------------------------
@_rpr_of_environment = ( me ) ->
  R = []
  R.push '\\begin'
  R.push @_rpr_of_options me
  R.push '{'
  R.push me[ 'name' ]
  R.push '}\n'
  R.push @rpr content for content in me[ 'contents' ]
  R.push '\n\\end{'
  R.push me[ 'name' ]
  R.push '}\n'
  return R.join ''

#-----------------------------------------------------------------------------------------------------------
@_rpr_of_options = ( me ) ->
  R = []
  #.........................................................................................................
  if ( options = me[ 'options' ] )?
    R.push '['
    _options = []
    for name, value of options
      _options.push if value? then "#{name}=#{value}" else name
    R.push _options.join ','
    R.push ']'
    return R.join ''
  #.........................................................................................................
  return ''


#===========================================================================================================
# UNRESOLVED DEPENDENCIES: NUMBER
#-----------------------------------------------------------------------------------------------------------
NUMBER = {}

#-----------------------------------------------------------------------------------------------------------
NUMBER.is_integer = ( x ) ->
  return ( TYPES.isa_number x ) and ( x == parseInt x, 10 )

#-----------------------------------------------------------------------------------------------------------
NUMBER.is_nonnegative_integer = ( x ) ->
  return ( @is_integer x ) and x >= 0

#-----------------------------------------------------------------------------------------------------------
NUMBER.validate_is_nonnegative_integer = ( x ) ->
  return null if @is_nonnegative_integer x
  throw new Error "expected a non-negative integer, got #{nrpr x}"


#===========================================================================================================
# UNRESOLVED DEPENDENCIES: LIST
#-----------------------------------------------------------------------------------------------------------
LIST = {}

#-----------------------------------------------------------------------------------------------------------
LIST.add = ( me, you ) ->
  me.splice me.length, 0, you...
  return me

#-----------------------------------------------------------------------------------------------------------
LIST.intersperse = ( me, x ) ->
  """Given a list and a value, stick the value in between each element pair in the list. This method is
  analogous to "a ``LIST/join`` that does not reduce its result to a text"."""
  if me.length > 1
    for idx in [ me.length - 1 .. 1 ] by -1
      @insert me, x, idx
  #.........................................................................................................
  return me

#-----------------------------------------------------------------------------------------------------------
LIST.insert = ( me, value, idx ) ->
  if idx?
    me.splice idx, 0, value
  else
    me.unshift value
  return me



# module.exports = bundle @

