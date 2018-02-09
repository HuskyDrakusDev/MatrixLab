# Class to parse and process commands for Matrix Lab system.

require 'set'

# ================================ CONSTANTS =============================================

# the maximum dimension allowed for a matrix in the system
MAX_DIMENSION = 100

DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']

ALPHAS = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']

ALNUMS = ALPHAS + DIGITS

SYS_COMMAND_STRINGS = ['ls', 'clr', 'rm']

ADD_OP_STRINGS = ['+', '-']

UNARY_OP_STRINGS = ['det', 'rref', 'inv', 'trans']

END_OF_INPUT_STRING = 'END_OF_INPUT'

# prefixes which user identifiers are not permitted to have
RESERVED_PREFIXES = SYS_COMMAND_STRINGS + ['I', 'Z']

class MatrixLabParser

  def initialize
    
    # hash to map identifiers to matrices    
    @matrices = {}
    
    @tokens = []
  
  end

  # ============================== PARSING HELPER METHODS ================================

  def end_token?(token)
    return token == END_OF_INPUT_STRING
  end
  
  def add_op?(token)
  	return ADD_OP_STRINGS.include? token
  end
  
  def integer?(token)
    isInt = true
    if token.length > 0
      i = 0
      if token[0] == '-'
        i = 1
      end
      token[i..-1].each_char { |c|
        if not DIGITS.include? c
          isInt = false
        end
      }
    else
      isInt = false
    end
    return isInt
  end
  
  def positive_integer?(token)
    return (integer? token and token[0] != '-')
  end
  
  def user_identifier?(token)
    isUserIdentifier = true
    if token.length > 0
      RESERVED_PREFIXES.each { |prefix| 
        if token.start_with? prefix
          isUserIdentifier = false
        end
      }
      
      if isUserIdentifier 
        if not DIGITS.include? token[0]
          token[1..-1].each_char { |c|
            if not ALNUMS.include? c
              isUserIdentifier = false
            end
          }
        else
          isUserIdentifier = false
        end
      end
    else
      isUserIdentifier = false
    end
    return isUserIdentifier
  end
  
  def reserved_identifier?(token)
    reserved = false
    if token.start_with? 'I', 'Z'
      if token.length >= 2
        for i in 1...token.length
          if DIGITS.include? token[i]
            reserved = true
          else
            reserved = false
            break
          end
        end
      end
    end
    return reserved
  end
  
  def identifier?(token)
    return (reserved_identifier? token or user_identifier? token)
  end

  # ============================== PARSE METHODS =========================================

  # note: shift on tokens returns next token, first on tokens looks at next token
  # by convention, of course, not enforced by language
  
  def parse_command(command)
    # set tokens so that tokenized command can be accessed globally, and add end of input
    @tokens = command + [END_OF_INPUT_STRING]
    
    # make sure the first token isn't the end. This should never happen, since
    # this would require an empty input from the user, yet that should be handled in
    # the main loop, but just in case I'll include this.
    if not end_token? @tokens.first 
      if SYS_COMMAND_STRINGS.include? @tokens.first
        # Attempt to parse a sys-command
        sysCommand = @tokens.shift # consume and store the command token
        if sysCommand == 'ls'
        	if end_token? @tokens.first
	        	#TODO process ls command
        	else
        		puts 'Error: ls command does not accept arguments.'
        	end
        elsif sysCommand == 'clr'
        	if end_token? @tokens.first
	        	#TODO process clr command
        	else
        		puts 'Error: clr command does not accept arguments.'
        	end
        elsif sysCommand == 'rm'
        	if not end_token? @tokens.first
	        	if user_identifier? @tokens.first
	        		identifier = @tokens.shift # consume and store the user identifier
			      	if end_token? @tokens.first
		      			#TODO process rm command
        			else
		        		puts 'Error: rm command accepts only one argument.'
		        	end
	        	else
	        		puts 'Error: rm expected valid user identifier.'
	        	end
        	else
        		puts 'Error: Missing identifier argument.'
        	end
        else 
        # should be a redundant case, because token had to have
        # been in SYS_COMMAND_STRINGS
        	puts 'Error: Invalid system command (dev, this should not happen).'
        end
      elsif @tokens[1] == '='
        if user_identifier? @tokens.first
          # at this point, this is either assignment to a new or exisitng identifier,
          # so a user identifier and an '=' character can be consumed
          identifier = @tokens.shift # consume identifier
          @tokens.shift # consume '=' character
          if @tokens.length >= 3 # path to check for dimensions
            if positive_integer? @tokens.first 
              if @tokens[1] == 'by' or @tokens[1] == 'x'
                m = @tokens.shift # consume and save the m dimension
                @tokens.shift # consume the 'by' or 'x' character
                if positive_integer? @tokens.first
                  # we must have an assignment command, with dimensions using a by or x
                  n = @tokens.shift
                  if end_token? @tokens.first
										#TODO get user input                  
                  else
                  	puts 'Error: Too many arguments for dimensions.'
                  end
                else
                  puts 'Error: Expected positive integer value for n dimension.'
                end
              elsif positive_integer? @tokens[1] 
                # we must have an assignment command, with dimensions without the by or x
                m = @tokens.shift
                n = @tokens.shift
                if end_token? @tokens.first
									#TODO get user input                  
                else
                	puts 'Error: Too many arguments for dimensions.'
                end
              else
                # must be assignment from expression
                expr = parse_expr
                if expr.is_a? [].class 
  	            	# type checking for an Array.
	                # Ruby doesnt like this but its necessary
                  @matrices[identifier] = expr
                else
                  puts 'Error: Cannot assign a scalar value to a variable.'
                end
              end
            else 
              # must be assignment from expression
              expr = parse_expr
              if expr.is_a? [].class 
              	# type checking for an Array.
                # Ruby doesnt like this but its necessary
                @matrices[identifier] = expr
              else
                puts 'Error: Cannot assign a scalar value to a variable.'
              end
            end
          else
            # must be assignment from expression
            expr = parse_expr
            if expr.is_a? [].class 
            	# type checking for an Array.
              # Ruby doesnt like this but its necessary
              @matrices[identifier] = expr
            else
              puts 'Error: Cannot assign a scalar value to a variable.'
            end
          end
        else
          puts 'Error: Expected user identifier for assignment.'
        end 
      else
        # case where just an expression was typed in
        expr = parse_expr #TODO expression but with extra garbage afterwards??
        puts ">> #{expr}"        
      end
    else
      puts 'Error: Command was empty (if this is happening, something is very broken)'
    end
  end
  
  def parse_expr
  	expr = parse_term # parse the first term into the expression
  	if not expr.equal? nil
  	  # make sure term parsed correctly
			while add_op? @tokens.first
			  op = @tokens.shift # consume and store operator token (+, -)
			  if not end_token? @tokens.first
			  	# make sure that there is a token to follow the add op
			  	term = parse_term # parse the term following the operation
			  	if not term.equal? nil
			  		# if next term was parsed correctly
			  		if op == '+'
							# handle adding terms
							if term.is_a? [].class
								# handle matrix addition
								if expr.is_a? [].class 
									# ensure current expression matches next term type
									# TODO matrix addition can be appropriately done here
								else
									puts 'Error: Cannot add matrix to scalar.'
									expr = nil
								end
							else
								# handle scalar addition
								if expr.is_a? 1.class 
									# ensure current expression matches next term type
									# TODO scalar addition can be appropriately handled here
									expr += term # calculate the expression using addition
								else
									puts 'Error: Cannot add scalar to matrix.'
									expr = nil
								end
							end
						else # op == '-'
							# handle subtracting terms
							if term.is_a? [].class
								# handle matrix subtraction
								if expr.is_a? [].class 
									# ensure current expression matches next term type
									# TODO matrix subtraction can be appropriately done here
								else
									puts 'Error: Cannot subtract matrix from scalar.'
									expr = nil
								end
							else
								# handle scalar subtraction
								if expr.is_a? 1.class 
									# ensure current expression matches next term type
									# TODO scalar subtraction can be appropriately handled here
									expr -= term # calculate the expression using subtraction
								else
									puts 'Error: Cannot subtract scalar from a matrix.'
									expr = nil
								end
							end
						end
			  	else
			  		puts 'Error Parsing Term' #TODO necessary to print here?
			  		expr = nil
			  	end
			  else 
			  	puts 'Error: Expected a term to follow (+/-).'
			  	expr = nil
			  end
			end
  	end
  	
  	return expr
  end
  
  def parse_term
  	return @tokens.shift.to_i #TODO palceholder for parse term
  end
  
  def parse_factor
  	
  end
  
end                           
