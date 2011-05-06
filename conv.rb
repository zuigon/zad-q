require "rubygems"
require "yaml"

class Hash
  def to_yaml( opts = {} )
    YAML::quick_emit( object_id, opts ) do |out|
      out.map( taguri, to_yaml_style ) do |map|
        sort.each do |k, v| # sort
          map.add( k, v )
        end
      end
    end
  end
end

class String
	def to_yaml_style
		:literal
	end
end

if ARGV.empty?
	puts "arg: folder(i) sa testovima (ime foldera je ime zadatka; folder sadrzi testove u datotekama in.N i out.N)"
	exit
end

d, a = [], {}
ARGV.each{|dd| d+=Dir["./#{dd}/{in,out}.*"] }

d.each{|x|
	zad = x[/^\.\/([a-z]+)\//, 1]
	id  = x[/^\.\/[a-z]+\/(in|out)\.(\d+)/, 2]
	var = x[/^\.\/[a-z]+\/(in|out)\.(\d+)/, 1]

	a[zad]={} if !a[zad]
	a[zad][id]={} if !a[zad][id]
	a[zad][id][var] = File.read "./#{zad}/#{var}.#{id}"
}

r = a.to_yaml.split("\n")
puts r[1..r.count-1].join("\n")
