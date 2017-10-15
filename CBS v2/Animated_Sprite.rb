#==============================================================================
# * Animated_Sprite Scripted by: RPG
# Edited by: cybersam
#
# i just removed the stuff that i dont need for my script...
# everything else is RPG's script... (here)
# 
#------------------------------------------------------------------------------
# A class for animated sprites.
#==============================================================================

class Animated_Sprite < RPG::Sprite
#--------------------------------------------------------------------------
# - Accessible instance variables.
#--------------------------------------------------------------------------
attr_accessor :frames # Number of animation frames 
attr_accessor :delay # Delay time between frames (speed)
attr_accessor :frame_width # Width of each frame 
attr_accessor :frame_height # Height of each frame
attr_accessor :offset_x # X coordinate of the 1st frame
attr_accessor :offset_y # Y coordinate of all frames
attr_accessor :current_frame # Current animation frame
attr_accessor :moving # Is the sprite moving?

#--------------------------------------------------------------------------
# - Initialize an animated sprite
# viewport : Sprite viewport
#--------------------------------------------------------------------------
def initialize(viewport = nil)
super(viewport)
@frame_width, @frame_height = 0, 0
change # A basic change to set initial variables
@old = Graphics.frame_count # For the delay method
@goingup = true # Increasing animation? (if @rm2k_mode is true)
@once = false # Is the animation only played once?
@animated = true # Used to stop animation when @once is true
end

#--------------------------------------------------------------------------
# Comment by RPG
# - Change the source rect (change the animation)
# frames : Number of animation frames
# delay : Frame delay, controls animation speed
# offx : X coordinate of the 1st frame
# offy : Y coordinate of all frames
# startf : Starting frame for animation
# once : Is the animation only played once?
# rm2k_mode : Animation pattern: 1-2-3-2 if true, 1-2-3-1 if false
#
# Comment by cybersam
#
# the rm2k_mode isnt pressent anymore...
# if you want that feature then use rm2k or use RPG's script...
#--------------------------------------------------------------------------
def change(frames = 0, delay = 0, offx = 0, offy = 0,
startf = 0, once = false)
@frames = frames
@delay = delay
@offset_x, @offset_y = offx, offy
@current_frame = startf
@once = once
x = @current_frame * @frame_width + @offset_x
self.src_rect = Rect.new(x, @offset_y, @frame_width, @frame_height)
@goingup = true
@animated = true
end

#--------------------------------------------------------------------------
# - Update animation and movement
#--------------------------------------------------------------------------
def update
super
if self.bitmap != nil and delay(@delay) and @animated
x = @current_frame * @frame_width + @offset_x
self.src_rect = Rect.new(x, @offset_y, @frame_width, @frame_height)
@current_frame = (@current_frame + 1) unless @frames == 0
@animated = false if @current_frame == @frames and @once
@current_frame %= @frames
end
end

#--------------------------------------------------------------------------
# - Move the sprite
# x : X coordinate of the destination point
# y : Y coordinate of the destination point
# speed : Speed of movement (0 = delayed, 1+ = faster)
# delay : Movement delay if speed is at 0
#--------------------------------------------------------------------------
def move(x, y, speed = 1, delay = 0)
@destx = x
@desty = y
@move_speed = speed
@move_delay = delay
@move_old = Graphics.frame_count
@moving = true
end

#--------------------------------------------------------------------------
# - Move sprite to destx and desty
#--------------------------------------------------------------------------
def update_move
return unless @moving
movinc = @move_speed == 0 ? 1 : @move_speed
if Graphics.frame_count - @move_old > @move_delay or @move_speed != 0
self.x += movinc if self.x < @destx
self.x -= movinc if self.x > @destx
self.y += movinc if self.y < @desty
self.y -= movinc if self.y > @desty
@move_old = Graphics.frame_count
end
if @move_speed > 1 # Check if sprite can't reach that point
self.x = @destx if (@destx - self.x).abs % @move_speed != 0 and
(@destx - self.x).abs <= @move_speed
self.y = @desty if (@desty - self.y).abs % @move_speed != 0 and
(@desty - self.y).abs <= @move_speed
end
if self.x == @destx and self.y == @desty
@moving = false
end
end

#--------------------------------------------------------------------------
# - Pause animation, but still updates movement
# frames : Number of frames
#--------------------------------------------------------------------------
def delay(frames)
update_move
if (Graphics.frame_count - @old >= frames)
@old = Graphics.frame_count
return true
end
return false
end
end