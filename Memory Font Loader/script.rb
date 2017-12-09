#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
# Memory Font Loader
# Author: ForeverZer0
# Version: 1.1
# Date: 12.17.2014
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
#                             VERSION HISTORY
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
# v.1.0   1.8.2014
#   - Original Release
# v.1.1   12.17.2014
#   - Improved compatibility on different systems by adding "AddFontResource"
#     as backup call if "AddFontResourceEx" fails
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
#
# Introduction:
#
#   Small script that allows for loading and using fonts into memory at run-time
#   without the need for installing them on the operating system. The advantage
#   of this script over others, such as Wachunga's font-install script, is that 
#   it does not require a administrator privileges to use the fonts, nor a 
#   restart of the game after running. 
#
# Features:
#
#   - Automatically load all fonts found in user-defined folder
#   - Supports TrueType (*.ttf) and OpenType(*.otf) fonts
#   - Does not require Administrator privileges
#   - Does not require a game restart
#
# Instructions:
#   
#   - Place script anywhere above main
#   - Some optional configuration below with explanation
#   - Use the script call "Font.add(PATH_TO_FILE)" to add a font.
#   - If using auto-load, create a folder for the fonts ("Fonts" by default), 
#     and place all font files within it. Loading will be done automatically.
#
# Compatibility:
#
#   - No known compatibility issues with any other script.
#
# Credits/Thanks:
#
#   - ForeverZer0, for the script
#   - Duds, for pointing out the "AddFontResource" fix
#
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=

#===============================================================================
# ** Font
#-------------------------------------------------------------------------------
# The font class. Font is a property of the Bitmap class.
#===============================================================================
class Font
  
  #-----------------------------------------------------------------------------
  #                            CONFIGURATION
  #-----------------------------------------------------------------------------
  
  # This value (true/false) indicates if all fonts in the specified fonts folder
  # will be automatically loaded when the game is started.
  AUTO_LOAD = true
    
  # Set this to the name of the folder, relative to the game directory, where
  # the font files are contained. This folder will be searched for font files
  # when using the auto-load feature
  FONT_FOLDER = 'Fonts'
  
  #-----------------------------------------------------------------------------
  #                           END CONFIGURATION
  #-----------------------------------------------------------------------------
  
  #-----------------------------------------------------------------------------
  # * Constants
  #-----------------------------------------------------------------------------
  WM_FONTCHANGE = 0x001D
  HWND_BROADCAST = 0xFFFF
  AddFontResource = Win32API.new('gdi32', 'AddFontResource', ['P'], 'L')
  AddFontResourceEx = Win32API.new('gdi32', 'AddFontResourceEx', 'PLL', 'L')
  SendMessage = Win32API.new('user32', 'SendMessage', 'LLLL', 'L')
  SendNotifyMessage = Win32API.new('user32', 'SendNotifyMessage', 'LLLL', 'L')
  #-----------------------------------------------------------------------------
  # * Class Variables
  #-----------------------------------------------------------------------------
  @@memory_fonts = []
  #-----------------------------------------------------------------------------
  # * Load font(s) into memory
  #     filename  : Full path to font file. Accepts multiple filenames.
  #-----------------------------------------------------------------------------
  def self.add(*filenames)
    filenames.each {|f| 
      next if @@memory_fonts.include?(f)
      if AddFontResourceEx.call(f, 16, 0) > 0 || AddFontResource.call(f) > 0
        @@memory_fonts.push(f)
      end
    }
    SendNotifyMessage.call(HWND_BROADCAST, WM_FONTCHANGE, 0, 0)
    SendMessage.call(HWND_BROADCAST, WM_FONTCHANGE, 0, 0)
  end
  #-----------------------------------------------------------------------------
  # * Automatically seach and load all font files found in the font folder.
  #-----------------------------------------------------------------------------
  def self.auto_load
    dir = FONT_FOLDER == '' ? Dir.pwd : File.join(Dir.pwd, FONT_FOLDER)
    return unless File.directory?(dir)
    files = Dir.glob(File.join(dir, '*.{ttf,otf}'))
    self.add(*files)
  end
end

# Load fonts if using auto-load
if Font::AUTO_LOAD
  Font.auto_load 
end