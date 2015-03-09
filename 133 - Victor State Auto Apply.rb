#==============================================================================
# ** Victor Engine - State Auto Apply
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.05.24 > First release
#  v 1.01 - 2012.05.30 > Fixed bug with anim id
#  v 1.02 - 2012.07.02 > Compatibility with Basic Module 1.22
#  v 1.03 - 2012.07.06 > Fixed problem with some conditions
#  v 1.04 - 2012.07.08 > Setup changed, now it's possible to setup different
#                      > conditions for states on the same object
#  v 1.05 - 2012.08.02 > Compatibility with Basic Module 1.27
#  v 1.06 - 2012.08.06 > Added setup for apply states when using items
#  v 1.07 - 2012.12.24 > Compatibility with Active Time Battle
#  v 1.08 - 2013.01.07 > Added 'state on' trigger
#------------------------------------------------------------------------------
#  This script allows to setup states automatically applied upon certain
# conditions. The states are only applied when the condition is met, they
# can still be removed by any other means.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.27 or higher
#   If used with 'Victor Engine - Animated Battle' place this bellow it.
#   If used with 'Victor Engine - Active Time Battle' place this bellow it.
#
# * Overwrite methods
#   class Game_Interpreter
#     def command_312
#
# * Alias methods
#   class << BattleManager
#     def next_subject
#
#   class Game_BattlerBase
#     def hp=(hp)
#     def mp=(mp)
#     def tp=(tp)
#     def refresh
#
#   class Game_Battler < Game_BattlerBase
#     def add_new_state(state_id)
#     def revemo_state(state_id)
#     def execute_damage(user)
#     def on_battle_start
#     def on_action_end
#     def on_turn_end
#     def on_battle_end
#
#   class Scene_Battle < Scene_Base
#     def turn_start
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Actors, Classes, Wapons, Armors, States and Enemies note tags:
#   Tags to be used on  Actors, Classes, Wapons, Armors, States and Enemies
#   note boxes.
# 
#  <apply auto state trigger: id, id>
#  conditions;
#  </apply auto state>
#
#   Setup the state ID, trigger and conditions to apply the state
#     id         : state ID
#     trigger    : the trigger define when the condition will be checked
#     conditions : conditions that must be met to the state be applied
#
#    Triggers: the trigger define when the condition will be checked
#      only one trigger can be set for each setting
#    - hp change    : make the check when the HP changes
#    - mp change    : make the check when the MP changes
#    - tp change    : make the check when the TP changes
#    - hp damage    : make the check when take HP damage
#    - hp recover   : make the check when recover HP
#    - mp damage    : make the check when take MP damage
#    - mp recover   : make the check when recover MP
#    - battle start : make the check on the battle start
#    - battle end   : make the check on the battle end
#    - turn start   : make the check on the turn start
#    - turn end     : make the check on the turn end
#    - action start : make the check on the action start
#    - action end   : make the check on the action end
#    - skill use x  : make the check when using the skill ID = x
#    - item use x   : make the check when using the item ID = x
#    - state on x   : make the check when the State ID = x is removed
#    - state off x  : make the check when the State ID = x is removed
#    
#    Conditions: conditions that must be met to the state be applied
#      the conditions can be status based or a custom script call
#      you can add how many values you want always separating them with a ;
#      at the end. Script calls can have multiple lines, just add the ; at
#      the end of the last condition.
#    stat higher x      stat equal x
#    stat higher x%     stat equal x%
#    stat lower x       stat different x
#    stat lower x%      stat different x%
#      The state add conditions will be valid if the stat set meets the
#      condition when compared with value y. You can use any stat
#      available for the battler,   even custom ones.
#        stat : stat name (maxhp, maxmp, maxtp, hp, mp, tp, atk, def, mat...)
#        x    : value (can be evaluted), % value can only be used with
#               the stats "hp", "mp" and "tp"
#
#------------------------------------------------------------------------------
# Additional instructions:
#  It's VERY important to not forget the ; at the end of each condition.
#  This script only add the state, the state can still be resisted normally.
#
#------------------------------------------------------------------------------
# Examples:
# 
#  <apply auto state hp damage: 14>
#  hp lower 25%;
#  </apply auto state>
#    This will apply the state ID 14 if the HP is lower than 25% when take
#    hp damage.
#
#  <apply auto state battle start: 24, 25>
#  hp equal 100%;
#  rand(100) < 30;
#  </apply auto state>
#    This have 30% o chance (defined by the script call rand(100) < 30)
#    to apply the states 24 and 25 at the battle start if the HP is full.
#
#  <apply auto state state off 1: 20>
#  if $game_switches[1]
#    rand(100) < 75
#  else
#    rand(100) < 25
#  end;
#  </apply auto state>
#    This have 25% o chance of apply the state 20 when the state 1 is removed
#    this chance is changed to 75% if the switch 1 is on
#
#------------------------------------------------------------------------------
# Useful script calls:
#   Here some useful script calls that can be used:
#
#   state?(x)
#    checks if the battler is under state ID x
#
#   state_addable?(x)
#    checks if the state ID x can be added (to avoid adding the state if the
#    battler is immune)
# 
#   $game_switches[x]
#    checks if game swicth ID x is ON
#
#   $game_variables[x]
#    you can use this to compare the variable ID x with any value (be sure to
#    to add the comparision sign and the value)
#
#   rand(100) < x
#    to make a % chance user rand(100) < x, where x is the % chance
# 
#   you can also use || for "or" and && for "and"
#     state?(1) || state?(2) # if state 1 or state 2 is added
#     state?(1) && state?(2) # if  boths state 1 and state 2 are added
#   
#   you can also add a ! in front of the condition to make the opposite check
#     !state?(2)         # if state 2 is NOT added
#     !$game_switches[3] # if Switch 3 is OFF
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * required
  #   This method checks for the existance of the basic module and other
  #   VE scripts required for this script to work, don't edit this
  #--------------------------------------------------------------------------
  def self.required(name, req, version, type = nil)
    if !$imported[:ve_basic_module]
      msg = "The script '%s' requires the script\n"
      msg += "'VE - Basic Module' v%s or higher above it to work properly\n"
      msg += "Go to http://victorscripts.wordpress.com/ to download this script."
      msgbox(sprintf(msg, self.script_name(name), version))
      exit
    else
      self.required_script(name, req, version, type)
    end
  end
  #--------------------------------------------------------------------------
  # * script_name
  #   Get the script name base on the imported value
  #--------------------------------------------------------------------------
  def self.script_name(name, ext = "VE")
    name = name.to_s.gsub("_", " ").upcase.split
    name.collect! {|char| char == ext ? "#{char} -" : char.capitalize }
    name.join(" ")
  end
end

$imported ||= {}
$imported[:ve_state_auto_apply] = 1.08
Victor_Engine.required(:ve_state_auto_apply, :ve_basic_module, 1.27, :above)

#==============================================================================
# ** BattleManager
#------------------------------------------------------------------------------
#  This module handles the battle processing
#==============================================================================

class << BattleManager
  #--------------------------------------------------------------------------
  # * Alias method: next_subject
  #--------------------------------------------------------------------------
  alias :next_subject_ve_state_auto_apply :next_subject
  def next_subject
    result = next_subject_ve_state_auto_apply
    result.add_action_start_state if result && result.current_action
    result
  end
end

#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  This class handles battlers. It's used as a superclass of the Game_Battler
# classes.
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Alias method: hp=
  #--------------------------------------------------------------------------
  alias :hp_ve_state_auto_apply :hp=
  def hp=(hp)
    @hp_change_flag = @hp != hp
    hp_ve_state_auto_apply(hp)
  end
  #--------------------------------------------------------------------------
  # * Alias method: mp=
  #--------------------------------------------------------------------------
  alias :mp_ve_state_auto_apply :mp=
  def mp=(mp)
    @mp_change_flag = @mp != mp
    mp_ve_state_auto_apply(mp)
  end
  #--------------------------------------------------------------------------
  # * Alias method: tp=
  #--------------------------------------------------------------------------
  alias :tp_ve_state_auto_apply :tp=
  def tp=(tp)
    @tp_change_flag = @tp != tp
    tp_ve_state_auto_apply(tp)
  end
  #--------------------------------------------------------------------------
  # * Alias method: change_hp
  #--------------------------------------------------------------------------
  alias :change_hp_ve_state_auto_apply :change_hp
  def change_hp(value, enable_death)
    change_hp_ve_state_auto_apply(value, enable_death)
    auto_apply_state(:hp_damage)  if value < 0
    auto_apply_state(:hp_recover) if value > 0
  end
  #--------------------------------------------------------------------------
  # * Alias method: refresh
  #--------------------------------------------------------------------------
  alias :refresh_ve_state_auto_apply :refresh
  def refresh
    refresh_auto_apply_states
    refresh_ve_state_auto_apply
  end
  #--------------------------------------------------------------------------
  # * New method: refresh_auto_apply_states
  #--------------------------------------------------------------------------
  def refresh_auto_apply_states
    auto_apply_state(:hp_change) if @hp_change_flag
    auto_apply_state(:mp_change) if @mp_change_flag
    auto_apply_state(:tp_change) if @tp_change_flag
    @hp_change_flag = @tp_change_flag = @tp_change_flag = nil
  end
  #--------------------------------------------------------------------------
  # * New method: auto_apply_state
  #--------------------------------------------------------------------------
  def auto_apply_state(trigger, id = 0)
    value1 = 'APPLY AUTO STATE'
    value2 = '([\w ]+): ((?:\d+ *,? *)+)'
    regexp = get_all_values("#{value1} #{value2}", value1)
    get_all_notes.scan(regexp) do
      state  = $2.dup
      notes  = $3.dup
      symbol = $1 =~ /([^\d ]+ *[^\d ]+) *(\d+)?/i ? make_symbol($1) : nil
      id2    = $2 ? $2.to_i : 0
      next if symbol != trigger || id != id2 || !apply_state_condition(notes)
      state.scan(/(\d+)/i) { add_state_normal($1.to_i) }
    end
  end
  #--------------------------------------------------------------------------
  # * New method: apply_state_condition
  #--------------------------------------------------------------------------
  def apply_state_condition(notes)
    notes.scan(/([^;]*);/im) do
      value  = $1.dup
      result = value =~ /\w+ (?:HIGHER|LOWER|EQUAL|DIFFERENT) [^><]*/i
      return false if  result && !apply_state_stat?(value)
      return false if !result && !apply_state_custom?(value)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * New method: apply_state_stat?
  #--------------------------------------------------------------------------
  def apply_state_stat?(notes)
    if notes =~ /(\w+) (HIGHER|LOWER|EQUAL|DIFFERENT) ([^><]*)/im
      stat  = $1.dup
      cond  = $2.dup
      value = $3.dup
      if value =~ /(\d+)\%/i and ["HP","MP","TP"].include?(stat.upcase)
        return eval("#{stat.downcase}_rate * 100 #{get_cond(cond)} #{$1}")
      else
        return eval("#{get_param(stat)} #{get_cond(cond)} #{value}")
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: apply_state_custom?
  #--------------------------------------------------------------------------
  def apply_state_custom?(notes)
    eval("#{notes.gsub(/\r\n/i, ";")}") rescue false
  end
end

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Alias method: add_new_state
  #--------------------------------------------------------------------------
  alias :add_new_state_ve_state_auto_apply :add_new_state
  def add_new_state(state_id)
    auto_apply_state(:state_on, state_id)
    add_new_state_ve_state_auto_apply(state_id)
  end
  #--------------------------------------------------------------------------
  # * Alias method: remove_state
  #--------------------------------------------------------------------------
  alias :remove_state_ve_state_auto_apply :remove_state
  def remove_state(state_id)
    auto_apply_state(:state_off, state_id) if state?(state_id)
    remove_state_ve_state_auto_apply(state_id)
  end
  #--------------------------------------------------------------------------
  # * Alias method: execute_damage
  #--------------------------------------------------------------------------
  alias :execute_damage_ve_state_auto_apply :execute_damage
  def execute_damage(user)
    execute_damage_ve_state_auto_apply(user)
    auto_apply_state(:hp_damage)  if @result.hp_damage > 0
    auto_apply_state(:hp_recover) if @result.hp_damage < 0
    auto_apply_state(:mp_damage)  if @result.mp_damage > 0
    auto_apply_state(:mp_recover) if @result.mp_damage < 0
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_battle_start
  #--------------------------------------------------------------------------
  alias :on_battle_start_ve_state_auto_apply :on_battle_start
  def on_battle_start
    on_battle_start_ve_state_auto_apply
    auto_apply_state(:battle_start)
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_action_end
  #--------------------------------------------------------------------------
  alias :on_action_end_ve_state_auto_apply :on_action_end
  def on_action_end
    on_action_end_ve_state_auto_apply
    auto_apply_state(:action_end)
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_turn_end
  #--------------------------------------------------------------------------
  alias :on_turn_end_ve_state_auto_apply :on_turn_end
  def on_turn_end
    on_turn_end_ve_state_auto_apply
    auto_apply_state(:turn_end)
  end
  #--------------------------------------------------------------------------
  # * Alias method: on_battle_end
  #--------------------------------------------------------------------------
  alias :on_battle_end_ve_state_auto_apply :on_battle_end
  def on_battle_end
    on_battle_end_ve_state_auto_apply
    auto_apply_state(:battle_end)
  end
  #--------------------------------------------------------------------------
  # * New method: add_action_start_state
  #--------------------------------------------------------------------------
  def add_action_start_state
    item = current_action.item
    auto_apply_state(:action_start)
    auto_apply_state(:skill_use, item.id) if item && item.skill?
    auto_apply_state(:item_use, item.id)  if item && item.item?
  end
end 

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Alias method: turn_start
  #--------------------------------------------------------------------------
  alias :execute_floor_damage_ve_state_auto_apply :execute_floor_damage
  def execute_floor_damage
    execute_floor_damage_ve_state_auto_apply
    auto_apply_state(:hp_damage) if (basic_floor_damage * fdr).to_i > 0
  end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Overwrite method: command_312
  #--------------------------------------------------------------------------
  def command_312
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.mp += value
      actor.auto_apply_state(:mp_damage)  if value < 0
      actor.auto_apply_state(:mp_recover) if value > 0
    end
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias method: turn_start
  #--------------------------------------------------------------------------
  alias :turn_start_ve_state_auto_apply :turn_start
  def turn_start
    turn_start_ve_state_auto_apply
    all_battle_members.each {|member| member.auto_apply_state(:turn_start) }
  end
end
