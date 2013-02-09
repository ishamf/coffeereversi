
# Raphael initialization
CELL_SIZE = 40
BOARD_SIZE = CELL_SIZE*8
paper = Raphael(0, 0, BOARD_SIZE, BOARD_SIZE)

current_player = 1

# Initialization
# Create an array that holds the cells
board = []
# Container functions to create the click and hover handler
clickcontainer = (x, y) ->
    return () ->
        # Handles clicking of pieces
        if pointlegalmove(x, y, current_player)
            move(x, y, current_player)
            playerswitch()
hovercontainer = (x, y) ->
    return () ->
        # Moves the cursor to follow the mouse
        cursor.attr 'cx', (x-0.5)*CELL_SIZE
        cursor.attr 'cy', (y-0.5)*CELL_SIZE
for x in [1..8]
    board[x] = []
    for y in [1..8]
        board[x][y] =
            # Create a circle in raphael
            img: paper.circle((x-0.5)*CELL_SIZE, (y-0.5)*CELL_SIZE, (CELL_SIZE-5)/2)
            # 0 is empty, 1 is white, 2 is black
            state: 0
        img = board[x][y].img
        # Make the circles clickable (by default they are transparent)
        img.attr 'fill', '#fff'
        # Adds the handlers
        img.click clickcontainer(x, y)
        img.hover hovercontainer(x, y)

# Creates a cursor that will follow the mouse and display the current player
cursor = paper.circle CELL_SIZE/2, CELL_SIZE/2, (CELL_SIZE)/2
cursor.attr 'stroke', '#ddf'
cursor.attr 'stroke-width', '4'

# An array of all possible directions
directions = [
    [1, 0],   # East
    [1, 1],   # Southeast
    [0, 1],   # South
    [-1, 1],  # Southwest
    [-1, 0],  # West
    [-1, -1], # Northwest
    [0, -1],  # North
    [1, -1],  # Northeast
]
# Define some helper functions

# Gives the opposite of the player
opposite = (player) -> if player == 1 then 2 else 1

# Switches the current player
# It also changes the color of the cursor to match the current player
playerswitch = () ->
    current_player = opposite current_player
    if current_player == 1
        cursor.attr 'stroke', '#ddf'
    else
        cursor.attr 'stroke', '#113'

# Traverses a direction from a point and return all cell coords
traverse = (x, y, xdir, ydir) ->
    cells = []
    while 1 <= x <= 8 and 1 <= y <= 8
        cells.push [x, y]
        x += xdir
        y += ydir
    return cells

# Simply calls traverse() on all 8 directions and returns 8 arrays
traversepoint = (x, y) ->
    result = []
    for [xdir, ydir] in directions
        result.push traverse x, y, xdir, ydir
    return result

# Checks if an array of coordinates from traverse() contains a legal move for a given player
linelegalmove = (array, player) ->
    # State opposite to the player
    ostate = opposite player 
    # Stores if the second cell is an opposite cell
    hasopposite = false 
    for [x, y] in array
        # If this cell does not contain the opposite state,
        if board[x][y].state != ostate 
            # the cell is owned by the player, and it has at least one opposite cell...
            if board[x][y].state == player and hasopposite 
                # The move is legal
                return true 
            else
                # Else it isn't (cell is empty)
                return false 
        else
            hasopposite = true

# Checks if the point has any legal move for the player
pointlegalmove = (x, y, player) ->
    # If it isn't empty then it is illegal
    if board[x][y].state != 0 then return false 
    arrays = traversepoint x, y
    for array in arrays
        if linelegalmove array[1..], player
            # Return as soon as we discover a legal move
            return true 
    # Return false if we didn't 
    return false 

# Sets a point on the board to be owned by the given player
# Also updates the graphics
setpoint = (x, y, player) ->
    board[x][y].state = player
    img = board[x][y].img
    img.attr 'stroke', '#000'
    img.attr 'fill', if player == 1 then '#ddf' else '#113'
    return undefined

# Captures the pieces until the player's piece in the array of coords
moveline = (array, player) ->
    if not linelegalmove array, player
        return undefined
    ostate = opposite player
    for [x, y] in array
        if board[x][y].state == ostate
            setpoint(x, y, player)
        else
            return undefined

# Calls moveline on all eight directions
move = (x, y, player) ->
    arrays = traversepoint x, y
    setpoint x, y, player
    for array in arrays
        moveline array[1..], player
    return undefined

# Specify the starting pieces
setpoint(4, 4, 1)
setpoint(4, 5, 2)
setpoint(5, 4, 2)
setpoint(5, 5, 1)
