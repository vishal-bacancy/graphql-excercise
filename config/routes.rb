Rails.application.routes.draw do
  resources :lessons
  resources :users
  resources :repositories do
    get "more", on: :collection
    get "all_repos", on: :collection
  end
  get "/", to: redirect("/repositories")
end
