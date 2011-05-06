class TaskRecord
	def initialize(t=nil)
		@struct = %w(id task done processing)
		@sep = ":"
		@t = t.nil? ? [""*@struct.count] : t.split(@sep)
	end

	def get(key)
		key_index = @struct.find_index{|x| x==key}
		raise "Key ne postoji u @struct !" if key_index.nil?
		@t[key_index]
	end

	def set(key, val)
		key_index = @struct.find_index{|x| x==key}
		raise "Key ne postoji u @struct !" if key_index.nil?
		@t[key_index] = val
	end

	def t
		@t.join(@sep)
	end
end
