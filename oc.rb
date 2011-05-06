# arg: ime zadatka
# stdio: source

require "rubygems"
require "yaml"

wdir = "/tmp/"
test_fname = './zadatci.yml'

@debug = false
# @debug = true

def d(txt)
	puts "DBG: #{txt}" if @debug
end

# optimiziraj test
def opt_test(test)
	return "" if test.nil?
	test.gsub(/\n+/, "\n").gsub(/^\n/, "").gsub(/\n$/, "")
end

def usporedi(a, b)
	opt_test(a) == opt_test(b)
end

####

if !ARGV[0]
	puts "arg: ime zadatka"
	exit 1
end

zad = ARGV[0]

s = ""
while x = STDIN.gets
	s+=x
end

d "write c file"
File.open(File.join(wdir, 'tmp.c'), 'w'){|f| f.puts s }


d "compile: "+(
	ret = system "cd '#{wdir}' && gcc tmp.c -o tmp.o 2>/dev/null";
	""
	)+"#{ret ? "OK" : "FAIL"}"

if !ret
	puts "Compile error!"
	exit 1
end


# testovi zadataka
defs = YAML.load File.read test_fname

# puts "Ucitano:\nzadataka: #{defs.count}"
if defs[zad].nil?
	puts "Zadatak nema testova!"
	exit 1
end
testovi = defs[zad]
d "n testova: #{testovi.count}"

b = 0

testovi.each{|id,t|
	tinp = opt_test t["in"]
	tout = opt_test t["out"]
	if tinp.empty? || tout.empty?
		puts "ERR: in ili out test nedostaje u testu #{id} za zadatak #{zad}"
		next
	end

	d 'write test to file'
	File.open(File.join(wdir, 'test.in'), 'w'){|f| f.puts opt_test tinp }

	d 'run and test'
	ret = system("cd '#{wdir}' && ./tmp.o < test.in > tmp.out")
	if !ret
		d "exec failed"
		next
	end
	out = `cat #{File.join wdir, 'tmp.out'}`

	d "output:"
	d out

	d "ocekivano:"
	d tout

	ok = usporedi(tout, out)
	if @debug
		puts "TEST #{id}: #{ok ? "OK" : "FAIL"}"
	else
		# print ok ? "+" : "F"
	end

	b+=1 if ok
}

`cd '#{wdir}' && set +e; rm tmp.{c,o} test.in tmp.out`

if @debug
	puts "Rezultat: #{b}/#{testovi.count}"
else
	puts testovi.count
	puts b
end
