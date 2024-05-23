
  openapi = "3.0.0"
  servers = [{
    url = "https://api.twitter.com",
    description = "Twitter API"
  }]
  info {
    description = "Twitter API v2 available endpoints"
    termsOfService = "https://developer.twitter.com/en/developer-terms/agreement-and-policy.html"
    version = "2.98"
    title = "Twitter API v2"
    contact {
      name = "Twitter Developers"
      url = "https://developer.twitter.com/"
    }
    license {
      url = "https://developer.twitter.com/en/developer-terms/agreement-and-policy.html"
      name = "Twitter Developer Agreement and Policy"
    }
  }
  tags "Compliance" {
    description = "Endpoints related to keeping X data in your systems compliant"
    externalDocs {
      url = "https://developer.twitter.com/en/docs/twitter-api/compliance/batch-tweet/introduction"
      description = "Find out more"
    }
  }
  tags "Direct Messages" {
    description = "Endpoints related to retrieving, managing Direct Messages"
    externalDocs {
      url = "https://developer.twitter.com/en/docs/twitter-api/direct-messages"
      description = "Find out more"
    }
  }
  tags "General" {
    description = "Miscellaneous endpoints for general API functionality"
    externalDocs {
      url = "https://developer.twitter.com/en/docs/twitter-api"
      description = "Find out more"
    }
  }
  tags "Lists" {
    description = "Endpoints related to retrieving, managing Lists"
    externalDocs {
      url = "https://developer.twitter.com/en/docs/twitter-api/lists"
      description = "Find out more"
    }
  }
  tags "Spaces" {
    description = "Endpoints related to retrieving, managing Spaces"
    externalDocs {
      url = "https://developer.twitter.com/en/docs/twitter-api/spaces"
      description = "Find out more"
    }
  }
  tags "Tweets" {
    description = "Endpoints related to retrieving, searching, and modifying Tweets"
    externalDocs {
      description = "Find out more"
      url = "https://developer.twitter.com/en/docs/twitter-api/tweets/lookup"
    }
  }
  tags "Users" {
    description = "Endpoints related to retrieving, managing relationships of Users"
    externalDocs {
      url = "https://developer.twitter.com/en/docs/twitter-api/users/lookup"
      description = "Find out more"
    }
  }
  tags "Bookmarks" {
    description = "Endpoints related to retrieving, managing bookmarks of a user"
    externalDocs {
      url = "https://developer.twitter.com/en/docs/twitter-api/bookmarks"
      description = "Find out more"
    }
  }
  paths "/2/dm_conversations/{dm_conversation_id}/messages" "post" {
    summary = "Send a new message to a DM Conversation"
    description = "Creates a new message for a DM Conversation specified by DM Conversation ID"
    operationId = "dmConversationByIdEventIdCreate"
    tags = ["Direct Messages"]
    security = [{
      OAuth2UserToken = ["dm.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "dm_conversation_id" {
      required = true
      in = "path"
      description = "The DM Conversation ID."
      style = "simple"
      schema = string()
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.CreateMessageRequest
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    responses "201" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.CreateDmEventResponse
      }
    }
  }
  paths "/2/users/{id}" "get" {
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "This endpoint returns information about a User. Specify User by ID."
    operationId = "findUserById"
    summary = "User lookup by ID"
    tags = ["Users"]
    parameters "id" {
      required = true
      description = "The ID of the User to lookup."
      style = "simple"
      in = "path"
      example = ""2244994945""
      schema = components.schemas.UserId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/lists/{id}/members" "get" {
    summary = "Returns User objects that are members of a List by the provided List ID."
    description = "Returns a list of Users that are members of a List by the provided List ID."
    operationId = "listGetMembers"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      description = "The ID of the List."
      style = "simple"
      schema = components.schemas.ListId
      required = true
      in = "path"
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationTokenLong
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2ListsIdMembersResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/lists/{id}/members" "post" {
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    operationId = "listAddMember"
    summary = "Add a List member"
    description = "Causes a User to become a member of a List."
    tags = ["Lists"]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the List for which to add a member."
      style = "simple"
      schema = components.schemas.ListId
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.ListAddUserRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListMutateResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/users/search" "get" {
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    operationId = "searchUserByQuery"
    summary = "User search"
    description = "Returns Users that match a search query."
    tags = ["Users"]
    parameters "query" {
      required = true
      in = "query"
      description = "TThe the query string by which to query for users."
      style = "form"
      example = "someXUser"
      schema = components.schemas.UserSearchQuery
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(1000))
    }
    parameters "next_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersSearchResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/bookmarks" "get" {
    tags = ["Bookmarks"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      OAuth2UserToken = ["bookmark.read", "tweet.read", "users.read"]
    }]
    summary = "Bookmarks by User"
    description = "Returns Post objects that have been bookmarked by the requesting User"
    operationId = "getUsersIdBookmarks"
    parameters "id" {
      in = "path"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      description = "The ID of the authenticated source User for whom to return results."
      style = "simple"
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdBookmarksResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/bookmarks" "post" {
    security = [{
      OAuth2UserToken = ["bookmark.write", "tweet.read", "users.read"]
    }]
    summary = "Add Post to Bookmarks"
    description = "Adds a Post (ID in the body) to the requesting User's (in the path) bookmarks"
    operationId = "postUsersIdBookmarks"
    tags = ["Bookmarks"]
    parameters "id" {
      description = "The ID of the authenticated source User for whom to add bookmarks."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
    }
    requestBody {
      required = true
      content "application/json" {
        schema = components.schemas.BookmarkAddRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.BookmarkMutationResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/trends/by/woeid/{woeid}" "get" {
    description = "Returns the Trend associated with the supplied WoeId."
    operationId = "getTrends"
    summary = "Trends"
    tags = ["Trends"]
    parameters = [components.parameters.TrendFieldsParameter]
    security = [{
      BearerToken = []
    }]
    parameters "woeid" {
      style = "simple"
      in = "path"
      description = "The WOEID of the place to lookup a trend for."
      example = ""2244994945""
      schema = integer(format("int32"))
      required = true
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TrendsByWoeidWoeidResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets" "get" {
    summary = "Post lookup by Post IDs"
    description = "Returns a variety of information about the Post specified by the requested ID."
    operationId = "findTweetsById"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "ids" {
      style = "form"
      schema = array([components.schemas.TweetId], maxItems(100), minItems(1))
      required = true
      in = "query"
      description = "A comma separated list of Post IDs. Up to 100 are allowed in a single request."
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsResponse
      }
    }
  }
  paths "/2/tweets" "post" {
    operationId = "createTweet"
    summary = "Creation of a Post"
    description = "Causes the User to create a Post under the authorized account."
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["tweet.read", "tweet.write", "users.read"]
    }, {
      UserToken = []
    }]
    requestBody {
      required = true
      content "application/json" {
        schema = components.schemas.TweetCreateRequest
      }
    }
    responses "201" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.TweetCreateResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/tweets/compliance/stream" "get" {
    description = "Streams 100% of compliance data for Posts"
    operationId = "getTweetsComplianceStream"
    tags = ["Compliance"]
    security = [{
      BearerToken = []
    }]
    summary = "Posts Compliance stream"
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(4))
      required = true
      in = "query"
      description = "The partition number."
    }
    parameters "start_time" {
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Post Compliance events will be provided."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
    }
    parameters "end_time" {
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Post Compliance events will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.TweetComplianceStreamResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/search/stream" "get" {
    description = "Streams Posts matching the stream's active rule set."
    operationId = "searchStream"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Filtered stream"
    parameters "backfill_minutes" {
      style = "form"
      in = "query"
      schema = integer(format("int32"), maximum(5))
      description = "The number of minutes of backfill requested."
    }
    parameters "start_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided."
      style = "form"
      in = "query"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.FilteredStreamingTweetResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/{tweet_id}/hidden" "put" {
    summary = "Hide replies"
    description = "Hides or unhides a reply to an owned conversation."
    operationId = "hideReplyById"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["tweet.moderate.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "tweet_id" {
      required = true
      description = "The ID of the reply that you want to hide or unhide."
      style = "simple"
      in = "path"
      schema = components.schemas.TweetId
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.TweetHideRequest
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.TweetHideResponse
      }
    }
  }
  paths "/2/compliance/jobs/{id}" "get" {
    summary = "Get Compliance Job"
    description = "Returns a single Compliance Job by ID"
    operationId = "getBatchComplianceJob"
    tags = ["Compliance"]
    parameters = [components.parameters.ComplianceJobFieldsParameter]
    security = [{
      BearerToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the Compliance Job to retrieve."
      style = "simple"
      schema = components.schemas.JobId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2ComplianceJobsIdResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/lists" "post" {
    security = [{
      OAuth2UserToken = ["list.read", "list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    operationId = "listIdCreate"
    summary = "Create List"
    description = "Creates a new List."
    tags = ["Lists"]
    requestBody {
      content "application/json" {
        schema = components.schemas.ListCreateRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListCreateResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/spaces/{id}" "get" {
    summary = "Space lookup by Space ID"
    description = "Returns a variety of information about the Space specified by the requested ID"
    tags = ["Spaces"]
    parameters = [components.parameters.SpaceFieldsParameter, components.parameters.SpaceExpansionsParameter, components.parameters.UserFieldsParameter, components.parameters.TopicFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    operationId = "findSpaceById"
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the Space to be retrieved."
      style = "simple"
      example = "1YqKDqWqdPLsV"
      schema = string(description("The unique identifier of this Space."), example("1SLjjRYNejbKM"), pattern("^[a-zA-Z0-9]{1,13}$"))
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesIdResponse
      }
    }
  }
  paths "/2/users/by/username/{username}" "get" {
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "User lookup by username"
    description = "This endpoint returns information about a User. Specify User by username."
    operationId = "findUserByUsername"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    parameters "username" {
      style = "simple"
      example = "TwitterDev"
      schema = string(pattern("^[A-Za-z0-9_]{1,15}$"))
      required = true
      in = "path"
      description = "A username."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersByUsernameUsernameResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/users/{id}/likes/{tweet_id}" "delete" {
    operationId = "usersIdUnlike"
    summary = "Causes the User (in the path) to unlike the specified Post"
    description = "Causes the User (in the path) to unlike the specified Post. The User must match the User context authorizing the request"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["like.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      description = "The ID of the authenticated source User that is requesting to unlike the Post."
      style = "simple"
      in = "path"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "tweet_id" {
      in = "path"
      description = "The ID of the Post that the User is requesting to unlike."
      style = "simple"
      schema = components.schemas.TweetId
      required = true
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersLikesDeleteResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/tweets/firehose/stream/lang/en" "get" {
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "English Language Firehose stream"
    description = "Streams 100% of English Language public Posts."
    operationId = "getTweetsFirehoseStreamLangEn"
    tags = ["Tweets"]
    parameters "backfill_minutes" {
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
      in = "query"
    }
    parameters "partition" {
      schema = integer(format("int32"), minimum(1), maximum(8))
      required = true
      description = "The partition number."
      style = "form"
      in = "query"
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
      in = "query"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingTweetResponse
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/search/stream/rules" "get" {
    tags = ["Tweets"]
    security = [{
      BearerToken = []
    }]
    summary = "Rules lookup"
    description = "Returns rules from a User's active rule set. Users can fetch all of their rules or a subset, specified by the provided rule ids."
    operationId = "getRules"
    parameters "ids" {
      schema = array([components.schemas.RuleId])
      in = "query"
      description = "A comma-separated list of Rule IDs."
      style = "form"
    }
    parameters "max_results" {
      in = "query"
      schema = integer(format("int32"), default(1000), minimum(1), maximum(1000))
      description = "The maximum number of results."
      style = "form"
    }
    parameters "pagination_token" {
      in = "query"
      description = "This value is populated by passing the 'next_token' returned in a request to paginate through results."
      style = "form"
      schema = string(maxLength(16), minLength(16))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.RulesLookupResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/search/stream/rules" "post" {
    summary = "Add/Delete rules"
    description = "Add or delete rules from a User's active rule set. Users can provide unique, optionally tagged rules to add. Users can delete their entire rule set or a subset specified by rule ids or values."
    operationId = "addOrDeleteRules"
    tags = ["Tweets"]
    security = [{
      BearerToken = []
    }]
    parameters "dry_run" {
      in = "query"
      description = "Dry Run can be used with both the add and delete action, with the expected result given, but without actually taking any action in the system (meaning the end state will always be as it was when the request was submitted). This is particularly useful to validate rule changes."
      style = "form"
      schema = boolean()
    }
    parameters "delete_all" {
      in = "query"
      description = "Delete All can be used to delete all of the rules associated this client app, it should be specified with no other parameters. Once deleted, rules cannot be recovered."
      style = "form"
      schema = boolean()
    }
    requestBody {
      required = true
      content "application/json" {
        schema = components.schemas.AddOrDeleteRulesRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.AddOrDeleteRulesResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/{id}/quote_tweets" "get" {
    summary = "Retrieve Posts that quote a Post."
    description = "Returns a variety of information about each Post that quotes the Post specified by the requested ID."
    operationId = "findTweetsThatQuoteATweet"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      schema = components.schemas.TweetId
      required = true
      description = "A single Post ID."
      style = "simple"
      in = "path"
    }
    parameters "max_results" {
      description = "The maximum number of results to be returned."
      style = "form"
      schema = integer(format("int32"), default(10), minimum(10), maximum(100))
      in = "query"
    }
    parameters "pagination_token" {
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      in = "query"
      schema = components.schemas.PaginationToken36
    }
    parameters "exclude" {
      description = "The set of entities to exclude (e.g. 'replies' or 'retweets')."
      style = "form"
      in = "query"
      schema = array([string(enum("replies", "retweets"))], example(["replies", "retweets"]), minItems(1), uniqueItems(true))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsIdQuoteTweetsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/usage/tweets" "get" {
    security = [{
      BearerToken = []
    }]
    summary = "Post Usage"
    description = "Returns the Post Usage."
    operationId = "getUsageTweets"
    tags = ["Usage"]
    parameters = [components.parameters.UsageFieldsParameter]
    parameters "days" {
      style = "form"
      schema = integer(format("int32"), default(7), minimum(1), maximum(90))
      in = "query"
      description = "The number of days for which you need usage for."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsageTweetsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/users/{id}/liked_tweets" "get" {
    summary = "Returns Post objects liked by the provided User ID"
    description = "Returns a list of Posts liked by the provided User ID"
    operationId = "usersIdLikedTweets"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["like.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      style = "simple"
      example = ""2244994945""
      schema = components.schemas.UserId
      required = true
      in = "path"
      description = "The ID of the User to lookup."
    }
    parameters "max_results" {
      style = "form"
      schema = integer(format("int32"), minimum(5), maximum(100))
      in = "query"
      description = "The maximum number of results."
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdLikedTweetsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/compliance/jobs" "get" {
    operationId = "listBatchComplianceJobs"
    tags = ["Compliance"]
    parameters = [components.parameters.ComplianceJobFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "List Compliance Jobs"
    description = "Returns recent Compliance Jobs for a given job type and optional job status"
    parameters "type" {
      required = true
      in = "query"
      description = "Type of Compliance Job to list."
      style = "form"
      schema = string(enum("tweets", "users"))
    }
    parameters "status" {
      description = "Status of Compliance Job to list."
      style = "form"
      schema = string(enum("created", "in_progress", "failed", "complete"))
      in = "query"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2ComplianceJobsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/compliance/jobs" "post" {
    tags = ["Compliance"]
    security = [{
      BearerToken = []
    }]
    summary = "Create compliance job"
    description = "Creates a compliance for the given job type"
    operationId = "createBatchComplianceJob"
    requestBody {
      required = true
      content "application/json" {
        schema = components.schemas.CreateComplianceJobRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.CreateComplianceJobResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/dm_events/{event_id}" "get" {
    operationId = "getDmEventsById"
    tags = ["Direct Messages"]
    parameters = [components.parameters.DmEventFieldsParameter, components.parameters.DmEventExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["dm.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Get DM Events by id"
    description = "Returns DM Events by event id."
    parameters "event_id" {
      required = true
      in = "path"
      description = "dm event id."
      style = "simple"
      schema = components.schemas.DmEventId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2DmEventsEventIdResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/dm_events/{event_id}" "delete" {
    summary = "Delete Dm"
    description = "Delete a Dm Event that you own."
    operationId = "dmEventDelete"
    tags = ["Direct Messages"]
    security = [{
      OAuth2UserToken = ["dm.read", "dm.write"]
    }, {
      UserToken = []
    }]
    parameters "event_id" {
      required = true
      in = "path"
      description = "The ID of the direct-message event to delete."
      style = "simple"
      schema = components.schemas.DmEventId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.DeleteDmResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/spaces/{id}/buyers" "get" {
    summary = "Retrieve the list of Users who purchased a ticket to the given space"
    description = "Retrieves the list of Users who purchased a ticket to the given space"
    operationId = "spaceBuyers"
    tags = ["Spaces", "Tweets"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    parameters "id" {
      in = "path"
      description = "The ID of the Space to be retrieved."
      style = "simple"
      example = "1YqKDqWqdPLsV"
      schema = string(description("The unique identifier of this Space."), example("1SLjjRYNejbKM"), pattern("^[a-zA-Z0-9]{1,13}$"))
      required = true
    }
    parameters "pagination_token" {
      style = "form"
      schema = components.schemas.PaginationToken32
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
    }
    parameters "max_results" {
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      in = "query"
      description = "The maximum number of results."
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesIdBuyersResponse
      }
    }
  }
  paths "/2/users/{id}/blocking" "get" {
    summary = "Returns User objects that are blocked by provided User ID"
    description = "Returns a list of Users that are blocked by the provided User ID"
    operationId = "usersIdBlocking"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["block.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the authenticated source User for whom to return results."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(1000))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken32
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdBlockingResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/users/{id}/bookmarks/{tweet_id}" "delete" {
    security = [{
      OAuth2UserToken = ["bookmark.write", "tweet.read", "users.read"]
    }]
    operationId = "usersIdBookmarksDelete"
    summary = "Remove a bookmarked Post"
    description = "Removes a Post from the requesting User's bookmarked Posts."
    tags = ["Bookmarks"]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the authenticated source User whose bookmark is to be removed."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "tweet_id" {
      required = true
      in = "path"
      description = "The ID of the Post that the source User is removing from bookmarks."
      style = "simple"
      schema = components.schemas.TweetId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.BookmarkMutationResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/pinned_lists/{list_id}" "delete" {
    summary = "Unpin a List"
    description = "Causes a User to remove a pinned List."
    operationId = "listUserUnpin"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User for whom to return results."
      style = "simple"
    }
    parameters "list_id" {
      required = true
      in = "path"
      description = "The ID of the List to unpin."
      style = "simple"
      schema = components.schemas.ListId
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListUnpinResponse
      }
    }
  }
  paths "/2/dm_conversations/{id}/dm_events" "get" {
    summary = "Get DM Events for a DM Conversation"
    description = "Returns DM Events for a DM Conversation"
    operationId = "getDmConversationsIdDmEvents"
    tags = ["Direct Messages"]
    parameters = [components.parameters.DmEventFieldsParameter, components.parameters.DmEventExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["dm.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      description = "The DM Conversation ID."
      style = "simple"
      schema = components.schemas.DmConversationId
      required = true
      in = "path"
    }
    parameters "max_results" {
      in = "query"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      description = "The maximum number of results."
      style = "form"
    }
    parameters "pagination_token" {
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken32
      in = "query"
    }
    parameters "event_types" {
      style = "form"
      in = "query"
      description = "The set of event_types to include in the results."
      schema = array([string(enum("MessageCreate", "ParticipantsJoin", "ParticipantsLeave"))], example(["MessageCreate", "ParticipantsLeave"]), minItems(1), uniqueItems(true))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2DmConversationsIdDmEventsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/label/stream" "get" {
    security = [{
      BearerToken = []
    }]
    summary = "Posts Label stream"
    description = "Streams 100% of labeling events applied to Posts"
    operationId = "getTweetsLabelStream"
    tags = ["Compliance"]
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "start_time" {
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Post labels will be provided."
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp from which the Post labels will be provided."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.TweetLabelStreamResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/{id}" "delete" {
    summary = "Post delete by Post ID"
    description = "Delete specified Post (in the path) by ID."
    operationId = "deleteTweetById"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["tweet.read", "tweet.write", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the Post to be deleted."
      style = "simple"
      schema = components.schemas.TweetId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.TweetDeleteResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/{id}" "get" {
    description = "Returns a variety of information about the Post specified by the requested ID."
    operationId = "findTweetById"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Post lookup by Post ID"
    parameters "id" {
      style = "simple"
      schema = components.schemas.TweetId
      required = true
      in = "path"
      description = "A single Post ID."
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsIdResponse
      }
    }
  }
  paths "/2/users/by" "get" {
    description = "This endpoint returns information about Users. Specify Users by their username."
    operationId = "findUsersByUsername"
    summary = "User lookup by usernames"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "usernames" {
      required = true
      in = "query"
      description = "A list of usernames, comma-separated."
      style = "form"
      schema = array([string(description("The X handle (screen name) of this User."), pattern("^[A-Za-z0-9_]{1,15}$"))], example("TwitterDev,TwitterAPI
"), maxItems(100), minItems(1))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersByResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/me" "get" {
    security = [{
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "This endpoint returns information about the requesting User."
    operationId = "findMyUser"
    summary = "User lookup me"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersMeResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/list_memberships" "get" {
    summary = "Get a User's List Memberships"
    description = "Get a User's List Memberships."
    operationId = "getUserListMemberships"
    tags = ["Lists"]
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
      schema = components.schemas.UserId
      required = true
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      style = "form"
      schema = components.schemas.PaginationTokenLong
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdListMembershipsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/dm_conversations" "post" {
    summary = "Create a new DM Conversation"
    description = "Creates a new DM Conversation."
    operationId = "dmConversationIdCreate"
    tags = ["Direct Messages"]
    security = [{
      OAuth2UserToken = ["dm.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    requestBody {
      content "application/json" {
        schema = components.schemas.CreateDmConversationRequest
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "201" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.CreateDmEventResponse
      }
    }
  }
  paths "/2/lists/{id}" "get" {
    summary = "List lookup by List ID."
    description = "Returns a List."
    operationId = "listIdGet"
    tags = ["Lists"]
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      in = "path"
      description = "The ID of the List."
      style = "simple"
      schema = components.schemas.ListId
      required = true
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2ListsIdResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/lists/{id}" "put" {
    summary = "Update List."
    description = "Update a List that you own."
    operationId = "listIdUpdate"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      schema = components.schemas.ListId
      required = true
      in = "path"
      description = "The ID of the List to modify."
      style = "simple"
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.ListUpdateRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListUpdateResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/lists/{id}" "delete" {
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Delete List"
    description = "Delete a List that you own."
    operationId = "listIdDelete"
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the List to delete."
      style = "simple"
      schema = components.schemas.ListId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListDeleteResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/{id}/retweeted_by" "get" {
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Returns User objects that have retweeted the provided Post ID"
    description = "Returns a list of Users that have retweeted the provided Post ID"
    operationId = "tweetsIdRetweetingUsers"
    parameters "id" {
      required = true
      in = "path"
      description = "A single Post ID."
      style = "simple"
      schema = components.schemas.TweetId
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      style = "form"
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsIdRetweetedByResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/spaces/search" "get" {
    tags = ["Spaces"]
    parameters = [components.parameters.SpaceFieldsParameter, components.parameters.SpaceExpansionsParameter, components.parameters.UserFieldsParameter, components.parameters.TopicFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    summary = "Search for Spaces"
    description = "Returns Spaces that match the provided query."
    operationId = "searchSpaces"
    parameters "query" {
      schema = string(example("crypto"), maxLength(2048), minLength(1))
      required = true
      in = "query"
      description = "The search query."
      style = "form"
      example = "crypto"
    }
    parameters "state" {
      schema = string(default("all"), enum("live", "scheduled", "all"))
      style = "form"
      in = "query"
      description = "The state of Spaces to search for."
    }
    parameters "max_results" {
      in = "query"
      description = "The number of results to return."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesSearchResponse
      }
    }
  }
  paths "/2/users/{id}/following" "get" {
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["follows.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Following by User ID"
    description = "Returns a list of Users that are being followed by the provided User ID"
    operationId = "usersIdFollowing"
    tags = ["Users"]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
      schema = components.schemas.UserId
    }
    parameters "max_results" {
      style = "form"
      in = "query"
      description = "The maximum number of results."
      schema = integer(format("int32"), minimum(1), maximum(1000))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken32
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdFollowingResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/following" "post" {
    summary = "Follow User"
    description = "Causes the User(in the path) to follow, or “request to follow” for protected Users, the target User. The User(in the path) must match the User context authorizing the request"
    operationId = "usersIdFollow"
    tags = ["Users"]
    security = [{
      OAuth2UserToken = ["follows.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to follow the target User."
      style = "simple"
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.UsersFollowingCreateRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersFollowingCreateResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/mentions" "get" {
    description = "Returns Post objects that mention username associated to the provided User ID"
    operationId = "usersIdMentions"
    summary = "User mention timeline by User ID"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
      schema = components.schemas.UserId
      required = true
      in = "path"
    }
    parameters "since_id" {
      schema = components.schemas.TweetId
      in = "query"
      description = "The minimum Post ID to be included in the result set. This parameter takes precedence over start_time if both are specified."
      style = "form"
    }
    parameters "until_id" {
      example = ""1346889436626259968""
      schema = components.schemas.TweetId
      in = "query"
      description = "The maximum Post ID to be included in the result set. This parameter takes precedence over end_time if both are specified."
      style = "form"
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), minimum(5), maximum(100))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "start_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided. The since_id parameter takes precedence if it is also specified."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
    }
    parameters "end_time" {
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided. The until_id parameter takes precedence if it is also specified."
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdMentionsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/retweets/{source_tweet_id}" "delete" {
    security = [{
      OAuth2UserToken = ["tweet.read", "tweet.write", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Causes the User (in the path) to unretweet the specified Post"
    description = "Causes the User (in the path) to unretweet the specified Post. The User must match the User context authorizing the request"
    operationId = "usersIdUnretweets"
    tags = ["Tweets"]
    parameters "id" {
      in = "path"
      description = "The ID of the authenticated source User that is requesting to repost the Post."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
    }
    parameters "source_tweet_id" {
      required = true
      in = "path"
      description = "The ID of the Post that the User is requesting to unretweet."
      style = "simple"
      schema = components.schemas.TweetId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersRetweetsDeleteResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/lists/{id}/followers" "get" {
    description = "Returns a list of Users that follow a List by the provided List ID"
    operationId = "listGetFollowers"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Returns User objects that follow a List by the provided List ID"
    parameters "id" {
      style = "simple"
      schema = components.schemas.ListId
      required = true
      in = "path"
      description = "The ID of the List."
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationTokenLong
      in = "query"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2ListsIdFollowersResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/lists/{id}/tweets" "get" {
    summary = "List Posts timeline by List ID."
    description = "Returns a list of Posts associated with the provided List ID."
    operationId = "listsIdTweets"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the List."
      style = "simple"
      schema = components.schemas.ListId
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2ListsIdTweetsResponse
      }
    }
  }
  paths "/2/spaces/by/creator_ids" "get" {
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    summary = "Space lookup by their creators"
    description = "Returns a variety of information about the Spaces created by the provided User IDs"
    operationId = "findSpacesByCreatorIds"
    tags = ["Spaces"]
    parameters = [components.parameters.SpaceFieldsParameter, components.parameters.SpaceExpansionsParameter, components.parameters.UserFieldsParameter, components.parameters.TopicFieldsParameter]
    parameters "user_ids" {
      style = "form"
      schema = array([components.schemas.UserId], maxItems(100), minItems(1))
      required = true
      in = "query"
      description = "The IDs of Users to search through."
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesByCreatorIdsResponse
      }
    }
  }
  paths "/2/tweets/search/stream/rules/counts" "get" {
    tags = ["General"]
    parameters = [components.parameters.RulesCountFieldsParameter]
    security = [{
      BearerToken = []
    }]
    description = "Returns the counts of rules from a User's active rule set, to reflect usage by project and application."
    operationId = "getRuleCount"
    summary = "Rules Count"
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsSearchStreamRulesCountsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/tweets" "get" {
    operationId = "usersIdTweets"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "User Posts timeline by User ID"
    description = "Returns a list of Posts authored by the provided User ID"
    parameters "id" {
      required = true
      style = "simple"
      in = "path"
      description = "The ID of the User to lookup."
      example = ""2244994945""
      schema = components.schemas.UserId
    }
    parameters "since_id" {
      example = ""791775337160081409""
      schema = components.schemas.TweetId
      in = "query"
      description = "The minimum Post ID to be included in the result set. This parameter takes precedence over start_time if both are specified."
      style = "form"
    }
    parameters "until_id" {
      in = "query"
      description = "The maximum Post ID to be included in the result set. This parameter takes precedence over end_time if both are specified."
      style = "form"
      example = ""1346889436626259968""
      schema = components.schemas.TweetId
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), minimum(5), maximum(100))
    }
    parameters "pagination_token" {
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      in = "query"
      schema = components.schemas.PaginationToken36
    }
    parameters "exclude" {
      description = "The set of entities to exclude (e.g. 'replies' or 'retweets')."
      style = "form"
      in = "query"
      schema = array([string(enum("replies", "retweets"))], example(["replies", "retweets"]), minItems(1), uniqueItems(true))
    }
    parameters "start_time" {
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided. The since_id parameter takes precedence if it is also specified."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
    }
    parameters "end_time" {
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided. The until_id parameter takes precedence if it is also specified."
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdTweetsResponse
      }
    }
  }
  paths "/2/tweets/counts/all" "get" {
    tags = ["Tweets"]
    parameters = [components.parameters.SearchCountFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Full archive search counts"
    description = "Returns Post Counts that match a search query."
    operationId = "tweetCountsFullArchiveSearch"
    parameters "query" {
      required = true
      in = "query"
      description = "One query/rule/filter for matching Posts. Refer to https://t.co/rulelength to identify the max query length."
      style = "form"
      schema = string(example("(from:TwitterDev OR from:TwitterAPI) has:media -is:retweet"), maxLength(4096), minLength(1))
    }
    parameters "start_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The oldest UTC timestamp (from most recent 7 days) from which the Posts will be provided. Timestamp is in second granularity and is inclusive (i.e. 12:00:01 includes the first second of the minute)."
      style = "form"
      schema = string(format("date-time"))
      in = "query"
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The newest, most recent UTC timestamp to which the Posts will be provided. Timestamp is in second granularity and is exclusive (i.e. 12:00:01 excludes the first second of the minute)."
      schema = string(format("date-time"))
      style = "form"
    }
    parameters "since_id" {
      style = "form"
      in = "query"
      description = "Returns results with a Post ID greater than (that is, more recent than) the specified ID."
      schema = components.schemas.TweetId
    }
    parameters "until_id" {
      in = "query"
      description = "Returns results with a Post ID less than (that is, older than) the specified ID."
      style = "form"
      schema = components.schemas.TweetId
    }
    parameters "next_token" {
      schema = components.schemas.PaginationToken36
      style = "form"
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
    }
    parameters "pagination_token" {
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
      in = "query"
    }
    parameters "granularity" {
      in = "query"
      description = "The granularity for the search counts results."
      style = "form"
      schema = string(default("hour"), enum("minute", "hour", "day"))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsCountsAllResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/tweets/firehose/stream/lang/ko" "get" {
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Korean Language Firehose stream"
    description = "Streams 100% of Korean Language public Posts."
    operationId = "getTweetsFirehoseStreamLangKo"
    parameters "backfill_minutes" {
      style = "form"
      schema = integer(format("int32"), maximum(5))
      in = "query"
      description = "The number of minutes of backfill requested."
    }
    parameters "partition" {
      required = true
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(2))
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingTweetResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/sample/stream" "get" {
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Sample stream"
    description = "Streams a deterministic 1% of public Posts."
    operationId = "sampleStream"
    tags = ["Tweets"]
    parameters "backfill_minutes" {
      schema = integer(format("int32"), maximum(5))
      description = "The number of minutes of backfill requested."
      style = "form"
      in = "query"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingTweetResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/{id}/liking_users" "get" {
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["like.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Returns User objects that have liked the provided Post ID"
    description = "Returns a list of Users that have liked the provided Post ID"
    operationId = "tweetsIdLikingUsers"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    parameters "id" {
      schema = components.schemas.TweetId
      required = true
      in = "path"
      description = "A single Post ID."
      style = "simple"
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      style = "form"
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsIdLikingUsersResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/owned_lists" "get" {
    summary = "Get a User's Owned Lists."
    description = "Get a User's Owned Lists."
    operationId = "listUserOwnedLists"
    tags = ["Lists"]
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
      schema = components.schemas.UserId
    }
    parameters "max_results" {
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      in = "query"
      description = "The maximum number of results."
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationTokenLong
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdOwnedListsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/retweets" "post" {
    summary = "Causes the User (in the path) to repost the specified Post."
    description = "Causes the User (in the path) to repost the specified Post. The User in the path must match the User context authorizing the request."
    operationId = "usersIdRetweets"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["tweet.read", "tweet.write", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to repost the Post."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.UsersRetweetsCreateRequest
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersRetweetsCreateResponse
      }
    }
  }
  paths "/2/dm_conversations/with/{participant_id}/dm_events" "get" {
    security = [{
      OAuth2UserToken = ["dm.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Get DM Events for a DM Conversation"
    description = "Returns DM Events for a DM Conversation"
    operationId = "getDmConversationsWithParticipantIdDmEvents"
    tags = ["Direct Messages"]
    parameters = [components.parameters.DmEventFieldsParameter, components.parameters.DmEventExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.TweetFieldsParameter]
    parameters "participant_id" {
      schema = components.schemas.UserId
      required = true
      description = "The ID of the participant user for the One to One DM conversation."
      style = "simple"
      in = "path"
    }
    parameters "max_results" {
      style = "form"
      in = "query"
      description = "The maximum number of results."
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      style = "form"
      schema = components.schemas.PaginationToken32
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
    }
    parameters "event_types" {
      schema = array([string(enum("MessageCreate", "ParticipantsJoin", "ParticipantsLeave"))], example(["MessageCreate", "ParticipantsLeave"]), minItems(1), uniqueItems(true))
      style = "form"
      in = "query"
      description = "The set of event_types to include in the results."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2DmConversationsWithParticipantIdDmEventsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/firehose/stream/lang/pt" "get" {
    security = [{
      BearerToken = []
    }]
    summary = "Portuguese Language Firehose stream"
    description = "Streams 100% of Portuguese Language public Posts."
    operationId = "getTweetsFirehoseStreamLangPt"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    parameters "backfill_minutes" {
      style = "form"
      in = "query"
      description = "The number of minutes of backfill requested."
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(2))
      required = true
      in = "query"
    }
    parameters "start_time" {
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
    }
    parameters "end_time" {
      in = "query"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingTweetResponse
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/sample10/stream" "get" {
    security = [{
      BearerToken = []
    }]
    operationId = "getTweetsSample10Stream"
    summary = "Sample 10% stream"
    description = "Streams a deterministic 10% of public Posts."
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    parameters "backfill_minutes" {
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
      in = "query"
    }
    parameters "partition" {
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(2))
      required = true
      in = "query"
      description = "The partition number."
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      in = "query"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsSample10StreamResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/users" "get" {
    operationId = "findUsersById"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "User lookup by IDs"
    description = "This endpoint returns information about Users. Specify Users by their ID."
    parameters "ids" {
      required = true
      in = "query"
      description = "A list of User IDs, comma-separated. You can specify up to 100 IDs."
      style = "form"
      example = "2244994945,6253282,12"
      schema = array([components.schemas.UserId], maxItems(100), minItems(1))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/muting" "get" {
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["mute.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Returns User objects that are muted by the provided User ID"
    description = "Returns a list of Users that are muted by the provided User ID"
    operationId = "usersIdMuting"
    tags = ["Users"]
    parameters "id" {
      description = "The ID of the authenticated source User for whom to return results."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
    }
    parameters "max_results" {
      schema = integer(format("int32"), default(100), minimum(1), maximum(1000))
      in = "query"
      description = "The maximum number of results."
      style = "form"
    }
    parameters "pagination_token" {
      style = "form"
      schema = components.schemas.PaginationTokenLong
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdMutingResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/muting" "post" {
    description = "Causes the User (in the path) to mute the target User. The User (in the path) must match the User context authorizing the request."
    operationId = "usersIdMute"
    tags = ["Users"]
    security = [{
      OAuth2UserToken = ["mute.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Mute User by User ID."
    parameters "id" {
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to mute the target User."
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.MuteUserRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.MuteUserMutationResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/dm_conversations/with/{participant_id}/messages" "post" {
    description = "Creates a new message for a DM Conversation with a participant user by ID"
    operationId = "dmConversationWithUserEventIdCreate"
    tags = ["Direct Messages"]
    security = [{
      OAuth2UserToken = ["dm.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Send a new message to a user"
    parameters "participant_id" {
      required = true
      in = "path"
      description = "The ID of the recipient user that will receive the DM."
      style = "simple"
      schema = components.schemas.UserId
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.CreateMessageRequest
      }
    }
    responses "201" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.CreateDmEventResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/counts/recent" "get" {
    tags = ["Tweets"]
    parameters = [components.parameters.SearchCountFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Recent search counts"
    description = "Returns Post Counts from the last 7 days that match a search query."
    operationId = "tweetCountsRecentSearch"
    parameters "query" {
      description = "One query/rule/filter for matching Posts. Refer to https://t.co/rulelength to identify the max query length."
      style = "form"
      in = "query"
      schema = string(example("(from:TwitterDev OR from:TwitterAPI) has:media -is:retweet"), maxLength(4096), minLength(1))
      required = true
    }
    parameters "start_time" {
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The oldest UTC timestamp (from most recent 7 days) from which the Posts will be provided. Timestamp is in second granularity and is inclusive (i.e. 12:00:01 includes the first second of the minute)."
      style = "form"
    }
    parameters "end_time" {
      schema = string(format("date-time"))
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The newest, most recent UTC timestamp to which the Posts will be provided. Timestamp is in second granularity and is exclusive (i.e. 12:00:01 excludes the first second of the minute)."
    }
    parameters "since_id" {
      style = "form"
      schema = components.schemas.TweetId
      in = "query"
      description = "Returns results with a Post ID greater than (that is, more recent than) the specified ID."
    }
    parameters "until_id" {
      in = "query"
      description = "Returns results with a Post ID less than (that is, older than) the specified ID."
      style = "form"
      schema = components.schemas.TweetId
    }
    parameters "next_token" {
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "granularity" {
      description = "The granularity for the search counts results."
      style = "form"
      in = "query"
      schema = string(default("hour"), enum("minute", "hour", "day"))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsCountsRecentResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/{id}/retweets" "get" {
    summary = "Retrieve Posts that repost a Post."
    description = "Returns a variety of information about each Post that has retweeted the Post specified by the requested ID."
    operationId = "findTweetsThatRetweetATweet"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "A single Post ID."
      style = "simple"
      schema = components.schemas.TweetId
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsIdRetweetsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/search/all" "get" {
    summary = "Full-archive search"
    description = "Returns Posts that match a search query."
    operationId = "tweetsFullarchiveSearch"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    parameters "query" {
      in = "query"
      description = "One query/rule/filter for matching Posts. Refer to https://t.co/rulelength to identify the max query length."
      style = "form"
      schema = string(example("(from:TwitterDev OR from:TwitterAPI) has:media -is:retweet"), maxLength(4096), minLength(1))
      required = true
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The oldest UTC timestamp from which the Posts will be provided. Timestamp is in second granularity and is inclusive (i.e. 12:00:01 includes the first second of the minute)."
      style = "form"
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The newest, most recent UTC timestamp to which the Posts will be provided. Timestamp is in second granularity and is exclusive (i.e. 12:00:01 excludes the first second of the minute)."
      style = "form"
      schema = string(format("date-time"))
    }
    parameters "since_id" {
      in = "query"
      description = "Returns results with a Post ID greater than (that is, more recent than) the specified ID."
      style = "form"
      schema = components.schemas.TweetId
    }
    parameters "until_id" {
      in = "query"
      description = "Returns results with a Post ID less than (that is, older than) the specified ID."
      style = "form"
      schema = components.schemas.TweetId
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of search results to be returned by a request."
      style = "form"
      schema = integer(format("int32"), default(10), minimum(10), maximum(500))
    }
    parameters "next_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "sort_order" {
      style = "form"
      in = "query"
      description = "This order in which to return results."
      schema = string(enum("recency", "relevancy"))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsSearchAllResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/timelines/reverse_chronological" "get" {
    summary = "User home timeline by User ID"
    description = "Returns Post objects that appears in the provided User ID's home timeline"
    operationId = "usersIdTimeline"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      description = "The ID of the authenticated source User to list Reverse Chronological Timeline Posts of."
      style = "simple"
      in = "path"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "since_id" {
      in = "query"
      description = "The minimum Post ID to be included in the result set. This parameter takes precedence over start_time if both are specified."
      style = "form"
      example = ""791775337160081409""
      schema = components.schemas.TweetId
    }
    parameters "until_id" {
      style = "form"
      example = ""1346889436626259968""
      schema = components.schemas.TweetId
      in = "query"
      description = "The maximum Post ID to be included in the result set. This parameter takes precedence over end_time if both are specified."
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "exclude" {
      schema = array([string(enum("replies", "retweets"))], example(["replies", "retweets"]), uniqueItems(true))
      in = "query"
      description = "The set of entities to exclude (e.g. 'replies' or 'retweets')."
      style = "form"
    }
    parameters "start_time" {
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided. The since_id parameter takes precedence if it is also specified."
      style = "form"
    }
    parameters "end_time" {
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided. The until_id parameter takes precedence if it is also specified."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdTimelinesReverseChronologicalResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/lists/{id}/members/{user_id}" "delete" {
    summary = "Remove a List member"
    description = "Causes a User to be removed from the members of a List."
    operationId = "listRemoveMember"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      style = "simple"
      in = "path"
      description = "The ID of the List to remove a member."
      schema = components.schemas.ListId
    }
    parameters "user_id" {
      schema = components.schemas.UserId
      required = true
      description = "The ID of User that will be removed from the List."
      style = "simple"
      in = "path"
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListMutateResponse
      }
    }
  }
  paths "/2/users/{id}/followers" "get" {
    description = "Returns a list of Users who are followers of the specified User ID."
    operationId = "usersIdFollowers"
    summary = "Followers by User ID"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["follows.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      schema = components.schemas.UserId
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(1000))
    }
    parameters "pagination_token" {
      style = "form"
      schema = components.schemas.PaginationToken32
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdFollowersResponse
      }
    }
  }
  paths "/2/users/{id}/followed_lists" "get" {
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Get User's Followed Lists"
    description = "Returns a User's followed Lists."
    operationId = "userFollowedLists"
    tags = ["Lists"]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
      schema = components.schemas.UserId
    }
    parameters "max_results" {
      description = "The maximum number of results."
      style = "form"
      in = "query"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      schema = components.schemas.PaginationTokenLong
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      in = "query"
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdFollowedListsResponse
      }
    }
  }
  paths "/2/users/{id}/followed_lists" "post" {
    summary = "Follow a List"
    description = "Causes a User to follow a List."
    operationId = "listUserFollow"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      in = "path"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      description = "The ID of the authenticated source User that will follow the List."
      style = "simple"
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.ListFollowedRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListFollowedResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/pinned_lists" "get" {
    summary = "Get a User's Pinned Lists"
    description = "Get a User's Pinned Lists."
    operationId = "listUserPinnedLists"
    tags = ["Lists"]
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      style = "simple"
      in = "path"
      description = "The ID of the authenticated source User for whom to return results."
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdPinnedListsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/pinned_lists" "post" {
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Pin a List"
    description = "Causes a User to pin a List."
    operationId = "listUserPin"
    tags = ["Lists"]
    parameters "id" {
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User that will pin the List."
    }
    requestBody {
      required = true
      content "application/json" {
        schema = components.schemas.ListPinnedRequest
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListPinnedResponse
      }
    }
  }
  paths "/2/users/{source_user_id}/following/{target_user_id}" "delete" {
    tags = ["Users"]
    security = [{
      OAuth2UserToken = ["follows.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Unfollow User"
    description = "Causes the source User to unfollow the target User. The source User must match the User context authorizing the request"
    operationId = "usersIdUnfollow"
    parameters "source_user_id" {
      in = "path"
      description = "The ID of the authenticated source User that is requesting to unfollow the target User."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
    }
    parameters "target_user_id" {
      required = true
      description = "The ID of the User that the source User is requesting to unfollow."
      style = "simple"
      in = "path"
      schema = components.schemas.UserId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersFollowingDeleteResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/likes/compliance/stream" "get" {
    summary = "Likes Compliance stream"
    description = "Streams 100% of compliance data for Users"
    operationId = "getLikesComplianceStream"
    tags = ["Compliance"]
    security = [{
      BearerToken = []
    }]
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "start_time" {
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Likes Compliance events will be provided."
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp from which the Likes Compliance events will be provided."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.LikesComplianceStreamResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/openapi.json" "get" {
    operationId = "getOpenApiSpec"
    tags = ["General"]
    summary = "Returns the OpenAPI Specification document."
    description = "Full OpenAPI Specification in JSON format. (See https://github.com/OAI/OpenAPI-Specification/blob/master/README.md)"
    responses "200" {
      description = "The request was successful"
      content "application/json" {
        schema = object()
      }
    }
  }
  paths "/2/tweets/search/recent" "get" {
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    operationId = "tweetsRecentSearch"
    summary = "Recent search"
    description = "Returns Posts from the last 7 days that match a search query."
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    parameters "query" {
      in = "query"
      description = "One query/rule/filter for matching Posts. Refer to https://t.co/rulelength to identify the max query length."
      style = "form"
      schema = string(example("(from:TwitterDev OR from:TwitterAPI) has:media -is:retweet"), maxLength(4096), minLength(1))
      required = true
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The oldest UTC timestamp from which the Posts will be provided. Timestamp is in second granularity and is inclusive (i.e. 12:00:01 includes the first second of the minute)."
      style = "form"
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The newest, most recent UTC timestamp to which the Posts will be provided. Timestamp is in second granularity and is exclusive (i.e. 12:00:01 excludes the first second of the minute)."
      style = "form"
      in = "query"
      schema = string(format("date-time"))
    }
    parameters "since_id" {
      in = "query"
      description = "Returns results with a Post ID greater than (that is, more recent than) the specified ID."
      style = "form"
      schema = components.schemas.TweetId
    }
    parameters "until_id" {
      in = "query"
      description = "Returns results with a Post ID less than (that is, older than) the specified ID."
      style = "form"
      schema = components.schemas.TweetId
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of search results to be returned by a request."
      style = "form"
      schema = integer(format("int32"), default(10), minimum(10), maximum(100))
    }
    parameters "next_token" {
      style = "form"
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      schema = components.schemas.PaginationToken36
    }
    parameters "pagination_token" {
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
      in = "query"
    }
    parameters "sort_order" {
      style = "form"
      schema = string(enum("recency", "relevancy"))
      in = "query"
      description = "This order in which to return results."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsSearchRecentResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/likes" "post" {
    security = [{
      OAuth2UserToken = ["like.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    operationId = "usersIdLike"
    summary = "Causes the User (in the path) to like the specified Post"
    description = "Causes the User (in the path) to like the specified Post. The User in the path must match the User context authorizing the request."
    tags = ["Tweets"]
    parameters "id" {
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to like the Post."
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.UsersLikesCreateRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersLikesCreateResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/dm_events" "get" {
    operationId = "getDmEvents"
    summary = "Get recent DM Events"
    description = "Returns recent DM Events across DM conversations"
    tags = ["Direct Messages"]
    parameters = [components.parameters.DmEventFieldsParameter, components.parameters.DmEventExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["dm.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken32
      in = "query"
    }
    parameters "event_types" {
      description = "The set of event_types to include in the results."
      style = "form"
      in = "query"
      schema = array([string(enum("MessageCreate", "ParticipantsJoin", "ParticipantsLeave"))], example(["MessageCreate", "ParticipantsLeave"]), minItems(1), uniqueItems(true))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2DmEventsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/likes/firehose/stream" "get" {
    tags = ["Likes"]
    parameters = [components.parameters.LikeFieldsParameter, components.parameters.LikeExpansionsParameter, components.parameters.TweetFieldsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Likes Firehose stream"
    description = "Streams 100% of public Likes."
    operationId = "likesFirehoseStream"
    parameters "backfill_minutes" {
      style = "form"
      in = "query"
      description = "The number of minutes of backfill requested."
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(20))
      required = true
    }
    parameters "start_time" {
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Likes will be provided."
      style = "form"
    }
    parameters "end_time" {
      in = "query"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingLikeResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/firehose/stream" "get" {
    summary = "Firehose stream"
    description = "Streams 100% of public Posts."
    operationId = "getTweetsFirehoseStream"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    parameters "backfill_minutes" {
      schema = integer(format("int32"), maximum(5))
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
    }
    parameters "partition" {
      required = true
      style = "form"
      in = "query"
      description = "The partition number."
      schema = integer(format("int32"), minimum(1), maximum(20))
    }
    parameters "start_time" {
      schema = string(format("date-time"))
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      example = ""2021-02-14T18:40:40.000Z""
    }
    parameters "end_time" {
      schema = string(format("date-time"))
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      example = ""2021-02-14T18:40:40.000Z""
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingTweetResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/users/compliance/stream" "get" {
    tags = ["Compliance"]
    security = [{
      BearerToken = []
    }]
    summary = "Users Compliance stream"
    description = "Streams 100% of compliance data for Users"
    operationId = "getUsersComplianceStream"
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      schema = integer(format("int32"), maximum(5))
      style = "form"
    }
    parameters "partition" {
      required = true
      description = "The partition number."
      style = "form"
      in = "query"
      schema = integer(format("int32"), minimum(1), maximum(4))
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the User Compliance events will be provided."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp from which the User Compliance events will be provided."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UserComplianceStreamResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/users/{source_user_id}/muting/{target_user_id}" "delete" {
    tags = ["Users"]
    security = [{
      OAuth2UserToken = ["mute.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Unmute User by User ID"
    description = "Causes the source User to unmute the target User. The source User must match the User context authorizing the request"
    operationId = "usersIdUnmute"
    parameters "source_user_id" {
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to unmute the target User."
    }
    parameters "target_user_id" {
      required = true
      in = "path"
      description = "The ID of the User that the source User is requesting to unmute."
      style = "simple"
      schema = components.schemas.UserId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.MuteUserMutationResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/spaces" "get" {
    parameters = [components.parameters.SpaceFieldsParameter, components.parameters.SpaceExpansionsParameter, components.parameters.UserFieldsParameter, components.parameters.TopicFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    description = "Returns a variety of information about the Spaces specified by the requested IDs"
    operationId = "findSpacesByIds"
    summary = "Space lookup up Space IDs"
    tags = ["Spaces"]
    parameters "ids" {
      in = "query"
      description = "The list of Space IDs to return."
      style = "form"
      schema = array([string(description("The unique identifier of this Space."), example("1SLjjRYNejbKM"), pattern("^[a-zA-Z0-9]{1,13}$"))], maxItems(100), minItems(1))
      required = true
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/spaces/{id}/tweets" "get" {
    summary = "Retrieve Posts from a Space."
    description = "Retrieves Posts shared in the specified Space."
    operationId = "spaceTweets"
    tags = ["Spaces", "Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the Space to be retrieved."
      style = "simple"
      example = "1YqKDqWqdPLsV"
      schema = string(description("The unique identifier of this Space."), example("1SLjjRYNejbKM"), pattern("^[a-zA-Z0-9]{1,13}$"))
    }
    parameters "max_results" {
      schema = integer(format("int32"), default(100), example(25), minimum(1), maximum(100))
      style = "form"
      in = "query"
      description = "The number of Posts to fetch from the provided space. If not provided, the value will default to the maximum of 100."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesIdTweetsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/firehose/stream/lang/ja" "get" {
    description = "Streams 100% of Japanese Language public Posts."
    operationId = "getTweetsFirehoseStreamLangJa"
    summary = "Japanese Language Firehose stream"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      required = true
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(2))
    }
    parameters "start_time" {
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
    }
    parameters "end_time" {
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingTweetResponse
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/likes/sample10/stream" "get" {
    security = [{
      BearerToken = []
    }]
    summary = "Likes Sample 10 stream"
    description = "Streams 10% of public Likes."
    operationId = "likesSample10Stream"
    tags = ["Likes"]
    parameters = [components.parameters.LikeFieldsParameter, components.parameters.LikeExpansionsParameter, components.parameters.TweetFieldsParameter, components.parameters.UserFieldsParameter]
    parameters "backfill_minutes" {
      style = "form"
      in = "query"
      description = "The number of minutes of backfill requested."
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      required = true
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(2))
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Likes will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      schema = string(format("date-time"))
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      example = ""2021-02-14T18:40:40.000Z""
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingLikeResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/users/{id}/followed_lists/{list_id}" "delete" {
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Unfollow a List"
    description = "Causes a User to unfollow a List."
    operationId = "listUserUnfollow"
    tags = ["Lists"]
    parameters "id" {
      description = "The ID of the authenticated source User that will unfollow the List."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
    }
    parameters "list_id" {
      required = true
      in = "path"
      description = "The ID of the List to unfollow."
      style = "simple"
      schema = components.schemas.ListId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListFollowedResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  components "schemas" "Topic" {
    type = "object"
    description = "The topic of a Space, as selected by its creator."
    required = ["id", "name"]
    properties {
      name = string(description("The name of the given topic."), example("Technology"))
      description = string(description("The description of the given topic."), example("All about technology"))
      id = components.schemas.TopicId
    }
  }
  components "schemas" "TweetWithheld" {
    type = "object"
    description = "Indicates withholding details for [withheld content](https://help.twitter.com/en/rules-and-policies/tweet-withheld-by-country)."
    required = ["copyright", "country_codes"]
    properties {
      scope = string(description("Indicates whether the content being withheld is the `tweet` or a `user`."), enum("tweet", "user"))
      copyright = boolean(description("Indicates if the content is being withheld for on the basis of copyright infringement."))
      country_codes = array([components.schemas.CountryCode], description("Provides a list of countries where this content is not available."), minItems(1), uniqueItems(true))
    }
  }
  components "schemas" "ContextAnnotation" {
    type = "object"
    description = "Annotation inferred from the Tweet text."
    required = ["domain", "entity"]
    properties {
      domain = components.schemas.ContextAnnotationDomainFields
      entity = components.schemas.ContextAnnotationEntityFields
    }
  }
  components "schemas" "DmParticipants" {
    type = "array"
    description = "Participants for the DM Conversation."
    minItems = 2
    maxItems = 49
    items = [components.schemas.UserId]
  }
  components "schemas" "Error" {
    type = "object"
    required = ["code", "message"]
    properties {
      code = integer(format("int32"))
      message = string()
    }
  }
  components "schemas" "Get2ListsIdFollowersResponse" {
    type = "object"
    properties {
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "Rule" {
    type = "object"
    description = "A user-provided stream filtering rule."
    required = ["value"]
    properties {
      id = components.schemas.RuleId
      tag = components.schemas.RuleTag
      value = components.schemas.RuleValue
    }
  }
  components "schemas" "UserComplianceSchema" {
    type = "object"
    required = ["user", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      user = object({
        id = components.schemas.UserId
      }, ["id"])
    }
  }
  components "schemas" "DownloadUrl" {
    format = "uri"
    description = "URL from which the user will retrieve their compliance results."
    type = "string"
  }
  components "schemas" "Get2UsersByUsernameUsernameResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.User
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Get2UsersIdResponse" {
    type = "object"
    properties {
      data = components.schemas.User
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "OperationalDisconnectProblem" {
    description = "You have been disconnected for operational reasons."
  }
  components "schemas" "TweetComplianceStreamResponse" {
    description = "Tweet compliance stream events."
  }
  components "schemas" "UploadUrl" {
    type = "string"
    format = "uri"
    description = "URL to which the user will upload their Tweet or user IDs."
  }
  components "schemas" "CreateAttachmentsMessageRequest" {
    type = "object"
    required = ["attachments"]
    properties {
      attachments = components.schemas.DmAttachments
      text = string(description("Text of the message."), minLength(1))
    }
  }
  components "schemas" "Get2ListsIdTweetsResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.Tweet], minItems(1))
    }
  }
  components "schemas" "Get2SpacesSearchResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.Space], minItems(1))
    }
  }
  components "schemas" "NextToken" {
    type = "string"
    description = "The next token."
    minLength = 1
  }
  components "schemas" "TweetComplianceSchema" {
    type = "object"
    required = ["tweet", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      quote_tweet_id = components.schemas.TweetId
      tweet = object({
        author_id = components.schemas.UserId,
        id = components.schemas.TweetId
      }, ["id", "author_id"])
    }
  }
  components "schemas" "TweetUnviewable" {
    type = "object"
    required = ["tweet", "event_at", "application"]
    properties {
      application = string(description("If the label is being applied or removed. Possible values are ‘apply’ or ‘remove’."), example("apply"))
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      tweet = object({
        author_id = components.schemas.UserId,
        id = components.schemas.TweetId
      }, ["id", "author_id"])
    }
  }
  components "schemas" "UserUnprotectComplianceSchema" {
    type = "object"
    required = ["user_unprotect"]
    properties {
      user_unprotect = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "Get2TweetsSearchAllResponse" {
    type = "object"
    properties {
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "ListAddUserRequest" {
    type = "object"
    required = ["user_id"]
    properties {
      user_id = components.schemas.UserId
    }
  }
  components "schemas" "ListUnpinResponse" {
    type = "object"
    properties {
      data = object({
        pinned = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "ResultCount" {
    type = "integer"
    format = "int32"
    description = "The number of results returned in this response."
  }
  components "schemas" "TweetNoticeSchema" {
    type = "object"
    required = ["public_tweet_notice"]
    properties {
      public_tweet_notice = components.schemas.TweetNotice
    }
  }
  components "schemas" "ContextAnnotationDomainFields" {
    type = "object"
    description = "Represents the data for the context annotation domain."
    required = ["id"]
    properties {
      id = string(description("The unique id for a context annotation domain."), pattern("^[0-9]{1,19}$"))
      name = string(description("Name of the context annotation domain."))
      description = string(description("Description of the context annotation domain."))
    }
  }
  components "schemas" "PlaceId" {
    type = "string"
    description = "The identifier for this place."
    example = "f7eb2fa2fea288b1"
  }
  components "schemas" "MentionEntity" {}
  components "schemas" "UrlImage" {
    type = "object"
    description = "Represent the information for the URL image."
    properties {
      url = components.schemas.Url
      width = components.schemas.MediaWidth
      height = components.schemas.MediaHeight
    }
  }
  components "schemas" "InvalidRequestProblem" {
    description = "A problem that indicates this request is invalid."
  }
  components "schemas" "List" {
    type = "object"
    description = "A X List is a curated group of accounts."
    required = ["id", "name"]
    properties {
      owner_id = components.schemas.UserId
      private = boolean()
      created_at = string(format("date-time"))
      description = string()
      follower_count = integer()
      id = components.schemas.ListId
      member_count = integer()
      name = string(description("The name of this List."))
    }
  }
  components "schemas" "ListPinnedRequest" {
    type = "object"
    required = ["list_id"]
    properties {
      list_id = components.schemas.ListId
    }
  }
  components "schemas" "MediaHeight" {
    type = "integer"
    description = "The height of the media in pixels."
  }
  components "schemas" "MediaWidth" {
    type = "integer"
    description = "The width of the media in pixels."
  }
  components "schemas" "CashtagEntity" {}
  components "schemas" "RuleTag" {
    type = "string"
    description = "A tag meant for the labeling of user provided rules."
    example = "Non-retweeted coffee Posts"
  }
  components "schemas" "UsageFields" {
    type = "object"
    description = "Represents the data for Usage"
    properties {
      date = string(format("date-time"), description("The time period for the usage"), example("2021-01-06T18:40:40.000Z"))
      usage = integer(format("int32"), description("The usage value"))
    }
  }
  components "schemas" "CreateMessageRequest" {}
  components "schemas" "UserTakedownComplianceSchema" {
    type = "object"
    required = ["user", "withheld_in_countries", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      user = object({
        id = components.schemas.UserId
      }, ["id"])
      withheld_in_countries = array([components.schemas.CountryCode], minItems(1))
    }
  }
  components "schemas" "MediaKey" {
    pattern = "^([0-9]+)_([0-9]+)$"
    type = "string"
    description = "The Media Key identifier for this attachment."
  }
  components "schemas" "ResourceNotFoundProblem" {
    description = "A problem that indicates that a given Tweet, User, etc. does not exist."
  }
  components "schemas" "Space" {
    type = "object"
    required = ["id", "state"]
    properties {
      lang = string(description("The language of the Space."), example("en"))
      created_at = string(format("date-time"), description("Creation time of the Space."), example("2021-07-06T18:40:40.000Z"))
      is_ticketed = boolean(description("Denotes if the Space is a ticketed Space."), example(""false"
"))
      id = components.schemas.SpaceId
      title = string(description("The title of the Space."), example("Spaces are Awesome"))
      updated_at = string(format("date-time"), description("When the Space was last updated."), example("2021-7-14T04:35:55Z"))
      ended_at = string(format("date-time"), description("End time of the Space."), example("2021-07-06T18:40:40.000Z"))
      subscriber_count = integer(format("int32"), description("The number of people who have either purchased a ticket or set a reminder for this Space."), example(10))
      host_ids = array([components.schemas.UserId], description("The user ids for the hosts of the Space."))
      state = string(description("The current state of the Space."), example("live"), enum("live", "scheduled", "ended"))
      invited_user_ids = array([components.schemas.UserId], description("An array of user ids for people who were invited to a Space."))
      speaker_ids = array([components.schemas.UserId], description("An array of user ids for people who were speakers in a Space."))
      participant_count = integer(format("int32"), description("The number of participants in a Space."), example(10))
      started_at = string(format("date-time"), description("When the Space was started as a date string."), example("2021-7-14T04:35:55Z"))
      topics = array([object({
        description = string(description("The description of the given topic.")),
        id = string(description("An ID suitable for use in the REST API.")),
        name = string(description("The name of the given topic."))
      }, description("The X Topic object."), example({
        name = "Technology",
        description = "All about technology",
        id = "848920371311001600"
      }), ["id", "name"])], description("The topics of a Space, as selected by its creator."))
      scheduled_start = string(format("date-time"), description("A date time stamp for when a Space is scheduled to begin."), example("2021-07-06T18:40:40.000Z"))
      creator_id = components.schemas.UserId
    }
  }
  components "schemas" "ComplianceJobName" {
    type = "string"
    description = "User-provided name for a compliance job."
    example = "my-job"
    maxLength = 64
  }
  components "schemas" "Get2ListsIdResponse" {
    type = "object"
    properties {
      data = components.schemas.List
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2UsersIdFollowingResponse" {
    type = "object"
    properties {
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "AnimatedGif" {}
  components "schemas" "DuplicateRuleProblem" {
    description = "The rule you have submitted is a duplicate."
  }
  components "schemas" "Get2SpacesByCreatorIdsResponse" {
    type = "object"
    properties {
      data = array([components.schemas.Space], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "Get2TweetsSearchStreamRulesCountsResponse" {
    type = "object"
    properties {
      data = components.schemas.RulesCount
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "TweetComplianceData" {
    description = "Tweet compliance data."
  }
  components "schemas" "UrlFields" {
    type = "object"
    description = "Represent the portion of text recognized as a URL."
    required = ["url"]
    properties {
      description = string(description("Description of the URL landing page."), example("This is a description of the website."))
      display_url = string(description("The URL as displayed in the X client."), example("twittercommunity.com/t/introducing-…"))
      media_key = components.schemas.MediaKey
      title = string(description("Title of the page the URL points to."), example("Introducing the v2 follow lookup endpoints"))
      expanded_url = components.schemas.Url
      images = array([components.schemas.UrlImage], minItems(1))
      unwound_url = string(format("uri"), description("Fully resolved url."), example("https://twittercommunity.com/t/introducing-the-v2-follow-lookup-endpoints/147118"))
      status = components.schemas.HttpStatusCode
      url = components.schemas.Url
    }
  }
  components "schemas" "UsersFollowingDeleteResponse" {
    type = "object"
    properties {
      data = object({
        following = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "ConflictProblem" {
    description = "You cannot create a new job if one is already in progress."
  }
  components "schemas" "DeleteRulesRequest" {
    type = "object"
    description = "A response from deleting user-specified stream filtering rules."
    required = ["delete"]
    properties {
      delete = object({
        ids = array([components.schemas.RuleId], description("IDs of all deleted user-specified stream filtering rules.")),
        values = array([components.schemas.RuleValue], description("Values of all deleted user-specified stream filtering rules."))
      }, description("IDs and values of all deleted user-specified stream filtering rules."))
    }
  }
  components "schemas" "Get2DmEventsResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken
      })
      data = array([components.schemas.DmEvent], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Get2TweetsIdRetweetsResponse" {
    type = "object"
    properties {
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "InvalidRuleProblem" {
    description = "The rule you have submitted is invalid."
  }
  components "schemas" "UserProtectComplianceSchema" {
    type = "object"
    required = ["user_protect"]
    properties {
      user_protect = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "Get2SpacesIdTweetsResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Get2TweetsSearchStreamResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "ListCreateRequest" {
    type = "object"
    required = ["name"]
    properties {
      private = boolean(default(false))
      description = string(maxLength(100))
      name = string(maxLength(25), minLength(1))
    }
  }
  components "schemas" "Tweet" {
    type = "object"
    example = {
      created_at = "Wed Jan 06 18:40:40 +0000 2021",
      id = "1346889436626259968",
      text = "Learn how to use the user Tweet timeline and user mention timeline endpoints in the X API v2 to explore Tweet\u2026 https:\/\/t.co\/56a0vZUx7i",
      author_id = "2244994945"
    }
    required = ["id", "text", "edit_history_tweet_ids"]
    properties {
      conversation_id = components.schemas.TweetId
      non_public_metrics = object({
        impression_count = integer(format("int32"), description("Number of times this Tweet has been viewed."))
      }, description("Nonpublic engagement metrics for the Tweet at the time of the request."))
      organic_metrics = object({
        like_count = integer(description("Number of times this Tweet has been liked.")),
        reply_count = integer(description("Number of times this Tweet has been replied to.")),
        retweet_count = integer(description("Number of times this Tweet has been Retweeted.")),
        impression_count = integer(description("Number of times this Tweet has been viewed."))
      }, description("Organic nonpublic engagement metrics for the Tweet at the time of the request."), ["impression_count", "retweet_count", "reply_count", "like_count"])
      author_id = components.schemas.UserId
      geo = object({
        coordinates = components.schemas.Point,
        place_id = components.schemas.PlaceId
      }, description("The location tagged on the Tweet, if the user provided one."))
      possibly_sensitive = boolean(description("Indicates if this Tweet contains URLs marked as sensitive, for example content suitable for mature audiences."), example(false))
      in_reply_to_user_id = components.schemas.UserId
      reply_settings = components.schemas.ReplySettingsWithVerifiedUsers
      note_tweet = object({
        entities = object({
          hashtags = array([components.schemas.HashtagEntity], minItems(1)),
          mentions = array([components.schemas.MentionEntity], minItems(1)),
          urls = array([components.schemas.UrlEntity], minItems(1)),
          cashtags = array([components.schemas.CashtagEntity], minItems(1))
        }),
        text = components.schemas.NoteTweetText
      }, description("The full-content of the Tweet, including text beyond 280 characters."))
      public_metrics = object({
        bookmark_count = integer(format("int32"), description("Number of times this Tweet has been bookmarked.")),
        impression_count = integer(format("int32"), description("Number of times this Tweet has been viewed.")),
        like_count = integer(description("Number of times this Tweet has been liked.")),
        quote_count = integer(description("Number of times this Tweet has been quoted.")),
        reply_count = integer(description("Number of times this Tweet has been replied to.")),
        retweet_count = integer(description("Number of times this Tweet has been Retweeted."))
      }, description("Engagement metrics for the Tweet at the time of the request."), ["retweet_count", "reply_count", "like_count", "impression_count", "bookmark_count"])
      edit_controls = object({
        editable_until = string(format("date-time"), description("Time when Tweet is no longer editable."), example("2021-01-06T18:40:40.000Z")),
        edits_remaining = integer(description("Number of times this Tweet can be edited.")),
        is_edit_eligible = boolean(description("Indicates if this Tweet is eligible to be edited."), example(false))
      }, ["is_edit_eligible", "editable_until", "edits_remaining"])
      entities = components.schemas.FullTextEntities
      lang = string(description("Language of the Tweet, if detected by X. Returned as a BCP47 language tag."), example("en"))
      source = string(description("This is deprecated."))
      context_annotations = array([components.schemas.ContextAnnotation], minItems(1))
      scopes = object({
        followers = boolean(description("Indicates if this Tweet is viewable by followers without the Tweet ID"), example(false))
      }, description("The scopes for this tweet"))
      edit_history_tweet_ids = array([components.schemas.TweetId], description("A list of Tweet Ids in this Tweet chain."), minItems(1))
      referenced_tweets = array([object({
        id = components.schemas.TweetId,
        type = string(enum("retweeted", "quoted", "replied_to"))
      }, ["type", "id"])], description("A list of Posts this Tweet refers to. For example, if the parent Tweet is a Retweet, a Quoted Tweet or a Reply, it will include the related Tweet referenced to by its parent."), minItems(1))
      withheld = components.schemas.TweetWithheld
      id = components.schemas.TweetId
      text = components.schemas.TweetText
      attachments = object({
        media_keys = array([components.schemas.MediaKey], description("A list of Media Keys for each one of the media attachments (if media are attached)."), minItems(1)),
        media_source_tweet_id = array([components.schemas.TweetId], description("A list of Posts the media on this Tweet was originally posted in. For example, if the media on a tweet is re-used in another Tweet, this refers to the original, source Tweet.."), minItems(1)),
        poll_ids = array([components.schemas.PollId], description("A list of poll IDs (if polls are attached)."), minItems(1))
      }, description("Specifies the type of attachments (if any) present in this Tweet."))
      created_at = string(format("date-time"), description("Creation time of the Tweet."), example("2021-01-06T18:40:40.000Z"))
      promoted_metrics = object({
        like_count = integer(format("int32"), description("Number of times this Tweet has been liked.")),
        reply_count = integer(format("int32"), description("Number of times this Tweet has been replied to.")),
        retweet_count = integer(format("int32"), description("Number of times this Tweet has been Retweeted.")),
        impression_count = integer(format("int32"), description("Number of times this Tweet has been viewed."))
      }, description("Promoted nonpublic engagement metrics for the Tweet at the time of the request."))
    }
  }
  components "schemas" "TweetDeleteComplianceSchema" {
    type = "object"
    required = ["delete"]
    properties {
      delete = components.schemas.TweetComplianceSchema
    }
  }
  components "schemas" "ListDeleteResponse" {
    type = "object"
    properties {
      data = object({
        deleted = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "TweetEditComplianceSchema" {
    type = "object"
    required = ["tweet_edit"]
    properties {
      tweet_edit = components.schemas.TweetEditComplianceObjectSchema
    }
  }
  components "schemas" "TweetHideResponse" {
    type = "object"
    properties {
      data = object({
        hidden = boolean()
      })
    }
  }
  components "schemas" "UserWithheld" {
    required = ["country_codes"]
    type = "object"
    description = "Indicates withholding details for [withheld content](https://help.twitter.com/en/rules-and-policies/tweet-withheld-by-country)."
    properties {
      country_codes = array([components.schemas.CountryCode], description("Provides a list of countries where this content is not available."), minItems(1), uniqueItems(true))
      scope = string(description("Indicates that the content being withheld is a `user`."), enum("user"))
    }
  }
  components "schemas" "UsersLikesCreateResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      data = object({
        liked = boolean()
      })
    }
  }
  components "schemas" "Aggregate" {
    type = "integer"
    format = "int32"
    description = "The sum of results returned in this response."
  }
  components "schemas" "Get2TweetsCountsRecentResponse" {
    type = "object"
    properties {
      data = array([components.schemas.SearchCount], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        total_tweet_count = components.schemas.Aggregate
      })
    }
  }
  components "schemas" "Get2UsersIdFollowersResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken
      })
      data = array([components.schemas.User], minItems(1))
    }
  }
  components "schemas" "LikeId" {
    pattern = "^[A-Za-z0-9_]{1,40}$"
    type = "string"
    description = "The unique identifier of this Like."
    example = "8ba4f34e6235d905a46bac021d98e923"
  }
  components "schemas" "TweetUnviewableSchema" {
    type = "object"
    required = ["public_tweet_unviewable"]
    properties {
      public_tweet_unviewable = components.schemas.TweetUnviewable
    }
  }
  components "schemas" "UsersRetweetsDeleteResponse" {
    type = "object"
    properties {
      data = object({
        retweeted = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "ContextAnnotationEntityFields" {
    type = "object"
    description = "Represents the data for the context annotation entity."
    required = ["id"]
    properties {
      description = string(description("Description of the context annotation entity."))
      id = string(description("The unique id for a context annotation entity."), pattern("^[0-9]{1,19}$"))
      name = string(description("Name of the context annotation entity."))
    }
  }
  components "schemas" "Get2TweetsIdLikingUsersResponse" {
    type = "object"
    properties {
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "Trend" {
    type = "object"
    description = "A trend."
    properties {
      trend_name = string(description("Name of the trend."))
      tweet_count = integer(format("int32"), description("Number of Posts in this trend."))
    }
  }
  components "schemas" "TweetId" {
    example = "1346889436626259968"
    pattern = "^[0-9]{1,19}$"
    type = "string"
    description = "Unique identifier of this Tweet. This is returned as a string in order to avoid complications with languages and tools that cannot handle large integers."
  }
  components "schemas" "UploadExpiration" {
    type = "string"
    format = "date-time"
    description = "Expiration time of the upload URL."
    example = "2021-01-06T18:40:40.000Z"
  }
  components "schemas" "BookmarkAddRequest" {
    required = ["tweet_id"]
    type = "object"
    properties {
      tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "ClientForbiddenProblem" {
    description = "A problem that indicates your client is forbidden from making this request."
  }
  components "schemas" "Get2SpacesIdResponse" {
    type = "object"
    properties {
      data = components.schemas.Space
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "UserSearchQuery" {
    type = "string"
    description = "The the search string by which to query for users."
    pattern = "^[A-Za-z0-9_]{1,32}$"
  }
  components "schemas" "Variant" {
    type = "object"
    properties {
      url = string(format("uri"), description("The url to the media."))
      bit_rate = integer(description("The bit rate of the media."))
      content_type = string(description("The content type of the media."))
    }
  }
  components "schemas" "ClientAppUsage" {
    type = "object"
    description = "Usage per client app"
    properties {
      client_app_id = string(format("^[0-9]{1,19}$"), description("The unique identifier for this project"))
      usage = array([components.schemas.UsageFields], description("The usage value"), minItems(1))
      usage_result_count = integer(format("int32"), description("The number of results returned"))
    }
  }
  components "schemas" "FieldUnauthorizedProblem" {
    description = "A problem that indicates that you are not allowed to see a particular field on a Tweet, User, etc."
  }
  components "schemas" "Get2UsersSearchResponse" {
    type = "object"
    properties {
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        previous_token = components.schemas.PreviousToken,
        next_token = components.schemas.NextToken
      })
    }
  }
  components "schemas" "PaginationTokenLong" {
    minLength = 1
    maxLength = 19
    type = "string"
    description = "A 'long' pagination token."
  }
  components "schemas" "PollOptionLabel" {
    type = "string"
    description = "The text of a poll choice."
    minLength = 1
    maxLength = 25
  }
  components "schemas" "RulesCapProblem" {
    description = "You have exceeded the maximum number of rules."
  }
  components "schemas" "Get2SpacesIdBuyersResponse" {
    type = "object"
    properties {
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "PaginationToken32" {
    type = "string"
    description = "A base32 pagination token."
    minLength = 16
  }
  components "schemas" "Position" {
    description = "A [GeoJson Position](https://tools.ietf.org/html/rfc7946#section-3.1.1) in the format `[longitude,latitude]`."
    example = ["-105.18816086351444", "40.247749999999996"]
    minItems = 2
    maxItems = 2
    items = [number()]
    type = "array"
  }
  components "schemas" "RuleId" {
    type = "string"
    description = "Unique identifier of this rule."
    example = "120897978112909812"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "RuleValue" {
    example = "coffee -is:retweet"
    type = "string"
    description = "The filterlang value of the rule."
  }
  components "schemas" "ClientAppId" {
    type = "string"
    description = "The ID of the client application"
    minLength = 1
    maxLength = 19
  }
  components "schemas" "ListFollowedRequest" {
    type = "object"
    required = ["list_id"]
    properties {
      list_id = components.schemas.ListId
    }
  }
  components "schemas" "TweetText" {
    type = "string"
    description = "The content of the Tweet."
    example = "Learn how to use the user Tweet timeline and user mention timeline endpoints in the X API v2 to explore Tweet\u2026 https:\/\/t.co\/56a0vZUx7i"
  }
  components "schemas" "Video" {}
  components "schemas" "Get2ComplianceJobsResponse" {
    type = "object"
    properties {
      data = array([components.schemas.ComplianceJob], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      meta = object({
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "Get2TweetsSearchRecentResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Get2UsersByResponse" {
    type = "object"
    properties {
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2UsersIdTweetsResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        oldest_id = components.schemas.OldestId,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken
      })
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "HttpStatusCode" {
    type = "integer"
    description = "HTTP Status Code."
    minimum = 100
    maximum = 599
  }
  components "schemas" "Get2UsersIdPinnedListsResponse" {
    type = "object"
    properties {
      data = array([components.schemas.List], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "LikesComplianceStreamResponse" {
    description = "Likes compliance stream events."
  }
  components "schemas" "Geo" {
    type = "object"
    required = ["type", "bbox", "properties"]
    properties {
      geometry = components.schemas.Point
      properties = object()
      type = string(enum("Feature"))
      bbox = array([number(format("double"), minimum(-180), maximum(180))], example(["-105.193475", "39.60973", "-105.053164", "39.761974"]), maxItems(4), minItems(4))
    }
  }
  components "schemas" "Get2TweetsFirehoseStreamLangJaResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
    }
  }
  components "schemas" "Get2UsersIdTimelinesReverseChronologicalResponse" {
    type = "object"
    properties {
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "TweetDeleteResponse" {
    type = "object"
    properties {
      data = object({
        deleted = boolean()
      }, ["deleted"])
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "StreamingTweetResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "UserComplianceData" {
    description = "User compliance data."
  }
  components "schemas" "ConnectionExceptionProblem" {
    description = "A problem that indicates something is wrong with the connection."
  }
  components "schemas" "CreateComplianceJobResponse" {
    type = "object"
    properties {
      data = components.schemas.ComplianceJob
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Get2TweetsIdRetweetedByResponse" {
    type = "object"
    properties {
      meta = object({
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken
      })
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2TweetsSampleStreamResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2UsageTweetsResponse" {
    type = "object"
    properties {
      data = components.schemas.Usage
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "UserComplianceStreamResponse" {
    description = "User compliance stream events."
  }
  components "schemas" "UserProfileModificationObjectSchema" {
    required = ["user", "profile_field", "new_value", "event_at"]
    type = "object"
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      new_value = string()
      profile_field = string()
      user = object({
        id = components.schemas.UserId
      }, ["id"])
    }
  }
  components "schemas" "AppRulesCount" {
    type = "object"
    description = "A count of user-provided stream filtering rules at the client application level."
    properties {
      rule_count = integer(format("int32"), description("Number of rules for client application"))
      client_app_id = components.schemas.ClientAppId
    }
  }
  components "schemas" "Get2DmConversationsWithParticipantIdDmEventsResponse" {
    type = "object"
    properties {
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.DmEvent], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "NonCompliantRulesProblem" {
    description = "A problem that indicates the user's rule set is not compliant."
  }
  components "schemas" "Poll" {
    type = "object"
    description = "Represent a Poll attached to a Tweet."
    required = ["id", "options"]
    properties {
      voting_status = string(enum("open", "closed"))
      duration_minutes = integer(format("int32"), minimum(5), maximum(10080))
      end_datetime = string(format("date-time"))
      id = components.schemas.PollId
      options = array([components.schemas.PollOption], maxItems(4), minItems(2))
    }
  }
  components "schemas" "TweetLabelData" {
    description = "Tweet label data."
  }
  components "schemas" "Get2UsersIdFollowedListsResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken
      })
      data = array([components.schemas.List], minItems(1))
    }
  }
  components "schemas" "TweetLabelStreamResponse" {
    description = "Tweet label stream events."
  }
  components "schemas" "FilteredStreamingTweetResponse" {
    description = "A Tweet or error that can be returned by the streaming Tweet API. The values returned with a successful streamed Tweet includes the user provided rules that the Tweet matched."
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      matching_rules = array([object({
        id = components.schemas.RuleId,
        tag = components.schemas.RuleTag
      }, ["id"])], description("The list of rules which matched the Tweet"))
    }
  }
  components "schemas" "UsersFollowingCreateRequest" {
    type = "object"
    required = ["target_user_id"]
    properties {
      target_user_id = components.schemas.UserId
    }
  }
  components "schemas" "Get2LikesFirehoseStreamResponse" {
    type = "object"
    properties {
      data = components.schemas.Like
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "ListUpdateRequest" {
    type = "object"
    properties {
      private = boolean()
      description = string(maxLength(100))
      name = string(maxLength(25), minLength(1))
    }
  }
  components "schemas" "RulesCount" {
    type = "object"
    description = "A count of user-provided stream filtering rules at the application and project levels."
    properties {
      all_project_client_apps = components.schemas.AllProjectClientApps
      cap_per_client_app = integer(format("int32"), description("Cap of number of rules allowed per client application"))
      cap_per_project = integer(format("int32"), description("Cap of number of rules allowed per project"))
      client_app_rules_count = components.schemas.AppRulesCount
      project_rules_count = integer(format("int32"), description("Number of rules for project"))
    }
  }
  components "schemas" "UsersLikesCreateRequest" {
    required = ["tweet_id"]
    type = "object"
    properties {
      tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "CreateDmConversationRequest" {
    type = "object"
    required = ["conversation_type", "participant_ids", "message"]
    properties {
      participant_ids = components.schemas.DmParticipants
      conversation_type = string(description("The conversation type that is being created."), enum("Group"))
      message = components.schemas.CreateMessageRequest
    }
  }
  components "schemas" "Get2UsersIdMentionsResponse" {
    type = "object"
    properties {
      meta = object({
        oldest_id = components.schemas.OldestId,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken
      })
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "UrlEntityDm" {
    description = "Represent the portion of text recognized as a URL, and its start and end position within the text."
  }
  components "schemas" "UsageCapExceededProblem" {
    description = "A problem that indicates that a usage cap has been exceeded."
  }
  components "schemas" "AllProjectClientApps" {
    type = "array"
    description = "Client App Rule Counts for all applications in the project"
    items = [components.schemas.AppRulesCount]
  }
  components "schemas" "Get2TweetsFirehoseStreamResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2UsersResponse" {
    type = "object"
    properties {
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "PaginationToken36" {
    type = "string"
    description = "A base36 pagination token."
    minLength = 1
  }
  components "schemas" "TweetCount" {
    type = "integer"
    description = "The count for the bucket."
  }
  components "schemas" "ClientDisconnectedProblem" {
    description = "Your client has gone away."
  }
  components "schemas" "End" {
    type = "string"
    format = "date-time"
    description = "The end time of the bucket."
  }
  components "schemas" "Get2SpacesResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = array([components.schemas.Space], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "TweetNotice" {
    type = "object"
    required = ["tweet", "event_type", "event_at", "application"]
    properties {
      details = string(description("Information shown on the Tweet label"))
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      event_type = string(description("The type of label on the Tweet"), example("misleading"))
      extended_details_url = string(description("Link to more information about this kind of label"))
      label_title = string(description("Title/header of the Tweet label"))
      tweet = object({
        author_id = components.schemas.UserId,
        id = components.schemas.TweetId
      }, ["id", "author_id"])
      application = string(description("If the label is being applied or removed. Possible values are ‘apply’ or ‘remove’."), example("apply"))
    }
  }
  components "schemas" "PollOption" {
    type = "object"
    description = "Describes a choice in a Poll object."
    required = ["position", "label", "votes"]
    properties {
      position = integer(description("Position of this choice in the poll."))
      votes = integer(description("Number of users who voted for this choice."))
      label = components.schemas.PollOptionLabel
    }
  }
  components "schemas" "TweetCreateRequest" {
    type = "object"
    properties {
      reply_settings = string(description("Settings to indicate who can reply to the Tweet."), enum("following", "mentionedUsers", "subscribers"))
      card_uri = string(description("Card Uri Parameter. This is mutually exclusive from Quote Tweet Id, Poll, Media, and Direct Message Deep Link."))
      direct_message_deep_link = string(description("Link to take the conversation from the public timeline to a private Direct Message."))
      for_super_followers_only = boolean(description("Exclusive Tweet for super followers."), default(false))
      text = components.schemas.TweetText
      nullcast = boolean(description("Nullcasted (promoted-only) Posts do not appear in the public timeline and are not served to followers."), default(false))
      quote_tweet_id = components.schemas.TweetId
      media {
        type = "object"
        description = "Media information being attached to created Tweet. This is mutually exclusive from Quote Tweet Id, Poll, and Card URI."
        required = ["media_ids"]
        properties {
          media_ids = array([components.schemas.MediaId], description("A list of Media Ids to be attached to a created Tweet."), maxItems(4), minItems(1))
          tagged_user_ids = array([components.schemas.UserId], description("A list of User Ids to be tagged in the media for created Tweet."), maxItems(10))
        }
      }
      reply {
        type = "object"
        description = "Tweet information of the Tweet being replied to."
        required = ["in_reply_to_tweet_id"]
        properties {
          exclude_reply_user_ids = array([components.schemas.UserId], description("A list of User Ids to be excluded from the reply Tweet."))
          in_reply_to_tweet_id = components.schemas.TweetId
        }
      }
      poll {
        type = "object"
        description = "Poll options for a Tweet with a poll. This is mutually exclusive from Media, Quote Tweet Id, and Card URI."
        required = ["options", "duration_minutes"]
        properties {
          duration_minutes = integer(format("int32"), description("Duration of the poll in minutes."), minimum(5), maximum(10080))
          options = array([string(description("The text of a poll choice."), maxLength(25), minLength(1))], maxItems(4), minItems(2))
          reply_settings = string(description("Settings to indicate who can reply to the Tweet."), enum("following", "mentionedUsers"))
        }
      }
      geo {
        type = "object"
        description = "Place ID being attached to the Tweet for geo location."
        properties {
          place_id = string()
        }
      }
    }
  }
  components "schemas" "MuteUserRequest" {
    type = "object"
    required = ["target_user_id"]
    properties {
      target_user_id = components.schemas.UserId
    }
  }
  components "schemas" "OldestId" {
    type = "string"
    description = "The oldest id in this response."
  }
  components "schemas" "RulesResponseMetadata" {
    required = ["sent"]
    type = "object"
    properties {
      summary = components.schemas.RulesRequestSummary
      next_token = components.schemas.NextToken
      result_count = integer(format("int32"), description("Number of Rules in result set."))
      sent = string()
    }
  }
  components "schemas" "DmAttachments" {
    type = "array"
    description = "Attachments to a DM Event."
    items = [components.schemas.DmMediaAttachment]
  }
  components "schemas" "Expansions" {
    type = "object"
    properties {
      media = array([components.schemas.Media], minItems(1))
      places = array([components.schemas.Place], minItems(1))
      polls = array([components.schemas.Poll], minItems(1))
      topics = array([components.schemas.Topic], minItems(1))
      tweets = array([components.schemas.Tweet], minItems(1))
      users = array([components.schemas.User], minItems(1))
    }
  }
  components "schemas" "Get2TrendsByWoeidWoeidResponse" {
    type = "object"
    properties {
      data = array([components.schemas.Trend], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Get2TweetsIdQuoteTweetsResponse" {
    type = "object"
    properties {
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "ListPinnedResponse" {
    type = "object"
    properties {
      data = object({
        pinned = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Get2TweetsFirehoseStreamLangPtResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
    }
  }
  components "schemas" "UsersRetweetsCreateResponse" {
    type = "object"
    properties {
      data = object({
        id = components.schemas.TweetId,
        retweeted = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "TweetTakedownComplianceSchema" {
    type = "object"
    required = ["tweet", "withheld_in_countries", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      quote_tweet_id = components.schemas.TweetId
      tweet = object({
        id = components.schemas.TweetId,
        author_id = components.schemas.UserId
      }, ["id", "author_id"])
      withheld_in_countries = array([components.schemas.CountryCode], minItems(1))
    }
  }
  components "schemas" "UserUndeleteComplianceSchema" {
    type = "object"
    required = ["user_undelete"]
    properties {
      user_undelete = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "UserWithheldComplianceSchema" {
    type = "object"
    required = ["user_withheld"]
    properties {
      user_withheld = components.schemas.UserTakedownComplianceSchema
    }
  }
  components "schemas" "CountryCode" {
    type = "string"
    description = "A two-letter ISO 3166-1 alpha-2 country code."
    example = "US"
    pattern = "^[A-Z]{2}$"
  }
  components "schemas" "Get2DmEventsEventIdResponse" {
    type = "object"
    properties {
      data = components.schemas.DmEvent
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2TweetsFirehoseStreamLangKoResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "ListCreateResponse" {
    type = "object"
    properties {
      data = object({
        id = components.schemas.ListId,
        name = string(description("The name of this List."))
      }, description("A X List is a curated group of accounts."), ["id", "name"])
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "ResourceUnavailableProblem" {
    description = "A problem that indicates a particular Tweet, User, etc. is not available to you."
  }
  components "schemas" "UserDeleteComplianceSchema" {
    required = ["user_delete"]
    type = "object"
    properties {
      user_delete = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "TweetCreateResponse" {
    type = "object"
    properties {
      data = object({
        id = components.schemas.TweetId,
        text = components.schemas.TweetText
      }, ["id", "text"])
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "CreateComplianceJobRequest" {
    type = "object"
    description = "A request to create a new batch compliance job."
    required = ["type"]
    properties {
      name = components.schemas.ComplianceJobName
      resumable = boolean(description("If true, this endpoint will return a pre-signed URL with resumable uploads enabled."))
      type = string(description("Type of compliance job to list."), enum("tweets", "users"))
    }
  }
  components "schemas" "DmMediaAttachment" {
    required = ["media_id"]
    type = "object"
    properties {
      media_id = components.schemas.MediaId
    }
  }
  components "schemas" "Get2ComplianceJobsIdResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      data = components.schemas.ComplianceJob
    }
  }
  components "schemas" "Get2UsersMeResponse" {
    type = "object"
    properties {
      data = components.schemas.User
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "ResourceUnauthorizedProblem" {
    description = "A problem that indicates you are not allowed to see a particular Tweet, User, etc."
  }
  components "schemas" "Get2TweetsIdResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Get2UsersIdMutingResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.User], minItems(1))
    }
  }
  components "schemas" "RuleNoId" {
    type = "object"
    description = "A user-provided stream filtering rule."
    required = ["value"]
    properties {
      tag = components.schemas.RuleTag
      value = components.schemas.RuleValue
    }
  }
  components "schemas" "TopicId" {
    type = "string"
    description = "Unique identifier of this Topic."
  }
  components "schemas" "Url" {
    type = "string"
    format = "uri"
    description = "A validly formatted URL."
    example = "https://developer.twitter.com/en/docs/twitter-api"
  }
  components "schemas" "Get2ListsIdMembersResponse" {
    type = "object"
    properties {
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "RulesRequestSummary" {}
  components "schemas" "AddOrDeleteRulesRequest" {}
  components "schemas" "UrlEntity" {
    description = "Represent the portion of text recognized as a URL, and its start and end position within the text."
  }
  components "schemas" "UsersLikesDeleteResponse" {
    type = "object"
    properties {
      data = object({
        liked = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "RulesLookupResponse" {
    type = "object"
    required = ["meta"]
    properties {
      data = array([components.schemas.Rule])
      meta = components.schemas.RulesResponseMetadata
    }
  }
  components "schemas" "UserUnsuspendComplianceSchema" {
    type = "object"
    required = ["user_unsuspend"]
    properties {
      user_unsuspend = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "BookmarkMutationResponse" {
    type = "object"
    properties {
      data = object({
        bookmarked = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Get2UsersIdListMembershipsResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.List], minItems(1))
    }
  }
  components "schemas" "TweetDropComplianceSchema" {
    type = "object"
    required = ["drop"]
    properties {
      drop = components.schemas.TweetComplianceSchema
    }
  }
  components "schemas" "DisallowedResourceProblem" {
    description = "A problem that indicates that the resource requested violates the precepts of this API."
  }
  components "schemas" "Get2TweetsResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      data = array([components.schemas.Tweet], minItems(1))
    }
  }
  components "schemas" "Like" {
    type = "object"
    description = "A Like event, with the liking user and the tweet being liked"
    properties {
      liked_tweet_id = components.schemas.TweetId
      liking_user_id = components.schemas.UserId
      timestamp_ms = integer(format("int32"), description("Timestamp in milliseconds of creation."))
      created_at = string(format("date-time"), description("Creation time of the Tweet."), example("2021-01-06T18:40:40.000Z"))
      id = components.schemas.LikeId
    }
  }
  components "schemas" "NoteTweetText" {
    description = "The note content of the Tweet."
    example = "Learn how to use the user Tweet timeline and user mention timeline endpoints in the X API v2 to explore Tweet\u2026 https:\/\/t.co\/56a0vZUx7i"
    type = "string"
  }
  components "schemas" "FullTextEntities" {
    type = "object"
    properties {
      mentions = array([components.schemas.MentionEntity], minItems(1))
      urls = array([components.schemas.UrlEntity], minItems(1))
      annotations = array([{
        description = "Annotation for entities based on the Tweet text."
      }], minItems(1))
      cashtags = array([components.schemas.CashtagEntity], minItems(1))
      hashtags = array([components.schemas.HashtagEntity], minItems(1))
    }
  }
  components "schemas" "PreviousToken" {
    type = "string"
    description = "The previous token."
    minLength = 1
  }
  components "schemas" "ReplySettings" {
    enum = ["everyone", "mentionedUsers", "following", "other"]
    pattern = "^[A-Za-z]{1,12}$"
    type = "string"
    description = "Shows who can reply a Tweet. Fields returned are everyone, mentioned_users, and following."
  }
  components "schemas" "CreateTextMessageRequest" {
    type = "object"
    required = ["text"]
    properties {
      attachments = components.schemas.DmAttachments
      text = string(description("Text of the message."), minLength(1))
    }
  }
  components "schemas" "Get2UsersIdBookmarksResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.Tweet], minItems(1))
    }
  }
  components "schemas" "UnlikeComplianceSchema" {
    type = "object"
    required = ["favorite", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      favorite = object({
        id = components.schemas.TweetId,
        user_id = components.schemas.UserId
      }, ["id", "user_id"])
    }
  }
  components "schemas" "Usage" {
    description = "Usage per client app"
    type = "object"
    properties {
      project_id = string(format("^[0-9]{1,19}$"), description("The unique identifier for this project"))
      project_usage = integer(format("int32"), description("The number of Posts read in this project"))
      cap_reset_day = integer(format("int32"), description("Number of days left for the Tweet cap to reset"))
      daily_client_app_usage = array([components.schemas.ClientAppUsage], description("The daily usage breakdown for each Client Application a project"), minItems(1))
      daily_project_usage = object({
        project_id = integer(format("int32"), description("The unique identifier for this project")),
        usage = array([components.schemas.UsageFields], description("The usage value"), minItems(1))
      }, description("The daily usage breakdown for a project"))
      project_cap = integer(format("int32"), description("Total number of Posts that can be read in this project per month"))
    }
  }
  components "schemas" "UserScrubGeoSchema" {
    type = "object"
    required = ["scrub_geo"]
    properties {
      scrub_geo = components.schemas.UserScrubGeoObjectSchema
    }
  }
  components "schemas" "DeleteDmResponse" {
    type = "object"
    properties {
      data = object({
        deleted = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "DmEventId" {
    type = "string"
    description = "Unique identifier of a DM Event."
    example = "1146654567674912769"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "Get2TweetsFirehoseStreamLangEnResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "UsersRetweetsCreateRequest" {
    type = "object"
    required = ["tweet_id"]
    properties {
      tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "User" {
    required = ["id", "name", "username"]
    type = "object"
    description = "The X User object."
    example = {
      name = "X Dev",
      protected = "false",
      username = "TwitterDev",
      created_at = "2013-12-14T04:35:55Z",
      id = "2244994945"
    }
    properties {
      description = string(description("The text of this User's profile description (also known as bio), if the User provided one."))
      created_at = string(format("date-time"), description("Creation time of this User."))
      entities = object({
        description = components.schemas.FullTextEntities,
        url = object({
          urls = array([components.schemas.UrlEntity], minItems(1))
        }, description("Expanded details for the URL specified in the User's profile, with start and end indices."))
      }, description("A list of metadata found in the User's profile description."))
      protected = boolean(description("Indicates if this User has chosen to protect their Posts (in other words, if this User's Posts are private)."))
      name = string(description("The friendly name of this User, as shown on their profile."))
      profile_image_url = string(format("uri"), description("The URL to the profile image for this User."))
      connection_status = array([string(description("Type of connection between users."), enum("follow_request_received", "follow_request_sent", "blocking", "followed_by", "following", "muting"))], description("Returns detailed information about the relationship between two users."))
      username = components.schemas.UserName
      location = string(description("The location specified in the User's profile, if the User provided one. As this is a freeform value, it may not indicate a valid location, but it may be fuzzily evaluated when performing searches with location queries."))
      id = components.schemas.UserId
      public_metrics = object({
        like_count = integer(description("The number of likes created by this User.")),
        listed_count = integer(description("The number of lists that include this User.")),
        tweet_count = integer(description("The number of Posts (including Retweets) posted by this User.")),
        followers_count = integer(description("Number of Users who are following this User.")),
        following_count = integer(description("Number of Users this User is following."))
      }, description("A list of metrics for this User."), ["followers_count", "following_count", "tweet_count", "listed_count"])
      verified = boolean(description("Indicate if this User is a verified X User."))
      pinned_tweet_id = components.schemas.TweetId
      withheld = components.schemas.UserWithheld
      verified_type = string(description("The X Blue verified type of the user, eg: blue, government, business or none."), enum("blue", "government", "business", "none"))
      receives_your_dm = boolean(description("Indicates if you can send a DM to this User"))
      url = string(description("The URL specified in the User's profile."))
      most_recent_tweet_id = components.schemas.TweetId
      subscription_type = string(description("The X Blue subscription type of the user, eg: Basic, Premium, PremiumPlus or None."), enum("Basic", "Premium", "PremiumPlus", "None"))
    }
  }
  components "schemas" "UserIdMatchesAuthenticatedUser" {
    type = "string"
    description = "Unique identifier of this User. The value must be the same as the authenticated user."
    example = "2244994945"
  }
  components "schemas" "ComplianceJobStatus" {
    type = "string"
    description = "Status of a compliance job."
    enum = ["created", "in_progress", "failed", "complete", "expired"]
  }
  components "schemas" "DmEvent" {
    type = "object"
    required = ["id", "event_type"]
    properties {
      sender_id = components.schemas.UserId
      attachments = object({
        media_keys = array([components.schemas.MediaKey], description("A list of Media Keys for each one of the media attachments (if media are attached)."), minItems(1)),
        card_ids = array([string()], description("A list of card IDs (if cards are attached)."), minItems(1))
      }, description("Specifies the type of attachments (if any) present in this DM."))
      created_at = string(format("date-time"))
      dm_conversation_id = components.schemas.DmConversationId
      participant_ids = array([components.schemas.UserId], description("A list of participants for a ParticipantsJoin or ParticipantsLeave event_type."), minItems(1))
      cashtags = array([components.schemas.CashtagEntity], minItems(1))
      text = string()
      id = components.schemas.DmEventId
      hashtags = array([components.schemas.HashtagEntity], minItems(1))
      urls = array([components.schemas.UrlEntityDm], minItems(1))
      mentions = array([components.schemas.MentionEntity], minItems(1))
      referenced_tweets = array([object({
        id = components.schemas.TweetId
      }, ["id"])], description("A list of Posts this DM refers to."), minItems(1))
      event_type = string(example("MessageCreate"))
    }
  }
  components "schemas" "Get2UsersIdLikedTweetsResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken
      })
      data = array([components.schemas.Tweet], minItems(1))
    }
  }
  components "schemas" "MediaId" {
    example = "1146654567674912769"
    pattern = "^[0-9]{1,19}$"
    type = "string"
    description = "The unique identifier of this Media."
  }
  components "schemas" "PlaceType" {
    type = "string"
    example = "city"
    enum = ["poi", "neighborhood", "city", "admin", "country", "unknown"]
  }
  components "schemas" "ComplianceJobType" {
    type = "string"
    description = "Type of compliance job to list."
    enum = ["tweets", "users"]
  }
  components "schemas" "TweetEditComplianceObjectSchema" {
    type = "object"
    required = ["tweet", "event_at", "initial_tweet_id", "edit_tweet_ids"]
    properties {
      edit_tweet_ids = array([components.schemas.TweetId], minItems(1))
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      initial_tweet_id = components.schemas.TweetId
      tweet = object({
        id = components.schemas.TweetId
      }, ["id"])
    }
  }
  components "schemas" "CreateDmEventResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      data = object({
        dm_conversation_id = components.schemas.DmConversationId,
        dm_event_id = components.schemas.DmEventId
      }, ["dm_conversation_id", "dm_event_id"])
    }
  }
  components "schemas" "HashtagFields" {
    type = "object"
    description = "Represent the portion of text recognized as a Hashtag, and its start and end position within the text."
    required = ["tag"]
    properties {
      tag = string(description("The text of the Hashtag."), example("MondayMotivation"))
    }
  }
  components "schemas" "TweetUndropComplianceSchema" {
    type = "object"
    required = ["undrop"]
    properties {
      undrop = components.schemas.TweetComplianceSchema
    }
  }
  components "schemas" "UserSuspendComplianceSchema" {
    type = "object"
    required = ["user_suspend"]
    properties {
      user_suspend = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "AddRulesRequest" {
    description = "A request to add a user-specified stream filtering rule."
    required = ["add"]
    type = "object"
    properties {
      add = array([components.schemas.RuleNoId])
    }
  }
  components "schemas" "HashtagEntity" {}
  components "schemas" "Variants" {
    type = "array"
    description = "An array of all available variants of the media."
    items = [components.schemas.Variant]
  }
  components "schemas" "CashtagFields" {
    type = "object"
    description = "Represent the portion of text recognized as a Cashtag, and its start and end position within the text."
    required = ["tag"]
    properties {
      tag = string(example("TWTR"))
    }
  }
  components "schemas" "EntityIndicesInclusiveExclusive" {
    type = "object"
    description = "Represent a boundary range (start and end index) for a recognized entity (for example a hashtag or a mention). `start` must be smaller than `end`.  The start index is inclusive, the end index is exclusive."
    required = ["start", "end"]
    properties {
      end = integer(description("Index (zero-based) at which position this entity ends.  The index is exclusive."), example(61))
      start = integer(description("Index (zero-based) at which position this entity starts.  The index is inclusive."), example(50))
    }
  }
  components "schemas" "MuteUserMutationResponse" {
    type = "object"
    properties {
      data = object({
        muting = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Problem" {
    type = "object"
    description = "An HTTP Problem Details object, as defined in IETF RFC 7807 (https://tools.ietf.org/html/rfc7807)."
    required = ["type", "title"]
    discriminator {
      propertyName = "type"
      mapping {
        https://api.twitter.com/2/problems/disallowed-resource = "#/components/schemas/DisallowedResourceProblem"
        https://api.twitter.com/2/problems/streaming-connection = "#/components/schemas/ConnectionExceptionProblem"
        https://api.twitter.com/2/problems/client-forbidden = "#/components/schemas/ClientForbiddenProblem"
        https://api.twitter.com/2/problems/not-authorized-for-resource = "#/components/schemas/ResourceUnauthorizedProblem"
        https://api.twitter.com/2/problems/oauth1-permissions = "#/components/schemas/Oauth1PermissionsProblem"
        https://api.twitter.com/2/problems/client-disconnected = "#/components/schemas/ClientDisconnectedProblem"
        https://api.twitter.com/2/problems/usage-capped = "#/components/schemas/UsageCapExceededProblem"
        about:blank = "#/components/schemas/GenericProblem"
        https://api.twitter.com/2/problems/invalid-request = "#/components/schemas/InvalidRequestProblem"
        https://api.twitter.com/2/problems/resource-not-found = "#/components/schemas/ResourceNotFoundProblem"
        https://api.twitter.com/2/problems/conflict = "#/components/schemas/ConflictProblem"
        https://api.twitter.com/2/problems/operational-disconnect = "#/components/schemas/OperationalDisconnectProblem"
        https://api.twitter.com/2/problems/not-authorized-for-field = "#/components/schemas/FieldUnauthorizedProblem"
        https://api.twitter.com/2/problems/unsupported-authentication = "#/components/schemas/UnsupportedAuthenticationProblem"
        https://api.twitter.com/2/problems/rule-cap = "#/components/schemas/RulesCapProblem"
        https://api.twitter.com/2/problems/invalid-rules = "#/components/schemas/InvalidRuleProblem"
        https://api.twitter.com/2/problems/resource-unavailable = "#/components/schemas/ResourceUnavailableProblem"
        https://api.twitter.com/2/problems/noncompliant-rules = "#/components/schemas/NonCompliantRulesProblem"
        https://api.twitter.com/2/problems/duplicate-rules = "#/components/schemas/DuplicateRuleProblem"
      }
    }
    properties {
      title = string()
      type = string()
      detail = string()
      status = integer()
    }
  }
  components "schemas" "DmConversationId" {
    example = "123123123-456456456"
    pattern = "^([0-9]{1,19}-[0-9]{1,19}|[0-9]{15,19})$"
    type = "string"
    description = "Unique identifier of a DM conversation. This can either be a numeric string, or a pair of numeric strings separated by a '-' character in the case of one-on-one DM Conversations."
  }
  components "schemas" "LikeComplianceSchema" {
    type = "object"
    required = ["delete"]
    properties {
      delete = components.schemas.UnlikeComplianceSchema
    }
  }
  components "schemas" "ReplySettingsWithVerifiedUsers" {
    type = "string"
    description = "Shows who can reply a Tweet. Fields returned are everyone, mentioned_users, subscribers, verified and following."
    enum = ["everyone", "mentionedUsers", "following", "other", "subscribers", "verified"]
    pattern = "^[A-Za-z]{1,12}$"
  }
  components "schemas" "UserName" {
    type = "string"
    description = "The X handle (screen name) of this user."
    pattern = "^[A-Za-z0-9_]{1,15}$"
  }
  components "schemas" "JobId" {
    type = "string"
    description = "Compliance Job ID."
    example = "1372966999991541762"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "ListFollowedResponse" {
    type = "object"
    properties {
      data = object({
        following = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "TweetHideRequest" {
    type = "object"
    required = ["hidden"]
    properties {
      hidden = boolean()
    }
  }
  components "schemas" "UsersFollowingCreateResponse" {
    type = "object"
    properties {
      data = object({
        following = boolean(),
        pending_follow = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "ComplianceJob" {
    type = "object"
    required = ["id", "type", "created_at", "upload_url", "download_url", "upload_expires_at", "download_expires_at", "status"]
    properties {
      download_expires_at = components.schemas.DownloadExpiration
      id = components.schemas.JobId
      upload_expires_at = components.schemas.UploadExpiration
      upload_url = components.schemas.UploadUrl
      created_at = components.schemas.CreatedAt
      download_url = components.schemas.DownloadUrl
      type = components.schemas.ComplianceJobType
      status = components.schemas.ComplianceJobStatus
      name = components.schemas.ComplianceJobName
    }
  }
  components "schemas" "ListId" {
    type = "string"
    description = "The unique identifier of this List."
    example = "1146654567674912769"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "Point" {
    description = "A [GeoJson Point](https://tools.ietf.org/html/rfc7946#section-3.1.2) geometry object."
    required = ["type", "coordinates"]
    type = "object"
    properties {
      coordinates = components.schemas.Position
      type = string(example("Point"), enum("Point"))
    }
  }
  components "schemas" "UnsupportedAuthenticationProblem" {
    description = "A problem that indicates that the authentication used is not supported."
  }
  components "schemas" "UserId" {
    description = "Unique identifier of this User. This is returned as a string in order to avoid complications with languages and tools that cannot handle large integers."
    example = "2244994945"
    pattern = "^[0-9]{1,19}$"
    type = "string"
  }
  components "schemas" "EntityIndicesInclusiveInclusive" {
    type = "object"
    description = "Represent a boundary range (start and end index) for a recognized entity (for example a hashtag or a mention). `start` must be smaller than `end`.  The start index is inclusive, the end index is inclusive."
    required = ["start", "end"]
    properties {
      end = integer(description("Index (zero-based) at which position this entity ends.  The index is inclusive."), example(61))
      start = integer(description("Index (zero-based) at which position this entity starts.  The index is inclusive."), example(50))
    }
  }
  components "schemas" "Get2LikesSample10StreamResponse" {
    type = "object"
    properties {
      data = components.schemas.Like
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2UsersIdBlockingResponse" {
    type = "object"
    properties {
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Place" {
    type = "object"
    required = ["id", "full_name"]
    properties {
      place_type = components.schemas.PlaceType
      contained_within = array([components.schemas.PlaceId], minItems(1))
      country = string(description("The full name of the county in which this place exists."), example("United States"))
      country_code = components.schemas.CountryCode
      full_name = string(description("The full name of this place."), example("Lakewood, CO"))
      geo = components.schemas.Geo
      id = components.schemas.PlaceId
      name = string(description("The human readable name of this place."), example("Lakewood"))
    }
  }
  components "schemas" "SearchCount" {
    required = ["end", "start", "tweet_count"]
    type = "object"
    description = "Represent a Search Count Result."
    properties {
      tweet_count = components.schemas.TweetCount
      end = components.schemas.End
      start = components.schemas.Start
    }
  }
  components "schemas" "ListUpdateResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      data = object({
        updated = boolean()
      })
    }
  }
  components "schemas" "Media" {
    type = "object"
    required = ["type"]
    discriminator {
      propertyName = "type"
      mapping {
        video = "#/components/schemas/Video"
        animated_gif = "#/components/schemas/AnimatedGif"
        photo = "#/components/schemas/Photo"
      }
    }
    properties {
      height = components.schemas.MediaHeight
      media_key = components.schemas.MediaKey
      type = string()
      width = components.schemas.MediaWidth
    }
  }
  components "schemas" "StreamingLikeResponse" {
    type = "object"
    properties {
      data = components.schemas.Like
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "TweetWithheldComplianceSchema" {
    type = "object"
    required = ["withheld"]
    properties {
      withheld = components.schemas.TweetTakedownComplianceSchema
    }
  }
  components "schemas" "Get2UsersIdOwnedListsResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.List], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Photo" {}
  components "schemas" "UserProfileModificationComplianceSchema" {
    type = "object"
    required = ["user_profile_modification"]
    properties {
      user_profile_modification = components.schemas.UserProfileModificationObjectSchema
    }
  }
  components "schemas" "Get2TweetsCountsAllResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        total_tweet_count = components.schemas.Aggregate
      })
      data = array([components.schemas.SearchCount], minItems(1))
    }
  }
  components "schemas" "ListMutateResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      data = object({
        is_member = boolean()
      })
    }
  }
  components "schemas" "NewestId" {
    type = "string"
    description = "The newest id in this response."
  }
  components "schemas" "Oauth1PermissionsProblem" {
    description = "A problem that indicates your client application does not have the required OAuth1 permissions for the requested endpoint."
  }
  components "schemas" "AddOrDeleteRulesResponse" {
    type = "object"
    description = "A response from modifying user-specified stream filtering rules."
    required = ["meta"]
    properties {
      data = array([components.schemas.Rule], description("All user-specified stream filtering rules that were created."))
      errors = array([components.schemas.Problem], minItems(1))
      meta = components.schemas.RulesResponseMetadata
    }
  }
  components "schemas" "CreatedAt" {
    format = "date-time"
    description = "Creation time of the compliance job."
    example = "2021-01-06T18:40:40.000Z"
    type = "string"
  }
  components "schemas" "DownloadExpiration" {
    description = "Expiration time of the download URL."
    example = "2021-01-06T18:40:40.000Z"
    type = "string"
    format = "date-time"
  }
  components "schemas" "Get2DmConversationsIdDmEventsResponse" {
    type = "object"
    properties {
      data = array([components.schemas.DmEvent], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "UserScrubGeoObjectSchema" {
    type = "object"
    required = ["user", "up_to_tweet_id", "event_at"]
    properties {
      up_to_tweet_id = components.schemas.TweetId
      user = object({
        id = components.schemas.UserId
      }, ["id"])
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
    }
  }
  components "schemas" "Start" {
    description = "The start time of the bucket."
    type = "string"
    format = "date-time"
  }
  components "schemas" "GenericProblem" {
    description = "A generic problem with no additional information beyond that provided by the HTTP status code."
  }
  components "schemas" "Get2TweetsSample10StreamResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "MentionFields" {
    type = "object"
    description = "Represent the portion of text recognized as a User mention, and its start and end position within the text."
    required = ["username"]
    properties {
      id = components.schemas.UserId
      username = components.schemas.UserName
    }
  }
  components "schemas" "PollId" {
    description = "Unique identifier of this poll."
    example = "1365059861688410112"
    pattern = "^[0-9]{1,19}$"
    type = "string"
  }
  components "schemas" "SpaceId" {
    pattern = "^[a-zA-Z0-9]{1,13}$"
    type = "string"
    description = "The unique identifier of this Space."
    example = "1SLjjRYNejbKM"
  }
  components "parameters" "PollFieldsParameter" {
    name = "poll.fields"
    in = "query"
    description = "A comma separated list of Poll fields to display."
    style = "form"
    schema = array([string(enum("duration_minutes", "end_datetime", "id", "options", "voting_status"))], description("The fields available for a Poll object."), example(["duration_minutes", "end_datetime", "id", "options", "voting_status"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "SpaceFieldsParameter" {
    name = "space.fields"
    in = "query"
    description = "A comma separated list of Space fields to display."
    style = "form"
    schema = array([string(enum("created_at", "creator_id", "ended_at", "host_ids", "id", "invited_user_ids", "is_ticketed", "lang", "participant_count", "scheduled_start", "speaker_ids", "started_at", "state", "subscriber_count", "title", "topic_ids", "updated_at"))], description("The fields available for a Space object."), example(["created_at", "creator_id", "ended_at", "host_ids", "id", "invited_user_ids", "is_ticketed", "lang", "participant_count", "scheduled_start", "speaker_ids", "started_at", "state", "subscriber_count", "title", "topic_ids", "updated_at"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "TrendFieldsParameter" {
    in = "query"
    schema = array([string(enum("trend_name", "tweet_count"))], description("The fields available for a Trend object."), example(["trend_name", "tweet_count"]), minItems(1), uniqueItems(true))
    description = "A comma separated list of Trend fields to display."
    style = "form"
    name = "trend.fields"
  }
  components "parameters" "ListExpansionsParameter" {
    style = "form"
    schema = array([string(enum("owner_id"))], description("The list of fields you can expand for a [List](#List) object. If the field has an ID, it can be expanded into a full object."), example(["owner_id"]), minItems(1), uniqueItems(true))
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
  }
  components "parameters" "SpaceExpansionsParameter" {
    style = "form"
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
    schema = array([string(enum("creator_id", "host_ids", "invited_user_ids", "speaker_ids", "topic_ids"))], description("The list of fields you can expand for a [Space](#Space) object. If the field has an ID, it can be expanded into a full object."), example(["creator_id", "host_ids", "invited_user_ids", "speaker_ids", "topic_ids"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "LikeExpansionsParameter" {
    description = "A comma separated list of fields to expand."
    style = "form"
    name = "expansions"
    in = "query"
    schema = array([string(enum("liked_tweet_id", "liking_user_id"))], description("The list of fields you can expand for a [Like](#Like) object. If the field has an ID, it can be expanded into a full object."), example(["liked_tweet_id", "liking_user_id"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "MediaFieldsParameter" {
    schema = array([string(enum("alt_text", "duration_ms", "height", "media_key", "non_public_metrics", "organic_metrics", "preview_image_url", "promoted_metrics", "public_metrics", "type", "url", "variants", "width"))], description("The fields available for a Media object."), example(["alt_text", "duration_ms", "height", "media_key", "non_public_metrics", "organic_metrics", "preview_image_url", "promoted_metrics", "public_metrics", "type", "url", "variants", "width"]), minItems(1), uniqueItems(true))
    description = "A comma separated list of Media fields to display."
    style = "form"
    name = "media.fields"
    in = "query"
  }
  components "parameters" "TweetFieldsParameter" {
    name = "tweet.fields"
    in = "query"
    description = "A comma separated list of Tweet fields to display."
    style = "form"
    schema = array([string(enum("attachments", "author_id", "card_uri", "context_annotations", "conversation_id", "created_at", "edit_controls", "edit_history_tweet_ids", "entities", "geo", "id", "in_reply_to_user_id", "lang", "non_public_metrics", "note_tweet", "organic_metrics", "possibly_sensitive", "promoted_metrics", "public_metrics", "referenced_tweets", "reply_settings", "scopes", "source", "text", "withheld"))], description("The fields available for a Tweet object."), example(["attachments", "author_id", "card_uri", "context_annotations", "conversation_id", "created_at", "edit_controls", "edit_history_tweet_ids", "entities", "geo", "id", "in_reply_to_user_id", "lang", "non_public_metrics", "note_tweet", "organic_metrics", "possibly_sensitive", "promoted_metrics", "public_metrics", "referenced_tweets", "reply_settings", "scopes", "source", "text", "withheld"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "ComplianceJobFieldsParameter" {
    schema = array([string(enum("created_at", "download_expires_at", "download_url", "id", "name", "resumable", "status", "type", "upload_expires_at", "upload_url"))], description("The fields available for a ComplianceJob object."), example(["created_at", "download_expires_at", "download_url", "id", "name", "resumable", "status", "type", "upload_expires_at", "upload_url"]), minItems(1), uniqueItems(true))
    name = "compliance_job.fields"
    in = "query"
    description = "A comma separated list of ComplianceJob fields to display."
    style = "form"
  }
  components "parameters" "UserExpansionsParameter" {
    in = "query"
    description = "A comma separated list of fields to expand."
    style = "form"
    schema = array([string(enum("most_recent_tweet_id", "pinned_tweet_id"))], description("The list of fields you can expand for a [User](#User) object. If the field has an ID, it can be expanded into a full object."), example(["most_recent_tweet_id", "pinned_tweet_id"]), minItems(1), uniqueItems(true))
    name = "expansions"
  }
  components "parameters" "LikeFieldsParameter" {
    name = "like.fields"
    in = "query"
    description = "A comma separated list of Like fields to display."
    style = "form"
    schema = array([string(enum("created_at", "id", "liked_tweet_id", "liking_user_id", "timestamp_ms"))], description("The fields available for a Like object."), example(["created_at", "id", "liked_tweet_id", "liking_user_id", "timestamp_ms"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "PlaceFieldsParameter" {
    description = "A comma separated list of Place fields to display."
    schema = array([string(enum("contained_within", "country", "country_code", "full_name", "geo", "id", "name", "place_type"))], description("The fields available for a Place object."), example(["contained_within", "country", "country_code", "full_name", "geo", "id", "name", "place_type"]), minItems(1), uniqueItems(true))
    style = "form"
    name = "place.fields"
    in = "query"
  }
  components "parameters" "RulesCountFieldsParameter" {
    name = "rules_count.fields"
    in = "query"
    description = "A comma separated list of RulesCount fields to display."
    style = "form"
    schema = array([string(enum("all_project_client_apps", "cap_per_client_app", "cap_per_project", "client_app_rules_count", "project_rules_count"))], description("The fields available for a RulesCount object."), example(["all_project_client_apps", "cap_per_client_app", "cap_per_project", "client_app_rules_count", "project_rules_count"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "DmEventExpansionsParameter" {
    schema = array([string(enum("attachments.media_keys", "participant_ids", "referenced_tweets.id", "sender_id"))], description("The list of fields you can expand for a [DmEvent](#DmEvent) object. If the field has an ID, it can be expanded into a full object."), example(["attachments.media_keys", "participant_ids", "referenced_tweets.id", "sender_id"]), minItems(1), uniqueItems(true))
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
    style = "form"
  }
  components "parameters" "SearchCountFieldsParameter" {
    name = "search_count.fields"
    in = "query"
    description = "A comma separated list of SearchCount fields to display."
    style = "form"
    schema = array([string(enum("end", "start", "tweet_count"))], description("The fields available for a SearchCount object."), example(["end", "start", "tweet_count"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "TopicFieldsParameter" {
    description = "A comma separated list of Topic fields to display."
    style = "form"
    schema = array([string(enum("description", "id", "name"))], description("The fields available for a Topic object."), example(["description", "id", "name"]), minItems(1), uniqueItems(true))
    name = "topic.fields"
    in = "query"
  }
  components "parameters" "TweetExpansionsParameter" {
    description = "A comma separated list of fields to expand."
    style = "form"
    schema = array([string(enum("attachments.media_keys", "attachments.media_source_tweet", "attachments.poll_ids", "author_id", "edit_history_tweet_ids", "entities.mentions.username", "geo.place_id", "in_reply_to_user_id", "entities.note.mentions.username", "referenced_tweets.id", "referenced_tweets.id.author_id"))], description("The list of fields you can expand for a [Tweet](#Tweet) object. If the field has an ID, it can be expanded into a full object."), example(["attachments.media_keys", "attachments.media_source_tweet", "attachments.poll_ids", "author_id", "edit_history_tweet_ids", "entities.mentions.username", "geo.place_id", "in_reply_to_user_id", "entities.note.mentions.username", "referenced_tweets.id", "referenced_tweets.id.author_id"]), minItems(1), uniqueItems(true))
    name = "expansions"
    in = "query"
  }
  components "parameters" "DmEventFieldsParameter" {
    schema = array([string(enum("attachments", "created_at", "dm_conversation_id", "entities", "event_type", "id", "participant_ids", "referenced_tweets", "sender_id", "text"))], description("The fields available for a DmEvent object."), example(["attachments", "created_at", "dm_conversation_id", "entities", "event_type", "id", "participant_ids", "referenced_tweets", "sender_id", "text"]), minItems(1), uniqueItems(true))
    name = "dm_event.fields"
    in = "query"
    description = "A comma separated list of DmEvent fields to display."
    style = "form"
  }
  components "parameters" "DmConversationFieldsParameter" {
    name = "dm_conversation.fields"
    in = "query"
    description = "A comma separated list of DmConversation fields to display."
    style = "form"
    schema = array([string(enum("id"))], description("The fields available for a DmConversation object."), example(["id"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "ListFieldsParameter" {
    style = "form"
    schema = array([string(enum("created_at", "description", "follower_count", "id", "member_count", "name", "owner_id", "private"))], description("The fields available for a List object."), example(["created_at", "description", "follower_count", "id", "member_count", "name", "owner_id", "private"]), minItems(1), uniqueItems(true))
    name = "list.fields"
    in = "query"
    description = "A comma separated list of List fields to display."
  }
  components "parameters" "UserFieldsParameter" {
    name = "user.fields"
    in = "query"
    description = "A comma separated list of User fields to display."
    style = "form"
    schema = array([string(enum("connection_status", "created_at", "description", "entities", "id", "location", "most_recent_tweet_id", "name", "pinned_tweet_id", "profile_image_url", "protected", "public_metrics", "receives_your_dm", "subscription_type", "url", "username", "verified", "verified_type", "withheld"))], description("The fields available for a User object."), example(["connection_status", "created_at", "description", "entities", "id", "location", "most_recent_tweet_id", "name", "pinned_tweet_id", "profile_image_url", "protected", "public_metrics", "receives_your_dm", "subscription_type", "url", "username", "verified", "verified_type", "withheld"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "UsageFieldsParameter" {
    description = "A comma separated list of Usage fields to display."
    style = "form"
    name = "usage.fields"
    in = "query"
    schema = array([string(enum("cap_reset_day", "daily_client_app_usage", "daily_project_usage", "project_cap", "project_id", "project_usage"))], description("The fields available for a Usage object."), example(["cap_reset_day", "daily_client_app_usage", "daily_project_usage", "project_cap", "project_id", "project_usage"]), minItems(1), uniqueItems(true))
  }
  components "securityScheme" "OAuth2UserToken" {
    type = "oauth2"
    flows {
      authorizationCode {
        authorizationUrl = "https://api.twitter.com/2/oauth2/authorize"
        tokenUrl = "https://api.twitter.com/2/oauth2/token"
        scopes {
          space.read = "Access all of the Spaces you can see."
          tweet.write = "Tweet and retweet for you."
          bookmark.write = "Allows an app to create and delete bookmarks"
          like.read = "Tweets you’ve liked and likes you can view."
          tweet.moderate.write = "Hide and unhide replies to your Tweets."
          users.read = "Any account you can see, including protected accounts. Any account you can see, including protected accounts."
          like.write = "Like and un-like Tweets for you."
          list.write = "Create and manage Lists for you."
          tweet.read = "All the Tweets you can see, including Tweets from protected accounts."
          mute.write = "Mute and unmute accounts for you."
          offline.access = "App can request refresh token."
          bookmark.read = "Allows an app to read bookmarked Tweets"
          dm.read = "All your Direct Messages"
          block.read = "Accounts you’ve blocked."
          mute.read = "Accounts you’ve muted."
          follows.read = "People who follow you and people who you follow."
          dm.write = "Send and manage Direct Messages for you"
          follows.write = "Follow and unfollow people for you."
          list.read = "Lists, list members, and list followers of lists you’ve created or are a member of, including private lists."
        }
      }
    }
  }
  components "securityScheme" "UserToken" {
    scheme = "OAuth"
    type = "http"
  }
  components "securityScheme" "BearerToken" {
    type = "http"
    scheme = "bearer"
  }
