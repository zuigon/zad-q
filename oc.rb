# arg: ime zadatka
# stdio: source

require "rubygems"
require "yaml"

module Oc
	def randname()
		l = 5
		h = ('0'..'9').to_a + ('a'..'f').to_a
		c = h.count
		(0...l).map{ h.to_a[rand(c)] }.join
	end

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

	def included?
		$0 == __FILE__
	end

	def ocjeni(zad, kod)
		tmpfname = randname()
		wdir = "/tmp/"
		test_fname = './zadatci.yml'
		@debug = false
		# @debug = true

		if zad.nil? || kod.nil?
			puts "arg: ime zadatka, kod"
			exit 1
		end

		d "write c file"
		File.open(File.join(wdir, "#{tmpfname}.c"), 'w'){|f| f.puts kod}

		d "compile: "+(
			ret = system "cd '#{wdir}' && gcc #{tmpfname}.c -o #{tmpfname}.o 2>/dev/null"; ""
		)+"#{ret ? "OK" : "FAIL"}"

		if !ret
			d "Compile error!"
			`cd #{wdir} && rm -f #{tmpfname}.*`
			return -1
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
			File.open(File.join(wdir, "#{tmpfname}.in"), 'w'){|f| f.puts opt_test tinp }

			d 'run and test'
			ret = system("cd '#{wdir}' && ./#{tmpfname}.o < #{tmpfname}.in > #{tmpfname}.out")
			if !ret
				d "exec failed"
				next
			end
			out = `cat #{File.join wdir, "#{tmpfname}.out"}`

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

		# `cd '#{wdir}' && rm -f #{tmpfname}.{c,o,in,out}`
		`cd '#{wdir}' && rm -f #{tmpfname}.*`

		if @debug
			puts "Rezultat: #{b}/#{testovi.count}"
		else
			if $0 != __FILE__
				return b
			else
				puts testovi.count
				puts b
			end
		end
	end

end

if $0 == __FILE__
	include Oc
	i = ""
	while s = STDIN.gets
		i += s
	end
	ocjeni ARGV[0], i
end

