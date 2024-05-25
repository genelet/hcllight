
  tags = [{
    name = "Bookmarks",
    description = "Endpoints related to retrieving, managing bookmarks of a user",
    externalDocs = {
      url = "https://developer.twitter.com/en/docs/twitter-api/bookmarks",
      description = "Find out more"
    }
  }, {
    name = "Compliance",
    description = "Endpoints related to keeping X data in your systems compliant",
    externalDocs = {
      url = "https://developer.twitter.com/en/docs/twitter-api/compliance/batch-tweet/introduction",
      description = "Find out more"
    }
  }, {
    name = "Direct Messages",
    description = "Endpoints related to retrieving, managing Direct Messages",
    externalDocs = {
      url = "https://developer.twitter.com/en/docs/twitter-api/direct-messages",
      description = "Find out more"
    }
  }, {
    name = "General",
    description = "Miscellaneous endpoints for general API functionality",
    externalDocs = {
      description = "Find out more",
      url = "https://developer.twitter.com/en/docs/twitter-api"
    }
  }, {
    name = "Lists",
    description = "Endpoints related to retrieving, managing Lists",
    externalDocs = {
      url = "https://developer.twitter.com/en/docs/twitter-api/lists",
      description = "Find out more"
    }
  }, {
    description = "Endpoints related to retrieving, managing Spaces",
    name = "Spaces",
    externalDocs = {
      url = "https://developer.twitter.com/en/docs/twitter-api/spaces",
      description = "Find out more"
    }
  }, {
    description = "Endpoints related to retrieving, searching, and modifying Tweets",
    name = "Tweets",
    externalDocs = {
      url = "https://developer.twitter.com/en/docs/twitter-api/tweets/lookup",
      description = "Find out more"
    }
  }, {
    name = "Users",
    description = "Endpoints related to retrieving, managing relationships of Users",
    externalDocs = {
      url = "https://developer.twitter.com/en/docs/twitter-api/users/lookup",
      description = "Find out more"
    }
  }]
  openapi = "3.0.0"
  servers = [{
    url = "https://api.twitter.com",
    description = "Twitter API"
  }]
  info {
    title = "Twitter API v2"
    description = "Twitter API v2 available endpoints"
    termsOfService = "https://developer.twitter.com/en/developer-terms/agreement-and-policy.html"
    version = "2.98"
    contact {
      name = "Twitter Developers"
      url = "https://developer.twitter.com/"
    }
    license {
      name = "Twitter Developer Agreement and Policy"
      url = "https://developer.twitter.com/en/developer-terms/agreement-and-policy.html"
    }
  }
  paths "/2/dm_conversations/with/{participant_id}/messages" "post" {
    summary = "Send a new message to a user"
    description = "Creates a new message for a DM Conversation with a participant user by ID"
    operationId = "dmConversationWithUserEventIdCreate"
    tags = ["Direct Messages"]
    security = [{
      OAuth2UserToken = ["dm.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
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
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/tweets/search/stream/rules" "get" {
    summary = "Rules lookup"
    description = "Returns rules from a User's active rule set. Users can fetch all of their rules or a subset, specified by the provided rule ids."
    operationId = "getRules"
    tags = ["Tweets"]
    security = [{
      BearerToken = []
    }]
    parameters "ids" {
      in = "query"
      description = "A comma-separated list of Rule IDs."
      style = "form"
      schema = array([components.schemas.RuleId])
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(1000), minimum(1), maximum(1000))
    }
    parameters "pagination_token" {
      style = "form"
      in = "query"
      description = "This value is populated by passing the 'next_token' returned in a request to paginate through results."
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
    operationId = "addOrDeleteRules"
    tags = ["Tweets"]
    security = [{
      BearerToken = []
    }]
    summary = "Add/Delete rules"
    description = "Add or delete rules from a User's active rule set. Users can provide unique, optionally tagged rules to add. Users can delete their entire rule set or a subset specified by rule ids or values."
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
  paths "/2/tweets/{id}/liking_users" "get" {
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
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
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken36
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
  paths "/2/users/{id}/pinned_lists" "post" {
    description = "Causes a User to pin a List."
    operationId = "listUserPin"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Pin a List"
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
        schema = components.schemas.ListPinnedResponse
      }
    }
  }
  paths "/2/users/{id}/pinned_lists" "get" {
    description = "Get a User's Pinned Lists."
    operationId = "listUserPinnedLists"
    tags = ["Lists"]
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Get a User's Pinned Lists"
    parameters "id" {
      required = true
      description = "The ID of the authenticated source User for whom to return results."
      style = "simple"
      in = "path"
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
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/users/{id}/retweets/{source_tweet_id}" "delete" {
    operationId = "usersIdUnretweets"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["tweet.read", "tweet.write", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Causes the User (in the path) to unretweet the specified Post"
    description = "Causes the User (in the path) to unretweet the specified Post. The User must match the User context authorizing the request"
    parameters "id" {
      description = "The ID of the authenticated source User that is requesting to repost the Post."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
    }
    parameters "source_tweet_id" {
      in = "path"
      description = "The ID of the Post that the User is requesting to unretweet."
      schema = components.schemas.TweetId
      required = true
      style = "simple"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersRetweetsDeleteResponse
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
  paths "/2/tweets/sample/stream" "get" {
    summary = "Sample stream"
    description = "Streams a deterministic 1% of public Posts."
    operationId = "sampleStream"
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
  paths "/2/users/search" "get" {
    description = "Returns Users that match a search query."
    operationId = "searchUserByQuery"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "User search"
    parameters "query" {
      required = true
      in = "query"
      description = "TThe the query string by which to query for users."
      style = "form"
      example = "someXUser"
      schema = components.schemas.UserSearchQuery
    }
    parameters "max_results" {
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(1000))
      in = "query"
      description = "The maximum number of results."
    }
    parameters "next_token" {
      schema = components.schemas.PaginationToken36
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      in = "query"
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
  paths "/2/users/{id}/followed_lists" "get" {
    summary = "Get User's Followed Lists"
    description = "Returns a User's followed Lists."
    operationId = "userFollowedLists"
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
        schema = components.schemas.Get2UsersIdFollowedListsResponse
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
      description = "The ID of the authenticated source User that will follow the List."
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      style = "simple"
      in = "path"
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.ListFollowedRequest
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
        schema = components.schemas.ListFollowedResponse
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
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to mute the target User."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
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
      description = "The maximum number of results."
      style = "form"
      in = "query"
      schema = integer(format("int32"), default(100), minimum(1), maximum(1000))
    }
    parameters "pagination_token" {
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationTokenLong
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
        schema = components.schemas.Get2UsersIdMutingResponse
      }
    }
  }
  paths "/2/lists/{id}/tweets" "get" {
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
    summary = "List Posts timeline by List ID."
    parameters "id" {
      in = "path"
      description = "The ID of the List."
      style = "simple"
      schema = components.schemas.ListId
      required = true
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      description = "This parameter is used to get the next 'page' of results."
      schema = components.schemas.PaginationToken36
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
        schema = components.schemas.Get2ListsIdTweetsResponse
      }
    }
  }
  paths "/2/openapi.json" "get" {
    summary = "Returns the OpenAPI Specification document."
    description = "Full OpenAPI Specification in JSON format. (See https://github.com/OAI/OpenAPI-Specification/blob/master/README.md)"
    operationId = "getOpenApiSpec"
    tags = ["General"]
    responses "200" {
      description = "The request was successful"
      content "application/json" {
        schema = object()
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
    summary = "Space lookup up Space IDs"
    description = "Returns a variety of information about the Spaces specified by the requested IDs"
    operationId = "findSpacesByIds"
    tags = ["Spaces"]
    parameters "ids" {
      in = "query"
      description = "The list of Space IDs to return."
      schema = array(maxItems(100), minItems(1), [string(description("The unique identifier of this Space."), example("1SLjjRYNejbKM"), pattern("^[a-zA-Z0-9]{1,13}$"))])
      required = true
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
        schema = components.schemas.Get2SpacesResponse
      }
    }
  }
  paths "/2/users/{id}/following" "get" {
    summary = "Following by User ID"
    description = "Returns a list of Users that are being followed by the provided User ID"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["follows.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    operationId = "usersIdFollowing"
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
      schema = integer(format("int32"), minimum(1), maximum(1000))
      in = "query"
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
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/users/{id}/following" "post" {
    tags = ["Users"]
    security = [{
      OAuth2UserToken = ["follows.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Follow User"
    description = "Causes the User(in the path) to follow, or “request to follow” for protected Users, the target User. The User(in the path) must match the User context authorizing the request"
    operationId = "usersIdFollow"
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
  paths "/2/likes/compliance/stream" "get" {
    security = [{
      BearerToken = []
    }]
    description = "Streams 100% of compliance data for Users"
    operationId = "getLikesComplianceStream"
    summary = "Likes Compliance stream"
    tags = ["Compliance"]
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Likes Compliance events will be provided."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      in = "query"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp from which the Likes Compliance events will be provided."
      style = "form"
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
  paths "/2/tweets/firehose/stream/lang/pt" "get" {
    summary = "Portuguese Language Firehose stream"
    description = "Streams 100% of Portuguese Language public Posts."
    operationId = "getTweetsFirehoseStreamLangPt"
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
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(2))
    }
    parameters "start_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
    }
    parameters "end_time" {
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
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
  paths "/2/tweets/{id}/retweeted_by" "get" {
    summary = "Returns User objects that have retweeted the provided Post ID"
    description = "Returns a list of Users that have retweeted the provided Post ID"
    operationId = "tweetsIdRetweetingUsers"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      style = "simple"
      in = "path"
      schema = components.schemas.TweetId
      required = true
      description = "A single Post ID."
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
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsIdRetweetedByResponse
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
  paths "/2/users/{id}/liked_tweets" "get" {
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["like.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Returns a list of Posts liked by the provided User ID"
    operationId = "usersIdLikedTweets"
    summary = "Returns Post objects liked by the provided User ID"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
      schema = components.schemas.UserId
    }
    parameters "max_results" {
      schema = integer(format("int32"), minimum(5), maximum(100))
      style = "form"
      in = "query"
      description = "The maximum number of results."
    }
    parameters "pagination_token" {
      schema = components.schemas.PaginationToken36
      style = "form"
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
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
        schema = components.schemas.Get2UsersIdLikedTweetsResponse
      }
    }
  }
  paths "/2/users/{source_user_id}/following/{target_user_id}" "delete" {
    security = [{
      OAuth2UserToken = ["follows.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Unfollow User"
    description = "Causes the source User to unfollow the target User. The source User must match the User context authorizing the request"
    operationId = "usersIdUnfollow"
    tags = ["Users"]
    parameters "source_user_id" {
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to unfollow the target User."
      style = "simple"
    }
    parameters "target_user_id" {
      required = true
      in = "path"
      description = "The ID of the User that the source User is requesting to unfollow."
      style = "simple"
      schema = components.schemas.UserId
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
        schema = components.schemas.UsersFollowingDeleteResponse
      }
    }
  }
  paths "/2/users/{source_user_id}/muting/{target_user_id}" "delete" {
    description = "Causes the source User to unmute the target User. The source User must match the User context authorizing the request"
    operationId = "usersIdUnmute"
    summary = "Unmute User by User ID"
    tags = ["Users"]
    security = [{
      OAuth2UserToken = ["mute.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "source_user_id" {
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to unmute the target User."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "target_user_id" {
      description = "The ID of the User that the source User is requesting to unmute."
      style = "simple"
      schema = components.schemas.UserId
      required = true
      in = "path"
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
  paths "/2/dm_conversations/with/{participant_id}/dm_events" "get" {
    security = [{
      OAuth2UserToken = ["dm.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Returns DM Events for a DM Conversation"
    operationId = "getDmConversationsWithParticipantIdDmEvents"
    summary = "Get DM Events for a DM Conversation"
    tags = ["Direct Messages"]
    parameters = [components.parameters.DmEventFieldsParameter, components.parameters.DmEventExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.TweetFieldsParameter]
    parameters "participant_id" {
      style = "simple"
      schema = components.schemas.UserId
      required = true
      in = "path"
      description = "The ID of the participant user for the One to One DM conversation."
    }
    parameters "max_results" {
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      in = "query"
      description = "The maximum number of results."
      style = "form"
    }
    parameters "pagination_token" {
      style = "form"
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      schema = components.schemas.PaginationToken32
    }
    parameters "event_types" {
      in = "query"
      description = "The set of event_types to include in the results."
      schema = array(example(["MessageCreate", "ParticipantsLeave"]), minItems(1), uniqueItems(true), [string(enum("MessageCreate", "ParticipantsJoin", "ParticipantsLeave"))])
      style = "form"
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
  paths "/2/likes/sample10/stream" "get" {
    description = "Streams 10% of public Likes."
    tags = ["Likes"]
    parameters = [components.parameters.LikeFieldsParameter, components.parameters.LikeExpansionsParameter, components.parameters.TweetFieldsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }]
    operationId = "likesSample10Stream"
    summary = "Likes Sample 10 stream"
    parameters "backfill_minutes" {
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
      in = "query"
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
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Likes will be provided."
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
        schema = components.schemas.StreamingLikeResponse
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/usage/tweets" "get" {
    description = "Returns the Post Usage."
    operationId = "getUsageTweets"
    tags = ["Usage"]
    parameters = [components.parameters.UsageFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Post Usage"
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
  paths "/2/tweets/{id}" "get" {
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Post lookup by Post ID"
    description = "Returns a variety of information about the Post specified by the requested ID."
    operationId = "findTweetById"
    tags = ["Tweets"]
    parameters "id" {
      required = true
      in = "path"
      description = "A single Post ID."
      style = "simple"
      schema = components.schemas.TweetId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsIdResponse
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
  paths "/2/tweets/{id}" "delete" {
    operationId = "deleteTweetById"
    summary = "Post delete by Post ID"
    description = "Delete specified Post (in the path) by ID."
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
  paths "/2/users" "get" {
    operationId = "findUsersById"
    summary = "User lookup by IDs"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "This endpoint returns information about Users. Specify Users by their ID."
    parameters "ids" {
      required = true
      in = "query"
      description = "A list of User IDs, comma-separated. You can specify up to 100 IDs."
      style = "form"
      example = "2244994945,6253282,12"
      schema = array(maxItems(100), minItems(1), [components.schemas.UserId])
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
  paths "/2/users/{id}/followed_lists/{list_id}" "delete" {
    summary = "Unfollow a List"
    description = "Causes a User to unfollow a List."
    operationId = "listUserUnfollow"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      in = "path"
      description = "The ID of the authenticated source User that will unfollow the List."
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      style = "simple"
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
  paths "/2/users/{id}/tweets" "get" {
    summary = "User Posts timeline by User ID"
    description = "Returns a list of Posts authored by the provided User ID"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    operationId = "usersIdTweets"
    parameters "id" {
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
      schema = components.schemas.UserId
      required = true
    }
    parameters "since_id" {
      in = "query"
      description = "The minimum Post ID to be included in the result set. This parameter takes precedence over start_time if both are specified."
      style = "form"
      example = ""791775337160081409""
      schema = components.schemas.TweetId
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
      in = "query"
      description = "The set of entities to exclude (e.g. 'replies' or 'retweets')."
      style = "form"
      schema = array(example(["replies", "retweets"]), minItems(1), uniqueItems(true), [string(enum("replies", "retweets"))])
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided. The since_id parameter takes precedence if it is also specified."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
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
        schema = components.schemas.Get2UsersIdTweetsResponse
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
  paths "/2/dm_events/{event_id}" "get" {
    parameters = [components.parameters.DmEventFieldsParameter, components.parameters.DmEventExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["dm.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Get DM Events by id"
    description = "Returns DM Events by event id."
    operationId = "getDmEventsById"
    tags = ["Direct Messages"]
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
    security = [{
      OAuth2UserToken = ["dm.read", "dm.write"]
    }, {
      UserToken = []
    }]
    operationId = "dmEventDelete"
    summary = "Delete Dm"
    description = "Delete a Dm Event that you own."
    tags = ["Direct Messages"]
    parameters "event_id" {
      style = "simple"
      in = "path"
      schema = components.schemas.DmEventId
      required = true
      description = "The ID of the direct-message event to delete."
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
        schema = components.schemas.DeleteDmResponse
      }
    }
  }
  paths "/2/tweets/firehose/stream" "get" {
    security = [{
      BearerToken = []
    }]
    summary = "Firehose stream"
    description = "Streams 100% of public Posts."
    operationId = "getTweetsFirehoseStream"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    parameters "backfill_minutes" {
      schema = integer(format("int32"), maximum(5))
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
    }
    parameters "partition" {
      required = true
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(20))
    }
    parameters "start_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      in = "query"
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
      schema = string(format("date-time"))
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      in = "query"
      example = ""2021-02-14T18:40:40.000Z""
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
  paths "/2/users/{id}/bookmarks/{tweet_id}" "delete" {
    tags = ["Bookmarks"]
    security = [{
      OAuth2UserToken = ["bookmark.write", "tweet.read", "users.read"]
    }]
    summary = "Remove a bookmarked Post"
    description = "Removes a Post from the requesting User's bookmarked Posts."
    operationId = "usersIdBookmarksDelete"
    parameters "id" {
      in = "path"
      description = "The ID of the authenticated source User whose bookmark is to be removed."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
    }
    parameters "tweet_id" {
      in = "path"
      description = "The ID of the Post that the source User is removing from bookmarks."
      style = "simple"
      schema = components.schemas.TweetId
      required = true
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.BookmarkMutationResponse
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
      description = "The ID of the authenticated source User that is requesting to repost the Post."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.UsersRetweetsCreateRequest
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
        schema = components.schemas.UsersRetweetsCreateResponse
      }
    }
  }
  paths "/2/compliance/jobs" "post" {
    description = "Creates a compliance for the given job type"
    operationId = "createBatchComplianceJob"
    tags = ["Compliance"]
    security = [{
      BearerToken = []
    }]
    summary = "Create compliance job"
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
      description = "Type of Compliance Job to list."
      style = "form"
      schema = string(enum("tweets", "users"))
      required = true
      in = "query"
    }
    parameters "status" {
      description = "Status of Compliance Job to list."
      style = "form"
      in = "query"
      schema = string(enum("created", "in_progress", "failed", "complete"))
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
  paths "/2/tweets/{tweet_id}/hidden" "put" {
    operationId = "hideReplyById"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["tweet.moderate.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Hide replies"
    description = "Hides or unhides a reply to an owned conversation."
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
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.TweetHideResponse
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
  paths "/2/users/me" "get" {
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "User lookup me"
    description = "This endpoint returns information about the requesting User."
    operationId = "findMyUser"
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
  paths "/2/dm_conversations" "post" {
    tags = ["Direct Messages"]
    security = [{
      OAuth2UserToken = ["dm.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Creates a new DM Conversation."
    operationId = "dmConversationIdCreate"
    summary = "Create a new DM Conversation"
    requestBody {
      content "application/json" {
        schema = components.schemas.CreateDmConversationRequest
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
  paths "/2/lists/{id}/members/{user_id}" "delete" {
    operationId = "listRemoveMember"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Remove a List member"
    description = "Causes a User to be removed from the members of a List."
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the List to remove a member."
      style = "simple"
      schema = components.schemas.ListId
    }
    parameters "user_id" {
      description = "The ID of User that will be removed from the List."
      style = "simple"
      schema = components.schemas.UserId
      required = true
      in = "path"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListMutateResponse
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
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    operationId = "spaceBuyers"
    summary = "Retrieve the list of Users who purchased a ticket to the given space"
    description = "Retrieves the list of Users who purchased a ticket to the given space"
    tags = ["Spaces", "Tweets"]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the Space to be retrieved."
      style = "simple"
      example = "1YqKDqWqdPLsV"
      schema = string(description("The unique identifier of this Space."), example("1SLjjRYNejbKM"), pattern("^[a-zA-Z0-9]{1,13}$"))
    }
    parameters "pagination_token" {
      style = "form"
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      schema = components.schemas.PaginationToken32
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesIdBuyersResponse
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
  paths "/2/tweets/firehose/stream/lang/ko" "get" {
    summary = "Korean Language Firehose stream"
    description = "Streams 100% of Korean Language public Posts."
    operationId = "getTweetsFirehoseStreamLangKo"
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
      schema = integer(format("int32"), minimum(1), maximum(2))
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
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
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
  paths "/2/users/{id}/likes/{tweet_id}" "delete" {
    description = "Causes the User (in the path) to unlike the specified Post. The User must match the User context authorizing the request"
    operationId = "usersIdUnlike"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["like.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Causes the User (in the path) to unlike the specified Post"
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to unlike the Post."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "tweet_id" {
      required = true
      in = "path"
      description = "The ID of the Post that the User is requesting to unlike."
      style = "simple"
      schema = components.schemas.TweetId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersLikesDeleteResponse
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
  paths "/2/spaces/by/creator_ids" "get" {
    description = "Returns a variety of information about the Spaces created by the provided User IDs"
    operationId = "findSpacesByCreatorIds"
    summary = "Space lookup by their creators"
    tags = ["Spaces"]
    parameters = [components.parameters.SpaceFieldsParameter, components.parameters.SpaceExpansionsParameter, components.parameters.UserFieldsParameter, components.parameters.TopicFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    parameters "user_ids" {
      description = "The IDs of Users to search through."
      style = "form"
      schema = array(maxItems(100), minItems(1), [components.schemas.UserId])
      required = true
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
        schema = components.schemas.Get2SpacesByCreatorIdsResponse
      }
    }
  }
  paths "/2/tweets/counts/all" "get" {
    parameters = [components.parameters.SearchCountFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Full archive search counts"
    description = "Returns Post Counts that match a search query."
    operationId = "tweetCountsFullArchiveSearch"
    tags = ["Tweets"]
    parameters "query" {
      required = true
      style = "form"
      in = "query"
      description = "One query/rule/filter for matching Posts. Refer to https://t.co/rulelength to identify the max query length."
      schema = string(example("(from:TwitterDev OR from:TwitterAPI) has:media -is:retweet"), maxLength(4096), minLength(1))
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The oldest UTC timestamp (from most recent 7 days) from which the Posts will be provided. Timestamp is in second granularity and is inclusive (i.e. 12:00:01 includes the first second of the minute)."
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
    parameters "next_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "pagination_token" {
      style = "form"
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
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
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/counts/recent" "get" {
    description = "Returns Post Counts from the last 7 days that match a search query."
    operationId = "tweetCountsRecentSearch"
    tags = ["Tweets"]
    parameters = [components.parameters.SearchCountFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Recent search counts"
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
      in = "query"
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      style = "form"
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The newest, most recent UTC timestamp to which the Posts will be provided. Timestamp is in second granularity and is exclusive (i.e. 12:00:01 excludes the first second of the minute)."
    }
    parameters "since_id" {
      description = "Returns results with a Post ID greater than (that is, more recent than) the specified ID."
      style = "form"
      schema = components.schemas.TweetId
      in = "query"
    }
    parameters "until_id" {
      schema = components.schemas.TweetId
      style = "form"
      in = "query"
      description = "Returns results with a Post ID less than (that is, older than) the specified ID."
    }
    parameters "next_token" {
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      in = "query"
      schema = components.schemas.PaginationToken36
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
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
  paths "/2/tweets/search/stream" "get" {
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    operationId = "searchStream"
    summary = "Filtered stream"
    description = "Streams Posts matching the stream's active rule set."
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      style = "form"
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
  paths "/2/users/by" "get" {
    description = "This endpoint returns information about Users. Specify Users by their username."
    operationId = "findUsersByUsername"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "User lookup by usernames"
    parameters "usernames" {
      required = true
      in = "query"
      description = "A list of usernames, comma-separated."
      style = "form"
      schema = array(example("TwitterDev,TwitterAPI
"), maxItems(100), minItems(1), [string(description("The X handle (screen name) of this User."), pattern("^[A-Za-z0-9_]{1,15}$"))])
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
  paths "/2/users/compliance/stream" "get" {
    security = [{
      BearerToken = []
    }]
    operationId = "getUsersComplianceStream"
    summary = "Users Compliance stream"
    description = "Streams 100% of compliance data for Users"
    tags = ["Compliance"]
    parameters "backfill_minutes" {
      schema = integer(format("int32"), maximum(5))
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
    }
    parameters "partition" {
      required = true
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(4))
    }
    parameters "start_time" {
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the User Compliance events will be provided."
      style = "form"
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp from which the User Compliance events will be provided."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
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
        schema = components.schemas.UserComplianceStreamResponse
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/users/{id}/likes" "post" {
    security = [{
      OAuth2UserToken = ["like.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Causes the User (in the path) to like the specified Post. The User in the path must match the User context authorizing the request."
    operationId = "usersIdLike"
    summary = "Causes the User (in the path) to like the specified Post"
    tags = ["Tweets"]
    parameters "id" {
      in = "path"
      description = "The ID of the authenticated source User that is requesting to like the Post."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
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
      in = "path"
      description = "The DM Conversation ID."
      style = "simple"
      schema = string()
      required = true
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
  paths "/2/spaces/{id}" "get" {
    description = "Returns a variety of information about the Space specified by the requested ID"
    operationId = "findSpaceById"
    summary = "Space lookup by Space ID"
    tags = ["Spaces"]
    parameters = [components.parameters.SpaceFieldsParameter, components.parameters.SpaceExpansionsParameter, components.parameters.UserFieldsParameter, components.parameters.TopicFieldsParameter]
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
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesIdResponse
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
    operationId = "getTrends"
    tags = ["Trends"]
    parameters = [components.parameters.TrendFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Trends"
    description = "Returns the Trend associated with the supplied WoeId."
    parameters "woeid" {
      required = true
      in = "path"
      description = "The WOEID of the place to lookup a trend for."
      style = "simple"
      example = ""2244994945""
      schema = integer(format("int32"))
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
  paths "/2/users/{id}/list_memberships" "get" {
    tags = ["Lists"]
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    operationId = "getUserListMemberships"
    summary = "Get a User's List Memberships"
    description = "Get a User's List Memberships."
    parameters "id" {
      description = "The ID of the User to lookup."
      style = "simple"
      in = "path"
      example = ""2244994945""
      schema = components.schemas.UserId
      required = true
    }
    parameters "max_results" {
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      style = "form"
      in = "query"
      description = "The maximum number of results."
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
        schema = components.schemas.Get2UsersIdListMembershipsResponse
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
    summary = "Returns User objects that are members of a List by the provided List ID."
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
    summary = "Add a List member"
    description = "Causes a User to become a member of a List."
    operationId = "listAddMember"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      description = "The ID of the List for which to add a member."
      style = "simple"
      schema = components.schemas.ListId
      required = true
      in = "path"
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
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/firehose/stream/lang/en" "get" {
    summary = "English Language Firehose stream"
    description = "Streams 100% of English Language public Posts."
    operationId = "getTweetsFirehoseStreamLangEn"
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
      in = "query"
      schema = integer(format("int32"), minimum(1), maximum(8))
      required = true
      description = "The partition number."
      style = "form"
    }
    parameters "start_time" {
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
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
  paths "/2/tweets/{id}/quote_tweets" "get" {
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Retrieve Posts that quote a Post."
    description = "Returns a variety of information about each Post that quotes the Post specified by the requested ID."
    operationId = "findTweetsThatQuoteATweet"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    parameters "id" {
      required = true
      in = "path"
      description = "A single Post ID."
      style = "simple"
      schema = components.schemas.TweetId
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results to be returned."
      schema = integer(format("int32"), default(10), minimum(10), maximum(100))
      style = "form"
    }
    parameters "pagination_token" {
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      in = "query"
      schema = components.schemas.PaginationToken36
    }
    parameters "exclude" {
      in = "query"
      description = "The set of entities to exclude (e.g. 'replies' or 'retweets')."
      style = "form"
      schema = array(example(["replies", "retweets"]), minItems(1), uniqueItems(true), [string(enum("replies", "retweets"))])
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
  paths "/2/spaces/search" "get" {
    summary = "Search for Spaces"
    description = "Returns Spaces that match the provided query."
    operationId = "searchSpaces"
    tags = ["Spaces"]
    parameters = [components.parameters.SpaceFieldsParameter, components.parameters.SpaceExpansionsParameter, components.parameters.UserFieldsParameter, components.parameters.TopicFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    parameters "query" {
      in = "query"
      description = "The search query."
      example = "crypto"
      schema = string(example("crypto"), maxLength(2048), minLength(1))
      required = true
      style = "form"
    }
    parameters "state" {
      schema = string(default("all"), enum("live", "scheduled", "all"))
      in = "query"
      description = "The state of Spaces to search for."
      style = "form"
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
      in = "query"
      description = "The number of Posts to fetch from the provided space. If not provided, the value will default to the maximum of 100."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesIdTweetsResponse
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
  paths "/2/tweets" "get" {
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    operationId = "findTweetsById"
    summary = "Post lookup by Post IDs"
    description = "Returns a variety of information about the Post specified by the requested ID."
    parameters "ids" {
      description = "A comma separated list of Post IDs. Up to 100 are allowed in a single request."
      style = "form"
      schema = array(maxItems(100), minItems(1), [components.schemas.TweetId])
      required = true
      in = "query"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsResponse
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
  paths "/2/tweets" "post" {
    description = "Causes the User to create a Post under the authorized account."
    operationId = "createTweet"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["tweet.read", "tweet.write", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Creation of a Post"
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
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/label/stream" "get" {
    description = "Streams 100% of labeling events applied to Posts"
    operationId = "getTweetsLabelStream"
    summary = "Posts Label stream"
    tags = ["Compliance"]
    security = [{
      BearerToken = []
    }]
    parameters "backfill_minutes" {
      schema = integer(format("int32"), maximum(5))
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
    }
    parameters "start_time" {
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Post labels will be provided."
      style = "form"
    }
    parameters "end_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp from which the Post labels will be provided."
      style = "form"
      in = "query"
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
  paths "/2/tweets/search/stream/rules/counts" "get" {
    operationId = "getRuleCount"
    tags = ["General"]
    parameters = [components.parameters.RulesCountFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Rules Count"
    description = "Returns the counts of rules from a User's active rule set, to reflect usage by project and application."
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
        schema = components.schemas.Get2TweetsSearchStreamRulesCountsResponse
      }
    }
  }
  paths "/2/compliance/jobs/{id}" "get" {
    description = "Returns a single Compliance Job by ID"
    operationId = "getBatchComplianceJob"
    tags = ["Compliance"]
    parameters = [components.parameters.ComplianceJobFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Get Compliance Job"
    parameters "id" {
      schema = components.schemas.JobId
      required = true
      in = "path"
      description = "The ID of the Compliance Job to retrieve."
      style = "simple"
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
    summary = "Create List"
    description = "Creates a new List."
    operationId = "listIdCreate"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.read", "list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
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
      description = "The ID of the List."
      style = "simple"
      schema = components.schemas.ListId
      required = true
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
        schema = components.schemas.Get2ListsIdResponse
      }
    }
  }
  paths "/2/lists/{id}" "put" {
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Update List."
    description = "Update a List that you own."
    operationId = "listIdUpdate"
    tags = ["Lists"]
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
        schema = components.schemas.ListUpdateResponse
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
      schema = components.schemas.ListId
      required = true
      in = "path"
      description = "The ID of the List to delete."
      style = "simple"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListDeleteResponse
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
  paths "/2/users/{id}/blocking" "get" {
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["block.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Returns User objects that are blocked by provided User ID"
    description = "Returns a list of Users that are blocked by the provided User ID"
    operationId = "usersIdBlocking"
    tags = ["Users"]
    parameters "id" {
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User for whom to return results."
      style = "simple"
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      schema = integer(format("int32"), minimum(1), maximum(1000))
      style = "form"
    }
    parameters "pagination_token" {
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      in = "query"
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
      style = "form"
      schema = components.schemas.PaginationTokenLong
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2ListsIdFollowersResponse
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
  paths "/2/tweets/search/recent" "get" {
    description = "Returns Posts from the last 7 days that match a search query."
    operationId = "tweetsRecentSearch"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Recent search"
    parameters "query" {
      required = true
      description = "One query/rule/filter for matching Posts. Refer to https://t.co/rulelength to identify the max query length."
      style = "form"
      in = "query"
      schema = string(example("(from:TwitterDev OR from:TwitterAPI) has:media -is:retweet"), maxLength(4096), minLength(1))
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The oldest UTC timestamp from which the Posts will be provided. Timestamp is in second granularity and is inclusive (i.e. 12:00:01 includes the first second of the minute)."
      style = "form"
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The newest, most recent UTC timestamp to which the Posts will be provided. Timestamp is in second granularity and is exclusive (i.e. 12:00:01 excludes the first second of the minute)."
      style = "form"
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
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "pagination_token" {
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
    }
    parameters "sort_order" {
      schema = string(enum("recency", "relevancy"))
      in = "query"
      description = "This order in which to return results."
      style = "form"
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
  paths "/2/users/{id}" "get" {
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    operationId = "findUserById"
    summary = "User lookup by ID"
    description = "This endpoint returns information about a User. Specify User by ID."
    parameters "id" {
      schema = components.schemas.UserId
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
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
  paths "/2/tweets/search/all" "get" {
    operationId = "tweetsFullarchiveSearch"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Full-archive search"
    description = "Returns Posts that match a search query."
    parameters "query" {
      in = "query"
      schema = string(example("(from:TwitterDev OR from:TwitterAPI) has:media -is:retweet"), maxLength(4096), minLength(1))
      required = true
      description = "One query/rule/filter for matching Posts. Refer to https://t.co/rulelength to identify the max query length."
      style = "form"
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The oldest UTC timestamp from which the Posts will be provided. Timestamp is in second granularity and is inclusive (i.e. 12:00:01 includes the first second of the minute)."
      style = "form"
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The newest, most recent UTC timestamp to which the Posts will be provided. Timestamp is in second granularity and is exclusive (i.e. 12:00:01 excludes the first second of the minute)."
      schema = string(format("date-time"))
      style = "form"
      in = "query"
    }
    parameters "since_id" {
      schema = components.schemas.TweetId
      description = "Returns results with a Post ID greater than (that is, more recent than) the specified ID."
      style = "form"
      in = "query"
    }
    parameters "until_id" {
      description = "Returns results with a Post ID less than (that is, older than) the specified ID."
      schema = components.schemas.TweetId
      style = "form"
      in = "query"
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of search results to be returned by a request."
      style = "form"
      schema = integer(format("int32"), default(10), minimum(10), maximum(500))
    }
    parameters "next_token" {
      style = "form"
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      schema = components.schemas.PaginationToken36
    }
    parameters "pagination_token" {
      style = "form"
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
    }
    parameters "sort_order" {
      in = "query"
      description = "This order in which to return results."
      style = "form"
      schema = string(enum("recency", "relevancy"))
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
        schema = components.schemas.Get2TweetsSearchAllResponse
      }
    }
  }
  paths "/2/users/by/username/{username}" "get" {
    summary = "User lookup by username"
    description = "This endpoint returns information about a User. Specify User by username."
    operationId = "findUserByUsername"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "username" {
      description = "A username."
      style = "simple"
      example = "TwitterDev"
      schema = string(pattern("^[A-Za-z0-9_]{1,15}$"))
      required = true
      in = "path"
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
  paths "/2/users/{id}/bookmarks" "get" {
    summary = "Bookmarks by User"
    description = "Returns Post objects that have been bookmarked by the requesting User"
    operationId = "getUsersIdBookmarks"
    tags = ["Bookmarks"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      OAuth2UserToken = ["bookmark.read", "tweet.read", "users.read"]
    }]
    parameters "id" {
      description = "The ID of the authenticated source User for whom to return results."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
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
    summary = "Add Post to Bookmarks"
    description = "Adds a Post (ID in the body) to the requesting User's (in the path) bookmarks"
    operationId = "postUsersIdBookmarks"
    tags = ["Bookmarks"]
    security = [{
      OAuth2UserToken = ["bookmark.write", "tweet.read", "users.read"]
    }]
    parameters "id" {
      required = true
      description = "The ID of the authenticated source User for whom to add bookmarks."
      style = "simple"
      in = "path"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
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
  paths "/2/users/{id}/mentions" "get" {
    summary = "User mention timeline by User ID"
    description = "Returns Post objects that mention username associated to the provided User ID"
    operationId = "usersIdMentions"
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
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
      schema = components.schemas.UserId
      required = true
    }
    parameters "since_id" {
      in = "query"
      description = "The minimum Post ID to be included in the result set. This parameter takes precedence over start_time if both are specified."
      style = "form"
      schema = components.schemas.TweetId
    }
    parameters "until_id" {
      description = "The maximum Post ID to be included in the result set. This parameter takes precedence over end_time if both are specified."
      style = "form"
      example = ""1346889436626259968""
      schema = components.schemas.TweetId
      in = "query"
    }
    parameters "max_results" {
      description = "The maximum number of results."
      style = "form"
      in = "query"
      schema = integer(format("int32"), minimum(5), maximum(100))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "start_time" {
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided. The since_id parameter takes precedence if it is also specified."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
    }
    parameters "end_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided. The until_id parameter takes precedence if it is also specified."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
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
      in = "path"
      description = "The ID of the authenticated source User to list Reverse Chronological Timeline Posts of."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "since_id" {
      schema = components.schemas.TweetId
      in = "query"
      description = "The minimum Post ID to be included in the result set. This parameter takes precedence over start_time if both are specified."
      style = "form"
      example = ""791775337160081409""
    }
    parameters "until_id" {
      schema = components.schemas.TweetId
      style = "form"
      in = "query"
      description = "The maximum Post ID to be included in the result set. This parameter takes precedence over end_time if both are specified."
      example = ""1346889436626259968""
    }
    parameters "max_results" {
      style = "form"
      in = "query"
      description = "The maximum number of results."
      schema = integer(format("int32"), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "exclude" {
      style = "form"
      schema = array(example(["replies", "retweets"]), uniqueItems(true), [string(enum("replies", "retweets"))])
      in = "query"
      description = "The set of entities to exclude (e.g. 'replies' or 'retweets')."
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided. The since_id parameter takes precedence if it is also specified."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided. The until_id parameter takes precedence if it is also specified."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
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
        schema = components.schemas.Get2UsersIdTimelinesReverseChronologicalResponse
      }
    }
  }
  paths "/2/dm_conversations/{id}/dm_events" "get" {
    operationId = "getDmConversationsIdDmEvents"
    summary = "Get DM Events for a DM Conversation"
    description = "Returns DM Events for a DM Conversation"
    tags = ["Direct Messages"]
    parameters = [components.parameters.DmEventFieldsParameter, components.parameters.DmEventExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["dm.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The DM Conversation ID."
      style = "simple"
      schema = components.schemas.DmConversationId
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
      schema = components.schemas.PaginationToken32
    }
    parameters "event_types" {
      in = "query"
      schema = array(example(["MessageCreate", "ParticipantsLeave"]), minItems(1), uniqueItems(true), [string(enum("MessageCreate", "ParticipantsJoin", "ParticipantsLeave"))])
      description = "The set of event_types to include in the results."
      style = "form"
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
  paths "/2/likes/firehose/stream" "get" {
    security = [{
      BearerToken = []
    }]
    summary = "Likes Firehose stream"
    description = "Streams 100% of public Likes."
    operationId = "likesFirehoseStream"
    tags = ["Likes"]
    parameters = [components.parameters.LikeFieldsParameter, components.parameters.LikeExpansionsParameter, components.parameters.TweetFieldsParameter, components.parameters.UserFieldsParameter]
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
      schema = integer(format("int32"), minimum(1), maximum(20))
    }
    parameters "start_time" {
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Likes will be provided."
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
        schema = components.schemas.StreamingLikeResponse
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
  paths "/2/tweets/compliance/stream" "get" {
    summary = "Posts Compliance stream"
    description = "Streams 100% of compliance data for Posts"
    operationId = "getTweetsComplianceStream"
    tags = ["Compliance"]
    security = [{
      BearerToken = []
    }]
    parameters "backfill_minutes" {
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
      in = "query"
    }
    parameters "partition" {
      required = true
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(4))
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Post Compliance events will be provided."
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
      style = "form"
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Post Compliance events will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
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
  paths "/2/users/{id}/followers" "get" {
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["follows.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Followers by User ID"
    description = "Returns a list of Users who are followers of the specified User ID."
    operationId = "usersIdFollowers"
    tags = ["Users"]
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
      schema = integer(format("int32"), minimum(1), maximum(1000))
      in = "query"
      description = "The maximum number of results."
    }
    parameters "pagination_token" {
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken32
      in = "query"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdFollowersResponse
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
      example = ""2244994945""
      schema = components.schemas.UserId
      required = true
      style = "simple"
      in = "path"
      description = "The ID of the User to lookup."
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
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User for whom to return results."
    }
    parameters "list_id" {
      required = true
      description = "The ID of the List to unpin."
      style = "simple"
      in = "path"
      schema = components.schemas.ListId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListUnpinResponse
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
  paths "/2/dm_events" "get" {
    security = [{
      OAuth2UserToken = ["dm.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Returns recent DM Events across DM conversations"
    operationId = "getDmEvents"
    summary = "Get recent DM Events"
    tags = ["Direct Messages"]
    parameters = [components.parameters.DmEventFieldsParameter, components.parameters.DmEventExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.TweetFieldsParameter]
    parameters "max_results" {
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      in = "query"
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken32
    }
    parameters "event_types" {
      in = "query"
      description = "The set of event_types to include in the results."
      style = "form"
      schema = array(example(["MessageCreate", "ParticipantsLeave"]), minItems(1), uniqueItems(true), [string(enum("MessageCreate", "ParticipantsJoin", "ParticipantsLeave"))])
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
        schema = components.schemas.Get2DmEventsResponse
      }
    }
  }
  paths "/2/tweets/sample10/stream" "get" {
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Sample 10% stream"
    description = "Streams a deterministic 10% of public Posts."
    operationId = "getTweetsSample10Stream"
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
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
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
  paths "/2/tweets/{id}/retweets" "get" {
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
    summary = "Retrieve Posts that repost a Post."
    description = "Returns a variety of information about each Post that has retweeted the Post specified by the requested ID."
    parameters "id" {
      style = "simple"
      schema = components.schemas.TweetId
      required = true
      in = "path"
      description = "A single Post ID."
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
  components "schemas" "Position" {
    minItems = 2
    maxItems = 2
    items = [number()]
    type = "array"
    description = "A [GeoJson Position](https://tools.ietf.org/html/rfc7946#section-3.1.1) in the format `[longitude,latitude]`."
    example = ["-105.18816086351444", "40.247749999999996"]
  }
  components "schemas" "TweetWithheld" {
    type = "object"
    description = "Indicates withholding details for [withheld content](https://help.twitter.com/en/rules-and-policies/tweet-withheld-by-country)."
    required = ["copyright", "country_codes"]
    properties {
      scope = string(description("Indicates whether the content being withheld is the `tweet` or a `user`."), enum("tweet", "user"))
      copyright = boolean(description("Indicates if the content is being withheld for on the basis of copyright infringement."))
      country_codes = array(description("Provides a list of countries where this content is not available."), minItems(1), uniqueItems(true), [components.schemas.CountryCode])
    }
  }
  components "schemas" "Get2TweetsFirehoseStreamLangPtResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2TweetsIdRetweetedByResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "DownloadUrl" {
    format = "uri"
    description = "URL from which the user will retrieve their compliance results."
    type = "string"
  }
  components "schemas" "Get2TweetsSearchStreamRulesCountsResponse" {
    type = "object"
    properties {
      data = components.schemas.RulesCount
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "NextToken" {
    type = "string"
    description = "The next token."
    minLength = 1
  }
  components "schemas" "CreateComplianceJobRequest" {
    type = "object"
    description = "A request to create a new batch compliance job."
    required = ["type"]
    properties {
      resumable = boolean(description("If true, this endpoint will return a pre-signed URL with resumable uploads enabled."))
      type = string(description("Type of compliance job to list."), enum("tweets", "users"))
      name = components.schemas.ComplianceJobName
    }
  }
  components "schemas" "CreateTextMessageRequest" {
    type = "object"
    required = ["text"]
    properties {
      text = string(description("Text of the message."), minLength(1))
      attachments = components.schemas.DmAttachments
    }
  }
  components "schemas" "ConnectionExceptionProblem" {
    description = "A problem that indicates something is wrong with the connection."
    allOf = [components.schemas.Problem, object({
      connection_issue = string(enum("TooManyConnections", "ProvisioningSubscription", "RuleConfigurationIssue", "RulesInvalidIssue"))
    })]
  }
  components "schemas" "Get2SpacesResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      data = array(minItems(1), [components.schemas.Space])
    }
  }
  components "schemas" "UserUndeleteComplianceSchema" {
    required = ["user_undelete"]
    type = "object"
    properties {
      user_undelete = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "ContextAnnotationEntityFields" {
    type = "object"
    description = "Represents the data for the context annotation entity."
    required = ["id"]
    properties {
      name = string(description("Name of the context annotation entity."))
      description = string(description("Description of the context annotation entity."))
      id = string(description("The unique id for a context annotation entity."), pattern("^[0-9]{1,19}$"))
    }
  }
  components "schemas" "UnlikeComplianceSchema" {
    type = "object"
    required = ["favorite", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      favorite = object(required(["id", "user_id"]), {
        id = components.schemas.TweetId,
        user_id = components.schemas.UserId
      })
    }
  }
  components "schemas" "UnsupportedAuthenticationProblem" {
    description = "A problem that indicates that the authentication used is not supported."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "UsersLikesCreateRequest" {
    type = "object"
    required = ["tweet_id"]
    properties {
      tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "Get2TweetsSampleStreamResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
    }
  }
  components "schemas" "TweetEditComplianceObjectSchema" {
    type = "object"
    required = ["tweet", "event_at", "initial_tweet_id", "edit_tweet_ids"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      initial_tweet_id = components.schemas.TweetId
      tweet = object(required(["id"]), {
        id = components.schemas.TweetId
      })
      edit_tweet_ids = array(minItems(1), [components.schemas.TweetId])
    }
  }
  components "schemas" "InvalidRuleProblem" {
    description = "The rule you have submitted is invalid."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "ResultCount" {
    format = "int32"
    description = "The number of results returned in this response."
    type = "integer"
  }
  components "schemas" "UserWithheld" {
    description = "Indicates withholding details for [withheld content](https://help.twitter.com/en/rules-and-policies/tweet-withheld-by-country)."
    required = ["country_codes"]
    type = "object"
    properties {
      country_codes = array(description("Provides a list of countries where this content is not available."), minItems(1), uniqueItems(true), [components.schemas.CountryCode])
      scope = string(description("Indicates that the content being withheld is a `user`."), enum("user"))
    }
  }
  components "schemas" "Get2ComplianceJobsIdResponse" {
    type = "object"
    properties {
      data = components.schemas.ComplianceJob
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2TweetsCountsRecentResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.SearchCount])
      errors = array(minItems(1), [components.schemas.Problem])
      meta = object({
        oldest_id = components.schemas.OldestId,
        total_tweet_count = components.schemas.Aggregate,
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken
      })
    }
  }
  components "schemas" "Expansions" {
    type = "object"
    properties {
      users = array(minItems(1), [components.schemas.User])
      media = array(minItems(1), [components.schemas.Media])
      places = array(minItems(1), [components.schemas.Place])
      polls = array(minItems(1), [components.schemas.Poll])
      topics = array(minItems(1), [components.schemas.Topic])
      tweets = array(minItems(1), [components.schemas.Tweet])
    }
  }
  components "schemas" "Get2DmConversationsIdDmEventsResponse" {
    type = "object"
    properties {
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.DmEvent])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2UsersIdOwnedListsResponse" {
    type = "object"
    properties {
      meta = object({
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken
      })
      data = array(minItems(1), [components.schemas.List])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2UsersIdResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.User
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "CashtagFields" {
    description = "Represent the portion of text recognized as a Cashtag, and its start and end position within the text."
    required = ["tag"]
    type = "object"
    properties {
      tag = string(example("TWTR"))
    }
  }
  components "schemas" "DmEventId" {
    type = "string"
    description = "Unique identifier of a DM Event."
    example = "1146654567674912769"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "Variant" {
    type = "object"
    properties {
      bit_rate = integer(description("The bit rate of the media."))
      content_type = string(description("The content type of the media."))
      url = string(format("uri"), description("The url to the media."))
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
  components "schemas" "TweetNotice" {
    required = ["tweet", "event_type", "event_at", "application"]
    type = "object"
    properties {
      application = string(description("If the label is being applied or removed. Possible values are ‘apply’ or ‘remove’."), example("apply"))
      details = string(description("Information shown on the Tweet label"))
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      event_type = string(description("The type of label on the Tweet"), example("misleading"))
      extended_details_url = string(description("Link to more information about this kind of label"))
      label_title = string(description("Title/header of the Tweet label"))
      tweet = object(required(["id", "author_id"]), {
        id = components.schemas.TweetId,
        author_id = components.schemas.UserId
      })
    }
  }
  components "schemas" "Get2TweetsSearchAllResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.Tweet])
    }
  }
  components "schemas" "RuleId" {
    pattern = "^[0-9]{1,19}$"
    type = "string"
    description = "Unique identifier of this rule."
    example = "120897978112909812"
  }
  components "schemas" "TweetNoticeSchema" {
    type = "object"
    required = ["public_tweet_notice"]
    properties {
      public_tweet_notice = components.schemas.TweetNotice
    }
  }
  components "schemas" "UsersFollowingCreateRequest" {
    required = ["target_user_id"]
    type = "object"
    properties {
      target_user_id = components.schemas.UserId
    }
  }
  components "schemas" "ClientAppId" {
    minLength = 1
    maxLength = 19
    type = "string"
    description = "The ID of the client application"
  }
  components "schemas" "Get2TweetsIdLikingUsersResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken
      })
    }
  }
  components "schemas" "ResourceUnavailableProblem" {
    description = "A problem that indicates a particular Tweet, User, etc. is not available to you."
    allOf = [components.schemas.Problem, object(required(["parameter", "resource_id", "resource_type"]), {
      parameter = string(minLength(1)),
      resource_id = string(),
      resource_type = string(enum("user", "tweet", "media", "list", "space"))
    })]
  }
  components "schemas" "CreatedAt" {
    type = "string"
    format = "date-time"
    description = "Creation time of the compliance job."
    example = "2021-01-06T18:40:40.000Z"
  }
  components "schemas" "OperationalDisconnectProblem" {
    description = "You have been disconnected for operational reasons."
    allOf = [components.schemas.Problem, object({
      disconnect_type = string(enum("OperationalDisconnect", "UpstreamOperationalDisconnect", "ForceDisconnect", "UpstreamUncleanDisconnect", "SlowReader", "InternalError", "ClientApplicationStateDegraded", "InvalidRules"))
    })]
  }
  components "schemas" "PollOptionLabel" {
    maxLength = 25
    type = "string"
    description = "The text of a poll choice."
    minLength = 1
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
  components "schemas" "TweetHideRequest" {
    type = "object"
    required = ["hidden"]
    properties {
      hidden = boolean()
    }
  }
  components "schemas" "TweetId" {
    type = "string"
    description = "Unique identifier of this Tweet. This is returned as a string in order to avoid complications with languages and tools that cannot handle large integers."
    example = "1346889436626259968"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "AddOrDeleteRulesResponse" {
    description = "A response from modifying user-specified stream filtering rules."
    required = ["meta"]
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      meta = components.schemas.RulesResponseMetadata
      data = array(description("All user-specified stream filtering rules that were created."), [components.schemas.Rule])
    }
  }
  components "schemas" "Get2UsersByResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
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
  components "schemas" "ClientDisconnectedProblem" {
    description = "Your client has gone away."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "DmMediaAttachment" {
    type = "object"
    required = ["media_id"]
    properties {
      media_id = components.schemas.MediaId
    }
  }
  components "schemas" "Photo" {
    allOf = [components.schemas.Media, object({
      alt_text = string(),
      url = string(format("uri"))
    })]
  }
  components "schemas" "UserProfileModificationComplianceSchema" {
    type = "object"
    required = ["user_profile_modification"]
    properties {
      user_profile_modification = components.schemas.UserProfileModificationObjectSchema
    }
  }
  components "schemas" "FullTextEntities" {
    type = "object"
    properties {
      cashtags = array(minItems(1), [components.schemas.CashtagEntity])
      hashtags = array(minItems(1), [components.schemas.HashtagEntity])
      mentions = array(minItems(1), [components.schemas.MentionEntity])
      urls = array(minItems(1), [components.schemas.UrlEntity])
      annotations = array(minItems(1), [{
        allOf = [components.schemas.EntityIndicesInclusiveInclusive, object(description("Represents the data for the annotation."), {
          type = string(description("Annotation type."), example("Person")),
          normalized_text = string(description("Text used to determine annotation."), example("Barack Obama")),
          probability = number(format("double"), description("Confidence factor for annotation type."), maximum(1))
        })],
        description = "Annotation for entities based on the Tweet text."
      }])
    }
  }
  components "schemas" "Get2TweetsResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2UsersIdTimelinesReverseChronologicalResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        newest_id = components.schemas.NewestId
      })
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "ListAddUserRequest" {
    type = "object"
    required = ["user_id"]
    properties {
      user_id = components.schemas.UserId
    }
  }
  components "schemas" "Get2DmEventsResponse" {
    type = "object"
    properties {
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.DmEvent])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2SpacesSearchResponse" {
    type = "object"
    properties {
      meta = object({
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.Space])
      errors = array(minItems(1), [components.schemas.Problem])
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
  components "schemas" "EntityIndicesInclusiveExclusive" {
    required = ["start", "end"]
    type = "object"
    description = "Represent a boundary range (start and end index) for a recognized entity (for example a hashtag or a mention). `start` must be smaller than `end`.  The start index is inclusive, the end index is exclusive."
    properties {
      start = integer(description("Index (zero-based) at which position this entity starts.  The index is inclusive."), example(50))
      end = integer(description("Index (zero-based) at which position this entity ends.  The index is exclusive."), example(61))
    }
  }
  components "schemas" "TweetDeleteComplianceSchema" {
    type = "object"
    required = ["delete"]
    properties {
      delete = components.schemas.TweetComplianceSchema
    }
  }
  components "schemas" "Get2SpacesIdBuyersResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.User])
    }
  }
  components "schemas" "Get2UsersIdLikedTweetsResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "MediaHeight" {
    type = "integer"
    description = "The height of the media in pixels."
  }
  components "schemas" "PaginationToken32" {
    type = "string"
    description = "A base32 pagination token."
    minLength = 16
  }
  components "schemas" "ReplySettingsWithVerifiedUsers" {
    enum = ["everyone", "mentionedUsers", "following", "other", "subscribers", "verified"]
    pattern = "^[A-Za-z]{1,12}$"
    type = "string"
    description = "Shows who can reply a Tweet. Fields returned are everyone, mentioned_users, subscribers, verified and following."
  }
  components "schemas" "UserName" {
    type = "string"
    description = "The X handle (screen name) of this user."
    pattern = "^[A-Za-z0-9_]{1,15}$"
  }
  components "schemas" "ContextAnnotationDomainFields" {
    description = "Represents the data for the context annotation domain."
    required = ["id"]
    type = "object"
    properties {
      description = string(description("Description of the context annotation domain."))
      id = string(description("The unique id for a context annotation domain."), pattern("^[0-9]{1,19}$"))
      name = string(description("Name of the context annotation domain."))
    }
  }
  components "schemas" "DmAttachments" {
    type = "array"
    description = "Attachments to a DM Event."
    items = [components.schemas.DmMediaAttachment]
  }
  components "schemas" "RulesCapProblem" {
    description = "You have exceeded the maximum number of rules."
    allOf = [components.schemas.Problem]
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
  components "schemas" "DmEvent" {
    type = "object"
    required = ["id", "event_type"]
    properties {
      attachments = object(description("Specifies the type of attachments (if any) present in this DM."), {
        card_ids = array(description("A list of card IDs (if cards are attached)."), minItems(1), [string()]),
        media_keys = array(description("A list of Media Keys for each one of the media attachments (if media are attached)."), minItems(1), [components.schemas.MediaKey])
      })
      id = components.schemas.DmEventId
      event_type = string(example("MessageCreate"))
      sender_id = components.schemas.UserId
      dm_conversation_id = components.schemas.DmConversationId
      created_at = string(format("date-time"))
      participant_ids = array(description("A list of participants for a ParticipantsJoin or ParticipantsLeave event_type."), minItems(1), [components.schemas.UserId])
      hashtags = array(minItems(1), [components.schemas.HashtagEntity])
      cashtags = array(minItems(1), [components.schemas.CashtagEntity])
      mentions = array(minItems(1), [components.schemas.MentionEntity])
      referenced_tweets = array(description("A list of Posts this DM refers to."), minItems(1), [object(required(["id"]), {
        id = components.schemas.TweetId
      })])
      text = string()
      urls = array(minItems(1), [components.schemas.UrlEntityDm])
    }
  }
  components "schemas" "Get2UsersIdPinnedListsResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.List])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "ListCreateResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      data = object(description("A X List is a curated group of accounts."), required(["id", "name"]), {
        id = components.schemas.ListId,
        name = string(description("The name of this List."))
      })
    }
  }
  components "schemas" "TweetComplianceStreamResponse" {
    description = "Tweet compliance stream events."
    oneOf = [object(description("Compliance event."), required(["data"]), {
      data = components.schemas.TweetComplianceData
    }), object(required(["errors"]), {
      errors = array(minItems(1), [components.schemas.Problem])
    })]
  }
  components "schemas" "UserSuspendComplianceSchema" {
    required = ["user_suspend"]
    type = "object"
    properties {
      user_suspend = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "EntityIndicesInclusiveInclusive" {
    type = "object"
    description = "Represent a boundary range (start and end index) for a recognized entity (for example a hashtag or a mention). `start` must be smaller than `end`.  The start index is inclusive, the end index is inclusive."
    required = ["start", "end"]
    properties {
      start = integer(description("Index (zero-based) at which position this entity starts.  The index is inclusive."), example(50))
      end = integer(description("Index (zero-based) at which position this entity ends.  The index is inclusive."), example(61))
    }
  }
  components "schemas" "Get2TweetsSample10StreamResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "UsageCapExceededProblem" {
    description = "A problem that indicates that a usage cap has been exceeded."
    allOf = [components.schemas.Problem, object({
      period = string(enum("Daily", "Monthly")),
      scope = string(enum("Account", "Product"))
    })]
  }
  components "schemas" "PollId" {
    example = "1365059861688410112"
    pattern = "^[0-9]{1,19}$"
    type = "string"
    description = "Unique identifier of this poll."
  }
  components "schemas" "Topic" {
    type = "object"
    description = "The topic of a Space, as selected by its creator."
    required = ["id", "name"]
    properties {
      description = string(description("The description of the given topic."), example("All about technology"))
      id = components.schemas.TopicId
      name = string(description("The name of the given topic."), example("Technology"))
    }
  }
  components "schemas" "UserProfileModificationObjectSchema" {
    type = "object"
    required = ["user", "profile_field", "new_value", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      new_value = string()
      profile_field = string()
      user = object(required(["id"]), {
        id = components.schemas.UserId
      })
    }
  }
  components "schemas" "DownloadExpiration" {
    type = "string"
    format = "date-time"
    description = "Expiration time of the download URL."
    example = "2021-01-06T18:40:40.000Z"
  }
  components "schemas" "Get2TweetsCountsAllResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        total_tweet_count = components.schemas.Aggregate
      })
      data = array(minItems(1), [components.schemas.SearchCount])
    }
  }
  components "schemas" "Get2TweetsSearchRecentResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        oldest_id = components.schemas.OldestId,
        result_count = components.schemas.ResultCount,
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken
      })
    }
  }
  components "schemas" "UploadUrl" {
    description = "URL to which the user will upload their Tweet or user IDs."
    type = "string"
    format = "uri"
  }
  components "schemas" "ClientForbiddenProblem" {
    description = "A problem that indicates your client is forbidden from making this request."
    allOf = [components.schemas.Problem, object({
      reason = string(enum("official-client-forbidden", "client-not-enrolled")),
      registration_url = string(format("uri"))
    })]
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
  components "schemas" "HttpStatusCode" {
    type = "integer"
    description = "HTTP Status Code."
    minimum = 100
    maximum = 599
  }
  components "schemas" "UsersLikesDeleteResponse" {
    type = "object"
    properties {
      data = object({
        liked = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "LikesComplianceStreamResponse" {
    description = "Likes compliance stream events."
    oneOf = [object(description("Compliance event."), required(["data"]), {
      data = components.schemas.LikeComplianceSchema
    }), object(required(["errors"]), {
      errors = array(minItems(1), [components.schemas.Problem])
    })]
  }
  components "schemas" "ListUnpinResponse" {
    type = "object"
    properties {
      data = object({
        pinned = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "DmConversationId" {
    type = "string"
    description = "Unique identifier of a DM conversation. This can either be a numeric string, or a pair of numeric strings separated by a '-' character in the case of one-on-one DM Conversations."
    example = "123123123-456456456"
    pattern = "^([0-9]{1,19}-[0-9]{1,19}|[0-9]{15,19})$"
  }
  components "schemas" "Get2UsersIdFollowedListsResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.List])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "ListDeleteResponse" {
    type = "object"
    properties {
      data = object({
        deleted = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "StreamingLikeResponse" {
    type = "object"
    properties {
      data = components.schemas.Like
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "UserIdMatchesAuthenticatedUser" {
    type = "string"
    description = "Unique identifier of this User. The value must be the same as the authenticated user."
    example = "2244994945"
  }
  components "schemas" "DmParticipants" {
    items = [components.schemas.UserId]
    type = "array"
    description = "Participants for the DM Conversation."
    minItems = 2
    maxItems = 49
  }
  components "schemas" "Get2ListsIdTweetsResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.Tweet])
    }
  }
  components "schemas" "Get2TweetsIdRetweetsResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "Get2UsersMeResponse" {
    type = "object"
    properties {
      data = components.schemas.User
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "NewestId" {
    type = "string"
    description = "The newest id in this response."
  }
  components "schemas" "NonCompliantRulesProblem" {
    allOf = [components.schemas.Problem]
    description = "A problem that indicates the user's rule set is not compliant."
  }
  components "schemas" "TweetLabelStreamResponse" {
    description = "Tweet label stream events."
    oneOf = [object(description("Tweet Label event."), required(["data"]), {
      data = components.schemas.TweetLabelData
    }), object(required(["errors"]), {
      errors = array(minItems(1), [components.schemas.Problem])
    })]
  }
  components "schemas" "UserComplianceStreamResponse" {
    description = "User compliance stream events."
    oneOf = [object(description("User compliance event."), required(["data"]), {
      data = components.schemas.UserComplianceData
    }), object(required(["errors"]), {
      errors = array(minItems(1), [components.schemas.Problem])
    })]
  }
  components "schemas" "AppRulesCount" {
    type = "object"
    description = "A count of user-provided stream filtering rules at the client application level."
    properties {
      client_app_id = components.schemas.ClientAppId
      rule_count = integer(format("int32"), description("Number of rules for client application"))
    }
  }
  components "schemas" "Get2TweetsIdResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "PlaceId" {
    type = "string"
    description = "The identifier for this place."
    example = "f7eb2fa2fea288b1"
  }
  components "schemas" "UserScrubGeoSchema" {
    type = "object"
    required = ["scrub_geo"]
    properties {
      scrub_geo = components.schemas.UserScrubGeoObjectSchema
    }
  }
  components "schemas" "Aggregate" {
    format = "int32"
    description = "The sum of results returned in this response."
    type = "integer"
  }
  components "schemas" "Place" {
    required = ["id", "full_name"]
    type = "object"
    properties {
      name = string(description("The human readable name of this place."), example("Lakewood"))
      place_type = components.schemas.PlaceType
      contained_within = array(minItems(1), [components.schemas.PlaceId])
      country = string(description("The full name of the county in which this place exists."), example("United States"))
      country_code = components.schemas.CountryCode
      full_name = string(description("The full name of this place."), example("Lakewood, CO"))
      geo = components.schemas.Geo
      id = components.schemas.PlaceId
    }
  }
  components "schemas" "Get2TweetsFirehoseStreamLangEnResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Oauth1PermissionsProblem" {
    description = "A problem that indicates your client application does not have the required OAuth1 permissions for the requested endpoint."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "UserProtectComplianceSchema" {
    type = "object"
    required = ["user_protect"]
    properties {
      user_protect = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "BookmarkMutationResponse" {
    type = "object"
    properties {
      data = object({
        bookmarked = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "ClientAppUsage" {
    type = "object"
    description = "Usage per client app"
    properties {
      usage_result_count = integer(format("int32"), description("The number of results returned"))
      client_app_id = string(format("^[0-9]{1,19}$"), description("The unique identifier for this project"))
      usage = array(description("The usage value"), minItems(1), [components.schemas.UsageFields])
    }
  }
  components "schemas" "TweetDropComplianceSchema" {
    type = "object"
    required = ["drop"]
    properties {
      drop = components.schemas.TweetComplianceSchema
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
      data = array(minItems(1), [components.schemas.DmEvent])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "PollOption" {
    required = ["position", "label", "votes"]
    type = "object"
    description = "Describes a choice in a Poll object."
    properties {
      label = components.schemas.PollOptionLabel
      position = integer(description("Position of this choice in the poll."))
      votes = integer(description("Number of users who voted for this choice."))
    }
  }
  components "schemas" "PreviousToken" {
    type = "string"
    description = "The previous token."
    minLength = 1
  }
  components "schemas" "UserComplianceData" {
    description = "User compliance data."
    oneOf = [components.schemas.UserProtectComplianceSchema, components.schemas.UserUnprotectComplianceSchema, components.schemas.UserDeleteComplianceSchema, components.schemas.UserUndeleteComplianceSchema, components.schemas.UserSuspendComplianceSchema, components.schemas.UserUnsuspendComplianceSchema, components.schemas.UserWithheldComplianceSchema, components.schemas.UserScrubGeoSchema, components.schemas.UserProfileModificationComplianceSchema]
  }
  components "schemas" "HashtagEntity" {
    allOf = [components.schemas.EntityIndicesInclusiveExclusive, components.schemas.HashtagFields]
  }
  components "schemas" "MuteUserRequest" {
    type = "object"
    required = ["target_user_id"]
    properties {
      target_user_id = components.schemas.UserId
    }
  }
  components "schemas" "ReplySettings" {
    type = "string"
    description = "Shows who can reply a Tweet. Fields returned are everyone, mentioned_users, and following."
    enum = ["everyone", "mentionedUsers", "following", "other"]
    pattern = "^[A-Za-z]{1,12}$"
  }
  components "schemas" "ListPinnedRequest" {
    type = "object"
    required = ["list_id"]
    properties {
      list_id = components.schemas.ListId
    }
  }
  components "schemas" "MediaId" {
    type = "string"
    description = "The unique identifier of this Media."
    example = "1146654567674912769"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "CreateMessageRequest" {
    anyOf = [components.schemas.CreateTextMessageRequest, components.schemas.CreateAttachmentsMessageRequest]
  }
  components "schemas" "JobId" {
    type = "string"
    description = "Compliance Job ID."
    example = "1372966999991541762"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "ListUpdateResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      data = object({
        updated = boolean()
      })
    }
  }
  components "schemas" "Problem" {
    type = "object"
    description = "An HTTP Problem Details object, as defined in IETF RFC 7807 (https://tools.ietf.org/html/rfc7807)."
    required = ["type", "title"]
    discriminator {
      propertyName = "type"
      mapping {
        https://api.twitter.com/2/problems/noncompliant-rules = "#/components/schemas/NonCompliantRulesProblem"
        https://api.twitter.com/2/problems/operational-disconnect = "#/components/schemas/OperationalDisconnectProblem"
        https://api.twitter.com/2/problems/oauth1-permissions = "#/components/schemas/Oauth1PermissionsProblem"
        https://api.twitter.com/2/problems/client-forbidden = "#/components/schemas/ClientForbiddenProblem"
        https://api.twitter.com/2/problems/rule-cap = "#/components/schemas/RulesCapProblem"
        https://api.twitter.com/2/problems/resource-unavailable = "#/components/schemas/ResourceUnavailableProblem"
        https://api.twitter.com/2/problems/duplicate-rules = "#/components/schemas/DuplicateRuleProblem"
        https://api.twitter.com/2/problems/invalid-request = "#/components/schemas/InvalidRequestProblem"
        https://api.twitter.com/2/problems/resource-not-found = "#/components/schemas/ResourceNotFoundProblem"
        https://api.twitter.com/2/problems/invalid-rules = "#/components/schemas/InvalidRuleProblem"
        https://api.twitter.com/2/problems/unsupported-authentication = "#/components/schemas/UnsupportedAuthenticationProblem"
        https://api.twitter.com/2/problems/conflict = "#/components/schemas/ConflictProblem"
        https://api.twitter.com/2/problems/streaming-connection = "#/components/schemas/ConnectionExceptionProblem"
        https://api.twitter.com/2/problems/usage-capped = "#/components/schemas/UsageCapExceededProblem"
        about:blank = "#/components/schemas/GenericProblem"
        https://api.twitter.com/2/problems/client-disconnected = "#/components/schemas/ClientDisconnectedProblem"
        https://api.twitter.com/2/problems/disallowed-resource = "#/components/schemas/DisallowedResourceProblem"
        https://api.twitter.com/2/problems/not-authorized-for-field = "#/components/schemas/FieldUnauthorizedProblem"
        https://api.twitter.com/2/problems/not-authorized-for-resource = "#/components/schemas/ResourceUnauthorizedProblem"
      }
    }
    properties {
      type = string()
      detail = string()
      status = integer()
      title = string()
    }
  }
  components "schemas" "TweetUnviewableSchema" {
    type = "object"
    required = ["public_tweet_unviewable"]
    properties {
      public_tweet_unviewable = components.schemas.TweetUnviewable
    }
  }
  components "schemas" "UserWithheldComplianceSchema" {
    type = "object"
    required = ["user_withheld"]
    properties {
      user_withheld = components.schemas.UserTakedownComplianceSchema
    }
  }
  components "schemas" "AddOrDeleteRulesRequest" {
    oneOf = [components.schemas.AddRulesRequest, components.schemas.DeleteRulesRequest]
  }
  components "schemas" "ComplianceJob" {
    type = "object"
    required = ["id", "type", "created_at", "upload_url", "download_url", "upload_expires_at", "download_expires_at", "status"]
    properties {
      created_at = components.schemas.CreatedAt
      name = components.schemas.ComplianceJobName
      download_url = components.schemas.DownloadUrl
      id = components.schemas.JobId
      status = components.schemas.ComplianceJobStatus
      type = components.schemas.ComplianceJobType
      upload_url = components.schemas.UploadUrl
      download_expires_at = components.schemas.DownloadExpiration
      upload_expires_at = components.schemas.UploadExpiration
    }
  }
  components "schemas" "Get2UsersIdBlockingResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.User])
    }
  }
  components "schemas" "Get2UsersIdTweetsResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "TweetUnviewable" {
    type = "object"
    required = ["tweet", "event_at", "application"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      tweet = object(required(["id", "author_id"]), {
        author_id = components.schemas.UserId,
        id = components.schemas.TweetId
      })
      application = string(description("If the label is being applied or removed. Possible values are ‘apply’ or ‘remove’."), example("apply"))
    }
  }
  components "schemas" "UserComplianceSchema" {
    type = "object"
    required = ["user", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      user = object(required(["id"]), {
        id = components.schemas.UserId
      })
    }
  }
  components "schemas" "DeleteDmResponse" {
    type = "object"
    properties {
      data = object({
        deleted = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Start" {
    type = "string"
    format = "date-time"
    description = "The start time of the bucket."
  }
  components "schemas" "Get2LikesFirehoseStreamResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      data = components.schemas.Like
    }
  }
  components "schemas" "Variants" {
    type = "array"
    description = "An array of all available variants of the media."
    items = [components.schemas.Variant]
  }
  components "schemas" "UserSearchQuery" {
    type = "string"
    description = "The the search string by which to query for users."
    pattern = "^[A-Za-z0-9_]{1,32}$"
  }
  components "schemas" "DisallowedResourceProblem" {
    description = "A problem that indicates that the resource requested violates the precepts of this API."
    allOf = [components.schemas.Problem, object(required(["resource_id", "resource_type", "section"]), {
      resource_id = string(),
      resource_type = string(enum("user", "tweet", "media", "list", "space")),
      section = string(enum("data", "includes"))
    })]
  }
  components "schemas" "Point" {
    type = "object"
    description = "A [GeoJson Point](https://tools.ietf.org/html/rfc7946#section-3.1.2) geometry object."
    required = ["type", "coordinates"]
    properties {
      coordinates = components.schemas.Position
      type = string(example("Point"), enum("Point"))
    }
  }
  components "schemas" "StreamingTweetResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2UsageTweetsResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      data = components.schemas.Usage
    }
  }
  components "schemas" "Get2UsersResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "TweetUndropComplianceSchema" {
    required = ["undrop"]
    type = "object"
    properties {
      undrop = components.schemas.TweetComplianceSchema
    }
  }
  components "schemas" "UsersFollowingDeleteResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      data = object({
        following = boolean()
      })
    }
  }
  components "schemas" "RulesResponseMetadata" {
    type = "object"
    required = ["sent"]
    properties {
      sent = string()
      summary = components.schemas.RulesRequestSummary
      next_token = components.schemas.NextToken
      result_count = integer(format("int32"), description("Number of Rules in result set."))
    }
  }
  components "schemas" "TweetCreateRequest" {
    type = "object"
    properties {
      reply = {
        type = "object",
        description = "Tweet information of the Tweet being replied to.",
        required = ["in_reply_to_tweet_id"],
        properties = {
          exclude_reply_user_ids = array(description("A list of User Ids to be excluded from the reply Tweet."), [components.schemas.UserId]),
          in_reply_to_tweet_id = components.schemas.TweetId
        }
      }
      reply_settings = string(description("Settings to indicate who can reply to the Tweet."), enum("following", "mentionedUsers", "subscribers"))
      direct_message_deep_link = string(description("Link to take the conversation from the public timeline to a private Direct Message."))
      poll = {
        type = "object",
        description = "Poll options for a Tweet with a poll. This is mutually exclusive from Media, Quote Tweet Id, and Card URI.",
        required = ["options", "duration_minutes"],
        properties = {
          reply_settings = string(description("Settings to indicate who can reply to the Tweet."), enum("following", "mentionedUsers")),
          duration_minutes = integer(format("int32"), description("Duration of the poll in minutes."), minimum(5), maximum(10080)),
          options = array(maxItems(4), minItems(2), [string(description("The text of a poll choice."), maxLength(25), minLength(1))])
        }
      }
      quote_tweet_id = components.schemas.TweetId
      for_super_followers_only = boolean(description("Exclusive Tweet for super followers."), default(false))
      media = {
        type = "object",
        description = "Media information being attached to created Tweet. This is mutually exclusive from Quote Tweet Id, Poll, and Card URI.",
        required = ["media_ids"],
        properties = {
          media_ids = array(description("A list of Media Ids to be attached to a created Tweet."), maxItems(4), minItems(1), [components.schemas.MediaId]),
          tagged_user_ids = array(description("A list of User Ids to be tagged in the media for created Tweet."), maxItems(10), [components.schemas.UserId])
        }
      }
      nullcast = boolean(description("Nullcasted (promoted-only) Posts do not appear in the public timeline and are not served to followers."), default(false))
      text = components.schemas.TweetText
      card_uri = string(description("Card Uri Parameter. This is mutually exclusive from Quote Tweet Id, Poll, Media, and Direct Message Deep Link."))
      geo = {
        type = "object",
        description = "Place ID being attached to the Tweet for geo location.",
        properties = {
          place_id = string()
        }
      }
    }
  }
  components "schemas" "TweetEditComplianceSchema" {
    type = "object"
    required = ["tweet_edit"]
    properties {
      tweet_edit = components.schemas.TweetEditComplianceObjectSchema
    }
  }
  components "schemas" "TweetLabelData" {
    description = "Tweet label data."
    oneOf = [components.schemas.TweetNoticeSchema, components.schemas.TweetUnviewableSchema]
  }
  components "schemas" "BookmarkAddRequest" {
    type = "object"
    required = ["tweet_id"]
    properties {
      tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "Space" {
    type = "object"
    required = ["id", "state"]
    properties {
      topics = array(description("The topics of a Space, as selected by its creator."), [object(description("The X Topic object."), example({
        id = "848920371311001600",
        name = "Technology",
        description = "All about technology"
      }), required(["id", "name"]), {
        description = string(description("The description of the given topic.")),
        id = string(description("An ID suitable for use in the REST API.")),
        name = string(description("The name of the given topic."))
      })])
      is_ticketed = boolean(description("Denotes if the Space is a ticketed Space."), example(""false"
"))
      state = string(description("The current state of the Space."), example("live"), enum("live", "scheduled", "ended"))
      lang = string(description("The language of the Space."), example("en"))
      title = string(description("The title of the Space."), example("Spaces are Awesome"))
      host_ids = array(description("The user ids for the hosts of the Space."), [components.schemas.UserId])
      invited_user_ids = array(description("An array of user ids for people who were invited to a Space."), [components.schemas.UserId])
      updated_at = string(format("date-time"), description("When the Space was last updated."), example("2021-7-14T04:35:55Z"))
      created_at = string(format("date-time"), description("Creation time of the Space."), example("2021-07-06T18:40:40.000Z"))
      speaker_ids = array(description("An array of user ids for people who were speakers in a Space."), [components.schemas.UserId])
      creator_id = components.schemas.UserId
      id = components.schemas.SpaceId
      ended_at = string(format("date-time"), description("End time of the Space."), example("2021-07-06T18:40:40.000Z"))
      started_at = string(format("date-time"), description("When the Space was started as a date string."), example("2021-7-14T04:35:55Z"))
      subscriber_count = integer(format("int32"), description("The number of people who have either purchased a ticket or set a reminder for this Space."), example(10))
      participant_count = integer(format("int32"), description("The number of participants in a Space."), example(10))
      scheduled_start = string(format("date-time"), description("A date time stamp for when a Space is scheduled to begin."), example("2021-07-06T18:40:40.000Z"))
    }
  }
  components "schemas" "TopicId" {
    type = "string"
    description = "Unique identifier of this Topic."
  }
  components "schemas" "PaginationToken36" {
    type = "string"
    description = "A base36 pagination token."
    minLength = 1
  }
  components "schemas" "RuleValue" {
    type = "string"
    description = "The filterlang value of the rule."
    example = "coffee -is:retweet"
  }
  components "schemas" "Geo" {
    type = "object"
    required = ["type", "bbox", "properties"]
    properties {
      bbox = array(example(["-105.193475", "39.60973", "-105.053164", "39.761974"]), maxItems(4), minItems(4), [number(format("double"), minimum(-180), maximum(180))])
      geometry = components.schemas.Point
      properties = object()
      type = string(enum("Feature"))
    }
  }
  components "schemas" "NoteTweetText" {
    type = "string"
    description = "The note content of the Tweet."
    example = "Learn how to use the user Tweet timeline and user mention timeline endpoints in the X API v2 to explore Tweet\u2026 https:\/\/t.co\/56a0vZUx7i"
  }
  components "schemas" "ResourceUnauthorizedProblem" {
    description = "A problem that indicates you are not allowed to see a particular Tweet, User, etc."
    allOf = [components.schemas.Problem, object(required(["value", "resource_id", "resource_type", "section", "parameter"]), {
      section = string(enum("data", "includes")),
      value = string(),
      parameter = string(),
      resource_id = string(),
      resource_type = string(enum("user", "tweet", "media", "list", "space"))
    })]
  }
  components "schemas" "UserDeleteComplianceSchema" {
    type = "object"
    required = ["user_delete"]
    properties {
      user_delete = components.schemas.UserComplianceSchema
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
  components "schemas" "MentionEntity" {
    allOf = [components.schemas.EntityIndicesInclusiveExclusive, components.schemas.MentionFields]
  }
  components "schemas" "PaginationTokenLong" {
    type = "string"
    description = "A 'long' pagination token."
    minLength = 1
    maxLength = 19
  }
  components "schemas" "Usage" {
    type = "object"
    description = "Usage per client app"
    properties {
      project_id = string(format("^[0-9]{1,19}$"), description("The unique identifier for this project"))
      project_usage = integer(format("int32"), description("The number of Posts read in this project"))
      cap_reset_day = integer(format("int32"), description("Number of days left for the Tweet cap to reset"))
      daily_client_app_usage = array(description("The daily usage breakdown for each Client Application a project"), minItems(1), [components.schemas.ClientAppUsage])
      daily_project_usage = object(description("The daily usage breakdown for a project"), {
        usage = array(description("The usage value"), minItems(1), [components.schemas.UsageFields]),
        project_id = integer(format("int32"), description("The unique identifier for this project"))
      })
      project_cap = integer(format("int32"), description("Total number of Posts that can be read in this project per month"))
    }
  }
  components "schemas" "Get2UsersIdMentionsResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
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
  components "schemas" "Like" {
    type = "object"
    description = "A Like event, with the liking user and the tweet being liked"
    properties {
      id = components.schemas.LikeId
      liked_tweet_id = components.schemas.TweetId
      liking_user_id = components.schemas.UserId
      timestamp_ms = integer(format("int32"), description("Timestamp in milliseconds of creation."))
      created_at = string(format("date-time"), description("Creation time of the Tweet."), example("2021-01-06T18:40:40.000Z"))
    }
  }
  components "schemas" "CreateDmConversationRequest" {
    type = "object"
    required = ["conversation_type", "participant_ids", "message"]
    properties {
      conversation_type = string(description("The conversation type that is being created."), enum("Group"))
      message = components.schemas.CreateMessageRequest
      participant_ids = components.schemas.DmParticipants
    }
  }
  components "schemas" "MentionFields" {
    required = ["username"]
    type = "object"
    description = "Represent the portion of text recognized as a User mention, and its start and end position within the text."
    properties {
      id = components.schemas.UserId
      username = components.schemas.UserName
    }
  }
  components "schemas" "MuteUserMutationResponse" {
    type = "object"
    properties {
      data = object({
        muting = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "UserScrubGeoObjectSchema" {
    type = "object"
    required = ["user", "up_to_tweet_id", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      up_to_tweet_id = components.schemas.TweetId
      user = object(required(["id"]), {
        id = components.schemas.UserId
      })
    }
  }
  components "schemas" "AddRulesRequest" {
    type = "object"
    description = "A request to add a user-specified stream filtering rule."
    required = ["add"]
    properties {
      add = array([components.schemas.RuleNoId])
    }
  }
  components "schemas" "CreateAttachmentsMessageRequest" {
    required = ["attachments"]
    type = "object"
    properties {
      text = string(description("Text of the message."), minLength(1))
      attachments = components.schemas.DmAttachments
    }
  }
  components "schemas" "UrlEntityDm" {
    description = "Represent the portion of text recognized as a URL, and its start and end position within the text."
    allOf = [components.schemas.EntityIndicesInclusiveExclusive, components.schemas.UrlFields]
  }
  components "schemas" "AllProjectClientApps" {
    type = "array"
    description = "Client App Rule Counts for all applications in the project"
    items = [components.schemas.AppRulesCount]
  }
  components "schemas" "Error" {
    required = ["code", "message"]
    type = "object"
    properties {
      code = integer(format("int32"))
      message = string()
    }
  }
  components "schemas" "Get2UsersIdListMembershipsResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.List])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "TweetCount" {
    type = "integer"
    description = "The count for the bucket."
  }
  components "schemas" "UploadExpiration" {
    type = "string"
    format = "date-time"
    description = "Expiration time of the upload URL."
    example = "2021-01-06T18:40:40.000Z"
  }
  components "schemas" "UserUnsuspendComplianceSchema" {
    required = ["user_unsuspend"]
    type = "object"
    properties {
      user_unsuspend = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "CreateComplianceJobResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      data = components.schemas.ComplianceJob
    }
  }
  components "schemas" "DuplicateRuleProblem" {
    description = "The rule you have submitted is a duplicate."
    allOf = [components.schemas.Problem, object({
      id = string(),
      value = string()
    })]
  }
  components "schemas" "TweetComplianceSchema" {
    type = "object"
    required = ["tweet", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      quote_tweet_id = components.schemas.TweetId
      tweet = object(required(["id", "author_id"]), {
        author_id = components.schemas.UserId,
        id = components.schemas.TweetId
      })
    }
  }
  components "schemas" "UserId" {
    description = "Unique identifier of this User. This is returned as a string in order to avoid complications with languages and tools that cannot handle large integers."
    example = "2244994945"
    pattern = "^[0-9]{1,19}$"
    type = "string"
  }
  components "schemas" "UsersLikesCreateResponse" {
    type = "object"
    properties {
      data = object({
        liked = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "FilteredStreamingTweetResponse" {
    type = "object"
    description = "A Tweet or error that can be returned by the streaming Tweet API. The values returned with a successful streamed Tweet includes the user provided rules that the Tweet matched."
    properties {
      matching_rules = array(description("The list of rules which matched the Tweet"), [object(required(["id"]), {
        id = components.schemas.RuleId,
        tag = components.schemas.RuleTag
      })])
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Media" {
    type = "object"
    required = ["type"]
    discriminator {
      propertyName = "type"
      mapping {
        animated_gif = "#/components/schemas/AnimatedGif"
        photo = "#/components/schemas/Photo"
        video = "#/components/schemas/Video"
      }
    }
    properties {
      type = string()
      width = components.schemas.MediaWidth
      height = components.schemas.MediaHeight
      media_key = components.schemas.MediaKey
    }
  }
  components "schemas" "Get2UsersIdFollowersResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.User])
    }
  }
  components "schemas" "LikeComplianceSchema" {
    type = "object"
    required = ["delete"]
    properties {
      delete = components.schemas.UnlikeComplianceSchema
    }
  }
  components "schemas" "TweetTakedownComplianceSchema" {
    type = "object"
    required = ["tweet", "withheld_in_countries", "event_at"]
    properties {
      withheld_in_countries = array(minItems(1), [components.schemas.CountryCode])
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      quote_tweet_id = components.schemas.TweetId
      tweet = object(required(["id", "author_id"]), {
        author_id = components.schemas.UserId,
        id = components.schemas.TweetId
      })
    }
  }
  components "schemas" "UsersRetweetsCreateResponse" {
    type = "object"
    properties {
      data = object({
        id = components.schemas.TweetId,
        retweeted = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "UsersRetweetsDeleteResponse" {
    type = "object"
    properties {
      data = object({
        retweeted = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "ComplianceJobName" {
    example = "my-job"
    maxLength = 64
    type = "string"
    description = "User-provided name for a compliance job."
  }
  components "schemas" "Get2UsersIdBookmarksResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.Tweet])
    }
  }
  components "schemas" "UserUnprotectComplianceSchema" {
    type = "object"
    required = ["user_unprotect"]
    properties {
      user_unprotect = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "Video" {
    allOf = [components.schemas.Media, object({
      preview_image_url = string(format("uri")),
      promoted_metrics = object(description("Promoted nonpublic engagement metrics for the Media at the time of the request."), {
        playback_0_count = integer(format("int32"), description("Number of users who made it through 0% of the video.")),
        playback_100_count = integer(format("int32"), description("Number of users who made it through 100% of the video.")),
        playback_25_count = integer(format("int32"), description("Number of users who made it through 25% of the video.")),
        playback_50_count = integer(format("int32"), description("Number of users who made it through 50% of the video.")),
        playback_75_count = integer(format("int32"), description("Number of users who made it through 75% of the video.")),
        view_count = integer(format("int32"), description("Number of times this video has been viewed."))
      }),
      public_metrics = object(description("Engagement metrics for the Media at the time of the request."), {
        view_count = integer(format("int32"), description("Number of times this video has been viewed."))
      }),
      variants = components.schemas.Variants,
      duration_ms = integer(),
      non_public_metrics = object(description("Nonpublic engagement metrics for the Media at the time of the request."), {
        playback_0_count = integer(format("int32"), description("Number of users who made it through 0% of the video.")),
        playback_100_count = integer(format("int32"), description("Number of users who made it through 100% of the video.")),
        playback_25_count = integer(format("int32"), description("Number of users who made it through 25% of the video.")),
        playback_50_count = integer(format("int32"), description("Number of users who made it through 50% of the video.")),
        playback_75_count = integer(format("int32"), description("Number of users who made it through 75% of the video."))
      }),
      organic_metrics = object(description("Organic nonpublic engagement metrics for the Media at the time of the request."), {
        playback_50_count = integer(format("int32"), description("Number of users who made it through 50% of the video.")),
        playback_75_count = integer(format("int32"), description("Number of users who made it through 75% of the video.")),
        view_count = integer(format("int32"), description("Number of times this video has been viewed.")),
        playback_0_count = integer(format("int32"), description("Number of users who made it through 0% of the video.")),
        playback_100_count = integer(format("int32"), description("Number of users who made it through 100% of the video.")),
        playback_25_count = integer(format("int32"), description("Number of users who made it through 25% of the video."))
      })
    })]
  }
  components "schemas" "ComplianceJobStatus" {
    type = "string"
    description = "Status of a compliance job."
    enum = ["created", "in_progress", "failed", "complete", "expired"]
  }
  components "schemas" "InvalidRequestProblem" {
    description = "A problem that indicates this request is invalid."
    allOf = [components.schemas.Problem, object({
      errors = array(minItems(1), [object({
        message = string(),
        parameters = map(array([string()]))
      })])
    })]
  }
  components "schemas" "ListFollowedResponse" {
    type = "object"
    properties {
      data = object({
        following = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2SpacesIdTweetsResponse" {
    type = "object"
    properties {
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "LikeId" {
    description = "The unique identifier of this Like."
    example = "8ba4f34e6235d905a46bac021d98e923"
    pattern = "^[A-Za-z0-9_]{1,40}$"
    type = "string"
  }
  components "schemas" "UrlImage" {
    type = "object"
    description = "Represent the information for the URL image."
    properties {
      url = components.schemas.Url
      width = components.schemas.MediaWidth
      height = components.schemas.MediaHeight
    }
  }
  components "schemas" "Get2ListsIdResponse" {
    type = "object"
    properties {
      data = components.schemas.List
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "PlaceType" {
    type = "string"
    example = "city"
    enum = ["poi", "neighborhood", "city", "admin", "country", "unknown"]
  }
  components "schemas" "SpaceId" {
    description = "The unique identifier of this Space."
    example = "1SLjjRYNejbKM"
    pattern = "^[a-zA-Z0-9]{1,13}$"
    type = "string"
  }
  components "schemas" "TweetComplianceData" {
    description = "Tweet compliance data."
    oneOf = [components.schemas.TweetDeleteComplianceSchema, components.schemas.TweetWithheldComplianceSchema, components.schemas.TweetDropComplianceSchema, components.schemas.TweetUndropComplianceSchema, components.schemas.TweetEditComplianceSchema]
  }
  components "schemas" "UrlFields" {
    type = "object"
    description = "Represent the portion of text recognized as a URL."
    required = ["url"]
    properties {
      expanded_url = components.schemas.Url
      status = components.schemas.HttpStatusCode
      title = string(description("Title of the page the URL points to."), example("Introducing the v2 follow lookup endpoints"))
      display_url = string(description("The URL as displayed in the X client."), example("twittercommunity.com/t/introducing-…"))
      media_key = components.schemas.MediaKey
      url = components.schemas.Url
      description = string(description("Description of the URL landing page."), example("This is a description of the website."))
      images = array(minItems(1), [components.schemas.UrlImage])
      unwound_url = string(format("uri"), description("Fully resolved url."), example("https://twittercommunity.com/t/introducing-the-v2-follow-lookup-endpoints/147118"))
    }
  }
  components "schemas" "ConflictProblem" {
    allOf = [components.schemas.Problem]
    description = "You cannot create a new job if one is already in progress."
  }
  components "schemas" "Get2ComplianceJobsResponse" {
    type = "object"
    properties {
      meta = object({
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.ComplianceJob])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2TweetsFirehoseStreamLangJaResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "MediaKey" {
    description = "The Media Key identifier for this attachment."
    pattern = "^([0-9]+)_([0-9]+)$"
    type = "string"
  }
  components "schemas" "RuleTag" {
    type = "string"
    description = "A tag meant for the labeling of user provided rules."
    example = "Non-retweeted coffee Posts"
  }
  components "schemas" "Get2ListsIdFollowersResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "Get2SpacesByCreatorIdsResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.Space])
    }
  }
  components "schemas" "Poll" {
    type = "object"
    description = "Represent a Poll attached to a Tweet."
    required = ["id", "options"]
    properties {
      options = array(maxItems(4), minItems(2), [components.schemas.PollOption])
      voting_status = string(enum("open", "closed"))
      duration_minutes = integer(format("int32"), minimum(5), maximum(10080))
      end_datetime = string(format("date-time"))
      id = components.schemas.PollId
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
  components "schemas" "UsageFields" {
    type = "object"
    description = "Represents the data for Usage"
    properties {
      date = string(format("date-time"), description("The time period for the usage"), example("2021-01-06T18:40:40.000Z"))
      usage = integer(format("int32"), description("The usage value"))
    }
  }
  components "schemas" "UsersFollowingCreateResponse" {
    type = "object"
    properties {
      data = object({
        following = boolean(),
        pending_follow = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "CashtagEntity" {
    allOf = [components.schemas.EntityIndicesInclusiveExclusive, components.schemas.CashtagFields]
  }
  components "schemas" "Get2TweetsSearchStreamResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "RulesRequestSummary" {
    oneOf = [object(description("A summary of the results of the addition of user-specified stream filtering rules."), required(["created", "not_created", "valid", "invalid"]), {
      created = integer(format("int32"), description("Number of user-specified stream filtering rules that were created."), example(1)),
      invalid = integer(format("int32"), description("Number of invalid user-specified stream filtering rules."), example(1)),
      not_created = integer(format("int32"), description("Number of user-specified stream filtering rules that were not created."), example(1)),
      valid = integer(format("int32"), description("Number of valid user-specified stream filtering rules."), example(1))
    }), object(required(["deleted", "not_deleted"]), {
      not_deleted = integer(format("int32"), description("Number of user-specified stream filtering rules that were not deleted.")),
      deleted = integer(format("int32"), description("Number of user-specified stream filtering rules that were deleted."))
    })]
  }
  components "schemas" "SearchCount" {
    type = "object"
    description = "Represent a Search Count Result."
    required = ["end", "start", "tweet_count"]
    properties {
      start = components.schemas.Start
      tweet_count = components.schemas.TweetCount
      end = components.schemas.End
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
  components "schemas" "Get2TweetsFirehoseStreamResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "ListFollowedRequest" {
    type = "object"
    required = ["list_id"]
    properties {
      list_id = components.schemas.ListId
    }
  }
  components "schemas" "Get2DmEventsEventIdResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.DmEvent
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2ListsIdMembersResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken
      })
      data = array(minItems(1), [components.schemas.User])
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
  components "schemas" "OldestId" {
    type = "string"
    description = "The oldest id in this response."
  }
  components "schemas" "TweetWithheldComplianceSchema" {
    type = "object"
    required = ["withheld"]
    properties {
      withheld = components.schemas.TweetTakedownComplianceSchema
    }
  }
  components "schemas" "User" {
    type = "object"
    description = "The X User object."
    example = {
      created_at = "2013-12-14T04:35:55Z",
      id = "2244994945",
      name = "X Dev",
      protected = "false",
      username = "TwitterDev"
    }
    required = ["id", "name", "username"]
    properties {
      location = string(description("The location specified in the User's profile, if the User provided one. As this is a freeform value, it may not indicate a valid location, but it may be fuzzily evaluated when performing searches with location queries."))
      subscription_type = string(description("The X Blue subscription type of the user, eg: Basic, Premium, PremiumPlus or None."), enum("Basic", "Premium", "PremiumPlus", "None"))
      username = components.schemas.UserName
      withheld = components.schemas.UserWithheld
      receives_your_dm = boolean(description("Indicates if you can send a DM to this User"))
      entities = object(description("A list of metadata found in the User's profile description."), {
        description = components.schemas.FullTextEntities,
        url = object(description("Expanded details for the URL specified in the User's profile, with start and end indices."), {
          urls = array(minItems(1), [components.schemas.UrlEntity])
        })
      })
      most_recent_tweet_id = components.schemas.TweetId
      public_metrics = object(description("A list of metrics for this User."), required(["followers_count", "following_count", "tweet_count", "listed_count"]), {
        followers_count = integer(description("Number of Users who are following this User.")),
        following_count = integer(description("Number of Users this User is following.")),
        like_count = integer(description("The number of likes created by this User.")),
        listed_count = integer(description("The number of lists that include this User.")),
        tweet_count = integer(description("The number of Posts (including Retweets) posted by this User."))
      })
      profile_image_url = string(format("uri"), description("The URL to the profile image for this User."))
      protected = boolean(description("Indicates if this User has chosen to protect their Posts (in other words, if this User's Posts are private)."))
      verified = boolean(description("Indicate if this User is a verified X User."))
      connection_status = array(description("Returns detailed information about the relationship between two users."), [string(description("Type of connection between users."), enum("follow_request_received", "follow_request_sent", "blocking", "followed_by", "following", "muting"))])
      name = string(description("The friendly name of this User, as shown on their profile."))
      created_at = string(format("date-time"), description("Creation time of this User."))
      pinned_tweet_id = components.schemas.TweetId
      url = string(description("The URL specified in the User's profile."))
      verified_type = string(description("The X Blue verified type of the user, eg: blue, government, business or none."), enum("blue", "government", "business", "none"))
      description = string(description("The text of this User's profile description (also known as bio), if the User provided one."))
      id = components.schemas.UserId
    }
  }
  components "schemas" "CountryCode" {
    type = "string"
    description = "A two-letter ISO 3166-1 alpha-2 country code."
    example = "US"
    pattern = "^[A-Z]{2}$"
  }
  components "schemas" "DeleteRulesRequest" {
    type = "object"
    description = "A response from deleting user-specified stream filtering rules."
    required = ["delete"]
    properties {
      delete = object(description("IDs and values of all deleted user-specified stream filtering rules."), {
        ids = array(description("IDs of all deleted user-specified stream filtering rules."), [components.schemas.RuleId]),
        values = array(description("Values of all deleted user-specified stream filtering rules."), [components.schemas.RuleValue])
      })
    }
  }
  components "schemas" "ListPinnedResponse" {
    type = "object"
    properties {
      data = object({
        pinned = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "UserTakedownComplianceSchema" {
    type = "object"
    required = ["user", "withheld_in_countries", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      user = object(required(["id"]), {
        id = components.schemas.UserId
      })
      withheld_in_countries = array(minItems(1), [components.schemas.CountryCode])
    }
  }
  components "schemas" "MediaWidth" {
    type = "integer"
    description = "The width of the media in pixels."
  }
  components "schemas" "TweetDeleteResponse" {
    type = "object"
    properties {
      data = object(required(["deleted"]), {
        deleted = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2UsersByUsernameUsernameResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.User
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "ResourceNotFoundProblem" {
    description = "A problem that indicates that a given Tweet, User, etc. does not exist."
    allOf = [components.schemas.Problem, object(required(["parameter", "value", "resource_id", "resource_type"]), {
      parameter = string(minLength(1)),
      resource_id = string(),
      resource_type = string(enum("user", "tweet", "media", "list", "space")),
      value = string(description("Value will match the schema of the field."))
    })]
  }
  components "schemas" "End" {
    type = "string"
    format = "date-time"
    description = "The end time of the bucket."
  }
  components "schemas" "Get2LikesSample10StreamResponse" {
    type = "object"
    properties {
      data = components.schemas.Like
      errors = array(minItems(1), [components.schemas.Problem])
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
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2SpacesIdResponse" {
    type = "object"
    properties {
      data = components.schemas.Space
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2TweetsIdQuoteTweetsResponse" {
    type = "object"
    properties {
      meta = object({
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken
      })
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2UsersIdMutingResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.User])
    }
  }
  components "schemas" "ListMutateResponse" {
    type = "object"
    properties {
      data = object({
        is_member = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "CreateDmEventResponse" {
    type = "object"
    properties {
      data = object(required(["dm_conversation_id", "dm_event_id"]), {
        dm_event_id = components.schemas.DmEventId,
        dm_conversation_id = components.schemas.DmConversationId
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "FieldUnauthorizedProblem" {
    description = "A problem that indicates that you are not allowed to see a particular field on a Tweet, User, etc."
    allOf = [components.schemas.Problem, object(required(["resource_type", "field", "section"]), {
      field = string(),
      resource_type = string(enum("user", "tweet", "media", "list", "space")),
      section = string(enum("data", "includes"))
    })]
  }
  components "schemas" "ListCreateRequest" {
    type = "object"
    required = ["name"]
    properties {
      description = string(maxLength(100))
      name = string(maxLength(25), minLength(1))
      private = boolean(default(false))
    }
  }
  components "schemas" "Tweet" {
    required = ["id", "text", "edit_history_tweet_ids"]
    type = "object"
    example = {
      author_id = "2244994945",
      created_at = "Wed Jan 06 18:40:40 +0000 2021",
      id = "1346889436626259968",
      text = "Learn how to use the user Tweet timeline and user mention timeline endpoints in the X API v2 to explore Tweet\u2026 https:\/\/t.co\/56a0vZUx7i"
    }
    properties {
      attachments = object(description("Specifies the type of attachments (if any) present in this Tweet."), {
        media_keys = array(description("A list of Media Keys for each one of the media attachments (if media are attached)."), minItems(1), [components.schemas.MediaKey]),
        media_source_tweet_id = array(description("A list of Posts the media on this Tweet was originally posted in. For example, if the media on a tweet is re-used in another Tweet, this refers to the original, source Tweet.."), minItems(1), [components.schemas.TweetId]),
        poll_ids = array(description("A list of poll IDs (if polls are attached)."), minItems(1), [components.schemas.PollId])
      })
      conversation_id = components.schemas.TweetId
      edit_controls = object(required(["is_edit_eligible", "editable_until", "edits_remaining"]), {
        editable_until = string(format("date-time"), description("Time when Tweet is no longer editable."), example("2021-01-06T18:40:40.000Z")),
        edits_remaining = integer(description("Number of times this Tweet can be edited.")),
        is_edit_eligible = boolean(description("Indicates if this Tweet is eligible to be edited."), example(false))
      })
      entities = components.schemas.FullTextEntities
      id = components.schemas.TweetId
      author_id = components.schemas.UserId
      geo = object(description("The location tagged on the Tweet, if the user provided one."), {
        coordinates = components.schemas.Point,
        place_id = components.schemas.PlaceId
      })
      referenced_tweets = array(description("A list of Posts this Tweet refers to. For example, if the parent Tweet is a Retweet, a Quoted Tweet or a Reply, it will include the related Tweet referenced to by its parent."), minItems(1), [object(required(["type", "id"]), {
        id = components.schemas.TweetId,
        type = string(enum("retweeted", "quoted", "replied_to"))
      })])
      scopes = object(description("The scopes for this tweet"), {
        followers = boolean(description("Indicates if this Tweet is viewable by followers without the Tweet ID"), example(false))
      })
      non_public_metrics = object(description("Nonpublic engagement metrics for the Tweet at the time of the request."), {
        impression_count = integer(format("int32"), description("Number of times this Tweet has been viewed."))
      })
      reply_settings = components.schemas.ReplySettingsWithVerifiedUsers
      withheld = components.schemas.TweetWithheld
      edit_history_tweet_ids = array(description("A list of Tweet Ids in this Tweet chain."), minItems(1), [components.schemas.TweetId])
      in_reply_to_user_id = components.schemas.UserId
      organic_metrics = object(description("Organic nonpublic engagement metrics for the Tweet at the time of the request."), required(["impression_count", "retweet_count", "reply_count", "like_count"]), {
        impression_count = integer(description("Number of times this Tweet has been viewed.")),
        like_count = integer(description("Number of times this Tweet has been liked.")),
        reply_count = integer(description("Number of times this Tweet has been replied to.")),
        retweet_count = integer(description("Number of times this Tweet has been Retweeted."))
      })
      source = string(description("This is deprecated."))
      created_at = string(format("date-time"), description("Creation time of the Tweet."), example("2021-01-06T18:40:40.000Z"))
      note_tweet = object(description("The full-content of the Tweet, including text beyond 280 characters."), {
        entities = object({
          mentions = array(minItems(1), [components.schemas.MentionEntity]),
          urls = array(minItems(1), [components.schemas.UrlEntity]),
          cashtags = array(minItems(1), [components.schemas.CashtagEntity]),
          hashtags = array(minItems(1), [components.schemas.HashtagEntity])
        }),
        text = components.schemas.NoteTweetText
      })
      context_annotations = array(minItems(1), [components.schemas.ContextAnnotation])
      text = components.schemas.TweetText
      lang = string(description("Language of the Tweet, if detected by X. Returned as a BCP47 language tag."), example("en"))
      possibly_sensitive = boolean(description("Indicates if this Tweet contains URLs marked as sensitive, for example content suitable for mature audiences."), example(false))
      promoted_metrics = object(description("Promoted nonpublic engagement metrics for the Tweet at the time of the request."), {
        retweet_count = integer(format("int32"), description("Number of times this Tweet has been Retweeted.")),
        impression_count = integer(format("int32"), description("Number of times this Tweet has been viewed.")),
        like_count = integer(format("int32"), description("Number of times this Tweet has been liked.")),
        reply_count = integer(format("int32"), description("Number of times this Tweet has been replied to."))
      })
      public_metrics = object(description("Engagement metrics for the Tweet at the time of the request."), required(["retweet_count", "reply_count", "like_count", "impression_count", "bookmark_count"]), {
        impression_count = integer(format("int32"), description("Number of times this Tweet has been viewed.")),
        like_count = integer(description("Number of times this Tweet has been liked.")),
        quote_count = integer(description("Number of times this Tweet has been quoted.")),
        reply_count = integer(description("Number of times this Tweet has been replied to.")),
        retweet_count = integer(description("Number of times this Tweet has been Retweeted.")),
        bookmark_count = integer(format("int32"), description("Number of times this Tweet has been bookmarked."))
      })
    }
  }
  components "schemas" "Url" {
    type = "string"
    format = "uri"
    description = "A validly formatted URL."
    example = "https://developer.twitter.com/en/docs/twitter-api"
  }
  components "schemas" "UrlEntity" {
    description = "Represent the portion of text recognized as a URL, and its start and end position within the text."
    allOf = [components.schemas.EntityIndicesInclusiveExclusive, components.schemas.UrlFields]
  }
  components "schemas" "ComplianceJobType" {
    type = "string"
    description = "Type of compliance job to list."
    enum = ["tweets", "users"]
  }
  components "schemas" "List" {
    type = "object"
    description = "A X List is a curated group of accounts."
    required = ["id", "name"]
    properties {
      member_count = integer()
      name = string(description("The name of this List."))
      owner_id = components.schemas.UserId
      private = boolean()
      created_at = string(format("date-time"))
      description = string()
      follower_count = integer()
      id = components.schemas.ListId
    }
  }
  components "schemas" "ListId" {
    type = "string"
    description = "The unique identifier of this List."
    example = "1146654567674912769"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "TweetCreateResponse" {
    type = "object"
    properties {
      data = object(required(["id", "text"]), {
        id = components.schemas.TweetId,
        text = components.schemas.TweetText
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "AnimatedGif" {
    allOf = [components.schemas.Media, object({
      preview_image_url = string(format("uri")),
      variants = components.schemas.Variants
    })]
  }
  components "schemas" "Get2UsersSearchResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken
      })
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2TweetsFirehoseStreamLangKoResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
    }
  }
  components "schemas" "TweetText" {
    type = "string"
    description = "The content of the Tweet."
    example = "Learn how to use the user Tweet timeline and user mention timeline endpoints in the X API v2 to explore Tweet\u2026 https:\/\/t.co\/56a0vZUx7i"
  }
  components "schemas" "GenericProblem" {
    description = "A generic problem with no additional information beyond that provided by the HTTP status code."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "Get2TrendsByWoeidWoeidResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.Trend])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "parameters" "LikeFieldsParameter" {
    name = "like.fields"
    in = "query"
    schema = array(description("The fields available for a Like object."), example(["created_at", "id", "liked_tweet_id", "liking_user_id", "timestamp_ms"]), minItems(1), uniqueItems(true), [string(enum("created_at", "id", "liked_tweet_id", "liking_user_id", "timestamp_ms"))])
    description = "A comma separated list of Like fields to display."
    style = "form"
  }
  components "parameters" "UserExpansionsParameter" {
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
    schema = array(description("The list of fields you can expand for a [User](#User) object. If the field has an ID, it can be expanded into a full object."), example(["most_recent_tweet_id", "pinned_tweet_id"]), minItems(1), uniqueItems(true), [string(enum("most_recent_tweet_id", "pinned_tweet_id"))])
    style = "form"
  }
  components "parameters" "UsageFieldsParameter" {
    name = "usage.fields"
    in = "query"
    description = "A comma separated list of Usage fields to display."
    schema = array(description("The fields available for a Usage object."), example(["cap_reset_day", "daily_client_app_usage", "daily_project_usage", "project_cap", "project_id", "project_usage"]), minItems(1), uniqueItems(true), [string(enum("cap_reset_day", "daily_client_app_usage", "daily_project_usage", "project_cap", "project_id", "project_usage"))])
    style = "form"
  }
  components "parameters" "DmConversationFieldsParameter" {
    name = "dm_conversation.fields"
    in = "query"
    description = "A comma separated list of DmConversation fields to display."
    style = "form"
    schema = array(description("The fields available for a DmConversation object."), example(["id"]), minItems(1), uniqueItems(true), [string(enum("id"))])
  }
  components "parameters" "TweetExpansionsParameter" {
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
    style = "form"
    schema = array(description("The list of fields you can expand for a [Tweet](#Tweet) object. If the field has an ID, it can be expanded into a full object."), example(["attachments.media_keys", "attachments.media_source_tweet", "attachments.poll_ids", "author_id", "edit_history_tweet_ids", "entities.mentions.username", "geo.place_id", "in_reply_to_user_id", "entities.note.mentions.username", "referenced_tweets.id", "referenced_tweets.id.author_id"]), minItems(1), uniqueItems(true), [string(enum("attachments.media_keys", "attachments.media_source_tweet", "attachments.poll_ids", "author_id", "edit_history_tweet_ids", "entities.mentions.username", "geo.place_id", "in_reply_to_user_id", "entities.note.mentions.username", "referenced_tweets.id", "referenced_tweets.id.author_id"))])
  }
  components "parameters" "ListFieldsParameter" {
    description = "A comma separated list of List fields to display."
    style = "form"
    schema = array(description("The fields available for a List object."), example(["created_at", "description", "follower_count", "id", "member_count", "name", "owner_id", "private"]), minItems(1), uniqueItems(true), [string(enum("created_at", "description", "follower_count", "id", "member_count", "name", "owner_id", "private"))])
    name = "list.fields"
    in = "query"
  }
  components "parameters" "ListExpansionsParameter" {
    in = "query"
    description = "A comma separated list of fields to expand."
    style = "form"
    name = "expansions"
    schema = array(description("The list of fields you can expand for a [List](#List) object. If the field has an ID, it can be expanded into a full object."), example(["owner_id"]), minItems(1), uniqueItems(true), [string(enum("owner_id"))])
  }
  components "parameters" "PollFieldsParameter" {
    style = "form"
    schema = array(description("The fields available for a Poll object."), example(["duration_minutes", "end_datetime", "id", "options", "voting_status"]), minItems(1), uniqueItems(true), [string(enum("duration_minutes", "end_datetime", "id", "options", "voting_status"))])
    name = "poll.fields"
    in = "query"
    description = "A comma separated list of Poll fields to display."
  }
  components "parameters" "TrendFieldsParameter" {
    name = "trend.fields"
    in = "query"
    description = "A comma separated list of Trend fields to display."
    style = "form"
    schema = array(description("The fields available for a Trend object."), example(["trend_name", "tweet_count"]), minItems(1), uniqueItems(true), [string(enum("trend_name", "tweet_count"))])
  }
  components "parameters" "ComplianceJobFieldsParameter" {
    description = "A comma separated list of ComplianceJob fields to display."
    style = "form"
    schema = array(description("The fields available for a ComplianceJob object."), example(["created_at", "download_expires_at", "download_url", "id", "name", "resumable", "status", "type", "upload_expires_at", "upload_url"]), minItems(1), uniqueItems(true), [string(enum("created_at", "download_expires_at", "download_url", "id", "name", "resumable", "status", "type", "upload_expires_at", "upload_url"))])
    name = "compliance_job.fields"
    in = "query"
  }
  components "parameters" "LikeExpansionsParameter" {
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
    style = "form"
    schema = array(description("The list of fields you can expand for a [Like](#Like) object. If the field has an ID, it can be expanded into a full object."), example(["liked_tweet_id", "liking_user_id"]), minItems(1), uniqueItems(true), [string(enum("liked_tweet_id", "liking_user_id"))])
  }
  components "parameters" "DmEventFieldsParameter" {
    in = "query"
    description = "A comma separated list of DmEvent fields to display."
    style = "form"
    schema = array(description("The fields available for a DmEvent object."), example(["attachments", "created_at", "dm_conversation_id", "entities", "event_type", "id", "participant_ids", "referenced_tweets", "sender_id", "text"]), minItems(1), uniqueItems(true), [string(enum("attachments", "created_at", "dm_conversation_id", "entities", "event_type", "id", "participant_ids", "referenced_tweets", "sender_id", "text"))])
    name = "dm_event.fields"
  }
  components "parameters" "UserFieldsParameter" {
    description = "A comma separated list of User fields to display."
    schema = array(description("The fields available for a User object."), example(["connection_status", "created_at", "description", "entities", "id", "location", "most_recent_tweet_id", "name", "pinned_tweet_id", "profile_image_url", "protected", "public_metrics", "receives_your_dm", "subscription_type", "url", "username", "verified", "verified_type", "withheld"]), minItems(1), uniqueItems(true), [string(enum("connection_status", "created_at", "description", "entities", "id", "location", "most_recent_tweet_id", "name", "pinned_tweet_id", "profile_image_url", "protected", "public_metrics", "receives_your_dm", "subscription_type", "url", "username", "verified", "verified_type", "withheld"))])
    style = "form"
    name = "user.fields"
    in = "query"
  }
  components "parameters" "TopicFieldsParameter" {
    name = "topic.fields"
    in = "query"
    description = "A comma separated list of Topic fields to display."
    style = "form"
    schema = array(description("The fields available for a Topic object."), example(["description", "id", "name"]), minItems(1), uniqueItems(true), [string(enum("description", "id", "name"))])
  }
  components "parameters" "DmEventExpansionsParameter" {
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
    style = "form"
    schema = array(description("The list of fields you can expand for a [DmEvent](#DmEvent) object. If the field has an ID, it can be expanded into a full object."), example(["attachments.media_keys", "participant_ids", "referenced_tweets.id", "sender_id"]), minItems(1), uniqueItems(true), [string(enum("attachments.media_keys", "participant_ids", "referenced_tweets.id", "sender_id"))])
  }
  components "parameters" "PlaceFieldsParameter" {
    style = "form"
    name = "place.fields"
    in = "query"
    description = "A comma separated list of Place fields to display."
    schema = array(description("The fields available for a Place object."), example(["contained_within", "country", "country_code", "full_name", "geo", "id", "name", "place_type"]), minItems(1), uniqueItems(true), [string(enum("contained_within", "country", "country_code", "full_name", "geo", "id", "name", "place_type"))])
  }
  components "parameters" "SpaceExpansionsParameter" {
    style = "form"
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
    schema = array(description("The list of fields you can expand for a [Space](#Space) object. If the field has an ID, it can be expanded into a full object."), example(["creator_id", "host_ids", "invited_user_ids", "speaker_ids", "topic_ids"]), minItems(1), uniqueItems(true), [string(enum("creator_id", "host_ids", "invited_user_ids", "speaker_ids", "topic_ids"))])
  }
  components "parameters" "MediaFieldsParameter" {
    name = "media.fields"
    in = "query"
    description = "A comma separated list of Media fields to display."
    schema = array(description("The fields available for a Media object."), example(["alt_text", "duration_ms", "height", "media_key", "non_public_metrics", "organic_metrics", "preview_image_url", "promoted_metrics", "public_metrics", "type", "url", "variants", "width"]), minItems(1), uniqueItems(true), [string(enum("alt_text", "duration_ms", "height", "media_key", "non_public_metrics", "organic_metrics", "preview_image_url", "promoted_metrics", "public_metrics", "type", "url", "variants", "width"))])
    style = "form"
  }
  components "parameters" "RulesCountFieldsParameter" {
    description = "A comma separated list of RulesCount fields to display."
    style = "form"
    name = "rules_count.fields"
    in = "query"
    schema = array(description("The fields available for a RulesCount object."), example(["all_project_client_apps", "cap_per_client_app", "cap_per_project", "client_app_rules_count", "project_rules_count"]), minItems(1), uniqueItems(true), [string(enum("all_project_client_apps", "cap_per_client_app", "cap_per_project", "client_app_rules_count", "project_rules_count"))])
  }
  components "parameters" "SearchCountFieldsParameter" {
    description = "A comma separated list of SearchCount fields to display."
    style = "form"
    schema = array(description("The fields available for a SearchCount object."), example(["end", "start", "tweet_count"]), minItems(1), uniqueItems(true), [string(enum("end", "start", "tweet_count"))])
    name = "search_count.fields"
    in = "query"
  }
  components "parameters" "TweetFieldsParameter" {
    style = "form"
    name = "tweet.fields"
    schema = array(description("The fields available for a Tweet object."), example(["attachments", "author_id", "card_uri", "context_annotations", "conversation_id", "created_at", "edit_controls", "edit_history_tweet_ids", "entities", "geo", "id", "in_reply_to_user_id", "lang", "non_public_metrics", "note_tweet", "organic_metrics", "possibly_sensitive", "promoted_metrics", "public_metrics", "referenced_tweets", "reply_settings", "scopes", "source", "text", "withheld"]), minItems(1), uniqueItems(true), [string(enum("attachments", "author_id", "card_uri", "context_annotations", "conversation_id", "created_at", "edit_controls", "edit_history_tweet_ids", "entities", "geo", "id", "in_reply_to_user_id", "lang", "non_public_metrics", "note_tweet", "organic_metrics", "possibly_sensitive", "promoted_metrics", "public_metrics", "referenced_tweets", "reply_settings", "scopes", "source", "text", "withheld"))])
    in = "query"
    description = "A comma separated list of Tweet fields to display."
  }
  components "parameters" "SpaceFieldsParameter" {
    style = "form"
    name = "space.fields"
    in = "query"
    description = "A comma separated list of Space fields to display."
    schema = array(description("The fields available for a Space object."), example(["created_at", "creator_id", "ended_at", "host_ids", "id", "invited_user_ids", "is_ticketed", "lang", "participant_count", "scheduled_start", "speaker_ids", "started_at", "state", "subscriber_count", "title", "topic_ids", "updated_at"]), minItems(1), uniqueItems(true), [string(enum("created_at", "creator_id", "ended_at", "host_ids", "id", "invited_user_ids", "is_ticketed", "lang", "participant_count", "scheduled_start", "speaker_ids", "started_at", "state", "subscriber_count", "title", "topic_ids", "updated_at"))])
  }
  components "securitySchemes" "BearerToken" {
    type = "http"
    scheme = "bearer"
  }
  components "securitySchemes" "OAuth2UserToken" {
    type = "oauth2"
    flows {
      authorizationCode {
        authorizationUrl = "https://api.twitter.com/2/oauth2/authorize"
        tokenUrl = "https://api.twitter.com/2/oauth2/token"
        scopes {
          list.write = "Create and manage Lists for you."
          offline.access = "App can request refresh token."
          dm.read = "All your Direct Messages"
          follows.read = "People who follow you and people who you follow."
          list.read = "Lists, list members, and list followers of lists you’ve created or are a member of, including private lists."
          space.read = "Access all of the Spaces you can see."
          tweet.write = "Tweet and retweet for you."
          block.read = "Accounts you’ve blocked."
          dm.write = "Send and manage Direct Messages for you"
          bookmark.read = "Allows an app to read bookmarked Tweets"
          follows.write = "Follow and unfollow people for you."
          like.write = "Like and un-like Tweets for you."
          users.read = "Any account you can see, including protected accounts. Any account you can see, including protected accounts."
          mute.read = "Accounts you’ve muted."
          mute.write = "Mute and unmute accounts for you."
          like.read = "Tweets you’ve liked and likes you can view."
          tweet.read = "All the Tweets you can see, including Tweets from protected accounts."
          bookmark.write = "Allows an app to create and delete bookmarks"
          tweet.moderate.write = "Hide and unhide replies to your Tweets."
        }
      }
    }
  }
  components "securitySchemes" "UserToken" {
    type = "http"
    scheme = "OAuth"
  }
