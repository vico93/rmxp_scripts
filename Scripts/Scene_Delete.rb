#============================================================================
# ** Scene_Delete
#----------------------------------------------------------------------------
#  Permite que você delete um save pelo jogo.
#============================================================================

class Scene_Delete < Scene_File
  #--------------------------------------------------------------------------
  # * Inicialização dos objeto
  #--------------------------------------------------------------------------
  def initialize
    # Refaz objetos temporaios
    $game_temp = Game_Temp.new
    # ????
    $game_temp.last_file_index = 0
    latest_time = Time.at(0)
    for i in 0..3
      filename = make_filename(i)
      if FileTest.exist?(filename)
        file = File.open(filename, "r")
        if file.mtime > latest_time
          latest_time = file.mtime
          $game_temp.last_file_index = i
        end
        file.close
      end
    end
    super("Que aventura você deseja apagar?")
  end
  #--------------------------------------------------------------------------
  # * Executa se necessario
  #--------------------------------------------------------------------------
  def on_decision(filename)
    # Se o arquivo não existe
    unless FileTest.exist?(filename)
      # Play SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # Play SE
    $game_system.se_play($data_system.decision_se)
    # Deleta a data
    File.delete(filename)
    # Volta a tela do titulo
    $scene = Scene_Title.new
  end
  #--------------------------------------------------------------------------
  # * Cancela se necessario
  #--------------------------------------------------------------------------
  def on_cancel
    # Play SE
    $game_system.se_play($data_system.cancel_se)
    # Volta a tela do titulo
    $scene = Scene_Title.new
  end
end