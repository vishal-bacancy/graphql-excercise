class RepositoriesController < ApplicationController

  IndexQuery = GitHub::Client.parse <<-'GRAPHQL'
    {
      organization(login: "google") {
        repositories(privacy: PUBLIC, first: 10) {
          nodes {
            id
            name
            url
            createdAt
            languages(first: 10) {
              nodes {
                name
              }
              totalCount
            }
          }
          edges {
            cursor
          }
          pageInfo{
            hasNextPage
          }
          totalCount
        }
      }
    }
  GRAPHQL

  CsvQuery = GitHub::Client.parse <<-'GRAPHQL'
    {
      organization(login: "google") {
        repositories(privacy: PUBLIC, first: 100) {
          nodes {
            name
            createdAt
            languages(first: 10) {
              nodes {
                name
              }
              totalCount
            }
          }
        }
    }
  }
  GRAPHQL

  # GET /repositories
  def index
  end

  def all_repos
    respond_to do |format|
      format.html {
        data = query IndexQuery
        render "repositories/all_repos", locals: {
          data: data.organization.repositories,
          total_count: data.organization.repositories.total_count
        }
      }
      format.csv {
        data = query CsvQuery
         send_data generate_csv(data.organization.repositories), filename: "repositories-#{Date.today}"
       }

    end

  end

  CSVQuery = GitHub::Client.parse <<-'GRAPHQL'
    {
      organization(login: "google") {
        repositories(privacy: PUBLIC, first: 10) {
          nodes {
            id
            name
            url
            createdAt
            languages(first: 10) {
              nodes {
                name
              }
              totalCount
            }
          }
          edges {
            cursor
          }
          pageInfo{
            hasNextPage
          }
          totalCount
        }
      }
    }
  GRAPHQL

  # Define query for "Show more repositories..." AJAX action.
  MoreQuery = GitHub::Client.parse <<-'GRAPHQL'
    # This query uses variables to accept an "after" param to load the next
    # 10 repositories.
    query($after: String!) {
        organization(login: "google") {
          repositories(privacy: PUBLIC, first: 10, after: $after) {
            nodes {
              id
              name
              url
            }
            edges {
              cursor
            }
            pageInfo{
              hasNextPage
            }
            totalCount
          }
        }
    }
  GRAPHQL

  # GET /repositories/more?after=CURSOR
  def more
    # Execute the MoreQuery passing along data from params to the query.
    # data = query MoreQuery, after: params[:after]
    data = query MoreQuery, after: params[:after]

    # Using an explicit render again, just render the repositories list partial
    # and return it to the client.
    render partial: "repositories/repositories", locals: {
      repositories: data.organization.repositories
    }
  end


  ShowQuery = GitHub::Client.parse <<-'GRAPHQL'
    # Query is parameterized by a $id variable.
    query($name: String!) {
      organization(login: "google") {
        repository(name: $name) {
          id
          name
          url
          hasIssuesEnabled
          description
          homepageUrl
          languages(first: 10) {
            nodes {
              color
              id
              name
            }
            totalCount
          }
          issues {
             totalCount
           }
           pullRequests {
             totalCount
           }
        }
      }
    }
  GRAPHQL

  # GET /repositories/ID
  def show
    data = query ShowQuery, name: params[:id]
    if repository = data.organization.repository
      render "repositories/show", locals: {
        repository: repository
      }
    else
      # If node can't be found, 404. This may happen if the repository doesn't
      # exist, we don't have permission or we used a global ID that was the
      # wrong type.
      head :not_found
    end
  end


  private

  def generate_csv(repositories)
    attributes = %w(Name Languages Total_Languages Created_at)
    CSV.generate({headers: attributes}) do |csv|
      repositories.nodes.each do |repo|
        csv << [
          repo.name,
          repo.languages.nodes.collect(&:name).join(', '),
          repo.languages.total_count,
          repo.created_at
        ]
      end
    end
  end

end
