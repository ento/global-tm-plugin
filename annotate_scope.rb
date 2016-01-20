require 'rubygems'
require 'json'
require 'textpow'
require 'linguist'
require 'linguist/grammars'

class Processor
  def initialize
    @line_number = 0
    @printable_line = ""
    @depth = 0
    @scope_stack = []
  end

  def pprint line, string, position = 0
    line.replace line.ljust( position + string.size, " ")
    line[position,string.size] = string
    line
  end

  def open_tag name, position
    @depth += 1
    @scope_stack.push(position)
    STDERR.puts pprint( "", "{#{name}", @depth)
  end

  def close_tag name, position
    start = @scope_stack.pop
    STDERR.puts pprint( "", @line[start..(position - 1)], @depth)
    STDERR.puts pprint( "", "}#{name}", @depth)
    @depth -= 1
  end

  def new_line line
    @line_number += 1
    @line_marks = "[#{@line_number.to_s.rjust( 4, '0' )}] "
    @line = line
    STDERR.puts "#{@line_marks}#{line}"
  end

  def start_parsing name
    STDERR.puts "{#{name}"
  end

  def end_parsing name
    STDERR.puts "}#{name}"
  end
end

def guess_syntax(path)
  languages = Linguist::Language.find_by_filename(path)
  return if languages.empty?
  grammar_file = File.join(Linguist::Grammars.path, "#{languages.first.tm_scope}.json")

  table = open(grammar_file) do |f|
    JSON.load(f.read.gsub(/\\x\{([0-9A-Fa-f]+)\}/, '\\x\1'))
  end

  Textpow::SyntaxNode.new(table)
end

def annotate_scope(path)
  syntax = guess_syntax(path)
  processor = Processor.new

  open(path) do |f|
    syntax.parse(f.read, processor)
  end
end

if __FILE__ == $0
  annotate_scope "sample.rb"
  annotate_scope "sample.py"
  annotate_scope "sample.elm"
end
