# Class to parse and process commands for Matrix Lab system.

# ================================ CONSTANTS =============================================

# the maximum dimension allowed for a matrix in the system
MAX_DIMENSION = 100

SYS_COMMAND_STRINGS = ['ls', 'clr', 'rm']

ADD_OP_STRINGS = ['+', '-']

UNARY_OP_STRINGS = ['det', 'rref', 'inv', 'trans']

END_OF_INPUT_STRING = 'END_OF_INPUT'

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

  # ============================== PARSE METHODS =========================================

  # note: shift on tokens returns next token, first on tokens looks at next token
  # by convention, of course, not enforced by language
  
  def parse_command(command)
    @tokens = command + [END_OF_INPUT_STRING]
    puts @tokens
    
    
  end
  



end
