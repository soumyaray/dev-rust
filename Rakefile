# frozen_string_literal: true

require 'yaml'

task :config do
  container = YAML.safe_load File.read('container.yml')
  @owner = container['dockerhub_username']
  @github_user = container['github_username']
  @name = container['name']
  @version = container['version']
  @username = ENV['USER']
end

desc 'Build the image from Dockerifle'
task build: :config do
  sh "docker build --rm --force-rm -t #{@owner}/#{@name}:#{@version} " +
     "--build-arg USERNAME=#{@username} --build-arg GITHUB_USERNAME=#{@github_user} ."
end

desc 'Run the built container as image'
task run: :config do
  sh "docker run --rm -it #{@owner}/#{@name}:#{@version} zsh"
end

desc 'Publish container to Dockerhub'
task push: :config do
  sh "docker push #{@owner}/#{@name}:#{@version}"
end
