(function() {
  var get_contents,
    __slice = [].slice;

  this.new_container = function(contents) {
    var R;
    R = {
      '~isa': 'TEX/container',
      'contents': get_contents(contents)
    };
    return R;
  };

  this.new_raw_container = function(contents) {
    var R;
    R = {
      '~isa': 'TEX/raw-container',
      'contents': get_contents(contents)
    };
    return R;
  };

  this.new_loner = function(name) {
    var R;
    this.validate_command_name(name);
    R = {
      '~isa': 'TEX/loner',
      'name': name
    };
    return R;
  };

  this.new_group = function(contents) {
    var R;
    R = {
      '~isa': 'TEX/group',
      'contents': get_contents(contents)
    };
    return R;
  };

  this.new_command = function(name, contents) {
    var R;
    this.validate_command_name(name);
    R = {
      '~isa': 'TEX/command',
      'name': name,
      'options': null,
      'contents': get_contents(contents)
    };
    return R;
  };

  this.new_multicommand = function(name, arity, contents) {
    var R;
    this.validate_command_name(name);
    NUMBER.validate_is_nonnegative_integer(arity);
    R = {
      '~isa': 'TEX/multi-command',
      'name': name,
      'arity': arity,
      'options': null,
      'contents': get_contents(contents)
    };
    return R;
  };

  this.new_environment = function(name, contents) {
    var R;
    this.validate_command_name(name);
    R = {
      '~isa': 'TEX/environment',
      'name': name,
      'contents': get_contents(contents)
    };
    return R;
  };

  get_contents = function(contents) {
    if (TYPES.isa_list(contents)) {
      return contents;
    } else {
      if (contents != null) {
        return [contents];
      } else {
        return [];
      }
    }
  };

  this.make_loner_group = function(name) {
    var _this = this;
    return function() {
      var P;
      P = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _this.new_group.apply(_this, [_this.new_loner(name)].concat(__slice.call(P)));
    };
  };

  this.make_environment = function(name) {
    var _this = this;
    return function() {
      var P;
      P = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _this.new_environment.apply(_this, [name].concat(__slice.call(P)));
    };
  };

  this.make_loner = function(name) {
    var _this = this;
    return function() {
      var P;
      P = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _this.new_loner.apply(_this, [name].concat(__slice.call(P)));
    };
  };

  this.make_command = function(name) {
    var _this = this;
    return function() {
      var P;
      P = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _this.new_command.apply(_this, [name].concat(__slice.call(P)));
    };
  };

  this.make_multicommand = function(name, arity) {
    var _this = this;
    return function() {
      var P;
      P = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _this.new_multicommand.apply(_this, [name, arity].concat(__slice.call(P)));
    };
  };

  this.validate_command_name = function(x) {
    TYPES.validate_isa_text(x);
    if ((x.match(/^[a-zA-Z]+\*?$/)) == null) {
      return bye("command names must only contain upper- and lowercase English letters; got " + (rpr(x)));
    }
  };

  this.validate_option_name = function(x) {
    TEXT.validate_is_nonempty_text(x);
    if ((x.match(/\\|\{|\}|&|\$|\#|%|_|\^|~/)) != null) {
      return bye("option names must not contain special characters; got " + (rpr(x)));
    }
  };

  this.validate_isa_command = function(x) {
    var type;
    if ((type = TYPES.type_of(x)) !== 'TEX/command') {
      return bye("expected a TEX/command, got a " + type);
    }
  };

  this.push = function(me, content) {
    me['contents'].push(content);
    return me;
  };

  this.append = function(me, content) {
    me['contents'].push(' ');
    me['contents'].push(content);
    return me;
  };

  this.add = function(me, you) {
    LIST.add(me['contents'], you);
    return me;
  };

  this.length_of = function(me) {
    return me['contents'].length;
  };

  this.is_empty = function(me) {
    return (this.length_of(me)) === 0;
  };

  this.intersperse = function(me, x) {
    LIST.intersperse(me['contents'], x);
    return me;
  };

  this.set = function(me, name, value) {
    var options;
    if (value == null) {
      value = null;
    }
    this.validate_isa_command(me);
    options = me['options'] != null ? me['options'] : me['options'] = {};
    this._set(options, name, value);
    return me;
  };

  this.set_options = function() {
    var me, name, options, part, value, _i, _len, _options;
    me = arguments[0], options = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    this.validate_isa_command(me);
    _options = me['options'] != null ? me['options'] : me['options'] = {};
    for (_i = 0, _len = options.length; _i < _len; _i++) {
      part = options[_i];
      if (TYPES.isa_text(part)) {
        this._set(_options, part, null);
      } else {
        for (name in part) {
          value = part[name];
          this._set(_options, name, value);
        }
      }
    }
    return null;
  };

  this._set = function(options, name, value) {
    this.validate_option_name(name);
    options[name] = value;
    return null;
  };

  this._escape_replacements = [[/\\/g, '\\textbackslash{}'], [/\{/g, '\\{'], [/\}/g, '\\}'], [/&/g, '\\&'], [/\$/g, '\\$'], [/\#/g, '\\#'], [/%/g, '\\%'], [/_/g, '\\_'], [/\^/g, '\\textasciicircum{}'], [/~/g, '\\textasciitilde{}']];

  this._escape = function(text) {
    var R, matcher, replacement, _i, _len, _ref, _ref1;
    R = text;
    _ref = this._escape_replacements;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      _ref1 = _ref[_i], matcher = _ref1[0], replacement = _ref1[1];
      R = R.replace(matcher, replacement);
    }
    return R;
  };

  this.rpr = function(x) {
    switch (TYPES.type_of(x)) {
      case 'text':
        return this._escape(x);
      case 'TEX/container':
        return this._rpr_of_container(x);
      case 'TEX/raw-container':
        return this._rpr_of_raw_container(x);
      case 'TEX/loner':
        return this._rpr_of_loner(x);
      case 'TEX/group':
        return this._rpr_of_group(x);
      case 'TEX/command':
        return this._rpr_of_command(x);
      case 'TEX/multi-command':
        return this._rpr_of_multicommand(x);
      case 'TEX/environment':
        return this._rpr_of_environment(x);
      default:
        return rpr(x);
    }
  };

  this._rpr_of_container = function(me) {
    var content;
    return ((function() {
      var _i, _len, _ref, _results;
      _ref = me['contents'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        content = _ref[_i];
        _results.push(this.rpr(content));
      }
      return _results;
    }).call(this)).join('');
  };

  this._rpr_of_raw_container = function(me) {
    return me['contents'].join('');
  };

  this._rpr_of_loner = function(me) {
    return '\\' + me['name'] + '{}';
  };

  this._rpr_of_group = function(me) {
    var R, content, _i, _len, _ref;
    R = ['{'];
    _ref = me['contents'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      content = _ref[_i];
      R.push(this.rpr(content));
    }
    R.push('}');
    return R.join('');
  };

  this._rpr_of_command = function(me) {
    var R, content, _i, _len, _ref;
    R = ['\\', me['name']];
    R.push(this._rpr_of_options(me));
    R.push('{');
    _ref = me['contents'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      content = _ref[_i];
      R.push(this.rpr(content));
    }
    R.push('}');
    return R.join('');
  };

  this._rpr_of_multicommand = function(me) {
    var R, arity, content, content_count, _i, _len, _ref;
    R = ['\\', me['name']];
    R.push(this._rpr_of_options(me));
    content_count = me['contents'].length;
    arity = me['arity'];
    if (content_count !== arity) {
      bye("command `\\" + me['name'] + "` expects " + arity + " arguments, got " + content_count);
    }
    _ref = me['contents'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      content = _ref[_i];
      R.push('{' + (this.rpr(content)) + '}');
    }
    return R.join('');
  };

  this._rpr_of_environment = function(me) {
    var R, content, _i, _len, _ref;
    R = ['\\begin{', me['name'], '}\n'];
    _ref = me['contents'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      content = _ref[_i];
      R.push(this.rpr(content));
    }
    R.push('\n\\end{');
    R.push(me['name']);
    R.push('}\n');
    return R.join('');
  };

  this._rpr_of_options = function(me) {
    var name, options, value, _options;
    if ((options = me['options']) != null) {
      R.push('[');
      _options = [];
      for (name in options) {
        value = options[name];
        _options.push(value != null ? "" + name + "=" + value : name);
      }
      R.push(_options.join(','));
      R.push(']');
      return R.join('');
    }
    return '';
  };

  module.exports = bundle(this);

}).call(this);
/****generated by https://github.com/loveencounterflow/larq****/