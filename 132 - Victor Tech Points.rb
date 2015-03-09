#==============================================================================
# ** Victor Engine - Tech Points
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.03.17 > First release
#  v 1.01 - 2012.05.20 > Fixed bug with tech recovering items
#  v 1.02 - 2012.07.17 > Added notetags to change max tech points
#                      > Added comment calls to control Tech points
#  v 1.03 - 2012.08.18 > Compatibility with Custom Hit Formula
#------------------------------------------------------------------------------
#   This script allows to setup a new cost mechanic for skill: each skill
# can be used a fixed number of times. Similar to Pokemon games. The skills
# can be recharged with the Recover All event command or specific tags on 
# items and skill.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.15 or higher
#   If used with 'Victor Engine - MP Levels' place this bellow it.
#   If used with 'Victor Engine - Custom Hit Formula' place this bellow it.
#
# * Alias methods (Default)
#   class Game_BattlerBase
#     def refresh
#     def skill_cost_payable?(skill)
#     def pay_skill_cost(skill)
#     def recover_all
# 
#   class Game_Battler < Game_BattlerBase
#     def item_apply(user, item)
#
#   class Game_Actor < Game_Battler
#     def setup(actor_id)
#
#   class Game_Enemy < Game_Battler
#     def initialize(index, enemy_id)
#
#   class Window_SkillList < Window_Selectable
#     def draw_skill_cost(rect, skill)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Actors, Classes, Enemies, Weapons, Armors and States note tags:
#   Tags to be used on Actors, Classes, Enemies, Weapons, Armors and States
#   note boxes.
#
#  <infinite tech point>
#   The battler will ignore tech point cost and will be able to use the skill
#   freely
#  
#------------------------------------------------------------------------------
# Actors and Enemies note tags:
#   Tags to be used on the Actors and Enemies note box in the database
#
#  <tech skill>
#   Setup the skill to use tech point system
#
#  <tech growth x: y>
#   Set a custom max tech point growth for the skill id x.
#     x : skill id
#     y : custom growth, a string that is evaluted, you can use any valid
#         stat for battlers.
#
#  <tech limit x: y>
#   Set a custom max tech point limit for the skill id x.
#     x : skill id
#     y : max tech points limit
#
#------------------------------------------------------------------------------
# Skills note tags:
#   Tags to be used on the Skill note box in the database
#
#  <tech growth: x>
#   Set a custom max tech point growth for the skill.
#     x : custom growth, a string that is evaluted, you can use any valid
#         stat for battlers.
#
#  <tech limit: x>
#   Set a custom max tech point limit for the skill.
#     x : max tech points limit
#
#------------------------------------------------------------------------------
# Skills and Items note tags:
#   Tags to be used on the Skills and Items note box in the database
#
#  <change tech point x: +y>
#  <change tech point x: -y>
#   Set a item or skill to change the current tech point of the skill id x.
#     x : skill id
#     y : changed value
#
#  <change max tech point x: +y>
#  <change max tech point x: =y>
#   Set a item or skill to change the max tech point of the skill id x.
#     x : skill id
#     y : changed value
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
# 
#  <change tech point x: y, +z>
#  <change tech point x: y, -z>
#   Change the current tech point of the actor id x for the skill id y.
#     x : actor id
#     y : skill id
#     z : changed value
# 
#  <change max tech point x: y, +z>
#  <change max tech point x: y, -z>
#   Change the max tech point of the actor id x for the skill id y.
#     x : actor id
#     y : skill id
#     z : changed value
# 
#  <recover tech points: x>
#   Recover all tech points for the actor id x
#     x : actor id
# 
#  <recover all tech points>
#   Recover all tech points for the whole party
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  The tech point growth and limit from actors have a higher priority than
#  the skill custom growth and limit, when both are set.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Set the tech points growth
  #   The growth value is a string that is evaluted, you can use any valid
  #   stat for battlers (level, mmh, mmp, atk, def, mat, mdf, agi, luk)
  #   and any valid method for Game_Battlers (as long they return numbers)
  #--------------------------------------------------------------------------
  VE_DEFAULT_TECH_GROWTH = "1 + level / 5"
  #--------------------------------------------------------------------------
  # * Setup the max tech point limit
  #--------------------------------------------------------------------------
  VE_DEFAULT_TECH_MAX = 20
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
$imported[:ve_techs_points] = 1.03
Victor_Engine.required(:ve_techs_points, :ve_basic_module, 1.15, :above)

#==============================================================================
# ** RPG::UsableItem
#------------------------------------------------------------------------------
#  This is the superclass for skills and items.
#==============================================================================

class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * New method: change_tech_points
  #--------------------------------------------------------------------------
  def change_tech_points
    regexp = /<CHANGE TECH POINT (\d+): ([+-]?\d+)>/i
    note.scan(regexp).collect { {id: $1.to_i, value: $2.to_i} }
  end
  #--------------------------------------------------------------------------
  # * New method: change_max_tech_points
  #--------------------------------------------------------------------------
  def change_max_tech_points
    regexp = /<CHANGE MAX TECH POINT (\d+): ([+-]?\d+)>/i
    note.scan(regexp).collect { {id: $1.to_i, value: $2.to_i} }
  end
end

#==============================================================================
# ** RPG::Skill
#------------------------------------------------------------------------------
#  This is the data class for skills.
#==============================================================================

class RPG::Skill < RPG::UsableItem
  #--------------------------------------------------------------------------
  # * New method: is_tech_skill?
  #--------------------------------------------------------------------------
  def is_tech_skill?
    note =~ /<TECH SKILL>/i
  end
  #--------------------------------------------------------------------------
  # * New method: tech_growth
  #--------------------------------------------------------------------------
  def tech_growth
    note =~ /<TECH GROWTH: ([^>]+)>/i ? $1 : ""
  end
  #--------------------------------------------------------------------------
  # * New method: tech_limit
  #--------------------------------------------------------------------------
  def tech_limit
    note =~ /<TECH LIMIT: (\d+)>/i ? $1 : ""
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
  # * Alias method: refresh
  #--------------------------------------------------------------------------
  alias :refresh_ve_tech_points :refresh
  def refresh
    refresh_techs
    refresh_ve_tech_points
  end
  #--------------------------------------------------------------------------
  # * Alias method: skill_cost_payable?
  #--------------------------------------------------------------------------
  alias :skill_cost_payable_ve_tech_points? :skill_cost_payable?
  def skill_cost_payable?(skill)
    skill_cost_payable_ve_tech_points?(skill) && skill_tech_points?(skill)
  end
  #--------------------------------------------------------------------------
  # * Alias method: pay_skill_cost
  #--------------------------------------------------------------------------
  alias :pay_skill_cost_ve_tech_points :pay_skill_cost
  def pay_skill_cost(skill)
    pay_skill_cost_ve_tech_points(skill)
    pay_tech_points_cost(skill)
  end
  #--------------------------------------------------------------------------
  # * Alias method: recover_all
  #--------------------------------------------------------------------------
  alias :recover_all_ve_tech_points :recover_all
  def recover_all
    recover_all_ve_tech_points
    recove_all_techs
  end
  #--------------------------------------------------------------------------
  # * New method: draw_tech_points_cost
  #--------------------------------------------------------------------------
  def skill_tech_points?(skill)
    return true if get_all_notes =~ /<INFINITE TECH POINTS>/i
    setup_tech(skill.id) if !@tech_skills[skill.id]
    @tech_skills[skill.id][:now] > 0
  end
  #--------------------------------------------------------------------------
  # * New method: draw_tech_points_cost
  #--------------------------------------------------------------------------
  def pay_tech_points_cost(skill)
    #change_tech_points(skill.id, -1) if skill.is_tech_skill?
    change_tech_points(skill.id, -1)
  end
  #--------------------------------------------------------------------------
  # * New method: change_tech_points
  #--------------------------------------------------------------------------
  def change_tech_points(id, value)
    setup_tech(id) if !@tech_skills[id]
    @tech_skills[id][:now] += value
    refresh_tech(id)
  end
  #--------------------------------------------------------------------------
  # * New method: change_max_tech_points
  #--------------------------------------------------------------------------
  def change_max_tech_points(id, value)
    @tech_points[id] ||= 0
    @tech_points[id] += value
  end
  #--------------------------------------------------------------------------
  # * New method: refresh_techs
  #--------------------------------------------------------------------------
  def refresh_techs
    @skills.each {|id| refresh_tech(id) }
  end
  #--------------------------------------------------------------------------
  # * New method: refresh_tech
  #--------------------------------------------------------------------------
  def refresh_tech(id)
    setup_tech(id) if !@tech_skills[id]
    max = setup_tech_max(id)
    @tech_skills[id][:max] = max
    @tech_skills[id][:now] = [[@tech_skills[id][:now], 0].max, max].min
  end
  #--------------------------------------------------------------------------
  # * New method: recove_all_techs
  #--------------------------------------------------------------------------
  def recove_all_techs
    @skills.each {|id| setup_tech(id) }
  end
  #--------------------------------------------------------------------------
  # * New method: setup_tech
  #--------------------------------------------------------------------------
  def setup_tech(id)
    max = setup_tech_max(id)
    @tech_skills[id] = {now: max, max: max}
  end
  #--------------------------------------------------------------------------
  # * New method: setup_tech_max
  #--------------------------------------------------------------------------
  def setup_tech_max(id)
    regexp1 = /<TECH GROWTH #{id}: ([^>]+)>/i
    regexp2 = /<TECH LIMIT #{id}: (\d+)>/i
    now  = get_all_notes.scan(regexp1).collect { eval($1) }.max
    max  = get_all_notes.scan(regexp2).collect { $1.to_i  }.max
    now ||= eval($data_skills[id].tech_growth)
    max ||= eval($data_skills[id].tech_limit)
    now ||= eval(VE_DEFAULT_TECH_GROWTH)
    max ||= VE_DEFAULT_TECH_MAX
    now +=  @tech_points[id] if @tech_points[id]
    [[now, 0].max, max].min
  end
  #--------------------------------------------------------------------------
  # * New method: tech_point
  #--------------------------------------------------------------------------
  def tech_point(id)
    @tech_skills[id][:now] rescue 0
  end
  #--------------------------------------------------------------------------
  # * New method: tech_max
  #--------------------------------------------------------------------------
  def tech_max(id)
    @tech_skills[id][:max] rescue 0
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
  # * Alias method: item_apply
  #--------------------------------------------------------------------------
  alias :item_apply_ve_tech_points :item_apply
  def item_apply(user, item)
    item_apply_ve_tech_points(user, item)
    item_tech_point_effect(user, item) if @result.hit?
  end
  #--------------------------------------------------------------------------
  # * New method: item_tech_point_effect
  #--------------------------------------------------------------------------
  def item_tech_point_effect(user, item)
    list = item.change_tech_points
    list.each {|result| change_tech_points(result[:id], result[:value]) }
    list = item.change_max_tech_points
    list.each {|result| change_max_tech_points(result[:id], result[:value]) }
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
  # * Alias method: setup
  #--------------------------------------------------------------------------
  alias :setup_ve_tech_points :setup
  def setup(actor_id)
    @tech_skills = {}
    @tech_points = {}
    setup_ve_tech_points(actor_id)
  end
end

#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemy characters. It's used within the Game_Troop class
# ($game_troop).
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_tech_points :initialize
  def initialize(index, enemy_id)
    @tech_skills = {}
    @tech_points = {}
    initialize_ve_tech_points(index, enemy_id)
    refresh_techs
  end
  #--------------------------------------------------------------------------
  # * New method: refresh_techs
  #--------------------------------------------------------------------------
  def refresh_techs
    enemy.actions.each do |action|
      setup_tech(action.skill_id) if !@tech_skills[action.skill_id]
      @tech_skills[action.skill_id][:max] = setup_tech_max(action.skill_id)
    end
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
  # * Alias method: comment_call
  #--------------------------------------------------------------------------
  alias :comment_call_ve_tech_points :comment_call
  def comment_call
    call_tech_point_change
    call_max_tech_point_change
    call_recover_tech_points
    call_recover_all_tech_points
    comment_call_ve_tech_points
  end
  #--------------------------------------------------------------------------
  # * New method: call_tech_point_change
  #--------------------------------------------------------------------------
  def call_tech_point_change
    regexp = /<CHANGE TECH POINT (\d+): (\d+), *([+-]\d+)>/i
    note.scan(regexp) do
      actor = $game_actors[$1.to_i]
      actor.change_tech_points($2.to_i, $3.to_i) if actor
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_tech_point_change
  #--------------------------------------------------------------------------
  def call_max_tech_point_change
    regexp = /<CHANGE MAX TECH POINT (\d+): (\d+), *([+-]\d+)>/i
    note.scan(regexp) do
      actor = $game_actors[$1.to_i]
      actor.change_max_tech_points($2.to_i, $3.to_i) if actor
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_recover_tech_points
  #--------------------------------------------------------------------------
  def call_recover_tech_points
    regexp = /<RECOVER TECH POINTS:(\d+)>/i
    note.scan(regexp) do
      actor = $game_actors[$1.to_i]
      actor.recove_all_techs if actor
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_recover_all_tech_points
  #--------------------------------------------------------------------------
  def call_recover_all_tech_points
    regexp = /<RECOVER ALL TECH POINTS>/i
    $game_party.members.each {|actor| actor.recove_all_techs }
  end
end

#==============================================================================
# ** Window_Skill
#------------------------------------------------------------------------------
#  This window displays a list of usable skills on the skill screen.
#==============================================================================

class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Alias method: draw_skill_cost
  #--------------------------------------------------------------------------
  alias :draw_skill_cost_ve_tech_points :draw_skill_cost
  def draw_skill_cost(rect, skill)
    draw_skill_cost_ve_tech_points(rect, skill)
    draw_tech_points_cost(rect, skill) if skill.is_tech_skill?
  end
  #--------------------------------------------------------------------------
  # * New method: draw_tech_points_cost
  #--------------------------------------------------------------------------
  def draw_tech_points_cost(rect, skill)
    rect.x -= 32 if @actor.skill_mp_cost(skill) > 0 && !$imported[:ve_mp_level]
    rect.x -= 32 if @actor.skill_tp_cost(skill) > 0 && !$imported[:ve_mp_level]
    change_color(normal_color, enable?(skill))
    now = @actor.tech_point(skill.id)
    max = @actor.tech_max(skill.id)
    draw_text(rect, "#{now}/#{max}", 2)
    rect.x -= 64
  end
end