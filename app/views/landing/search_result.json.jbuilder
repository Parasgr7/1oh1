json.categories do
  json.array! @categories do |category|
    json.name category.name
    json.description category.description
    json.url categories_explorers_path(category)
    json.icon category_photo(category)
  end
end
json.guides do
  json.array! @guides do |profile|
    json.name profile.user.full_name
    json.url profile_path(profile)
    json.icon profile_photo(profile)
  end
end

json.explores do
  json.array! @explores do |profile|
    json.name profile.user.full_name
    json.url profile_path(profile)
    json.icon profile_photo(profile)
  end
end
json.projects do
  json.array! @projects do |project|
    json.name project.profile.user.full_name
    json.url project_path(project.id)
    json.icon project_photo(project)
  end
end
json.users do
  json.array! @users do |profile|
    json.name profile.user.full_name
    json.url profile_path(profile)
    json.icon profile_photo(profile)
  end
end
