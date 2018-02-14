
class MatrixLabFileHandler

	def initialize(fname, parser)
    # file name for save file
		@fname = fname
		
		# reference to parser, so that helper methods can be called,
		# such as identifier? and integer? 
		@parser = parser
	end

	# read a row of matrix input from the savefile
  def read_row(savefile)
    valid = true # flag to keep track of valid input
    
    # read a line from the file
    row = savefile.readline.chomp
    
    # make sure line wasn't a blank line, if it was we will return []
    if row.length > 0
      row = row.split # split the row into separate tokens
      
      # remove pipe characters if present, these are optional
      if row.first == '|'
        row.shift
        if row.length > 0 and row[row.length - 1] == '|'
          row.pop
        end
      end
      
      # process digit values of row
      if row.length > 0
        # after removing pipe characters (if present), must check length again
        for i in 0...row.length # iterate with i through the row
          if @parser.integer? row[i]
            row[i] = row[i].to_i # convert to numbers from strings
          else
            print 'Load Error: Row entry contained non digit characters '
            valid = false
            break # break from the loop because of invalid input
          end
        end
      else
        print 'Load Error: Row entry cannot be blank '
        valid = false        
      end
    else
      # this is not necessarily an error
      row = [] # return an empty array if the line was simply blank
    end
    
    if(valid)
      return row
    else
      return nil
    end
  end

	# load and return the hash saved in the file	
	def load_hash
	  matrices = {}
	  linenum = 1
	  success = true
	  
	  savefile = File.open(@fname, "r")
	  
	  while success and not savefile.eof?
	    # get a line which should have a user identifier
	    line = savefile.readline.chomp.split
	    
	    if line.length == 1
	      if @parser.user_identifier? line.first
	        identifier = line.first
	        matrix = []
	        matrix_loaded = false
	        cols = nil
	        first_read = true
	        # get matrix input from file
	        while success and not matrix_loaded
	          
	          if not savefile.eof?
  	          row = read_row savefile
  	          linenum += 1
  	          if first_read 
  	            if row == []
  	              puts "Load Error: Expected matrix definition to follow identifier on line #{linenum}."
  	              success = false
  	            elsif not row.equal? nil
  	              cols = row.length
  	            end
  	            first_read = false
  	          end

  	          if not row.equal? nil
    	          if row == [] 
    	            matrix_loaded = true
    	          else
    	            # end of row input not yet reached
      	          if cols == row.length
      	            # valid number of columns and valid return from read_row
      	            matrix.push []
      	            row.each { |integer|
      	              matrix[matrix.length - 1].push integer
      	            }
      	          else
      	            puts "Load Error: Expected #{cols} columns at line #{linenum}."
      	            success = false
      	          end
    	            if savefile.eof?
    	              matrix_loaded = true
    	            end
    	          end
  	          else
  	            # print linenum of error in file
  	            puts "(line #{linenum})"
  	            success = false
  	          end
  	        else
  	          puts "Load Error: Expected matrix definition to follow identifier on line #{linenum}."
  	          success = false
  	        end
	        end # end while loop
	        
	        if success
	          matrices[identifier] = matrix
	        end
	        
	      else
	        puts "Load Error: Expected Identifier on line #{linenum}."
	        success = false
	      end
	    else
	      puts "Load Error: Extra characters on line #{linenum}."
	      success = false
	    end
	    
	    # increment linenum
	    linenum += 1
	  end
	  
	  savefile.close
	  
	  if not success
    	puts 'Aborting savefile load...'
  	end
  	
  	# should be safe to return this even after an abort.
  	# This way, any matrices that were successfully entered in the
  	# file will still be loaded.
	  return matrices 
	end
	
	# save the given hash into the file
	def save_hash(hash)
		savefile = File.open(@fname, "w")
		
		# write each matrix from the hash into the save file
		hash.each { |identifier, matrix|
		  # only save user matrices, not cached identities and zeroes
			if not @parser.reserved_identifier? identifier
				# get matrix dimensions
				m = matrix.length
				n = matrix.first.length
				
				# print identifier
				savefile.puts identifier
				
				# print matrix in a readable format into the file
				for row in 0...m
					savefile.write '| '
					for col in 0...n
						savefile.write matrix[row][col].to_s + ' '
					end
					savefile.write '|'
					savefile.puts
				end
				
				# print a blank line after the end of a matrix
				savefile.puts
			end
		}
		savefile.close
	end
	
end


