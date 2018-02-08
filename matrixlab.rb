# Matrix Lab - Ruby
require_relative 'MatrixLabParser.rb'

# current version
version_num = '0.0.1'

# the symbol to display as a prompt
prompt = '%'

# loop control variable
run = true


# ============================= Define Functions =========================================

def quit_command?(str)
  return (str == 'q' or str == 'quit' or str == 'exit')
end


# Initialize Program

# parser object to process the command
parser = MatrixLabParser.new

# display welcome message
puts 'Matrix Lab v#{version_num}'

# main program loop
while run
  
    # get a command from the user
    print prompt + ' '
    com = gets.chomp.split
    
    if com.length > 0 
      # flag to end main loop, if quit or exit command entered
      if quit_command?(com[0])
        run = false
      else
        # attempt to parse and process the command
        parser.parse_command com
      end      
    end
end

