namespace :games do
  desc 'Closes old games'
  task :close => [:environment] do
    games.closeable.find_each do |game|
      game.is_closed = true
      game.save!
      UpdateGameMessageWorker.perform_async(game.id)
    end
  end

  desc 'Updates all messages'
  task :update => [:environment] do
    Game.find_each do |game|
      UpdateGameMessageWorker.perform_async(game.id)
    end
  end
end
