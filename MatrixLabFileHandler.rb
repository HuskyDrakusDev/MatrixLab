
class MatrixLabFileHandler

	def initialize(fname)
		@fname = fname
	end

	# load and return the hash saved in the file	
	def load_hash
	
	end
	
	# save the given hash into the file
	def save_hash(hash)
		savefile = File.open(@fname, "w")
		
		hash.each { |identifier, matrix|
			if not (identifier.start_with? 'I') and (not identifier.start_with? 'Z')
				m = matrix.length
				n = matrix.first.length
				savefile.puts identifier
				for row in 0...m
					savefile.write '| '
					for col in 0...n
						savefile.write matrix[row][col].to_s
					end
					savefile.write ' |'
				end
				savefile.puts
			end
		}
		savefile.close
	end
end


