class Spriteset_Battle

  #just throw the weather creation somewhere after viewports created...
  alias tsuki_weatherfx_create_viewports create_viewports
  def create_viewports
    tsuki_weatherfx_create_viewports
    create_weather
  end

  def create_weather
    @weather = Spriteset_Weather.new(@viewport2)
    @weather.type = $game_map.screen.weather_type
    @weather.power = $game_map.screen.weather_power
  end

  alias tsuki_screenfx_spritebattle_update update
  def update
    tsuki_screenfx_spritebattle_update
    update_weather
  end

  #only update weather if it's not the same as the current weather?
  def update_weather
    #@weather.type = $game_troop.screen.weather_type if $game_troop.screen.weather_type != @weather.type
    #@weather.power = $game_troop.screen.weather_power if $game_troop.screen.weather_power != @weather.power
    @weather.ox = 0
    @weather.oy = 0
    @weather.update
  end

  #throw weather disposal somewhere before viewports are disposed...
  alias tsuki_weatherfx_dispose_viewports dispose_viewports
  def dispose_viewports
    dispose_weather
    tsuki_weatherfx_dispose_viewports
  end

  def dispose_weather
    @weather.dispose
  end
end

class Game_Interpreter

  #allow weather in battle
  alias tsuki_weatherfx_command_236 command_236
  def command_236
    if $game_party.in_battle
      screen.change_weather(@params[0], @params[1], @params[2])
      wait(@params[2]) if @params[3]
    else
      tsuki_weatherfx_command_236
    end
  end
end
