=begin
===============================================================================
 Playtime in Menu v2.1 (03/9/2014)
-------------------------------------------------------------------------------
 Created By: Shadowmaster/Shadowmaster9000/Shadowpasta
 (www.crimson-castle.co.uk)
 
===============================================================================
 Information
-------------------------------------------------------------------------------
 This script places the total playtime you see on the file screens on your
 menu. The playtime on the menu will also update every second. The window and
 font size for the playtime should automatically match the gold's window and
 font size.
 
===============================================================================
 How to Use
-------------------------------------------------------------------------------
 Place this script under Materials, preferably below by menu altering scripts.
 Nothing else is needed to be done.

===============================================================================
 Required
-------------------------------------------------------------------------------
 Nothing.
 
===============================================================================
 Change log
-------------------------------------------------------------------------------
 v2.1: Fixed error with other scenes that displayed gold also displaying time.
 (03/9/2014)
 v2.0: Added ability to move playtime display above or below gold window. As
 well as the feature to make playtime and party gold share the same window.
 (27/05/2014)
 v1.5: Reduced number of lines used for improved efficiency. (21/08/2013)
 v1.0: First release. (13/01/2013)

===============================================================================
 Terms of Use
-------------------------------------------------------------------------------
 * Free to use for both commercial and non-commerical projects.
 * Credit me if used.
 * Do not claim this as your own.
 * You're free to post this on other websites, but please credit me and keep
 the header intact.
 * If you want to release any modifications/add-ons for this script, the
 add-on script must use the same Terms of Use as this script uses. (But you
 can also require any users of your add-on script to credit you in their game
 if they use your add-on script.)
 * If you're making any compatibility patches or scripts to help this script
 work with other scripts, the Terms of Use for the compatibility patch does
 not matter so long as the compatibility patch still requires this script to
 run.
 * If you want to use your own seperate Terms of Use for your version or
 add-ons of this script, you must contact me at http://www.rpgmakervxace.net
 or www.crimson-castle.co.uk

===============================================================================
=end
$imported = {} if $imported.nil?
$imported["MenuPlaytime"] = true

module MenuPlaytime
  
#==============================================================================
# ** Display Playtime above Gold
#------------------------------------------------------------------------------
#  If set to true, playtime will always be shown above the party gold,
#  regardless of whether the two share the same window or use separate windows.
#  If set to false, playtime will be displayed below the party gold.
#==============================================================================
    
    DisplayPlaytimeAboveGold = true

#==============================================================================
# ** Insert Playtime into Gold Window
#------------------------------------------------------------------------------
#  If set to true, instead of using its own separate window above the gold
#  window, both the playtime and party gold will be displayed within the
#  same window.
#==============================================================================
    
    PlaytimeInGoldWindow = false
    
#==============================================================================
# ** DO NOT edit anything below this unless if you know what you're doing!
#==============================================================================

end

#==============================================================================
# ** Window Time
#------------------------------------------------------------------------------
#  Display Game Time
#==============================================================================
class Window_Time < Window_Base

  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(dx, dy, width)
    super(dx, dy, width, fitting_height(1))
    @play_time = $game_system.playtime_s
    refresh
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    @play_time = $game_system.playtime_s
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(normal_color)
    draw_text(4, 0, contents.width - 8, line_height, @play_time, 2)
  end
end

#==============================================================================
# ** Window_MenuGold
#------------------------------------------------------------------------------
#  This window displays the party's gold.
#==============================================================================

class Window_MenuGold < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, fitting_height(2))
    @play_time = $game_system.playtime_s
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    @play_time = $game_system.playtime_s
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    if MenuPlaytime::DisplayPlaytimeAboveGold == true
      draw_currency_value(value, currency_unit, 4, line_height, contents.width - 8)
      change_color(normal_color)
      draw_text(4, 0, contents.width - 8, line_height, @play_time, 2)
    else
      draw_currency_value(value, currency_unit, 4, 0, contents.width - 8)
      change_color(normal_color)
      draw_text(4, line_height, contents.width - 8, line_height, @play_time, 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Get Party Gold
  #--------------------------------------------------------------------------
  def value
    $game_party.gold
  end
  #--------------------------------------------------------------------------
  # Get Currency Unit
  #--------------------------------------------------------------------------
  def currency_unit
    Vocab::currency_unit
  end
  #--------------------------------------------------------------------------
  # * Open Window
  #--------------------------------------------------------------------------
  def open
    refresh
    super
  end
end

#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  This class performs the menu screen processing.
#==============================================================================
class Scene_Menu < Scene_MenuBase

  #--------------------------------------------------------------------------
  # * Alias Start
  #--------------------------------------------------------------------------
  alias menu_windowtime_start start
  def start
    menu_windowtime_start
    create_time_window if MenuPlaytime::PlaytimeInGoldWindow == false
  end
  #--------------------------------------------------------------------------
  # * Create Time Window
  #--------------------------------------------------------------------------
  def create_time_window
    @time_window = Window_Time.new(Graphics.width - @gold_window.width, 0, @gold_window.width)
    if MenuPlaytime::DisplayPlaytimeAboveGold == true
      @time_window.y = Graphics.height - @time_window.height - @gold_window.height
    else
      @time_window.y = Graphics.height - @time_window.height
    end
  end
  #--------------------------------------------------------------------------
  # * Create Gold Window
  #--------------------------------------------------------------------------
  alias create_gold_window_time create_gold_window
  def create_gold_window
    if MenuPlaytime::PlaytimeInGoldWindow == true
      @gold_window = Window_MenuGold.new
      @gold_window.x = 0
      @gold_window.y = Graphics.height - @gold_window.height
    else
      create_gold_window_time
      @gold_window.y -= @gold_window.height if MenuPlaytime::DisplayPlaytimeAboveGold == false
    end
  end
end
