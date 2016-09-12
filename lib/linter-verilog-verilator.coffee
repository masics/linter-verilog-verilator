{ CompositeDisposable } = require 'atom'
path = require 'path'

lint = (editor) ->
  helpers = require('atom-linter')
  #regex = /((?:[A-Z]:)?[^:]+):([^:]+):(.+)/
  regex = /%(.*?)-(?:.*?): *(.*?):(.*?):(.*)/
  file = "/cygwin/" + editor.getPath().replace(/\\/g, "/").replace(/:/, "")
  dirname = "/cygwin/" + path.dirname(file).replace(/\\/g, "/").replace(/:/, "")
  
  args = ("#{arg}" for arg in atom.config.get('linter-verilog-verilator.extraOptions'))
  args = args.concat ['-c ', '\'',  '/usr/local/bin/verilator', '--lint-only', '-I', dirname,  file, '\'']
  helpers.exec('bash', args, {stream: 'both'}).then (output) ->
    lines = output.stderr.split("\n")
    messages = []
    for line in lines
      if line.length == 0
        continue

      console.log(line)
      parts = line.match(regex)
      if !parts || parts.length != 4
        console.debug("Droping line:", line)
      else
        message =
          filePath: parts[1].trim()
          range: helpers.rangeFromLineNumber(editor, parseInt(parts[2])-1, 0)
          type: parts[0].trim()
          text: parts[3].trim()

        messages.push(message)

    return messages

module.exports =
  config:
    extraOptions:
      type: 'array'
      default: []
      description: 'Comma separated list of iverilog options'
  activate: ->
    require('atom-package-deps').install('linter-verilog-verilator')

  provideLinter: ->
    provider =
      grammarScopes: ['source.verilog']
      scope: 'project'
      lintOnFly: false
      name: 'Verilog'
      lint: (editor) => lint(editor)
